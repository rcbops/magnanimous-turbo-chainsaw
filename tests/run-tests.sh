#!/usr/bin/env bash

set -ve

## Variables -----------------------------------------------------------------
export TEST_DIR="$(readlink -f $(dirname ${0})/../)"
export TEST_TYPE="${TEST_TYPE:-aio}"

## Main ----------------------------------------------------------------------
bash ${TEST_DIR}/scripts/setup.sh

if [[ "${TEST_TYPE}" == "aio" ]]; then
    eval "${HOME}/ansible_venv/bin/ansible-playbook" -i 'localhost,' \
                                                     -vv \
                                                     -e ansible_connection=local \
                                                     ${TEST_DIR}/playbooks/test-basic-setup.yml

    eval "${HOME}/ansible_venv/bin/ansible-playbook" -i 'localhost,' \
                                                     -vv \
                                                     -e ansible_connection=local \
                                                     ${TEST_DIR}/tests/playbooks/test.yml

    source ${TEST_DIR}/scripts/deploy-all.sh
fi
