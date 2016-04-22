{% from "rabbitmq/map.jinja" import rabbitmq with context %}

{% for plugin in rabbitmq.get('plugins', []) %}
{% if plugin.get('package_name') %}
download_rabbitmq_plugin_{{ plugin.name }}:
  file.managed:
    - name: /usr/lib/rabbitmq/lib/rabbitmq_server-{{ rabbitmq.version.split('-')[0] }}/plugins/{{ plugin.package_name }}
    - source: https://www.rabbitmq.com/community-plugins/v3.6.x/{{ plugin.package_name }}
    - source_hash: {{ plugin.package_hash }}
{% endif %}

install_rabbitmq_plugin_{{ plugin.name }}:
  rabbitmq_plugin.{{ plugin.state }}:
    - name: {{ plugin.name }}
    - onlyif: test -e /usr/local/bin/rabbitmq-plugins
{% endfor %}
