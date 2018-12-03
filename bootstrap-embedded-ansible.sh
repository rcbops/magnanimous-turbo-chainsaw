#!/bin/bash

# Rather than adding upstream openstack-ansible-ops as a submodule for use with
# RPC Toolstack work, it makes sense use this as a wrapper for upstream
# bootstrap-embedded-ansible.sh

# Set the compatible version of ansible for RPC Toolstack projects
export ANSIBLE_VERSION="2.6.5"

# Determine OS and validate curl is installed
source /etc/os-release
export ID="$(echo ${ID} | awk -F'-' '{print $1}')"

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

# Pull down upstream openstack bootstrap-embedded-ansible.sh
UPSTREAM_URL="https://raw.githubusercontent.com/openstack/openstack-ansible-ops/master/bootstrap-embedded-ansible/bootstrap-embedded-ansible.sh"
curl -s ${UPSTREAM_URL} > /opt/bootstrap-embedded-ansible.sh

# Source the script
source /opt/bootstrap-embedded-ansible.sh
