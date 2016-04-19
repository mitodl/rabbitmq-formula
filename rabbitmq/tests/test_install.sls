test_install_erlang_solutions_repository:
  testinfra.package:
    - name: erlang-solutions
    - is_installed: True

test_install_erlang_pkgs:
  testinfra.package:
    - name: erlang-nox
    - is_installed: True

test_rabbitmq_pkg:
  testinfra.package:
    - name: rabbitmq-server
    - is_installed: True
    - version:
        expected: 3.6.1-1
        comparison: eq

test_rabbitmq_service:
  testinfra.service:
    - name: rabbitmq-server
    - is_running: True
    - is_enabled: True
