#!/usr/bin/env bash


## Variables -----------------------------------------------------------------
source "$(dirname $(readlink -f ${BASH_SOURCE[0]}))/set-vars.sh"


## Main ----------------------------------------------------------------------
if [[ -d "${OSA_PATH}/playbooks" ]]; then
  pushd "${OSA_PATH}/playbooks"
    ansible-playbook ${ANSIBLE_EXTRA_VARS:-} lxc-containers-create.yml --limit 'lxc_hosts:kolide-fleet_all'
  popd
fi

source "$(dirname $(readlink -f ${BASH_SOURCE[0]}))/setup-workspace.sh"

pushd /opt/openstack-ansible-ops/osquery
    ansible-galaxy install -r ansible-role-requirements.yml --ignore-errors --force --roles-path=${HOME}/ansible_venv/repositories/roles
    ansible-playbook ${ANSIBLE_EXTRA_VARS:-} \
                     ${MTC_BLACKLIST} \
                     -e @${MTC_VARS_PATH}/user_tools_secrets.yml \
                     -e @${MTC_VARS_PATH}/user_tools_variables.yml \
                     -e 'galera_ignore_cluster_state=true' \
                     -f 75 \
                     site.yml
popd

deactivate
