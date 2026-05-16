import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/insight_result.dart';

class ActionCard extends StatelessWidget {
  final int index;
  final ActionItem action;
  final VoidCallback onToggle;

  const ActionCard({
    super.key,
    required this.index,
    required this.action,
    required this.onToggle,
  });

  Color _priorityColor() {
    switch (action.priority) {
      case 'Immediate':
        return const Color(0xFFEF4444);
      case 'Short-term':
        return const Color(0xFFF59E0B);
      default:
        return const Color(0xFF3B82F6);
    }
  }

  Color _effortColor() {
    switch (action.effort) {
      case 'High':
        return const Color(0xFFEF4444);
      case 'Medium':
        return const Color(0xFFF59E0B);
      default:
        return const Color(0xFF10B981);
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final pColor = _priorityColor();
    final eColor = _effortColor();

    return GestureDetector(
      onTap: onToggle,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 350),
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          gradient: action.isExecuted
              ? LinearGradient(
                  colors: [
                    const Color(0xFF10B981).withOpacity(0.08),
                    const Color(0xFF059669).withOpacity(0.04),
                  ],
                )
              : LinearGradient(
                  colors: [
                    cs.surfaceContainerHighest.withOpacity(0.5),
                    cs.surfaceContainerHighest.withOpacity(0.2),
                  ],
                ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: action.isExecuted
                ? const Color(0xFF10B981).withOpacity(0.5)
                : cs.outline.withOpacity(0.2),
            width: action.isExecuted ? 1.5 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: (action.isExecuted ? const Color(0xFF10B981) : pColor)
                  .withOpacity(0.06),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Header row ──────────────────────────────────────────────
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Index / check circle
                AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: action.isExecuted
                        ? const Color(0xFF10B981)
                        : pColor.withOpacity(0.12),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: action.isExecuted
                        ? const Icon(Icons.check_rounded,
                            color: Colors.white, size: 16)
                        : Text(
                            '${index + 1}',
                            style: GoogleFonts.inter(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: pColor,
                            ),
                          ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    action.title,
                    style: GoogleFonts.inter(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: cs.onSurface,
                      decoration:
                          action.isExecuted ? TextDecoration.lineThrough : null,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                // Priority badge
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: pColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: pColor.withOpacity(0.25)),
                  ),
                  child: Text(
                    action.priority,
                    style: GoogleFonts.inter(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: pColor,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 10),

            // ── Description ──────────────────────────────────────────────
            Text(
              action.description,
              style: GoogleFonts.inter(
                fontSize: 13,
                color: cs.onSurface.withOpacity(0.68),
                height: 1.6,
              ),
            ),

            const SizedBox(height: 12),

            // ── Metadata row ──────────────────────────────────────────────
            Row(
              children: [
                // Effort
                _Badge(
                  icon: Icons.bolt_rounded,
                  label: 'Effort: ${action.effort}',
                  color: eColor,
                ),
                const SizedBox(width: 8),
                // Department
                _Badge(
                  icon: Icons.groups_2_outlined,
                  label: action.department,
                  color: cs.primary,
                ),
              ],
            ),

            const SizedBox(height: 10),

            // ── Expected outcome ──────────────────────────────────────────
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: cs.primaryContainer.withOpacity(0.35),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  Icon(Icons.trending_up_rounded,
                      size: 14, color: cs.primary),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      action.expectedOutcome,
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: cs.onSurface.withOpacity(0.72),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // ── Executed banner ───────────────────────────────────────────
            if (action.isExecuted) ...[
              const SizedBox(height: 10),
              Row(
                children: [
                  const Icon(Icons.check_circle_rounded,
                      size: 15, color: Color(0xFF10B981)),
                  const SizedBox(width: 6),
                  Text(
                    'Marked as executed',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF10B981),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const _Badge(
      {required this.icon, required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: GoogleFonts.inter(
                fontSize: 11, fontWeight: FontWeight.w600, color: color),
          ),
        ],
      ),
    );
  }
}
