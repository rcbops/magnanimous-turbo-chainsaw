#!/usr/bin/env bash

set -ve

## Variables -----------------------------------------------------------------
export RE_JOB_SCENARIO="${RE_JOB_SCENARIO:-all}"
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

    # Deploys specified toolset
    case ${RE_JOB_SCENARIO} in
        fleet)
            . ${TEST_DIR}/scripts/deploy-fleet.sh;;
        elk)
            . ${TEST_DIR}/scripts/deploy-elk.sh;;
        skydive)
            . ${TEST_DIR}/scripts/deploy-skydive.sh;;
        all)
            . ${TEST_DIR}/scripts/deploy-all.sh;;
    esac
fi

# ---------TESTING GOES HERE--------- #

