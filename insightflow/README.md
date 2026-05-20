# InsightFlow: Autonomous Content-to-Action Agent

**InsightFlow** is a next-generation agentic AI system designed to ingest unstructured data (PDFs, Images, CSVs) and transform it into actionable business intelligence. It does not just summarize—it understands, analyzes, recommends actions, and simulates the execution of those actions.

Built for **Challenge 1** of the AI Seekho Hackathon.

---

## 🚀 Features

*   **Multimodal Ingestion:** Directly upload PDFs (Reports), CSVs (Financial Data), and Images (Dashboards). 
*   **Agentic Reasoning Pipeline:** Visualizes the AI's internal "thought process" using a beautiful macOS-style terminal UI.
*   **Structured Output:** Generates deterministic, highly-structured JSON responses ensuring reliable data extraction.
*   **Action Simulation:** Automatically selects the highest-priority business action and simulates a realistic audit log of its execution.
*   **Cloud Persistence:** Seamlessly integrates with Supabase to store a historical trace of all analyses and simulations.

---

## 🏗️ Architecture & Tech Stack

*   **Frontend:** Flutter (Cross-platform Mobile & Web)
*   **AI Orchestration:** Google Antigravity & Google Generative AI SDK (Gemini 3 Flash Preview)
*   **Backend & Database:** Supabase (PostgreSQL with JSONB structured storage)

### How Google Antigravity Was Used
Google Antigravity served as the core development platform and AI coding assistant for this project. 
1. **Architectural Planning:** Used Antigravity to design the agentic mega-prompt architecture that bypasses free-tier rate limits (combining 5 reasoning steps into 1 API call).
2. **Implementation:** Pair-programmed the Flutter UI, file parsing logic, and Supabase database integration.
3. **Debugging:** Antigravity autonomously diagnosed API quota limits and restructured the payload injection dynamically based on file Mime Types (PDF, Image, CSV).

---

## 🛠️ Installation & Setup

1. Clone the repository.
2. Run `flutter pub get` to install dependencies.
3. Create a `.env` file in the root directory:
   ```env
   GEMINI_API_KEY=your_google_ai_studio_key
   SUPABASE_URL=your_supabase_project_url
   SUPABASE_ANON_KEY=your_supabase_anon_key
   ```
4. Run the app: `flutter run`

---

## 📊 Assumptions & Limitations
*   **Payload Size:** To comply with standard REST API inline payload limits, file uploads are capped at 15MB per run.
*   **Simulated State:** The execution simulation generates highly realistic logs but does not actually mutate external 3rd-party SaaS databases (e.g., Salesforce) in this prototype phase.
