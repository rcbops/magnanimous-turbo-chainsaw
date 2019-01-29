#!/bin/bash

(deactivate_workspace &> /dev/null) || true

## Variables -----------------------------------------------------------------
source "$(dirname $(readlink -f ${BASH_SOURCE[0]}))/set-vars.sh"

if [[ -f "${HOME}/.mtc.rc" ]]; then
  source "${HOME}/.mtc.rc"
fi

## Functional ----------------------------------------------------------------
function deactivate_workspace {
  deactivate_embedded_venv || true
  if [[ -f "${ANSIBLE_LOG_PATH}" ]]; then
    tar -czf "${ANSIBLE_LOG_PATH}.tar.gz" "${ANSIBLE_LOG_PATH}" &> /dev/null
    rm "${ANSIBLE_LOG_PATH}"
    unset ANSIBLE_LOG_PATH
    unset ANSIBLE_EXTRA_VARS
    unset ANSIBLE_INVENTORY
    unset ANSIBLE_GATHERING
    unset ANSIBLE_CACHE_PLUGIN
    unset ANSIBLE_CACHE_PLUGIN_CONNECTION
    unset ANSIBLE_PRIVATE_KEY_FILE
    unset MTC_WORKING_DIR
    unset MTC_SCRIPT_DIR
    unset MTC_PLAYBOOK_DIR
    unset MTC_BLACKLIST
    unset USER_ALL_VARS
  fi
  # Remove host blacklist file if found
  if [[ -f "/tmp/mtc.blacklist" ]]; then
    rm /tmp/mtc.blacklist
  fi
  unset deactivate_workspace &> /dev/null
  unalias deactivate &> /dev/null
}

## Main ----------------------------------------------------------------------
pushd /opt/openstack-ansible-ops/bootstrap-embedded-ansible
  source bootstrap-embedded-ansible.sh
popd

alias deactivate=deactivate_workspace

# Set test inventory
if [[ -f "/tmp/inventory-test.yml" ]]; then
  echo -e "\n#### NOTICE ####\n\nTest Inventory found, enabling test mode.\n\n#### NOTICE ####\n"
  if [[ -f "/tmp/user_tools_secrets.yml" ]] && [[ ! "$(echo -e '${ANSIBLE_EXTRA_VARS}' | grep -q 'tmp/user_tools_secrets')" ]]; then
    export ANSIBLE_EXTRA_VARS+=" -e @/tmp/user_tools_secrets.yml"
  fi
  export ANSIBLE_INVENTORY="/tmp/inventory-test.yml,/opt/openstack-ansible-ops/overlay-inventories/osa-integration-inventory.yml"
  echo -e "\n#### VARS ####\nINVENTORY: ${ANSIBLE_INVENTORY}"
  echo -e "EXTRA_VARS: ${ANSIBLE_EXTRA_VARS}\n#### VARS ####\n"
else
  # Generate cached inventory
  if [[ -f "/etc/openstack_deploy/openstack_inventory.json" ]]; then
    # Obtain the openstack inventory and cache it
    if [[ -f "${OSA_PATH}/inventory/dynamic_inventory.py" ]]; then
      ANSIBLE_INVENTORY="${OSA_PATH}/inventory/dynamic_inventory.py" \
        "${HOME}/ansible_venv/bin/ansible-inventory" --vars \
                                                    --yaml \
                                                    --export \
                                                    --list > /tmp/inventory-cache.yml
    elif [[ -f "${OSA_PATH}/playbooks/inventory/dynamic_inventory.py" ]]; then
      ANSIBLE_INVENTORY="${OSA_PATH}/playbooks/inventory/dynamic_inventory.py" \
        "${HOME}/ansible_venv/bin/ansible-inventory" --vars \
                                                    --yaml \
                                                    --export \
                                                    --list > /tmp/inventory-cache.yml
    fi
    # Set the ansible inventory
    export ANSIBLE_INVENTORY="/tmp/inventory-cache.yml,/opt/openstack-ansible-ops/overlay-inventories/osa-integration-inventory.yml"
    if [[ -f "/etc/openstack_deploy/inventory.ini" ]]; then
      export ANSIBLE_INVENTORY="/etc/openstack_deploy/inventory.ini,${ANSIBLE_INVENTORY}"
    fi
  fi

  # Set ceph ansible inventory
  if [[ -f "/tmp/inventory-ceph.ini" ]]; then
    export ANSIBLE_INVENTORY="${ANSIBLE_INVENTORY},/tmp/inventory-ceph.ini"
  fi

  # Set rpco ansible inventory
  if [[ -f "/opt/rpc-openstack/inventory.ini" ]]; then
    export ANSIBLE_INVENTORY="/opt/rpc-openstack/inventory.ini,${ANSIBLE_INVENTORY}"
  fi
fi

# Set static user all vars
export USER_ALL_VARS=""

if [[ -d "/etc/openstack_deploy" ]]; then
  export USER_ALL_VARS+="$(for i in $(ls -1 /etc/openstack_deploy/user_*.yml); do echo -n "-e@$i "; done)"
fi

# When executing within an OSP environment make sure the connection plugin is not modified from default
if [[ -f "/etc/rhosp-release" ]]; then
  unset ANSIBLE_CONNECTION_PLUGINS
  if [[ -d "/home/stack" ]]; then
    export USER_ALL_VARS+="$(for i in $(ls -1 /home/stack/user_*.yml); do echo -n "-e@$i "; done)"
    if [[ -f "/home/stack/.ssh/id_rsa" ]]; then
      export ANSIBLE_PRIVATE_KEY_FILE="/home/stack/.ssh/id_rsa"
    fi
  fi
fi
