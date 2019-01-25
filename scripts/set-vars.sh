#!/bin/bash

# Set the compatible version of ansible for RPC Toolstack projects
export ANSIBLE_LOG_PATH="${ANSIBLE_LOG_PATH:-$HOME/magnanimous-turbo-chainsaw-$(date +%Y-%m-%d).log}"
export ANSIBLE_VERSION="${ANSIBLE_VERSION:-2.7.5.0}"
export MTC_WORKING_DIR="/opt/magnanimous-turbo-chainsaw"
export MTC_SCRIPT_DIR="${MTC_WORKING_DIR}/scripts"
export MTC_PLAYBOOK_DIR="${MTC_WORKING_DIR}/playbooks"
export MTC_BLACKLIST=""

# Use this environment variable to add additional options to all ansible runs.
export ANSIBLE_EXTRA_VARS="${ANSIBLE_EXTRA_VARS:-}"

# Determine OS and validate curl is installed
if [[ -f "/etc/os-release" ]]; then
  source /etc/os-release
  export ID="$(echo ${ID} | awk -F'-' '{print $1}')"
fi

# Append our user vars file to the extra vars options when found.
if [[ -f "/etc/openstack_deploy/user_tools_variables.yml" ]]; then
  export ANSIBLE_EXTRA_VARS+=" -e @/etc/openstack_deploy/user_tools_variables.yml"
fi

# Define the playbook directory
if [[ -d "/opt/openstack-ansible" ]]; then
  export OSA_PATH="/opt/openstack-ansible"
elif [[ -d "/opt/rpc-openstack/openstack-ansible" ]]; then
  export OSA_PATH="/opt/rpc-openstack/openstack-ansible"
  echo -e "# MTC managed\n\n[rpco]\nlocalhost ansible_host=127.0.0.1 ansible_connection=local\n" > /opt/rpc-openstack/inventory.ini
else
  export OSA_PATH=""
fi

if [[ -d "/home/stack" ]] && [[ -f "/bin/tripleo-ansible-inventory" ]]; then
  export OSP_PATH=""  # unimplemented
fi

# Append limit blacklist to the runtime
if [[ -f "/tmp/mtc.blacklist" ]]; then
  export MTC_BLACKLIST="--limit @/tmp/mtc.blacklist"
fi
