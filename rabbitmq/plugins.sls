{% from "rabbitmq/map.jinja" import rabbitmq with context %}

include:
  - .configure
  - .install

{% for plugin in rabbitmq.get('plugins', []) %}
{% if plugin.get('package_name') %}
download_rabbitmq_plugin_{{ plugin.name }}:
  file.managed:
    - name: /usr/lib/rabbitmq/lib/rabbitmq_server-{{ rabbitmq.version.split('-')[0] }}/plugins/{{ plugin.package_name }}
    - source: https://www.rabbitmq.com/community-plugins/v3.6.x/{{ plugin.package_name }}
    - source_hash: {{ plugin.package_hash }}
    - require_in:
        - rabbitmq_plugin: install_rabbitmq_plugin_{{ plugin.name }}
    - require:
        - pkg: install_rabbitmq_server
{% endif %}

install_rabbitmq_plugin_{{ plugin.name }}:
  rabbitmq_plugin.{{ plugin.state }}:
    - name: {{ plugin.name }}
    - onlyif: test -e /usr/local/bin/rabbitmq-plugins
    - require:
        - pkg: install_rabbitmq_server
        - file: enable_rabbitmq_plugin_tool
        - file: enable_rabbitmq_env_tool
    - require_in:
        - file: generate_rabbitmq_env_file
        - file: generate_rabbitmq_config_file
{% endfor %}
