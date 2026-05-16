class InsightResult {
  final String rawInput;
  final String summary;
  final List<String> keyFacts;
  final String insight;
  final String insightType; // e.g. "Business", "Policy", "Financial"
  final String impactAnalysis;
  final String severity; // "Low", "Medium", "High", "Critical"
  final List<ActionItem> actions;
  final SimulationResult simulation;
  final List<AgentStep> agentTrace;
  final DateTime timestamp;

  InsightResult({
    required this.rawInput,
    required this.summary,
    required this.keyFacts,
    required this.insight,
    required this.insightType,
    required this.impactAnalysis,
    required this.severity,
    required this.actions,
    required this.simulation,
    required this.agentTrace,
    required this.timestamp,
  });

  factory InsightResult.fromJson(Map<String, dynamic> json) {
    return InsightResult(
      rawInput: json['raw_input'] ?? '',
      summary: json['summary'] ?? '',
      keyFacts: List<String>.from(json['key_facts'] ?? []),
      insight: json['insight'] ?? '',
      insightType: json['insight_type'] ?? 'General',
      impactAnalysis: json['impact_analysis'] ?? '',
      severity: json['severity'] ?? 'Medium',
      actions: (json['actions'] as List<dynamic>? ?? [])
          .map((a) => ActionItem.fromJson(a))
          .toList(),
      simulation: SimulationResult.fromJson(
          json['simulation'] ?? {}),
      agentTrace: (json['agent_trace'] as List<dynamic>? ?? [])
          .map((s) => AgentStep.fromJson(s))
          .toList(),
      timestamp: DateTime.now(),
    );
  }
}

class ActionItem {
  final String title;
  final String description;
  final String priority; // "Immediate", "Short-term", "Long-term"
  final String expectedOutcome;
  bool isExecuted;

  ActionItem({
    required this.title,
    required this.description,
    required this.priority,
    required this.expectedOutcome,
    this.isExecuted = false,
  });

  factory ActionItem.fromJson(Map<String, dynamic> json) {
    return ActionItem(
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      priority: json['priority'] ?? 'Short-term',
      expectedOutcome: json['expected_outcome'] ?? '',
    );
  }
}

class SimulationResult {
  final String actionExecuted;
  final String beforeState;
  final String afterState;
  final List<String> executionLogs;
  final String outcome;
  final Map<String, dynamic> metrics;

  SimulationResult({
    required this.actionExecuted,
    required this.beforeState,
    required this.afterState,
    required this.executionLogs,
    required this.outcome,
    required this.metrics,
  });

  factory SimulationResult.fromJson(Map<String, dynamic> json) {
    return SimulationResult(
      actionExecuted: json['action_executed'] ?? '',
      beforeState: json['before_state'] ?? '',
      afterState: json['after_state'] ?? '',
      executionLogs: List<String>.from(json['execution_logs'] ?? []),
      outcome: json['outcome'] ?? '',
      metrics: Map<String, dynamic>.from(json['metrics'] ?? {}),
    );
  }
}

class AgentStep {
  final String stepName;
  final String reasoning;
  final String output;
  final int durationMs;

  AgentStep({
    required this.stepName,
    required this.reasoning,
    required this.output,
    required this.durationMs,
  });

  factory AgentStep.fromJson(Map<String, dynamic> json) {
    return AgentStep(
      stepName: json['step_name'] ?? '',
      reasoning: json['reasoning'] ?? '',
      output: json['output'] ?? '',
      durationMs: json['duration_ms'] ?? 0,
    );
  }
}
