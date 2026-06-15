# z/OS Agent

## Overview

The IBM Agents for z/OS configuration agent can assist with queries about the configuration of your z/OS systems, such as how to enable SMF tracing, if a library is currently in LNKLST, or displaying the APF-authorized libraries, etc.

## Agent Capabilities

| Agent Capability | Description |
|------------------|-------------|
| z/OS System Interaction | Interact with IBM z/OS systems through z/os REST APIs |
| Dynamic Tool Loading | Leverage MCP for dynamic loading of tools and prompts |
| AI-Powered Automation | Use LangGraph-based AI to automate z/OS operations |

## Prerequisites

Ensure the following:

- watsonx Assistant for Z is installed
- z/os is properly configured and accessible
- You have the necessary credentials and permissions to access z/os APIs

## Install the z/os Agent

> **Note:** Follow CR-based deployment using the `AgentService` custom resource, please refer to the [Deployment Guide](../../DEPLOYMENT_GUIDE.md) for detailed instructions.

### Step 1: Configure Global Shared Variables

***Create Shared Variables(Create once, reuse everywhere)***

| Key                           | What it is                                                            | Reference                    |
| ----------------------------- | --------------------------------------------------------------------- | ---------------------------- |
| `WATSONX_DEPLOYMENT_SPACE_ID` | ID of the watsonx.ai **Deployment Space** used for model deployments. | [Watsonx.ai Deployment Spaces](https://www.ibm.com/docs/en/cloud-paks/cp-data/5.2.x?topic=spaces-creating-deployment)|
| `WATSONX_ML_URL`              | Base URL of the **Watson Machine Learning / CPD** instance.           | CPD  Instance url or WML Endpoint(Cloud Only)           |
| `CPD_USERNAME`                | Username for **Cloud Pak for Data** authentication.                   | CPD Username           |
| `WATSONX_API_KEY`             | API key used to access CPD/Watsonx services.            |   [Create WATSONX_API_KEY](https://www.ibm.com/docs/en/cloud-paks/cp-data/5.2.x?topic=tutorials-generating-api-keys)      |
| `WATSONX_PROJECT_ID`          | watsonx.ai **Project** identifier used for assets and jobs.           | [Watsonx.ai Projects](https://www.ibm.com/docs/en/cloud-paks/cp-data/5.2.x?topic=projects-creating-project#create-a-project)    |
| `ORCHESTRATE_ENV_URL`          | Watsonx Orchestrate Service Instance URL           | Log In to watsonx orchestrate. Navigate to `settings`, copy the service instance url from `API Details` tab     |
| `ORCHESTRATE_ENV_TYPE`          | Watsonx Orchestrate Instance Type           | ibm_iam(for cloud), mcsp(AWS saas), cpd (on-prem)     |
| `EXTERNAL_WATSONX_API_KEY`          | External Watsonx API Key(Optional)         | External CPD API Key, required  only when External IFM is configured for WxO with model gateway |
| `MODEL_RUNTIME`          | Model runtime environment type (Required)         | Use "on-prem" for watsonx.ai on CPD, "cloud" for watsonx.ai on SaaS, or "openai_protocol" for OpenAI-compatible inference runtimes |
| `LLM_BASE_URL`          | Inferencing stack URL (Optional)         | Required only when `MODEL_RUNTIME` is set to "openai_protocol" |
| `LLM_API_KEY`          | Inferencing stack API key (Optional)         | Required only when `MODEL_RUNTIME` is set to "openai_protocol" |


### Step 2: Configure Image Pull Secret

In the same `values.yaml` file, configure the registry credentials under `global.registry`:

```yaml
global:
  registry:
    name: wxa4z-image-pull-secret
    createSecret: true  # Set to true to create the secret automatically
    server: icr.io
    username: iamapikey
    entitlementKey: "<your-entitlement-key>"  # Your watsonx Assistant for Z entitlement key
```

### Step 3: Configure z/os Agent-Specific Settings

Scroll down to the `zos-agent` section in the `values.yaml` file and configure the following:

#### 3.1 Enable the Agent

```yaml
zos-agent:
  enabled: true  # Set to true to enable the z/os Agent
```

#### 3.2 Configure Environment Variables

```yaml
  env:
    DEPLOYMENT_TYPE: "on-prem"  # Set to "cloud" for IBM Cloud or "on-prem" for CPD
    WATSONX_DEPLOYMENT_SPACE_ID: "<your-deployment-space-id>"  # Deployment space ID
    WATSONX_MODEL_ID: "ibm/granite-3-3-8b-instruct"  # LLM model to use
    WATSONX_ML_URL: "<your-watsonx-ml-url>"  # Watson Machine Learning URL
    ONPREM_WML_INSTANCE_ID: "openshift"  # WML instance ID for on-premise
    LANGFUSE_EVALUATION_LLM_MODEL: "ibm/granite-3-3-8b-instruct"  # LLM model for evaluation
    MCP_SERVER_URL: "<mcp-server-url>"  # MCP server URL
    CPD_VERSION: "5.2"  # Cloud Pak for Data version
    MAX_COMPLETION_TOKENS: 4096  # Maximum completion tokens
    APPLID: "<application-id>"  # Application ID for passticket
    TENANT_ID: "<tenant-id>"  # Tenant ID
    RAG_REMOTE_URL: "<rag-remote-url>"  # Remote RAG URL
```

#### 3.3 Configure Agent-Specific Secrets

```yaml
  secrets:
    name: wxa4z-zos-agent-secrets
    data:
      CPD_USERNAME: "cpadmin"  # Cloud Pak for Data username
      WRAPPER_USERNAME: "<opensearch-username>"  # OpenSearch wrapper username
      WRAPPER_PASSWORD: "<opensearch-password>"  # OpenSearch wrapper password
      WRAPPER_URL: "<opensearch-url>"  # OpenSearch wrapper URL
      WATSONX_API_KEY: "<your-watsonx-api-key>"  # Watsonx API key
      WATSONX_PROJECT_ID: "<your-project-id>"  # Watsonx project ID
      AGENT_AUTH_TOKEN: "<agent-auth-token>"  # Authentication token for the agent
      AGENT_ID: "wxa4z:zosconfig:agent"  # Agent identifier
      AUTH_SERVICE_BASE_URL: "<auth-service-url>"  # Authorization service base URL
      LANGFUSE_SECRET_KEY: "<langfuse-secret>"  # Langfuse secret key (optional)
      LANGFUSE_PUBLIC_KEY: "<langfuse-public>"  # Langfuse public key (optional)
      LANGFUSE_BASE_URL: "<langfuse-url>"  # Langfuse base URL (optional)
      MODEL_RUNTIME: "on-prem"  # Model runtime: "on-prem", "cloud", or "openai_protocol"
      LLM_BASE_URL: "<llm-base-url>"  # LLM base URL (required for openai_protocol)
      LLM_API_KEY: "<llm-api-key>"  # LLM API key (required for openai_protocol)
```

### Custom Resource (CR) Configuration

The z/OS Agent can be deployed using a Custom Resource (CR) definition. The CR provides a declarative way to manage the agent deployment through the agent operator.

#### Prerequisites for CR Deployment

Before deploying the agent using the CR, ensure:

1. The agent operator is installed and running in your cluster
2. You have created the required secrets (see [Secret Configuration](#secret-configuration))
3. The target namespace exists
4. z/OS is properly configured and accessible
5. Authorization service is deployed for passticket generation

#### CR Structure Overview

The Custom Resource consists of the following main sections:

- **metadata**: Identifies the agent and its namespace
- **spec.agentDetails**: Defines agent-specific configuration and bootstrap settings
- **spec.chart**: Specifies the Helm chart location and version
- **spec.values**: Contains deployment values including environment variables and secret references

#### CR Reference

Below is the complete Custom Resource definition for the z/OS Agent. Update the placeholder values according to your environment:

```yaml
apiVersion: wxa4z.watsonx.ibm.com/v1alpha1
kind: AgentService
metadata:
  name: zos-agent
  namespace: ""  # REQUIRED: Target namespace (e.g., wxa4z-agents)
  labels:
    wxa4z.watsonx.ibm.com/managed-by: agent-operator
spec:
  releaseName: zos-agent
  namespace: ""  # REQUIRED: Must match metadata.namespace
  tenantId: ""  # REQUIRED: Tenant identifier for multi-tenancy support
  wxa4z-core-services-namespace: wxa4z-zad  # Namespace where wxa4z core services are deployed
  
  agentDetails:
    - agentName: zos-agent
      agentId: wxa4z:zosconfig:agent
      description: 'Assists with queries about z/OS system configuration'
      bootstrapConfig:
        name: "zos-agent-bootstrap-config"
        fileName: "zos_agent_bootstrap_config.yaml"
  
  chart:
    repository: oci://icr.io/wxa4z-dev-container-registry
    name: zos-agent
    version: "1.0.0"  # Update to the desired chart version
    # Uncomment if using a private registry:
    # pullSecrets:
    #   - name: wxa4z-image-pull-secret

  values:
    replicaCount: 1
    
    global:
      secrets:
        name: wxa4z-watsonx-credentials  # Global secrets shared across agents
    
    secrets:
      name: wxa4z-zos-agent-secrets  # Agent-specific secrets
    
    env:
      # Model Runtime Configuration
      MODEL_RUNTIME: "on-prem"  # Options: "on-prem", "cloud", or "openai_protocol"
      WATSONX_MODEL_ID: "ibm/granite-3-3-8b-instruct"  # LLM model to use
      # Add other ENV variables as needed for deployment
```

#### Applying the CR

1. Save the CR configuration to a file (e.g., `zos-agent-cr.yaml`)
2. Update all placeholder values marked as `REQUIRED`
3. Apply the CR to your cluster:

```bash
oc apply -f zos-agent-cr.yaml
```

4. Verify the deployment:

```bash
# Check CR status
oc get agentservice zos-agent -n <namespace>

# Check agent pods
oc get pods -n <namespace> -l app=zos-agent

# View agent logs
oc logs -n <namespace> -l app=zos-agent --tail=100
```

### Secret Configuration

The agent requires Kubernetes Secrets containing sensitive configuration values. **Never commit secrets to version control.**

#### Secret Types

The agent uses two types of secrets:

1. **Global Secrets** (`wxa4z-watsonx-credentials`): Shared across all agents
2. **Agent-Specific Secrets** (`wxa4z-zos-agent-secrets`): Unique to this agent

#### Agent-Specific Secret Reference

Create a secret with the following structure. **All values must be base64-encoded.**

```yaml
apiVersion: v1
kind: Secret
metadata:
  name: wxa4z-zos-agent-secrets
  namespace: ""  # REQUIRED: Must match the agent namespace
type: Opaque
data:
  # Agent Authentication (base64-encoded)
  AGENT_AUTH_TOKEN: ""  # Authentication token for the agent
  AGENT_ID: "wxa4z:zosconfig:agent"  # Agent identifier
  AUTH_SERVICE_BASE_URL: ""  # Authorization service base URL
  # Optional: Langfuse Observability (base64-encoded)
  LANGFUSE_SECRET_KEY: ""
  LANGFUSE_PUBLIC_KEY: ""
  LANGFUSE_BASE_URL: ""
```

#### Creating the Secret

Apply the secret:

```bash
oc apply -f secret.yaml
```

#### 3.4 Configure Image Registry (Agent-Specific)

```yaml
  registry:
    name: zos-agent-image-pull-secret
    createSecret: true
    server: icr.io
    username: iamapikey
    entitlementKey: "<your-entitlement-key>"  # Your watsonx Assistant for Z entitlement key
```
## Environment Variables Reference

This section provides a comprehensive list of all environment variables that can be configured for the z/OS Agent based on the values.yaml file.

### 1. Core Configuration

| Variable | Description | Location |
|----------|-------------|----------|
| `WATSONX_DEPLOYMENT_SPACE_ID` | Deployment space ID for watsonx.ai | env |
| `DEPLOYMENT_TYPE` | Deployment type ('on-prem' or 'cloud') | env |
| `ONPREM_WML_INSTANCE_ID` | WML instance ID for on-premise deployments | env |
| `WATSONX_MODEL_ID` | Large Language Model ID (e.g., ibm/granite-3-3-8b-instruct) | env |
| `LANGFUSE_EVALUATION_LLM_MODEL` | LLM model for evaluation | env |
| `MCP_SERVER_URL` | MCP server URL | env |
| `WATSONX_ML_URL` | Watson Machine Learning service URL | env |
| `CPD_VERSION` | Cloud Pak for Data version | env |
| `MAX_COMPLETION_TOKENS` | Maximum completion tokens | env |

### 2. Passticket Configuration

| Variable | Description | Location |
|----------|-------------|----------|
| `APPLID` | Application ID for passticket | env |
| `TENANT_ID` | Tenant ID | env |

### 3. RAG Configuration

| Variable | Description | Location |
|----------|-------------|----------|
| `RAG_REMOTE_URL` | Remote RAG system URL | env/secrets |

### 4. Authentication and Credentials

| Variable | Description | Location |
|----------|-------------|----------|
| `CPD_USERNAME` | Cloud Pak for Data username | secrets |
| `WATSONX_API_KEY` | Watsonx API key | secrets |
| `WATSONX_PROJECT_ID` | Watsonx project ID | secrets |
| `AGENT_AUTH_TOKEN` | Authentication token for the agent | secrets |
| `AGENT_ID` | Agent identifier | secrets |
| `AUTH_SERVICE_BASE_URL` | Authorization service base URL | secrets |

### 5. OpenSearch Configuration

| Variable | Description | Location |
|----------|-------------|----------|
| `WRAPPER_USERNAME` | OpenSearch wrapper username | secrets |
| `WRAPPER_PASSWORD` | OpenSearch wrapper password | secrets |
| `WRAPPER_URL` | OpenSearch wrapper service URL | secrets |

### 6. Langfuse Observability (Optional)

| Variable | Description | Location |
|----------|-------------|----------|
| `LANGFUSE_SECRET_KEY` | Langfuse secret key | secrets |
| `LANGFUSE_PUBLIC_KEY` | Langfuse public key | secrets |
| `LANGFUSE_BASE_URL` | Langfuse service URL | secrets |

### 7. OpenAI Protocol Support (Optional)

| Variable | Description | Location |
|----------|-------------|----------|
| `MODEL_RUNTIME` | Runtime type ('on-prem', 'cloud', or 'openai_protocol') | secrets |
| `LLM_BASE_URL` | Base URL for OpenAI-compatible API | secrets |
| `LLM_API_KEY` | API key for OpenAI-compatible API | secrets |

*Required when MODEL_RUNTIME is 'openai_protocol'

### 8. Bootstrap Job Configuration

| Variable | Description | Location |
|----------|-------------|----------|
| `ORCHESTRATE_ENV_NAME` | Watsonx Orchestrate environment name | bootstrapJob.env |
| `ORCHESTRATE_ENV_TYPE` | Orchestrate environment type | bootstrapJob.secret |
| `ORCHESTRATE_ENV_URL` | Watsonx Orchestrate URL | bootstrapJob.secret |


### Install or Upgrade the wxa4z-agent-suite

> **Note**: If you're installing multiple agents, you can configure the [values.yaml](../../wxa4z-agent-suite/values.yaml) file for all the agents you wish to install. Once the file is updated, run the command below to install them all at once.

Use the following command to install or upgrade the wxa4z-agent-suite:

```bash
helm upgrade --install wxa4z-agent-suite \
  ./wxa4z-agent-suite \
  -n <wxa4z-namespace> \
  -f <path_to>/values.yaml --wait
```

Replace `<wxa4z-namespace>` with your target namespace and `<path_to>` with the path to your values.yaml file.

## Deploy the Agent

1. Log in to watsonx Orchestrate.
2. From the main menu, navigate to **Build** > **Agent Builder**.
3. Select the **IBM Agents for z/OS** tile.
4. In the AI Assistant window, enter a query to confirm that the response aligns with your expectations.
5. Click **Deploy** to activate the agent and make it available in the live environment.

## Test Your Agent

After deployment, the agent becomes active and is available for selection in the live environment.

1. Log in to watsonx Orchestrate.
2. From the main menu, click **Chat**.
3. Choose your agent from the list.
4. Enter your queries using the AI Assistant.
   
   For example:
   - "Is SMF enabled on my system?"
   - "Which data sets are currently in LNKLST?"
   - "Which SMF record types are being collected on my system right now?"

   Responses are displayed either in a tabular format or as a sentence, depending on the context.

5. Verify that the responses returned by the AI Assistant are accurate.
