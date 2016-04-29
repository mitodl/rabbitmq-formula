test_rabbitmq_config:
  testinfra.file:
    - name: /etc/rabbitmq/rabbitmq.config
    - exists: True
    - contains:
        parameter: vm_memory_high_watermark
        expected: True
        comparison: is_

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
