# IBM Concert for Z Agent

## Overview

The IBM® Concert for Z Agent enables you to use natural language to query the IBM Z® data that is collected by IBM Concert® for Z.

The agent uses the conventions that are required by the agent-controller for proper registration and integration with IBM watsonx Orchestrate.

| Field         | Value                                                                |
|---------------|----------------------------------------------------------------------|
| Agent Names    | `ibm-concert-agent-z`                                          |
| Image         | `icr.io/ibm-operations-aai/ibm-concert-z-agent:<tag>`    |
| Endpoint Path | `/v1/wlm_unite_chat`                                                 |
| Auth Type     | `API_KEY`                                                            |
| Architecture  | Dual deployment: MCP Client (port 9001) + MCP Server (port 9002) using the same container image |
| Description   | Answers questions about CICS® regions, CICSPlexes, sysplexes, LPARs, and workloads in z/OS environments. Searches for relevant AIOps information across Db2, LPAR, IMS, Network, JVM, MQ, Storage, CICSplex, and OMEGAMON. Tracks CPU utilization, I/O activity, transaction volumes, response times, and storage availability, and detects high-consuming transactions or short-on-storage conditions. Monitors limits such as maximum tasks (MAXTASKS) and concurrent transactions to provide visibility into active CICSPlexes, their regions, and transaction classes. For sysplexes and LPARs, delivers information about CPU health, utilization, and system topology, and validates resource existence. Provides z/OS Workload Management (WLM) insights, including transaction rates, response times, performance indexes, and goal achievements, and highlights service classes that are not meeting objectives. Reports critical events and critical event groups. Includes relevant Concert UI dashboard URLs in responses for seamless navigation. Automatically uses the Concert UI time range context when no explicit time range is specified in questions. |

## Agent capabilities

|  Capability         |            Description                  |
|------------------------------|-----------------------------------|
| Provide general insight        | Provides information about CICS regions, CICSPlexes, sysplexes, LPARs, and workloads in z/OS environments.  |
| Track z/OS Metrics | Can track CPU utilization, I/O activity, transaction volumes, response times, and storage availability, and can detect high-consuming transactions or short-on-storage conditions.|
| OMEGAMON MCP integration | Provides information about Db2, IMS, and JVM, pulled from OMEGAMON via MCP|
| Monitor data |  Can monitor limits, such as maximum tasks (MAXTASKS) and concurrent transactions, to give visibility into active CICSPlexes, their regions, and transaction classes.|
| Provide health and system information | For sysplexes and LPARs, provides information about CPU health, utilization, and system topology, and can validate resource existence.|
| Workload Management insights | Provides z/OS Workload Management (WLM) insights, including transaction rates, response times, performance indexes, and goal achievements, and can highlight service classes that are not meeting objectives. |
| Critical event search | Can report information about critical events and critical event groups.|
| System automation | Allows user to list domains, systems, and resources across Automation and Netview, and retrieve detailed information about each. Also supports fetching members, relations, and requests for automation resources, along with a server health check to ensure everything is functioning correctly. |
| Workload scheduler | Provides complete visibility into workload scheduling by querying engines, workstations, job streams, jobs, and critical jobs across the system. Enables detailed retrieval of configuration and job‑level data while also offering a health check to ensure the server and all tool functions are operational. |
| Concert UI integration | Automatically includes relevant Concert UI dashboard URLs in responses for seamless navigation to related dashboards. Uses the Concert UI time range context when no explicit time range is specified in questions, with support for all time presets (Last 15m, 1h, 24h, 7d, 30d) and custom ranges. |

---

## Prerequisites
The following software must be installed and configured:

- [IBM watsonx Assistant for Z](https://www.ibm.com/docs/en/watsonx/waz/2.0.0?topic=install-watsonx-assistant-z)
- IBM Concert for Z (https://www.ibm.com/docs/z-concert)

## Image Signature Verification Guide

This container image of the **IBM Concert for Z Agent** is digitally signed to guarantee authenticity and integrity.
Use the following instructions to verify the image signature with the provided files.

---

### Image reference

```bash
icr.io/ibm-operations-aai/ibm-concert-z-agent:v1.2.0
```
### Files provided

#### IBM Concert for Z Agent
- **PRD0014680key.pem.cer** – Certificate
- **PRD0014680key.pem.chain** – CA chain
- **PRD0014680key.pem.pub.key** – Public key

---

### Prerequisites

Before you begin signature verification, ensure that the following command-line tools are installed:

- **cosign**: For verifying the container signature
- **jq**: A lightweight JSON processor
- **crane**: For inspecting image manifests
- **OpenSSL**: For cryptographic checks on the certificate and public key

---

### Quick Verification

To immediately verify the image signature, run the following command:

```bash
cosign verify --key PRD0014680key.pem.pub.key \
  icr.io/ibm-operations-aai/ibm-concert-z-agent:v1.2.0 | jq .
```

If the signature is valid, details about the signer and the certificate are shown in the output.

## Optional: Detailed Verification Steps

### 1. Check Signature Manifest

Identify the signature manifest reference:

```bash
cosign triangulate icr.io/ibm-operations-aai/ibm-concert-z-agent:v1.2.0
```
Example output:

```bash
icr.io/ibm-concert-aai/ibm-concert-agent-z:sha256-<digest>.sig
```
Inspect the signature details:

```bash
crane manifest icr.io/ibm-operations-aai/ibm-concert-z-agent:sha256-<digest>.sig | jq .
```
This displays the certificate chain and metadata that is embedded in the signature object.

### 2. Ensure that the public key and the certificate match.

Compare the public key and certificate by inspecting their modulus and exponent:

```bash
openssl x509 -in PRD0014680key.pem.cer -noout -text
openssl rsa -noout -text -inform PEM -in PRD0014680key.pem.pub.key -pubin
```
Look for the modulus and exponent values, which must match across both outputs.
A match of these values confirms that the public key corresponds to the signing certificate.

### 3. Verify that the provided certificate is valid.

Use the Online Certificate Status Protocol (OCSP) to verify the certificate.
This sends a request to the Certificate Authority (DigiCert) to confirm the certificate status.

```bash
openssl ocsp -no_nonce \
  -issuer PRD0014680key.pem.chain \
  -cert PRD0014680key.pem.cer \
  -VAfile PRD0014680key.pem.chain \
  -url http://ocsp.digicert.com \
  -respout ocsptest -text
```
If the certificate is valid, the output will include:

```bash
Response verify OK
```

## WXA4Z Assistant Configuration Details

| **Parameter**                     | **Details** |
|----------------------------------|-------------|
| **ASSISTANT_ENV_ID**             | **Path:** Open watsonx Orchestrate → Navigate to Assistant Builder → Choose Assistant for zOS → Navigate to Settings → Assistant ID & API Details → View Details → copy Environment ID. <br> **Use:** If Published, use Live; otherwise use Draft. <br> **Example:** `c2f3d4e5-aaaa-bbbb-cccc-111122223333` |
| **ASSISTANT_SVC_INSTANCE_URL**   | **Path:** watsonx Orchestrate → AI Assistant Builder → Assistant for zOS → Settings → Assistant ID & API Details → View Details → copy Service Instance URL. <br> **Use:** <br> - **CPD/on-prem:** append `/api` → `<serviceInstanceUrl>/api` <br> - **IBM Cloud:** use as-is. <br> **Example:** <br> - CPD On-prem → `https://cpd-cpd-instance-42.apps.example.cp.fyre.ibm.com/assistant/cpd-instance-42-wo-wa/instances/1234567890123456/api` <br> - Cloud → `https://api.us-east.assistant.watsonx.cloud.ibm.com/instances/aaaaaaaa-bbbb-cccc-dddd-eeeeeeeeeee` |
| **CPD_AUTH_URL** *(On-prem only)*| **Construct:** `https://<CPD_BASE_HOST>/icp4d-api/v1/authorize` (from your CPD console base host). <br> **Note:** Do not append `/api` here. <br> **Example:** `https://cpd-cpd-instance-42.apps.example.cp.fyre.ibm.com/icp4d-api/v1/authorize` |
| **CPD_ADMIN_PASSWORD** *(On-prem only)* | Password for the CPD admin user. |
| **ASSISTANT_API_KEY** *(IBM Cloud only)* | IBM Cloud API key (or service credential) for your Assistant instance. <br> **Use:** Required on Cloud; not used on on-prem (CPD uses `CPD_AUTH_URL` with CPD credentials/tokens). |

## Install IBM Concert for Z Agent

### Retrieve the entitlement key

The entitlement key is shipped as part of IBM Concert for Z
> **Note**: In the Shopz memo, this key is referred to as an API key.
Enter the value of this key in the `ibm-concert-agent-z` section of the `values.yaml` file in the `wxa4z-agent-suite` folder.
(See [values.yaml](../../wxa4z-agent-suite/values.yaml)).

```yaml:
ibm-concert-agent-z:
  ...
    registry:
        name: ibm-concert-image-pull-secret
        server: icr.io
        username: iamapikey
        entitlementKey: entitlementKey
```

### Create Shared Variables

Certain variables are common across all agents. To configure these shared variables, refer to [Create shared variables](https://github.com/IBM/z-ai-agents?tab=readme-ov-file#1-global-settings).
However, if any of these shared variables are also defined in your agent-specific [values.yaml](https://github.ibm.com/wxa4z/agent-deployment-charts/blob/main/wxa4z-agent-suite/values.yaml) file, the values specified in the values.yaml file will override the shared ones.

### Configure the values.yaml file

To enable the IBM Concert for Z Agent, you need to configure agent-specific values in the [values.yaml](https://github.ibm.com/wxa4z/agent-deployment-charts/blob/main/wxa4z-agent-suite/values.yaml) file.

In the values.yaml file, scroll down to the IBM Concert for Z Agent section and update the keys as outlined in the following table.

> **Note**: This helm chart deploys **two separate containers** using the same image:
> - **MCP Client** (`SERVICE_MODE=client`) - Handles agent operations and external communication on port 9001
> - **MCP Server** (`SERVICE_MODE=server`) - Handles MCP protocol operations on port 9002
>
> Both containers share the same configuration from `values.yaml`. The deployment templates automatically set the appropriate `SERVICE_MODE` environment variable for each container.

**SET VALUES FOR BELOW KEYS IN `env` SECTION of `values.yaml` as required**

#### Secrets (configured in mcpSecrets section)
| Key                          | Description                                                                 |
|------------------------------|-----------------------------------------------------------------------------|
| `WATSONX_ML_URL`             | Watsonx ML service URL                                                      |
| `WATSONX_DEPLOYMENT_SPACE_ID`| Watsonx deployment space ID                                                 |
| `WATSONX_PROJECT_ID`         | Watsonx project ID                                                          |
| `EXTERNAL_WATSONX_API_KEY`   | Watsonx API key                                                             |
| `CPD_USERNAME`               | CPD username (for on-prem deployments)                                      |
| `AGENT_AUTH_TOKEN`           | Token used by the agent-controller to register this agent with wxo (API_KEY or Bearer)  |
| `UNITE_CLIENT_ID`            | Client ID for Unite API access                                              |
| `UNITE_CLIENT_SECRET`        | Client secret for Unite API access                                          |
| `UNITE_GRANT_TYPE`           | OAuth2 grant type (e.g. `client_credentials`)                               |
| `UNITE_API_URL`              | Unite API base URL                                                          |
| `UNITE_TOKEN_URL`            | URL to retrieve the Unite token                                             |
| `LANGFUSE_SECRET_KEY`        | Secret key for Langfuse tracing                                             |
| `LANGFUSE_PUBLIC_KEY`        | Public key for Langfuse tracing                                             |
| `WRAPPER_URL`                | Wrapper URL for OpenSearch queries                                          |
| `WRAPPER_USERNAME`           | Wrapper username                                                            |
| `WRAPPER_PASSWORD`           | Wrapper password                                                            |
| `EMBEDDING_MODEL_PATH`       | Path to embedding model                                                     |
| `TOOL_EMBEDDING_PATH`        | Path to tool embeddings                                                     |
| `CONCERT_MCP_SERVER_URL`     | MCP server URL endpoint (internal service URL)                              |
| `CONCERT_MCP_SERVER_HOST`    | MCP server host (default: `0.0.0.0`)                                        |
| `CONCERT_MCP_SERVER_PATH`    | MCP server path (default: `/mcp`)                                           |
| `CONCERT_MCP_SERVER_PORT`    | MCP server port (default: `9002`)                                           |
| `OMEGAMON_MCP_URL`           | OMEGAMON MCP URL (optional)                                                 |
| `WORKLOAD_MCP_URL`           | Workload MCP URL (optional)                                                 |
| `AUTOMATION_MCP_URL`         | Automation MCP URL (optional)                                               |
| `UNITE_LEGACY_API_URL`       | Unite Legacy API URL (optional)                                             |
| `UNITE_AGENTIC_API_URL`      | Unite Agentic API URL (optional)                                            |
| `CONCERT_UI_BASE_URL`        | Base URL for Concert UI (used for generating dashboard links in responses)  |

#### Other keys
| Key                       | Description                                                            |
|---------------------------|------------------------------------------------------------------------|
| `CPD_VERSION`             | CPD version (e.g. `"5.2"`)                                             |
| `DEPLOYMENT_TYPE`         | Either `"cloud"` or `"on-prem"` depending on deployment                |
| `LOG_LEVEL`               | Log level (e.g. `INFO`)                                                |
| `VERIFY_SSL`              | Whether to verify SSL certificates (`true`/`false`)                    |
| `ONPREM_WML_INSTANCE_ID`  | On-prem WML instance ID (default: `"openshift"`)                       |
| `UNITE_METRIC_INDEX`      | Index name for Unite metrics (default: `"unite-metrics"`)              |
| `UNITE_EVENT_INDEX`       | Index name for Unite events (default: `"unite-events"`)                |
| `LLM_MODEL`               | LLM model to use (e.g. `meta-llama/llama-3-3-70b-instruct`)            |
| `LANGFUSE_HOST`           | Langfuse host URL (if tracing enabled)                                 |
| `LANGFUSE_TRACING_ENABLED`| Enable or disable Langfuse tracing (`true`/`false`)                    |
| `SUMMARY_DIR`             | Directory path for summaries (default: `"/data"`)                      |
| `GRAPH_RECURSION_LIMIT`   | Defines the maximum depth of recursive or looping calls a graph can make before execution is halted to prevent infinite cycles. If unset, the agent defaults to 30. Users can override this in values.yaml.|
| `CONTEXT_LENGTH`          | Context length for LLM (default: `"16000"`)                            |
| `DEBUG_TOOLSELECTION`     | Enable debug mode for tool selection (default: `"false"`)              |
| `QUERY_PATH`              | Path to OpenSearch query templates                                     |

> You must always set a valid `DEPLOYMENT_TYPE` option of either "cloud" or "on-prem".

## Custom Resource (CR) Configuration

The IBM Concert for Z Agent can be deployed using a Custom Resource (CR) definition. The CR provides a declarative way to manage the agent deployment through the agent operator.

### Prerequisites for CR Deployment

Before deploying the agent using the CR, ensure:

- The agent operator is installed and running in your cluster
- You have created the required secrets (see Secret Configuration)
- The target namespace exists

### CR Structure Overview

The Custom Resource consists of the following main sections:

- **metadata**: Identifies the agent and its namespace
- **spec.agentDetails**: Defines agent-specific configuration and bootstrap settings
- **spec.chart**: Specifies the Helm chart location and version
- **spec.values**: Contains deployment values including environment variables and secret references

### CR Reference

Below is the complete Custom Resource definition for the IBM Concert for Z Agent. Update the placeholder values according to your environment:

```yaml
apiVersion: wxa4z.watsonx.ibm.com/v1alpha1
kind: AgentService
metadata:
  name: ibm-concert-agent-z
  namespace: ""  # REQUIRED: Target namespace (e.g., wxa4z-agents)
  labels:
    wxa4z.watsonx.ibm.com/managed-by: agent-operator

spec:
  releaseName: ibm-concert-agent-z
  namespace: ""  # REQUIRED: Must match metadata.namespace
  tenantId: ""  # REQUIRED: Tenant identifier for multi-tenancy support
  wxa4z-core-services-namespace: wxa4z-zad  # Namespace where wxa4z core services are deployed

  agentDetails:
    - agentName: ibm-concert-agent-z
      agentId: wxa4z:ibm-concert-agent-z:agent
      description: 'Provides list of critical events from the system. Provides analyze the WLM goals information. Provides WLM utilization of the event and give a summary. Can answer, questions related to retrieving critical events from systems and analyzing WLM utilization.'
      agentDisplayName: "IBM Concert for Z Agent"
      bootstrapConfig:
        name: "ibm-concert-agent-z-bootstrap-config"
        fileName: "ibm_concert_agent_bootstrap_config.yaml"

  chart:
    repository: oci://icr.io/wxa4z-dev-container-registry
    name: ibm-concert-agent-z
    version: "1.1.2"  # Update to the desired chart version
    # Uncomment if using a private registry:
    # pullSecrets:
    #   - name: wxa4z-image-pull-secret

  values:
    replicaCount: 1

    global:
      secrets:
        name: wxa4z-watsonx-credentials  # Global secrets shared across agents

    secrets:
      name: ibm-concert-agent-z-mcp-secrets  # Agent-specific secrets

    env:
      # LLM Configuration
      LLM_MODEL: "meta-llama/llama-3-3-70b-instruct"
      # Add other ENV variables as needed for deployment
```

### Applying the CR

1. Save the CR configuration to a file (e.g., `ibm-concert-agent-z-cr.yaml`)
2. Update all placeholder values marked as REQUIRED
3. Apply the CR to your cluster:

```bash
oc apply -f ibm-concert-agent-z-cr.yaml
```

4. Verify the deployment:

```bash
# Check CR status
oc get agentservice ibm-concert-agent-z -n <namespace>

# Check agent pods
oc get pods -n <namespace> -l app=ibm-concert-agent-z

# View agent logs
oc logs -n <namespace> -l app=ibm-concert-agent-z --tail=100
```

## Secret Configuration

The agent requires Kubernetes Secrets containing sensitive configuration values. Never commit secrets to version control.

### Secret Types

The agent uses two types of secrets:

1. **Global Secrets** (`wxa4z-watsonx-credentials`): Shared across all agents
2. **Agent-Specific Secrets** (`ibm-concert-agent-z-mcp-secrets`): Unique to this agent

### Agent-Specific Secret Reference

Create a secret with the following structure. All values must be base64-encoded.

```yaml
apiVersion: v1
kind: Secret
metadata:
  name: ibm-concert-agent-z-mcp-secrets
  namespace: ""  # REQUIRED: Must match the agent namespace
type: Opaque
data:
  # Agent Authentication (base64-encoded, REQUIRED)
  AGENT_AUTH_TOKEN: ""  # REQUIRED: Agent auth token for registration with WxO. A default value "WXA4Z_SAMPLE_API_KEY" is set if not provided, but you should configure a proper token.

  # Unite API Configuration (base64-encoded, REQUIRED)
  UNITE_CLIENT_ID: ""  # REQUIRED: Client ID for Unite API access
  UNITE_CLIENT_SECRET: ""  # REQUIRED: Client secret for Unite API access
  UNITE_GRANT_TYPE: ""  # REQUIRED: OAuth2 grant type (e.g., "client_credentials")
  UNITE_API_URL: ""  # REQUIRED: Unite API base URL
  UNITE_TOKEN_URL: ""  # REQUIRED: URL to retrieve the Unite token

  # Wrapper Configuration (base64-encoded, REQUIRED)
  WRAPPER_URL: ""  # REQUIRED: Wrapper URL for OpenSearch queries
  WRAPPER_USERNAME: ""  # REQUIRED: Wrapper username
  WRAPPER_PASSWORD: ""  # REQUIRED: Wrapper password

  # MCP Server Configuration (base64-encoded, REQUIRED)
  CONCERT_MCP_SERVER_URL: ""  # REQUIRED: MCP server URL endpoint (internal service URL)
  CONCERT_MCP_SERVER_HOST: ""  # REQUIRED: MCP server host (default: "0.0.0.0")
  CONCERT_MCP_SERVER_PATH: ""  # REQUIRED: MCP server path (default: "/mcp")
  CONCERT_MCP_SERVER_PORT: ""  # REQUIRED: MCP server port (default: "9002")

  # LLM Model (base64-encoded, REQUIRED)
  LLM_MODEL: ""  # REQUIRED: LLM model to use (e.g., "meta-llama/llama-3-3-70b-instruct")

  # Embedding Model Configuration (base64-encoded, optional)
  EMBEDDING_MODEL_PATH: ""  # Optional: Path to embedding model
  TOOL_EMBEDDING_PATH: ""  # Optional: Path to tool embeddings

  # Additional MCP URLs (base64-encoded, optional)
  OMEGAMON_MCP_URL: ""  # Optional: OMEGAMON MCP URL
  WORKLOAD_MCP_URL: ""  # Optional: Workload MCP URL
  AUTOMATION_MCP_URL: ""  # Optional: Automation MCP URL
  UNITE_LEGACY_API_URL: ""  # Unite Legacy API URL
  UNITE_AGENTIC_API_URL: ""  # Unite Agentic API URL
  CONCERT_UI_BASE_URL: ""  # Optional: Base URL for Concert UI (used for generating dashboard links)

  # Watsonx Configuration (base64-encoded, optional - required only when dev_mode is enabled)
  WATSONX_ML_URL: ""  # Optional: Watsonx ML service URL (required if dev_mode=true)
  WATSONX_DEPLOYMENT_SPACE_ID: ""  # Optional: Watsonx deployment space ID (required if dev_mode=true)
  WATSONX_PROJECT_ID: ""  # Optional: Watsonx project ID (required if dev_mode=true)
  EXTERNAL_WATSONX_API_KEY: ""  # Optional: Watsonx API key (required if dev_mode=true)
  CPD_USERNAME: ""  # Optional: CPD username (required if dev_mode=true for on-prem deployments)

  # Langfuse Tracing (base64-encoded, optional - required only if LANGFUSE_TRACING_ENABLED=true)
  LANGFUSE_PUBLIC_KEY: ""  # Optional: Public key for Langfuse tracing (required if tracing enabled)
  LANGFUSE_SECRET_KEY: ""  # Optional: Secret key for Langfuse tracing (required if tracing enabled)
```

**Important:**
- `AGENT_AUTH_TOKEN` is required for agent registration with watsonx Orchestrate.
- Unite API credentials (`UNITE_CLIENT_ID`, `UNITE_CLIENT_SECRET`, `UNITE_GRANT_TYPE`, `UNITE_API_URL`, `UNITE_TOKEN_URL`) are required for accessing Concert data.
- Wrapper credentials (`WRAPPER_URL`, `WRAPPER_USERNAME`, `WRAPPER_PASSWORD`) are required for OpenSearch queries.
- MCP Server configuration (`CONCERT_MCP_SERVER_URL`, `CONCERT_MCP_SERVER_HOST`, `CONCERT_MCP_SERVER_PATH`, `CONCERT_MCP_SERVER_PORT`) is required for the dual-deployment architecture.
- `LLM_MODEL` is required to specify which language model to use.

### Creating the Secret

Apply the secret:

```bash
oc apply -f secret.yaml
```

### Step 1: Create ICR Pull Secret (First-Time Setup)

Run the following command to create an image pull secret for IBM Cloud Container Registry (ICR):

```bash
oc create secret -n <your-namespace> docker-registry ibm-concert-image-mcp-pull-secret \
  --docker-server=icr.io \  #replace this with container registry
  --docker-username=iamapikey \ # replace this with container registry username
  --docker-password=<your-api-key> # replace this with container registry password
```

> Replace `<your-namespace>` and `<your-api-key>` with your specific namespace and API key.

Alternatively, configure the secret creation in `values.yaml`:

```yaml
registry:
  name: ibm-concert-image-pull-secret
  createSecret: true
  server: icr.io
  username: iamapikey
  entitlementKey: <your-api-key>
```

---

### Step 2: Update pull secret in `values.yaml`

In your Helm chart's `values.yaml`, update the image pull secret:

```yaml
imagePullSecrets:
  - name: ibm-concert-image-mcp-pull-secret
```

---

### Step 3: Install Helm Chart

Finally, install the Helm chart:

```bash
helm upgrade --install ibm-concert-agent-z . \
  -n <your-namespace> \
  -f values.yaml
```
> **Note**: If you want to install the agent standalone on an OpenShift cluster without wxa4z-operator, agent registration should be done through UI refer the official guidance [Adding AI assistants from external AI agents](https://www.ibm.com/docs/en/watsonx/watson-orchestrate/current?topic=agent-adding-ai-assistants-ai-chat#external-agents)
---

## Install or upgrade the wxa4z-agent-suite

> **Note**: If you're installing multiple agents, you can configure the [values.yaml](https://github.ibm.com/wxa4z/agent-deployment-charts/blob/main/wxa4z-agent-suite/values.yaml) file for all the agents you wish to install. Once the file is updated, run the command below to install them all at once.


Use the following command to install or upgrade the wxa4z_agent_suite:

```yaml
helm upgrade --install wxa4z-agent-suite \
  ./wxa4z-agent-suite \
  -n <wxa4z-namespace> \
  -f <path_to>/values.yaml --wait
```

## Enabling the Agent and Accepting the License

The WXA4Z-suite install will only install the IBM Concert for Z Agent if it is enabled and the license is accepted. To enable IBM Concert for Z Agent change the values of the following keys:

The enabled key should be set to true.
The acceptLicense key should be set to true. Setting this to true implies that you agree to the license terms.
These values are available in the shared [values.yaml](../../wxa4z-agent-suite/values.yaml).


```bash
ibm-concert-agent-z:
  enabled: true
  acceptLicense: true
```

## Deploy the agent

1. Log in to watsonx Orchestrate.
2. From the main menu, navigate to **Build** > **Agent Builder**.
3. Select the **IBM Concert for Z Agent** tile.
4. In the AI Assistant window, enter a query to confirm that the response aligns with your expectations.
5. Click **Deploy** to activate the agent and make it available in the live environment.

## Test your agent

After deployment, the agent becomes active and is available for selection in the live environment.

1. Log in to watsonx Orchestrate.
2. From the main menu, click **Chat**.
2. Choose **IBM Concert for Z Agent** from the list.
3. Enter your queries using the AI Assistant.
Responses are displayed either in a tabular format or as a sentence, depending on the context.
4. Verify that the responses returned by the AI Assistant are accurate.