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
`https_proxy` are set, as needed. The setup process will react to proxies making

``` bash
curl https://raw.githubusercontent.com/rcbops/magnanimous-turbo-chainsaw/master/scripts/setup.sh | bash
```

#### Cleaning up an existing ELK environment

With the MTC setup, change directories to the scripts path and run the
cleanup tooling.

``` bash
cd /opt/magnanimous-turbo-chainsaw
bash ./scripts/cleanup-legacy-elk.sh
```

#### Deploying a new ELK environment

With the MTC setup, change directories to the scripts path and run the
deployment tooling.

``` bash
cd /opt/magnanimous-turbo-chainsaw
bash ./scripts/deploy-elk.sh
```

#### Deploying a new Fleet+OSQuery environment

With the MTC setup, change directories to the scripts path and run the
deployment tooling.

``` bash
cd /opt/magnanimous-turbo-chainsaw
bash ./scripts/deploy-fleet.sh
```
