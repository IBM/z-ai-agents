# z-ai-agents - Deployment Guide

## Table of Contents

1. [Overview](#overview)
2. [Repo Layout](#repo-layout)
3. [Compatibility & Requirements](#compatibility--requirements)
4. [Preflight Checklist](#preflight-checklist)
5. [Quickstart](#quick-start)
   - [Global settings](#1-global-settings)
   - [Per Agent Configuration](#2-per-agent-configuration)
   - [Deploy Agents using AgentService Custom Resource](#3-deploy-agents-using-agentservice-custom-resource)
6. [Post Deployment Verification](#post-deployment-verification)
7. [Troubleshooting](#troubleshooting)
8. [FAQ](#faq)
---

## Overview
Orchestrates the deployment of multiple IBM z/OS‑focused agents. It’s designed for enterprises running on OpenShift who want:

- A **consistent install** story across environments (dev/test/prod)
- **Federated configuration** (shared global values + agent‑specific overrides)
- **Secure secret handling** (no hard‑coding; Kubernetes Secrets only)
- **Idempotent upgrades** (Helm‑native lifecycle)


---

## Repo Layout
```
<agent-folder>/ #
├─ README.md # Readme to guide users on how to use the agent
├─ cr.yaml # Custom Resource Definition (CRD)
├─ LICENSE # License file
README.md # Overall README file
LICENSE # License file
```
---

## Supported Agents

### IBM watsonx Assistant for Z Foundational Agents

| Name                       | Chart name               | Category      |   Reference   |
| -------------------------- | ------------------------ | ------------- | ------------- |
| IBM Z Support Agent              | `support-agent`          | Foundational | [README](./support-agent/README.md)                   |
| IBM Z OMEGAMON Insights Agent | `omegamon-insights-agent` | Foundational | [README](./omegamon-insight-agent-z/README.md)                  |
| IBM Z Upgrade Agent    | `upgrade-agent`          | Foundational |  [README](./upgrade-agent/README.md)                  |
| IBM Z Automation Insights Agent | `automation-insights-agent` | Foundational |[README](./automation-insight-agent/README.md)|
| IBM Z Workload Scheduler Insights Agent | `workload-scheduler-agent-z` | Foundational |[README](./workload-scheduler-agent-z/README.md)|
| IBM zRAG Agent | `zRAG Agent` | Foundational |[README](./zrag-agent/README.md)|

### Prebuilt IBM Z product agents

| Name                           | Chart name                     | Category         |  Reference       |
| ------------------------------ | ------------------------------ | -----------------| -----------------|
| IBM CICS Transaction Server agents for Z                     | `cics-agent`                   | Product  |[README](./cics-agent/README.md)|
| IBM Db2 for z/OS Agent             | `db2z-agent`                   | Product  |[README](./db2z-agent/README.md)|
| IBM IMS Agents                 | `ims-agent`                    | Product  |[README](./ims-agent/README.md)|
| IBM IntelliMagic agent for Z             | `intellimagic-agent`           | Product  |[README](./intellimagic-agent/README.md)|
| IBM Concert for Z Agent| `ibm-concert-agent-z` | Product  |[README](./ibm-concert-agent-z/README.md)|
| IBM Z Compilers Fix Finder Agent | `compiler-fix-finder-agent` | Product  |[README](./compiler-fix-finder-agent/README.md)|

---

## ⚠️ Attention

> **This site hosts only the Agent Deployment Guide, not the agents themselves. A valid entitlement must be obtained before agents can be properly deployed.**

> For **IBM watsonx Assistant for Z Foundational Agents**, entitlement is automatically granted with the purchase of **IBM watsonx Assistant for Z**. By installing the **IBM watsonx Assistant for Z Foundational Agents** in accordance with the instructions provided herein, you acknowledge and agree to comply with the terms of the **[IBM watsonx Assistant for Z License](https://www.ibm.com/support/customer/csol/terms/?id=L-EZAK-KGTP3H)**.

> For **Prebuilt IBM Z product agents**, a separate entitlement must be obtained for each corresponding product.

---

## Compatibility & Requirements

- **Helm:** v3.11+ (recommended v3.12+)
- **OpenShift CLI (oc)**:
    - installed and authenticated to the target cluster;
    - version compatible with your OCP (for example, oc 4.12+ for OCP 4.12).
    - Check: `oc whoami && oc version`
- **Network access:**
  - Online mode: pull images from registries (e.g., `icr.io`) or
  - Air-gapped mode: mirror images into a private registry and configure `global.registry.*`
- **Architectures:** `amd64` and `s390x`

## Preflight Checklist

- **Prerequisite product installed**: IBM watsonx Assistant for Z (foundation). Install steps: IBM Docs → [Install watsonx Assistant for Z](https://www.ibm.com/docs/en/watsonx/waz/3.3.0?topic=install-premises-watsonx-orchestrate-watsonx-assistant-z).

- **Entitlement(s) available for all agents being installed**:

    - Foundational Agents → covered by IBM watsonx Assistant for Z entitlement.

    - Prebuilt IBM Z product agents → require separate product entitlements (e.g. Db2 for z/OS, IMS).

### Where do I get the entitlement key?

- For **IBM watsonx Assistant for Z**: During the installation process of watsonx Assistant for Z, you would have acquired the entitlement key. However, if you need to retrieve it again, follow the steps in [Get wxa4z entitlement key](https://www.ibm.com/docs/en/watsonx/waz/3.3.0?topic=z-update-global-pull-secret)

- For **Prebuilt IBM Z product agents**: Refer to agent specific [README](#prebuilt-ibm-z-product-agents)

---

## Quick Start

### 1. Global settings

***Create Shared Variables(Create once, reuse everywhere)***

| Key                           | What it is                                                            | Reference                    |
| ----------------------------- | --------------------------------------------------------------------- | ---------------------------- |
| `WATSONX_DEPLOYMENT_SPACE_ID` | ID of the watsonx.ai **Deployment Space** used for model deployments. (Optional) | [Watsonx.ai Deployment Spaces](https://www.ibm.com/docs/en/cloud-paks/cp-data/5.2.x?topic=spaces-creating-deployment) if Watsonx deployment space ID available then add, otherwise keep empty|
| `WATSONX_ML_URL`              | Base URL of the **Watson Machine Learning / CPD** instance.           | CPD  Instance url or WML Endpoint(Cloud Only)           |
| `CPD_USERNAME`                | Username for **Cloud Pak for Data** authentication.                   | CPD Username           |
| `CPD_INSTANCE_API_KEY`             | API key used to access CPD/Watsonx services.            |   [Create CPD_INSTANCE_API_KEY](https://www.ibm.com/docs/en/cloud-paks/cp-data/5.2.x?topic=tutorials-generating-api-keys)      |
| `WATSONX_PROJECT_ID`          | watsonx.ai **Project** identifier used for assets and jobs. (Optional)          | [Watsonx.ai Projects](https://www.ibm.com/docs/en/cloud-paks/cp-data/5.2.x?topic=projects-creating-project#create-a-project) if Watsonx Project ID available then add, otherwise keep empty   |
| `ORCHESTRATE_ENV_URL`          | Watsonx Orchestrate Service Instance URL           | Log in to watsonx orchestrate. Navigate to `settings`, copy the service instance URL from `API Details` tab     |
| `ORCHESTRATE_ENV_TYPE`          | Watsonx Orchestrate Instance Type           | ibm_iam(for cloud), mcsp(AWS saas), cpd (on-prem)     |
| `EXTERNAL_WATSONX_API_KEY`          | Watsonx API Key(Optional)         | CPD API Key, required  only when External/Internal IFM is configured for WxO with model gateway |
| `MODEL_RUNTIME`          | Model runtime environment type (Required)         | Use "on-prem" for watsonx.ai on CPD, "cloud" for watsonx.ai on SaaS, or "openai_protocol" for OpenAI-compatible inference runtimes |
| `LLM_BASE_URL`          | Inferencing stack URL (Optional)         | Required only when `MODEL_RUNTIME` is set to "openai_protocol" |
| `LLM_API_KEY`          | Inferencing stack API key (Optional)         | Required only when `MODEL_RUNTIME` is set to "openai_protocol" |
| `LANGFUSE_SECRET_KEY`  | Langfuse secret key for observability (Optional) | Used for LLM observability and tracing |
| `WRAPPER_USERNAME`     | Username for wrapper service authentication (Optional) | Required for agents using wrapper services. Wrapper Username will be auto-populated on tenant namespace. Keep this value empty |
| `WRAPPER_URL`          | Wrapper service endpoint URL (Optional) | Required for agents using wrapper services. Wrapper URL will be auto-populated on tenant namespace. Keep this value empty. Once values are updated on Tenant NS, please append "/v1/query" to the WRAPPER_URL endpoint |
| `WRAPPER_PASSWORD`     | Password for wrapper service authentication (Optional) | Required for agents using wrapper services. Wrapper Password will be auto-populated on tenant namespace. Keep this value empty |
| `TENANT_ID`            | Tenant identifier for multi-tenancy support | Unique identifier for the tenant. Tenant ID will be auto-populated on tenant namespace. Keep this value empty   |
| `INGESTION_URL`        | Document ingestion service URL (Optional) | Required for agents with document ingestion capabilities. CI URL will be auto-populated on tenant namespace. Keep this value empty |
| `INGESTION_PASSWORD`   | Password for document ingestion service (Optional) | Required for agents with document ingestion capabilities. CI Password will be auto-populated on tenant namespace. Keep this value empty  |
| `LANGFUSE_HOST`        | Langfuse host URL for observability (Optional) | Host URL for Langfuse observability platform |

---

**Configure registry for mirrored images:**

   If using a private or mirrored registry, set `global.registry.server` to your internal registry endpoint and update `global.registry.name` to reference the imagePullSecret containing the registry credentials.
   > In air-gapped mode, authenticate to the private registry instead of using IBM entitlement keys.


   ```yaml
   apiVersion: v1
   kind: Secret
   metadata:
     name: wxa4z-watsonx-credentials
     namespace: <your-namespace>  # Replace with common service namespace
   type: Opaque
   stringData:
     ORCHESTRATE_ENV_TYPE: "cpd"  # Set to "cpd" for on-prem, "ibm_iam" for IBM Cloud
     ORCHESTRATE_ENV_URL: ""  # Watsonx Orchestrate service instance URL
     CPD_USERNAME: ""  # CPD Username (required for on-prem deployments)
     CPD_INSTANCE_API_KEY: ""  # CPD Instance API Key (required for register agent to orchestrate)
     WATSONX_DEPLOYMENT_SPACE_ID: ""  # Watsonx deployment space ID (Optional) if Watsonx deployment space ID available then add, otherwise keep empty
     WATSONX_ML_URL: ""  # CPD Instance FQDN (for on-prem) or WML endpoint (for cloud) (when MODEL_RUNTIME is "cloud/on-prem")
     EXTERNAL_WATSONX_API_KEY: ""  # CPD API Key to connect to instance where llm is hosted
     WATSONX_PROJECT_ID: ""  # Watsonx project ID (Optional) if Watsonx project ID available then add, otherwise keep empty
     MODEL_RUNTIME: ""  # Required: "on-prem", "cloud", or "openai_protocol"
     LLM_BASE_URL: ""  # Inferencing stack URL (when MODEL_RUNTIME is "openai_protocol")
     LLM_API_KEY: ""  # Inferencing stack API key (when MODEL_RUNTIME is "openai_protocol")
     LANGFUSE_SECRET_KEY: ""  # Langfuse secret key (optional)
     LANGFUSE_HOST: ""  # Langfuse host URL (optional)
     WRAPPER_USERNAME: ""  # Wrapper service username (optional) keep this empty, on tenant NS it will be auto-populated with username
     WRAPPER_URL: ""  # Wrapper service URL (optional) keep this empty, on tenant NS it will be auto-populated with URL, make sure to add "/v1/query" at the end of the URL once data is populated
     WRAPPER_PASSWORD: ""  # Wrapper service password (optional) keep this empty
     TENANT_ID: ""  # Tenant identifier (optional) Tenant ID will be auto-populated on tenant namespace. Keep this value empty
     INGESTION_URL: ""  # Document ingestion service URL (optional) CI URL will be auto-populated on tenant namespace. Keep this value empty
     INGESTION_PASSWORD: ""  # Document ingestion password (optional) CI Password will be auto-populated on tenant namespace. Keep this value empty
   ```

   **Note:** 
   1. wxa4z-watsonx-credentials secret will be auto-created in the tenant namespace.This secret only needs to be created in the common service namespace.
   2. All values in `stringData` are automatically base64-encoded by Kubernetes. Replace placeholder values with your actual configuration.
   3. After the tenant is created, append "/v1/query" to the WRAPPER_URL endpoint in the "wxa4z-watsonx-credentials" secret within the tenant namespace.

   Apply the secret:
   ```bash
   oc apply -f wxa4z-watsonx-credentials-secret.yaml
   ```

   Verify the secret was created:
   ```bash
   oc get secret wxa4z-watsonx-credentials -n <your-namespace>
   ```
---


## 2. Agent Configuration

### Connecting to LLM via AI Gateway

> **Note:** Use this configuration only if your agents must connect to an **instance with LLMs hosted** through an AI Gateway.

---

##### 1. Create Model Gateway Connection
- Follow the IBM documentation to create and configure a Model Gateway connection:
  [Managing LLM in Watson Orchestrate](https://developer.watson-orchestrate.ibm.com/llm/managing_llm)

---

##### 2. Configure EXTERNAL_WATSONX_API_KEY or LLM_API_KEY in the wxa4z-watsonx-credentials secret
- Update your EXTERNAL_WATSONX_API_KEY with the **CPD API key** or **IBM Cloud API key** if MODEL_RUNTIME is set to **cloud** or **on-prem**, and LLM_API_KEY with the **CPD API key** or **IBM Cloud API key** if MODEL_RUNTIME is set to **openai_protocol**

- Set the `WATSONX_ML_URL` to point to the **CPD instance with LLM running**.

#### 3. Deploy Agents using AgentService Custom Resource

For detailed deployment instructions using the `AgentService` custom resource, refer to the [Deployment Guide](https://www.ibm.com/docs/en/watsonx/waz/3.3.0?topic=z-deploy-agents).

#### Quick Start

1. **Create Agent-Specific Secret** (required for each agent)

   Before deploying an agent, create the agent-specific secret in the tenant namespace. Check the agent's `values.yaml` file to determine required secret fields.

   Example for agent-secret:
   ```bash
   oc apply -f <agent-name>-secret.yaml
   ```


2. **Apply AgentService Custom Resource**

   ```bash
   oc apply -f <agent-name>-cr.yaml
   ```

3. **Verify Deployment**

   ```bash
   # Check CR status
   oc get agentservice <agent-name> -n <tenant-namespace>
   
   # Check agent pods
   oc get pods -n <tenant-namespace> -l app=<agent-name>
   
   # View agent logs
   oc logs -n <tenant-namespace> -l app=<agent-name> --tail=100
   ```

#### Subscribe and Deploy Agent on watsonx Orchestrate

After successfully deploying the agent, you need to subscribe to it and deploy it in watsonx Orchestrate to make it available for use.

**Subscribe to the Agent:**

1. Open the Cloud Pak for Data (CPD) home page.
   - Example: `https://cpd-<instance>.apps.<cluster-domain>/zen/?context=icp4data#/homepage`

2. Click on the **Launch WXA4Z Console** tab.
   - This opens the WXA4Z Content Ingestion UI (Tenant Overview page).
   - Example: `https://wxa4z-content-ingestion-ui-route-wxa4z-zad.apps.<cluster-domain>/en`

3. On the Tenant Overview page, click on your **Tenant name**.

4. Navigate to the **Subscriptions** tab.
   - You will see a list of deployed agents with a **Subscribe** button next to each.

5. Click the **Subscribe** button next to your agent.
   - This action adds the agent to watsonx Orchestrate (WXO) and makes it available for deployment.

**Deploy the Agent on WXO:**

1. Log in to watsonx Orchestrate.

2. From the main menu, navigate to **Build** > **Agent Builder**.

3. Select your agent tile.

4. In the AI Assistant window, enter a query to confirm that the response aligns with your expectations.

5. Click **Deploy** to activate the agent and make it available in the live environment.

**Test the Agent:**

1. From the main menu, click **Chat**.

2. Choose your agent from the list.

3. Enter your queries using the AI Assistant.

4. Verify that the responses returned by the AI Assistant are accurate.

#### Upgrade Agent

To upgrade an agent to a new version:

1. Update the `spec.chart.version` field in your AgentService CR
2. Apply the updated CR:
   ```bash
   oc apply -f <agent-name>-cr.yaml
   ```
3. Monitor the upgrade:
   ```bash
   oc get pods -n <tenant-namespace> -l app=<agent-name> -w
   ```

#### Uninstall Agent

To uninstall an agent:

> **Important:** If the agent was previously subscribed to watsonx Orchestrate, you must first unsubscribe it before uninstalling.

**Unsubscribe the Agent (if previously subscribed):**

1. Open the Cloud Pak for Data (CPD) home page.
   - Example: `https://cpd-<instance>.apps.<cluster-domain>/zen/?context=icp4data#/homepage`

2. Click on the **Launch WXA4Z console** tab.
   - This opens the WXA4Z Content Ingestion UI (Tenant Overview page).
   - Example: `https://wxa4z-content-ingestion-ui-route-wxa4z-zad.apps.<cluster-domain>/en`

3. On the Tenant Overview page, click on your **Tenant name**.

4. Navigate to the **Subscriptions** tab.
   - You will see a list of deployed agents with an **Unsubscribe** button next to each.

5. Click the **Unsubscribe** button next to your agent.
   - This action removes the agent from watsonx Orchestrate (WXO).

**Then, delete the agent resources:**

```bash
oc delete agentservice <agent-name> -n <tenant-namespace>
```

Verify resources are removed:
```bash
oc get pods -n <tenant-namespace> -l app=<agent-name>
oc get agentservice -n <tenant-namespace>
```

---

## Post Deployment Verification

```bash
# Check AgentService CR status
oc get agentservice -n <tenant-namespace>

# Check agent pods
oc get pods -n <tenant-namespace>

# Check agent routes (OpenShift)
oc get route -n <tenant-namespace>

# View agent logs
oc logs -n <tenant-namespace> -l app=<agent-name> --tail=50
```

Common health signals:

- AgentService CR shows `Installed` status
- All agent pods are in `Running`/`Ready` state
- Routes/Ingresses are admitted and resolve over TLS
- Agents successfully reach required backends (CPD/WML, Orchestrate, z/OS endpoints)

---

## Troubleshooting

### Common Issues

- **Image pull back-off**:
  - Verify the pull secret exists in the tenant namespace
  - Ensure the pull secret is referenced in the AgentService CR (`spec.chart.pullSecrets`)
  - For air-gapped clusters, verify images are mirrored to your private registry

- **Agent pod fails to start**:
  - Check that the global secret `wxa4z-watsonx-credentials` exists in the core services namespace
  - Verify agent-specific secret exists in the tenant namespace
  - Check secret names match those referenced in the AgentService CR

- **Connectivity issues**:
  - Verify CPD/Orchestrate URLs and tokens in secrets
  - Check firewall rules and network policies
  - Test connectivity with `curl` from a debug pod

- **Helm chart not found**:
  - Ensure the Helm chart is packaged and pushed to the registry
  - Verify the chart repository URL in the AgentService CR
  - Check authentication to the container registry

### Getting Logs

```bash
# Describe failing pods
oc describe pod/<pod-name> -n <tenant-namespace>

# View agent operator logs
oc logs -n <operator-namespace> -l app=agent-operator --tail=100

# View agent logs
oc logs -n <tenant-namespace> -l app=<agent-name> --tail=100

# OpenShift events
oc get events -n <tenant-namespace> --sort-by=.lastTimestamp | tail -n 50
```

### Debug Mode

To enable debug logging for an agent, add the following to the AgentService CR:

```yaml
spec:
  values:
    env:
      LOG_LEVEL: "DEBUG"
```

---

## FAQ

**Q: How do I deploy multiple agents?**\
Create separate AgentService CRs for each agent. Each agent can have its own configuration and secrets.

**Q: Can I use a private registry?**\
Yes. Push your Helm charts to your private OCI-compliant registry and update the `spec.chart.repository` field in the AgentService CR.

**Q: How do I update agent configuration?**\
Update the AgentService CR with new configuration values and apply it. The agent operator will handle the rolling update.

**Q: Which architectures are supported?**\
Most agents target `amd64` and `s390x`. Check each agent's README for specific architecture support.

**Q: How do I manage secrets across environments?**\
Create environment-specific secrets (dev, qa, prod) in their respective namespaces. Reference the appropriate secret name in each environment's AgentService CR.

**Q: Can I deploy agents in different namespaces?**\
Yes. Each AgentService CR specifies its target namespace. Ensure the global secret exists in the core services namespace and agent-specific secrets exist in each tenant namespace.
