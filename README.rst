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


Template
========

This formula was created from a cookiecutter template.

See https://github.com/mitodl/saltstack-formula-cookiecutter.
