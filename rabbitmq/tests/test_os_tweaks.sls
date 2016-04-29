{% from "rabbitmq/map.jinja" import rabbitmq with context %}

verify_file_descriptor_limit_configuration:
  testinfra.file:
    - name: /etc/sysctl.conf
    - contains:
        parameter: fs.file_max={{ rabbitmq.fd_limit }}
        expected: True
        comparison: is_

verify_file_descriptor_limit:
  testinfra.command:
    - name: sysctl fs.file-max
    - stdout:
        expected: '{{ rabbitmq.fd_limit }}$'
        comparison: search
