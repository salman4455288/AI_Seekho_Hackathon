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

  Color _priorityColor(String priority) {
    switch (priority) {
      case 'Immediate':
        return Colors.red;
      case 'Short-term':
        return Colors.orange;
      default:
        return Colors.blue;
    }
  }

  Color _effortColor(String effort) {
    switch (effort) {
      case 'High':
        return Colors.red;
      case 'Medium':
        return Colors.orange;
      default:
        return Colors.green;
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final priorityColor = _priorityColor(action.priority);

    return GestureDetector(
      onTap: onToggle,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: action.isExecuted
              ? Colors.green.withOpacity(0.08)
              : cs.surfaceContainerHighest.withOpacity(0.3),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: action.isExecuted
                ? Colors.green.withOpacity(0.4)
                : cs.outline.withOpacity(0.2),
            width: action.isExecuted ? 1.5 : 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                // Index circle
                Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color: action.isExecuted
                        ? Colors.green
                        : priorityColor.withOpacity(0.15),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: action.isExecuted
                        ? const Icon(Icons.check,
                            color: Colors.white, size: 14)
                        : Text(
                            '${index + 1}',
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: priorityColor,
                            ),
                          ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    action.title,
                    style: GoogleFonts.inter(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: cs.onSurface,
                      decoration: action.isExecuted
                          ? TextDecoration.lineThrough
                          : null,
                    ),
                  ),
                ),
                // Priority badge
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: priorityColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    action.priority,
                    style: GoogleFonts.inter(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: priorityColor,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              action.description,
              style: GoogleFonts.inter(
                fontSize: 13,
                color: cs.onSurface.withOpacity(0.7),
                height: 1.5,
              ),
            ),
            const SizedBox(height: 10),
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: cs.primaryContainer.withOpacity(0.4),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(Icons.trending_up,
                      size: 14,
                      color: cs.primary),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      action.expectedOutcome,
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: cs.onSurface.withOpacity(0.7),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            if (action.isExecuted) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.check_circle,
                      size: 14, color: Colors.green),
                  const SizedBox(width: 4),
                  Text(
                    'Marked as executed',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: Colors.green,
                      fontWeight: FontWeight.w500,
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
