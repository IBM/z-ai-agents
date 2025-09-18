# IBM Z Workload Scheduler Insights Agent

## Overview
The IBM Z Workload Scheduler Insights Agent enables system programmers to retrieve and analyze workloads and engines information through the Watson Assistant for Z chat interface.
## Agent capabilities

| Agent capability                                 | Description                                                                                                                 |
| ------------------------------------------------ | --------------------------------------------------------------------------------------------------------------------------- |
| Retrieves engine details                  | Provides metadata and status information about all engines and their detailed information.           |
| Retrieves jobs details                     | Provides metadata and status information about all jobs and their detailed information.                            |
| Retrieves job streams information                 | Provides metadata and status information about all job streams and their detailed information.                                |
| Retrieves workstation details                    | Provides metadata and status information about all workstations and their detailed information..                            |
| Retrieves critical jobs details                        | Provides metadata and status information about all critical jobs and their detailed information.                                       |




## Prerequisites
Ensure the following:

- [watsonx Assistant for Z](https://www.ibm.com/docs/en/watsonx/waz/2.0.0?topic=install-watsonx-assistant-z) is installed
- The [AIOps integration server](https://www.ibm.com/docs/en/watsonx/waz/2.0.0?topic=deploy-configure-aiops-your-cluster) is installed

## Install the IBM Z Workload Scheduler Insights Agent


### Retrieve the entitlement key

During the installation process of watsonx Assistant for Z, you would have acquired the entitlement key. However, if you need to retrieve it again, follow these steps:

1. Click the ink to sign in to [My IBM](https://myibm.ibm.com/dashboard/).
2. Scroll down and locate the Container Software & Entitlement Keys tile, then click View Library.
3. Find your hidden key and click the Copy button next to it.
4. Set the global entitlement key using the watsonx Assistant for Z entitlement key:

```yaml
global:
  registry:
    name: wxa4z-image-pull-secret
    createSecret: true
    server: icr.io
    username: iamapikey
    entitlementKey: "<WATSONX_ASSISTANT_FOR_Z_ENTITLEMENT_KEY>"
```

### Create Shared Variables

Certain variables are common across all agents. To configure these shared variables, refer to [Create shared variables]([https://github.ibm.com/wxa4z/agent-deployment-charts/tree/readme-update?tab=readme-ov-file#step-2-create-shared-variablescreate-once-reuse-everywhere) (link to the global GitHub page).
However, if any of these shared variables are also defined in your agent-specific [values.yaml](https://github.ibm.com/wxa4z/agent-deployment-charts/blob/main/wxa4z-agent-suite/values.yaml) file, the values specified in the values.yaml file will override the shared ones.

### Configure the values.yaml file

To enable the IBM Z Workload Scheduler Insights Agent, you need to configure agent-specific values in the [values.yaml](https://github.ibm.com/wxa4z/agent-deployment-charts/blob/main/wxa4z-agent-suite/values.yaml) file.

In the values.yaml file, scroll down to the workload-scheduler-agent-z section and update the keys as outlined in the following table.

| Key       |            Description                  |
|------------------------------|-----------------------------------|
**Environment variables**                                                        |
WATSONX_MODEL_ID | LLM Model Used by the Agent. For example, "meta-llama/llama-3-70b-instruct".
**Secrets**
AIOPS_BASE_URL | The endpoint URL for the ZchatOps server.
AIOPS_TOKEN | Token for connecting to the ZchatOps server.
AGENT_AUTH_TOKEN | Authentication token for the agent.


### Install or upgrade the wxa4z-agent-suite

<div class="note note"><span class="notetitle">Note:</span> If you're installing multiple agents, you can configure the [values.yaml](https://github.ibm.com/wxa4z/agent-deployment-charts/blob/main/wxa4z-agent-suite/values.yaml) file for all the agents you wish to install. Once the file is updated, run the command below to install them all at once.</div>

Use the following command to install or upgrade the wxa4z_agent_suite:

```yaml
helm upgrade --install wxa4z-agent-suite \
  ./wxa4z-agent-suite \
  -n <wxa4z-namespace> \
  -f <path_to>/values.yaml --wait
```

## Deploy your agent

1. Log in to watsonx Orchestrate.
2. From the main menu, navigate to **Build** > **Agent Builder**.
3. Select the **IBM Z Workload Scheduler Insights Agent** tile.
4. In the AI Assistant window, enter a query to confirm that the response aligns with your expectations.
5. Click **Deploy** to activate the agent and make it available in the live environment.


## Test your agent

After deployment, the agent becomes active and is available for selection in the live environment.

1. From the main menu, click **Chat**.
2. Choose your agent from the list.
3. Enter your queries using the AI Assistant.
   For example:

  - Show all engines.
  - Show all job streams.
  - Show all jobs.

    Responses are displayed either in a tabular format.

4. Verify that the responses returned by the AI Assistant are accurate.


------------------------------------------------------------