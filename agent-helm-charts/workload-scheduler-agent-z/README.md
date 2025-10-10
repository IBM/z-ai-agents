# IBM Z Workload Scheduler Insights Agent

## Overview
The IBM Z Workload Scheduler Insights Agent allows system programmers to access and analyze workload and engine data via the Watson Assistant for Z chat interface.

## Agent capabilities

| Agent capability                                 | Description                                                                                                                 |
| ------------------------------------------------ | --------------------------------------------------------------------------------------------------------------------------- |
| Retrieves engine details                          | Provides metadata and status details for all engines, including in-depth engine information.           |
| Retrieves jobs details                            | Provides metadata and status details for all jobs, including comprehensive job-level information.                            |
| Retrieves job streams information                 | Provides metadata and status details for all job streams, including comprehensive job-level information.                                |
| Retrieves workstation details                     | Provides metadata and status details for all workstations, including comprehensive workstation-level information.                            |
| Retrieves critical jobs details                   | Provides metadata and status details for all critical jobs, including comprehensive job-level information.                                       |


## Prerequisites
Ensure the following:

- [watsonx Assistant for Z](https://www.ibm.com/docs/watsonx/waz/3.0.0?topic=install-premises-watsonx-orchestrate-watsonx-assistant-z) is installed
- The [AIOps integration server](https://www.ibm.com/docs/en/watsonx/waz/3.0.0?topic=deploying-configuring-aiops-your-cluster) is installed

## Install the IBM Z Workload Scheduler Insights Agent

### Create Shared Variables

Certain variables are common across all agents. To configure these shared variables, refer to [Create Shared Variables](../../README.md#1-global-settings).
However, if any of these shared variables are also defined in your agent-specific [values.yaml](/agent-helm-charts/workload-scheduler-agent-z/values.yaml) file, the values specified in the suite [values.yaml](/wxa4z-agent-suite/values.yaml) file will override the shared ones.

### Configure the values.yaml file

To enable the IBM Z Workload Scheduler Insights Agent, you need to configure agent-specific values in the [values.yaml](/wxa4z-agent-suite/values.yaml) file.

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

> **Note**:- If you're installing multiple agents, you can configure the [values.yaml](/wxa4z-agent-suite/values.yaml) file for all the agents you wish to install. Once the file is updated, run the command below to install them all at once.

Use the following command to install or upgrade the wxa4z_agent_suite:

```yaml
helm upgrade --install wxa4z-agent-suite \
  ./wxa4z-agent-suite \
  -n <wxa4z-namespace> \
  -f <path_to>/values.yaml --wait
```

## Deploy the agent

1. Log in to watsonx Orchestrate.
2. From the main menu, navigate to **Build** > **Agent Builder**.
3. Select the **IBM Z Workload Scheduler Insights Agent** tile.
4. In the AI Assistant window, enter a query to confirm that the response aligns with your expectations.
5. Click **Deploy** to activate the agent and make it available in the live environment.


## Test the agent

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


## Troubleshooting installation errors

If you run into any errors during installation, see [Troubleshooting](../../README.md#troubleshooting) for troubleshooting steps.


## Uninstalling the agent

For uninstallation instructions, see [Uninstall specific agent](../../README.md#uninstall-specific-agent).


## Troubleshooting agent runtime errors

Follow these steps to troubleshoot agent runtime errors:

1. _HTTPSConnectionPool_: check that your AIOps integration server is reachable (correct AIOPS Base URL and AIOPS Token, VPN access, etc.)

------------------------------------------------------------