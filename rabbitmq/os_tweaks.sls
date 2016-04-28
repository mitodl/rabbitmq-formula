{% from "rabbitmq/map.jinja" import rabbitmq with context %}

increase_file_descriptor_limit:
  cmd.run:
    - name: sysctl -w fs.file-max={{ rabbitmq.fd_limit }}
  file.append:
    - name: /etc/sysctl.conf
    - text: fs.file_max={{ rabbitmq.fd_limit }}

# TODO: add options for tweaking other factors, such as TCP
# settings, etc.
