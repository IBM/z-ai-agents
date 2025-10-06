# IBM Db2 for z/OS Agent

## Overview
IBM Db2 for z/OS Agent is an AI-powered assistant that enables you to easily obtain real-time information about your Db2 for z/OS subsystems and database objects through a simple prompt-based conversational interface. For example, you can ask it what the current value of a particular subsystem parameter is, which buffer pool a particular index uses, or if any utilities are currently running on a subsystem. In addition to providing a response, the agent also explains the method that it used to obtain the response.

## Architecture support
IBM Db2 for z/OS Agent is currently supported on `x86_64` architecture.


## Agent capabilities

| Agent capability         |             Description                  |
|------------------------------|-----------------------------------|
**Retrieving System Information**
Show me all the bufferpools under DBD1. | Lists all bufferpools in the specified Db2 subsystem. |
Can you tell me details about BP32K?  | Retrieves configuration and usage details for the specified bufferpool. |
Comparing System Information Across Subsystems | Compares system information between different Db2 subsystems and shows only differences. |
**Retrieving zParm Values**
What is the zparm value of UTILITY_HISTORY in DBD1?  |  Shows current value of the specified zparm parameter. |
**Comparing zParm Across Subsystems**
Show me MAXDBAT, CONDBAT, DSMAX, and APPLCOMPAT zparm values for DBD1 and DBC1. | Structured output listing the values of the requested zparm. |
**Catalog Navigation with System Information**
What are the schemas under DBD1? | Lists all schemas defined in the given Db2 subsystem. |
What are the indexes under DSN81310?  | Lists all indexes within the specified schema. |
Which table is XCONA1 created for? | Identifies the table that a given index is defined on. |
Which bufferpool does XCONA1 use? | Shows which bufferpool is associated with the index. |
Can you give me details about that bufferpool? | Fetches detailed bufferpool information related to the referenced index. |


# Prerequisites:
- [watsonx Assistant for Z](https://www.ibm.com/docs/en/watsonx/waz/2.0.0?topic=install-watsonx-assistant-z)
- Db2 for z/OS v13
* ODBC connectivity to Db2 for z/OS
  - Server verification is recommended but client verification is supported by mounting the license into the deployed container at
    `/usr/local/lib64/python3.12/site-packages/clidriver/license`
* A watsonx api key, which is used as the value for the WATSONX_API_KEY environment variable
  - Configured as `WATSONX_API_KEY` environment variable.
* A watsonx Deployment Space ID or Project ID.
  - See [create deployment space](https://www.ibm.com/docs/en/watsonx/w-and-w/2.1.0?topic=spaces-creating-deployment) for instructions. To get the `space GUID`, open your deployment space, and click the `Manage` tab.
  - Use this value as `WATSONX_DEPLOYMENT_SPACE_ID` or `WATSONX_PROJECT_ID` environment variable.


## Install the IBM Db2 for z/OS Agent


### Retrieve the entitlement key

An entitlement key is required to download the Db2 for z/OS Agent container image from the IBM Container Registry. This entitlement key is available at no charge to licensed users of Db2 13.
 
* Existing Db2 for z/OS customers should download and apply the PTF that is associated with APAR PH67670 to access the PDF document that contains the entitlement key.
* For new Db2 for z/OS customers, the entitlement key is included with the product code that you obtain through Shopz.
 
Set the global entitlement key using the watsonx Assistant for Z entitlement key:

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
However, if any of these shared variables are also defined in your agent-specific [values.yaml](https://github.ibm.com/wxa4z/agent-deployment-charts/blob/main/agent-helm-charts/db2z-agent/values.yaml) file, the values specified in the values.yaml file will override the shared ones.

### Configure the values.yaml file

To enable the IBM Db2 for z/OS Agent, you need to configure agent-specific values in the [values.yaml](https://github.ibm.com/wxa4z/agent-deployment-charts/blob/main/agent-helm-charts/db2z-agent/values.yaml) file.

In the values.yaml file, scroll down to the IBM Db2 for z/OS Agent section and update the keys as outlined in the following table.

| Key       |            Description                  |
|------------------------------|-----------------------------------|
***Environment variables***
**For ON-PREM Deployments**
WATSONX_DEPLOYMENT_TYPE | Deployment environment type (`on_prem`)  
WML_URL | CPD Instance URL 
ONPREM_WML_INSTANCE_ID | on-prem wml instance id (always set to `openshift`)
CPD_VERSION | CPD version for on-prem deployments (e.g., `5.1`)              
**For Cloud Deployment**
WATSONX_DEPLOYMENT_TYPE | Deployment environment type (`cloud`)  
WML_URL | WML Instance URL  [IBM WML API Reference](https://cloud.ibm.com/apidocs/machine-learning)               |
**Common For ON-PREM/Cloud Deployment**
DEPLOYMENT_SPACE_ID | Identifier of the Watson Machine Learning deployment space  refer [Prerequesites]
(#prerequisites) for creating deployment space.
LLM_MODEL | Name  of the large language model to use (`meta-llama/llama-3-1-70b-instruct`)
MONGODB_DB_NAME |  Name of the mongodb database. For example, `db2zagent`.
AUTH_SERVICE_BASE_URL | URL of the authorization service the agent needs to be registered.
MCP_SERVER_NAME | Name of the MCP server.
MCP_SERVER_URL: | URL of the MCP server that IBM Db2 for z/OS Agent interacts with. 
SERVICE_ENDPOINT | URL of the service endpoint to generate passticket and user to establish connection of Db2.
AGENT_SERVICE_PATH | Rest path exposed by the agent.
***Secrets***
MONGODB_URI | Bundled MongoDB container for metadata store.<br />By default, the agent connects to a bundled MongoDB container running on the same Docker network.<br />This container is only accessible to other containers on the same network and is not exposed externally.<br />The values for these CAN be changed but be done so with care to not break the service
MONGODB_DB_USERNAME | Bundled MongoDB container intial user username
MONGODB_DB_PASSWORD | Bundled MongoDB container intial user password 
WATSONX_API_KEY | IBM Cloud API key for cloud or on-prem deployments [How to get cpd api key on-prem](https://www.ibm.com/docs/en/cloud-paks/cp-data/5.1.x?topic=tutorials-generating-api-keys)
AGENT_AUTH_TOKEN | Token used by the agent-controller to register this agent with wxo (API_KEY or Bearer) 
CPD_USERNAME | CPD username for on-prem deployments (set to empty for cloud)   
ENCRYPT_KEY | Encrypt key for storing confidential information in mongodb metadata store. See [Generating an encrypt key with Python](#generating-an-encrypt-key-with-python)
AGENT_SECRET | Authorization token for agents to interact with Authorization service.


## Generating an encrypt key with Python

### Step 1: Install the package cryptography via pip and run python
```bash
pip install cryptography
python
```

### Step 2: Generate the key in python terminal
```python
from cryptography.fernet import Fernet
Fernet.generate_key()
```      


### Storage
To use persistent storage, set `pvc.enabled` to true and adjust the `pvc.size`, `pvc.storageClass`, and `pvc.accessModes` settings as needed. 

### Resources
Configure `resources.limits` and `resources.requests` to configure the CPU and memory resources for your deployment. 


### Install or upgrade the wxa4z-agent-suite

> **Note**:- If you're installing multiple agents, you can configure the [values.yaml](https://github.ibm.com/wxa4z/agent-deployment-charts/blob/main/wxa4z-agent-suite/values.yaml) file for all the agents you wish to install. Once the file is updated, run the command below to install them all at once.


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
3. Select the **IBM Db2 for z/OS Agent** tile.
4. In the AI Assistant window, enter a query to confirm that the response aligns with your expectations.
5. Click **Deploy** to activate the agent and make it available in the live environment.


## Test your agent

After deployment, the agent becomes active and is available for selection in the live environment.

1. From the main menu, click **Chat**.
2. Choose your agent from the list.
3. Enter your queries using the AI Assistant.
   For example:
   
      - What are the bufferpool sizes of all my Db2 subsystems?

      - Show me all the indexes under DSN81310 in DWY1.

      - Please retrieve all indexes from utec648.vmec.svl.ibm.com/STLEC1.

    Responses are displayed either in a tabular format or as a sentence, depending on the context.

4. Verify that the responses returned by the AI Assistant are accurate.


------------------------------------------------------------


