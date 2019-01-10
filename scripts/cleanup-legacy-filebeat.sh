#!/usr/bin/env bash

## Variables -----------------------------------------------------------------
source "$(dirname $(readlink -f ${BASH_SOURCE[0]}))/set-vars.sh"

## Main ----------------------------------------------------------------------
source "$(dirname $(readlink -f ${BASH_SOURCE[0]}))/setup-workspace.sh"

# Cleanup all legacy systems prior to deployment
ansible-playbook ${ANSIBLE_EXTRA_VARS:-} "/opt/magnanimous-turbo-chainsaw/playbooks/cleanup-legacy-filebeat.yml"
