{% from "rabbitmq/map.jinja" import rabbitmq with context %}

rabbitmq:
  pkg.installed:
    - pkgs: {{ rabbitmq.pkgs }}
  service:
    - running
    - name: {{ rabbitmq.service }}
    - enable: True
    - require:
      - pkg: rabbitmq
