{% from "rabbitmq/map.jinja" import rabbitmq with context %}

include:
  - .service
  - .configure

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

install_rabbitmq_server:
  pkg.installed:
    - sources:
        - rabbitmq-server: http://www.rabbitmq.com/releases/rabbitmq-server/v{{ rabbitmq.version.split('-')[0] }}/rabbitmq-server_{{ rabbitmq.version }}{{ rabbitmq.pkg_suffix }}
    - require:
        - pkg: install_erlang_pkgs
    - require_in:
        - service: rabbitmq_service_running
        - file: generate_rabbitmq_config_file

enable_rabbitmq_env_tool:
  file.symlink:
    - name: /usr/local/bin/rabbitmq-env
    - target: /usr/lib/rabbitmq/bin/rabbitmq-env
    - makedirs: True
    - require:
        - pkg: install_rabbitmq_server

enable_rabbitmq_plugin_tool:
  file.symlink:
    - name: /usr/local/bin/rabbitmq-plugins
    - target: /usr/lib/rabbitmq/bin/rabbitmq-plugins
    - makedirs: True
    - require:
        - pkg: install_rabbitmq_server
