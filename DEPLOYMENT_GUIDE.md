# Deployment Guide

> This guide describes the manual steps required for deploying agents with the `AgentService` custom resource. It includes:
>
> - **Pre-deployment secret creation** for shared watsonx credentials
> - **Pre-deployment route preparation** for Agent Manager access
> - **YAML manifests** ready to apply in OpenShift

---

## Table of Contents

1. [Overview](#overview)
2. [Pre-deployment Steps](#pre-deployment-steps)
3. [Apply Resources](#apply-resources)

---

## Overview

Use this guide when deploying agents with the `AgentService` custom resource. Some resources must be prepared manually outside the main deployment flow, and the Agent Manager route should be created after the `Zassistantdeploy` custom resource is created.

These steps cover:

- Creating the **global secret** required by the deployed agents
- Creating the **OpenShift route** for Agent Manager as part of deployment preparation
- Providing reusable YAML definitions for both resources

> **Note:** Replace example namespaces, credentials, and environment-specific values before applying these manifests.

---

## Pre-deployment Steps

### Create Global Secret  (one-time setup)

Create the shared secret used by the agents deployed through the `AgentService` custom resource. This secret must be created in core-services namespace (for eg: wxa4z-zad)

```yaml
apiVersion: v1
kind: Secret
metadata:
  name: wxa4z-watsonx-credentials
  namespace: wxa4z-zad
type: Opaque
data:
  ORCHESTRATE_ENV_TYPE: "" # Set this to "cpd", "ibm_iam"(for ibm cloud). Non‑sensitive.
  CPD_INSTANCE_API_KEY: "" # Set this to CPD API key (on‑prem Refer https://www.ibm.com/docs/en/cloud-paks/cp-data/5.2.x?topic=tutorials-generating-api-keys) or IBM Cloud IAM API key (cloud).
  ORCHESTRATE_ENV_URL: "" # Set this to wxo service instance url.
  CPD_USERNAME: "" # Set this to CPD Username for on-prem deployments.
  WATSONX_DEPLOYMENT_SPACE_ID: "" # Set this to Watsonx deployment space id (Refer https://www.ibm.com/docs/en/cloud-paks/cp-data/5.2.x?topic=spaces-creating-deployment).
  WATSONX_ML_URL: "" # Set this to CPD Instance FQDN for on-prem deployments.
  EXTERNAL_WATSONX_API_KEY: "" # Set this to CPD Instance API key for connect
  WATSONX_PROJECT_ID: "" # Set this to Watsonx project id (Refer https://www.ibm.com/docs/en/cloud-paks/cp-data/5.2.x?topic=projects-creating-project#create-a-project).
  LANGFUSE_HOST: ""
  LANGFUSE_SECRET_KEY: ""
  LANGFUSE_PUBLIC_KEY: ""
  MODEL_RUNTIME: "" # "cpd" for watsonx ai on on-prem, "cloud" for watsonx ai on saas, openai_protocol for inferencing stack with open ai protocol.
  LLM_BASE_URL: "" # Set this to inferencing stack url when MODEL_RUNTIME is set to openai_protocol
  LLM_API_KEY: "" # Set this to inferencing stack url when LLM_API_KEY is set to openai_protocol
  WRAPPER_URL: ""
  WRAPPER_PASSWORD: "" # Set this to the desired wrapper password
  WRAPPER_USERNAME: "" # Set this to the desired wrapper username
  INGESTION_PASSWORD: "" # Set this to the desired client ingestion password
  INGESTION_URL: ""
  TENANT_ID: ""
```
> **Note:** The `wxa4z-watsonx-credentials` secret is automatically created in the tenant namespace when the tenant is created. To update any environment variable values, modify this secret in the tenant namespace.

### Create Agent-Specific Secret (required for each agent)

Before deploying an agent with the `AgentService` custom resource, you must create any  agent-specific secret required in the tenant namespace. 


> **Important:** Each agent has its own set of required secret fields. Check the `secrets.data` section in the agent's `values.yaml` file (located in `agent-helm-charts/<agent-name>/values.yaml`) to determine which fields are required for that specific agent.

> **Note:** When creating secrets manually, ensure that `createSecret` is set to `false` in the agent's `values.yaml` file.

For example, in `agent-helm-charts/support-agent/values.yaml`:

```yaml
secrets:
  name: wxa4z-support-agent-agent-secrets
  createSecret: true
  data:
    # CPD USERNAME,  Needed for on-prem only.(set it to empty for cloud)
    CPD_USERNAME: cpadmin
    # Set this to CPD API Key for On-prem Deployments, For ibm cloud use ibm cloud IAM API key
    WATSONX_API_KEY: ""
    # External App Credential specific to tls-agent
    AAP_ENDPOINT: ""
    AAP_USERNAME: ""
    AAP_PASSWORD: ""
    SEND_DUMP_TRANSFER_ID: ""
    SEND_DUMP_TRANSFER_PASSWORD: ""
    # This is the auth token for communication with agent
    AGENT_AUTH_TOKEN: ""
    LANGFUSE_SECRET_KEY: "LANGFUSE_SECRET_KEY"
    LANGFUSE_PUBLIC_KEY: "LANGFUSE_PUBLIC_KEY"
    LLM_BASE_URL: ""
    LLM_API_KEY: ""
```

> **Note:** The secret name is referenced in the `AgentService` CR under `spec.values.secrets.name`. Ensure the secret exists before applying the CR, or the agent deployment will fail.

**Example: Support Agent Secret**

```yaml
apiVersion: v1
kind: Secret
metadata:
  name: wxa4z-support-agent-agent-secrets
  namespace: <tenant-namespace>
type: Opaque
stringData:
  CPD_USERNAME: "cpadmin"
  WATSONX_API_KEY: "<your-watsonx-api-key>"
  AAP_ENDPOINT: "<ansible-automation-platform-endpoint>"
  AAP_USERNAME: "<aap-username>"
  AAP_PASSWORD: "<aap-password>"
  SEND_DUMP_TRANSFER_ID: "<transfer-id>"
  SEND_DUMP_TRANSFER_PASSWORD: "<transfer-password>"
  AGENT_AUTH_TOKEN: "<agent-auth-token>"
  LANGFUSE_SECRET_KEY: "<langfuse-secret-key>"
  LANGFUSE_PUBLIC_KEY: "<langfuse-public-key>"
  LLM_BASE_URL: "<llm-base-url>"
  LLM_API_KEY: "<llm-api-key>"
```

> **Tip:** Use `stringData` for plain text values (Kubernetes will automatically base64 encode them). Replace all placeholder values (enclosed in `< >`) with your actual configuration values.

### Create and Push Helm Chart Package

Before applying the `AgentService` custom resource, package the agent Helm chart and push it to the container registry.

#### Package the Helm chart

Navigate to the agent chart directory and create the Helm package:

```bash
cd agent-helm-charts/<agent-name>
helm package .
```

This creates a tar.gz file named `<agent-name>-<chart-version>.tgz` in the current directory.

#### Push the Helm chart to the registry

Push the packaged Helm chart to your OCI-compliant container registry. For example, to push to IBM Container Registry (ICR):

```bash
helm push <agent-name>-<chart-version>.tgz oci://icr.io/wxa4z-dev-container-registry
```

> **Note:** Ensure you are authenticated to the container registry before pushing. Use `helm registry login` if needed.

---

## Apply Resources

Use `oc apply` to create the resources after updating the values for your environment.

### Apply the secret

```bash
oc apply -f global-secret.yaml
```

> **Tip:** Store these manifests as separate files if you want to manage them independently across environments.


---

## Sample AgentService Custom Resource

Use the following sample `AgentService` custom resource to deploy agents.

#### YAML File for Agent Service Configuration

```yaml
apiVersion: wxa4z.watsonx.ibm.com/v1alpha1
kind: AgentService
metadata:
  name: <agent-service-cr-name> # eg: upgrade-agent-test
  namespace: <tenant-namespace>
  labels:
    wxa4z.watsonx.ibm.com/managed-by: agent-operator

spec:
  releaseName: <release-name>
  tenantId: <tenant-id>
  namespace: <tenant-namespace>
  wxa4z-core-services-namespace: wxa4z-zad # namespace in which the opensearch-client, authorization etc are deployed

  agentDetails:
    - agentName: <agent-name-1>
      agentId: wxa4z:<agent-name-1>:agent
      displayName: <agent display name>
      description: <agent description>
      bootstrapConfig:
        name: <name of the bootstrap configmap for this agent as available in the templates folder>
        fileName: <name of the file containing the bootstrap config>

  chart:
    repository: <repository name where the helm tar.gz has been pushed> # (oci://icr.io/wxa4z-dev-container-registry)
    name: <name for the agent helm tar.gz> # (upgrade-agent)
    version: <version of the helm tar.gz>
    pullSecrets: # if not mentioned in CR, by default will search in the secret - pull-secret
      - name: pull-secret # the name of the secret containing the credentials for the image repo of the agent so that the tar.gz can be pulled

  values:
    replicaCount: 1

    global:
      secrets:
        name: wxa4z-watsonx-credentials # this should be provided in the CR so that the global variables can be referenced

    secrets:
      name: <agent-secrets> # upgrade-agent-secrets (this secret is about each agent)

    env: # below are samples of configurable environment variables
      HOST_NAME: "apps.wxa4z311-cpd530-x86-qa.cp.fyre.ibm.com"
```


---

> **Note:** Each tenant needs connection and model gateway configuration.