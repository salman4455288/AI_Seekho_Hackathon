import 'dart:convert';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/insight_result.dart';

class SupabaseService {
  static final SupabaseService _instance = SupabaseService._internal();
  factory SupabaseService() => _instance;
  SupabaseService._internal();

  SupabaseClient get _client => Supabase.instance.client;

  // ── Auth ──────────────────────────────────────────────────────────────────

  Future<AuthResponse> signInAnonymously() async {
    return await _client.auth.signInAnonymously();
  }

  Future<AuthResponse> signUpWithEmail(String email, String password) async {
    return await _client.auth.signUp(email: email, password: password);
  }

  Future<AuthResponse> signInWithEmail(String email, String password) async {
    return await _client.auth.signInWithPassword(
      email: email,
      password: password,
    );
  }

  Future<void> signOut() async {
    await _client.auth.signOut();
  }

  User? get currentUser => _client.auth.currentUser;
  bool get isAuthenticated => currentUser != null;

  Stream<AuthState> get authStateChanges => _client.auth.onAuthStateChange;

  // ── Insight Results CRUD ──────────────────────────────────────────────────

  /// Save a new InsightResult to Supabase
  Future<void> saveInsight(InsightResult result) async {
    final row = {
      'id': result.id,
      'user_id': currentUser?.id,
      'raw_input': result.rawInput,
      'summary': result.summary,
      'key_facts': result.keyFacts,
      'insight': result.insight,
      'insight_type': result.insightType,
      'impact_analysis': result.impactAnalysis,
      'severity': result.severity,
      'actions': result.actions.map((a) => a.toJson()).toList(),
      'simulation': result.simulation.toJson(),
      'agent_trace': result.agentTrace.map((s) => s.toJson()).toList(),
      'timestamp': result.timestamp.toIso8601String(),
      'file_names': result.fileNames,
    };

    await _client.from('insight_results').upsert(row);
  }

  /// Fetch all insights for the current user (newest first)
  Future<List<InsightResult>> fetchMyInsights() async {
    final uid = currentUser?.id;
    if (uid == null) return [];

    final data = await _client
        .from('insight_results')
        .select()
        .eq('user_id', uid)
        .order('timestamp', ascending: false)
        .limit(50);

    return (data as List)
        .map((row) => InsightResult.fromJson(_normalizeRow(row)))
        .toList();
  }

  /// Delete a specific insight
  Future<void> deleteInsight(String id) async {
    await _client.from('insight_results').delete().eq('id', id);
  }

  // ── Analytics ─────────────────────────────────────────────────────────────

  /// Count insights by severity for the current user
  Future<Map<String, int>> getSeverityStats() async {
    final uid = currentUser?.id;
    if (uid == null) return {};

    final data = await _client
        .from('insight_results')
        .select('severity')
        .eq('user_id', uid);

    final counts = <String, int>{};
    for (final row in (data as List)) {
      final sev = row['severity'] as String? ?? 'Unknown';
      counts[sev] = (counts[sev] ?? 0) + 1;
    }
    return counts;
  }

  /// Count insights by domain type for the current user
  Future<Map<String, int>> getDomainStats() async {
    final uid = currentUser?.id;
    if (uid == null) return {};

    final data = await _client
        .from('insight_results')
        .select('insight_type')
        .eq('user_id', uid);

    final counts = <String, int>{};
    for (final row in (data as List)) {
      final type = row['insight_type'] as String? ?? 'General';
      counts[type] = (counts[type] ?? 0) + 1;
    }
    return counts;
  }

  // ── Helpers ───────────────────────────────────────────────────────────────

  /// Supabase returns JSONB as Maps – normalize nested lists/maps
  Map<String, dynamic> _normalizeRow(Map<String, dynamic> row) {
    return {
      ...row,
      'key_facts': _asList<String>(row['key_facts']),
      'file_names': _asList<String>(row['file_names']),
      'actions': _asList<Map<String, dynamic>>(row['actions']),
      'agent_trace': _asList<Map<String, dynamic>>(row['agent_trace']),
      'simulation': row['simulation'] is Map
          ? row['simulation'] as Map<String, dynamic>
          : jsonDecode(row['simulation'].toString()),
    };
  }

  List<T> _asList<T>(dynamic value) {
    if (value == null) return [];
    if (value is List) return value.cast<T>();
    if (value is String) {
      final decoded = jsonDecode(value);
      if (decoded is List) return decoded.cast<T>();
    }
    return [];
  }
}
