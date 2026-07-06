# 🛠️ Specialized Development Skills: InsightFlow

This document details the specialized software engineering skills used and developed during the construction of InsightFlow, categorized into **UI/UX Engineering** and **LLM/Agentic Engineering**.

---

## 🎨 Skill 1: Premium UI/UX Engineering (macOS-Style Terminal UX)

### Overview
Creating an interface that represents the internal "thought process" of an AI agent in a highly engaging, visual, and human-readable way.

### Core Techniques:
1. **macOS-Style Interactive Terminal UI:** Built a dedicated terminal shell mockup in Flutter with custom window controls (red/yellow/green window buttons), monospaced fonts, and color-coded logging outputs.
2. **Real-time Streaming Output Simulation:** Created customized interval timers in Dart to animate the agent's internal reasoning steps (e.g., `[PARSING FILE...]`, `[EXTRACTING METRICS...]`, `[SIMULATING LOGS...]`), making the background AI processing highly interactive and dynamic.
3. **Multimodal File Drag & Drop UX:** Integrated custom gesture detectors and file pickers that dynamically adjust their card layouts depending on whether a PDF, CSV, or Image is uploaded.
4. **Responsive Flex-Layouts:** Ensured the dashboard grid transitions seamlessly between desktop web viewports (dual-column split layout) and mobile phone viewports (single-column stack layout) without clipping.

---

## 🤖 Skill 2: LLM Interaction & Agentic Engineering

### Overview
Structuring communication pipelines between the client app and Google's Gemini models to run complex agentic reasoning workflows with 100% deterministic success.

### Core Techniques:
1. **Multi-Step Mega-Prompting:** Rather than calling the LLM multiple times (which incurs heavy network latency and risks hitting rate limits), we built a "chain-of-thought" (CoT) mega-prompt. This prompt instructs the model to:
   * **Step 1:** Parse the base64 document content.
   * **Step 2:** Analyze key business trends and flag anomalies.
   * **Step 3:** Generate prioritized actionable recommendations.
   * **Step 4:** Simulate execution logs of the highest-priority action.
2. **Deterministic Schema Enforcement:** Injecting absolute structural rules inside the system prompt telling Gemini to output purely in strict JSON. This ensures the output is immediately parseable by the Dart frontend and matches the database schema.
3. **Base64 Payload Injection:** Programmed dynamic MIME-type mapping to inject PDF bytes, image pixels, and CSV plain-text directly into the Gemini multimodal API call, bypassing local text extractors.
4. **Supabase Telemetry Logging:** Engineered real-time DB writers that map the returned agent JSON directly into relational Supabase database columns, archiving all historical traces for auditability.
