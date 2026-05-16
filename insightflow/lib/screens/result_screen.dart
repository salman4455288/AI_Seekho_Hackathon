import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/insight_result.dart';
import '../widgets/insight_card.dart';
import '../widgets/action_card.dart';
import '../widgets/trace_timeline.dart';
import '../widgets/simulation_panel.dart';

class ResultScreen extends StatefulWidget {
  final InsightResult result;

  const ResultScreen({super.key, required this.result});

  @override
  State<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Color _severityColor(String sev) {
    switch (sev) {
      case 'Critical':
        return const Color(0xFFEF4444);
      case 'High':
        return const Color(0xFFF97316);
      case 'Medium':
        return const Color(0xFFF59E0B);
      default:
        return const Color(0xFF10B981);
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final result = widget.result;
    final sevColor = _severityColor(result.severity);

    return Scaffold(
      backgroundColor: cs.surface,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: cs.surface,
        title: Text(
          'Analysis Result',
          style: GoogleFonts.inter(fontWeight: FontWeight.w700, fontSize: 18),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          // Severity badge
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
              decoration: BoxDecoration(
                color: sevColor.withOpacity(0.12),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: sevColor.withOpacity(0.4)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 7,
                    height: 7,
                    decoration: BoxDecoration(
                      color: sevColor,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    result.severity,
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: sevColor,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          labelStyle:
              GoogleFonts.inter(fontWeight: FontWeight.w700, fontSize: 13),
          unselectedLabelStyle:
              GoogleFonts.inter(fontWeight: FontWeight.w400, fontSize: 13),
          indicatorColor: const Color(0xFF7C3AED),
          labelColor: const Color(0xFF7C3AED),
          isScrollable: true,
          tabAlignment: TabAlignment.start,
          tabs: const [
            Tab(text: 'Insights'),
            Tab(text: 'Actions'),
            Tab(text: 'Simulate'),
            Tab(text: 'Trace'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _InsightsTab(result: result),
          _ActionsTab(result: result),
          _SimulateTab(result: result),
          TraceTimeline(steps: result.agentTrace),
        ],
      ),
    );
  }
}

// ── Insights Tab ──────────────────────────────────────────────────────────────

class _InsightsTab extends StatelessWidget {
  final InsightResult result;
  const _InsightsTab({required this.result});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Domain badge
          Row(
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: [
                    const Color(0xFF7C3AED).withOpacity(0.15),
                    const Color(0xFF4F46E5).withOpacity(0.08),
                  ]),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                      color: const Color(0xFF7C3AED).withOpacity(0.3)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.category_outlined,
                        size: 13, color: Color(0xFF7C3AED)),
                    const SizedBox(width: 6),
                    Text(
                      result.insightType,
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF7C3AED),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Text(
                result.timestamp
                    .toLocal()
                    .toString()
                    .substring(0, 16),
                style: GoogleFonts.inter(
                    fontSize: 12, color: cs.onSurface.withOpacity(0.4)),
              ),
            ],
          ).animate().fadeIn(),

          const SizedBox(height: 16),

          // Summary card
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: cs.surfaceContainerHighest.withOpacity(0.35),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: cs.outline.withOpacity(0.15)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.summarize_outlined,
                        size: 15, color: cs.onSurface.withOpacity(0.5)),
                    const SizedBox(width: 6),
                    Text(
                      'SUMMARY',
                      style: GoogleFonts.inter(
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.2,
                        color: cs.onSurface.withOpacity(0.45),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  result.summary,
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    height: 1.65,
                    color: cs.onSurface.withOpacity(0.82),
                  ),
                ),
              ],
            ),
          ).animate().fadeIn(delay: 80.ms),

          const SizedBox(height: 14),

          // Primary insight
          InsightCard(
            title: 'Primary Insight',
            content: result.insight,
            icon: Icons.lightbulb_rounded,
            color: const Color(0xFF7C3AED).withOpacity(0.08),
            iconColor: const Color(0xFF7C3AED),
          ),

          const SizedBox(height: 14),

          // Key facts
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: cs.surfaceContainerHighest.withOpacity(0.3),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: cs.outline.withOpacity(0.15)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.fact_check_outlined,
                        size: 16, color: Color(0xFF0284C7)),
                    const SizedBox(width: 8),
                    Text(
                      'Key Facts',
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF0284C7),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                ...result.keyFacts.asMap().entries.map((e) => Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 24,
                            height: 24,
                            decoration: const BoxDecoration(
                              color: Color(0xFF0284C7),
                              shape: BoxShape.circle,
                            ),
                            child: Center(
                              child: Text(
                                '${e.key + 1}',
                                style: const TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              e.value,
                              style: GoogleFonts.inter(
                                fontSize: 14,
                                height: 1.55,
                                color: cs.onSurface.withOpacity(0.82),
                              ),
                            ),
                          ),
                        ],
                      ),
                    )),
              ],
            ),
          ).animate().fadeIn(delay: 160.ms),

          const SizedBox(height: 14),

          // Impact analysis
          InsightCard(
            title: 'Impact Analysis',
            content: result.impactAnalysis,
            icon: Icons.trending_up_rounded,
            color: const Color(0xFFF59E0B).withOpacity(0.08),
            iconColor: const Color(0xFFF59E0B),
          ),
        ],
      ),
    );
  }
}

// ── Actions Tab ───────────────────────────────────────────────────────────────

class _ActionsTab extends StatefulWidget {
  final InsightResult result;
  const _ActionsTab({required this.result});

  @override
  State<_ActionsTab> createState() => _ActionsTabState();
}

class _ActionsTabState extends State<_ActionsTab> {
  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Recommended Actions',
              style: GoogleFonts.inter(
                  fontSize: 20, fontWeight: FontWeight.w800)),
          const SizedBox(height: 4),
          Text(
            'Ordered by priority — tap to mark as executed',
            style: GoogleFonts.inter(
                fontSize: 13, color: cs.onSurface.withOpacity(0.5)),
          ),
          const SizedBox(height: 16),
          ...widget.result.actions.asMap().entries.map(
                (entry) => Padding(
                  padding: const EdgeInsets.only(bottom: 14),
                  child: ActionCard(
                    index: entry.key,
                    action: entry.value,
                    onToggle: () => setState(
                        () => entry.value.isExecuted = !entry.value.isExecuted),
                  ),
                ).animate().fadeIn(delay: (120 * entry.key).ms).slideY(begin: 0.08),
              ),
        ],
      ),
    );
  }
}

// ── Simulate Tab ──────────────────────────────────────────────────────────────

class _SimulateTab extends StatelessWidget {
  final InsightResult result;
  const _SimulateTab({required this.result});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Action being simulated banner
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: [
                const Color(0xFF7C3AED).withOpacity(0.12),
                const Color(0xFF4F46E5).withOpacity(0.06),
              ]),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                  color: const Color(0xFF7C3AED).withOpacity(0.3)),
            ),
            child: Row(
              children: [
                const Icon(Icons.rocket_launch_rounded,
                    color: Color(0xFF7C3AED), size: 22),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'EXECUTING ACTION',
                        style: GoogleFonts.inter(
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1.2,
                          color: const Color(0xFF7C3AED),
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        result.simulation.actionExecuted,
                        style: GoogleFonts.inter(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: cs.onSurface,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ).animate().fadeIn(),

          const SizedBox(height: 20),

          // Metrics
          if (result.simulation.metrics.isNotEmpty) ...[
            Text('Impact Metrics',
                style: GoogleFonts.inter(
                    fontSize: 16, fontWeight: FontWeight.w700)),
            const SizedBox(height: 10),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: result.simulation.metrics.entries
                  .map((e) => _MetricChip(label: e.key, value: e.value.toString()))
                  .toList(),
            ),
            const SizedBox(height: 20),
          ],

          // Simulation panel
          SimulationPanel(simulation: result.simulation),

          // Outcome
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF10B981).withOpacity(0.08),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                  color: const Color(0xFF10B981).withOpacity(0.35)),
            ),
            child: Row(
              children: [
                const Icon(Icons.check_circle_rounded,
                    color: Color(0xFF10B981), size: 22),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'EXPECTED OUTCOME',
                        style: GoogleFonts.inter(
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1.2,
                          color: const Color(0xFF10B981),
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        result.simulation.outcome,
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          height: 1.55,
                          color: const Color(0xFF065F46),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ).animate().fadeIn(delay: 300.ms),
        ],
      ),
    );
  }
}

class _MetricChip extends StatelessWidget {
  final String label;
  final String value;
  const _MetricChip({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: cs.surfaceContainerHighest.withOpacity(0.4),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: cs.outline.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: GoogleFonts.inter(
                  fontSize: 11, color: cs.onSurface.withOpacity(0.5))),
          const SizedBox(height: 2),
          Text(value,
              style: GoogleFonts.inter(
                  fontSize: 15, fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }
}
