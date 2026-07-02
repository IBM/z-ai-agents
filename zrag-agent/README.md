# zRAG LangGraph Agent

A LangGraph-based RAG agent for IBM Z mainframe documentation. Provides hybrid
routing (simple vs complex questions), iterative retrieval with LLM-driven
sufficiency checks, multi-hop question decomposition, and parametric knowledge
fallback — all orchestrated as a compiled LangGraph StateGraph. 

## Architecture

```
User Query
    │
    ▼
┌─────────────────────────────────────────────┐
│        Query Classifier (LLM)               │
│   complexity + Z-scope in one call (~2-3s)  │
│   (heuristic fallback if LLM fails)         │
└──────┬──────────┬──────────┬────────────────┘
       │          │          │
   simple      complex   out-of-scope
       │          │          │
       ▼          ▼          │
┌────────────┐ ┌───────────────────────┐     
│ Retrieval  │ │ Multi-Hop Retrieval   │     
│ (iterative,│ │ (decompose → iterate  │     
│  LLM suff. │ │  → accumulate context │     
│  check, ≤3)│ │  → sufficiency, ≤5)   │     
└──────┬─────┘ └──────────┬────────────┘     
       │                  │                  
       └────────┬─────────┘                  
                │    
                ▼    
       ┌──────────────────┐
       │  Generation Node │
       │ (3 modes: strict │
       │  RAG / parametric│
       │  Z / out-of-scope│
       └────────┬─────────┘
                ▼
       ┌──────────────────┐
       │Results Processing│
       │ (citations or    │
       │  skip for OOS)   │
       └────────┬─────────┘
                ▼
          Final Answer
```

### External Services

| Service | Protocol | Auth | Purpose |
|---------|----------|------|---------|
| OpenSearch Wrapper | HTTPS POST `/v1/query` | Basic Auth | Document retrieval + reranking |
| WatsonX LLM | HTTPS POST `/ml/v1/text/chat[_stream]` | Bearer Token | Decomposition, sufficiency checks, answer generation |
| Langfuse (optional) | HTTPS | API Key pair | LLM observability |

## Quick Start

### Prerequisites

- Python 3.11+
- Access to a zRAG retriever backend (OpenSearch Wrapper)
- IBM WatsonX AI credentials (SaaS API key or CPD username/password)
- Knowledge base is ingested into OpenSearch with appropriate indices

### Local Setup

```bash
# Clone and enter the repo
cd zrag_external_agent

# Create virtual environment
python -m venv venv
source venv/bin/activate

# Install dependencies
pip install -r requirements.txt

# Configure environment
cp .env.example .env   # if .env.example exists, otherwise edit .env directly
# Edit .env with your credentials (see Configuration below)

# Validate configuration
python main.py --validate-config

```

### Docker

```bash
# Build and run
docker compose up --build

# Or build manually
docker build -t zrag-agent .
docker run --env-file .env -p 8000:8000 zrag-agent
```

## Usage

### Install ZRAG Agent
- ZRAG ext agent should be deployed as part of operator installation
- Once the latest operator is deployed, log in to Watsonx Orchestrate
- Create a service instance (tenant) on the Orcehstrate, and you should see a namespace with a tenant id getting provisioned in the Openshift Console
- Navigate to the pods section of that tenant namespace in Openshift Console
- You should see tenant specific ZRAG Agent pod coming up

### Sequence Flow

- User enters a query in the zRAG Agent chat interface
- Orchestrate routes the query to the wxa4z_zRAG_Agent_ext
- The external agent then calls the wrapper to retrieve relevant documents
- A sufficiency check happens to check if the retrieved content is sufficient, else the documents from the parametric knowledge of model are supplemented 
- The retrieved documents are then passed to the LLM for answer generation
- Answer is streamed back to the chat window with inline citations and source references

## Configuration

All configuration is via environment variables (loaded from `.env`).

### Required

```bash
# Retrieval backend
ZRAG_RETRIEVER_URL=https://your-opensearch-wrapper-url
ZRAG_USERNAME=admin
ZRAG_PASSWORD=your_password

# WatsonX AI - Option 1: SaaS
WATSONX_URL=https://us-south.ml.cloud.ibm.com/
WATSONX_APIKEY=your_api_key
WATSONX_PROJECT_ID=your_project_id          # or WATSONX_SPACE_ID

# WatsonX AI - Option 2: CPD
WATSONX_URL=https://your-cpd-cluster.com
WATSONX_USERNAME=your_username
WATSONX_PASSWORD=your_password
WATSONX_PROJECT_ID=your_project_id
WATSONX_VERIFY_SSL=false                    # for self-signed certs
```

### Model

```bash
MODEL_ID=<WATSONX_MODEL_ID>         # WatsonX model ID
MODEL_TEMPERATURE=0.3                       # 0=deterministic, 1=creative
MODEL_MAX_TOKENS=4096                      # Token budget (strict RAG)
MODEL_MAX_TOKENS_PARAMETRIC=4096           # Token budget (hybrid/parametric)
```

### Pipeline Behavior

```bash
# Multi-hop routing
ENABLE_MULTIHOP=true                        # Enable hybrid routing
MULTIHOP_MAX_ITERATIONS=5                   # Max sub-question retrievals

# Simple-path iterative refinement
SIMPLE_MAX_REFINEMENTS=3                    # Max query reformulations

# Parametric knowledge fallback
ENABLE_PARAMETRIC_FALLBACK=true             # Use model's own knowledge when retrieval insufficient
```

### Search & Citations

```bash
CITATION_MIN_CONFIDENCE=0.4
DOC_CONTENT_MAX_LENGTH=600
MAX_DOCS_TO_PROCESS=5
```

### Multi-Tenancy (Optional)

```bash
ENABLE_MULTI_TENANCY=false
PROVIDER_ID=
DEFAULT_TENANT_ID=default
DEPLOYMENT_MODE=dedicated                   # dedicated | shared
```

### Observability (Optional)

```bash
LANGFUSE_SECRET_KEY=your_secret_key
LANGFUSE_PUBLIC_KEY=your_public_key
LANGFUSE_BASE_URL=https://cloud.langfuse.com
```

### Web Search
```bash
ENABLE_WEB_SEARCH=false
SERPER_API_KEY=<YOUR-SERPER-API-KEY>
```

### Filters (Optional)
Note: WXO is not supporting credentials and filters via the UI for external agent and hence, if need be, we need to configure it manually by adding the following Keys with desired values in the config map of zrag agent for the corresponding namespace 
```bash
ZRAG_DEFAULT_RERANK=true
ZRAG_DEFAULT_SEARCH_TYPE=reranked_fusion
ZRAG_DEFAULT_IBM_INDICES=*_ibm_docs_slate,*_ibm_redbooks_slate
ZRAG_DEFAULT_CUSTOMER_INDICES=

ZRAG_METADATA_PRODUCT_WEIGHT=1
ZRAG_METADATA_CUSTOMER_WEIGHT=0
ZRAG_METADATA_AGENT_WEIGHT=0
```

## Key Features

### LLM Query Classification + Speculative Retrieval

Every query is classified in a single upfront LLM call (~2-3 s) that determines
both **complexity** (`simple` / `complex`) and **Z-scope** (`true` / `false`).
If the LLM call fails, the agent falls back to keyword heuristics (<1 ms).

The first retrieval call is fired **speculatively in parallel** with the LLM
classification. Since ~80% of queries go through the simple path and always
start with a retrieval of the original query, this hides the classification
latency from the critical path. For complex/out-of-scope queries the
speculative retrieval is discarded (no correctness impact).

Out-of-scope queries skip retrieval entirely and go straight to generation,
turning a 60+ second pipeline into a ~5 second response.

This determines the generation strategy:

| Z-Scope | Retrieval | Generation Mode | Behaviour |
|---------|-----------|-----------------|-----------|
| Yes | Sufficient | Strict RAG | Answer using ONLY retrieved context |
| Yes | Insufficient | Parametric Z Expert | Context + model's IBM Z expertise (marked) |
| No | Any | Out-of-scope | Graceful 1-liner + brief general-knowledge answer |

### Hybrid Routing

Questions are classified as **simple** or **complex** by the LLM classifier.
Simple questions use single-hop retrieval with iterative refinement; complex
questions are decomposed into sub-questions via LLM and retrieved **in parallel**
(`asyncio.gather`) with context accumulation. Out-of-scope queries bypass
retrieval entirely.

### Iterative Retrieval with LLM Sufficiency Checks

Both paths use LLM-driven sufficiency checks: after each retrieval iteration, the
model evaluates whether the accumulated context is enough to answer the original
question. If not, it proposes a reformulated search query targeting the gap.

All sufficiency decisions are made by the LLM — there are no heuristic confidence
thresholds. This avoids false positives where reranker scores are high but the
documents don't actually answer the question.

### Parametric Knowledge Fallback

When retrieval is insufficient after all iterations and `ENABLE_PARAMETRIC_FALLBACK`
is enabled, the generation node switches to a hybrid prompt that allows the model
to supplement retrieval context with its own expert knowledge. Parametric
contributions are explicitly marked in the answer.

### Stage Profiler

Every pipeline stage is timed with wall-clock precision. The profiler summary is
included in both log output and the API response:

Simple query (speculative retrieval overlaps with classification):
```
  Stage                            Duration   % Total
  ------------------------------ ----------  --------
  query_classification             2500 ms      9.2%  ← retrieval runs in parallel
  retrieval_iter_1               16900 ms     62.2%  ← uses speculative result
  sufficiency_check_1             2500 ms      9.2%
  generation_llm_call             4500 ms     16.6%
  citation_matching                  2.0 ms      0.0%
  ------------------------------ ----------  --------
  TOTAL                          27200 ms
```

Complex query (parallel sub-question retrieval):
```
  Stage                            Duration   % Total
  ------------------------------ ----------  --------
  query_classification             2500 ms      9.6%
  multihop_decomposition           2500 ms      9.6%
  multihop_parallel_retrieval    17000 ms     65.4%  ← 3 sub-Qs in parallel
  multihop_final_sufficiency       2500 ms      9.6%
  generation_llm_call              4500 ms     17.3%
  citation_matching                  2.0 ms      0.0%
  ------------------------------ ----------  --------
  TOTAL                          26000 ms
```

### Citation Management

Citations are extracted via phrase matching (4-8 word noun phrases from documents
matched against the answer text), scored using a blended formula (40% phrase length
+ 40% document relevance score + 20% uniqueness), and inserted as inline markers
with a references section.
Note: Citations may not come for queries not related to Z or for the queries, where parametric knowledge of the inferencing model is entirely used rather than retrieved docs to give results

## Troubleshooting

### Configuration Issues

```bash
python main.py --validate-config
```

### Common Errors

| Error | Cause | Fix |
|-------|-------|-----|
| `No WatsonX credentials provided` | Missing API key or CPD creds | Set `WATSONX_APIKEY` or `WATSONX_USERNAME`+`WATSONX_PASSWORD` |
| `Parameters [...] is/are not recognized` | Using text-gen params for chat API | Already fixed — ensure latest `models/watsonx.py` |
| `Failed to initialize model` | Invalid credentials or model ID | Verify `WATSONX_URL`, credentials, and `MODEL_ID` |
| Connection timeout to retriever | Retriever backend unreachable | Check `ZRAG_RETRIEVER_URL` and network access |
| `SSL: CERTIFICATE_VERIFY_FAILED` | CPD with self-signed certs | Set `WATSONX_VERIFY_SSL=false` |

### Logging

```bash
# Default: INFO level
python main.py

# Debug level (verbose LLM payloads, HTTP requests)
LOG_LEVEL=DEBUG python main.py
```

## Security Notes

- Never commit `.env` files with real credentials
- Use environment variables or Kubernetes Secrets in production
- The agent forwards tenant credentials (does not authenticate tenants itself)
- SSL verification is configurable per backend (`WATSONX_VERIFY_SSL`)
