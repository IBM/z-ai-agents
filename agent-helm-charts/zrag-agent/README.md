# zRAG Agent

## Overview
The zRAG Agent provides technical support for mainframe and enterprise systems through the Watson Assistant for Z chat interface. It leverages the zRAG (z/OS Retrieval-Augmented Generation) knowledge base to deliver accurate, citation-backed responses by integrating with IBM's documentation repositories and custom enterprise documentation.

## Agent capabilities

| Agent capability         |            Description                  |
|------------------------------|-----------------------------------|
| Document retrieval        | Queries the zRAG backend to fetch relevant technical documentation from IBM docs, Redbooks, and custom enterprise content    |
| Health monitoring | Performs health checks on the zRAG MCP server, returning server status and configuration information
| AI-powered answers with citations | Generates comprehensive, expert-level answers grounded in retrieved documentation with automatic inline citations and reference sections
| Compact responses for agents | Provides streamlined responses optimized for multi-turn agent conversations, reducing token usage by 80% while maintaining answer quality
| Streaming responses | Delivers real-time token-by-token generation for improved user experience
| Multi-source knowledge base | Searches across IBM product documentation, Redbooks, customer-specific docs, and agent documentation with configurable weights


## Architecture

The zRAG Agent consists of two primary components:

### 1. zRAG MCP Server
An MCP (Model Context Protocol) toolkit imported on Orchestrate that provides 4 specialized tools:
- **health_check**: Performs a health check on the zRAG MCP server. Returns server status, configuration information, and environment diagnostics
- **zrag_retriever**: Queries the zRAG retriever backend service to fetch relevant documents. All configuration parameters (search type, reranking, indices) are loaded from environment variables
- **zrag_chat**: Complete RAG pipeline with streaming generation and code-based citations. Returns verbose responses (~12k tokens) with comprehensive metadata including answer, sources, citations, performance metrics, and quality reports
- **zrag_chat_compact**: Optimized RAG tool for agents with minimal response size (~2k tokens, 80% smaller than zrag_chat). Returns only essential fields: answer with citations and cited documents

### 2. zRAG Native Agent
A native agent configured to use the MCP tools:
- Uses 2 MCP tools: **health_check** and **zrag_retriever**
- Streaming is enabled by default
- Built on React-style agent architecture for iterative reasoning
- Configured with **meta-llama/llama-3-3-70b-instruct** LLM

### Sequence Flow
1. User enters a query in the zRAG Agent chat interface
2. Orchestrate routes the query to the MCP tool (**zrag_retriever**)
3. **zrag_retriever** tool executes the retrieval logic against the OpenSearch backend and responds with the result set
4. Orchestrate uses this result and passes it to the LLM for answer generation
5. Answer is streamed back to the chat window with inline citations and source references


## Prerequisites
Ensure the following:

- [watsonx Assistant for Z](https://www.ibm.com/docs/watsonx/waz/3.2.0?topic=install-premises-watsonx-orchestrate-watsonx-assistant-z) is installed
- OpenSearch backend with zRAG wrapper service is deployed and accessible
- WatsonX AI endpoint is configured (either IBM Cloud SaaS or CPD on-premises)
- Knowledge base is ingested into OpenSearch with appropriate indices

## Install the zRAG Agent


### Retrieve the entitlement key

During the installation process of watsonx Assistant for Z, you would have acquired the entitlement key. However, if you need to retrieve it again, follow these steps:

1. Click the link to sign in to [My IBM](https://myibm.ibm.com/dashboard/).
2. Scroll down and locate the Container Software & Entitlement Keys tile, then click View Library.
3. Find your hidden key and click the Copy button next to it.
4. Set the global entitlement key using the watsonx Assistant for Z entitlement key:

```yaml
global:
  registry:
    name: wxa4z-image-pull-secret
    createSecret: true
    server: icr.io
    username: iamapikey
    entitlementKey: "<WATSONX_ASSISTANT_FOR_Z_ENTITLEMENT_KEY>"
```

### Create Shared Variables

Certain variables are common across all agents. To configure these shared variables, refer to [Create shared variables](https://github.com/IBM/z-ai-agents/blob/main/README.md#1-global-settings) (link to the global GitHub page).
However, if any of these shared variables are also defined in your agent-specific [values.yaml](https://github.com/IBM/z-ai-agents/blob/main/wxa4z-agent-suite/values.yaml) file, the values specified in the values.yaml file will override the shared ones.

### Configure the values.yaml file

To enable the zRAG Agent, you need to configure agent-specific values in the [values.yaml](https://github.com/IBM/z-ai-agents/blob/main/wxa4z-agent-suite/values.yaml) file.

In the values.yaml file, scroll down to the zRAG Agent section and update the keys as outlined in the following table.

| Key       |            Description                  |
|------------------------------|-----------------------------------|
**Environment variables - zRAG Backend Connection**                                                       |
ZRAG_RETRIEVER_URL | URL endpoint for the OpenSearch wrapper service. For example, "https://wxa4z-opensearch-wrapper.wxa4z-zad.svc.cluster.local:8080".
ZRAG_USERNAME | Username for authenticating with the zRAG retriever backend (Basic Auth).
ZRAG_PASSWORD | Password for authenticating with the zRAG retriever backend (Basic Auth).
**Environment variables - WatsonX AI Configuration (SaaS Mode - IBM Cloud)**                                                        |
WATSONX_ML_URL | WatsonX AI endpoint URL for SaaS deployment. For example, "https://us-south.ml.cloud.ibm.com".
WATSONX_API_KEY | IBM Cloud IAM API key for authenticating with WatsonX AI (SaaS mode).
WATSONX_DEPLOYMENT_SPACE_ID | Deployment space ID for WatsonX AI (SaaS mode).
**Environment variables - WatsonX AI Configuration (CPD Mode - On-Premises)**                                                        |
WATSONX_URL | WatsonX AI endpoint URL for CPD on-premises deployment. For example, "https://cpd-instance.company.com" (set via WATSONX_ML_URL in values.yaml).
CPD_USERNAME | Username for authenticating with CPD on-premises deployment. For example, "cpadmin".
WATSONX_PASSWORD | Password for authenticating with CPD on-premises deployment.
WATSONX_PROJECT_ID | Project ID for WatsonX AI (CPD mode).
WATSONX_VERSION | CPD version. For example, "5.2".
WATSONX_VERIFY_SSL | Set to "false" for self-signed certificates in CPD environments.
**Environment variables - Model Configuration**                                                        |
MODEL_ID | LLM model used by the zRAG MCP server for answer generation. Default: "ibm/granite-3-3-8b-instruct". Options include Granite 3.3 models or other WatsonX models.
MODEL_TEMPERATURE | Controls randomness of model outputs (0.0-1.0). Lower values produce more deterministic responses. Default: "0.4".
MODEL_MAX_TOKENS | Maximum number of tokens the model can generate per response. Default: "400" (capped at 450).
MODEL_TOP_K | Top-k sampling parameter (optional). Controls diversity by limiting to top k tokens.
**Environment variables - Search Configuration**                                                        |
ZRAG_DEFAULT_RERANK | Enable reranking of search results for improved relevance. Default: "true".
ZRAG_DEFAULT_SEARCH_TYPE | Search algorithm to use. Options: "keyword", "semantic", "fusion", "reranked_fusion". Default: "reranked_fusion".
ZRAG_DEFAULT_IBM_INDICES | Comma-separated list of IBM documentation indices to search. Default: "*_ibm_docs_slate,*_ibm_redbooks_slate".
**Environment variables - Citation Configuration**                                                        |
ENABLE_CODE_CITATIONS | Use code-based citation extraction (not LLM-based) for accuracy. Default: "true".
CITATION_MIN_SIMILARITY | Minimum phrase similarity threshold for matching citations (0.0-1.0). Default: "0.7".
CITATION_MIN_CONFIDENCE | Minimum confidence score for including citations (0.0-1.0). Default: "0.4".
**Environment variables - MCP Server Runtime**                                                        |
WXO_MCP_TRANSPORT | Transport mode for MCP server. Options: "stdio", "sse", "http". Default: "sse".
WXO_MCP_HOST | Bind address for the MCP server. Default: "0.0.0.0".
WXO_MCP_PORT | Port number for the MCP server. Default: "8000".
LOG_LEVEL | Logging verbosity level. Options: "DEBUG", "INFO", "WARNING", "ERROR". Default: "INFO".
**Secrets**
ZRAG_USERNAME | Username for accessing the zRAG retriever backend (also used as environment variable).
ZRAG_PASSWORD | Password for accessing the zRAG retriever backend (also used as environment variable).
WATSONX_API_KEY | IBM Cloud IAM API key for WatsonX AI (SaaS mode) or CPD API key (on-prem mode).
CPD_USERNAME | Username for CPD on-premises deployment (also used as environment variable).
WATSONX_PASSWORD | Password for CPD on-premises deployment (also used as environment variable).

### Install or upgrade the wxa4z-agent-suite

> **Note**: If you're installing multiple agents, you can configure the [values.yaml](https://github.com/IBM/z-ai-agents/blob/main/wxa4z-agent-suite/values.yaml) file for all the agents you wish to install. Once the file is updated, run the command below to install them all at once.


Use the following command to install or upgrade the wxa4z_agent_suite:

```yaml
helm upgrade --install wxa4z-agent-suite \
  ./wxa4z-agent-suite \
  -n <wxa4z-namespace> \
  -f <path_to>/values.yaml --wait
```

## Deploy the agent

1. Log in to watsonx Orchestrate.
2. From the main menu, navigate to **Build** > **Agent Builder**.
3. Select the **zRAG Agent** tile.
4. In the AI Assistant window, enter a query to confirm that the response aligns with your expectations.
5. Click **Deploy** to activate the agent and make it available in the live environment.


## Test the agent

After deployment, the agent becomes active and is available for selection in the live environment.

1. From the main menu, click **Chat**.
2. Choose **zRAG Agent** from the list.
3. Enter your queries using the AI Assistant.
   For example:

      - What is CICS Transaction Server?

      - How do I configure JCL for batch processing?

      - Explain VSAM file organization methods

      - What are the security features in RACF?

    Responses are displayed with comprehensive technical explanations, inline citations [1], [2], and a sources section with clickable documentation links.

4. Verify that the responses returned by the AI Assistant are accurate and include proper citations with relevance scores.

## Custom Search Configurations for zRAG Retriever

The zRAG retriever sends a structured JSON payload to the OpenSearch wrapper with two top-level configuration blocks -- `metadata` (controls search behavior) and `filter` (controls result filtering). These parameters are configured via **connection credentials** in watsonx Orchestrate and are resolved at runtime with the following priority:

```
HTTP headers (from Orchestrate connection credentials)  >  Environment variables (from Helm values.yaml)  >  Code defaults
```

This means any value set in Orchestrate connection credentials will override the corresponding environment variable set during Helm installation.

### Payload Structure

When the zRAG retriever tool is invoked, it constructs the following JSON payload to the OpenSearch wrapper:

```json
{
  "query": "user's search query",
  "metadata": {
    "rerank": true,
    "search_type": "reranked_fusion",
    "ibm_indices": "*_ibm_docs_slate,*_ibm_redbooks_slate",
    "customer_indices": "",
    "doc_weight": {
      "customer_docs": 0.5,
      "product_docs": 0.5,
      "agent_docs": 0.0
    },
    "dynamic_filtering": true
  },
  "filter": {
    "topics": {
      "enable": "",
      "disable": ""
    },
    "customer_indices": "customer_*",
    "ibm_indices": "",
    "agent_indices": "agent_*",
    "doc_weight": {
      "product_docs": 0.5,
      "customer_docs": 0.5,
      "agent_docs": 0.0
    }
  }
}
```

Every field in this payload is configurable through connection credentials (environment variables).

### Configuration Methods

#### Method 1: Using Orchestrate UI

Use the Orchestrate web interface to set connection credentials directly as key-value pairs. These credentials are passed as HTTP headers at runtime and take the highest priority.

1. Log in to **watsonx Orchestrate** and navigate to **Build** > **Connections** from the left sidebar.
2. Locate the connection associated with the zRAG MCP toolkit (for example, `zrag-mcp`).
3. Click on the connection name to open its details.
4. Select the **Credentials** tab.
5. Click **Edit** to open the credential editor.
6. Add or modify credentials as **key-value pairs**. Each key corresponds to an environment variable name, and the value is the desired setting. For example:

   | Key | Value |
   |-----|-------|
   | `ZRAG_DEFAULT_RERANK` | `true` |
   | `ZRAG_DEFAULT_SEARCH_TYPE` | `reranked_fusion` |
   | `ZRAG_DEFAULT_IBM_INDICES` | `*_ibm_docs_slate,*_ibm_redbooks_slate` |
   | `ZRAG_METADATA_PRODUCT_WEIGHT` | `0.7` |
   | `ZRAG_METADATA_CUSTOMER_WEIGHT` | `0.3` |
   | `ZRAG_TOPICS_ENABLE` | `cics,db2` |
   | `ZRAG_FILTER_CUSTOMER_INDICES` | `customer_*` |

7. Click **Done** to save.
8. Repeat for both **draft** and **live** environments if the agent is deployed to both.

> **Note**: Changes to connection credentials take effect immediately on the next tool invocation -- no server restart or redeployment is required. The MCP server reads these values from HTTP headers on every request.

#### Method 2: Using Orchestrate ADK CLI

The ADK (Agent Development Kit) CLI provides a programmatic way to manage connections and credentials. This is the recommended approach for automation, CI/CD pipelines, and reproducible configurations.

**Step 1: Create the connection** (one-time setup)

```bash
orchestrate connections add -a zrag-mcp
```

**Step 2: Configure the connection for each environment**

```bash
# Configure for draft environment
orchestrate connections configure \
  -a zrag-mcp \
  --env draft \
  --type team \
  --kind key_value

# Configure for live environment
orchestrate connections configure \
  -a zrag-mcp \
  --env live \
  --type team \
  --kind key_value
```

**Step 3: Set the credentials (backend connection + search configuration)**

```bash
orchestrate connections set-credentials \
  -a zrag-mcp \
  --env draft \
  -e "ZRAG_RETRIEVER_URL=https://wxa4z-opensearch-wrapper.wxa4z-zad.svc.cluster.local:8080" \
  -e "ZRAG_USERNAME=<username>" \
  -e "ZRAG_PASSWORD=<password>" \
  -e "ZRAG_DEFAULT_RERANK=true" \
  -e "ZRAG_DEFAULT_SEARCH_TYPE=reranked_fusion" \
  -e "ZRAG_DEFAULT_IBM_INDICES=*_ibm_docs_slate,*_ibm_redbooks_slate" \
  -e "ZRAG_DEFAULT_CUSTOMER_INDICES=" \
  -e "ZRAG_METADATA_PRODUCT_WEIGHT=0.5" \
  -e "ZRAG_METADATA_CUSTOMER_WEIGHT=0.5" \
  -e "ZRAG_METADATA_AGENT_WEIGHT=0.0" \
  -e "ZRAG_DEFAULT_DYNAMIC_FILTERING=true" \
  -e "ZRAG_TOPICS_ENABLE=" \
  -e "ZRAG_TOPICS_DISABLE=" \
  -e "ZRAG_FILTER_CUSTOMER_INDICES=customer_*" \
  -e "ZRAG_FILTER_IBM_INDICES=" \
  -e "ZRAG_FILTER_AGENT_INDICES=agent_*"
```

> **Tip**: You do not need to set every parameter. Only set the values you want to override -- all unset parameters fall back to their defaults (listed in the tables below).

**Step 4: Import the MCP toolkit**

```bash
orchestrate toolkits import \
  --kind mcp \
  --name zrag-retrieval \
  --description "zRAG retrieval and RAG tools" \
  --url "http://<mcp-server-host>:8000/sse" \
  --transport sse \
  --tools "*" \
  --app-id zrag-mcp
```

**Step 5: Deploy the agent**

```bash
orchestrate agents import -f deployment/agents/zrag_agent.yaml
```

**Step 6: Verify**

```bash
orchestrate toolkits list | grep zrag-retrieval
orchestrate agents list | grep zrag_agent
```

For a complete end-to-end walkthrough, refer to the [zRAG MCP deployment notebook](https://github.ibm.com/wxa4z/zrag-mcp-server/blob/main/deployment/zrag_mcp_deployment_notebook.ipynb).

### Credential-to-Payload Mapping Reference

The following tables show the exact mapping between the environment variable name (used in connection credentials) and the field it controls in the retrieval payload.

#### Metadata Parameters (Search Behavior)

These parameters control how the search is executed against the OpenSearch backend.

| Credential Key (Environment Variable) | Payload Field | Type | Default | Description |
|---------------------------------------|---------------|------|---------|-------------|
| `ZRAG_DEFAULT_RERANK` | `metadata.rerank` | boolean | `true` | Enable reranking of search results using a cross-encoder model for improved relevance. |
| `ZRAG_DEFAULT_SEARCH_TYPE` | `metadata.search_type` | string | `reranked_fusion` | Search algorithm. Options: `keyword` (BM25 only), `semantic` (vector only), `fusion` (hybrid keyword+vector), `reranked_fusion` (hybrid + cross-encoder reranking). |
| `ZRAG_DEFAULT_IBM_INDICES` | `metadata.ibm_indices` | string | `*_ibm_docs_slate,*_ibm_redbooks_slate` | Comma-separated glob patterns for IBM documentation indices to search. |
| `ZRAG_DEFAULT_CUSTOMER_INDICES` | `metadata.customer_indices` | string | `""` (empty) | Comma-separated glob patterns for customer-specific documentation indices. |
| `ZRAG_METADATA_PRODUCT_WEIGHT` | `metadata.doc_weight.product_docs` | float | `0.5` | Weight for product/IBM documentation in result ranking (0.0-1.0). |
| `ZRAG_METADATA_CUSTOMER_WEIGHT` | `metadata.doc_weight.customer_docs` | float | `0.5` | Weight for customer documentation in result ranking (0.0-1.0). |
| `ZRAG_METADATA_AGENT_WEIGHT` | `metadata.doc_weight.agent_docs` | float | `0.0` | Weight for agent documentation in result ranking (0.0-1.0). |
| `ZRAG_DEFAULT_DYNAMIC_FILTERING` | `metadata.dynamic_filtering` | boolean | `true` | Enable dynamic filtering that automatically narrows results based on query context (e.g., product mentions). |

#### Filter Parameters (Result Filtering)

These parameters control post-retrieval filtering, including topic-based filtering and index-level scoping.

| Credential Key (Environment Variable) | Payload Field | Type | Default | Description |
|---------------------------------------|---------------|------|---------|-------------|
| `ZRAG_TOPICS_ENABLE` | `filter.topics.enable` | string | `""` (empty) | Comma-separated list of topics to **include**. Only documents matching these topics are returned. Example: `cics,db2,ims`. |
| `ZRAG_TOPICS_DISABLE` | `filter.topics.disable` | string | `""` (empty) | Comma-separated list of topics to **exclude**. Documents matching these topics are removed from results. Example: `deprecated,legacy`. |
| `ZRAG_FILTER_CUSTOMER_INDICES` | `filter.customer_indices` | string | `customer_*` | Glob pattern for customer index filtering. Restricts which customer indices are included in filter evaluation. |
| `ZRAG_FILTER_IBM_INDICES` | `filter.ibm_indices` | string | `""` (empty) | Glob pattern for IBM index filtering. When empty, no IBM index filtering is applied. |
| `ZRAG_FILTER_AGENT_INDICES` | `filter.agent_indices` | string | `agent_*` | Glob pattern for agent index filtering. |
| `ZRAG_FILTER_PRODUCT_WEIGHT` | `filter.doc_weight.product_docs` | float | _(not set)_ | Optional override for product document weight at the filter level. Only included in the payload when explicitly set. |
| `ZRAG_FILTER_CUSTOMER_WEIGHT` | `filter.doc_weight.customer_docs` | float | _(not set)_ | Optional override for customer document weight at the filter level. Only included in the payload when explicitly set. |
| `ZRAG_FILTER_AGENT_WEIGHT` | `filter.doc_weight.agent_docs` | float | _(not set)_ | Optional override for agent document weight at the filter level. Only included in the payload when explicitly set. |

### Configuration Examples

#### Example 1: Focus on IBM product documentation only

```bash
orchestrate connections set-credentials \
  -a zrag-mcp --env draft \
  -e "ZRAG_DEFAULT_IBM_INDICES=*_ibm_docs_slate,*_ibm_redbooks_slate" \
  -e "ZRAG_DEFAULT_CUSTOMER_INDICES=" \
  -e "ZRAG_METADATA_PRODUCT_WEIGHT=1.0" \
  -e "ZRAG_METADATA_CUSTOMER_WEIGHT=0.0"
```

Or via the **Orchestrate UI**: navigate to **Build > Connections > zrag-mcp > Credentials > Edit** and set:
- `ZRAG_METADATA_PRODUCT_WEIGHT` = `1.0`
- `ZRAG_METADATA_CUSTOMER_WEIGHT` = `0.0`

#### Example 2: Include customer documentation with equal weight

```bash
orchestrate connections set-credentials \
  -a zrag-mcp --env draft \
  -e "ZRAG_DEFAULT_CUSTOMER_INDICES=customer_acme_docs" \
  -e "ZRAG_METADATA_PRODUCT_WEIGHT=0.5" \
  -e "ZRAG_METADATA_CUSTOMER_WEIGHT=0.5"
```

#### Example 3: Filter results to specific topics

```bash
orchestrate connections set-credentials \
  -a zrag-mcp --env draft \
  -e "ZRAG_TOPICS_ENABLE=cics,db2,zos_security" \
  -e "ZRAG_TOPICS_DISABLE=deprecated"
```

Or via the **Orchestrate UI**: set the key `ZRAG_TOPICS_ENABLE` to `cics,db2,zos_security`.

#### Example 4: Use keyword search without reranking (faster, lower quality)

```bash
orchestrate connections set-credentials \
  -a zrag-mcp --env draft \
  -e "ZRAG_DEFAULT_RERANK=false" \
  -e "ZRAG_DEFAULT_SEARCH_TYPE=keyword"
```

### Configuration Best Practices

- **Reranking**: Keep enabled (`true`) for production. The cross-encoder reranking significantly improves relevance but adds latency (~200-500ms).
- **Search Type**: Use `reranked_fusion` for best quality. Use `keyword` for fastest response times when precision is less critical.
- **Index Selection**: Configure `ZRAG_DEFAULT_IBM_INDICES` and `ZRAG_DEFAULT_CUSTOMER_INDICES` to scope searches to your relevant documentation sources. Narrower index patterns improve both performance and relevance.
- **Document Weights**: Adjust `ZRAG_METADATA_PRODUCT_WEIGHT` and `ZRAG_METADATA_CUSTOMER_WEIGHT` based on which documentation sources matter most for your users. Weights should sum to 1.0 for balanced scoring.
- **Topic Filtering**: Use `ZRAG_TOPICS_ENABLE` to restrict results to specific product areas (e.g., `cics,db2`). Use `ZRAG_TOPICS_DISABLE` to exclude irrelevant or deprecated content.
- **Dynamic Filtering**: Keep enabled (`true`) to let the system automatically detect product mentions in the query and boost relevant results.

For more detailed information about these parameters and their usage, refer to the [zRAG MCP Server README](https://github.ibm.com/wxa4z/zrag-mcp-server/blob/main/Readme.md).

## Troubleshooting installation errors
If you run into any errors during installation, see [Troubleshooting link](https://github.ibm.com/wxa4z/agent-deployment-charts/tree/main/agent-helm-charts/zrag-agent) for troubleshooting steps.

## Uninstalling the agent
For uninstallation instructions, see [Agent Uninstallation](https://github.ibm.com/wxa4z/agent-deployment-charts/tree/main/agent-helm-charts/zrag-agent)

-------------------------
