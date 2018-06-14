{% from "rabbitmq/map.jinja" import rabbitmq with context %}
{% set rabbitmq_config = salt.pillar.get('rabbitmq:configuration') %}
{% set rabbitmq_env = salt.pillar.get('rabbitmq:environment') %}
{% set rabbitmq_config_dir = '/etc/rabbitmq' %}

set_system_locale_for_rabbitmq:
  locale.system:
    - name: en_US.UTF-8

write_erlang_cookie_for_rabbitmq:
  file.managed:
    - name: /var/lib/rabbitmq/.erlang.cookie
    - contents_pillar: rabbitmq:erlang_cookie

write_rabbitmq_config:
  file.managed:
    - name: {{ rabbitmq_config_dir }}/rabbitmq.conf
    - makedirs: True
    - source: salt://rabbitmq/templates/conf.jinja
    - template: jinja
    - context:
        settings: {{ rabbitmq_config }}

{% if rabbitmq_env %}
write_rabbitmq_env_config:
  file.managed:
    - name: {{ rabbitmq_config_dir }}/rabbitmq-env.conf
    - makedirs: True
    - source: salt://rabbitmq/templates/conf.jinja
    - template: jinja
    - context:
        settings: {{ rabbitmq_env }}
{% endif %}

increase_file_descriptor_limit:
  cmd.run:
    - name: sysctl -w fs.file-max={{ rabbitmq.fd_limit }}
  file.append:
    - name: /etc/sysctl.conf
    - text: fs.file_max={{ rabbitmq.fd_limit }}
