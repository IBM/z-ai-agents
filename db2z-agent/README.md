# IBM Db2 for z/OS Agent

## Overview
IBM Db2 for z/OS Agent is an AI-powered assistant that enables you to easily obtain real-time information about your Db2 for z/OS subsystems and database objects through a simple prompt-based conversational interface. For example, you can ask it what the current value of a particular subsystem parameter is, which buffer pool a particular index uses, or if any utilities are currently running on a subsystem. In addition to providing a response, the agent also explains the method that it used to obtain the response.

## Architecture support
IBM Db2 for z/OS Agent is currently supported on `x86_64` and `s390x` architectures.


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
- [watsonx Assistant for Z](https://www.ibm.com/docs/watsonx/waz/3.2.0?topic=install-premises-watsonx-orchestrate-watsonx-assistant-z)
- Db2 for z/OS v13
* ODBC connectivity to Db2 for z/OS
  - Server verification is recommended but client verification is supported by mounting the license into the deployed container at
    `/usr/local/lib64/python3.12/site-packages/clidriver/license`
  - Steps for mounting license files
      - Authenticate with the OpenShift cluster via terminal using the `oc` CLI.
      - To copy the license files into the designated mounted path, execute the following script.
            

            NS="OPENSHIFT_NAMESPACE"
            POD="POD_NAME"  # Name of the pod Agent is deployed on.
            CTR="CONTAINER_NAME" # Name of MCP server container for e.g. db2z-mcp-server.

            # Local folder to copy (contents of this dir will land under DEST)
            SRC_DIR="./"  # e.g., "./license"
            DEST="/usr/local/lib64/python3.12/site-packages/clidriver/license"

            # Create DEST in the container, then extract from STDIN tar stream
            tar -C "${SRC_DIR}" -cf - . \
            | oc exec -i -n "${NS}" "${POD}" -c "${CTR}" -- env DEST="${DEST}" \
              python -c 'import sys, os, tarfile
            d = os.environ["DEST"]
            os.makedirs(d, exist_ok=True)
            with tarfile.open(fileobj=sys.stdin.buffer, mode="r|*") as t:
                t.extractall(d)
            ' 
            
  - To connect the Agent to Db2, connections need to be created via MCP server. Click the [link](https://www.ibm.com/docs/en/db2-for-zos/13.0.0?topic=configuring-connecting-agent-db2) for more details.
          
          
* A watsonx api key, which is used as the value for the WATSONX_API_KEY environment variable
  - Configured as `WATSONX_API_KEY` environment variable.
* One of the following deployment options:
  - A watsonx Deployment Space ID or a watsonx Project ID. See Creating deployment spaces for instructions for creating a deployment space and for obtaining the GUID for the space. You will specify the GUID value on the WATSONX_DEPLOYMENT_SPACE_ID or the WATSONX_PROJECT_ID environment variable in a subsequent step.
  - IFM-Lite enabled in your environment. If IFM-Lite is enabled in your environment, do not assign a value to the WATSONX_DEPLOYMENT_SPACE_ID or WATSONX_PROJECT_ID environment variable.

## Install the IBM Db2 for z/OS Agent


### Retrieve the entitlement key

An entitlement key is required to download the Db2 for z/OS Agent container image from the IBM Container Registry. This entitlement key is available at no charge to licensed users of Db2 13.
 
* To obtain the entitlement key, open a case with IBM Support indicating that you are requesting the entitlement key for IBM Db2 for z/OS Agent.
 
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

### Create shared variables

Certain variables are common across all agents. To configure these shared variables, refer to [Create shared variables](https://github.com/IBM/z-ai-agents?tab=readme-ov-file#1-global-settings) (link to the global GitHub page).
However, if any of these shared variables are also defined in your agent-specific [values.yaml](https://github.com/IBM/z-ai-agents/blob/main/agent-helm-charts/db2z-agent/values.yaml) file, the values specified in the values.yaml file will override the shared ones.

### Configure the values.yaml file

To enable the IBM Db2 for z/OS Agent, you need to configure agent-specific values in the values.yaml file.

Update the keys as outlined in the following table.

| Key       |            Description                  |
|------------------------------|-----------------------------------|
***Environment variables***
**For ON-PREM Deployments**
MODEL_RUNTIME | Deployment environment type (`on_prem`)  
WML_URL | CPD Instance URL 
ONPREM_WML_INSTANCE_ID | On-prem wml instance id (always set to `openshift`)
CPD_VERSION | CPD version for on-prem deployments (e.g., `5.1`)              
**For Cloud Deployment**
MODEL_RUNTIME | Deployment environment type (`cloud`)  
WML_URL | WML Instance URL  [IBM WML API Reference](https://cloud.ibm.com/apidocs/machine-learning)               |
**For AIOptimizer Inference Server**
MODEL_RUNTIME | Deployment environment type (`openai_protocol`)
LLM_BASE_URL | URL of the hosted model endpoint
LLM_API_KEY | API key for authenticating with the service
**Common For ON-PREM/Cloud Deployment**
WATSONX_DEPLOYMENT_SPACE_ID | GUID for watsonx deployment space. If IFM-Lite is enabled in your environment, do not specify a value for this variable.
LLM_MODEL | Name  of the large language model to use (`meta-llama/llama-3-1-70b-instruct`)
DB_NAME |  Name of the database (for example, db2zagent)
AUTH_SERVICE_BASE_URL | URL of the authorization service the agent needs to be registered
MCP_SERVER_NAME | Name of the MCP server
MCP_SERVER_URL: | URL of the MCP server that IBM Db2 for z/OS Agent interacts with
SERVICE_ENDPOINT | URL of the service endpoint to generate passticket and user to establish connection of Db2
AGENT_SERVICE_PATH | Rest path exposed by the agent
***Secrets***
WATSONX_API_KEY | IBM Cloud API key for cloud or on-prem deployments. See [Generating API keys for authentication](https://www.ibm.com/docs/en/cloud-paks/cp-data/5.1.x?topic=tutorials-generating-api-keys)
AGENT_AUTH_TOKEN | Token used by the agent-controller to register this agent with wxo (API_KEY or Bearer)
CPD_USERNAME | CPD username for on-prem deployments (set to empty for cloud)
ENCRYPT_KEY | Encrypt key for storing confidential information in montydb metadata store. See [Generating an encrypt key with Python](#generating-an-encrypt-key-with-python)
DB2_AGENT_TOKEN | Authorization token for agents to interact with Authorization service

### Custom Resource (CR) Configuration

The IBM Db2 for z/OS Agent can be deployed using a Custom Resource (CR) definition. The CR provides a declarative way to manage the agent deployment through the agent operator.

#### Prerequisites for CR Deployment

Before deploying the agent using the CR, ensure:

1. The agent operator is installed and running in your cluster
2. You have created the required secrets (see [Secret Configuration](#secret-configuration))
3. The target namespace exists
4. Db2 for z/OS v13 is available with ODBC connectivity configured

#### CR Structure Overview

The Custom Resource consists of the following main sections:

- **metadata**: Identifies the agent and its namespace
- **spec.agentDetails**: Defines agent-specific configuration and bootstrap settings
- **spec.chart**: Specifies the Helm chart location and version
- **spec.values**: Contains deployment values including environment variables and secret references

#### CR Definition

Below is the complete Custom Resource definition for the Db2 for z/OS Agent. Update the placeholder values according to your environment:

```yaml
apiVersion: wxa4z.watsonx.ibm.com/v1alpha1
kind: AgentService
metadata:
  name: db2z-agent
  namespace: ""  # REQUIRED: Target namespace (e.g., wxa4z-agents)
  labels:
    wxa4z.watsonx.ibm.com/managed-by: agent-operator
spec:
  releaseName: db2z-agent
  namespace: ""  # REQUIRED: Must match metadata.namespace
  tenantId: ""  # REQUIRED: Tenant identifier for multi-tenancy support
  wxa4z-core-services-namespace: wxa4z-zad  # Namespace where wxa4z core services are deployed
  
  agentDetails:
    - agentName: db2z-agent
      agentId: wxa4z:db2z-agent:agent
      description: 'AI-powered assistant for Db2 for z/OS subsystems and database objects'
      bootstrapConfig:
        name: "db2z-agent-bootstrap-config"
        fileName: "db2z_agent_bootstrap_config.yaml"
  
  chart:
    repository: oci://icr.io/ibm-db2z-ai
    name: db2z-agent
    version: "1.1.1"  # Update to the desired chart version
    # Uncomment if using a private registry:
    # pullSecrets:
    #   - name: wxa4z-image-pull-secret

  values:
    replicaCount: 1
    
    global:
      secrets:
        name: wxa4z-watsonx-credentials  # Global secrets shared across agents
    
    secrets:
      name: wxa4z-db2z-agent-secrets  # Agent-specific secrets
    
    env:
      # LLM Configuration
      LLM_MODEL: "ibm/granite-4.1-8b"
      # Database Configuration
      DB_NAME: "db2zagent"
      # MCP Configuration
      MCP_SERVER_NAME: "db2z-mcp-server"
      MCP_SERVER_URL: "http://db2z-mcp-server:8080"
      # Add other ENV variables as needed for deployment
```

#### Installing the Agent

1. Save the CR configuration to a file (e.g., `db2z-agent-cr.yaml`)
2. Update all placeholder values marked as `REQUIRED`
3. Apply the CR to your cluster:

```bash
oc apply -f db2z-agent-cr.yaml
```

4. Verify the deployment:

```bash
# Check CR status
oc get agentservice db2z-agent -n <namespace>

# Check agent pods
oc get pods -n <namespace> -l app=db2z-agent

# View agent logs
oc logs -n <namespace> -l app=db2z-agent --tail=100
```

### Secret Configuration

The agent requires Kubernetes Secrets containing sensitive configuration values. **Never commit secrets to version control.**

#### Secret Types

The agent uses two types of secrets:

1. **Global Secrets** (`wxa4z-watsonx-credentials`): Shared across all agents
2. **Agent-Specific Secrets** (`wxa4z-db2z-agent-secrets`): Unique to this agent

#### Agent-Specific Secret Reference

Create a secret with the following structure. **All values must be base64-encoded.**

```yaml
apiVersion: v1
kind: Secret
metadata:
  name: wxa4z-db2z-agent-secrets
  namespace: ""  # REQUIRED: Must match the agent namespace
type: Opaque
data:
  AGENT_AUTH_TOKEN: ""  # Token used by agent-controller to register with wxo
  # Database Configuration (base64-encoded)
  ENCRYPT_KEY: ""  # Encryption key for storing confidential information
  DB2_AGENT_TOKEN: ""  # Authorization token for interacting with Authorization service
  # Optional: Observability (base64-encoded)
  LANGFUSE_SECRET_KEY: ""
  LANGFUSE_PUBLIC_KEY: ""
```

#### Creating the Secret

Apply the secret:

```bash
oc apply -f secret.yaml
```


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


### Step 3: Subscribe to the agent

After successfully deploying the agent, you need to subscribe to it to make it available in watsonx Orchestrate.

1. Open the Cloud Pak for Data (CPD) home page.
   - Example: `https://cpd-<instance>.apps.<cluster-domain>/zen/?context=icp4data#/homepage`

2. Click on the **Launch WXA4Z console** tab.
   - This opens the WXA4Z Content Ingestion UI (Tenant Overview page).
   - Example: `https://wxa4z-content-ingestion-ui-route-wxa4z-zad.apps.<cluster-domain>/en`

3. On the Tenant Overview page, click on your **Tenant name**.

4. Navigate to the **Subscriptions** tab.
   - You will see a list of deployed agents with a **Subscribe** button next to each.

5. Click the **Subscribe** button next to the **IBM Db2 for z/OS Agent**.
   - This action adds the agent to watsonx Orchestrate (WXO) and makes it available for deployment.


### Step 4: Deploy the agent

1. Log in to watsonx Orchestrate.
2. From the main menu, navigate to **Build** > **Agent Builder**.
3. Select the **IBM Db2 for z/OS Agent** tile.
4. In the AI Assistant window, enter a query to confirm that the response aligns with your expectations.
5. Click **Deploy** to activate the agent and make it available in the live environment.


### Step 5: Upgrade the Agent

To upgrade the agent to a new version:

> **Note:** If the agent was previously subscribed to watsonx Orchestrate, you must first unsubscribe it before upgrading. After the upgrade is complete, re-subscribe the agent. See the [Uninstall the Agent](#step-6-uninstall-the-agent) section for unsubscribe steps and the [Subscribe to the agent](#step-3-subscribe-to-the-agent) section for subscribe steps.

1. Update the `spec.chart.version` field in your CR file:

```yaml
spec:
  chart:
    version: "1.1.2"  # Update to the new version
```

2. Apply the updated CR:

```bash
oc apply -f db2z-agent-cr.yaml
```

3. Monitor the upgrade progress:

```bash
# Watch the MCP client pods rolling update
oc get pods -n <namespace> -l app=db2z-agent-mcp-client -w

# Watch the MCP server pods rolling update
oc get pods -n <namespace> -l app=db2z-agent-mcp-server -w

# Check the CR status
oc describe agentservice db2z-agent -n <namespace>
```

The agent operator will automatically handle the upgrade process, including rolling updates of both MCP client and server pods.

### Step 6: Uninstall the Agent

To uninstall the agent:

**If the agent was previously subscribed to watsonx Orchestrate**, first unsubscribe it:

1. Open the Cloud Pak for Data (CPD) home page.
   - Example: `https://cpd-<instance>.apps.<cluster-domain>/zen/?context=icp4data#/homepage`

2. Click on the **Launch WXA4Z console** tab.
   - This opens the WXA4Z Content Ingestion UI (Tenant Overview page).
   - Example: `https://wxa4z-content-ingestion-ui-route-wxa4z-zad.apps.<cluster-domain>/en`

3. On the Tenant Overview page, click on your **Tenant name**.

4. Navigate to the **Subscriptions** tab.
   - You will see a list of deployed agents with an **Unsubscribe** button next to each.

5. Click the **Unsubscribe** button next to the **IBM Db2 for z/OS Agent**.
   - This action removes the agent from watsonx Orchestrate (WXO).

**Then, delete the agent resources:**

1. Delete the Custom Resource:

```bash
oc delete agentservice db2z-agent -n <namespace>
```

2. Verify the agent resources are removed:

```bash
# Check that the MCP client pods are terminated
oc get pods -n <namespace> -l app=db2z-agent-mcp-client

# Check that the MCP server pods are terminated
oc get pods -n <namespace> -l app=db2z-agent-mcp-server

# Verify the CR is deleted
oc get agentservice -n <namespace>
```

3. (Optional) Clean up secrets if no longer needed:

```bash
# Delete agent-specific secrets
oc delete secret wxa4z-db2z-agent-secrets -n <namespace>

# Note: Do not delete global secrets if other agents are using them
```

> **Note:** The agent operator will automatically clean up all resources created by the agent, including deployments, services, and configmaps. However, secrets must be manually deleted if they are no longer needed.

## Test the agent

After deployment, the agent becomes active and is available for selection in the live environment.

1. From the main menu, click **Chat**.
2. Choose your agent from the list.
3. Enter your queries using the AI Assistant.
   For example:
   
      - What are the bufferpool sizes of all my Db2 subsystems?

      - Show me all the indexes under DSN81310 in DWY1.

      - Please retrieve all indexes from STLEC1.

    Responses are displayed either in a tabular format or as a sentence, depending on the context.

4. Verify that the responses returned by the AI Assistant are accurate.

## Troubleshooting installation errors

If you run into any errors during installation, see [Troubleshooting](../../README.md#troubleshooting) for troubleshooting steps.

## Troubleshooting agent runtime errors

Follow these steps to troubleshoot agent runtime errors:

1. _Db2 Connection Error_: Verify that ODBC connectivity is properly configured and license files are mounted correctly
2. _MCP Server Connection Error_: Check that MCP_SERVER_URL is correct and the MCP server is running
3. _Authentication Issues_: Ensure AGENT_AUTH_TOKEN and DB2_AGENT_TOKEN are correctly configured
4. _Database Access Issues_: Verify that the Db2 user has appropriate permissions for the requested operations
5. _MCP Communication Issues_: Check that both MCP client and server pods are running and can communicate

-------------------------

