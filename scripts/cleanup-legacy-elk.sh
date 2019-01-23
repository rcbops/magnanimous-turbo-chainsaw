#!/usr/bin/env bash

## Variables -----------------------------------------------------------------
source "$(dirname $(readlink -f ${BASH_SOURCE[0]}))/set-vars.sh"

## Main ----------------------------------------------------------------------
source "$(dirname $(readlink -f ${BASH_SOURCE[0]}))/setup-workspace.sh"

# Remove old container definitions and delete from inventory
rm /etc/openstack_deploy/env.d/{elasticsearch,kibana,logstash}.yml || true
rm /etc/openstack_deploy/conf.d/{elasticsearch,kibana,logstash}.yml || true

# Cleanup all legacy filebeat
source "$(dirname $(readlink -f ${BASH_SOURCE[0]}))/cleanup-legacy-filebeat.sh"

pushd "${OSA_PATH}"
  # Not needed unless containers exist in inventory
  ansible-playbook lxc-containers-destroy.yml -e "force_containers_destroy=yes" \
                                              -e "force_containers_data_destroy=yes" \
                                              --limit 'lxc_hosts:elasticsearch_all:kibana_all:logstash_all:elk_all'

  for i in $(../scripts/inventory-manage.py -l | grep -e apm -e elastic -e kibana -e logstash | awk '{print $2}'); do
    echo "Removing $i"
    eval "${OSA_PATH}/../scripts/inventory-manage.py -r ${i}"
  done
popd
