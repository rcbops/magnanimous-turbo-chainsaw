#!/bin/bash

# Set the compatible version of ansible for RPC Toolstack projects
export ANSIBLE_LOG_PATH="${ANSIBLE_LOG_PATH:-$HOME/magnanimous-turbo-chainsaw-$(date +%Y-%m-%d).log}"
export ANSIBLE_VERSION="${ANSIBLE_VERSION:-2.7.5.0}"
export ANSIBLE_GATHERING="${ANSIBLE_GATHERING:-smart}"
export ANSIBLE_CACHE_PLUGIN="${ANSIBLE_CACHE_PLUGIN:-jsonfile}"
export ANSIBLE_CACHE_PLUGIN_CONNECTION="${ANSIBLE_CACHE_PLUGIN_CONNECTION:-/tmp/mtc_facts-$(date +%Y-%m-%d)}"
export ANSIBLE_STDOUT_CALLBACK="${ANSIBLE_STDOUT_CALLBACK:-debug}"
export MTC_WORKING_DIR="/opt/magnanimous-turbo-chainsaw"
export MTC_SCRIPT_DIR="${MTC_WORKING_DIR}/scripts"
export MTC_PLAYBOOK_DIR="${MTC_WORKING_DIR}/playbooks"
export MTC_BLACKLIST=""

# The MTC vars path defaults to /tmp and will be reset based on the deployment
# environment.
export MTC_VARS_PATH="/tmp"

# Use this environment variable to add additional options to all ansible runs.
export ANSIBLE_EXTRA_VARS="${ANSIBLE_EXTRA_VARS:-}"

# Environment variable to append options to MTC pip commands
export PIP_INSTALL_OPTS="${PIP_INSTALL_OPTS:-}"

# Export pre-existing no_proxy variable
export ORIG_NO_PROXY="${ORIG_NO_PROXY:-$(env | awk -F= '/^no_proxy/ {print $NF}')}"

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
  export MTC_VARS_PATH="/etc/openstack_deploy"
elif [[ -d "/opt/rpc-openstack/openstack-ansible" ]]; then
  export OSA_PATH="/opt/rpc-openstack/openstack-ansible"
  echo -e "# MTC managed\n\n[rpco]\nlocalhost ansible_host=127.0.0.1 ansible_connection=local\n" > /opt/rpc-openstack/inventory.ini
  export MTC_VARS_PATH="/etc/openstack_deploy"
else
  export OSA_PATH=""
fi

if [[ -d "/home/stack" ]] && [[ -f "/bin/tripleo-ansible-inventory" ]]; then
  export OSP_PATH="${OSP_PATH:-/opt/rpc-maas}"
  export STACK_HOME="${STACK_HOME:-/home/stack}"
  export MTC_VARS_PATH="${STACK_HOME}"
  source "${STACK_HOME}/stackrc"
  export OS_CACERT="${OS_CACERT:-/etc/pki/tls/certs/ca-bundle.crt}"
fi

# This should catch RPC-R ceph standalone deployments. If the associated
# cloud is OSP13, it's recommended the director node is used to deploy
# OSP and standalone ceph-ansible. If the OSP version is prior to OSP13,
# then it's recommended to deploy from a separate deployment node
# because MTC will fail due to detecting a director node, but not having
# the necessary tripleo functionality available.
if [[ ! -d "/home/stack" ]] && [[ -d "/usr/share/ceph-ansible" ]]; then
  export OSP_PATH="${OSP_PATH:-/opt/rpc-maas}"
  export STACK_HOME="${STACK_HOME:-/usr/share/ceph-ansible}"
  export MTC_VARS_PATH="${STACK_HOME}"
fi

# Append limit blacklist to the runtime
if [[ -f "/tmp/mtc.blacklist" ]]; then
  export MTC_BLACKLIST="--limit @/tmp/mtc.blacklist"
fi
