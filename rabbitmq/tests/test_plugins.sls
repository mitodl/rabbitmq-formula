{% from "rabbitmq/map.jinja" import rabbitmq with context %}

{% for plugin in rabbitmq.get('plugins', []) %}
verify_{{ plugin.name }}_plugin_is_installed:
  testinfra.command:
    - name: rabbitmq-plugins list
    - stdout:
        expected: '\[[Ee] \] {{ plugin.name }}\s+'
        comparison: search
{% endfor %}
