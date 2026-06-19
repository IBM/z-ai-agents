# IBM CICS Transaction Server agents for Z Helm Chart

## Overview
The IBM CICS Transaction Server agents for Z (CICS agent) can answer questions about CICS topology and assist with problem determination when given transaction error codes. It provides targeted responses to questions, drawing on a variety of data sources to deliver context-aware guidance, best practice recommendations, and actionable next steps.

The CICS agent provides the following agents:
- CICS topology agent.
- CICS problem determination agent.
- CICS tool calling agent.
- CICS followup agent.
- CICS routing agent(installed as part of the watsonx Assistant for Z set up).

For information about CICS TS for z/OS, see https://www.ibm.com/docs/en/cics-ts/6.x

## Agents capabilities

| Agents capability       |            Description                  |
|------------------------------|-----------------------------------|
**CICS topology agent**
Topology Support        | Answers questions about CICS TS by using various data sources, including information from subject matter experts (SMEs) and IBM product documentation. By providing understanding, recommendations, and best practices, it helps users to gain clarity and to make informed configuration and management decisions effectively.
SME interview data |Insights from IBM CICS subject matter experts to enhance accuracy and clarify complex behavior. It embeds best practices into responses to ensure that recommendations are grounded in real-world experience.
Z RAG Capabilities| Answers topology-related queries by using ingested IBM documentation from Z RAG, to provide clear, accurate, and structured insights into the CICS system setup and configuration.
Ranks Documentation | To improve relevance, prioritizes and ranks documents based on how well they match the user's query.
**CICS problem determination agent**
Problem determination Support |  Helps to diagnose issues in the user's CICS system by using various data sources, including live system data and IBM product documentation. It explains error codes (for example, DFHAC messages), identifies likely causes, and recommends next steps that are tailored to the user’s environment.
Z RAG Capabilities| Uses ingested IBM documentation from Z RAG to support problem determination.
Interacts with live CICS systems  | 	Executes read-only commands to retrieve real-time system data that supports analysis.
Tool Integration | Provides visibility into live CICS system behavior through MCP, including information about transaction and programs. This helps to maintain situational awareness and to support informed decision-making during investigations.
Extracts DFHAC message | Parses and interprets DFHAC error messages to support troubleshooting.
Adaptive response strategy | Dynamically responds using live system data when this data is available, or falls back to static documentation when it is not, depending on server availability.
**CICS tool calling agent**
Live System Queries | Executes targeted queries against live CICS systems to retrieve real-time resource information, including programs, transactions, files, dynamic storage areas, and system parameters.
MCP Tool Integration | Leverages MCP (Model Context Protocol) tools to interact with CICS regions and CICSplexes, providing visibility into current system state and configuration.
Resource Parsing | Intelligently parses user queries to identify specific CICS resources and their IDs, then selects appropriate tools to retrieve the requested information.
Context-Aware Responses | Generates summaries of live data with explanations of field values and their implications, helping users understand the current state of their CICS environment.
Multi-Resource Support | Handles queries about multiple resources simultaneously, processing each resource and consolidating results into a comprehensive response.
**CICS followup agent**
Follow-up Question Handling | Processes follow-up questions by analyzing conversation history to resolve ambiguous references and maintain context across multi-turn conversations.
Relevance Checking | Validates that queries are CICS-related before processing, ensuring the agent stays focused on its domain expertise.
Documentation Retrieval | Uses RAG (Retrieval-Augmented Generation) to search and rank relevant CICS documentation based on user queries and conversation context.
Context Resolution | Resolves pronouns and implicit references (e.g., "it", "that value") by examining conversation history to identify specific CICS terms and concepts.
Intent-Aware Search | Classifies query intent (informational, clarification, troubleshooting, comparison) to optimize documentation search strategies.
**CICS routing agent**
Question routing | Identifies the theme of the user's query and directs it to the most appropriate agent, ensuring the question is handled by the agent best suited to resolve it.


## Prerequisites
Ensure the following:
- [IBM watsonx Assistant for Z](https://www.ibm.com/docs/en/watsonx/waz/2.0.0?topic=install-watsonx-assistant-z) is installed
- The minimum version of z/OSMF is 3.1
- The agents require a watsonx Project ID.
  - This should be used as WATSONX_PROJECT_ID as an environment variable.

Additionally, the CICS problem determination agent requires:
- CICS Transaction Server for z/OS version 6.3 or later, with APAR PH68212 applied.
- MCP server running in CICS. See [Configuring CICS MCP server](https://www.ibm.com/docs/en/cics-ts/6.x?topic=configuring-cics-mcp-server)
  - **Important**: The MCP_SERVER_URL must include the full endpoint path with toolbox suffix. Format: `http://<hostname>:<port>/mcp/<toolbox>/shttp`
    - For developer functions: `/mcp/developer/shttp`
    - For system programmer functions: `/mcp/sysprog/shttp`
    - For all tools: `/mcp/allTools/shttp`
  - Example: `http://z1.pok.stglabs.ibm.com:3006/mcp/allTools/shttp`
  - Visit `http://<hostname>:<port>/mcp/` to see the MCP Server landing page with available endpoints
  - To list all the available toolboxes, visit http://hostname:port/mcp/ 

Optionally, to validate container signatures, `skopeo` and `gpg`.

## Optional: Verify container signatures

You will need [skopeo](https://github.com/containers/skopeo>) installed to validate signatures. You will also need `gpg` installed.

> The CICS agent is deployed as a single unified container image that provides all agent capabilities (topology, problem determination, tool calling and followup questions).

#### Step 1: Importing the Key
This directory contains a file named `pubkey.asc`. To verify the signature, install this GPG Public Key into your local keyring.

First run: `gpg --import ./public_key.asc` to import the public key. You should see something like:

```
gpg: key F884D56B4AA7091A: public key "IBM CICS Transaction Server agents for Z <psirt@us.ibm.com>" imported
gpg: Total number processed: 1
gpg:               imported: 1
```

Now run `export FINGERPRINT=$(gpg --fingerprint --with-colons | grep fpr | tr -d 'fpr:')`
<br>

#### Step 2: Extracting the container

Sign in to skopeo so the container can be pulled with `skopeo login --username <USERNAME> --password <PASSWORD_OR_TOKEN> icr.io`.

Copy the container image to a temporary directory with `skopeo copy docker://icr.io/ibm-cics-ts/cics-orchestrated-agent-v1.3.0:latest dir:./tmp/`.
  
This copies blobs, manifests and signatures from the container into the `tmp` directory. The signature will usually be something like `signature-1`.
<br>

#### Step 3: Validating the signature

You can now verify the signature. Run `skopeo standalone-verify ./tmp/manifest.json icr.io/ibm-cics-ts/cics-orchestrated-agent-v1.3.0:latest $FINGERPRINT ./tmp/signature-1`

You should see output like this:
```Signature verified using fingerprint B83574F1F039B21CDCC4FD5FF884D56B4AA7091A, digest sha256:f2f11696e64395b79a9f5e31b91bae4f8c802ae1548ffd831067b3eb3ed1f077```

If you see something else, such as an error, check the image was downloaded from a trusted source. An example of an incorrect signature verification would be:

```FATA[0000] Error verifying signature: Signature by B83574F1F039B21CDCC4FD5FF884D56B4AA7091A does not match expected fingerprints [B83574F1F039B21CDCC4FD5FF884D56B4AA7091B]```

You can repeat this process for the other signature files in the `tmp` folder if multiple signatures are present.

> Remember to clear the folder `tmp` with `rm -rf ./tmp` after the image has been verified.

## Install the CICS Agent

### Retrieve the entitlement key

An entitlement key is required to download the IBM CICS Transaction Server agents for Z container images from the IBM Container Registry. This entitlement key is available at no charge to licensed users of IBM CICS Transaction Server for z/OS.

To obtain the entitlement key, open a case with IBM Support indicating that you are requesting the entitlement key for IBM CICS Transaction Server agents for Z. 

Once you have an entitlement key, paste it into the Helm chart under the `cics-agent` definitions like so:

```yaml
cics-agent:
  enabled: false
  acceptLicense: True  #IBM Terms - https://www.ibm.com/support/customer/csol/terms/?id=L-SSLZ-QYC4LH
  registry:
    name: cics-image-pull-secret
    createSecret: true
    server: icr.io
    username: iamapikey
    entitlementKey: "<CICS_ENTITLEMENT_KEY>"
```

## CICS Agent Configuration

The CICS agent is deployed as a single unified container that provides all agent capabilities (topology, problem determination, tool calling, and followup questions). This section describes how to configure the agent.

### Create Shared Variables

Some variables are common across all agents. To configure these shared variables, refer to [Create shared variables](https://github.com/IBM/z-ai-agents/blob/main/README.md#1-global-settings).
However, if any of these shared variables are also defined in your agent-specific [values.yaml](https://github.com/IBM/z-ai-agents/blob/main/wxa4z-agent-suite/values.yaml) file, the values that you specify in the values.yaml file will override the shared ones.

### Configure the values.yaml file

To enable the CICS agent, you need to configure agent-specific values in the [values.yaml](https://github.com/IBM/z-ai-agents/blob/main/wxa4z-agent-suite/values.yaml) file.

In the values.yaml file, scroll down to the CICS Agent section and update the keys as outlined in the following table.

| Key       |            Description                  |
|------------------------------|-----------------------------------|
**Environment variables**
WATSONX_MODEL_ID | Default model to use in LLM calls.
MODEL_CATALOG_PATH | File path to the YAML configuration file.
MCP_SERVER_URL | Full URL endpoint for the MCP Server within CICS, including toolbox suffix (e.g., `http://hostname:port/mcp/allTools/shttp`). See Prerequisites section for details on endpoint format.
APPLID| The VTAM Generic APPLID for the target CICS system that hosts the MCP Server
MODEL_RUNTIME | Runtime environment for the model (e.g., "openai_protocol").
ORCHESTRATE_STYLE | Orchestration style for the agent (e.g., "react").
**Secrets**
WATSONX_API_KEY| Your watsonx API key.
WRAPPER_USERNAME| The username for the Z RAG instance in your cluster.
WRAPPER_PASSWORD| The password for the Z RAG instance in your cluster.
WRAPPER_URL| The URL for the Z RAG instance in your cluster.
INGESTION_URL| Endpoint URL for the data ingestion.
INGESTION_PASSWORD| Password that is used to authenticate with the ingestion service.
AGENT_ID| Unique identifier for the Agent instance, used to distinguish it within the watsonx Orchestrate.
AGENT_AUTH_SERVICE_KEY | Authorization key used to authenticate with the wxa4z authorization service (not the CPD API key).
WATSONX_PROJECT_URL| Your watsonx URL.
WATSONX_PROJECT_ID| Identifier for your watsonx Project ID.
SERVICE_ENDPOINT | Service endpoint URL for agent registration.
> DO NOT CHANGE VALUES IN `secrets` SECTION of  `values.yaml`

### Self signed certificates

If you are connecting to services that use self-signed certificates (such as Z RAG or MCP server), the agent will not communicate with those services without first providing it with the certificates to validate all requests.

You will need your endpoints certificates content, which you need to put into `values.yaml` - into the `cicsCertSecret` section, replacing the content already there. **Make sure never to commit or add this certificate to version control.**

If you require more than one certificate, you can use a Terminal to concatenate multiple certificates into a single block of text data. To do so, run `cat cert1.crt cert2.crt > combined.crt`, replacing the first two `.crt` files with your own certificates. You will also need to ensure new lines are between the certificates `-----BEGIN CERTIFICATE-----` blocks. You are looking for something that looks like:
```
-----BEGIN CERTIFICATE-----
ENCODED DATA IN HERE
-----END CERTIFICATE-----
-----BEGIN CERTIFICATE-----
ENCODED DATA IN HERE
-----END CERTIFICATE-----
```

This can then be added to the correct value in `values.yaml` inside the `cics-agent` folder.


### Install or upgrade the wxa4z-agent-suite

> <div class="note note"><span class="notetitle">Note:</span> If you're installing multiple agents, you can configure the <a href="https://github.com/IBM/z-ai-agents/blob/main/wxa4z-agent-suite/values.yaml">values.yaml</a> file for all the agents you wish to install. After the file is updated, run the command below to install them all at once.</div>

Use the following command to install or upgrade the wxa4z_agent_suite:

```yaml
helm upgrade --install wxa4z-agent-suite \
  ./wxa4z-agent-suite \
  -n <wxa4z-namespace> \
  -f <path_to>/values.yaml --wait
```

> Ensure there are no extra lines or white space between certificates and avoid adding white space after the last certificate.
### Custom Resource (CR) Configuration

The CICS Agent can be deployed using a Custom Resource (CR) definition. The CR provides a declarative way to manage the agent deployment through the agent operator.

#### Prerequisites for CR Deployment

Before deploying the agent using the CR, ensure:

1. The agent operator is installed and running in your cluster
2. You have created the required secrets (see Secret Configuration below)
3. The target namespace exists
4. CICS Transaction Server for z/OS version 6.3 or later is available (for problem determination capabilities)
5. MCP server is configured in CICS (for problem determination and tool calling capabilities)

#### CR Structure Overview

The Custom Resource consists of the following main sections:

- **metadata**: Identifies the agent and its namespace
- **spec.agentDetails**: Defines agent-specific configuration and bootstrap settings
- **spec.chart**: Specifies the Helm chart location and version
- **spec.values**: Contains deployment values including environment variables and secret references

#### CR Reference

Below is the complete Custom Resource definition for the unified CICS Agent. Update the placeholder values according to your environment:

```yaml
apiVersion: wxa4z.watsonx.ibm.com/v1alpha1
kind: AgentService
metadata:
  name: cics-agent
  namespace: ""  # REQUIRED: Target namespace (e.g., wxa4z-agents)
  labels:
    wxa4z.watsonx.ibm.com/managed-by: agent-operator

spec:
  releaseName: cics-agent
  namespace: ""  # REQUIRED: Must match metadata.namespace
  tenantId: ""  # REQUIRED: Tenant identifier for multi-tenancy support
  wxa4z-core-services-namespace: wxa4z-zad  # Namespace where wxa4z core services are deployed

  agentDetails:
    - agentName: cics-agent
      agentId: wxa4z:cics-agent:agent
      displayName: IBM CICS Transaction Server agents for Z
      description: 'The CICS (Customer Information Control System) Transaction Server agent can take queries about CICS concepts, such as topologies and also provide problem determination assistance for transaction error codes.'
      bootstrapConfig:
        name: "cics-agent-bootstrap-config"
        fileName: cics_agent_bootstrap_config.yaml

  chart:
    repository: oci://icr.io/wxa4z-dev-container-registry
    name: cics-agent
    version: 1.3.0
    # pullSecrets:
    #   - name: pull-secret

  values:
    replicaCount: 1

    global:
      secrets:
        name: wxa4z-watsonx-credentials  # Global secrets shared across agents

    secrets:
      name: wxa4z-cics-agent-secrets  # Agent-specific secrets

    env:
      # LLM Configuration
      WATSONX_MODEL_ID: "meta-llama/llama-3-3-70b-instruct"
      MODEL_RUNTIME: "cloud"
      
      # Add other environment variables as needed for your deployment
```

#### Applying the CR

1. Save the CR configuration to a file (e.g., `cics-agent-cr.yaml`) or use the provided `cr.yaml` file
2. Update all placeholder values marked as `REQUIRED`
3. Apply the CR to your cluster:

```bash
oc apply -f cics-agent-cr.yaml
```

4. Verify the deployment:

```bash
# Check CR status
oc get agentservice cics-agent -n <namespace>

# Check agent pods
oc get pods -n <namespace> -l app=cics-agent

# View agent logs
oc logs -n <namespace> -l app=cics-agent --tail=100
```

#### Secret Configuration

The agent requires Kubernetes Secrets containing sensitive configuration values. **Never commit secrets to version control.**

##### Secret Types

The agent uses two types of secrets:

1. **Global Secrets** (`wxa4z-watsonx-credentials`): Shared across all agents
2. **Agent-Specific Secrets** (`wxa4z-cics-agent-secrets`): Unique to this agent

##### Agent-Specific Secret Reference

Create a secret with the following structure. **All values must be base64-encoded.**

```yaml
apiVersion: v1
kind: Secret
metadata:
  name: wxa4z-cics-agent-secrets
  namespace: ""  # REQUIRED: Must match the agent namespace
type: Opaque
data:
  # MCP Configuration (base64-encoded, REQUIRED for problem determination and tool calling capabilities)
  MCP_SERVER_URL: ""  # REQUIRED: Full MCP Server URL with toolbox suffix (e.g., http://hostname:port/mcp/allTools/shttp or https://hostname:port/mcp/sysprog/shttp)
  APPLID: ""  # REQUIRED: VTAM Generic APPLID for target CICS system
  
  # Z RAG Configuration (base64-encoded, REQUIRED for topology, problem determination, and followup capabilities)
  WRAPPER_USERNAME: ""  # REQUIRED: Username for Z RAG instance
  WRAPPER_PASSWORD: ""  # REQUIRED: Password for Z RAG instance
  WRAPPER_URL: ""  # REQUIRED: URL for Z RAG instance
  
  # Agent Registration (base64-encoded, REQUIRED)
  AGENT_ID: ""  # REQUIRED: Unique identifier for the agent (e.g., "wxa4z:cics:agent")
  AGENT_AUTH_SERVICE_KEY: ""  # REQUIRED: Authorization key for wxa4z authorization service authentication
  SERVICE_ENDPOINT: ""  # REQUIRED: Service endpoint URL for agent registration
  AUTH_SERVICE_BASE_URL: ""  # REQUIRED: Base URL for authentication service
  AGENT_AUTH_TOKEN: ""  # REQUIRED: Authentication token for the agent
  
  # Watsonx Configuration (base64-encoded, REQUIRED)
  WATSONX_PROJECT_URL: ""  # REQUIRED: Watsonx project URL
  WATSONX_PROJECT_ID: ""  # REQUIRED: Watsonx project ID
```

**Important:**
- All secret values must be base64-encoded before adding to the secret
- The CICS entitlement key is required and can be obtained from IBM Support
- MCP configuration is required for problem determination and tool calling capabilities
- Z RAG configuration is required for topology and problem determination capabilities
- All agent registration fields are required for proper integration with watsonx Orchestrate

##### Creating the Secret

Apply the secret:

```bash
oc apply -f secret.yaml
```


### Install or upgrade the wxa4z-agent-suite

> <div class="note note"><span class="notetitle">Note:</span> If you're installing multiple agents, you can configure the <a href="https://github.com/IBM/z-ai-agents/blob/main/wxa4z-agent-suite/values.yaml">values.yaml</a> file for all the agents you wish to install. After the file is updated, run the command below to install them all at once.</div>

Use the following command to install or upgrade the wxa4z_agent_suite:

```yaml
helm upgrade --install wxa4z-agent-suite \
  ./wxa4z-agent-suite \
  -n <wxa4z-namespace> \
  -f <path_to>/values.yaml --wait
```

## Deploy the agent

1. Log in to IBM watsonx Orchestrate.
2. From the main menu, navigate to **Build** > **Agent Builder**.
3. Select the **IBM CICS Transaction Server agents for Z** tile.
4. In the AI Assistant window, enter a query to confirm that the response aligns with your expectations.
5. Click **Deploy** to activate the agent and make it available in the live environment.

## Test your agent

After deployment, the agent becomes active and is available for selection in the live environment. The CICS agent provides all capabilities including topology, problem determination, tool calling, and followup questions functionality.

1. From the main menu, click **Chat**.
2. Choose your agent from the list.
3. Enter your queries using the AI Assistant. The agent can handle various types of queries:

   **Topology queries:**
    - How do I configure CICS regions for high availability?
    - Should I use a single CICS region for all my applications?

   **Problem determination queries:**
    - Can you guide me through debugging a DFHAC2001 error in CICS? On transaction [_transaction ID_]?
    - I am getting DFHAC2010 on [_transaction ID_] transaction ID?

   **Tool calling queries:**
    - What is the status of program PROG1?
    - Tell me about transaction TXN1 in region REGION1 in plex PLEX1
    - Give me information on DSA CDSA

   **Followup queries:**
    - Tell me more about that routing value
    - Tell me more about that dynamic thing
    - Can you tell me a bit more about why those fields would be blank

   Responses are displayed either in a tabular format or as a sentence, depending on the context.

4. Verify that the responses returned by the AI Assistant are accurate.
