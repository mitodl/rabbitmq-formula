{% set listen_ports = salt.pillar.get('rabbitmq:configuration:rabbit:tcp_listeners', [5672]) %}

test_rabbitmq_service_running:
  testinfra.service:
    - name: rabbitmq-server
    - is_running: True
    - is_enabled: True

{% for port in listen_ports %}
{% if port is mapping %}
{% for ip, portnum in port.items() %}
test_rabbitmq_listening_{{ ip }}:
  testinfra.socket:
    - name: 'tcp://{{ ip }}:{{ portnum }}'
    - is_listening: True
{% endfor %}
{% else %}
test_rabbitmq_listening_{{ port }}:
  testinfra.socket:
    - name: 'tcp://:::{{ port }}'
    - is_listening: True
{% endif %}
{% endfor %}
