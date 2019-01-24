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
There are many ways to bootstrap an environment with the MTC tooling, the
easiest way is to simply download the setup script and run it.

If working with a proxy, make sure the `noproxy`, `http_proxy`, and
`https_proxy` are set, as needed. The setup process will react to proxies
making

``` bash
curl https://raw.githubusercontent.com/rcbops/magnanimous-turbo-chainsaw/master/scripts/setup.sh | bash
```

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
