#!/usr/bin/env bash

pushd /opt/openstack-ansible/playbooks
  openstack-ansible ${ANSIBLE_EXTRA_VARS:-} lxc-containers-create.yml --limit 'lxc_hosts:kolide-fleet_all'
popd

source /opt/bootstrap-embedded-ansible.sh

pushd /opt/openstack-ansible-ops/osquery
    ansible-galaxy install -r ansible-role-requirements.yml --ignore-errors --roles-path=${HOME}/ansible_venv/repositories/roles
    ansible-playbook ${ANSIBLE_EXTRA_VARS:-} ${USER_VARS:-} \
                     -e @/etc/openstack_deploy/user_tools_variables.yml \
                     -f 75 \
                     site.yml
popd
