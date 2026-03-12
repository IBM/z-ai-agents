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
4. Orchestrate uses this result and passes it to the LLM (Llama 3.3 70B) for answer generation
5. Answer is streamed back to the chat window with inline citations and source references


## Prerequisites
Ensure the following:

- [watsonx Assistant for Z](https://www.ibm.com/docs/watsonx/waz/3.1.0?topic=install-premises-watsonx-orchestrate-watsonx-assistant-z) is installed
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
MODEL_TOP_P | Nucleus sampling parameter (optional). Controls diversity via cumulative probability cutoff.
MODEL_TOP_K | Top-k sampling parameter (optional). Controls diversity by limiting to top k tokens.
**Environment variables - Search Configuration**                                                        |
ZRAG_DEFAULT_RERANK | Enable reranking of search results for improved relevance. Default: "true".
ZRAG_DEFAULT_SEARCH_TYPE | Search algorithm to use. Options: "keyword", "semantic", "fusion", "reranked_fusion". Default: "reranked_fusion".
ZRAG_DEFAULT_IBM_INDICES | Comma-separated list of IBM documentation indices to search. Default: "*_ibm_docs_slate,*_ibm_redbooks_slate".
ZRAG_DEFAULT_MAX_RESULTS | Maximum number of documents to retrieve from the backend. Default: "10".
ZRAG_DEFAULT_MIN_SCORE | Minimum relevance score for including documents (0.0-1.0). Default: "0.5".
ZRAG_CONTEXT_WINDOW | Maximum context window size in tokens for building prompts. Default: "2048".
ZRAG_MAX_CONTEXT_DOCS | Maximum number of documents to include in the LLM context. Default: "6".
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

The zRAG retriever supports advanced search configurations that can be customized to optimize document retrieval. These parameters can be configured in two ways:

### Configuration Methods

#### Method 1: Using ADK CLI (Environment Variables)

You can set connection credentials using the ADK CLI, which are internally referred to as environment variables. This method is demonstrated in the [zRAG MCP deployment notebook](https://github.ibm.com/wxa4z/zrag-mcp-server/blob/main/deployment/zrag_mcp_deployment_notebook.ipynb).

Example:
```bash
orchestrate connections set-credentials \
  -a zrag-mcp \
  --env draft \
  -e "ZRAG_DEFAULT_RERANK=true" \
  -e "ZRAG_DEFAULT_SEARCH_TYPE=reranked_fusion" \
  -e "ZRAG_DEFAULT_IBM_INDICES=*_ibm_docs_slate,*_ibm_redbooks_slate"
```

#### Method 2: Using Orchestrate UI

1. Navigate to the **Orchestrate Connections** page
2. Click on the **Credentials** tab
3. Select your connection ID
4. Click **Edit**
5. In the pop-up window, set the credentials as key/value pairs:
   - Key: Parameter name (e.g., `ZRAG_DEFAULT_RERANK`)
   - Value: Parameter value (e.g., `true`)
6. Once completed, click **Done**

### Available zrag_retriever Parameters

The following parameters can be configured to customize the search behavior:

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `query` | string | Required | Search query |
| `rerank` | boolean | true | Enable reranking of search results |
| `search_type` | string | "reranked_fusion" | Search algorithm: "keyword", "semantic", "fusion", "reranked_fusion" |
| `ibm_indices` | string | "*_ibm_docs_slate,*_ibm_redbooks_slate" | Comma-separated list of IBM documentation indices |
| `customer_indices` | string | "" | Comma-separated list of customer-specific indices |
| `metadata_product_weight` | float | 0.5 | Weight for product documentation (0.0-1.0) |
| `metadata_customer_weight` | float | 0.5 | Weight for customer documentation (0.0-1.0) |
| `metadata_agent_weight` | float | 0.0 | Weight for agent documentation (0.0-1.0) |
| `dynamic_filtering` | boolean | true | Enable dynamic filtering based on query context |
| `topics_enable` | string | "" | Comma-separated list of topics to include |
| `topics_disable` | string | "" | Comma-separated list of topics to exclude |

### Configuration Best Practices

- **Reranking**: Keep enabled (`true`) for improved relevance in production environments
- **Search Type**: Use `reranked_fusion` for best results, which combines keyword and semantic search with reranking
- **Index Selection**: Configure indices based on your documentation sources to reduce search scope and improve performance
- **Document Weights**: Adjust weights based on the relative importance of different documentation sources for your use case
- **Dynamic Filtering**: Enable to allow the system to automatically filter results based on query context

For more detailed information about these parameters and their usage, refer to the [zRAG MCP Server README](https://github.ibm.com/wxa4z/zrag-mcp-server/blob/main/Readme.md).

## Troubleshooting installation errors
If you run into any errors during installation, see [Troubleshooting link](https://github.ibm.com/wxa4z/agent-deployment-charts/tree/main/agent-helm-charts/zrag-agent) for troubleshooting steps.

## Uninstalling the agent
For uninstallation instructions, see [Agent Uninstallation](https://github.ibm.com/wxa4z/agent-deployment-charts/tree/main/agent-helm-charts/zrag-agent)

-------------------------
