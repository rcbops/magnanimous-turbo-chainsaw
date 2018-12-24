#!/usr/bin/env bash

pushd /opt/openstack-ansible/playbooks
  openstack-ansible ${ANSIBLE_EXTRA_VARS:-} lxc-containers-create.yml --limit 'lxc_hosts:elk_all'
popd

source /opt/bootstrap-embedded-ansible.sh

pushd /opt/openstack-ansible-ops/elk_metrics_6x
    ansible-playbook ${ANSIBLE_EXTRA_VARS:-} ${USER_VARS:-} \
                     -e @/etc/openstack_deploy/user_tools_variables.yml \
                     -f 75 \
                     site.yml
popd
