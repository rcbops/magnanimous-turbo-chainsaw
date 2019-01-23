#!/usr/bin/env bash


## Variables -----------------------------------------------------------------
source "$(dirname $(readlink -f ${BASH_SOURCE[0]}))/set-vars.sh"

## Main ----------------------------------------------------------------------
if [[ -d "${OSA_PATH}/playbooks" ]]; then
  pushd "${OSA_PATH}/playbooks"
    ansible-playbook ${ANSIBLE_EXTRA_VARS:-} lxc-containers-create.yml --limit 'lxc_hosts:elk_all'
  popd
fi

source "$(dirname $(readlink -f ${BASH_SOURCE[0]}))/setup-workspace.sh"

pushd /opt/openstack-ansible-ops/elk_metrics_6x
    ansible-playbook ${ANSIBLE_EXTRA_VARS:-} \
                     -e @/etc/openstack_deploy/user_tools_secrets.yml \
                     -e @/etc/openstack_deploy/user_tools_variables.yml \
                     -f 75 \
                     site.yml
popd
