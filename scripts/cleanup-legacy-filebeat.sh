#!/usr/bin/env bash

## Variables -----------------------------------------------------------------
source "$(dirname $(readlink -f ${BASH_SOURCE[0]}))/set-vars.sh"

## Main ----------------------------------------------------------------------
source "$(dirname $(readlink -f ${BASH_SOURCE[0]}))/setup-workspace.sh"

# Cleanup all legacy systems prior to deployment
ansible-playbook ${ANSIBLE_EXTRA_VARS:-} ${MTC_BLACKLIST} "${MTC_PLAYBOOK_DIR}/cleanup-legacy-filebeat.yml"
ansible-playbook ${ANSIBLE_EXTRA_VARS:-} ${MTC_BLACKLIST} "${MTC_PLAYBOOK_DIR}/cleanup-legacy-kibana.yml"
ansible-playbook ${ANSIBLE_EXTRA_VARS:-} ${MTC_BLACKLIST} "${MTC_PLAYBOOK_DIR}/cleanup-legacy-logstash.yml"
ansible-playbook ${ANSIBLE_EXTRA_VARS:-} ${MTC_BLACKLIST} "${MTC_PLAYBOOK_DIR}/cleanup-legacy-elasticsearch.yml"
