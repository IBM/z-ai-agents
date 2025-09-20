# IBM Z Automation Insights Agent

## Overview
The IBM Z Automation Insights Agent enables system programmers to retrieve and analyze system information through the Watsonx Assistant for Z chat interface, using insights from Automation and Netview domains.

## Agent capabilities

| Agent capability                                 | Description                                                                                                                 |
| ------------------------------------------------ | --------------------------------------------------------------------------------------------------------------------------- |
| Retrieves Automation Domain details              | Provides metadata and status information about Automation Domain subsystems, including domains, domain state, and list of resources for a domain.                                            |
| Retrieves Automation Resource details            | Provides visibility into domain resources, including detailed views of individual resources, their members, relationships, and associated requests.      |
| Retrieves Automation System details              | Lists available systems and provides specific system details.                                |
| Retrieves Netview details                        | Shows a list of all netview domains, details for a specific netview domain, and canzlogs for a specific netview domain.                            |

## Prerequisites
Ensure the following:

- [watsonx Assistant for Z](https://www.ibm.com/docs/watsonx/waz/3.0.0?topic=install-premises-watsonx-orchestrate-watsonx-assistant-z) is installed
- The [AIOps integration server](https://www.ibm.com/docs/en/watsonx/waz/3.0.0?topic=deploying-configuring-aiops-your-cluster) is installed

## IBM Z Automation Insights Agent

### Create Shared Variables

Certain variables are common across all agents. To configure these shared variables, refer to [Create Shared Variables](../../README.md#1-global-settings).
However, if any of these shared variables are also defined in your agent-specific [values.yaml](https://github.ibm.com/wxa4z/agent-deployment-charts/blob/main/wxa4z-agent-suite/values.yaml) file, the values specified in the values.yaml file will override the shared ones.

### Configure the values.yaml file

To enable the IBM Z Automation Insights Agent, you need to configure agent-specific values in the [values.yaml](https://github.ibm.com/wxa4z/agent-deployment-charts/blob/main/wxa4z-agent-suite/values.yaml) file.

In the values.yaml file, scroll down to the automation-insights-agent section and update the keys as outlined in the following table.

| Key       |            Description                  |
|------------------------------|-----------------------------------|
**Environment variables**                                                        |
WATSONX_MODEL_ID | LLM Model Used by the Agent. For example, "meta-llama/llama-3-3-70b-instruct".
**Secrets**
AIOPS_BASE_URL | The endpoint URL for the ZchatOps server.
AIOPS_TOKEN | Token for connecting to the ZchatOps server.
AGENT_AUTH_TOKEN | Authentication token for the agent.


### Install or upgrade the wxa4z-agent-suite

> **Note**:- If you're installing multiple agents, you can configure the [values.yaml](https://github.ibm.com/wxa4z/agent-deployment-charts/blob/main/wxa4z-agent-suite/values.yaml) file for all the agents you wish to install. Once the file is updated, run the command below to install them all at once.

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
3. Select the **IBM Z Automation Insights Agent** tile.
4. In the AI Assistant window, enter a query to confirm that the response aligns with your expectations.
5. Click **Deploy** to activate the agent and make it available in the live environment.


## Test the agent

After deployment, the agent becomes active and is available for selection in the live environment.

1. From the main menu, click **Chat**.
2. Choose your agent from the list.
3. Enter your queries using the AI Assistant.
   For example:

  - Show all domains.

  - Show all systems.

  - Show all netviews.

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