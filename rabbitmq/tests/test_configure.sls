{% from "rabbitmq/map.jinja" import rabbitmq with context %}

verify_file_descriptor_limit_configuration:
  testinfra.file:
    - name: /etc/sysctl.conf
    - contains:
        parameter: fs.file_max={{ rabbitmq.fd_limit }}
        expected: True
        comparison: is_

verify_file_descriptor_limit:
  testinfra.command:
    - name: sysctl fs.file-max
    - stdout:
        expected: '{{ rabbitmq.fd_limit }}$'
        comparison: search

test_rabbitmq_config:
  testinfra.file:
    - name: /etc/rabbitmq/rabbitmq.config
    - exists: True

{% if salt.pillar.get('rabbitmq:env', {}) %}
test_rabbitmq_env:
  testinfra.file:
    - name: /etc/rabbitmq/rabbitmq-env.conf
    - exists: True
    - contains:
        parameter: {{ salt.pillar.get('rabbitmq:env').keys()[0] }}
        expected: True
        comparison: is_
{% endif %}
