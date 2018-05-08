{% from "rabbitmq/map.jinja" import rabbitmq with context %}
{% set oscodename = salt.grains.get('oscodename') %}
{% set os = salt.grains.get('os') %}
{% set osmajorrelease = salt.grains.get('osmajorrelease') %}
{% set os_family = salt.grains.get('os_family') %}

{% if os_family == 'Debian' %}
{% set pkg_type = 'deb' %}
{% elif os_family == 'RedHat' %}
{% set pkg_type = 'rpm' %}
{% endif %}

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
  cmd.run:
    - name: curl -s https://packagecloud.io/install/repositories/rabbitmq/rabbitmq-server/script.{{ pkg_type }}.sh | bash

install_rabbitmq_server:
  pkg.installed:
   - name: rabbitmq-server
   - version: '{{ rabbitmq.version }}'
   - require:
        - cmd: add_rabbitmq_pkg_repo
