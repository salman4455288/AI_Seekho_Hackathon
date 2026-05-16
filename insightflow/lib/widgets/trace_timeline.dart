import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/insight_result.dart';

class TraceTimeline extends StatelessWidget {
  final List<AgentStep> steps;

  const TraceTimeline({super.key, required this.steps});

  static const List<Color> _colors = [
    Color(0xFF7C3AED),
    Color(0xFF0284C7),
    Color(0xFFF59E0B),
    Color(0xFFEF4444),
    Color(0xFF10B981),
  ];

  static const List<IconData> _icons = [
    Icons.input_rounded,
    Icons.manage_search_rounded,
    Icons.analytics_outlined,
    Icons.bolt_rounded,
    Icons.play_circle_outline_rounded,
  ];

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final totalMs = steps.fold(0, (sum, s) => sum + s.durationMs);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header ────────────────────────────────────────────────────
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: [
                cs.primaryContainer.withOpacity(0.5),
                cs.primaryContainer.withOpacity(0.2),
              ]),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              children: [
                Icon(Icons.account_tree_outlined, size: 18, color: cs.primary),
                const SizedBox(width: 10),
                Text(
                  'Agent Reasoning Trace',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: cs.primary,
                  ),
                ),
                const Spacer(),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: cs.primary.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '${steps.length} steps • ${totalMs}ms',
                    style: GoogleFonts.inter(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: cs.primary),
                  ),
                ),
              ],
            ),
          ).animate().fadeIn(),

          const SizedBox(height: 24),

          // ── Steps ──────────────────────────────────────────────────────
          ...steps.asMap().entries.map((entry) {
            final i = entry.key;
            final step = entry.value;
            final color = _colors[i % _colors.length];
            final icon = _icons[i % _icons.length];
            final isLast = i == steps.length - 1;

            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Left: icon + connector line
                SizedBox(
                  width: 48,
                  child: Column(
                    children: [
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              color.withOpacity(0.25),
                              color.withOpacity(0.1),
                            ],
                          ),
                          shape: BoxShape.circle,
                          border: Border.all(
                              color: color.withOpacity(0.5), width: 1.5),
                          boxShadow: [
                            BoxShadow(
                              color: color.withOpacity(0.2),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Center(
                          child: Icon(icon, size: 20, color: color),
                        ),
                      ),
                      if (!isLast)
                        Container(
                          width: 2,
                          height: 90,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                color.withOpacity(0.4),
                                color.withOpacity(0.05),
                              ],
                            ),
                          ),
                        ),
                    ],
                  ),
                ),

                const SizedBox(width: 12),

                // Right: content card
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(bottom: isLast ? 0 : 12),
                    child: Container(
                      padding: const EdgeInsets.all(14),
                      margin: const EdgeInsets.only(bottom: 8),
                      decoration: BoxDecoration(
                        color: cs.surfaceContainerHighest.withOpacity(0.35),
                        borderRadius: BorderRadius.circular(14),
                        border:
                            Border.all(color: color.withOpacity(0.25)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Step name + duration
                          Row(
                            mainAxisAlignment:
                                MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  step.stepName,
                                  style: GoogleFonts.inter(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w700,
                                    color: color,
                                  ),
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                  color: color.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Text(
                                  '${step.durationMs}ms',
                                  style: GoogleFonts.inter(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w600,
                                    color: color,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          // Reasoning
                          Text(
                            step.reasoning,
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              color: cs.onSurface.withOpacity(0.58),
                              fontStyle: FontStyle.italic,
                              height: 1.5,
                            ),
                          ),
                          const SizedBox(height: 8),
                          // Output preview (terminal style)
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: const Color(0xFF0D1117),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              step.output.length > 220
                                  ? '${step.output.substring(0, 220)}...'
                                  : step.output,
                              style: const TextStyle(
                                fontSize: 11,
                                color: Color(0xFF8B949E),
                                fontFamily: 'monospace',
                                height: 1.5,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ).animate().fadeIn(delay: (150 * i).ms).slideX(begin: -0.04);
          }),

          const SizedBox(height: 8),

          // ── Total time ─────────────────────────────────────────────────
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: cs.surfaceContainerHighest.withOpacity(0.3),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: cs.outline.withOpacity(0.15)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.timer_outlined,
                    size: 16, color: cs.onSurface.withOpacity(0.5)),
                const SizedBox(width: 8),
                Text(
                  'Total pipeline: ${totalMs}ms across ${steps.length} agent steps',
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    color: cs.onSurface.withOpacity(0.55),
                  ),
                ),
              ],
            ),
          ).animate().fadeIn(delay: 800.ms),

          const SizedBox(height: 24),
        ],
      ),
    );
  }
}
