# IBM Concert for Z Agent- Spyre

## Overview

The IBM® Concert Agent for Z - Spyre enables you to use natural language to query the IBM Z® data that is collected by IBM Concert® for Z.

The agent uses the conventions that are required by the agent-controller for proper registration and integration with IBM watsonx Orchestrate.

| Field         | Value                                                                |
|---------------|----------------------------------------------------------------------|
| Agent Name    |  `ibm-concert-agent-z-spyre`                                             |
| Images        | `icr.io/ibm-operations-aai/ibm-concert-z-agent-spyre:<tag>`    |
| Endpoint Path | `/v1/wlm_unite_chat`                                                 |
| Auth Type     | `API_KEY`                                                            |
| Description   | Answers questions about CICS® regions, CICSPlexes, sysplexes, LPARs, and workloads in z/OS environments. Tracks CPU utilization, I/O activity, transaction volumes, response times, and storage availability, and detects high-consuming transactions or short-on-storage conditions. Monitors limits, such as maximum tasks (MAXTASKS) and concurrent transactions, to give visibility into active CICSPlexes, their regions, and transaction classes. For sysplexes and LPARs, the agent provides information about CPU health, utilization, and system topology, and validates resource existence. Delivers z/OS Workload Management (WLM) insights, including transaction rates, response times, performance indexes, and goal achievements, and highlights service classes that are not meeting objectives. Reports critical events and critical event groups. IBM Concert for Z Agent - Spyre supports Granite models on Spyre. |

## Agent capabilities

|  Capability         |            Description                  |
|------------------------------|-----------------------------------|
| Provide general insight        | Provides information about CICS regions, CICSPlexes, sysplexes, LPARs, and workloads in z/OS environments.  |
| Track z/OS Metrics | Can track CPU utilization, I/O activity, transaction volumes, response times, and storage availability, and can detect high-consuming transactions or short-on-storage conditions.|
| Monitor data |  Can monitor limits, such as maximum tasks (MAXTASKS) and concurrent transactions, to give visibility into active CICSPlexes, their regions, and transaction classes.|
| Provide health and system information | For sysplexes and LPARs, provides information about CPU health, utilization, and system topology, and can validate resource existence.|
| Workload Management insights | Provides z/OS Workload Management (WLM) insights, including transaction rates, response times, performance indexes, and goal achievements, and can highlight service classes that are not meeting objectives. |
| Critical event search | Can report information about critical events and critical event groups.|

---

## Prerequisites
The following software must be installed and configured:

- [IBM watsonx Assistant for Z](https://www.ibm.com/docs/en/watsonx/waz/2.0.0?topic=install-watsonx-assistant-z)
- IBM Concert for Z (https://www.ibm.com/docs/z-concert)

## Image Signature Verification Guide

This container image of the **IBM Concert for Z Agent - Spyre** is digitally signed to guarantee authenticity and integrity.
Use the following instructions to verify the image signature with the provided files.

---

### Image reference

```bash
icr.io/ibm-operations-aai/ibm-concert-z-agent-spyre:v1.2.0
```
### Files provided

#### IBM Concert for Z Agent - Spyre
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
  icr.io/ibm-operations-aai/ibm-concert-z-agent-spyre:v1.2.0* | jq .
```

If the signature is valid, details about the signer and the certificate are shown in the output.

## Optional: Detailed Verification Steps

### 1. Check Signature Manifest

Identify the signature manifest reference:

```bash
cosign triangulate icr.io/ibm-operations-aai/ibm-concert-z-agent-spyre:v1.2.0
```
Example output:

```bash
icr.io/ibm-operations-aai/ibm-concert-z-agent-spyre:sha256-<digest>.sig
```
Inspect the signature details:

```bash
crane manifest icr.io/ibm-operations-aai/ibm-concert-z-agent-spyre:sha256-<digest>.sig | jq .
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

## Install IBM Concert for Z Agent - Spyre

### Retrieve the entitlement key

The entitlement key is shipped as part of IBM Concert for Z
> **Note**: In the Shopz memo, this key is referred to as an API key.
Enter the value of this key in the `ibm-concert-agent-z` section of the `values.yaml` file in the `wxa4z-agent-suite` folder.
(See [values.yaml](../../wxa4z-agent-suite/values.yaml)).

```yaml:
ibm-concert-agent-z-spyre:
  ...
    registry:
        name: ibm-concert-agent-image-pull-secret-spyre
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

**SET VALUES FOR BELOW KEYS IN `env` SECTION of `values.yaml` as required**

#### Secrets
| Key                          | Description                                                                 |
|------------------------------|-----------------------------------------------------------------------------|
| `AGENT_AUTH_TOKEN`           | Token used by the agent-controller to register this agent with wxo (API_KEY or Bearer)  |
| `UNITE_CLIENT_ID`            | Client ID for Unite API access                                              |
| `UNITE_CLIENT_SECRET`        | Client secret for Unite API access                                          |
| `UNITE_GRANT_TYPE`           | OAuth2 grant type (e.g. `client_credentials`)                               |
| `UNITE_API_URL`              | Unite API base URL                                                          |
| `UNITE_TOKEN_URL`            | URL to retrieve the Unite token                                             |
| `LANGFUSE_SECRET_KEY`        | Secret key for Langfuse tracing                                             |
| `LANGFUSE_PUBLIC_KEY`        | Public key for Langfuse tracing                                             |
| `ASSISTANT_VERSION`          | Assistant API version                                                       |
| `ASSISTANT_ENV_ID`           | Assistant environment ID                                                    |
| `ASSISTANT_API_KEY`          | Assistant API key                                                           |
| `ASSISTANT_SVC_INSTANCE_URL` | Assistant service instance URL                                              |
---

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

> You must always set a valid `DEPLOYMENT_TYPE` option of either "cloud" or "on-prem".

### Custom Resource (CR) Configuration

The IBM Concert for Z Agent - Spyre can be deployed using a Custom Resource (CR) definition. The CR provides a declarative way to manage the agent deployment through the agent operator.

#### Prerequisites for CR Deployment

Before deploying the agent using the CR, ensure:

1. The agent operator is installed and running in your cluster
2. You have created the required secrets (see [Secret Configuration](#secret-configuration))
3. The target namespace exists
4. IBM Concert for Z is installed and accessible

#### CR Structure Overview

The Custom Resource consists of the following main sections:

- **metadata**: Identifies the agent and its namespace
- **spec.agentDetails**: Defines agent-specific configuration and bootstrap settings
- **spec.chart**: Specifies the Helm chart location and version
- **spec.values**: Contains deployment values including environment variables and secret references

#### CR Reference

Below is the complete Custom Resource definition for the IBM Concert for Z Agent - Spyre. Update the placeholder values according to your environment:

```yaml
apiVersion: wxa4z.watsonx.ibm.com/v1alpha1
kind: AgentService
metadata:
  name: ibm-concert-agent-z-spyre
  namespace: ""  # REQUIRED: Target namespace (e.g., wxa4z-agents)
  labels:
    wxa4z.watsonx.ibm.com/managed-by: agent-operator
spec:
  releaseName: ibm-concert-agent-z-spyre
  namespace: ""  # REQUIRED: Must match metadata.namespace
  tenantId: ""  # REQUIRED: Tenant identifier for multi-tenancy support
  wxa4z-core-services-namespace: wxa4z-zad  # Namespace where wxa4z core services are deployed
  
  agentDetails:
    - agentName: ibm-concert-agent-z-spyre
      agentId: wxa4z:ibm-concert-agent-z-spyre:agent
      description: 'Answers questions about CICS regions, CICSPlexes, sysplexes, LPARs, and workloads in z/OS environments'
      bootstrapConfig:
        name: "ibm-concert-agent-z-spyre-bootstrap-config"
        fileName: "ibm_concert_agent_z_spyre_bootstrap_config.yaml"
  
  chart:
    repository: oci://icr.io/ibm-operations-aai
    name: ibm-concert-agent-z-spyre
    version: "1.2.0"  # Update to the desired chart version
    # Uncomment if using a private registry:
    # pullSecrets:
    #   - name: ibm-concert-agent-image-pull-secret-spyre

  values:
    replicaCount: 1
    
    global:
      secrets:
        name: wxa4z-watsonx-credentials  # Global secrets shared across agents
    
    secrets:
      name: wxa4z-ibm-concert-agent-z-spyre-secrets  # Agent-specific secrets
    
    env:
      # LLM Configuration
      LLM_MODEL: "meta-llama/llama-3-3-70b-instruct"
      MODEL_RUNTIME: "openai_protocol"
```

#### Applying the CR

1. Save the CR configuration to a file (e.g., `ibm-concert-agent-z-spyre-cr.yaml`)
2. Update all placeholder values marked as `REQUIRED`
3. Apply the CR to your cluster:

```bash
oc apply -f ibm-concert-agent-z-spyre-cr.yaml
```

4. Verify the deployment:

```bash
# Check CR status
oc get agentservice ibm-concert-agent-z-spyre -n <namespace>

# Check agent pods
oc get pods -n <namespace> -l app=ibm-concert-agent-z-spyre

# View agent logs
oc logs -n <namespace> -l app=ibm-concert-agent-z-spyre --tail=100
```

### Secret Configuration

The agent requires Kubernetes Secrets containing sensitive configuration values. **Never commit secrets to version control.**

#### Secret Types

The agent uses two types of secrets:

1. **Global Secrets** (`wxa4z-watsonx-credentials`): Shared across all agents
2. **Agent-Specific Secrets** (`wxa4z-ibm-concert-agent-z-spyre-secrets`): Unique to this agent

#### Agent-Specific Secret Reference

Create a secret with the following structure. **All values must be base64-encoded.**

```yaml
apiVersion: v1
kind: Secret
metadata:
  name: wxa4z-ibm-concert-agent-z-spyre-secrets
  namespace: ""  # REQUIRED: Must match the agent namespace
type: Opaque
data:
  # Agent Authentication (base64-encoded)
  AGENT_AUTH_TOKEN: ""  # Token used by agent-controller to register with wxo
  # Unite API Configuration (base64-encoded)
  UNITE_CLIENT_ID: ""  # Client ID for Unite API access
  UNITE_CLIENT_SECRET: ""  # Client secret for Unite API access
  UNITE_GRANT_TYPE: ""  # OAuth2 grant type (e.g., client_credentials)
  UNITE_API_URL: ""  # Unite API base URL
  UNITE_TOKEN_URL: ""  # URL to retrieve the Unite token
  # Assistant Configuration (base64-encoded)
  ASSISTANT_VERSION: ""  # Assistant API version
  ASSISTANT_ENV_ID: ""  # Assistant environment ID
  ASSISTANT_API_KEY: ""  # Assistant API key (for cloud deployments)
  ASSISTANT_SVC_INSTANCE_URL: ""  # Assistant service instance URL
  # CPD Configuration (for on-prem only, base64-encoded)
  CPD_AUTH_URL: ""  # CPD authorization URL (on-prem only)
  CPD_ADMIN_PASSWORD: ""  # CPD admin password (on-prem only)
  # Optional: Langfuse Observability (base64-encoded)
  LANGFUSE_SECRET_KEY: ""
  LANGFUSE_PUBLIC_KEY: ""
  LANGFUSE_HOST: ""
```

#### Creating the Secret

Apply the secret:

```bash
oc apply -f secret.yaml
```

### Step 1: Create ICR Pull Secret (First-Time Setup)

Run the following command to create an image pull secret for IBM Cloud Container Registry (ICR):

```bash
oc create secret -n <your-namespace> docker-registry ibm-concert-agent-z-secrets \
  --docker-server=icr.io \  #replace this with container registry
  --docker-username=iamapikey \ # replace this with container registry username
  --docker-password=<your-api-key> # replace this with container registry password
```

> Replace <your-namespace> and <your-api-key> with your specific namespace and API key.


---

### Step 2: Update pull secret in `values.yaml`

In your Helm chart's[ `values.yaml`] , update the image pull secret:

```yaml
imagePullSecrets:
  - name: ibm-concert-agent-z-secrets
```

---

### Step 3: Install Helm Chart

Finally, install the Helm chart:

```bash
helm upgrade --install ibm-concert-agent-z-spyre . \
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
ibm-concert-agent-z-spyre:
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