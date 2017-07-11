{% set autocluster_version = salt.pillar.get('rabbitmq:autocluster:version', '0.8.0') %}
{% set autocluster_hash = salt.pillar.get('rabbitmq:autocluster:hash', '7004cb50d63f4cf88dd3af4478b8a845647d405f4394e3863e6e6811d2cba12b') %}
{% set aws_hash = salt.pillar.get('rabbitmq:autocluster:aws_hash', 'cc3867d587c22777104b6c9f0209721d9840e14fb08b5bb8d940a0027f7f7ec3') %}

include:
  - rabbitmq.service

install_rabbitmq_aws_rabbitmq_plugin:
  file.managed:
    - name: /usr/lib/rabbitmq/lib/rabbitmq_server-{{ salt.pillar.get('rabbitmq:overrides:version', '3.6.2-1').split('-')[0] }}/plugins/rabbitmq_aws.ez
    - source: https://github.com/rabbitmq/rabbitmq-autocluster/releases/download/{{ autocluster_version }}/rabbitmq_aws-{{ autocluster_version }}.ez
    - source_hash: {{ aws_hash }}
  rabbitmq_plugin.enabled:
    - name: rabbitmq_aws
    - watch:
        - file: install_rabbitmq_aws_rabbitmq_plugin
    - watch_in:
        - service: rabbitmq_service_running

install_autocluster_rabbitmq_plugin:
  file.managed:
    - name: /usr/lib/rabbitmq/lib/rabbitmq_server-{{ salt.pillar.get('rabbitmq:overrides:version', '3.6.2-1').split('-')[0] }}/plugins/rabbitmq_autocluster.ez
    - source: https://github.com/rabbitmq/rabbitmq-autocluster/releases/download/{{ autocluster_version }}/autocluster-{{ autocluster_version }}.ez
    - source_hash: {{ autocluster_hash }}
  rabbitmq_plugin.enabled:
    - name: autocluster
    - watch:
        - file: install_autocluster_rabbitmq_plugin
    - watch_in:
        - service: rabbitmq_service_running
    - require:
        - rabbitmq_plugin: install_rabbitmq_aws_rabbitmq_plugin
