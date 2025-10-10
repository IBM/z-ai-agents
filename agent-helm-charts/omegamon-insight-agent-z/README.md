# IBM Z OMEGAMON Insights Agent

## Overview
The IBM Z OMEGAMON Insights Agent enables system programmers to retrieve and analyze system information through the Watson Assistant for Z chat interface. It provides accurate insights by leveraging OMEGAMON data.

## Agent capabilities

| Agent capability                                 | Description                                                                                                                 |
| ------------------------------------------------ | --------------------------------------------------------------------------------------------------------------------------- |
| Retrieves Db2 subsystem details                  | Provides metadata and status information about Db2 subsystems, including configuration, buffer pools, and health.           |
| Retrieves IMS system details                     | Displays IMS system data, region details, and overall system status for monitoring and analysis.                            |
| Retrieves JVM system information                 | Retrieves JVM system data and lock runtime metrics for workload monitoring and analysis.                                |
| Retrieves LPAR system details                    | Displays LPAR system details and job statuses for performance monitoring and analysis.                            |
| Retrieves network details                        | Displays network system information and TCP listener metrics for monitoring and analysis.                                       |
| Retrieves storage information                    | Displays storage system information, volume details, and dataset statuses for performance monitoring and analysis.                                            |
| Retrieves CICSplex and CICS region details       | Displays CICSplex system information, region details, and transaction statuses for monitoring and analysis.                                                     |
| Retrieves MQ subsystem details                   | Displays MQ system information and queue statuses for performance monitoring and analysis.                                                      |
| Monitors OMEGAMON events                         | Retrieves events from OMEGAMON for different systems.                                             |


## Prerequisites
Ensure the following:

- [watsonx Assistant for Z](https://www.ibm.com/docs/watsonx/waz/3.0.0?topic=install-premises-watsonx-orchestrate-watsonx-assistant-z) is installed
- The [AIOps integration server](https://www.ibm.com/docs/en/watsonx/waz/3.0.0?topic=deploying-configuring-aiops-your-cluster) is installed

## Install the IBM Z OMEGAMON Insights Agent

### Create Shared Variables

Certain variables are common across all agents. To configure these shared variables, refer to [Create Shared Variables](../../README.md#1-global-settings).
However, if any of these shared variables are also defined in your agent-specific [values.yaml](/agent-helm-charts/omegamon-insight-agent-z/values.yaml) file, the values specified in the suite [values.yaml](/wxa4z-agent-suite/values.yaml) file will override the shared ones.

### Configure the values.yaml file

To enable the IBM Z OMEGAMON Insights Agent, you need to configure agent-specific values in the [values.yaml](/wxa4z-agent-suite/values.yaml) file.

In the values.yaml file, scroll down to the omegamon-insights-agent section and update the keys as outlined in the following table.

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
3. Select the **IBM Z OMEGAMON Insights Agent** tile.
4. In the AI Assistant window, enter a query to confirm that the response aligns with your expectations.
5. Click **Deploy** to activate the agent and make it available in the live environment.


## Test the agent

After deployment, the agent becomes active and is available for selection in the live environment.

1. From the main menu, click **Chat**.
2. Choose your agent from the list.
3. Enter your queries using the AI Assistant.
   For example:

  - Show all db2 systems.

  - Show all ims systems.

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