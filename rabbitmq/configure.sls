#!pyobjects
from __future__ import division

import re
import socket
import collections
from bisect import bisect

include('rabbitmq.service')


def update(d, u):
    """Recursively merge two dictionaries. Adapted from
    http://stackoverflow.com/a/3233356/5221054"""
    for k, v in u.items():
        if isinstance(v, collections.Mapping):
            r = update(d.get(k, {}), v)
            d[k] = r
        elif isinstance(v, list):
            d[k] = d.get(k, [])
            d[k] += v
        else:
            d[k] = u[k]
    return d


def is_ipaddr(addr_string):
    try:
        socket.inet_pton(socket.AF_INET, addr_string)
    except (AttributeError, OSError, socket.error):
        try:
            socket.inet_pton(socket.AF_INET6, addr_string)
        except (AttributeError, OSError, socket.error):
            return False
    return True


def determine_ram_limit():
    """Calculate the RAM Limit as recommended in
    http://www.rabbitmq.com/production-checklist.html"""
    MINIMUM_RAM = 128
    system_ram = grains('mem_total')
    min_ratio = MINIMUM_RAM / system_ram
    ram_ranges = [4096, 8192, 16384]
    ram_ratios = [0.75, 0.8, 0.85, 0.9]
    return max(min_ratio, ram_ratios[bisect(ram_ranges, system_ram)])


def determine_disk_limit():
    """Calculate the disk limit as recommended in
    http://www.rabbitmq.com/production-checklist.html"""
    MINIMUM_DISK = 2048
    rabbit_mountpoint = pillar('rabbitmq:mount_path', '/')
    total_disk = salt.status.diskusage(rabbit_mountpoint)[
        rabbit_mountpoint]['total'] / 1024 / 1024
    system_ram = grains('mem_total')
    min_ratio = 2048 / total_disk
    max_ratio = 0.7
    ram_ranges = [8192, 32768]
    ram_ratios = [0.5, 0.4, 0.3]
    set_ratio = ram_ratios[bisect(ram_ranges, system_ram)]
    space_override = (system_ram * set_ratio) > total_disk
    limit = {'mem_relative': max(set_ratio, min_ratio)}
    if space_override:
        limit = total_disk * max_ratio
    return limit


def gen_erlang_config(data):
    """Given a Python data structure, generate a valid Erlang config file"""
    def recurse_settings(settings):
        conf_string = ''
        for k, v in settings.items():
            conf_string += '{{{key}, '.format(key=k if not is_ipaddr(k)
                                              else '"{}"'.format(k))
            if isinstance(v, dict):
                conf_string += '{0}}},\n'.format(recurse_settings(v))
            if isinstance(v, (int, float)):
                conf_string += '{value}}},\n'.format(value=v)
            if isinstance(v, str):
                conf_string += '"{value}"}},\n'.format(value=v)
            if isinstance(v, list):
                temp_string = ''
                for val in v:
                    if isinstance(val, str):
                        temp_string += '"{0}",\n '.format(val)
                    elif isinstance(val, (int, float)):
                        temp_string += '{0},\n '.format(val)
                    elif isinstance(val, dict):
                        temp_string += recurse_settings(val)
                conf_string += '[{0}]}},\n'.format(temp_string.strip(',\n '))
        return conf_string.strip(',\n')
    config = '['
    for app, settings in data.items():
        config += '{{{0},\n ['.format(app)
        config += recurse_settings(settings)
        config += ']},\n'
    config = config.strip(',\n')
    config += '].'
    return config

rabbit_conf = {
    'rabbit': {
        'vm_memory_high_watermark': determine_ram_limit(),
        'vm_memory_high_watermark_paging_ratio': determine_ram_limit(),
        'disk_free_limit': determine_disk_limit(),
    }
}

rabbit_pillar_conf = pillar('rabbitmq:configuration', {})

rabbit_conf = update(rabbit_conf, rabbit_pillar_conf)

rabbitmq_config = File.managed('generate_rabbitmq_config_file',
                               name='/etc/rabbitmq/rabbitmq.config',
                               contents=gen_erlang_config(rabbit_conf),
                               makedirs=True,
                               watch_in=Service('rabbitmq_service_running'))

rabbitmq_external_configs = pillar('rabbitmq:external_configs', {})

rabbitmq_env_contents = ['{k}={v}'.format(k=key, v=value) for key, value in
                         pillar('rabbitmq:env', {}).items()]

with Service('rabbitmq_service_running', 'watch_in'):
    File.managed('generate_rabbitmq_env_file',
                 name='/etc/rabbitmq/rabbitmq-env.conf',
                 contents='\n'.join(rabbitmq_env_contents))

    File.managed('set_rabbitmq_erlang_cookie',
                 name='/var/lib/rabbitmq/.erlang.cookie',
                 user='rabbitmq',
                 group='rabbitmq',
                 contents=pillar('rabbitmq:erlang_cookie',
                                 salt.hashutil.md5_digest(
                                     str(pillar('rabbitmq:configuration',
                                                {})).lower())),
                 mode='0400')

    # The rabbitmq-server command starts up the erlang VM but then when
    # trying to call systemctl restart rabbitmq-server it uses rabbitmqctl
    # which doesn't affect the state of the underlying erlang VM. In order
    # to be able to change the erlang cookie and the erlang env variables the
    # VM itself needs to be restarted. Since there is no service management
    # layer for the VM specifically it is necessary to use the kill command.
    Cmd.wait('stop_erlang_vm',
             name='pkill beam',
             watch=[File('set_rabbitmq_erlang_cookie'),
                    File('generate_rabbitmq_env_file')])

    for fname, config_data in rabbitmq_external_configs.items():
        File.managed('rabbitmq_external_config_{0}'.format(fname),
                     name='/etc/rabbitmq/rabbitmq.d/{0}.config'.format(fname),
                     contents=gen_erlang_config(config_data),
                     makedirs=True)
