# TAZ Functional Testing Agent

## Overview
IBM Test Accelerator for Z - Functional Testing Agent

Product Description:
 An AI-powered solution that uses natural language inputs to automatically create UI-driven functional test cases.
 This tool leverages agentic AI to transform written requirements and manual test descriptions into executable Java Galasa tests. The Microsoft Visual Studio Code (VS Code) of this tool enables user to view all the capabilities of transaction screens and generate functional tests for them.

Requirements:

- IBM Test Accelerator for Z, from a product enablement perspective.
- IBM TAZ Functional Testing extension for VS Code
- IBM Enterprise Edition for Galasa is required to run the generated Java Galasa functional tests and is backed by IBM Technical Support.

For more details, explore the following resources:

- Functional Testing - <https://www.ibm.com/think/topics/functional-testing>
- IBM Test Accelerator for Z and IBM Enterprise Edition for Galasa – <https://www.ibm.com/products/test-accelerator-z>
- The Open Mainframe Project Galasa - <https://galasa.dev/>

## Agent Capabilities

| Agent Capability         |            Description                  |
|------------------------------|-----------------------------------|
| Generates Functional Tests for CICS application | Agent generates Functional Tests for CICS application from BMS Map files |
| Generates Functional tests for IMS application | Agent generates Functional Tests for IMS application from MFS Map files |
| Bulk generation of Functional Tests | Agent generates Functional Tests for multiple capabilities at one go|

## Prerequisites

The following prerequisites must be completed:

- Requires an active IBM Test Accelerator for Z instance with valid credentials.

- A watsonx.ai deployment space must be configured.
  - Please refer to [create deployment space](https://www.ibm.com/docs/en/watsonx/w-and-w/2.1.0?topic=spaces-creating-deployment) and to get the space GUID, open your deployment space and click the Manage tab.
  - The space GUID should be set as deployment_space_id as environment variable.

- Additional details regarding prerequisites can be found in the - [Functional Testing
](https://www.ibm.com/docs/en/test-accelerator-for-z/2.0.0?topic=functional-testing)

## Install the IBM Z Functional Test Agent

For installation guidance, refer to [Installing the Functional Testing VS Code extension](https://www.ibm.com/docs/en/test-accelerator-for-z/2.0.0?topic=testing-installation)

### Retrieve the entitlement key

During the installation of watsonx Assistant for Z, you would have received an entitlement key. If you need to retrieve it again, follow these steps:

 1. Sign in to [My IBM](https://myibm.ibm.com/dashboard/).
 2. Scroll to the Container Software & Entitlement Keys section and click View Library.
 3. Locate your entitlement key and click Copy.
 4. Set the global entitlement key using the watsonx Assistant for Z entitlement key.

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

Certain variables are common across all agents. To configure these shared variables, refer to [Create shared variables](https://github.com/IBM/z-ai-agents?tab=readme-ov-file#1-global-settings) (link to the global GitHub page).
However, if any of these shared variables are also defined in your agent-specific [values.yaml](https://github.com/IBM/z-ai-agents/blob/main/agent-helm-charts/taz-functional-testing-agent/values.yaml) file, the values specified in the values.yaml file will override the shared ones.

### Resources

Configure `resources.limits` and `resources.requests` to configure the CPU and memory resources for your deployment.

### Configure the values.yaml file

To enable the IBM Z Functional Test Agent, you need to configure agent-specific values in the [values.yaml](https://github.com/IBM/z-ai-agents/blob/main/wxa4z-agent-suite/values.yaml) file.

In the values.yaml file, scroll down to the taz-functional-testing-agent section and update the keys as outlined in the following table.

**Environment variables**

| Key                      |            Description                  |
|--------------------------|-----------------------------------------|
| `DEPLOYMENT_SPACE_ID`    | Identifier of the Watson Machine Learning deployment space  refer [Prerequisites](#prerequisites) for creating deployment space.
| `WML_URL`                | CPD Instance URL.
| `ONPREM_WML_INSTANCE_ID` | on-prem wml instance id (always set to `openshift`)                                                                                |
| `LLM_MODEL`              | Name  of the large language model to use. For example, `meta-llama/llama-3-1-70b-instruct`
| `DEPLOYMENT_TYPE`        | Deployment environment type. For example `on-prem`                                                                                             |
| `CPD_VERSION`            | CPD version for on-prem deployments (e.g., `5.1`)
| `API_BASE_URL`           | API BASE URL
| `UPLOADS_PATH`           | Folder path where context files are stored after user/UI uploads them. For example /opt/app-root/data/uploads
| `DOWNLOADS_PATH`         | Folder path where generated test files are stored. For example, /opt/app-root/data/uploads
| `UNDERSTAND_API_ENDPOINT`| The understand url from where the data is fetched
| `CFG_URI`                | The url from which the CFGs are fetched
| `AD_HOST`                | The name of the AD Host where data is present
| `ZOOKEEPER_HOST_PORT`    | AD ZooKeeper port through which database can be accessed
| `IS_UNDERSTAND_CERT_VALIDATE_REQ` | Indicates whether certificate validation is required for the Understand component (accepts "True" or "False" as values).


**Secrets**

| Key                          |            Description            |
|------------------------------|-----------------------------------|
| `CPD_USERNAME`               | CPD username for on-prem deployments (set to empty for cloud) 
| `AGENT_AUTH_TOKEN`           | Token used by the agent-controller to register this agent with wxo (API_KEY or Bearer)
| `UNDERSTAND_API_KEY`         | The API key that is used to get data from understand
| `ENVIRONMENT_ID`             | The unique ID to access database
| `understandName`             | Generate a Kubernetes secret from the certificate of the 'understand' component within the TAZ FTA cluster's namespace, and configure the values.yaml file to reference this secret.


### Install or upgrade the taz-functional-testing-agent

> **Note**:- If you're installing multiple agents, you can configure the [values.yaml](https://github.com/IBM/z-ai-agents/blob/main/wxa4z-agent-suite/values.yaml) file for all the agents you wish to install. Once the file is updated, run the command below to install them all at once.

Use the following command to install or upgrade the taz-functional-testing-agent:

```yaml
helm upgrade --install taz-functional-testing-agent \
  ./wxa4z-agent-suite \
  -n <wxa4z-namespace> \
  -f <path_to>/values.yaml --wait
```

## Deploy your agent

1. Log in to watsonx Orchestrate.
2. From the main menu, navigate to **Build** > **Agent Builder**.
3. Select the **IBM Z Functional Test Agent** tile.
4. In the AI Assistant window, enter a query to confirm that the response aligns with your expectations.
5. Click **Deploy** to activate the agent and make it available in the live environment.

## Test your agent

Once deployed, the agent becomes active and available for use in the live environment:

 1. Navigate to the Chat section from the main menu.
 2. Select your agent from the available list.
 3. Enter queries via the AI Assistant, such as:

  - Generate Galasa test for sample application for functionality adding a customer
  - Generate Galasa test for updating motor policy (agent will prompt for context file upload)

 4. Responses are displayed in the chat window, with an option to download the generated Galasa test file.
 5. Review the responses to ensure accuracy.
 
------------------------------------------------------------
