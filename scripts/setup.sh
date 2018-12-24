#!/bin/bash


## Shell Opts ----------------------------------------------------------------
set -e -u -x


## Variables -----------------------------------------------------------------
# Set the compatible version of ansible for RPC Toolstack projects
export ANSIBLE_VERSION="2.6.5"
export SCRIPT_DIR="$(readlink -f $(dirname ${0}))"

# Use this environment variable to add additional options to all ansible runs.
export ANSIBLE_EXTRA_VARS=""

# Determine OS and validate curl is installed
source /etc/os-release
export ID="$(echo ${ID} | awk -F'-' '{print $1}')"


## Variables -----------------------------------------------------------------
function ssh_key_create {
  # Ensure that the ssh key exists and is an authorized_key
  key_path="${HOME}/.ssh"
  key_file="${key_path}/id_rsa"

  # Ensure that the .ssh directory exists and has the right mode
  if [ ! -d ${key_path} ]; then
    mkdir -p ${key_path}
    chmod 700 ${key_path}
  fi
  if [ ! -f "${key_file}" -a ! -f "${key_file}.pub" ]; then
    rm -f ${key_file}*
    ssh-keygen -t rsa -f ${key_file} -N ''
  fi

  # Ensure that the public key is included in the authorized_keys
  # for the default root directory and the current home directory
  key_content=$(cat "${key_file}.pub")
  if ! grep -q "${key_content}" ${key_path}/authorized_keys; then
    echo "${key_content}" | tee -a ${key_path}/authorized_keys
  fi
}


## Main ----------------------------------------------------------------------
if [[ ! -e $(which curl) ]]; then
  if [[ ${ID} = "ubuntu" ]]; then
    apt-get update
    apt-get -y install curl
  elif [[ ${ID} = "opensuse" ]] || [[ ${ID} = "suse" ]]; then
    zypper install -y curl
  elif [[ ${ID} = "centos" ]] || [[ ${ID} = "redhat" ]] || [[ ${ID} = "rhel" ]]; then
    yum install -y curl
  else
    echo "Unknown operating system"
    exit 99
  fi
fi

# Setup git for use with a proxy if one is found.
if [[ ! -z "${http_proxy:-}" ]] || [[ ! -z "${https_proxy:-}" ]]; then
  if [[ -f "${SCRIPT_DIR}/proxy-setup.sh" ]];  then
    bash "${SCRIPT_DIR}/proxy-setup.sh"
  else
    curl -D - https://raw.githubusercontent.com/rcbops/magnanimous-turbo-chainsaw/master/scripts/proxy-setup.sh -o /tmp/proxy-setup.sh
    bash /tmp/proxy-setup.sh
  fi
fi

# Generate keys if they are not currently setup
ssh_key_create

# Source the embedded ansible script
if [[ -f "/opt/bootstrap-embedded-ansible.sh" ]]; then
  PS1=${PS1:-'\\u@\h \\W]\\$'} source /opt/bootstrap-embedded-ansible.sh
else
  curl -D - https://raw.githubusercontent.com/openstack/openstack-ansible-ops/master/bootstrap-embedded-ansible/bootstrap-embedded-ansible.sh \
       -o /opt/bootstrap-embedded-ansible.sh
  PS1=${PS1:-'\\u@\h \\W]\\$'} source /opt/bootstrap-embedded-ansible.sh
fi

# NOTICE(Cloudnull): This pip install is only required until we can sort out
#                    why its needed for installation that use Hashicorp-Vault.
pip install pyOpenSSL==16.2.0 --isolated

# Get the environmental tools repo
if [[ -f "${SCRIPT_DIR}/../playbooks/get-mtc.yml" ]];  then
  ansible-playbook ${ANSIBLE_EXTRA_VARS} -i 'localhost,' "${SCRIPT_DIR}/../playbooks/get-mtc.yml"
else
  curl -D - https://raw.githubusercontent.com/rcbops/magnanimous-turbo-chainsaw/master/playbooks/get-mtc.yml -o /tmp/get-mtc.yml
  ansible-playbook ${ANSIBLE_EXTRA_VARS} -i 'localhost,' /tmp/get-mtc.yml
  export SCRIPT_DIR="/opt/magnanimous-turbo-chainsaw/scripts"
fi

# Cleanup all legacy systems prior to deployment
ansible-playbook ${ANSIBLE_EXTRA_VARS} "${SCRIPT_DIR}/../playbooks/cleanup-legacy-filebeat.yml"

# Generate the required variables
ansible-playbook ${ANSIBLE_EXTRA_VARS} \
                 -i 'localhost,' \
                 -e "http_proxy_server=${http_proxy:-'none://none:none'}" \
                 /opt/magnanimous-turbo-chainsaw/playbooks/generate-environment-vars.yml

if [[ -d "/opt/openstack-ansible" ]]; then
  # Destroy old elk containers and redeploy new ones
  source "${SCRIPT_DIR}/cleanup-legacy-elk.sh"
fi

# Deploy ELK
source "${SCRIPT_DIR}/deploy-elk.sh"
