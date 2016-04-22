{% from "rabbitmq/map.jinja" import rabbitmq with context %}

set_rabbitmq_ram_limit:
  file.append:
    # TODO: update RAM limit based on system availability (http://www.rabbitmq.com/production-checklist.html)

set_rabbitmq_disk_space_alarm_limits:
  file.append:
    # TODO: determine and set appropriate limit

set_rabbitmq_open_file_handle_limit:


set_rabbitmq_erlang_cookie:
  file.managed:
    - name: /var/lib/rabbitmq/.erlang.cookie
    - user: rabbitmq
    - group: rabbitmq
    - content: 
