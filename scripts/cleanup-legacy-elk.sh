#!/usr/bin/env bash

# Remove old container definitions and delete from inventory
rm /etc/openstack_deploy/env.d/{elasticsearch,kibana,logstash}.yml

pushd /opt/openstack-ansible/playbooks
  # Not needed unless containers exist in inventory
  openstack-ansible lxc-containers-destroy.yml --limit 'elasticsearch_all:kibana_all:logstash_all:elk_all'
popd

for i in $(../scripts/inventory-manage.py -l | grep -e apm -e elastic -e kibana -e logstash | awk '{print $2}'); do
  echo "Removing $i"
  /opt/openstack-ansible/scripts/inventory-manage.py -r "${i}"
done

pushd /opt/openstack-ansible/playbooks
  openstack-ansible ${ANSIBLE_EXTRA_VARS} lxc-containers-create.yml --limit 'log_hosts:elk_all'
popd
