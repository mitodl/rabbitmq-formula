{% from "rabbitmq/map.jinja" import rabbitmq with context %}
{% set rabbitmq_config = salt.pillar.get('rabbitmq:configuration') %}
{% set rabbitmq_config_dir = '/etc/rabbitmq' %}

set_system_locale_for_rabbitmq:
  locale.system:
    - name: en_US.UTF-8

write_rabbitmq_config:
  file.managed:
    - name: {{ rabbitmq_config_dir }}/rabbitmq.conf
    - makedirs: True
    - source: salt://rabbitmq/templates/conf.jinja
    - template: jinja
    - context:
        settings: {{ rabbitmq_config }}

increase_file_descriptor_limit:
  cmd.run:
    - name: sysctl -w fs.file-max={{ rabbitmq.fd_limit }}
  file.append:
    - name: /etc/sysctl.conf
    - text: fs.file_max={{ rabbitmq.fd_limit }}
