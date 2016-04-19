{% from "rabbitmq/map.jinja" import rabbitmq, rabbitmq_config with context %}

include:
  - rabbitmq

rabbitmq-config:
  file.managed:
    - name: {{ rabbitmq.conf_file }}
    - source: salt://rabbitmq/templates/conf.jinja
    - template: jinja
    - context:
      config: {{ rabbitmq_config }}
    - watch_in:
      - service: rabbitmq
    - require:
      - pkg: rabbitmq
