#!/bin/bash

if [ "$(ls /vagrant)" ]
then
    SRCDIR=/vagrant
else
    SRCDIR=/home/vagrant/sync
fi
sudo mkdir -p /srv/salt
sudo mkdir -p /srv/pillar
sudo mkdir -p /srv/formulas
sudo cp $SRCDIR/pillar.example /srv/pillar/pillar.sls
sudo ln -s $SRCDIR/rabbitmq /srv/salt/rabbitmq
echo "\
base:
  '*':
    - pillar" | sudo tee /srv/pillar/top.sls
echo "\
base:
  '*':
    - rabbitmq
    - rabbitmq.tests" | sudo tee /srv/salt/top.sls
