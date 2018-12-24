#!/usr/bin/env bash


## In the case where nodes do not exist in inventory,
## but have container artifacts on the underlying log_hosts
## being used.
# ansible log_hosts -m shell -a 'lxc-ls | xargs -n 1 lxc-destroy -fn'
# ansible log_hosts -m shell -a 'ls -d /openstack/*container* | xargs -n 1 rm -rf'

# Fixed authorized_keys issue (from=) and run plays
/opt/boo
pushd /opt/openstack-ansible-ops/elk_metrics_6x
    ansible-playbook ${ANSIBLE_EXTRA_VARS} \
                    ${USER_VARS} \
                    -e @/etc/openstack_deploy/user_tools_variables.yml \
                    -f 75 \
                    site.yml
popd
