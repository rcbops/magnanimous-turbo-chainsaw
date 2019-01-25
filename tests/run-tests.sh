#!/usr/bin/env bash
# Copyright 2018, Rackspace US, Inc.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

set -ve

export TEST_DIR="$(readlink -f $(dirname ${0})/../)"

bash ${TEST_DIR}/scripts/setup.sh

${HOME}/ansible_venv/bin/ansible-playbook -i 'localhost,' \
                                          -vv \
                                          -e ansible_connection=local \
                                          ${TEST_DIR}/playbooks/test-basic-setup.yml

${HOME}/ansible_venv/bin/ansible-playbook -i 'localhost,' \
                                          -vv \
                                          -e ansible_connection=local \
                                          ${TEST_DIR}/tests/playbooks/test.yml

source ${TEST_DIR}/scripts/deploy-all.sh
