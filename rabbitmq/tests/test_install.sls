{% from "rabbitmq/map.jinja" import rabbitmq with context %}

test_install_erlang_solutions_repository:
  testinfra.package:
    - name: erlang-solutions
    - is_installed: True

test_install_erlang_pkgs:
  testinfra.package:
    - name: esl-erlang
    - is_installed: True

test_rabbitmq_pkg:
  testinfra.package:
    - name: rabbitmq-server
    - is_installed: True
    - version:
        expected: {{ rabbitmq.version }}
        comparison: eq

test_rabbitmq_plugin_tool:
  testinfra.file:
    - name: /usr/lib/rabbitmq/bin/rabbitmq-plugins
    - is_file: True
    - exists: True
    - is_symlink: True
