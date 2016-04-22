#!pydsl
from __future__ import division
import logging
logging.basicConfig()
log = logging.getLogger(__name__)

from bisect import bisect

def determine_ram_limit():
    # TODO: make this overridable by pillar data
    pillar_limit = __salt__['pillar.get']('rabbitmq:ram_limit')
    if pillar_limit:
        return pillar_limit
    MINIMUM_RAM = 128
    system_ram = __grains__['mem_total']
    min_ratio = MINIMUM_RAM / system_ram
    ram_ranges = [4096, 8192, 16384]
    ram_ratios = [0.75, 0.8, 0.85, 0.9]
    return max(min_ratio, ram_ratios[bisect(ram_ranges, system_ram)])


def determine_disk_limit():
    # TODO: make this configurable as to the partition used
    MINIMUM_DISK = 2048
    total_disk = __salt__['status.diskusage']('/')['/']['total'] / 1024 / 1024
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
        print('CONF STRING IS: ', conf_string)
        for k, v in settings.items():
            conf_string += '{{{key}, '.format(key=k)
            if isinstance(v, dict):
                conf_string += '{0}}},\n'.format(recurse_settings(v))
            if isinstance(v, (int, float)):
                conf_string += '{value}}},\n'.format(value=v)
            if isinstance(v, str):
                conf_string += '"{value}"}},\n'.format(value=v)
        return conf_string.strip(',\n')
    config = '['
    for app, settings in data:
        config += '{{{0}, ['.format(app)
        config += recurse_settings(settings)
        config += ']},\n'
    config = config.strip(',\n')
    config += ']'
    return config

rabbit_conf = {
    'vm_memory_high_watermark': determine_ram_limit(),
    'vm_memory_high_watermark_paging_ratio': determine_ram_limit(),
    'disk_free_limit': determine_disk_limit(),
}

rabbitmq_config = state('generate_rabbitmq_config_file').file.managed(
    name='/etc/rabbitmq/rabbitmq.config',
    contents=gen_erlang_config([('rabbit', rabbit_conf)]),
    makedirs=True
)
