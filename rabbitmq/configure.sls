#!pydsl
from __future__ import division

import re
import socket
import collections
from bisect import bisect

include('rabbitmq.service')


def update(d, u):
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
    MINIMUM_RAM = 128
    system_ram = __grains__['mem_total']
    min_ratio = MINIMUM_RAM / system_ram
    ram_ranges = [4096, 8192, 16384]
    ram_ratios = [0.75, 0.8, 0.85, 0.9]
    return max(min_ratio, ram_ratios[bisect(ram_ranges, system_ram)])


def determine_disk_limit():
    MINIMUM_DISK = 2048
    rabbit_mountpoint = __salt__['pillar.get']('rabbitmq:mount_path', '/')
    total_disk = __salt__['status.diskusage'](rabbit_mountpoint)[
        rabbit_mountpoint]['total'] / 1024 / 1024
    system_ram = __grains__['mem_total']
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
                conf_string += '[{vlist}]}},\n'.format(vlist=',\n  '.join([
                    val if not isinstance(val, dict)
                    else recurse_settings(val) for val in v
                ]))
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

rabbit_pillar_conf = __salt__['pillar.get']('rabbitmq:configuration', {})

rabbit_conf = update(rabbit_conf, rabbit_pillar_conf)

rabbitmq_config = state('generate_rabbitmq_config_file').file.managed(
    name='/etc/rabbitmq/rabbitmq.config',
    contents=gen_erlang_config(rabbit_conf),
    makedirs=True
).watch_in(service='rabbitmq_service_running')

erlang_cookie = state('set_rabbitmq_erlang_cookie').file.managed(
    name='/var/lib/rabbitmq/.erlang.cookie',
    user='rabbitmq',
    group='rabbitmq',
    contents=__salt__['hashutil.md5_digest'](
        str(__salt__['pillar.get']('rabbitmq_configuration', {})).lower()),
    mode='0400'
)

kill_erlang = state('stop_erlang_vm').cmd.wait(
    name='pkill beam'
).watch(
    file='set_rabbitmq_erlang_cookie'
).watch_in(service='rabbitmq_service_running')
