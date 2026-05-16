// ─── InsightResult Model ──────────────────────────────────────────────────────

class InsightResult {
  final String id;
  final String rawInput;
  final String summary;
  final List<String> keyFacts;
  final String insight;
  final String insightType;
  final String impactAnalysis;
  final String severity;
  final List<ActionItem> actions;
  final SimulationResult simulation;
  final List<AgentStep> agentTrace;
  final DateTime timestamp;
  final List<String> fileNames;
  final String? userId;

  InsightResult({
    required this.id,
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
    this.fileNames = const [],
    this.userId,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'raw_input': rawInput,
        'summary': summary,
        'key_facts': keyFacts,
        'insight': insight,
        'insight_type': insightType,
        'impact_analysis': impactAnalysis,
        'severity': severity,
        'actions': actions.map((a) => a.toJson()).toList(),
        'simulation': simulation.toJson(),
        'agent_trace': agentTrace.map((s) => s.toJson()).toList(),
        'timestamp': timestamp.toIso8601String(),
        'file_names': fileNames,
        'user_id': userId,
      };

  factory InsightResult.fromJson(Map<String, dynamic> json) {
    return InsightResult(
      id: json['id'] ?? '',
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
      simulation: SimulationResult.fromJson(json['simulation'] ?? {}),
      agentTrace: (json['agent_trace'] as List<dynamic>? ?? [])
          .map((s) => AgentStep.fromJson(s))
          .toList(),
      timestamp:
          DateTime.tryParse(json['timestamp'] ?? '') ?? DateTime.now(),
      fileNames: List<String>.from(json['file_names'] ?? []),
      userId: json['user_id'],
    );
  }
}

// ─── ActionItem ───────────────────────────────────────────────────────────────

class ActionItem {
  final String title;
  final String description;
  final String priority;
  final String expectedOutcome;
  final String effort;
  final String department;
  bool isExecuted;

  ActionItem({
    required this.title,
    required this.description,
    required this.priority,
    required this.expectedOutcome,
    this.effort = 'Medium',
    this.department = 'General',
    this.isExecuted = false,
  });

  Map<String, dynamic> toJson() => {
        'title': title,
        'description': description,
        'priority': priority,
        'expected_outcome': expectedOutcome,
        'effort': effort,
        'department': department,
        'is_executed': isExecuted,
      };

  factory ActionItem.fromJson(Map<String, dynamic> json) {
    return ActionItem(
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      priority: json['priority'] ?? 'Short-term',
      expectedOutcome: json['expected_outcome'] ?? '',
      effort: json['effort'] ?? 'Medium',
      department: json['department'] ?? 'General',
      isExecuted: json['is_executed'] ?? false,
    );
  }
}

// ─── SimulationResult ─────────────────────────────────────────────────────────

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

  Map<String, dynamic> toJson() => {
        'action_executed': actionExecuted,
        'before_state': beforeState,
        'after_state': afterState,
        'execution_logs': executionLogs,
        'outcome': outcome,
        'metrics': metrics,
      };

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

// ─── AgentStep ────────────────────────────────────────────────────────────────

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

  Map<String, dynamic> toJson() => {
        'step_name': stepName,
        'reasoning': reasoning,
        'output': output,
        'duration_ms': durationMs,
      };

  factory AgentStep.fromJson(Map<String, dynamic> json) {
    return AgentStep(
      stepName: json['step_name'] ?? '',
      reasoning: json['reasoning'] ?? '',
      output: json['output'] ?? '',
      durationMs: json['duration_ms'] ?? 0,
    );
  }
}
