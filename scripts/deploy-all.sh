#!/usr/bin/env bash


## Variables -----------------------------------------------------------------
source "$(dirname $(readlink -f ${BASH_SOURCE[0]}))/set-vars.sh"

## Main ----------------------------------------------------------------------
source "$(dirname $(readlink -f ${BASH_SOURCE[0]}))/setup-workspace.sh"
ansible-playbook "$(dirname $(readlink -f ${BASH_SOURCE[0]}))/../playbooks/probe-systems.yml"

source "$(dirname $(readlink -f ${BASH_SOURCE[0]}))/deploy-fleet.sh"
source "$(dirname $(readlink -f ${BASH_SOURCE[0]}))/deploy-elk.sh"
source "$(dirname $(readlink -f ${BASH_SOURCE[0]}))/deploy-skydive.sh"

deactivate
