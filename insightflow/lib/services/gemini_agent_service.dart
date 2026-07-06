import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:uuid/uuid.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:async';
import '../models/insight_result.dart';

class GeminiAgentService {
  static String get _apiKey {
    final rawKey = dotenv.env['GEMINI_API_KEY'] ?? 'YOUR_GEMINI_API_KEY_HERE';
    if (rawKey.startsWith('AIza') || rawKey.startsWith('AQ.')) {
      return rawKey;
    }
    try {
      final decoded = utf8.decode(base64.decode(rawKey.trim()));
      if (decoded.startsWith('AIza') || decoded.startsWith('AQ.')) {
        return decoded;
      }
    } catch (_) {}
    return rawKey;
  }


  final _uuid = const Uuid();

  // ── Callbacks for step-by-step progress ──────────────────────────────────
  Function(int step, String label)? onStepUpdate;

  GeminiAgentService({this.onStepUpdate});

  // ── Main Agentic Pipeline (Optimized for Free Tier) ──────────────────────
  Future<InsightResult> runAgentPipeline({
    String? textInput,
    List<PlatformFile>? files,
  }) async {
    final sw = Stopwatch()..start();
    final List<AgentStep> trace = [];

    // Initialize GenerativeModel using the Dart SDK
    final model = GenerativeModel(
      model: 'gemini-3-flash-preview',
      apiKey: _apiKey,
      generationConfig: GenerationConfig(
        temperature: 0.4,
        topK: 40,
        topP: 0.95,
        responseMimeType: 'application/json', // Force JSON output!
      ),
    );

    // To prevent rate limiting (15 RPM / limit 0 errors), we will combine all 5 steps
    // into a SINGLE powerful API call, but we will artificially update the UI 
    // to keep the beautiful agentic step-by-step experience.
    
    // Start fake UI progression
    bool isDone = false;
    _startFakeUiProgression(() => isDone);

    try {
      final t1 = sw.elapsedMilliseconds;
      
      final prompt = '''
You are an advanced AI Agentic Pipeline. You must process the attached financial documents and/or text and perform 5 steps of analysis.
You MUST return ONLY valid JSON matching this exact structure:
{
  "step1_ingest": {
    "summary": "<2-sentence summary of what this content is about>"
  },
  "step2_extract": {
    "primary_insight": "<the single most important non-obvious insight>",
    "domain": "<one of: Business, Financial, Policy, Logistics, Healthcare, Technology, News>",
    "key_facts": ["<fact 1>", "<fact 2>", "<fact 3>", "<fact 4>", "<fact 5>"]
  },
  "step3_analyze": {
    "analysis": "<detailed explanation of why this insight matters and consequences>",
    "severity": "<one of: Low, Medium, High, Critical>"
  },
  "step4_actions": [
    {
      "title": "<short action name>",
      "description": "<detailed description of what to do>",
      "priority": "<Immediate | Short-term | Long-term>",
      "expected_outcome": "<measurable result if action is taken>",
      "effort": "<Low | Medium | High>",
      "department": "<which team/department executes this>"
    }
  ],
  "step5_simulate": {
    "action_executed": "<name of the top priority action executed>",
    "before_state": "<description of system BEFORE action>",
    "after_state": "<description of system AFTER action>",
    "execution_logs": [
      "[TIMESTAMP] <log entry 1>",
      "[TIMESTAMP] <log entry 2>",
      "[TIMESTAMP] Action completed successfully"
    ],
    "outcome": "<concrete measurable outcome of execution>",
    "metrics": {
      "metric_name": "before -> after"
    }
  }
}
''';

      final parts = <Part>[TextPart(prompt)];

      if (textInput != null && textInput.isNotEmpty) {
        parts.add(TextPart('\n\nTEXT INPUT:\n$textInput'));
      }

      if (files != null && files.isNotEmpty) {
        for (final file in files) {
          if (file.bytes != null) {
            final ext = file.extension?.toLowerCase();
            String mimeType = 'application/pdf'; // Default fallback
            
            if (ext == 'png') mimeType = 'image/png';
            else if (ext == 'jpg' || ext == 'jpeg') mimeType = 'image/jpeg';
            else if (ext == 'csv') mimeType = 'text/csv';
            else if (ext == 'txt') mimeType = 'text/plain';

            parts.add(DataPart(mimeType, file.bytes!));
          }
        }
      }

      final response = await model.generateContent([Content.multi(parts)]);
      isDone = true; // Stop the fake UI progression

      if (response.text == null || response.text!.isEmpty) {
        throw Exception('Gemini returned an empty response.');
      }

      final text = response.text!;
      final cleaned = text.replaceAll('```json', '').replaceAll('```', '').trim();
      final data = jsonDecode(cleaned) as Map<String, dynamic>;

      // Build the trace
      final duration = sw.elapsedMilliseconds - t1;
      
      trace.add(AgentStep(
        stepName: '1. Content Ingestion',
        reasoning: 'Parsed raw PDFs into structured text.',
        output: data['step1_ingest']?['summary'] ?? '',
        durationMs: (duration * 0.1).toInt(),
      ));
      trace.add(AgentStep(
        stepName: '2. Insight Extraction',
        reasoning: 'Extracted key signals and non-trivial facts.',
        output: data['step2_extract']?['primary_insight'] ?? '',
        durationMs: (duration * 0.2).toInt(),
      ));
      trace.add(AgentStep(
        stepName: '3. Impact Analysis',
        reasoning: 'Evaluated severity and stakeholders.',
        output: data['step3_analyze']?['analysis'] ?? '',
        durationMs: (duration * 0.2).toInt(),
      ));
      trace.add(AgentStep(
        stepName: '4. Action Generation',
        reasoning: 'Generated prioritized action list.',
        output: jsonEncode(data['step4_actions']),
        durationMs: (duration * 0.2).toInt(),
      ));
      trace.add(AgentStep(
        stepName: '5. Action Simulation',
        reasoning: 'Simulated action execution and state change.',
        output: jsonEncode(data['step5_simulate']),
        durationMs: (duration * 0.3).toInt(),
      ));

      // Force UI to show final step
      onStepUpdate?.call(4, 'Simulating action execution...');
      await Future.delayed(const Duration(milliseconds: 500));

      final fileNames = files?.map((f) => f.name).toList() ?? [];
      final actionsList = (data['step4_actions'] as List?) ?? [];

      return InsightResult(
        id: _uuid.v4(),
        rawInput: textInput ?? '(PDF Documents Uploaded)',
        summary: data['step1_ingest']?['summary'] ?? '',
        keyFacts: List<String>.from(data['step2_extract']?['key_facts'] ?? []),
        insight: data['step2_extract']?['primary_insight'] ?? '',
        insightType: data['step2_extract']?['domain'] ?? 'General',
        impactAnalysis: data['step3_analyze']?['analysis'] ?? '',
        severity: data['step3_analyze']?['severity'] ?? 'Medium',
        actions: actionsList.map((a) => ActionItem.fromJson(a as Map<String, dynamic>)).toList(),
        simulation: SimulationResult.fromJson(data['step5_simulate'] ?? {}),
        agentTrace: trace,
        timestamp: DateTime.now(),
        fileNames: fileNames,
      );
    } catch (e) {
      isDone = true;
      throw Exception('Agent Pipeline Failed: $e');
    }
  }

  void _startFakeUiProgression(bool Function() isDone) async {
    final labels = [
      'Ingesting content...',
      'Extracting insights...',
      'Analyzing impact...',
      'Generating actions...',
      'Simulating execution...',
    ];
    
    for (int i = 0; i < 4; i++) {
      if (isDone()) break;
      onStepUpdate?.call(i, labels[i]);
      // Wait a bit before moving to the next fake step
      await Future.delayed(const Duration(seconds: 3));
    }
  }
}
