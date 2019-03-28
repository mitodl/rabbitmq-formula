{% from "rabbitmq/map.jinja" import rabbitmq with context %}

rabbitmq_service_running:
  service.running:
    - name: {{ rabbitmq.service }}
    - enable: True
    - onchanges:
        - file: /etc/rabbitmq/rabbitmq.conf
