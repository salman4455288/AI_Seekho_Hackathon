import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/gemini_agent_service.dart';
import '../models/insight_result.dart';
import 'result_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _controller = TextEditingController();
  final GeminiAgentService _agentService = GeminiAgentService();
  bool _isProcessing = false;
  String _processingStep = '';
  int _stepIndex = 0;

  final List<Map<String, String>> _exampleInputs = [
    {
      'icon': '📊',
      'label': 'Sales Report',
      'text':
          'Q3 2024 Sales Report - Lahore Region\n\nTotal orders declined by 28% compared to Q2. Revenue dropped from PKR 4.2M to PKR 3.0M. Customer churn rate increased to 18%. Key product categories affected: Electronics (-35%), Apparel (-20%). Competitor XYZ launched aggressive discounts in August. Top 5 customer accounts have not reordered in 45+ days. Delivery complaints increased by 40% due to fuel price hikes. New customer acquisition cost has risen 60%.',
    },
    {
      'icon': '📰',
      'label': 'News Article',
      'text':
          'Breaking: State Bank of Pakistan Raises Interest Rate to 22%\n\nThe State Bank of Pakistan announced today an emergency rate hike from 19% to 22%, the highest in 25 years. The decision follows CPI inflation reaching 38% last month. This will directly impact SME loan costs and housing mortgage rates. Banks are expected to revise lending rates within 72 hours. The textile sector, Pakistan\'s largest export industry, is projected to face PKR 12 billion in additional financing costs. Experts warn 30,000 jobs may be at risk in the manufacturing sector.',
    },
    {
      'icon': '🏭',
      'label': 'Supply Chain',
      'text':
          'Supply Chain Disruption Alert - Manufacturing Facility Report\n\nPrimary supplier in Karachi flooded due to monsoon. 60% of raw material inventory compromised. Backup supplier in Faisalabad has only 30% of required capacity. Current production can continue for 8 days at current inventory levels. 12 active client orders worth USD 850,000 are at risk. Alternative import route via Gwadar adds 3-week lead time and 25% cost premium. Staff overtime already at maximum. Q4 delivery commitments to EU clients cannot be met without immediate action.',
    },
    {
      'icon': '🏙️',
      'label': 'Urban Policy',
      'text':
          'Islamabad CDA Monthly Report - G-Sectors Infrastructure Assessment\n\nWater supply to G-11 and G-12 sectors reduced by 45% due to main pipeline leakage. Estimated 85,000 residents affected. Repair timeline: 3-4 weeks. Power outages in I-8 increasing to 8 hours/day. Three schools and two hospitals reporting critical water shortage. Sewer overflow reported in G-9/1 posing public health risk. Dengue cases up 120% in affected areas compared to last year. Budget for emergency repairs: PKR 23 million approved but contractor not yet mobilized.',
    },
  ];

  final List<String> _steps = [
    'Ingesting content...',
    'Extracting insights...',
    'Analyzing impact...',
    'Generating actions...',
    'Simulating execution...',
  ];

  Future<void> _runAnalysis() async {
    if (_controller.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter some content to analyze')),
      );
      return;
    }

    setState(() {
      _isProcessing = true;
      _stepIndex = 0;
      _processingStep = _steps[0];
    });

    // Simulate step progression for UX
    final stepTimer = Stream.periodic(const Duration(seconds: 3), (i) => i)
        .take(_steps.length)
        .listen((i) {
      if (mounted && _isProcessing) {
        setState(() {
          _stepIndex = (i + 1).clamp(0, _steps.length - 1);
          _processingStep = _steps[_stepIndex];
        });
      }
    });

    try {
      final result =
          await _agentService.runAgentPipeline(_controller.text.trim());
      stepTimer.cancel();

      if (!mounted) return;
      setState(() => _isProcessing = false);

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ResultScreen(result: result),
        ),
      );
    } catch (e) {
      stepTimer.cancel();
      if (!mounted) return;
      setState(() => _isProcessing = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString()}'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 5),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: cs.surface,
      body: SafeArea(
        child: _isProcessing
            ? _buildProcessingView(cs)
            : _buildInputView(cs),
      ),
    );
  }

  Widget _buildInputView(ColorScheme cs) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 16),
          // Header
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: cs.primaryContainer,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(Icons.auto_awesome,
                    color: cs.primary, size: 28),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'InsightFlow',
                    style: GoogleFonts.inter(
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                      color: cs.onSurface,
                    ),
                  ),
                  Text(
                    'Content → Insight → Action',
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      color: cs.onSurface.withOpacity(0.6),
                    ),
                  ),
                ],
              ),
            ],
          ).animate().fadeIn(duration: 400.ms).slideY(begin: -0.2),

          const SizedBox(height: 28),

          // Input area
          Text(
            'Paste your content',
            style: GoogleFonts.inter(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: cs.onSurface,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                  color: cs.outline.withOpacity(0.3), width: 1.5),
              color: cs.surfaceContainerHighest.withOpacity(0.3),
            ),
            child: TextField(
              controller: _controller,
              maxLines: 8,
              style: GoogleFonts.inter(fontSize: 14),
              decoration: InputDecoration(
                hintText:
                    'Paste a report, news article, dashboard data, policy document...',
                hintStyle: GoogleFonts.inter(
                  color: cs.onSurface.withOpacity(0.4),
                  fontSize: 14,
                ),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.all(16),
              ),
            ),
          ).animate().fadeIn(delay: 100.ms),

          const SizedBox(height: 20),

          // Quick examples
          Text(
            'Or try an example',
            style: GoogleFonts.inter(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: cs.onSurface.withOpacity(0.7),
            ),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _exampleInputs
                .asMap()
                .entries
                .map((entry) => _ExampleChip(
                      icon: entry.value['icon']!,
                      label: entry.value['label']!,
                      onTap: () {
                        _controller.text = entry.value['text']!;
                      },
                    ))
                .toList(),
          ).animate().fadeIn(delay: 200.ms),

          const SizedBox(height: 32),

          // Agent pipeline info
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: cs.primaryContainer.withOpacity(0.3),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                  color: cs.primary.withOpacity(0.2), width: 1),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.account_tree_outlined,
                        color: cs.primary, size: 18),
                    const SizedBox(width: 8),
                    Text(
                      'Agentic Pipeline (Gemini 1.5 Flash)',
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: cs.primary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                ...[
                  '① Ingest & clean content',
                  '② Extract non-trivial insights',
                  '③ Analyze real-world impact',
                  '④ Generate prioritized actions',
                  '⑤ Simulate action execution',
                ].map((step) => Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Text(
                        step,
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          color: cs.onSurface.withOpacity(0.7),
                        ),
                      ),
                    )),
              ],
            ),
          ).animate().fadeIn(delay: 300.ms),

          const SizedBox(height: 28),

          // Run button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _runAnalysis,
              icon: const Icon(Icons.play_arrow_rounded, size: 22),
              label: Text(
                'Run Agent Pipeline',
                style: GoogleFonts.inter(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: cs.primary,
                foregroundColor: cs.onPrimary,
                padding:
                    const EdgeInsets.symmetric(vertical: 18),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
          ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.2),

          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildProcessingView(ColorScheme cs) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Animated icon
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: cs.primaryContainer,
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.auto_awesome,
                  color: cs.primary, size: 40),
            )
                .animate(onPlay: (c) => c.repeat())
                .shimmer(duration: 1500.ms, color: cs.primary.withOpacity(0.3)),

            const SizedBox(height: 32),

            Text(
              'Analyzing Content...',
              style: GoogleFonts.inter(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: cs.onSurface,
              ),
            ),

            const SizedBox(height: 24),

            // Step progress
            ...List.generate(_steps.length, (i) {
              final isDone = i < _stepIndex;
              final isCurrent = i == _stepIndex;
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Row(
                  children: [
                    AnimatedContainer(
                      duration: 300.ms,
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isDone
                            ? cs.primary
                            : isCurrent
                                ? cs.primaryContainer
                                : cs.surfaceContainerHighest,
                      ),
                      child: Center(
                        child: isDone
                            ? Icon(Icons.check,
                                color: cs.onPrimary, size: 16)
                            : isCurrent
                                ? SizedBox(
                                    width: 16,
                                    height: 16,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: cs.primary,
                                    ),
                                  )
                                : Text(
                                    '${i + 1}',
                                    style: GoogleFonts.inter(
                                      fontSize: 12,
                                      color: cs.onSurface.withOpacity(0.4),
                                    ),
                                  ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        _steps[i],
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          fontWeight: isCurrent
                              ? FontWeight.w600
                              : FontWeight.w400,
                          color: isCurrent
                              ? cs.onSurface
                              : isDone
                                  ? cs.primary
                                  : cs.onSurface.withOpacity(0.4),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }),

            const SizedBox(height: 32),

            Text(
              'Powered by Gemini 1.5 Flash',
              style: GoogleFonts.inter(
                fontSize: 12,
                color: cs.onSurface.withOpacity(0.4),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ExampleChip extends StatelessWidget {
  final String icon;
  final String label;
  final VoidCallback onTap;

  const _ExampleChip({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: cs.secondaryContainer.withOpacity(0.5),
          borderRadius: BorderRadius.circular(20),
          border:
              Border.all(color: cs.outline.withOpacity(0.3)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(icon, style: const TextStyle(fontSize: 16)),
            const SizedBox(width: 6),
            Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: cs.onSecondaryContainer,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
