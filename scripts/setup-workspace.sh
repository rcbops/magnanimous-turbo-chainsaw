#!/bin/bash

## Variables -----------------------------------------------------------------
source "$(dirname $(readlink -f ${BASH_SOURCE[0]}))/set-vars.sh"

if [[ -f "${HOME}/.mtc.rc" ]]; then
  source "${HOME}/.mtc.rc"
fi

## Functional ----------------------------------------------------------------
function deactivate_workspace {
  deactivate || true
  deactivate_embedded_venv || true
  if [[ -f "${ANSIBLE_LOG_PATH}" ]]; then
    tar -czf "${ANSIBLE_LOG_PATH}.tar.gz" "${ANSIBLE_LOG_PATH}"
    rm "${ANSIBLE_LOG_PATH}"
    unset ANSIBLE_LOG_PATH
  fi
  unalias deactivate > /dev/null 2&>1
  unalias deactivate_embedded_venv > /dev/null 2&>1
}

## Main ----------------------------------------------------------------------
(alias deactivate &> /dev/null && deactivate) || true

pushd /opt/openstack-ansible-ops/bootstrap-embedded-ansible
  source bootstrap-embedded-ansible.sh
popd

alias deactivate=deactivate_workspace

# Generate cached inventory
if [[ -f "/etc/openstack_deploy/openstack_inventory.json" ]]; then
  # Read inventory and cache it
  cat /etc/openstack_deploy/openstack_inventory.json | "${HOME}/ansible_venv/bin/ansible-inventory" --vars --yaml --export --list > /tmp/inventory-cache.yml
  # Set the ansible invntory
  export ANSIBLE_INVENTORY="/tmp/inventory-cache.yml,/opt/openstack-ansible-ops/overlay-inventories/osa-integration-inventory.yml"
fi
