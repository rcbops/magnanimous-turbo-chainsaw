#!/bin/bash


## Variables -----------------------------------------------------------------
source "$(dirname $(readlink -f ${BASH_SOURCE[0]}))/set-vars.sh"

if [[ -f "${HOME}/.mtc.rc" ]]; then
  source "${HOME}/.mtc.rc"
fi

## Main ----------------------------------------------------------------------
pushd /opt/openstack-ansible-ops/bootstrap-embedded-ansible
  source bootstrap-embedded-ansible.sh
popd
