{% from "rabbitmq/map.jinja" import rabbitmq with context %}
{% set oscodename = salt.grains.get('oscodename') %}
{% set os = salt.grains.get('os') %}
{% set osmajorrelease = salt.grains.get('osmajorrelease') %}
{% set os_family = salt.grains.get('os_family') %}

add_erlang_pkg_repo:
  pkgrepo.managed:
    - humanname: erlang-solutions
    {% if os_family == 'Debian' %}
    - name: deb https://packages.erlang-solutions.com/debian {{ oscodename }} contrib
    - key_url: https://packages.erlang-solutions.com/debian/erlang_solutions.asc
    {% elif os_family == 'RedHat' %}
    - name: erlang
    - baseurl: https://packages.erlang-solutions.com/rpm/{{ os.lower() }}/{{ osmajorrelease }}/x86_64
    - gpgkey: https://packages.erlang-solutions.com/rpm/erlang_solutions.asc
    {% endif %}
    - gpgcheck: 1
    - enabled: 1
    - refresh_db: True

install_esl_erlang_solutions:
  pkg.installed:
    - name: esl-erlang
    - version: '{{ rabbitmq.erlang_version }}'
    - require:
        - pkgrepo: add_erlang_pkg_repo

add_rabbitmq_pkg_repo:
  pkgrepo.managed:
    - name: RabbitMQ
    {% if os_family == 'Debian' %}
    - name: deb https://dl.bintray.com/rabbitmq/debian {{ oscodename }} main
    - key_url: https://dl.bintray.com/rabbitmq/Keys/rabbitmq-release-signing-key.asc
    {% elif os_family == 'RedHat' %}
    - baseurl: https://bintray.com/rabbitmq/rpm/rabbitmq-server
    - gpgkey: https://dl.bintray.com/rabbitmq/Keys/rabbitmq-release-signing-key.asc
    {% endif %}
    - gpgcheck: 1
    - enabled: 1
    - refresh_db: True

install_rabbitmq_server:
  pkg.installed:
   - name: rabbitmq-server
   - version: '{{ rabbitmq.version }}'
   - require:
        - pkg: install_esl_erlang_solutions
        - pkgrepo: add_rabbitmq_pkg_repo
