import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:file_picker/file_picker.dart';
import '../services/gemini_agent_service.dart';
import '../services/supabase_service.dart';
import 'result_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  final TextEditingController _controller = TextEditingController();
  List<PlatformFile> _selectedFiles = [];
  bool _isProcessing = false;
  int _stepIndex = 0;
  // ignore: unused_field
  String _stepLabel = '';
  late AnimationController _pulseCtrl;

  final _supabase = SupabaseService();

  final List<String> _stepLabels = [
    'Ingesting content...',
    'Extracting insights...',
    'Analyzing impact...',
    'Generating actions...',
    'Simulating execution...',
  ];

  @override
  void initState() {
    super.initState();
    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    _pulseCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickFiles() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        allowMultiple: true,
        type: FileType.custom,
        allowedExtensions: ['pdf'],
        withData: true, // Crucial: loads bytes into memory for Gemini!
      );

      if (result != null) {
        setState(() {
          // Add new files to existing ones, avoiding exact duplicates by name
          for (final file in result.files) {
            if (!_selectedFiles.any((f) => f.name == file.name)) {
              _selectedFiles.add(file);
            }
          }
        });
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error picking files: $e')),
      );
    }
  }

  void _removeFile(PlatformFile file) {
    setState(() {
      _selectedFiles.remove(file);
    });
  }

  Future<void> _runAnalysis() async {
    if (_controller.text.trim().isEmpty && _selectedFiles.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please enter text or upload PDFs to analyze',
              style: GoogleFonts.inter()),
          backgroundColor: const Color(0xFFEF4444),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
      return;
    }

    setState(() {
      _isProcessing = true;
      _stepIndex = 0;
      _stepLabel = _stepLabels[0];
    });

    final service = GeminiAgentService(
      onStepUpdate: (step, label) {
        if (mounted) {
          setState(() {
            _stepIndex = step;
            _stepLabel = label;
          });
        }
      },
    );

    try {
      final result = await service.runAgentPipeline(
        textInput: _controller.text.trim(),
        files: _selectedFiles.isNotEmpty ? _selectedFiles : null,
      );

      // Save to Supabase (fire-and-forget)
      _supabase.saveInsight(result).catchError((_) {});

      if (!mounted) return;
      setState(() => _isProcessing = false);

      Navigator.push(
        context,
        PageRouteBuilder(
          pageBuilder: (_, a1, a2) => ResultScreen(result: result),
          transitionsBuilder: (_, anim, __, child) => FadeTransition(
            opacity: anim,
            child: SlideTransition(
              position: Tween(begin: const Offset(0.05, 0), end: Offset.zero)
                  .animate(CurvedAnimation(parent: anim, curve: Curves.easeOut)),
              child: child,
            ),
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _isProcessing = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString()}', style: GoogleFonts.inter()),
          backgroundColor: const Color(0xFFEF4444),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          duration: const Duration(seconds: 6),
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
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 500),
          child: _isProcessing ? _buildProcessingView(cs) : _buildInputView(cs),
        ),
      ),
    );
  }

  // ── Processing Screen ────────────────────────────────────────────────────
  Widget _buildProcessingView(ColorScheme cs) {
    return Center(
      key: const ValueKey('processing'),
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedBuilder(
              animation: _pulseCtrl,
              builder: (_, __) => Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      const Color(0xFF7C3AED),
                      const Color(0xFF7C3AED)
                          .withOpacity(0.3 + 0.4 * _pulseCtrl.value),
                      Colors.transparent,
                    ],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF7C3AED)
                          .withOpacity(0.3 + 0.2 * _pulseCtrl.value),
                      blurRadius: 30 + 20 * _pulseCtrl.value,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: const Icon(Icons.auto_awesome,
                    color: Colors.white, size: 44),
              ),
            ),
            const SizedBox(height: 36),
            Text(
              'Running Agent Pipeline',
              style: GoogleFonts.inter(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: cs.onSurface,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Powered by Gemini 1.5 Flash Vision',
              style: GoogleFonts.inter(
                fontSize: 13,
                color: cs.onSurface.withOpacity(0.45),
              ),
            ),
            const SizedBox(height: 32),
            ...List.generate(_stepLabels.length, (i) {
              final isDone = i < _stepIndex;
              final isCurrent = i == _stepIndex;
              return Padding(
                padding: const EdgeInsets.only(bottom: 14),
                child: Row(
                  children: [
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isDone
                            ? const Color(0xFF7C3AED)
                            : isCurrent
                                ? const Color(0xFF7C3AED).withOpacity(0.15)
                                : cs.surfaceContainerHighest.withOpacity(0.5),
                        border: isCurrent
                            ? Border.all(
                                color: const Color(0xFF7C3AED), width: 2)
                            : null,
                      ),
                      child: Center(
                        child: isDone
                            ? const Icon(Icons.check_rounded,
                                color: Colors.white, size: 16)
                            : isCurrent
                                ? const SizedBox(
                                    width: 16,
                                    height: 16,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Color(0xFF7C3AED),
                                    ),
                                  )
                                : Text(
                                    '${i + 1}',
                                    style: GoogleFonts.inter(
                                      fontSize: 13,
                                      color: cs.onSurface.withOpacity(0.3),
                                    ),
                                  ),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _stepLabels[i],
                            style: GoogleFonts.inter(
                              fontSize: 14,
                              fontWeight: isCurrent
                                  ? FontWeight.w600
                                  : FontWeight.w400,
                              color: isDone
                                  ? const Color(0xFF7C3AED)
                                  : isCurrent
                                      ? cs.onSurface
                                      : cs.onSurface.withOpacity(0.35),
                            ),
                          ),
                          if (isCurrent)
                            const LinearProgressIndicator(
                              backgroundColor: Colors.transparent,
                              color: Color(0xFF7C3AED),
                            ).animate(onPlay: (c) => c.repeat()).shimmer(
                                duration: 1200.ms,
                                color: const Color(0xFF7C3AED)),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  // ── Input Screen ─────────────────────────────────────────────────────────
  Widget _buildInputView(ColorScheme cs) {
    return SingleChildScrollView(
      key: const ValueKey('input'),
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 40),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header ──────────────────────────────────────────────
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF7C3AED), Color(0xFF4F46E5)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF7C3AED).withOpacity(0.35),
                      blurRadius: 14,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: const Icon(Icons.auto_awesome,
                    color: Colors.white, size: 26),
              ),
              const SizedBox(width: 14),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'InsightFlow',
                    style: GoogleFonts.inter(
                      fontSize: 26,
                      fontWeight: FontWeight.w800,
                      color: cs.onSurface,
                      letterSpacing: -0.5,
                    ),
                  ),
                  Text(
                    'Multimodal Agent',
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      color: cs.onSurface.withOpacity(0.5),
                    ),
                  ),
                ],
              ),
              const Spacer(),
              IconButton(
                onPressed: () => Navigator.pushNamed(context, '/history'),
                icon: const Icon(Icons.history_rounded),
                tooltip: 'History',
                style: IconButton.styleFrom(
                  backgroundColor: cs.surfaceContainerHighest.withOpacity(0.5),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ],
          ).animate().fadeIn(duration: 400.ms).slideY(begin: -0.15),

          const SizedBox(height: 28),

          // ── Upload Documents Zone ──────────────────────────────────
          Text(
            'Upload Financial Documents',
            style: GoogleFonts.inter(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: cs.onSurface,
            ),
          ),
          const SizedBox(height: 8),
          GestureDetector(
            onTap: _pickFiles,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 16),
              decoration: BoxDecoration(
                color: cs.surfaceContainerHighest.withOpacity(0.2),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: const Color(0xFF7C3AED).withOpacity(0.4),
                  width: 1.5,
                  style: BorderStyle.solid, // Flutter doesn't natively support dashed borders easily
                ),
              ),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFF7C3AED).withOpacity(0.15),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.upload_file_rounded,
                        size: 28, color: Color(0xFF7C3AED)),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Tap to browse PDFs',
                    style: GoogleFonts.inter(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: cs.onSurface,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Invoices, Tax Returns, Sales Reports',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: cs.onSurface.withOpacity(0.5),
                    ),
                  ),
                ],
              ),
            ),
          ).animate().fadeIn(delay: 100.ms),

          // ── Selected Files List ───────────────────────────────────
          if (_selectedFiles.isNotEmpty) ...[
            const SizedBox(height: 16),
            ..._selectedFiles.map((file) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(
                      color: cs.surfaceContainerHighest.withOpacity(0.4),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: cs.outline.withOpacity(0.3)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.picture_as_pdf_rounded,
                            color: Color(0xFFEF4444), size: 20),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                file.name,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: GoogleFonts.inter(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              Text(
                                '${(file.size / 1024).toStringAsFixed(1)} KB',
                                style: GoogleFonts.inter(
                                  fontSize: 11,
                                  color: cs.onSurface.withOpacity(0.5),
                                ),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          onPressed: () => _removeFile(file),
                          icon: const Icon(Icons.close_rounded, size: 18),
                          visualDensity: VisualDensity.compact,
                        ),
                      ],
                    ),
                  ),
                ).animate().fadeIn()),
          ],

          const SizedBox(height: 28),

          // ── Optional Text Context ──────────────────────────────────
          Text(
            'Additional Context (Optional)',
            style: GoogleFonts.inter(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: cs.onSurface,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: cs.outline.withOpacity(0.25), width: 1.5),
              color: cs.surfaceContainerHighest.withOpacity(0.3),
            ),
            child: TextField(
              controller: _controller,
              maxLines: 4,
              style: GoogleFonts.inter(fontSize: 14, height: 1.6),
              decoration: InputDecoration(
                hintText:
                    'E.g. "Focus specifically on the Q3 revenue drop in these invoices..."',
                hintStyle: GoogleFonts.inter(
                    color: cs.onSurface.withOpacity(0.38), fontSize: 14),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.all(18),
              ),
            ),
          ).animate().fadeIn(delay: 200.ms),

          const SizedBox(height: 32),

          // ── Run button ──────────────────────────────────────────────
          SizedBox(
            width: double.infinity,
            height: 58,
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF7C3AED), Color(0xFF4F46E5)],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF7C3AED).withOpacity(0.4),
                    blurRadius: 18,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: ElevatedButton.icon(
                onPressed: _runAnalysis,
                icon: const Icon(Icons.play_arrow_rounded, size: 22),
                label: Text(
                  'Run Agent Pipeline',
                  style: GoogleFonts.inter(
                      fontSize: 16, fontWeight: FontWeight.w700),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  foregroundColor: Colors.white,
                  shadowColor: Colors.transparent,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16)),
                ),
              ),
            ),
          ).animate().fadeIn(delay: 250.ms).slideY(begin: 0.15),

          const SizedBox(height: 16),
        ],
      ),
    );
  }
}
