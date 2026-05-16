# InsightFlow — Autonomous Content-to-Action Agent

## Overview
InsightFlow is a Flutter mobile app that transforms unstructured content (reports, news articles, policy documents, dashboards) into actionable outcomes using a multi-step agentic AI pipeline powered by Google Gemini 1.5 Flash.

## Architecture

```
Input (text/report)
    │
    ▼
┌─────────────────────────────────────────────┐
│         Gemini 1.5 Flash Agent Pipeline      │
│                                              │
│  Step 1: Ingest     → Clean & structure      │
│  Step 2: Extract    → Key insights & signals │
│  Step 3: Analyze    → Impact & severity      │
│  Step 4: Act        → Prioritized actions    │
│  Step 5: Simulate   → Execute & log changes  │
└─────────────────────────────────────────────┘
    │
    ▼
Result Screen
├── Insights Tab   → Primary insight + key facts + impact
├── Actions Tab    → 3 prioritized recommendations
└── Trace Tab      → Full agent reasoning log

    │
    ▼
Simulation Screen
├── Before vs After state
├── Animated execution log (real-time)
├── Impact metrics
└── Measurable outcome
```

## Agentic Workflow
Each of the 5 steps calls Gemini separately, creating a true chain-of-thought pipeline:
1. **Ingest Agent** — cleans raw input, identifies content type
2. **Extraction Agent** — finds non-trivial insights (not just summaries)
3. **Impact Analysis Agent** — reasons about real-world consequences + severity
4. **Action Generation Agent** — produces domain-specific ranked recommendations
5. **Simulation Agent** — executes top action, records before/after state + logs

## Setup

### 1. Clone and install
```bash
flutter pub get
```

### 2. Add your Gemini API Key
Open `lib/services/gemini_agent_service.dart` and replace:
```dart
static const String _apiKey = 'YOUR_GEMINI_API_KEY_HERE';
```
Get a free key at: https://aistudio.google.com/app/apikey

### 3. Run the app
```bash
flutter run
```

## Tools & APIs Used
- **Google Gemini 1.5 Flash** — core LLM for all 5 agent steps
- **Flutter** — cross-platform mobile framework
- **flutter_animate** — smooth UI animations
- **google_fonts** — typography (Inter)
- **http** — REST API calls to Gemini

## How Antigravity is Used
Google Antigravity (Gemini) is used as the central reasoning engine for ALL agent steps:
- Each step is a structured Gemini prompt with JSON output
- Steps are chained: output of each step feeds into the next
- The agent trace captures reasoning, decisions, and timing for full auditability

## Assumptions
- Content is in English (Urdu support can be added with translation preprocessing)
- Gemini API has internet access
- Mock simulation is realistic but not connected to live systems
- No real personal data is used

## Example Scenarios
1. **Sales Report** → Detects 28% order decline → Recommends regional campaign → Simulates email blast to 5,000 customers
2. **News Article** → Detects policy change → Analyzes operational impact → Simulates pricing table update
3. **Supply Chain Alert** → Detects inventory risk → Recommends supplier switch → Simulates reorder workflow
4. **Urban Policy** → Detects infrastructure failure → Recommends emergency response → Simulates alert dispatch
