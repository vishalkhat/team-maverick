# GharSense — Product Requirements Document (PRD)

**Version:** 1.0
**Date:** April 09, 2026
**Status:** Draft — Hackathon Submission

---

## Table of Contents

1. [Overview](#1-overview)
2. [Problem Statement](#2-problem-statement)
3. [Proposed Solution](#3-proposed-solution)
4. [Target Users](#4-target-users)
5. [Core Features](#5-core-features)
6. [User Journey](#6-user-journey)
7. [Conversation Flow Design](#7-conversation-flow-design)
8. [System Architecture](#8-system-architecture)
9. [Tech Stack](#9-tech-stack)
10. [Data Sources & APIs](#10-data-sources--apis)
11. [Data Schema](#11-data-schema)
12. [Brochure Output Specification](#12-brochure-output-specification)
13. [AI Prompt Strategy](#13-ai-prompt-strategy)
14. [Non-Functional Requirements](#14-non-functional-requirements)
15. [Hackathon Build Plan](#15-hackathon-build-plan)
16. [Risks & Mitigations](#16-risks--mitigations)
17. [Future Scope](#17-future-scope)
18. [Success Metrics](#18-success-metrics)

---

## 1. Overview

**Product Name:** GharSense
**Tagline:** Your AI real estate thinking partner — from "Should I buy?" to "Here's your dream home."

GharSense is a conversational AI agent built on Google's Gemma 4 open model that helps first-time home buyers in India make smarter property decisions. It works entirely through WhatsApp — no app download, no sign-up, no learning curve.

The agent guides users through three phases: (1) evaluating whether buying makes financial sense for their life situation, (2) matching them with properties that fit their lifestyle and goals, and (3) delivering a personalized property brochure directly on WhatsApp.

---

## 2. Problem Statement

Buying a home is the single largest financial decision most Indians make, yet the process is broken in multiple ways:

**Decision paralysis:** First-time buyers don't know whether buying is even the right move. Online calculators give numbers but no context. There's no one to talk through the decision with who isn't trying to sell them something.

**Information overload:** Property portals list thousands of properties but offer no personalization beyond basic filters (BHK, budget, location). They don't consider commute time to the user's specific office, proximity to schools for their future children, or the financial opportunity cost of the down payment.

**Language and literacy barriers:** Most calculators and property tools are in English and assume financial literacy. A significant portion of Indian home buyers prefer to communicate in Hindi, Kannada, Tamil, or other regional languages.

**Trust deficit:** Real estate agents have misaligned incentives. Buyers need an unbiased advisor who can do honest math and tell them "renting is smarter for you right now" when that's true.

**Fragmented workflow:** Today, a buyer must visit 4-5 different websites (property portals, EMI calculators, map services, locality review sites) and manually piece together information. No single tool connects the dots.

---

## 3. Proposed Solution

GharSense is a WhatsApp-based AI agent powered by Gemma 4 that acts as an unbiased real estate advisor. It combines three capabilities that currently require separate tools into a single conversational experience:

1. **Financial Advisor** — Honest rent-vs-buy analysis based on the user's complete life context.
2. **Property Matchmaker** — Intelligent matching against real listings, scored by life-fit (not just price and location).
3. **Brochure Generator** — Personalized PDF with matched properties, financial breakdown, and neighbourhood insights delivered on WhatsApp.

The key differentiator is that GharSense is a *thinking partner*, not a search tool. It challenges assumptions, asks the right questions, and delivers a recommendation — not a list of 500 results.

---

## 4. Target Users

### Primary Persona: First-Time Home Buyer in Bangalore

- **Age:** 26–38
- **Income:** ₹8–30 LPA
- **Profile:** Salaried IT/ITES professional
- **Situation:** Currently renting, considering first home purchase
- **Pain points:** Doesn't know where to start, overwhelmed by options, unsure if buying is financially smart, no trusted advisor
- **Tech comfort:** Uses WhatsApp daily, comfortable with chat interfaces

### Secondary Personas

- **Relocating professional:** Moving to Bangalore for a new job, needs to find a home quickly with no local knowledge.
- **NRI investor:** Looking to buy property in India remotely, needs someone to shortlist and analyze properties on their behalf.
- **Couple planning a family:** Need to factor in future requirements (school proximity, extra bedroom, safe neighbourhood).

---

## 5. Core Features

### F1: Life Context Collection (Conversational)
The agent collects the user's financial and life situation through natural, one-question-at-a-time dialogue. No forms, no dropdowns.

**Data collected:**
- Annual income and monthly take-home
- Existing EMIs (car loan, personal loan, credit card debt)
- Current monthly rent
- Available savings for down payment
- Job industry and employment type (salaried/freelance/business)
- How long they plan to stay in the city
- Family situation (single, married, planning kids)
- Risk appetite for investments

### F2: Rent vs Buy Financial Analysis
Using the collected data, the agent performs a comprehensive rent-vs-buy comparison.

**Factors considered:**
- Monthly EMI vs current rent
- Down payment opportunity cost (if invested in equity/mutual funds at 12% CAGR)
- Property appreciation estimate (locality-specific)
- Maintenance costs (1–2% of property value per year)
- Property tax (Karnataka: 0.5–1% of property value)
- Stamp duty (5%) and registration charges (1%)
- Tax benefits under Section 80C (₹1.5L on principal) and Section 24(b) (₹2L on interest)
- Break-even timeline (how many years before buying beats renting)

**Output:** A clear recommendation with supporting numbers: "Buy — it makes sense if you stay 7+ years" or "Rent — buying would cost you ₹12L more over 10 years."

### F3: Property Preference Collection
If buying is recommended, the agent transitions to preference collection.

**Data collected:**
- Office location (specific address or area)
- Maximum acceptable commute time
- BHK configuration
- Budget range (pre-filled from F2 affordability calculation)
- Must-have amenities (parking, gym, park, gated community)
- Floor preference
- New construction vs resale
- Preferred localities (or "suggest for me")

### F4: Intelligent Property Matching
The agent matches user preferences against the property database using a life-fit scoring algorithm.

**Scoring dimensions:**
- **Budget fit** (0–25 points): How close to the user's affordable range
- **Commute score** (0–25 points): Travel time to office via car and public transit
- **Amenity match** (0–20 points): Percentage of must-have amenities present
- **Future-proofing** (0–15 points): School proximity (if planning kids), hospital access, metro connectivity
- **Appreciation potential** (0–15 points): Locality-wise price trend data

**Output:** Top 5–7 properties ranked by total life-fit score.

### F5: Personalized PDF Brochure Generation
A professionally designed PDF containing:

- User's financial summary (affordability, EMI capacity, recommended budget)
- Rent vs buy analysis results with charts
- Top 5–7 matched properties with:
  - Property photo
  - Price, EMI estimate, down payment required
  - BHK, area, floor, furnishing status
  - Commute time to user's office
  - Nearby schools, hospitals, metro stations
  - "Why this fits you" — personalized note explaining the match
- Comparison table across all shortlisted properties
- Neighbourhood insights for each locality
- Next steps and tips for first-time buyers

### F6: WhatsApp Delivery
The brochure PDF is sent directly to the user's WhatsApp within the active conversation. No email, no app download, no login required.

### F7: Multilingual Support
The agent detects and responds in the user's preferred language. Supported languages for MVP: English, Hindi, Kannada.

---

## 6. User Journey

```
User sends "Hi" on WhatsApp
        │
        ▼
Phase 1: Life Assessment (6-8 messages)
  ├── Income, savings, EMIs
  ├── Job stability, city plans
  ├── Family situation
  └── Risk appetite
        │
        ▼
Rent vs Buy Verdict (with numbers)
        │
    ┌───┴───┐
    │       │
  Rent    Buy
  better  makes
    │     sense
    ▼       │
  Renting   ▼
  tips    Phase 2: Preferences (5-6 messages)
  shared    ├── Office location
            ├── Commute tolerance
            ├── BHK, budget, amenities
            └── Locality preferences
                  │
                  ▼
            Phase 3: Matching & Delivery
              ├── Score properties
              ├── Generate brochure PDF
              └── Send on WhatsApp
                      │
                      ▼
                User receives
                personalized brochure
```

**Total conversation time:** 5–8 minutes
**Total messages exchanged:** 15–25

---

## 7. Conversation Flow Design

### Design Principles

1. **One question per message.** Never ask two things at once.
2. **Acknowledge before asking.** Validate the user's previous answer before moving on.
3. **Use concrete numbers.** "Your EMI would be ₹38,000/month" not "Your EMI would be high."
4. **Be honest.** If renting is smarter, say so. The agent has no sales incentive.
5. **Keep it casual.** "Got it!" and "Let's figure this out" — not "Thank you for providing the information."
6. **Offer choices where possible.** "Are you looking for a 2BHK or 3BHK? Or should I suggest based on your family size?"

### Sample Conversation

**Agent:** Hey! 👋 Thinking about buying a home in Bangalore? I can help you figure out if it's the right move, and if it is, find properties that actually fit your life — not just your budget. Let's start — what's your approximate annual income?

**User:** 18 lakh

**Agent:** ₹18 LPA, got it. That puts your take-home around ₹1.25L/month after taxes. Do you have any running EMIs right now — car loan, personal loan, credit card dues?

**User:** Car loan EMI 12000

**Agent:** Okay, ₹12K going to car loan. That leaves about ₹1.13L for everything else. How much are you paying in rent currently?

**User:** 25000

**Agent:** ₹25K rent. And how much have you saved up that you could put towards a down payment?

**User:** Around 12 lakh

**Agent:** Nice, ₹12L in savings. Now a couple of life questions — what industry do you work in? And do you see yourself staying in Bangalore for the next 7-10 years?

**User:** IT, yes planning to stay long term

**Agent:** IT with long-term plans in Bangalore — that's a stable base. Last one — are you single, married, or planning a family soon? This affects the kind of home that makes sense.

**User:** Married, planning kids in 2-3 years

**Agent:** Perfect. Let me crunch the numbers for you...

📊 **Here's your rent vs buy analysis:**

With ₹12L down payment on a ₹65-70L property:
- **Home loan EMI:** ~₹45,000/month (20 years at 8.75%)
- **Your current rent:** ₹25,000/month
- **Monthly jump:** ₹20,000 more
- **But:** You get ₹3.5L/year tax benefits, which effectively reduces your EMI to ~₹38,000

If you invested that ₹12L in index funds instead and kept renting, you'd have ~₹37L in 10 years. The flat would need to appreciate to ₹95L+ to beat that.

**Verdict: Buying makes sense for you** — but only if you stay 7+ years (which you plan to). With a kid on the way, locking in a home now at lower rates is smart. The tax benefits and forced savings work in your favor.

Ready to find the right property? Where's your office located?

---

## 8. System Architecture

```
┌─────────────────────────────────────────────────┐
│                   USER (WhatsApp)                │
└─────────────────────┬───────────────────────────┘
                      │ Twilio / WhatsApp Cloud API
                      ▼
┌─────────────────────────────────────────────────┐
│              FastAPI Backend Server              │
│                                                  │
│  ┌──────────┐  ┌──────────┐  ┌──────────────┐  │
│  │ Session   │  │ Convo    │  │ Phase        │  │
│  │ Manager   │  │ History  │  │ Controller   │  │
│  └──────────┘  └──────────┘  └──────────────┘  │
│                      │                           │
│                      ▼                           │
│  ┌─────────────────────────────────────────┐    │
│  │         Gemma 4 (via Ollama)            │    │
│  │    System Prompt + Function Calling     │    │
│  └─────────────────────────────────────────┘    │
│                      │                           │
│         Function calls triggered                 │
│                      │                           │
│  ┌──────────┐  ┌──────────┐  ┌──────────────┐  │
│  │ EMI &    │  │ Property │  │ Google Maps  │  │
│  │ Finance  │  │ Matcher  │  │ API Client   │  │
│  │ Engine   │  │ Engine   │  │              │  │
│  └──────────┘  └──────────┘  └──────────────┘  │
│                      │                           │
│                      ▼                           │
│  ┌─────────────────────────────────────────┐    │
│  │      PDF Brochure Generator             │    │
│  │      (Jinja2 + WeasyPrint)              │    │
│  └─────────────────────────────────────────┘    │
│                      │                           │
└──────────────────────┼──────────────────────────┘
                       │
                       ▼
              WhatsApp (PDF sent)
```

### Component Descriptions

**Session Manager:** Tracks user state (current phase, collected data, conversation history). Uses in-memory dict or SQLite for the hackathon.

**Conversation History:** Maintains the full chat transcript for Gemma's context window. Appended with each message exchange.

**Phase Controller:** Determines which phase the user is in (assessment, preferences, matching) and routes accordingly. Transitions are triggered by Gemma's function calls.

**Gemma 4 (Ollama):** The core AI engine. Receives the full conversation history + system prompt + available functions. Returns either a text response or a function call.

**EMI & Finance Engine:** Pure Python module. Calculates EMI, rent-vs-buy analysis, tax benefits, opportunity cost. No external API needed.

**Property Matcher Engine:** Queries the pre-scraped property JSON database. Scores and ranks properties using the life-fit algorithm.

**Google Maps API Client:** Fetches commute time (office to each property), nearby amenities (schools, hospitals, metro).

**PDF Brochure Generator:** Takes matched properties + financial summary + user data → renders HTML template → converts to PDF via WeasyPrint.

---

## 9. Tech Stack

| Layer | Technology | Why This Choice |
|---|---|---|
| AI Model | Gemma 4 E4B (via Ollama) | Open-source, on-device capable, multimodal, function calling, 140+ languages. Apache 2.0 license. |
| Backend | Python 3.11 + FastAPI | Async support, fast development, excellent ecosystem for AI/ML. |
| WhatsApp | Twilio WhatsApp Sandbox (hackathon) / WhatsApp Cloud API (production) | Instant setup, free for testing, media support. |
| Maps | Google Maps Distance Matrix + Places API | Best accuracy for Indian addresses, traffic-aware, $200/month free credits. |
| Property Data | Pre-scraped JSON (via Apify) | No property portal offers a public API. Pre-scraping ensures demo reliability. |
| PDF Generation | Jinja2 + WeasyPrint | Free, open-source, supports CSS for professional layouts. |
| Database | SQLite (hackathon) / PostgreSQL (production) | Zero setup for hackathon. Session data + property data. |
| Hosting | Localhost + ngrok (hackathon) | Free, instant public URL for WhatsApp webhook. |
| Model Serving | Ollama | One-command setup for Gemma 4. Handles quantization, context management. |

---

## 10. Data Sources & APIs

### Property Listings

| Source | Access Method | Cost | Data Available |
|---|---|---|---|
| 99acres | Apify scraper (pre-scraped) | Free tier (5 USD credits) | Price, BHK, area, amenities, photos, location |
| NoBroker | Unofficial REST API (api.market) | Free tier available | Price, BHK, coordinates, features, availability |
| MagicBricks | Apify scraper (pre-scraped) | Free tier | Price, BHK, area, builder, locality |
| Housing.com | Apify scraper (pre-scraped) | Free tier | Price, BHK, area, amenities, photos |

**Hackathon strategy:** Pre-scrape 200–500 Bangalore listings from 99acres + NoBroker into a single normalized JSON file 1-2 days before the event.

### Maps & Location

| API | Purpose | Free Tier |
|---|---|---|
| Google Distance Matrix | Commute time (office → property) | $200/month free credit |
| Google Places (Nearby Search) | Schools, hospitals, metro, parks near each property | Same $200 credit |
| Google Geocoding | Convert locality names to lat/long | Same $200 credit |

### WhatsApp

| Service | Purpose | Cost |
|---|---|---|
| Twilio WhatsApp Sandbox | Hackathon demo | Free |
| WhatsApp Business Cloud API | Production | Free access + per-message charges (₹0.14–0.80) |

### Financial Data (Hardcoded)

| Data Point | Source | Update Frequency |
|---|---|---|
| Home loan interest rates | Bank websites (SBI, HDFC, ICICI) | Monthly |
| Stamp duty & registration | Karnataka govt rates | Annually |
| Property appreciation rates | 99acres Price Trends, NHB RESIDEX | Quarterly |
| Income tax slabs & deductions | IT department | Annually |
| Index fund return assumptions | Historical NIFTY 50 data | Static (12% CAGR assumed) |

---

## 11. Data Schema

### User Session

```json
{
  "session_id": "uuid",
  "phone_number": "+91XXXXXXXXXX",
  "current_phase": "assessment | preferences | matching | delivered",
  "created_at": "2026-04-09T10:30:00Z",
  "language": "en | hi | kn",

  "life_context": {
    "annual_income": 1800000,
    "monthly_take_home": 125000,
    "existing_emis": 12000,
    "current_rent": 25000,
    "savings_for_down_payment": 1200000,
    "industry": "IT",
    "employment_type": "salaried",
    "years_in_city_plan": 10,
    "family_status": "married",
    "planning_kids": true,
    "kids_timeline_years": 2
  },

  "financial_analysis": {
    "max_affordable_property": 7000000,
    "recommended_emi": 45000,
    "recommended_down_payment": 1400000,
    "rent_vs_buy_verdict": "buy",
    "break_even_years": 7,
    "opportunity_cost_10yr": 3700000,
    "tax_benefit_annual": 350000
  },

  "preferences": {
    "office_location": "Outer Ring Road, Marathahalli",
    "office_lat": 12.9568,
    "office_lng": 77.7011,
    "max_commute_minutes": 45,
    "bhk": 3,
    "budget_min": 5500000,
    "budget_max": 7500000,
    "must_have_amenities": ["parking", "power-backup", "gated-community"],
    "floor_preference": "mid",
    "construction_type": "new",
    "preferred_localities": ["Whitefield", "Sarjapur Road", "Electronic City"]
  },

  "matched_properties": ["prop_001", "prop_002", "prop_003"],
  "brochure_url": "/brochures/uuid.pdf",
  "conversation_history": []
}
```

### Property Listing

```json
{
  "property_id": "prop_001",
  "source": "99acres",
  "title": "3 BHK Flat in Prestige Lakeside Habitat",
  "price": 7200000,
  "price_per_sqft": 6000,
  "bhk": 3,
  "bathrooms": 2,
  "carpet_area_sqft": 1200,
  "built_up_area_sqft": 1450,
  "floor": "5th of 14",
  "furnishing": "semi-furnished",
  "possession": "ready-to-move",
  "construction_age_years": 2,
  "builder": "Prestige Group",
  "project_name": "Prestige Lakeside Habitat",
  "locality": "Whitefield",
  "sub_locality": "Varthur Road",
  "city": "Bangalore",
  "latitude": 12.9698,
  "longitude": 77.7500,
  "amenities": [
    "gym", "swimming-pool", "parking", "power-backup",
    "gated-community", "children-play-area", "clubhouse"
  ],
  "description": "Spacious 3BHK in premium gated community...",
  "images": [
    "https://example.com/img1.jpg",
    "https://example.com/img2.jpg"
  ],
  "listing_url": "https://99acres.com/property/12345",
  "scraped_date": "2026-04-07"
}
```

### Life-Fit Score

```json
{
  "property_id": "prop_001",
  "session_id": "uuid",
  "total_score": 82,
  "breakdown": {
    "budget_fit": 22,
    "commute_score": 20,
    "amenity_match": 18,
    "future_proofing": 12,
    "appreciation_potential": 10
  },
  "commute_car_minutes": 28,
  "commute_transit_minutes": 45,
  "nearby_schools": 4,
  "nearby_hospitals": 2,
  "nearest_metro_km": 1.2,
  "locality_appreciation_5yr_pct": 35,
  "personalized_note": "Strong commute fit at 28 min by car. 4 schools within 2km — great for your family plans. Whitefield has seen 35% appreciation in 5 years."
}
```

---

## 12. Brochure Output Specification

### Format
- **Type:** PDF (A4, portrait)
- **Pages:** 4–6
- **Generation method:** Jinja2 HTML template → WeasyPrint PDF

### Page Layout

**Page 1 — Cover + Financial Summary**
- GharSense branding
- User name and date
- Income and affordability summary
- Rent vs Buy verdict with key numbers
- EMI capacity and recommended budget

**Page 2 — Rent vs Buy Deep Dive**
- Side-by-side comparison table (rent scenario vs buy scenario over 10/15/20 years)
- Key assumptions listed
- Tax benefits breakdown
- Break-even chart (simple bar chart)

**Page 3–5 — Property Profiles (1 per page)**
- Property photo (hero image)
- Price, EMI estimate, down payment required
- BHK, area, floor, furnishing, possession status
- Commute time (car + transit) to user's office
- Nearby amenities (schools, hospitals, metro)
- Life-fit score (visual bar)
- "Why this fits you" personalized note

**Page 6 — Comparison Table + Next Steps**
- All shortlisted properties in a comparison table
- Columns: Property, Price, EMI, Commute, Score, Key highlight
- Next steps: How to schedule visits, documents needed for home loan, tips for negotiation

---

## 13. AI Prompt Strategy

### System Prompt Structure

The Gemma 4 system prompt is structured in three layers:

**Layer 1 — Persona & Rules**
```
You are GharSense, an honest and friendly AI real estate advisor for Indian home buyers.
You help users decide whether to buy or rent, and if buying makes sense, you find
properties that fit their life — not just their budget.

Rules:
- Ask ONE question at a time. Never dump multiple questions.
- Always acknowledge the user's answer before asking the next question.
- Use specific numbers, not vague statements.
- Be honest. If renting is smarter, say so clearly.
- Keep language casual and warm. You're a smart friend, not a bank officer.
- Detect the user's language and respond in the same language.
- Never recommend a specific property portal or agent. Stay neutral.
```

**Layer 2 — Phase Definitions & Transitions**
```
You operate in three phases:

PHASE 1 (Assessment): Collect life context. When you have enough data
(income, EMIs, rent, savings, job stability, city plans, family status),
call the function `calculate_rent_vs_buy` with the collected data.

PHASE 2 (Preferences): Only enter this phase if the rent_vs_buy verdict is "buy".
Collect property preferences. When complete, call `match_properties`.

PHASE 3 (Delivery): Present the top matches conversationally, then call
`generate_and_send_brochure` to send the PDF.
```

**Layer 3 — Available Functions**
```
Functions available:
- calculate_rent_vs_buy(income, emis, rent, savings, industry, years_in_city, family_status)
- match_properties(office_location, max_commute, bhk, budget_min, budget_max, amenities, localities)
- get_commute_time(origin_lat, origin_lng, dest_lat, dest_lng)
- get_nearby_places(lat, lng, type, radius_meters)
- generate_and_send_brochure(session_id)
```

---

## 14. Non-Functional Requirements

### Performance
- **Response time:** Agent should respond within 5 seconds per message (Gemma inference + any API calls).
- **Brochure generation:** PDF should be generated and sent within 30 seconds of triggering.
- **Concurrent users:** Hackathon demo supports 1–3 simultaneous users. Production target: 100+.

### Privacy & Security
- All user financial data is stored locally (never sent to external analytics services).
- Conversation history is session-scoped and not persisted beyond the interaction (hackathon).
- Phone numbers are not shared with any third party.
- Property data is sourced from publicly available listings only.

### Reliability
- Property database is pre-loaded locally — no dependency on external scraping during demo.
- Google Maps API calls are cached to avoid redundant requests.
- Graceful fallback if Gemma inference fails (retry once, then apologize and ask user to rephrase).

### Scalability (Production Roadmap)
- Replace SQLite with PostgreSQL.
- Move Gemma to GPU server or use Gemma 26B MoE for better quality.
- Implement Redis for session caching.
- Add message queue (RabbitMQ/Celery) for async brochure generation.

---

## 15. Hackathon Build Plan

### Pre-Hackathon (1–2 days before)

| Task | Time | Output |
|---|---|---|
| Set up Gemma 4 E4B on Ollama | 30 min | Model running locally |
| Pre-scrape 200+ Bangalore properties via Apify | 2 hours | `properties.json` |
| Get Google Maps API key + enable APIs | 15 min | API key ready |
| Set up Twilio WhatsApp Sandbox | 15 min | Webhook URL configured |
| Design brochure HTML template | 2 hours | `brochure_template.html` |

### Hackathon Day — Hour-by-Hour Plan

| Hour | Task | Deliverable |
|---|---|---|
| 1–2 | FastAPI skeleton + Twilio webhook + Ollama integration | Bot responds on WhatsApp |
| 3–4 | Phase 1: System prompt + life context collection + rent-vs-buy engine | Financial analysis works end-to-end |
| 5–6 | Phase 2: Preference collection + property matching engine + life-fit scoring | Properties matched and ranked |
| 7–8 | Phase 3: Google Maps integration (commute + nearby places) + brochure PDF generation | PDF generated with real data |
| 9 | WhatsApp PDF delivery + end-to-end testing | Full flow works |
| 10 | Edge cases, conversation polish, demo preparation | Demo-ready |

---

## 16. Risks & Mitigations

| Risk | Likelihood | Impact | Mitigation |
|---|---|---|---|
| Property scraping blocked during demo | Medium | High | Pre-scrape all data into local JSON before event |
| Google Maps API quota exceeded | Low | Medium | Cache all commute/places results; use OSRM as free fallback |
| WhatsApp sandbox message limits | Low | Low | Limit demo to 2-3 phone numbers (sandbox supports 5) |
| Gemma hallucinates property data | Medium | High | Ground all responses in actual scraped data via function calling; never let Gemma "imagine" properties |
| Slow Gemma inference on laptop | Medium | Medium | Use quantized E4B (Q4_K_M GGUF); keep context window under 8K tokens; pre-generate common responses |
| WeasyPrint PDF rendering issues | Low | Medium | Test template thoroughly before event; have a static sample PDF as backup |
| User asks in unsupported language | Low | Low | Default to English with a friendly message asking to switch |

---

## 17. Future Scope

### Phase 2 (Post-Hackathon)

- **Live property data:** Replace pre-scraped JSON with real-time API integration via NoBroker unofficial API or partnerships with property portals.
- **Site visit scheduling:** Agent helps schedule property visits and sends calendar invites.
- **Home loan comparison:** Compare loan offers from SBI, HDFC, ICICI, Axis based on user profile.
- **Document checklist:** Generate a personalized document checklist based on employment type and property type.
- **Multi-city support:** Expand beyond Bangalore to Mumbai, Pune, Hyderabad, Delhi-NCR.

### Phase 3 (Product Vision)

- **Voice interface:** Voice-first interaction using Gemma E2B/E4B's native audio input. User speaks; agent responds with text and voice.
- **Augmented reality property preview:** User points phone camera at a building; agent overlays price, EMI, and fit score in real time.
- **Community intelligence:** Aggregate anonymized user preferences to generate neighbourhood demand signals and price predictions.
- **Mobile app (on-device):** Run Gemma E2B entirely on the user's phone. Zero server costs, complete privacy.
- **Partnership model:** White-label GharSense for property portals, banks, and real estate developers.

---

## 18. Success Metrics

### Hackathon Demo

| Metric | Target |
|---|---|
| End-to-end conversation completion | < 8 minutes |
| Time from "Hi" to brochure delivery | < 10 minutes |
| Agent response latency | < 5 seconds per message |
| Brochure generation time | < 30 seconds |
| Demo works without internet (except WhatsApp) | Yes (pre-loaded data + local Gemma) |

### Production (Future)

| Metric | Target |
|---|---|
| Conversation completion rate | > 60% of users who start reach brochure |
| User satisfaction (post-brochure survey) | > 4.2/5 |
| Rent-vs-buy accuracy | Within 5% of manual financial advisor calculation |
| Property match relevance | > 70% of users find at least 2 "good fit" properties |
| Monthly active users | 10,000 within 6 months of launch |

---

## Appendix A: Repository Structure

```
gharsense/
├── README.md
├── PRD.md                          # This document
├── requirements.txt
├── .env.example
│
├── app/
│   ├── main.py                     # FastAPI entry point
│   ├── config.py                   # Environment variables, API keys
│   │
│   ├── agents/
│   │   ├── system_prompt.py        # Gemma system prompt & function definitions
│   │   ├── gemma_client.py         # Ollama API wrapper
│   │   └── phase_controller.py     # Phase transition logic
│   │
│   ├── engines/
│   │   ├── finance_engine.py       # EMI, rent-vs-buy, tax calculations
│   │   ├── property_matcher.py     # Life-fit scoring algorithm
│   │   └── brochure_generator.py   # Jinja2 + WeasyPrint PDF generation
│   │
│   ├── integrations/
│   │   ├── whatsapp.py             # Twilio / WhatsApp Cloud API
│   │   ├── google_maps.py          # Distance Matrix + Places API
│   │   └── property_scraper.py     # Apify client (for data refresh)
│   │
│   ├── models/
│   │   ├── session.py              # User session data model
│   │   ├── property.py             # Property listing data model
│   │   └── score.py                # Life-fit score data model
│   │
│   └── templates/
│       └── brochure/
│           ├── brochure.html       # Jinja2 HTML template
│           └── styles.css          # Brochure CSS
│
├── data/
│   ├── properties.json             # Pre-scraped property listings
│   ├── localities.json             # Bangalore locality appreciation data
│   └── loan_rates.json             # Current home loan interest rates
│
├── tests/
│   ├── test_finance_engine.py
│   ├── test_property_matcher.py
│   └── test_conversation_flow.py
│
└── docs/
    ├── architecture.png
    ├── conversation_flow.png
    └── api_feasibility.md
```

---

## Appendix B: Environment Variables

```env
# Gemma / Ollama
OLLAMA_BASE_URL=http://localhost:11434
GEMMA_MODEL=gemma4:e4b

# Twilio (WhatsApp)
TWILIO_ACCOUNT_SID=your_account_sid
TWILIO_AUTH_TOKEN=your_auth_token
TWILIO_WHATSAPP_NUMBER=whatsapp:+14155238886

# Google Maps
GOOGLE_MAPS_API_KEY=your_api_key

# App
APP_HOST=0.0.0.0
APP_PORT=8000
DATABASE_URL=sqlite:///./gharsense.db
```

---
