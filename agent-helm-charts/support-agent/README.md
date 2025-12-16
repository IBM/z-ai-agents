# IBM Z Support Agent

## Overview
The IBM Z Support Agent enables users to execute Ansible playbooks through the Watson Assistant for Z chat interface.

## Agent capabilities

| Agent capability         |            Description                  |
|------------------------------|-----------------------------------|
| Take z/OS dump        | Collect dump on a z/OS address space    |
| Send z/OS dump | Transfer the dump collected on z/OS address space |
| Retrieve job status | Retrieve the launched ansible job status and logs |



## Prerequisites
Ensure the following:

- [watsonx Assistant for Z](https://www.ibm.com/docs/watsonx/waz/3.1.0?topic=install-premises-watsonx-orchestrate-watsonx-assistant-z) is installed
- Ansible Automation Platform instance and its credentials



## Install the IBM Z Support Agent

### Create Shared Variables

Certain variables are common across all agents. To configure these shared variables, refer to [Create shared variables](https://github.com/IBM/z-ai-agents/blob/main/README.md#1-global-settings) (link to the global GitHub page).
However, if any of these shared variables are also defined in your agent-specific [values.yaml](https://github.com/IBM/z-ai-agents/blob/main/wxa4z-agent-suite/values.yaml) file, the values specified in the values.yaml file will override the shared ones.

### Configure the values.yaml file

To enable the IBM Z Support Agent, you need to configure agent-specific values in the [values.yaml](https://github.com/IBM/z-ai-agents/blob/main/wxa4z-agent-suite/values.yaml) file.

In the values.yaml file, scroll down to the Support Agent section and update the keys as outlined in the following table.

| Key       |            Description                  |
|------------------------------|-----------------------------------|
**Environment variables**                                                        |
WATSONX_MODEL_ID | LLM Model Used by the Agent. For example, "meta-llama/llama-3-70b-instruct".
TAKE_DUMP_JOB_TEMPLATE | Template name of take dump ansible job 
SEND_DUMP_JOB_TEMPLATE | Template name of send dump anisble job
**Secrets**
AAP_ENDPOINT | Base URL of your AAP instance for the tls-agent
AAP_USERNAME | Username credential for accessing the AAP API
AAP_PASSWORD | Password credential for accessing the AAP API
SEND_DUMP_TRANSFER_ID | Transfer ID for required send dump job
SEND_DUMP_TRANSFER_PASSWORD | Transfer password required for send dump job
AGENT_AUTH_TOKEN | Authentication token for the agent.



### Install or upgrade the wxa4z-agent-suite

> **Note**:- If you're installing multiple agents, you can configure the [values.yaml](https://github.com/IBM/z-ai-agents/blob/main/wxa4z-agent-suite/values.yaml) file for all the agents you wish to install. Once the file is updated, run the command below to install them all at once.


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
3. Select the **IBM Z Support Agent** tile.
4. In the AI Assistant window, enter a query to confirm that the response aligns with your expectations.
5. Click **Deploy** to activate the agent and make it available in the live environment.


## Test the agent

After deployment, the agent becomes active and is available for selection in the live environment.

1. From the main menu, click **Chat**.
2. Choose your agent from the list.
3. Enter your queries using the AI Assistant.
   For example:
   
      - Can you take dump of z/os?

    Responses are displayed either in a tabular format or as a sentence, depending on the context.

4. Verify that the responses returned by the AI Assistant are accurate.


## Troubleshooting installation errors

If you run into any errors during installation, see [wxa4z-agent-suite installation guide](https://github.ibm.com/wxa4z/agent-deployment-charts/tree/support_agent-readme-update/agent-helm-charts/support-agent) for troubleshooting steps.

## Uninstalling the agent
For uninstallation instructions, see [wxa4z-agent-suite installation guide](https://github.ibm.com/wxa4z/agent-deployment-charts/tree/support_agent-readme-update/agent-helm-charts/support-agent)

------------------------------------------------------------