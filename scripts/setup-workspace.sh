#!/bin/bash


## Variables -----------------------------------------------------------------
source "$(dirname $(readlink -f ${BASH_SOURCE[0]}))/set-vars.sh"


## Main ----------------------------------------------------------------------
pushd /opt/openstack-ansible-ops/bootstrap-embedded-ansible
    source bootstrap-embedded-ansible.sh
popd
