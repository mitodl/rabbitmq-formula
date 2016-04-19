{% from "rabbitmq/map.jinja" import rabbitmq with context %}

install_erlang_solutions_repository:
  pkg.installed:
    - sources:
        - erlang-solutions: http://packages.erlang-solutions.com/{{ rabbitmq.esl_repo_pkg }}

install_erlang_pkgs:
  pkg.installed:
    - pkgs: {{ rabbitmq.pkgs }}
    - require:
        - pkg: install_erlang_solutions_repository
    - update: True

rabbitmq:
  pkg.installed:
    - sources:
        - rabbitmq-server: http://www.rabbitmq.com/releases/rabbitmq-server/v{{ rabbitmq.version.split('-')[0] }}/rabbitmq-server_{{ rabbitmq.version }}{{ rabbitmq.pkg_suffix }}
    - require:
        - pkg: install_erlang_pkgs
  service.running:
    - name: {{ rabbitmq.service }}
    - enable: True
    - require:
      - pkg: rabbitmq
