# Magnanimous Turbo Chainsaw

The Magnanimous-Turbo-Chainsaw repository contains system, configuration,
and deployment tools used by the RPC-Tools team. These tools deliver our
value added services to environments which enables a versioning structure
and tool validation.

### Overview

These tools will be leveraged by job automation and humans alike with the
intention to rapidly deploy and maintain value added tooling across
environments.

#### Setup

Run the setup script on a deployment host which will be managed by the MTC.
There are many ways to setup an environment with the MTC tooling, just do
what works best for the environment.

Download the setup script and execute it.

``` bash
wget https://raw.githubusercontent.com/rcbops/magnanimous-turbo-chainsaw/master/scripts/setup.sh -O /opt/mtc-setup.sh
bash /opt/mtc-setup.sh
```

Run a single command.

``` bash
curl https://raw.githubusercontent.com/rcbops/magnanimous-turbo-chainsaw/master/scripts/setup.sh | bash
```

Clone the tools and execute the setup script.

``` bash
git clone https://github.com/rcbops/magnanimous-turbo-chainsaw /opt/magnanimous-turbo-chainsaw
bash /opt/magnanimous-turbo-chainsaw/scripts/setup.sh
```

If working with a proxy, make sure the `noproxy`, `http_proxy`, and
`https_proxy` options are set, as needed. The setup process will react
to proxies ensuring our tooling is configured in a way that is proxy
friendly.

#### Creating a workspace

With the MTC setup, change directories to the scripts path and source the
workspace script.

``` bash
source setup-workspace.sh
```

This will ensure the deployment workspace is loaded and ready to run workloads.

#### Probing the environment

While this process is optional, it is recommended. Before running any major
deployment it is recommended to probe the environment for any host that is
unreachable. The following playbook will probe all hosts throughout an
environment and blacklist any host that is not available.

With the MTC setup, change directories to the playbooks path and run the
probe playbook.

``` bash
ansible-playbook probe-systems.yml
```

At the completion of this playbook the `/tmp/mtc.blacklist` file will have
been created which will ensure no workloads are run against the unresponsive
hosts.

#### Cleaning up an existing ELK environment

With the MTC setup, change directories to the scripts path and run the
cleanup tooling.

``` bash
cd /opt/magnanimous-turbo-chainsaw
bash ./scripts/cleanup-legacy-elk.sh
```

----

#### Deploying a new Fleet+OSQuery environment

With the MTC setup, change directories to the scripts path and run the
deployment tooling.

``` bash
cd /opt/magnanimous-turbo-chainsaw
bash ./scripts/deploy-fleet.sh
```

#### Deploying a new ELK environment

With the MTC setup, change directories to the scripts path and run the
deployment tooling.

``` bash
cd /opt/magnanimous-turbo-chainsaw
bash ./scripts/deploy-elk.sh
```

#### Deploying a new Skydive environment

With the MTC setup, change directories to the scripts path and run the
deployment tooling.

``` bash
cd /opt/magnanimous-turbo-chainsaw
bash ./scripts/deploy-skydive.sh
```

----

#### Ensureing the MTC is up-to-date after a system upgrade

In the event that the underlying system is running `openstack-ansible`
for an OpenStack cloud deployment it's recommended to update the MTC
repositories whenever the system's roles have been changed or modified;
after an OpenStack version upgrade. This can be done by running a
simple Ansible galaxy command.

``` bash
# Make sure to have the OSA_PATH defined
${HOME}/ansible_venv/bin/ansible-galaxy install -r "${OSA_PATH}/ansible-role-requirements.yml"\
                                                --ignore-errors \
                                                --force \
                                                --roles-path="${HOME}/ansible_venv/repositories/roles"
```

----

### Local testing

All of the tools covered by the MTC can be tested on a local test instance.
Recommended specifcations are >= 4GiB of RAM with 32GiB or disk space on root.

To spin up a test instance, run the following command.

``` bash
cd /opt/magnanimous-turbo-chainsaw
bash ./tests/run-tests.sh
```
