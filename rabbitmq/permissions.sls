include:
  - .service

{% for user in salt.pillar.get('rabbitmq:users', []) %}
rabbitmq_user_{{ user.name }}_{{ user.state }}:
  rabbitmq_user.{{ user.state }}:
    - name: {{ user.name }}
    {% for key, value in user.get('settings', {}).items() %}
    - {{ key }}: {{ value }}
    {% endfor %}
    - require:
        - service: rabbitmq_service_running
{% endfor %}

{% for vhost in salt.pillar.get('rabbitmq:vhosts', []) %}
rabbitq_vhost_{{ vhost.name }}_{{ vhost.state }}:
  rabbitmq_vhost.{{ vhost.state }}:
    - name: {{ vhost.name }}
    {% for key, value in vhost.get('settings', {}).items() %}
    - {{ key }}: {{ value }}
    {% endfor %}
    - require:
        - service: rabbitmq_service_running
{% endfor %}

{% for policy in salt.pillar.get('rabbitmq:policies', []) %}
rabbitq_policy_{{ policy.name }}_{{ policy.state }}:
  rabbitmq_policy.{{ policy.state }}:
    {% for key, value in policy.get('settings', {}).items() %}
    - {{ key }}: {{ value }}
    {% endfor %}
    - require:
        - service: rabbitmq_service_running
{% endfor %}
