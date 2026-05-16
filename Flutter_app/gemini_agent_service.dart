import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/insight_result.dart';

class GeminiAgentService {
  // Replace with your actual Gemini API key or load from .env
  static const String _apiKey = 'YOUR_GEMINI_API_KEY_HERE';
  static const String _baseUrl =
      'https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash:generateContent';

  // Main entry point — runs the full 5-step agentic pipeline
  Future<InsightResult> runAgentPipeline(String inputContent) async {
    final stopwatch = Stopwatch()..start();
    final List<AgentStep> trace = [];

    // Step 1: Ingest & clean
    final step1 = await _step1_ingest(inputContent);
    trace.add(AgentStep(
      stepName: '1. Content Ingestion',
      reasoning: 'Parsing and structuring raw input for downstream analysis.',
      output: step1['cleaned'],
      durationMs: stopwatch.elapsedMilliseconds,
    ));
    stopwatch.reset();

    // Step 2: Extract key facts
    final step2 = await _step2_extract(step1['cleaned']);
    trace.add(AgentStep(
      stepName: '2. Insight Extraction',
      reasoning: 'Identifying non-trivial patterns and key signals from content.',
      output: jsonEncode(step2),
      durationMs: stopwatch.elapsedMilliseconds,
    ));
    stopwatch.reset();

    // Step 3: Impact analysis
    final step3 = await _step3_analyze(step2);
    trace.add(AgentStep(
      stepName: '3. Impact Analysis',
      reasoning: 'Evaluating real-world consequences and severity of detected insight.',
      output: jsonEncode(step3),
      durationMs: stopwatch.elapsedMilliseconds,
    ));
    stopwatch.reset();

    // Step 4: Action generation
    final step4 = await _step4_generateActions(step2, step3);
    trace.add(AgentStep(
      stepName: '4. Action Generation',
      reasoning: 'Producing domain-relevant, prioritized action recommendations.',
      output: jsonEncode(step4),
      durationMs: stopwatch.elapsedMilliseconds,
    ));
    stopwatch.reset();

    // Step 5: Simulate execution
    final step5 = await _step5_simulate(step4['actions'][0], step3);
    trace.add(AgentStep(
      stepName: '5. Action Simulation',
      reasoning: 'Executing top-priority action and recording system state change.',
      output: jsonEncode(step5),
      durationMs: stopwatch.elapsedMilliseconds,
    ));

    return InsightResult(
      rawInput: inputContent,
      summary: step1['summary'],
      keyFacts: List<String>.from(step2['key_facts'] ?? []),
      insight: step2['primary_insight'],
      insightType: step2['domain'],
      impactAnalysis: step3['analysis'],
      severity: step3['severity'],
      actions: (step4['actions'] as List)
          .map((a) => ActionItem.fromJson(a))
          .toList(),
      simulation: SimulationResult.fromJson(step5),
      agentTrace: trace,
      timestamp: DateTime.now(),
    );
  }

  // ─── Step 1: Ingest ────────────────────────────────────────────────────────
  Future<Map<String, dynamic>> _step1_ingest(String content) async {
    const prompt = '''
You are an expert content analyst. Clean and prepare the following content for analysis.
Return ONLY valid JSON with NO markdown fences.

{
  "cleaned": "<cleaned and structured version of the input>",
  "summary": "<2-sentence summary of what this content is about>",
  "content_type": "<e.g. sales report, news article, policy document, financial data>"
}
''';
    return await _callGemini('$prompt\n\nCONTENT:\n$content');
  }

  // ─── Step 2: Extract ───────────────────────────────────────────────────────
  Future<Map<String, dynamic>> _step2_extract(String cleanedContent) async {
    const prompt = '''
You are an insight extraction specialist. Analyze this content deeply.
Return ONLY valid JSON with NO markdown fences.

{
  "primary_insight": "<the single most important non-obvious insight>",
  "domain": "<one of: Business, Financial, Policy, Logistics, Healthcare, Technology, News>",
  "key_facts": ["<fact 1>", "<fact 2>", "<fact 3>", "<fact 4>", "<fact 5>"],
  "signals": ["<signal or trend observed>"],
  "entities": ["<company/person/place mentioned>"]
}

Do NOT summarize. Extract SPECIFIC non-trivial insights with numbers/percentages where available.
''';
    return await _callGemini('$prompt\n\nCONTENT:\n$cleanedContent');
  }

  // ─── Step 3: Analyze ───────────────────────────────────────────────────────
  Future<Map<String, dynamic>> _step3_analyze(
      Map<String, dynamic> extractedData) async {
    const prompt = '''
You are a strategic impact analyst. Analyze the real-world implications of these insights.
Return ONLY valid JSON with NO markdown fences.

{
  "analysis": "<detailed explanation of why this insight matters and what consequences it leads to>",
  "severity": "<one of: Low, Medium, High, Critical>",
  "stakeholders_affected": ["<stakeholder 1>", "<stakeholder 2>"],
  "time_sensitivity": "<Immediate / This Week / This Month / Long-term>",
  "risk_if_ignored": "<what happens if no action is taken>"
}
''';
    return await _callGemini(
        '$prompt\n\nINSIGHTS:\n${jsonEncode(extractedData)}');
  }

  // ─── Step 4: Generate Actions ──────────────────────────────────────────────
  Future<Map<String, dynamic>> _step4_generateActions(
      Map<String, dynamic> insights, Map<String, dynamic> impact) async {
    const prompt = '''
You are an action planning agent. Generate concrete, domain-specific recommended actions.
Return ONLY valid JSON with NO markdown fences.

{
  "actions": [
    {
      "title": "<short action name>",
      "description": "<detailed description of what to do>",
      "priority": "<Immediate | Short-term | Long-term>",
      "expected_outcome": "<measurable result if action is taken>",
      "effort": "<Low | Medium | High>",
      "department": "<which team/department executes this>"
    }
  ]
}

Generate exactly 3 actions ordered by priority. Be specific and realistic.
''';
    return await _callGemini(
        '$prompt\n\nINSIGHTS:\n${jsonEncode(insights)}\n\nIMPACT:\n${jsonEncode(impact)}');
  }

  // ─── Step 5: Simulate ──────────────────────────────────────────────────────
  Future<Map<String, dynamic>> _step5_simulate(
      Map<String, dynamic> topAction, Map<String, dynamic> impact) async {
    const prompt = '''
You are an action simulation engine. Simulate the execution of this action realistically.
Return ONLY valid JSON with NO markdown fences.

{
  "action_executed": "<name of action executed>",
  "before_state": "<description of system/situation BEFORE action>",
  "after_state": "<description of system/situation AFTER action>",
  "execution_logs": [
    "[TIMESTAMP] <log entry 1>",
    "[TIMESTAMP] <log entry 2>",
    "[TIMESTAMP] <log entry 3>",
    "[TIMESTAMP] <log entry 4>",
    "[TIMESTAMP] Action completed successfully"
  ],
  "outcome": "<concrete measurable outcome of execution>",
  "metrics": {
    "<metric name>": "<before value>",
    "<metric name after>": "<after value>"
  }
}

Use realistic timestamps like [2025-01-15 14:32:01]. Make logs feel like a real system audit trail.
''';
    return await _callGemini(
        '$prompt\n\nACTION:\n${jsonEncode(topAction)}\n\nCONTEXT:\n${jsonEncode(impact)}');
  }

  // ─── Gemini API Call ───────────────────────────────────────────────────────
  Future<Map<String, dynamic>> _callGemini(String prompt) async {
    final response = await http.post(
      Uri.parse('$_baseUrl?key=$_apiKey'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'contents': [
          {
            'parts': [
              {'text': prompt}
            ]
          }
        ],
        'generationConfig': {
          'temperature': 0.4,
          'topK': 40,
          'topP': 0.95,
          'maxOutputTokens': 2048,
        },
        'safetySettings': [
          {
            'category': 'HARM_CATEGORY_HARASSMENT',
            'threshold': 'BLOCK_NONE'
          },
          {
            'category': 'HARM_CATEGORY_HATE_SPEECH',
            'threshold': 'BLOCK_NONE'
          }
        ]
      }),
    );

    if (response.statusCode != 200) {
      throw Exception(
          'Gemini API error ${response.statusCode}: ${response.body}');
    }

    final data = jsonDecode(response.body);
    final text =
        data['candidates'][0]['content']['parts'][0]['text'] as String;

    // Strip markdown code fences if present
    final cleaned = text
        .replaceAll('```json', '')
        .replaceAll('```', '')
        .trim();

    return jsonDecode(cleaned) as Map<String, dynamic>;
  }
}
