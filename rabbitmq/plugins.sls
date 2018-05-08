{% from "rabbitmq/map.jinja" import rabbitmq with context %}

include:
  - rabbitmq.configure
  - rabbitmq.install

{% for plugin in rabbitmq.get('plugins', []) %}
{% if plugin.get('package_name', []) %}
download_rabbitmq_plugin_{{ plugin.name }}:
  file.managed:
    - name: /usr/lib/rabbitmq/lib/rabbitmq_server-{{ rabbitmq.version.split('-')[0] }}/plugins/{{ package_name }}
    - source: https://dl.bintray.com/rabbitmq/community-plugins/{{ rabbitmq.version.split('-')[0][:-1] }}.x/{{ package_name }}
    - source_hash: {{ plugin.package_hash }}
    - require_in:
        - rabbitmq_plugin: install_rabbitmq_plugin_{{ plugin.name }}
    - require:
        - pkg: install_rabbitmq_server
{% endif %}

set_rabbitmq_plugin_{{ plugin.name }}_state:
  rabbitmq_plugin.{{ plugin.state }}:
    - name: {{ plugin.name }}
    - require:
        - pkg: install_rabbitmq_server
{% endfor %}
