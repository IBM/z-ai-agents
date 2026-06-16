# IBM Z Compilers Fix Finder Agent

## Overview
The IBM Z Compilers Fix Finder Agent helps compiler users find any potential fixes for unexpected compiler behavior.

## Agent capabilities

| Agent capability                                 | Description                                                                                                                 |
| ------------------------------------------------ | --------------------------------------------------------------------------------------------------------------------------- |
| Investigate error causes              | Provides related documentation for known errors that may be related to the problem described                                            |
| Report known fixes            | Provides a list of known fixes and workarounds for given errors for supported IBM Z compilers      |

## Prerequisites
Ensure the following:

- [watsonx Assistant for Z](https://www.ibm.com/docs/watsonx/waz/3.0.0?topic=install-premises-watsonx-orchestrate-watsonx-assistant-z) is installed

## Deployment Guide

The IBM Z Compilers Fix Finder Agent is deployed using a Custom Resource (CR) definition. The CR provides a declarative way to manage the agent deployment through the agent operator.

### Prerequisites

Before deploying the agent, ensure:

1. The agent operator is installed and running in your cluster
2. The target namespace exists

### Step 1: Create Secrets

The agent requires Kubernetes Secrets containing sensitive configuration values. **Never commit secrets to version control.**

#### Secret Types

The agent uses two types of secrets:

1. **Global Secrets** (`wxa4z-watsonx-credentials`): Shared across all agents
2. **Agent-Specific Secrets** (`wxa4z-compiler-fix-finder-agent-agent-secrets`): Unique to this agent

#### Agent-Specific Secret Reference

Create a secret with the following structure. **All values must be base64-encoded.**

```yaml
apiVersion: v1
kind: Secret
metadata:
  name: wxa4z-compiler-fix-finder-agent-secrets
  namespace: ""  # REQUIRED: Must match the agent namespace
type: Opaque
data:
  # Agent Authentication (base64-encoded, REQUIRED)
  AGENT_AUTH_TOKEN: ""  # REQUIRED: Agent auth token for registration with WxO. A default value "AGENT_AUTH_TOKEN" is set if not provided, but you should configure a proper token.
  LANGFUSE_SECRET_KEY: ""
  LANGFUSE_PUBLIC_KEY: ""
```

> **Important:**
> - **AGENT_AUTH_TOKEN is required** for agent registration with watsonx Orchestrate.


#### Creating the Secret

1. Save the secret configuration to a file (e.g., `compiler-fix-finder-agent-agent-secret.yaml`)
2. Update the namespace and base64-encode all secret values
3. Apply the secret:

```bash
oc apply -f compiler-fix-finder-agent-agent-secret.yaml
```

4. Verify the secret was created:

```bash
oc get secret wxa4z-compiler-fix-finder-agent-agent-secrets -n <namespace>
```

### Step 2: Deploy Agent using Custom Resource (CR)

The IBM Z Compilers Fix Finder Agent can be deployed using a Custom Resource (CR) definition. The CR provides a declarative way to manage the agent deployment through the agent operator.

#### Configuration Parameters

The following table outlines the key configuration parameters:

| Parameter | Description | Required |
|-----------|-------------|----------|
| **metadata.namespace** | Target namespace for agent deployment | Yes |
| **spec.tenantId** | Tenant identifier for multi-tenancy support | Yes |
| **spec.chart.version** | Helm chart version to deploy | Yes |
| **spec.values.env.WATSONX_MODEL_ID** | LLM Model ID (e.g., "meta-llama/llama-3-3-70b-instruct") | Yes |
| **spec.values.env.MODEL_RUNTIME** | MODEL RUNTIME (e.g., "openai_protocol") | Yes |
| **spec.values.secrets.name** | Name of agent-specific secrets | Yes |
| **spec.values.global.secrets.name** | Name of global shared secrets | Yes |

#### CR Definition

Below is the complete Custom Resource definition. Update the placeholder values according to your environment:

```yaml
apiVersion: wxa4z.watsonx.ibm.com/v1alpha1
kind: AgentService
metadata:
  name: compiler-fix-finder-agent
  namespace: ""  # REQUIRED: Target namespace (e.g., wxa4z-agents)
  labels:
    wxa4z.watsonx.ibm.com/managed-by: agent-operator
spec:
  releaseName: compiler-fix-finder-agent
  namespace: ""  # REQUIRED: Must match metadata.namespace
  tenantId: ""  # REQUIRED: Tenant identifier for multi-tenancy support
  wxa4z-core-services-namespace: wxa4z-zad  # Namespace where wxa4z core services are deployed
  
  agentDetails:
    - agentName: compiler-fix-finder-agent
      agentId: wxa4z:compiler-fix-finder-agent:agent
      description: 'Enables system programmers to retrieve and analyze Automation and Netview domain information'
      bootstrapConfig:
        name: "compiler-fix-finder-agent-bootstrap-config"
        fileName: "compiler_fix_finder_agent_bootstrap_config.yaml"
  
  chart:
    repository: oci://icr.io/zoscp-sandbox/charts
    name: compiler-fix-finder-agent
    version: "1.1.3"  # Update to the desired chart version
    # Uncomment if using a private registry:
    # pullSecrets:
    #   - name: wxa4z-image-pull-secret

  values:
    replicaCount: 1
    
    global:
      secrets:
        name: wxa4z-watsonx-credentials  # Global secrets shared across agents
    
    secrets:
      name: wxa4z-compiler-fix-finder-agent-secrets  # Agent-specific secrets
    
    env:
      # LLM Configuration
      WATSONX_MODEL_ID: "meta-llama/llama-3-3-70b-instruct"
      MODEL_RUNTIME: "openai_protocol"
      # Add if other ENV need for deployment
```

#### Installing the Agent

1. Save the CR configuration to a file (e.g., `compiler-fix-finder-agent-cr.yaml`)
2. Update all placeholder values marked as `REQUIRED`
3. Apply the CR to your cluster:

```bash
oc apply -f compiler-fix-finder-agent-cr.yaml
```

4. Verify the deployment:

```bash
# Check CR status
oc get agentservice compiler-fix-finder-agent -n <namespace>

# Check agent pods
oc get pods -n <namespace> -l app=compiler-fix-finder-agent

# View agent logs
oc logs -n <namespace> -l app=compiler-fix-finder-agent --tail=100
```

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

5. Click the **Subscribe** button next to the **IBM Z Compilers Fix Finder Agent**.
   - This action adds the agent to watsonx Orchestrate (WXO) and makes it available for deployment.


### Step 4: Deploy the agent

1. Log in to watsonx Orchestrate.
2. From the main menu, navigate to **Build** > **Agent Builder**.
3. Select the **IBM Z Compilers Fix Finder Agent** tile.
4. In the AI Assistant window, enter a query to confirm that the response aligns with your expectations.
5. Click **Deploy** to activate the agent and make it available in the live environment.


### Step 5: Upgrade the Agent

To upgrade the agent to a new version:

> **Note:** If the agent was previously subscribed to watsonx Orchestrate, you must first unsubscribe it before upgrading. After the upgrade is complete, re-subscribe the agent. See the [Uninstall the Agent](#step-6-uninstall-the-agent) section for unsubscribe steps and the [Subscribe to the agent](#step-3-subscribe-to-the-agent) section for subscribe steps.

1. Update the `spec.chart.version` field in your CR file:

```yaml
spec:
  chart:
    version: "1.1.4"  # Update to the new version
```

2. Apply the updated CR:

```bash
oc apply -f compiler-fix-finder-agent-agent-cr.yaml
```

3. Monitor the upgrade progress:

```bash
# Watch the agent pods rolling update
oc get pods -n <namespace> -l app=compiler-fix-finder-agent-agent -w

# Check the CR status
oc describe agentservice compiler-fix-finder-agent-agent -n <namespace>
```

The agent operator will automatically handle the upgrade process, including rolling updates of the agent pods.

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

5. Click the **Unsubscribe** button next to the **IBM Z Compilers Fix Finder Agent**.
   - This action removes the agent from watsonx Orchestrate (WXO).

**Then, delete the agent resources:**

1. Delete the Custom Resource:

```bash
oc delete agentservice compiler-fix-finder-agent-agent -n <namespace>
```

2. Verify the agent resources are removed:

```bash
# Check that the agent pods are terminated
oc get pods -n <namespace> -l app=compiler-fix-finder-agent-agent

# Verify the CR is deleted
oc get agentservice -n <namespace>
```

3. (Optional) Clean up secrets if no longer needed:

```bash
# Delete agent-specific secrets
oc delete secret wxa4z-compiler-fix-finder-agent-agent-secrets -n <namespace>

# Note: Do not delete global secrets if other agents are using them
```

> **Note:** The agent operator will automatically clean up all resources created by the agent, including deployments, services, and configmaps. However, secrets must be manually deleted if they are no longer needed.

## Test the agent

After deployment, the agent becomes active and is available for selection in the live environment.

1. From the main menu, select **Chat**.
2. Choose your agent from the list.
3. Enter your queries using the AI Assistant.
   For example:

  - How do I properly update my usermod after installing a PTF that modifies the IGYCDOPT module?
  - My COBOL 6.3 program is crashing when I code a JSON statement. Are there fixes related to this?

4. Verify that the responses returned by the AI Assistant are accurate.


## Troubleshooting

### Installation Errors

If you encounter errors during installation:

1. **Verify Prerequisites:**
   ```bash
   # Check agent operator is running
   oc get pods -n <operator-namespace> -l app=agent-operator

   # Verify secrets exist
   oc get secrets -n <namespace>
   ```

2. **Check CR Status:**
   ```bash
   oc describe agentservice compiler-fix-finder-agent-agent -n <namespace>
   ```

3. **Review Agent Operator Logs:**
   ```bash
   oc logs -n <operator-namespace> -l app=agent-operator --tail=100
   ```

4. **Validate Secret Configuration:**
   - Ensure all required secrets are properly base64-encoded
   - Verify secret names match those referenced in the CR


------------------------------------------------------------