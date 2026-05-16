import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/insight_result.dart';

class SimulationPanel extends StatefulWidget {
  final SimulationResult simulation;

  const SimulationPanel({super.key, required this.simulation});

  @override
  State<SimulationPanel> createState() => _SimulationPanelState();
}

class _SimulationPanelState extends State<SimulationPanel> {
  bool _showAfter = false;
  int _visibleLogs = 0;
  bool _isRunning = false;

  SimulationResult get sim => widget.simulation;

  Future<void> _runSimulation() async {
    setState(() {
      _isRunning = true;
      _visibleLogs = 0;
      _showAfter = false;
    });

    for (int i = 0; i < sim.executionLogs.length; i++) {
      await Future.delayed(const Duration(milliseconds: 650));
      if (mounted) setState(() => _visibleLogs = i + 1);
    }

    await Future.delayed(const Duration(milliseconds: 400));
    if (mounted) setState(() { _showAfter = true; _isRunning = false; });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Before / After ─────────────────────────────────────────────
        Row(
          children: [
            Expanded(
              child: _StateCard(
                label: 'BEFORE',
                content: sim.beforeState,
                isActive: !_showAfter,
                color: const Color(0xFFF59E0B),
                icon: Icons.history_rounded,
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: AnimatedOpacity(
                opacity: _showAfter ? 1 : 0.3,
                duration: 400.ms,
                child: const Icon(Icons.arrow_forward_rounded,
                    color: Color(0xFF10B981), size: 22),
              ),
            ),
            Expanded(
              child: _StateCard(
                label: 'AFTER',
                content: _showAfter ? sim.afterState : '...',
                isActive: _showAfter,
                color: const Color(0xFF10B981),
                icon: Icons.check_circle_outline_rounded,
              ),
            ),
          ],
        ).animate().fadeIn(delay: 100.ms),

        const SizedBox(height: 20),

        // ── Terminal log ───────────────────────────────────────────────
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: const Color(0xFF0D1117),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: const Color(0xFF30363D)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Terminal title bar
              Row(
                children: [
                  _Dot(color: const Color(0xFFFF5F57)),
                  const SizedBox(width: 6),
                  _Dot(color: const Color(0xFFFFBD2E)),
                  const SizedBox(width: 6),
                  _Dot(color: const Color(0xFF28C840)),
                  const SizedBox(width: 12),
                  Text(
                    'execution.log',
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      color: const Color(0xFF8B949E),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              const Divider(color: Color(0xFF21262D), height: 1),
              const SizedBox(height: 10),
              // Log lines
              ...List.generate(
                _visibleLogs,
                (i) => Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('▶ ',
                          style: TextStyle(
                              color: Color(0xFF3FB950),
                              fontSize: 11,
                              fontFamily: 'monospace')),
                      Expanded(
                        child: Text(
                          sim.executionLogs[i],
                          style: const TextStyle(
                            color: Color(0xFFE6EDF3),
                            fontSize: 11,
                            fontFamily: 'monospace',
                            height: 1.5,
                          ),
                        ),
                      ),
                    ],
                  ),
                ).animate().fadeIn(duration: 300.ms),
              ),
              // Blinking cursor
              if (_isRunning || _visibleLogs == 0)
                const Text('█',
                    style: TextStyle(
                        color: Color(0xFF3FB950),
                        fontSize: 12,
                        fontFamily: 'monospace'))
                    .animate(onPlay: (c) => c.repeat())
                    .fadeIn(duration: 500.ms),
            ],
          ),
        ).animate().fadeIn(delay: 200.ms),

        const SizedBox(height: 16),

        // ── Run button ──────────────────────────────────────────────────
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: _isRunning ? null : _runSimulation,
            icon: _isRunning
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.play_arrow_rounded, size: 20),
            label: Text(
              _isRunning
                  ? 'Running simulation...'
                  : _showAfter
                      ? 'Re-run Simulation'
                      : 'Run Simulation',
              style: GoogleFonts.inter(
                  fontSize: 15, fontWeight: FontWeight.w600),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF7C3AED),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14)),
            ),
          ),
        ),
      ],
    );
  }
}

class _StateCard extends StatelessWidget {
  final String label;
  final String content;
  final bool isActive;
  final Color color;
  final IconData icon;

  const _StateCard({
    required this.label,
    required this.content,
    required this.isActive,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 400),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isActive ? color.withOpacity(0.08) : Colors.transparent,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isActive
              ? color.withOpacity(0.45)
              : cs.outline.withOpacity(0.2),
          width: isActive ? 1.5 : 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 13, color: isActive ? color : Colors.grey),
              const SizedBox(width: 5),
              Text(
                label,
                style: GoogleFonts.inter(
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.8,
                  color: isActive ? color : Colors.grey,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            content,
            style: GoogleFonts.inter(
              fontSize: 12,
              color: isActive
                  ? cs.onSurface.withOpacity(0.82)
                  : Colors.grey,
              height: 1.5,
            ),
            maxLines: 4,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

class _Dot extends StatelessWidget {
  final Color color;
  const _Dot({required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
        width: 12, height: 12, decoration: BoxDecoration(color: color, shape: BoxShape.circle));
  }
}
