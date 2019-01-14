#!/bin/bash


## Variables -----------------------------------------------------------------
source "$(dirname $(readlink -f ${BASH_SOURCE[0]}))/set-vars.sh"

if [[ -f "${HOME}/.mtc.rc" ]]; then
  source "${HOME}/.mtc.rc"
fi

## Functional ----------------------------------------------------------------
function deactivate_workspace {
  deactivate
  deactivate_embedded_venv || true
  if [[ -f "${ANSIBLE_LOG_PATH}" ]]; then
    tar -czf "${ANSIBLE_LOG_PATH}.tar.gz" "${ANSIBLE_LOG_PATH}"
    rm "${ANSIBLE_LOG_PATH}"
    unset ANSIBLE_LOG_PATH
  fi
  unalias deactivate
  unalias deactivate_embedded_venv
}

## Main ----------------------------------------------------------------------
pushd /opt/openstack-ansible-ops/bootstrap-embedded-ansible
  source bootstrap-embedded-ansible.sh
popd

alias deactivate=deactivate_workspace
