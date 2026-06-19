# IBM IMS Agents

## Overview

The IBM IMS Agents is a unified agent solution that combines question-answering capabilities with real-time system interaction. IMS Agents can answer general IMS command-related questions, such as the format or syntax of commands, and can provide insights into the operational state of IMS systems, which can help accelerate troubleshooting by streamlining diagnostics.

## Agent capabilities

| Agent capability            | Description                                                                                          | Tool Name                                           |
| --------------------------- | ---------------------------------------------------------------------------------------------------- | --------------------------------------------------- |
| **General IMS Q/A**         | Answers general IMS related questions and provides documentation search.                             | ims_documentation_search<br/>ims_performance_search |
| **IMS commands**            | Explains syntax for IMS type-1 and type-2 commands.                                                  | get_command_syntax                                  |
| **IMS system**              | Displays active regions and data communication (DC) information for the IMS system.                  | ims_get_system_info                                 |
| **OTMA**                    | Displays IMS Open Transaction Manager Access (OTMA) status and connectivity.                         | ims_get_otma_info                                   |
| **TMEMBER**                 | Displays information about OTMA transaction members (TMEMBERs) and their transaction pipes (TPIPEs). | ims_get_tmember_info                                |
| **Pool**                    | Displays IMS storage pool utilization statistics and buffer usage.                                   | ims_get_pool_info                                   |
| **Transaction**             | Displays the status of IMS transactions.                                                             | ims_get_transaction_info                            |
| **Delayed response**        | Displays nodes with delayed transaction responses exceeding a timeout threshold.                     | ims_get_delayed_response                            |
| **Subsystem**               | Displays information about external subsystems connected to IMS (Db2, MQ, and so on).                | ims_get_subsys_info                                 |
| **Database**                | Displays the status and attributes of IMS databases.                                                 | ims_get_db_info                                     |
| **IMS Connect**             | Displays the current status and activity of IMS Connect (ICON).                                      | ims_get_ims_connect_info                            |
| **Shared queues structure** | Displays the status of IMS shared queues coupling facility structures.                               | ims_get_shared_queues_structure_info                |
| **CCTL**                    | Displays information about Coordinator Controllers (CCTLs) like CICS regions connected to IMS.       | ims_get_cctl_info                                   |
| **Resource error status**   | Displays the current error status of a specified IMS resource type.                                  | ims_get_resource_error_status                       |
| **Diagnostic SNAP**         | Collects diagnostic information and error details for IMS resources.                                 | ims_diag_snap                                       |
| **Program**                 | Displays the normal operating status of a specific program.                                          | ims_get_program_info                                |
| **OLDS**                    | Displays the system logging status.                                                                  | ims_get_olds_info                                   |
| **User**                    | Displays information about IMS user structures and user IDs.                                         | ims_get_user_info                                   |
| **SYSID transaction**       | Displays the IDs of the local and remote systems associated with a transaction.                      | ims_sysid_transaction                               |
| **Queue**                   | Displays IMS message queue status information.                                                       | ims_get_queue_info                                  |
| **Trace**                   | Displays IMS trace definitions or status.                                                            | ims_get_trace_info                                  |
| **CQS**                     | Displays the status of the IMS Common Queue Server (CQS).                                            | ims_get_cqs_info                                    |
| **PSB**                     | Displays which transactions the PSB is processing and which databases are accessed.                  | ims_get_psb_info                                    |
| **Queue count**             | Displays global queue count information for the specified resource type.                             | ims_display_qcnt                                    |
| **DBD**                     | Displays database type, accessing PSBs, and access types for databases being accessed.               | ims_dis_dbd                                         |
| **Overflow queue**          | Displays queue names that are in overflow mode for coupling facility structures.                     | ims_dis_overflowq                                   |
| **Area**                    | Displays data sets, status conditions, and databases associated with Fast Path DEDB areas.           | ims_dis_area                                        |

## Check prerequisites

Ensure that the following software is installed:

- [IBM watsonx Assistant for Z](https://www.ibm.com/docs/en/watsonx/waz/2.0.0?topic=install-watsonx-assistant-z)
- IMS 15.5 or later
  - You will need to order IMS 15.6 from Shopz to get the required entitlement key, but you do not need to install 15.6.
  - In the IMS configuration requirements, ensure that `CMDMCS=B, C, R or Y` is set in the DFSPBxxx member that is used to start IMS. Additionally, you can use these sources about [mcs-console](https://www.ibm.com/docs/en/ims/15.6.0?topic=commands-using-multiple-console-support-mcs-consoles) and [cmdmcs](https://www.ibm.com/docs/en/ims/15.6.0?topic=parameters-cmdmcs-parameter-procedures) to set up IMS properly.
- z/OSMF is 3.1 or later

> Optional: Verify image signatures

## Optional: Verify image signatures

You can verify the container image signatures by setting a pull policy for your transport method. You must install Skopeo to use the examples in this guide.

You can verify the signature for the following manifest:

- `icr.io/ibm-ims-ai/ims-agent:1.1.0`

Under the `ims-agent` directory, find the folder named `imagesign`, which contains a file named `public.pub.asc`. Place this file in a location of your choice. Then, copy the Docker container policy `policy.json` file into the`/etc/containers/policy.json` and update the `keyPath` field to reflect the location of your `public.pub.asc`.

```json
{
  "default": [
    {
      "type": "reject"
    }
  ],
  "transports": {
    "docker": {
      "icr.io": [
        {
          "type": "signedBy",
          "keyType": "GPGKeys",
          "keyPath": "/path/to/public.pub.asc"
        }
      ]
    },
    "docker-daemon": {
      "": [
        {
          "type": "reject"
        }
      ]
    }
  }
}
```

1. Log in to Skopeo:

   ```bash
   echo <PASSWORD_OR_TOKEN> | skopeo login --username <USERNAME> --password-stdin icr.io
   ```

2. Use Skopeo to copy the image. Make sure the transport method matches the transport that is used in the policy. This example uses `docker`:

   ```bash
   mkdir temp1
   skopeo copy docker://icr.io/ibm-ims-ai/ims-agent:1.1.0 dir:temp1
   ```

If the image signature is valid and verified by `public.pub.asc`, then the image pull will be successful. Otherwise, it will fail.

1. Import `public.pub.asc` into your local keyring:

   ```bash
   gpg --import /path/to/public_key.asc
   ```

2. Extract the fingerprint:

   ```bash
   export FINGERPRINT=$(gpg --fingerprint --with-colons | grep fpr | tr -d 'fpr:')
   ```

3. Validate the signature:

   ```bash
   skopeo standalone-verify ./temp1/manifest.json icr.io/ibm-ims-ai/ims-agent:1.1.0 $FINGERPRINT ./temp1/signature-1
   ```

If the validation is successful, you should see the following message:

```bash
Signature verified using fingerprint...
```

This is followed by the public key's fingerprint and the digest sha of the image. If a failure occurs, you might see this error:

```bash
FATA[0000] Error verifying signature: ...
```

## Install the IBM IMS Agents

### Retrieve the entitlement key

When you install watsonx Assistant for Z, you should have acquired the entitlement key. However, if you need to retrieve it again, follow these steps:

1. Sign in to [IBM Shopz](https://www.ibm.com/software/shopzseries/ShopzSeries_public.wss).
2. Place an order for IMS 15.6 in IBM Shopz to obtain the entitlement key, which is in the PDF document.
3. Set the following product `entitlementKey` field by using the IBM IMS Agents entitlement key.

```yaml
ims-agent:
  enabled: false # Must be set to true to install.
  acceptLicense: false # Must be set to true to install.
  registry:
    name: ims-image-pull-secret
    server: icr.io
    username: iamapikey
    entitlementKey: ""
```

Ensure that `global.registry.entitlementKey` is set to the watsonx Assistant for Z entitlement key.


## Deploying agents

The IBM Z Support Agent is deployed using a Custom Resource (CR) definition. The CR provides a declarative way to manage the agent deployment through the agent operator.

### Prerequisites

Before deploying the agent, ensure:

1. The agent operator is installed and running in your cluster.
2. The target namespace exists.

Create an instance from CPD UI. It should give a tenant-id and also create a namespace with wxa4z-<tenant-id>

### Step 1: Create secrets

The agent requires Kubernetes Secrets containing sensitive configuration values. **Never commit secrets to version control.**

#### Secret types

The agent uses two types of secrets:

1. **Global Secrets** (`wxa4z-watsonx-credentials`): Shared across all agents
2. **Agent-Specific Secrets** (`wxa4z-ims-agent-secrets`): Unique to this agent


#### Agent-specific secret reference

Create a secret with the following structure. **All values must be base64-encoded.**

```yaml
apiVersion: v1
kind: Secret
metadata:
  name: wxa4z-ims-agent-secrets
  namespace: ""  # REQUIRED: Must match the agent namespace
type: Opaque
data:
  # Agent Authentication (base64-encoded, REQUIRED)
  AGENT_AUTH_TOKEN: ""  # REQUIRED: Agent auth token for registration with WxO
  LANGFUSE_API_KEY: ""  # REQUIRED: Langfuse API key for translation
  LANGFUSE_API_SECRET: ""  # REQUIRED: Langfuse API secret for translation
  
```

> **Important:**
> - **AGENT_AUTH_TOKEN is required** for agent registration with watsonx Orchestrate.

#### Creating the Secret

1. Save the secret configuration to a file (for example, `ims-agent-secret.yaml`).
2. Update the namespace and base64-encode all secret values.
3. Apply the secret:

```bash
oc apply -f ims-agent-secret.yaml
```

4. Verify the Secret was created:

```bash
oc get secret wxa4z-ims-agent-secrets -n <namespace>
```


### Step 2: Install Agents by using Custom Resource (CR)

#### Configuration parameters

The following table outlines the key configuration parameters:

| Parameter | Description | Required |
|-----------|-------------|----------|
| **metadata.namespace** | Target namespace for agent deployment | Yes |
| **spec.tenantId** | Tenant identifier for multi-tenancy support | Yes |
| **spec.chart.version** | Helm chart version to deploy | Yes |
| **spec.values.env.WATSONX_MODEL_ID** | LLM Model ID (for example, "meta-llama/llama-3-3-70b-instruct") | Yes |
| **spec.values.env.MODEL_RUNTIME** | MODEL RUNTIME (for example, "openai_protocol") | Yes |
| **spec.values.secrets.name** | Name of agent-specific secrets | Yes |
| **spec.values.global.secrets.name** | Name of global shared secrets | Yes |
| **spec.values.env.AUTHZ_BASE_URL** | Authentication service route in OCP wxa4z-zad namespace | Yes |
| **spec.values.env.DEPLOYMENT_TYPE** | DEPLOYMENT TYPE (for example, "on-prem/openai_protocol")  | Yes |


#### CR definition

The following code is the complete Custom Resource definition. Update the placeholder values according to your environment:

```yaml
apiVersion: wxa4z.watsonx.ibm.com/v1alpha1
kind: AgentService
metadata:
  name: ims-agent
  namespace: ""  # REQUIRED: Target namespace (for example, wxa4z-agents)
  labels:
    wxa4z.watsonx.ibm.com/managed-by: agent-operator
spec:
  releaseName: ims-agent
  namespace: ""  # REQUIRED: Must match metadata.namespace
  tenantId: ""  # REQUIRED: Tenant identifier for multi-tenancy support
  wxa4z-core-services-namespace: wxa4z-zad  # Namespace where wxa4z core services are deployed
  
  agentDetails:
    - agentName: ims
      agentId: wxa4z:ims:agent
      displayName: "IBM Z IMS Agent"
      description: "IMS AGENT helps to answer all IMS related questions"
      bootstrapConfig:
        name: ims-agent-bootstrap-config
        fileName: ims_agent_bootstrap_config.yaml
  
  chart:
    repository: oci://icr.io/wxa4z-dev-container-registry
    name: ims-agent
    version: "1.1.0"  # Update to the desired chart version
    # Uncomment if using a private registry:
    # pullSecrets:
    #   - name: wxa4z-image-pull-secret

  values:
    replicaCount: 1
    
    global:
      secrets:
        name: wxa4z-watsonx-credentials  # Global secrets shared across agents
    
    secrets:
      name: wxa4z-ims-agent-secrets  # Agent-specific secrets
    
    env:
      # LLM Configuration
      WATSONX_MODEL_ID: "meta-llama/llama-3-3-70b-instruct"
      MODEL_RUNTIME: "openai_protocol"
      AUTHZ_BASE_URL: ""  # REQUIRED: Auth service route
      DEPLOYMENT_TYPE: ""  # REQUIRED: on-prem/openai_protocol/cloud
    registry:
      entitlementKey: ""
```

#### Installing the Agent

1. Save the CR configuration to a file (for example, `ims-agent-cr.yaml`).
2. Update all placeholder values marked as `REQUIRED`.
3. Apply the CR to your cluster:

```bash
oc apply -f ims-agent-cr.yaml
```

4. Verify the deployment:

```bash
# Check CR status
oc get agentservice ims-agent -n <namespace>

# Check the agent pods:
oc get pods -n <namespace> -l app=ims-agent

# View the agent logs:
oc logs -n <namespace> -l app=ims-agent --tail=100
```

### Step 3: Subscribe to the agent

After successfully deploying the agent, you need to subscribe to it to make it available in watsonx Orchestrate.

1. Open the Cloud Pak for Data (CPD) home page, for example: 
   - `https://cpd-<instance>.apps.<cluster-domain>/zen/?context=icp4data#/homepage`

2. Click the **Launch WXA4Z console** tab.
   - This opens the WXA4Z Content Ingestion UI (Tenant Overview page).
   - Example: `https://wxa4z-content-ingestion-ui-route-wxa4z-zad.apps.<cluster-domain>/en`

3. On the Tenant Overview page, click your **Tenant name**.

4. Navigate to the **Subscriptions** tab.
   - You will see a list of deployed agents with a **Subscribe** button next to each.

5. Click the **Subscribe** button next to the **IBM Z IMS Agent**.
   - This action adds the agent to watsonx Orchestrate (WXO) and makes it available for deployment.

### Step 4: Deploy the agent

1. Log in to watsonx Orchestrate.
2. From the main menu, navigate to **Build** > **Agent Builder**.
3. Select the **IBM IMS Agent** tile.
4. In the AI Assistant window, enter a query to confirm that the response aligns with your expectations.
5. Click **Deploy** to activate the agent and make it available in the live environment.

### Step 5: Upgrade the agent

To upgrade the agent to a new version:

> **Note:** If the agent was previously subscribed to watsonx Orchestrate, first unsubscribe to it before upgrading. After the upgrade is complete, re-subscribe the agent. See the [Uninstall the Agent](#step-6-uninstall-the-agent) section for unsubscribe steps and the [Subscribe to the agent](#step-3-subscribe-to-the-agent) section for subscribe steps.

1. Update the `spec.chart.version` field in your CR file:

```yaml
spec:
  chart:
    version: "1.1.0"  # Update to the new version
```

2. Apply the updated CR:

```bash
oc apply -f ims-agent-cr.yaml
```

3. Monitor the upgrade progress:

```bash
# Watch the agent pods rolling update
oc get pods -n <namespace> -l app=ims-agent -w

# Check the CR status:
oc describe agentservice ims-agent -n <namespace>
```

The agent operator will automatically handle the upgrade process, including rolling updates of the agent pods.

### Step 6: Uninstall the Agent

To uninstall the agent:

**If the agent was previously subscribed to watsonx Orchestrate**, first unsubscribe it:

1. Open the Cloud Pak for Data (CPD) home page, for example:
   - `https://cpd-<instance>.apps.<cluster-domain>/zen/?context=icp4data#/homepage`

2. Click the **Launch WXA4Z console** tab.
   - This opens the WXA4Z Content Ingestion UI (Tenant Overview page).
   - Example: `https://wxa4z-content-ingestion-ui-route-wxa4z-zad.apps.<cluster-domain>/en`

3. On the Tenant Overview page, click on your **Tenant name**.

4. Navigate to the **Subscriptions** tab.
   - You will see a list of deployed agents with an **Unsubscribe** button next to each.

5. Click the **Unsubscribe** button next to the **IBM Z IMS Agent**.
   - This action removes the agent from watsonx Orchestrate (WXO).

**Delete the agent resources:**

1. Delete the Custom Resource:

```bash
oc delete agentservice ims-agent -n <namespace>
```

2. Verify the agent resources are removed:

```bash
# Check that the agent pods are terminated
oc get pods -n <namespace> -l app=ims-agent

# Verify the CR is deleted
oc get agentservice -n <namespace>
```

3. Optional: Clean up Secrets if no longer needed:

```bash
# Delete agent-specific secrets
oc delete secret wxa4z-ims-agent-secrets -n <namespace>

# Note: Do not delete global secrets if other agents are using them
```

> **Tip:** The agent operator will automatically clean up all resources created by the agent, including deployments, services, and configmaps. However, secrets must be manually deleted if they are no longer needed.


### Optional: Configure shared variables

Certain variables are common across all agents. To configure these shared variables, see [Create shared variables](https://github.com/IBM/z-ai-agents?tab=readme-ov-file#1-global-settings).
However, if any of these shared variables are also defined in your agent-specific configuration, the values specified in the values.env section of the custom resource file will override the shared ones. Additionally, the wxa4z-watsonx-credentials secret in the `wxa4z-<tenant-id>` namespace can be edited manually to update any value.


### Configure the IMS connections - z/OS machines an agent can pull information from

The IMS Agent provides an API endpoint for creating connections to IMS systems. This allows clients to establish secure connections for executing IMS commands and operations.

#### Endpoint

```
POST <AUTH_URL>/api/v2/tenants/{tenant_id}/agents/{agent_id}/connections
```

**Path Parameters:**
- `tenant_id` - Your tenant identifier (for example, `17700000005109`)
- `agent_id` - The agent identifier (for example, `wxa4z:ims:agent`, URL-encoded as `wxa4z%3Aims%3Aagent`)

**Variables:**
- `<AUTH_URL>` - Your authorization service base URL (for example, `https://wxa4z-authorization-route-namespace.apps.domain.com`)

#### Authentication

Before creating a connection, you must obtain a bearer token from the authentication endpoint:

```
GET <AUTH_URL>/api/v1/agents/{agent_id}/token
```

Include the bearer token in the `Authorization` header of your connection request:

```
Authorization: Bearer <your_token>
```

#### Request body

The request body must be a JSON object with the following structure:

```json
{
  "data": {
    "agent_id": "wxa4z:ims:agent",
    "zos_url": "https://ec0000a.example.ibm.com",
    "application_id": "IZUDFLT",
    "port": 0000,
    "context": "ec0000a",
    "client_cert": "<base64_encoded_certificate>",
    "client_key": "<base64_encoded_key>",
    "tokchg_secret": "<token_exchange_secret>"
  }
}
```

**Field Descriptions:**

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `agent_id` | string | Yes | The unique identifier for the IMS agent |
| `zos_url` | string | Yes | The base URL of your z/OS system |
| `application_id` | string | Yes | z/OSMF application ID (typically `IZUDFLT`) |
| `port` | integer | Yes | The port number for secure communication (typically `5443`) |
| `context` | string | Yes | The context identifier for the z/OS system |
| `client_cert` | string | Yes | Base64-encoded client certificate for mTLS authentication |
| `client_key` | string | Yes | Base64-encoded client private key |
| `tokchg_secret` | string | Yes | Secret for token exchange service authentication |

#### Example request

```bash
# Set your authorization URL:
export AUTH_URL="https://wxa4z-authorization-route-namespace.apps.domain.com"

# Step 1: Obtain bearer token:
curl -X GET \
  "${AUTH_URL}/api/v1/agents/wxa4z%3Aims%3Aagent/token" \
  -H 'Content-Type: application/json'

# Step 2: Create connection:
curl -X POST \
  "${AUTH_URL}/api/v2/tenants/17700000005109/agents/wxa4z%3Aims%3Aagent/connections" \
  -H 'Authorization: Bearer <your_token>' \
  -H 'Content-Type: application/json' \
  -d '{
    "data": {
      "agent_id": "wxa4z:ims:agent",
      "zos_url": "https://ec0000a.example.ibm.com",
      "application_id": "IZUDFLT",
      "port": 0000,
      "context": "ec0000a",
      "client_cert": "...",
      "client_key": ".....",
      "tokchg_secret": "....."
    }
  }'
```

The wxa4z Authentication service also provides an endpoint for configuring agent settings, including z/OS system details and certificates.

#### Endpoint

```
POST <AUTH_URL>/api/v2/tenants/{tenant_id}/agents/{agent_id}/configs
```

**Path parameters:**
- `tenant_id` - Your tenant identifier (for example, `17700000005109`)
- `agent_id` - The agent identifier (for example, `wxa4z:ims:agent`, URL-encoded as `wxa4z%3Aims%3Aagent`)

**Variables:**
- `<AUTH_URL>` - Your authorization service base URL

#### Authentication

This endpoint requires the same bearer token authentication as the connections endpoint. Obtain a token from:

```
GET <AUTH_URL>/api/v1/agents/{agent_id}/token
```

#### Request Body

The request body must be a JSON object with the following structure:

```json
{
  "agent_id": "wxa4z:ims:agent",
  "context": "ec0000a",
  "config": {
    "host": "https://ec0000a.example.ibm.com",
    "console_name": "console name",
    "subsystem_id": "id value",
    "connect_jobname": "job name",
    "cert": "-----BEGIN CERTIFICATE-----\n...\n-----END CERTIFICATE-----"
  }
}
```

**Field descriptions:**

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `agent_id` | string | Yes | The unique identifier for the IMS agent |
| `context` | string | Yes | A context identifier for this configuration should be the **same value** as context in connection|
| `config.host` | string | Yes | The base URL of your z/OS system |
| `config.console_name` | string | Yes | The z/OS console name (for example, `oadm000a`) |
| `config.subsystem_id` | string | Yes | IMS subsystem instance ID (for example, `IMS1`) |
| `config.connect_jobname` | string | Yes | The job name of IMS Connect (for example, `HWS1`) |
| `config.cert` | string | Yes | PEM-formatted certificate for secure communication |

#### Example request

```bash
# Set your authorization URL:
export AUTH_URL="https://wxa4z-authorization-route-namespace.apps.domain.com"

# Step 1: Obtain the bearer token (if it is not already obtained):
curl -X GET \
  "${AUTH_URL}/api/v1/agents/wxa4z%3Aims%3Aagent/token" \
  -H 'Content-Type: application/json'

# Step 2: Configure agent settings:
curl -X POST \
  "${AUTH_URL}/api/v2/tenants/17700000005109/agents/wxa4z%3Aims%3Aagent/configs" \
  -H 'Authorization: Bearer <your_token>' \
  -H 'Content-Type: application/json' \
  -d '{
    "agent_id": "wxa4z:ims:agent",
    "context": "ec0000a",
    "config": {
      "host": "https://ec0000a.vmec.svl.ibm.com",
      "console_name": "val",
      "subsystem_id": "id",
      "connect_jobname": "jobname",
      "cert": "-----BEGIN CERTIFICATE-----\n-----END CERTIFICATE-----"
    }
  }'
```

#### Response

A successful connection creation returns a `201 Created` status code with connection details in the response body.


#### Security guidelines

- Always use HTTPS for API requests
- Store certificates and secrets securely
- Rotate tokens and secrets regularly
- Never commit credentials to version control
- Use environment variables or secure vaults for sensitive data​

## Test your agent

After deployment, the agent becomes active and is available for selection in the live environment.

1. Log in to watsonx Orchestrate.
2. From the main menu, click **Chat**.
3. Choose your agent from the list.
4. Enter queries using the AI Assistant, for example:

   ```text
   What is IMS TM?

   What is the IMS type-1 command to show the status of a transaction named xyz? use ec01182a

   Show me the status of my IMS system.
   ```

5. Verify that the responses returned by the AI Assistant are accurate.




### Additional configuration steps

#### Ensure OpenSearch is deployed to your cluster

The IMS Agent relies on an instance of an OpenSearch vector database for question-answering capabilities. If OpenSearch is not already deployed to your cluster, [follow instructions on how to deploy an instance.](https://www.ibm.com/docs/en/watsonx/waz/3.0.0?topic=cluster-deploying-zassistantdeploy-your)

#### Configure local embeddings

The agent can use local embedding models for specific operations. The image references two available models:

- `ibm-granite/granite-embedding-278m-multilingual`
- `ibm-granite/granite-embedding-107m-multilingual`

You can explicitly select which model to use by adding and setting the `LOCAL_EMBEDDING_MODEL` environment variable to one of the options above. If this variable is not set, the system defaults to `ibm-granite/granite-embedding-278m-multilingual`. Although the default 278 million parameter model might offer enhanced performance, it could result in longer processing times depending on your cluster's allotted resources.

#### Ensure the Authorization service is deployed to your cluster

The agent's MCP tools rely on the Authorization service to communicate with your z/OS system. If the Authorization service is not deployed to your cluster, [follow instructions to deploy it.](https://www.ibm.com/docs/en/watsonx/waz/3.0.0?topic=cluster-deploying-zassistantdeploy-your) Additionally, [follow instructions to enable pass-ticket generation](https://www.ibm.com/docs/en/watsonx/waz/3.0.0?topic=deploying-token-exchange-service-passticket-generation) for a specified APPL ID.

#### Configuring your z/OSMF certificate

The agent's MCP tools rely on z/OSMF to communicate with your z/OS system. Note that z/OSMF console setup is required. A valid certificate is also required for secure, TLS communication.

To set up a z/OS Operator Console, [follow these instructions](https://www.ibm.com/docs/en/zos/latest?topic=consoles-completing-console-setup#zuCNhpOperatorConsolesSettingUp). To allow a specified TSO/E user to issue the CONSOLE commands, [follow these instructions](https://www.ibm.com/docs/en/zos/2.4.0?topic=racf-allowing-tsoe-user-issue-console-command) or run the following command with a given user, for example, `USRT001`:

```jcl
SETROPTS CLASSACT(TSOAUTH)
RDEFINE TSOAUTH CONOPER UACC(NONE)
PERMIT CONOPER CLASS(TSOAUTH) ID(USRT001) ACCESS(ALTER)
SETROPTS RACLIST(TSOAUTH) REFRESH
```

To create a certificate, run the following JCL within a JOB on your system:

```jcl
//SYSTSIN  DD  *
  RACDCERT GENCERT ID(IZUSVR) +
    SUBJECTSDN( CN('your.zos.system.com') +
    O('IBM') OU('IZUDFLT') )+
    ALTNAME( DOMAIN('your.zos.system.com') ) +
    NOTAFTER(DATE(2030-12-31)) +
    WITHLABEL('DefaultzOSMFCert.SAN') +
    KEYUSAGE(HANDSHAKE DATAENCRYPT CERTSIGN)

  RACDCERT ID(IZUSVR) CONNECT( LABEL('DefaultzOSMFCert.SAN') +
                                   RING(IZUKeyring.IZUDFLT) DEFAULT )
/*
```

The CN and SAN domain (your.zos.system.com in this example) must exactly match the hostname used in your `ZOSMF_ENDPOINT` environment variable.

> The previous JCL assumes the APPL ID is `IZUDFLT`. You might need to stop and restart z/OSMF for changes to take effect. For example, run `/P IZUSVR1` and `/S IZUSVR1`and modify as needed.

Save the certificate information to a file by using the following commands:

```bash
export SITE="your.zos.system.com"

openssl s_client -connect ${SITE}:443 -servername ${SITE} -showcerts </dev/null \
 | awk '/-----BEGIN CERTIFICATE-----/,/-----END CERTIFICATE-----/{print $0}' > ${SITE}_full_chain.pem
```

After deployment, an opaque secret named `service-endpoint-cert-secret` (with a placeholder certificate value) is automatically created and mounted to the `ims-agent` container. You must update the value of this secret to reflect the value of the certificate that you just created. Either update the secret in the `mcpCertSecret` section of the `values.yaml` file before running the helm-install command or manually update the secret after deployment.

**Important**: If you update the `values.yaml` file, remember to never store or commit secrets to Git.

To manually update the secret after deployment, you can use a graphical user interface, such as the OpenShift® console, or you can use the OpenShift® CLI patch command after logging in:

```bash
oc patch secret service-endpoint-cert-secret -p '{"data":{"service_endpoint_cert.pem":"'$(cat ${SITE}_full_chain.pem | base64)'"}}'
```

To apply any changes to the secret, remember to restart the pod.

### Security: Internal pod communication

The IBM IMS Agent follows industry-standard HTTPS/HTTP edge termination architecture where external traffic is encrypted via HTTPS, and internal pod-to-pod communication uses HTTP. To mitigate potential security concerns about unencrypted internal traffic, implement one of these options:

**Option 1: Network policy enforcement (implemented)**

The agent deployment includes NetworkPolicies that restrict pod ingress traffic to accept connections only from the OpenShift Ingress Controller namespace. This prevents unauthorized pod-to-pod communication and eliminates the attack surface for packet sniffing or man-in-the-middle attacks within the cluster.

**Option 2: Platform-level IPsec (cluster administrator)**

If your OpenShift cluster uses the OVN-Kubernetes network plugin, cluster administrators can enable platform-wide IPsec encryption. This automatically encrypts all pod-to-pod traffic at the network layer before it traverses physical infrastructure, providing defense-in-depth protection against network sniffers.

To check if IPsec is enabled on your cluster:

```bash
oc get network.config.openshift.io cluster -o jsonpath='{.spec.defaultNetwork.ovnKubernetesConfig.ipsecConfig}'
```

If IPsec is enabled, you will see output indicating the mode (for example, `Full` or `External`). This is a cluster-level configuration managed by platform administrators and requires no application-level changes.

**Option 3: TLS re-encryption (advanced)**

For organizations requiring end-to-end encryption, you can enable TLS re-encryption using OpenShift service-serving certificates. The agent code automatically detects and uses TLS certificates when available.

To enable TLS re-encryption:

1. Add service annotation to auto-generate certificates:
2. Update route termination from `edge` to `reencrypt` in the route configuration.
3. Mount the certificate secret to the pod at `/etc/tls/`:

The agent automatically detects certificates at the expected paths (`/etc/tls/tls.key` and `/etc/tls/tls.crt`) and enables TLS on the server.

For detailed instructions, see [OpenShift documentation on service-serving certificates](https://docs.redhat.com/en/documentation/openshift_container_platform/4.9/html/security_and_compliance/configuring-certificates#add-service-certificate).

### Install or upgrade the ims-agent using the wxa4z-agent-suite

> **Tip**: If you're installing multiple agents, you can configure the [values.yaml](https://github.com/IBM/z-ai-agents/blob/main/wxa4z-agent-suite/values.yaml) file for all the agents that you want to install. After the file is updated, run the following command to install them all at the same time.

Use the following command to install or upgrade the agent using the wxa4z_agent_suite:

```bash
helm upgrade --install wxa4z-agent-suite \
  ./wxa4z-agent-suite \
  -n <wxa4z-namespace> \
  -f <path_to>/values.yaml --wait
```

> You can choose to configure the IBM IMS agents' NetworkPolicies.
> By default, all traffic is allowed for simplicity, which ensures connectivity out of the box. If your organization requires stricter security, you can customize NetworkPolicies in the Helm charts.
> For example, you can restrict ingress to trusted namespaces and limit egress to required services (for example, HTTPS and DNS). [Learn more about configuring ingress/egress rules.](https://docs.redhat.com/en/documentation/openshift_container_platform/4.19/html/network_security/network-policy)


## Troubleshooting installation errors

If you experience errors during installation, see [Troubleshooting](../../README.md#troubleshooting) for troubleshooting steps.

## Uninstalling the agent

For uninstallation instructions, see [Uninstall specific agent](../../README.md#uninstall-specific-agent).

## Troubleshooting

### Common issues

The IMS Agent might experience issues or generate unhelpful responses if:

- Required environment variables are not properly set
- Issues occur with the OpenSearch pod
- The wxa4z-authorization service is misconfigured on the cluster that is hosting the agent or on the z/OS system

The agent relies on the OpenSearch pod for retrieval-augmented generation (RAG). If the agent cannot communicate with the OpenSearch instance deployed to the target cluster, it might hallucinate (generate non-factual text), resulting in low-quality or unhelpful responses for question-answering queries.

#### Resolving issues

1. Ensure all required environment variables are correctly set.

      **Recommendation:** It is recommended that you use a hostname instead of an IP address in the `ZOSMF_ENDPOINT` and `SERVICE_ENDPOINT` environment variables because using an IP address might cause issues.

2. Validate `wxa4z-authorization` and Token Exchanger service 
   - **Authorization Pod**

     Check whether the wxa4z-authorization pod is deployed and is running on the target cluster.

   - **Token Exchanger Service**

     **Tip:** You can check that the token-exchanger service is running by using SSH to access your z/OS system. For example, enter `ssh username@your.zos.system.com` and then run this command to see whether the process is running:
     `ps -ef | grep java`  

      If you see `java -jar token-exchange-mtls.jar` in the results list, the token-exchanger service is running. If it is not running, [deploy and start the service](https://github.ibm.com/wxa4z/tokenexchange/releases/tag/v0.1.0).
     
     You can also check the logs from the token-exchanger service by using this command:
     `scp username@your.zos.system.com:path/to/passticket-mtls/nohup.out ~/Download/log.txt`
     This command will download the logs to your local workstation and place them here: `~/Download/log.txt`

3. Check the z/OSMF and Operator Console
   - Ensure that z/OSMF is running and an Operator Console is set up and active.
   - Ensure that the z/OSMF Certificate was created and the corresponding secret (`service-endpoint-cert-secret`) was updated in OpenShift.

   **Tip:** Consoles often shut down due to inactivity. If the MCP Agent attempts to communicate with an inactive console, errors will occur. Periodically verify that the console is active.

4. Restart the pod to implement the changes.

---