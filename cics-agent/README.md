# IBM CICS Transaction Server agents for Z Helm Chart

## Overview
The IBM CICS Transaction Server agents for Z (CICS agent) can answer questions about CICS topology and assist with problem determination when given transaction error codes. It provides targeted responses to questions, drawing on a variety of data sources to deliver context-aware guidance, best practice recommendations, and actionable next steps.

The CICS agent provides the following agents:
- CICS topology agent.
- CICS problem determination agent.
- CICS tool calling agent.

For information about CICS TS for z/OS, see https://www.ibm.com/docs/en/cics-ts/6.x

## Agents capabilities

### CICS topology agent

| Agent capability | Description |
|------------------|-------------|
| Topology Support | Answers questions about CICS TS by using various data sources, including information from subject matter experts (SMEs) and IBM product documentation. By providing understanding, recommendations, and best practices, it helps users to gain clarity and to make informed configuration and management decisions effectively. |
| SME interview data | Insights from IBM CICS subject matter experts to enhance accuracy and clarify complex behavior. It embeds best practices into responses to ensure that recommendations are grounded in real-world experience. |
| Z RAG Capabilities | Answers topology-related queries by using ingested IBM documentation from Z RAG, to provide clear, accurate, and structured insights into the CICS system setup and configuration. |
| Ranks Documentation | To improve relevance, prioritizes and ranks documents based on how well they match the user's query. |

### CICS problem determination agent

| Agent capability | Description |
|------------------|-------------|
| Problem determination Support | Helps to diagnose issues in the user's CICS system by using various data sources, including live system data and IBM product documentation. It explains error codes (for example, DFH messages), identifies likely causes, and recommends next steps that are tailored to the user's environment. |
| Z RAG Capabilities | Uses ingested IBM documentation from Z RAG to support problem determination. |
| Interacts with live CICS systems | Executes read-only commands to retrieve real-time system data that supports analysis. |
| Tool Integration | Provides visibility into live CICS system behavior through MCP, including information about transaction and programs. This helps to maintain situational awareness and to support informed decision-making during investigations. |
| Extracts DFH messages | Parses and interprets DFH error messages to support troubleshooting. |
| Adaptive response strategy | Dynamically responds using live system data when this data is available, or falls back to static documentation when it is not, depending on server availability. |

### CICS tool calling agent

| Agent capability | Description |
|------------------|-------------|
| Live System Queries | Executes targeted queries against live CICS systems to retrieve real-time resource information, including programs, transactions, files, dynamic storage areas, and system parameters. |
| MCP Tool Integration | Leverages MCP (Model Context Protocol) tools to interact with CICS regions and CICSplexes, providing visibility into current system state and configuration. |
| Resource Parsing | Intelligently parses user queries to identify specific CICS resources and their IDs, then selects appropriate tools to retrieve the requested information. |
| Context-Aware Responses | Generates summaries of live data with explanations of field values and their implications, helping users understand the current state of their CICS environment. |
| Multi-Resource Support | Handles queries about multiple resources simultaneously, processing each resource and consolidating results into a comprehensive response. |

## Prerequisites
Ensure the following:
- [IBM watsonx Assistant for Z](https://www.ibm.com/docs/en/watsonx/waz/2.0.0?topic=install-watsonx-assistant-z) is installed
- The minimum version of z/OSMF is 3.1

Additionally, the CICS agent requires:
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

The entitlement key is contained within the Bill of Materials PDF, hosted in Shopz as part of your CICS TS materials.

Once you have an entitlement key, create a image-pull secret file in following way:

```
oc create secret docker-registry cics-image-pull-secret \
  --docker-server=icr.io \
  --docker-username=iamapikey \
  --docker-password=<CICS_ENTITLEMENT_KEY> \
  --namespace=<namespace> \
  --dry-run=client -o yaml > cics-image-pull-secret.yaml
```

Apply the secret:
```
oc apply -f cics-image-pull-secret.yaml
```

Verify the secret was created:
```
oc get secret cics-image-pull-secret -n <namespace>
```

## CICS Agent Configuration

The CICS agent is deployed as a single unified container that provides all agent capabilities (topology, problem determination, tool calling, and followup questions). This section describes how to configure the agent.

### Secret Configuration

The agent requires Kubernetes Secrets containing sensitive configuration values. **Never commit secrets to version control.**

#### Secret Types

The agent uses two types of secrets:

1. **Global Secrets** (`wxa4z-watsonx-credentials`): Shared across all agents. For the full list of variables and how to configure them, refer to [Create shared variables](https://github.com/IBM/z-ai-agents/blob/main/README.md#1-global-settings).
2. **Agent-Specific Secrets** (`wxa4z-cics-agent-secrets`): Unique to this agent

#### Agent-Specific Secret Reference

The following table describes the fields required in the agent-specific secret:

| Key | Description |
|-----|-------------|
| `MCP_SERVER_URL` | Full URL endpoint for the MCP Server within CICS, including toolbox suffix (e.g., `http://hostname:port/mcp/allTools/shttp`). See Prerequisites section for details on endpoint format. |
| `APPLID` | The VTAM Generic APPLID for the target CICS system that hosts the MCP Server. |
| `AGENT_ID` | Unique identifier for this agent instance (e.g., `wxa4z:cics-agent:agent`), used to distinguish it within watsonx Orchestrate. |
| `SERVICE_ENDPOINT` | The agent's backend/service URL — where registration or service calls for this agent are sent. |
| `AUTH_SERVICE_BASE_URL` | The authentication server base URL — where the wxa4z auth service is reached to validate agent tokens. To obtain this value, copy `AUTH_SERVICE_BASE_URL` from the `wxa4z-authorization-secrets` resource in your cluster. |
| `AGENT_AUTH_TOKEN` | Token used by the agent-controller to register this agent with watsonx Orchestrate. Use a CPD API key of your watsonx project for on-prem clusters, or a watsonx API key for cloud. See [Generating API keys](https://www.ibm.com/docs/en/cloud-paks/cp-data/5.4.x?topic=tutorials-generating-api-keys). |
| `WATSONX_PROJECT_URL` | URL of your watsonx.ai project endpoint. For SaaS: regional endpoint (e.g., `https://us-south.ml.cloud.ibm.com`). For on-prem CPD: your CPD instance FQDN. Found in your watsonx.ai project settings under API details. |
| `LANGFUSE_SECRET_KEY` | (Optional) Langfuse secret key (e.g., `sk-lf-xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx`). Required only for Langfuse observability and traceability. |
| `LANGFUSE_PUBLIC_KEY` | (Optional) Langfuse public key (e.g., `pk-lf-xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx`). Required only for Langfuse observability and traceability. |

Create agent-specific secret with the following structure. **All values must be base64-encoded.**

```yaml
apiVersion: v1
kind: Secret
metadata:
  name: wxa4z-cics-agent-secrets
  namespace: ""  # REQUIRED: Must match the agent namespace
type: Opaque
data:
  # MCP Configuration (REQUIRED for problem determination and tool calling capabilities)
  MCP_SERVER_URL: ""  # REQUIRED: Full MCP Server URL with toolbox suffix
                       # (e.g., http://hostname:port/mcp/allTools/shttp)
  APPLID: ""  # REQUIRED: VTAM Generic APPLID for the target CICS system

  # Agent Registration (REQUIRED)
  # The following values are unique to this agent and must be set here.
  AGENT_ID: ""  # REQUIRED: Unique identifier for this agent instance (e.g., "wxa4z:cics-agent:agent"),
                # used to distinguish it within watsonx Orchestrate.
  SERVICE_ENDPOINT: ""  # REQUIRED: The agent's backend/service URL — where registration or
                         # service calls for this agent are sent.
  AUTH_SERVICE_BASE_URL: ""  # REQUIRED: The authentication server base URL — where the wxa4z
                              # auth service is reached to validate agent tokens.
                              # To obtain this value, copy AUTH_SERVICE_BASE_URL from the
                              # wxa4z-authorization-secrets resource in your cluster.
  AGENT_AUTH_TOKEN: ""  # REQUIRED: Token used by the agent-controller to register this agent
                         # with watsonx Orchestrate. Use a CPD API key of your watsonx project
                         # for on-prem clusters, or a watsonx API key for cloud.
                         # See: https://www.ibm.com/docs/en/cloud-paks/cp-data/5.4.x?topic=tutorials-generating-api-keys

  # Watsonx Configuration (REQUIRED)
  # Note: WATSONX_PROJECT_ID is read from the global wxa4z-watsonx-credentials secret, not here.
  WATSONX_PROJECT_URL: ""  # REQUIRED: URL of your watsonx.ai project endpoint.
                            # For SaaS: regional endpoint (e.g., https://us-south.ml.cloud.ibm.com).
                            # For on-prem CPD: your CPD instance FQDN.
                            # Found in your watsonx.ai project settings under API details.

  # Langfuse Observability (OPTIONAL — required only for traceability)
  LANGFUSE_SECRET_KEY: ""  # OPTIONAL: Langfuse secret key (e.g., sk-lf-xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx).
                            # Required only for Langfuse observability and traceability.
  LANGFUSE_PUBLIC_KEY: ""  # OPTIONAL: Langfuse public key (e.g., pk-lf-xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx).
                            # Required only for Langfuse observability and traceability.

  # The following keys are NOT set here — they are read from other secrets automatically:
  #
  # From global wxa4z-watsonx-credentials secret:
  #   WRAPPER_USERNAME, WRAPPER_PASSWORD, WRAPPER_URL  (Z RAG credentials)
  #   INGESTION_URL, INGESTION_PASSWORD                (ingestion service credentials)
  #   WATSONX_PROJECT_ID                               (watsonx project identifier)
  #
  # From wxa4z-authorization-secrets secret:
  #   AGENT_AUTH_SERVICE_KEY  (read as CICS_AGENT_TOKEN)
```

#### Creating the Secret

Apply the secret:

```bash
oc apply -f secret.yaml
```

### Self signed certificates

This section applies only if any of the services the agent connects to — such as your Z RAG server, WxA Endpoint, or CMCI — have been configured to use self-signed certificates. When CMCI (or another service) is configured to use SSL with a self-signed certificate, the agent needs a copy of that service's public certificate to validate the trust chain during the SSL handshake. This is not a user or agent identity certificate — it is used solely to verify the server's certificate when establishing a secure connection.

Without providing these certificates, the agent will not be able to communicate with the affected services.

For background on how CMCI uses SSL and how clients authenticate, refer to:
- [Configuring CICS to use SSL](https://www.ibm.com/docs/en/cics-ts/6.x?topic=layers-configuring-cics-use-ssl)
- [CMCI security features: How CMCI authenticates clients](https://www.ibm.com/docs/en/cics-ts/6.x?topic=cmci-security-features-how-authenticates-clients)

To obtain the public certificate, export it from the SSL configuration of the service.

For OpenShift-hosted services, you can retrieve it from the serving secret in the service's namespace:

```bash
oc get secret <service-tls-secret> -n <namespace> -o jsonpath='{.data.tls\.crt}' | base64 --decode > service.crt
```

For the CICS MCP Server, you can retrieve this with:

```bash
echo quit | openssl s_client -showcerts -servername "$HOST" -connect "$HOST:$PORT" > "certs/$CA.pem"
```

Where `$HOST` and `$PORT` refer to the values that form your `MCP_SERVER_URL`.

Once you have the certificate file, update the certificate secret using the following commands:

Encode the certificate to base64 and remove newlines
```bash
CERT_BASE64=$(cat /path/to/cert.crt | base64 | tr -d '\n')
```

Update the certificate in the secret
```bash
oc patch secret cics-custom-cert-secret -n <namespace> \
  --type='merge' \
  -p='{"data":{"cert.crt":"'"${CERT_BASE64}"'"}}'
```

If you require more than one certificate, you can use a Terminal to concatenate multiple certificates into a single block of text data. To do so, run `cat cert1.crt cert2.crt > combined.crt`, replacing the first two `.crt` files with your own certificates. You will also need to ensure new lines are between the certificates `-----BEGIN CERTIFICATE-----` blocks. You are looking for something that looks like:
```
-----BEGIN CERTIFICATE-----
ENCODED DATA IN HERE
-----END CERTIFICATE-----
-----BEGIN CERTIFICATE-----
ENCODED DATA IN HERE
-----END CERTIFICATE-----
```

You can then run the above commands by pointing to the combined certificate file (`combined.crt`).

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

The complete Custom Resource definition is provided in [`cr.yaml`](./cr.yaml) in this directory. Update the placeholder values according to your environment before applying.

#### Applying the CR

1. Open [`cr.yaml`](./cr.yaml) and update all required placeholder values
2. Apply the CR to your cluster:

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
