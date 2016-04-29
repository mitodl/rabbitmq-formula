========
rabbitmq
========

SaltStack formula for deploying and managing RabbitMQ

.. note::

   This formula takes advantage of the TestInfra state module found in the MIT ODL
   `salt-extensions <https://github.com/mitodl/salt-extensions`_ repository.

.. note::

    See the full `Salt Formulas installation and usage instructions
    <http://docs.saltstack.com/en/latest/topics/development/conventions/formulas.html>`_.


Available states
================

.. contents::
    :local:

``rabbitmq``
------------

Installs and configures RabbitMQ server based on pillar data.

``rabbitmq.install``
--------------------

Install RabbitMQ server and make sure it is running

``rabbitmq.configure``
----------------------

Configure RabbitMQ based on pillar data.

``rabbitmq.plugins``
--------------------

Install RabbitMQ plugins based on pillar data

``rabbitmq.os_tweaks``
----------------------

Update OS level settings such as file descriptor limit for tuning of RabbitMQ performance

``rabbitmq.permissions``
------------------------

Add users, vhosts, and policies to RabbitMQ server based on pillar data

``rabbitmq.tests``
------------------

Uses testinfra module from mitodl/salt-extensions to verify proper state of server

Template
========

This formula was created from a cookiecutter template.

See https://github.com/mitodl/saltstack-formula-cookiecutter.
