#!/bin/bash

## Shell Opts ----------------------------------------------------------------
set -e -u -x


## Variables -----------------------------------------------------------------
export MTC_RELEASE=${MTC_RELEASE:-master}
export MTC_WORKING_DIR="/opt/magnanimous-turbo-chainsaw"
export MTC_SCRIPT_DIR="${MTC_WORKING_DIR}/scripts"


## functions -----------------------------------------------------------------
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

if [[ -f "${MTC_SCRIPT_DIR}/set-vars.sh" ]];  then
  source "${MTC_SCRIPT_DIR}/set-vars.sh"
else
  curl -D - "https://raw.githubusercontent.com/rcbops/magnanimous-turbo-chainsaw/${MTC_RELEASE}/scripts/set-vars.sh" -o /tmp/set-vars.sh
  source /tmp/set-vars.sh
fi

# Setup git for use with a proxy if one is found.
if [[ ! -z "${http_proxy:-}" ]] || [[ ! -z "${https_proxy:-}" ]]; then
  if [[ -f "${MTC_SCRIPT_DIR}/setup-proxy.sh" ]];  then
    bash "${MTC_SCRIPT_DIR}/setup-proxy.sh"
  else
    curl -D - "https://raw.githubusercontent.com/rcbops/magnanimous-turbo-chainsaw/${MTC_RELEASE}/scripts/setup-proxy.sh" -o /tmp/setup-proxy.sh
    bash /tmp/setup-proxy.sh
  fi
fi

# Generate keys if they are not currently setup
ssh_key_create

# If a pip config is present move it out of the way for the basic setup
if [[ -d "${HOME}/.pip" ]]; then
  mv "${HOME}/.pip" "${HOME}/.pip.bak"
fi

# Source the ops repo
if [[ ! -d "/opt/openstack-ansible-ops" ]]; then
  git clone https://github.com/openstack/openstack-ansible-ops /opt/openstack-ansible-ops
elif [[ ! -d "/opt/openstack-ansible-ops/bootstrap-embedded-ansible" ]]; then
  pushd /opt/openstack-ansible-ops
    git fetch --all
    git reset --hard origin/master
  popd
fi

if [[ -f "${MTC_SCRIPT_DIR}/setup-workspace.sh" ]];  then
  PS1="${PS1:-'\[\033[01;31m\]\h\[\033[01;34m\] \W \$\[\033[00m\] '}" source "${MTC_SCRIPT_DIR}/setup-workspace.sh"
else
  curl -D - "https://raw.githubusercontent.com/rcbops/magnanimous-turbo-chainsaw/${MTC_RELEASE}/scripts/setup-workspace.sh" -o /tmp/setup-workspace.sh
  PS1="${PS1:-'\[\033[01;31m\]\h\[\033[01;34m\] \W \$\[\033[00m\] '}" source /tmp/setup-workspace.sh

  # NOTICE(Cloudnull): This pip install is only required until we can sort out
  #                    why its needed for installation that use Hashicorp-Vault.
  pip install pyOpenSSL==16.2.0 ${PIP_INSTALL_OPTS}
fi

# Restore the pip config if found
if [[ -d "${HOME}/.pip.bak" ]]; then
  mv "${HOME}/.pip.bak" "${HOME}/.pip"
fi

# Get the environmental tools repo
if [[ -f "${MTC_PLAYBOOK_DIR}/get-mtc.yml" ]];  then
  ansible-playbook ${ANSIBLE_EXTRA_VARS:-} ${MTC_BLACKLIST} -i "${ANSIBLE_INVENTORY:-localhost,}" "${MTC_PLAYBOOK_DIR}/get-mtc.yml"
else
  curl -D - "https://raw.githubusercontent.com/rcbops/magnanimous-turbo-chainsaw/${MTC_RELEASE}/playbooks/get-mtc.yml" -o /tmp/get-mtc.yml
  ansible-playbook ${ANSIBLE_EXTRA_VARS:-} ${MTC_BLACKLIST} -i "${ANSIBLE_INVENTORY:-localhost,}" /tmp/get-mtc.yml
fi

# Get all roles OSA requires
if [[ -n "${OSA_PATH}" ]] && [[ -f "${OSA_PATH}/ansible-role-requirements.yml" ]]; then
    ansible-galaxy install -r "${OSA_PATH}/ansible-role-requirements.yml" --ignore-errors --force --roles-path="${HOME}/ansible_venv/repositories/roles"
fi

PS1="${PS1:-'\[\033[01;31m\]\h\[\033[01;34m\] \W \$\[\033[00m\] '}" bash "${MTC_SCRIPT_DIR}/setup-workspace.sh"

# Get osa ops tools
ansible-playbook ${ANSIBLE_EXTRA_VARS:-} ${MTC_BLACKLIST} -i "${ANSIBLE_INVENTORY:-localhost,}" "${MTC_PLAYBOOK_DIR}/get-osa-ops.yml"

# Generate the required variables
ansible-playbook ${ANSIBLE_EXTRA_VARS:-} ${MTC_BLACKLIST} -i "${ANSIBLE_INVENTORY:-localhost,}" \
                 -e "http_proxy_server=${http_proxy:-'none://none:none'}" \
                 -e "extra_no_proxy_hosts=${ORIG_NO_PROXY:-''}" \
                 ${MTC_PLAYBOOK_DIR}/generate-environment-vars.yml
