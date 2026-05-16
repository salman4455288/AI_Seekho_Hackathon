import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/insight_result.dart';

class TraceTimeline extends StatelessWidget {
  final List<AgentStep> steps;

  const TraceTimeline({super.key, required this.steps});

  static const List<Color> _stepColors = [
    Color(0xFF5B4FCF),
    Color(0xFF0E76A8),
    Color(0xFFF4B942),
    Color(0xFFE8623A),
    Color(0xFF2EA96B),
  ];

  static const List<IconData> _stepIcons = [
    Icons.input_rounded,
    Icons.search_rounded,
    Icons.analytics_outlined,
    Icons.bolt_rounded,
    Icons.play_circle_outline,
  ];

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: cs.primaryContainer.withOpacity(0.3),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(Icons.account_tree_outlined,
                    size: 16, color: cs.primary),
                const SizedBox(width: 8),
                Text(
                  'Agent Reasoning Trace',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: cs.primary,
                  ),
                ),
                const Spacer(),
                Text(
                  '${steps.length} steps',
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: cs.primary.withOpacity(0.7),
                  ),
                ),
              ],
            ),
          ).animate().fadeIn(),

          const SizedBox(height: 20),

          // Timeline steps
          ...steps.asMap().entries.map((entry) {
            final i = entry.key;
            final step = entry.value;
            final color = _stepColors[i % _stepColors.length];
            final icon = _stepIcons[i % _stepIcons.length];
            final isLast = i == steps.length - 1;

            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Left: icon + line
                Column(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: color.withOpacity(0.15),
                        shape: BoxShape.circle,
                        border: Border.all(
                            color: color.withOpacity(0.4), width: 1.5),
                      ),
                      child: Center(
                        child: Icon(icon, size: 18, color: color),
                      ),
                    ),
                    if (!isLast)
                      Container(
                        width: 2,
                        height: 100,
                        color: color.withOpacity(0.2),
                      ),
                  ],
                ),
                const SizedBox(width: 14),
                // Right: content
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(
                      bottom: isLast ? 0 : 16,
                    ),
                    child: Container(
                      padding: const EdgeInsets.all(14),
                      margin: const EdgeInsets.only(bottom: 8),
                      decoration: BoxDecoration(
                        color: cs.surfaceContainerHighest.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                            color: color.withOpacity(0.2)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment:
                                MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                step.stepName,
                                style: GoogleFonts.inter(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                  color: color,
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(
                                  color: color.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Text(
                                  '${step.durationMs}ms',
                                  style: GoogleFonts.inter(
                                    fontSize: 10,
                                    color: color,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Text(
                            step.reasoning,
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              color:
                                  cs.onSurface.withOpacity(0.6),
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: const Color(0xFF0D1117),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              step.output.length > 200
                                  ? '${step.output.substring(0, 200)}...'
                                  : step.output,
                              style: const TextStyle(
                                fontSize: 11,
                                color: Color(0xFF8B949E),
                                fontFamily: 'monospace',
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ).animate().fadeIn(delay: (150 * i).ms).slideX(begin: -0.05);
          }),

          const SizedBox(height: 20),

          // Total time
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: cs.surfaceContainerHighest.withOpacity(0.3),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.timer_outlined, size: 16),
                const SizedBox(width: 6),
                Text(
                  'Total processing: ${steps.fold(0, (sum, s) => sum + s.durationMs)}ms',
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    color: cs.onSurface.withOpacity(0.6),
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
