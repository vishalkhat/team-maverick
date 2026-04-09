# GharSense — Low-Level Design (LLD)

**Team:** Team Maverick
**Related PRD:** [PRD.md](./PRD.md)
**Last updated:** April 09, 2026

---

## 1. Context

GharSense is a WhatsApp-based AI real estate advisor. A user sends a WhatsApp message; Twilio forwards it to our FastAPI service on EKS; the service maintains a stateful conversation, calls Gemma 4 (Ollama locally) or Gemini (EKS production) for intelligence, runs deterministic finance/matching engines for grounded answers, and sends responses back through Twilio. At conversation end, a personalized PDF brochure is generated and delivered on WhatsApp.

```text
[ User / WhatsApp ]
        │  Twilio webhook POST
        ▼
[ FastAPI service — EKS (service-one / gharsense) ]
   ├── PhaseController (state machine: ASSESSMENT → PREFERENCES → MATCHING → DELIVERED)
   ├── LLMAdapter (Ollama/Gemma4 locally | Gemini API on EKS)
   ├── FinanceEngine (pure Python — EMI, rent-vs-buy, tax)
   ├── PropertyMatcher (life-fit scoring against pre-loaded JSON)
   ├── BrochureGenerator (Jinja2 → WeasyPrint PDF)
   └── GoogleMapsClient (commute + nearby places, Valkey-cached)
        │
        ├── MySQL 8.0 (in-hack-mysql)  — sessions, properties, scores
        ├── Valkey / ElastiCache       — Maps API cache, session TTL index
        └── Twilio API                 — send text + PDF media back to user
```

---

## 2. Architecture

### 2.1 Components

| Component | Responsibility | Location in repo |
|-----------|----------------|------------------|
| **FastAPI app** | HTTP entry-point, webhook signature verification, request routing | `src/app/main.py` |
| **PhaseController** | State machine: decides which phase the user is in and transitions | `src/app/agents/phase_controller.py` |
| **LLMAdapter** | Abstract interface; OllamaAdapter (Gemma 4) or GeminiAdapter | `src/app/agents/llm_adapter.py` |
| **FunctionRegistry** | Maps Gemma/Gemini tool-call names → Python callables | `src/app/agents/function_registry.py` |
| **ConversationService** | Orchestrates: load session → call LLM → execute tool calls → persist → reply | `src/app/services/conversation_service.py` |
| **FinanceEngine** | Deterministic EMI, rent-vs-buy, opportunity cost, tax calculations | `src/app/engines/finance_engine.py` |
| **PropertyMatcher** | Loads `data/properties.json`, applies life-fit scoring algorithm | `src/app/engines/property_matcher.py` |
| **GoogleMapsClient** | Distance Matrix + Places API with Valkey caching | `src/app/integrations/google_maps.py` |
| **BrochureGenerator** | Jinja2 + WeasyPrint → PDF bytes; served via `/brochures/{id}` | `src/app/engines/brochure_generator.py` |
| **WhatsAppClient** | Twilio REST client: send text, send media | `src/app/integrations/whatsapp.py` |
| **SessionRepository** | MySQL CRUD for `user_sessions` table | `src/app/repositories/session_repo.py` |
| **PropertyRepository** | MySQL seed + lookup for `properties` table | `src/app/repositories/property_repo.py` |

### 2.2 Boundaries

- **Owns:** Conversation state, financial calculations, property matching logic, PDF generation
- **Calls / reads:** Twilio API (send messages), Google Maps API (commute/places), MySQL (sessions + properties), Valkey (cache), Ollama (local) or Gemini API (EKS)
- **Does not own:** WhatsApp infra, property portal data (pre-scraped), cloud infrastructure

### 2.3 LLM Adapter Design

The adapter pattern decouples business logic from the LLM provider, allowing seamless switching between Gemma 4 (Ollama) and Gemini without touching any service code.

```python
class LLMAdapter(ABC):
    async def chat(
        self,
        messages: list[ChatMessage],
        tools: list[ToolDefinition] | None = None,
    ) -> LLMResponse:  # returns text OR tool_call
        ...

class OllamaAdapter(LLMAdapter):   # Gemma 4 E4B via Ollama
    ...

class GeminiAdapter(LLMAdapter):   # Gemini 2.0 Flash via Google AI API
    ...
```

Selected at startup via `LLM_PROVIDER=ollama|gemini` env var.

---

## 3. Interfaces

### 3.1 REST API Endpoints

| Method | Path | Description | Auth |
|--------|------|-------------|------|
| `POST` | `/api/v1/webhook/twilio` | Twilio WhatsApp message webhook | Twilio signature header |
| `POST` | `/api/v1/webhook/whatsapp` | WhatsApp Cloud API webhook | `X-Hub-Signature-256` |
| `GET` | `/api/v1/webhook/whatsapp` | WhatsApp webhook verification challenge | Query token |
| `GET` | `/api/v1/brochures/{session_id}` | Serve generated PDF | None (UUID in path) |
| `GET` | `/health` | Liveness check — returns `{"status":"ok"}` | None |
| `GET` | `/ready` | Readiness — checks MySQL + Valkey connectivity | None |

### 3.2 Twilio Webhook Payload (inbound)

```json
{
  "From":    "whatsapp:+919876543210",
  "To":      "whatsapp:+14155238886",
  "Body":    "18 lakh",
  "NumMedia": "0"
}
```
Response must be `200 OK` within **5 seconds**. Heavy work (Maps, PDF) runs in an `asyncio.create_task()` background coroutine.

### 3.3 LLM Tool Calls (Gemma/Gemini function calling)

| Function | Triggered when | Returns |
|----------|---------------|---------|
| `calculate_rent_vs_buy` | Phase 1 complete (all context collected) | `FinancialAnalysis` JSON |
| `match_properties` | Phase 2 complete (preferences collected) | List of `PropertyScore` JSON |
| `get_commute_time` | During property matching | `{car_minutes, transit_minutes}` |
| `get_nearby_places` | During property matching | `{schools, hospitals, metro_stations}` |
| `generate_and_send_brochure` | Phase 3 triggered | `{brochure_url}` |

### 3.4 Async Background Task Flow

```
POST /webhook  ──► Twilio 200 ack (immediate)
                       │
                asyncio.create_task()
                       │
                [background coroutine]
                  ├── load/create session
                  ├── call LLM (agentic loop with tool calls)
                  ├── persist updated session
                  └── send reply via Twilio
```

---

## 4. Data

### 4.1 MySQL Schema

**`user_sessions`**
```sql
CREATE TABLE user_sessions (
    id              CHAR(36)     PRIMARY KEY DEFAULT (UUID()),
    phone_number    VARCHAR(20)  NOT NULL UNIQUE,
    phase           ENUM('assessment','preferences','matching','delivered','renting_tips') NOT NULL DEFAULT 'assessment',
    language        CHAR(2)      NOT NULL DEFAULT 'en',
    life_context    JSON,
    financial_analysis JSON,
    preferences     JSON,
    matched_property_ids JSON,
    brochure_path   VARCHAR(512),
    conversation_history JSON     NOT NULL DEFAULT (JSON_ARRAY()),
    created_at      DATETIME(3)  NOT NULL DEFAULT NOW(3),
    updated_at      DATETIME(3)  NOT NULL DEFAULT NOW(3) ON UPDATE NOW(3),
    INDEX idx_phone (phone_number),
    INDEX idx_phase (phase)
);
```

**`properties`**
```sql
CREATE TABLE properties (
    id              CHAR(36)     PRIMARY KEY,
    source          VARCHAR(50)  NOT NULL,
    title           VARCHAR(500) NOT NULL,
    price           BIGINT       NOT NULL,
    price_per_sqft  INT,
    bhk             TINYINT      NOT NULL,
    bathrooms       TINYINT,
    carpet_area_sqft INT,
    built_up_sqft   INT,
    floor_info      VARCHAR(50),
    furnishing      VARCHAR(50),
    possession      VARCHAR(50),
    construction_age_years TINYINT,
    builder         VARCHAR(200),
    project_name    VARCHAR(300),
    locality        VARCHAR(100) NOT NULL,
    sub_locality    VARCHAR(100),
    city            VARCHAR(100) NOT NULL DEFAULT 'Bangalore',
    latitude        DECIMAL(10,7),
    longitude       DECIMAL(10,7),
    amenities       JSON,
    description     TEXT,
    images          JSON,
    listing_url     VARCHAR(1024),
    scraped_date    DATE,
    INDEX idx_locality (locality),
    INDEX idx_bhk_price (bhk, price),
    INDEX idx_city (city)
);
```

**`life_fit_scores`**
```sql
CREATE TABLE life_fit_scores (
    id                   CHAR(36)    PRIMARY KEY DEFAULT (UUID()),
    session_id           CHAR(36)    NOT NULL,
    property_id          CHAR(36)    NOT NULL,
    total_score          TINYINT     NOT NULL,
    budget_fit           TINYINT,
    commute_score        TINYINT,
    amenity_match        TINYINT,
    future_proofing      TINYINT,
    appreciation_potential TINYINT,
    commute_car_min      TINYINT,
    commute_transit_min  TINYINT,
    nearby_schools       TINYINT,
    nearby_hospitals     TINYINT,
    nearest_metro_km     DECIMAL(5,2),
    locality_appreciation_pct TINYINT,
    personalized_note    TEXT,
    INDEX idx_session (session_id),
    INDEX idx_score (session_id, total_score DESC)
);
```

### 4.2 Storage

| Data | Store | Notes |
|------|-------|-------|
| User session state + conversation history | MySQL `user_sessions` (JSON columns) | Persisted across WhatsApp disconnects |
| Property listings | MySQL `properties` + `data/properties.json` seed | Pre-loaded at startup; ~300 Bangalore listings |
| Life-fit scores | MySQL `life_fit_scores` | Computed once per session |
| Active session phone→id mapping | Valkey `session:{e164_phone}` TTL 24h | Fast lookup without DB hit per message |
| Google Maps commute cache | Valkey `maps:commute:{sha256(origin+dest)}` TTL 7d | Avoid redundant API calls |
| Google Maps places cache | Valkey `maps:places:{lat:.3f}:{lng:.3f}:{type}` TTL 7d | Same |
| Generated PDFs | `/tmp/brochures/{session_id}.pdf` in pod | Served by FastAPI; regenerated if pod restarts |

### 4.3 Valkey Key Reference

```
session:{+91XXXXXXXXXX}               → "uuid-of-session"            TTL 86400
maps:commute:{hex32}                  → "28"  (car minutes as str)   TTL 604800
maps:places:{12.969}:{77.750}:school  → JSON array of place names    TTL 604800
```

---

## 5. Configuration & Secrets

### Environment Variables

| Var | Default | Description |
|-----|---------|-------------|
| `LLM_PROVIDER` | `gemini` | `ollama` or `gemini` |
| `OLLAMA_BASE_URL` | `http://localhost:11434` | Ollama server URL |
| `OLLAMA_MODEL` | `gemma4:e4b` | Ollama model tag |
| `GEMINI_API_KEY` | — | Google AI API key |
| `GEMINI_MODEL` | `gemini-2.0-flash` | Gemini model |
| `TWILIO_ACCOUNT_SID` | — | Twilio account SID |
| `TWILIO_AUTH_TOKEN` | — | Twilio auth token |
| `TWILIO_WHATSAPP_NUMBER` | — | `whatsapp:+14155238886` |
| `WHATSAPP_TOKEN` | — | WhatsApp Cloud API token (future) |
| `WHATSAPP_VERIFY_TOKEN` | — | Webhook verification token |
| `GOOGLE_MAPS_API_KEY` | — | Google Maps API key |
| `DATABASE_URL` | — | `mysql+aiomysql://user:pass@host/gharsense` |
| `REDIS_URL` | — | `redis://host:6379/0` |
| `APP_BASE_URL` | — | Public URL for brochure PDF links |
| `LOG_LEVEL` | `INFO` | `DEBUG`, `INFO`, `WARNING` |

### Secrets (never in source)

Stored as GitHub repo secrets, injected via `config/secrets.json` into the EKS pod:

```json
{
  "DATABASE_URL":        "DATABASE_URL",
  "REDIS_URL":           "REDIS_URL",
  "TWILIO_ACCOUNT_SID":  "TWILIO_ACCOUNT_SID",
  "TWILIO_AUTH_TOKEN":   "TWILIO_AUTH_TOKEN",
  "TWILIO_WHATSAPP_NUMBER": "TWILIO_WHATSAPP_NUMBER",
  "GOOGLE_MAPS_API_KEY": "GOOGLE_MAPS_API_KEY",
  "GEMINI_API_KEY":      "GEMINI_API_KEY",
  "WHATSAPP_VERIFY_TOKEN": "WHATSAPP_VERIFY_TOKEN"
}
```

---

## 6. Deployment & Operations

### How It Runs

- **Service folder:** `service-one/` (renamed to `gharsense` in Helm)
- **Entrypoint:** `uvicorn app.main:app --host 0.0.0.0 --port 8000 --workers 2`
- **Dockerfile:** `./helm/python-service.Dockerfile` (Poetry multi-stage)
- **Package layout:** `pyproject.toml` at service root; source in `src/app/`
- **DB migrations:** Alembic; run as Helm `migration-job` pre-deployment

### Helm Key Values (`config/deploy.yaml`)

```yaml
helmReleaseName: gharsense
namespace: team-maverick
dockerfilePath: ./helm/python-service.Dockerfile
docker:
  buildArgs:
    PORT: "8000"
    POETRY_APP_MODULE: "app.main:app"
application:
  container:
    command: ["uvicorn"]
    args: ["app.main:app", "--host", "0.0.0.0", "--port", "8000", "--workers", "2"]
  resources:
    requests: { cpu: "500m", memory: "1Gi" }
    limits:   { cpu: "2000m", memory: "2Gi" }
```

### Health Checks

| Check | Path | What it verifies |
|-------|------|-----------------|
| Liveness | `GET /health` | Process is alive; returns `{"status":"ok"}` |
| Readiness | `GET /ready` | MySQL ping + Valkey ping succeed |

### Scaling

- **Replicas:** 2 (hackathon); HPA enabled at 60% CPU
- **Stateless design:** Sessions in MySQL + Valkey; any pod can handle any request
- PDF files stored in pod `/tmp/`; if pod restarts, brochure is regenerated on next request

---

## 7. Failure Modes & Mitigations

| Failure | Impact | Mitigation |
|---------|--------|------------|
| LLM timeout / error | User gets no reply | Retry once (tenacity); send "I'm thinking, give me a moment" fallback |
| Gemini API quota | Agent silent | Raise alert; `LLM_PROVIDER=ollama` as fallback env var swap |
| MySQL connection lost | Session not persisted | SQLAlchemy connection pool auto-reconnect; 3 retries with backoff |
| Valkey unavailable | Maps cache miss + session lookup falls back to DB | Fail open: skip cache, hit MySQL directly |
| Google Maps quota exceeded | Commute scores unavailable | Fall back to straight-line distance estimate; flag in brochure note |
| WeasyPrint PDF failure | Brochure not generated | Catch exception; send text summary with property list instead |
| Twilio webhook replay | Double-processing a message | Idempotency: check `conversation_history` for duplicate message body + timestamp before processing |
| Property JSON empty / missing | No matches returned | Startup validation; refuse to start if `properties.json` has < 50 entries |

---

## 8. Trade-offs & Deferred Work

### Hackathon Simplifications

| Decision | What was simplified | Production path |
|----------|--------------------|-----------------|
| PDF storage | `/tmp/` in pod (ephemeral) | S3 with presigned URLs |
| Background tasks | `asyncio.create_task()` | Celery + Redis queue for reliable delivery |
| Migrations | Alembic run manually pre-deploy | Helm migration-job hook |
| Property data | Pre-seeded static JSON (~300 listings) | Live NoBroker/99acres API integration |
| WhatsApp | Twilio sandbox (5 phones max) | WhatsApp Business API with full verification |
| LLM on EKS | Gemini API (no GPU nodes) | Dedicated GPU node group + Ollama deployment |
| Rate limiting | Redis token bucket per phone | Full Nginx/API Gateway rate limiting |
| Observability | Structured JSON logs | Prometheus metrics + Grafana + distributed tracing |

### What Would Come Next

1. **Celery workers** for async PDF + Maps enrichment (non-blocking brochure delivery)
2. **S3 brochure storage** with signed 24h URLs
3. **Live property scraping** scheduled daily via Apify
4. **Site visit scheduling** — agent books calendar slots, sends reminders
5. **Voice interface** — Gemma E2B/E4B audio input on mobile
