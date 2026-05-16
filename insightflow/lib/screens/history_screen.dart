import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/supabase_service.dart';
import '../models/insight_result.dart';
import 'result_screen.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  final _supa = SupabaseService();
  List<InsightResult> _items = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() { _loading = true; _error = null; });
    try {
      final data = await _supa.fetchMyInsights();
      if (mounted) setState(() { _items = data; _loading = false; });
    } catch (e) {
      if (mounted) setState(() { _error = e.toString(); _loading = false; });
    }
  }

  Future<void> _delete(InsightResult item) async {
    await _supa.deleteInsight(item.id);
    setState(() => _items.remove(item));
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Deleted', style: GoogleFonts.inter()),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
    }
  }

  Color _sevColor(String sev) {
    switch (sev) {
      case 'Critical': return const Color(0xFFEF4444);
      case 'High':     return const Color(0xFFF97316);
      case 'Medium':   return const Color(0xFFF59E0B);
      default:         return const Color(0xFF10B981);
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: cs.surface,
      appBar: AppBar(
        backgroundColor: cs.surface,
        elevation: 0,
        title: Text('History',
            style: GoogleFonts.inter(
                fontWeight: FontWeight.w700, fontSize: 20)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: _load,
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.cloud_off_rounded,
                          size: 48, color: Colors.grey),
                      const SizedBox(height: 12),
                      Text('Could not load history\n(add Supabase keys in .env)',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.inter(
                              color: cs.onSurface.withOpacity(0.5))),
                      const SizedBox(height: 16),
                      ElevatedButton(onPressed: _load, child: const Text('Retry')),
                    ],
                  ),
                )
              : _items.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.history_rounded,
                              size: 64, color: cs.onSurface.withOpacity(0.2)),
                          const SizedBox(height: 16),
                          Text('No analyses yet',
                              style: GoogleFonts.inter(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w700,
                                  color: cs.onSurface.withOpacity(0.4))),
                          const SizedBox(height: 6),
                          Text('Run your first pipeline from home',
                              style: GoogleFonts.inter(
                                  color: cs.onSurface.withOpacity(0.35))),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
                      itemCount: _items.length,
                      itemBuilder: (context, i) {
                        final item = _items[i];
                        final sevColor = _sevColor(item.severity);

                        return Dismissible(
                          key: ValueKey(item.id),
                          direction: DismissDirection.endToStart,
                          background: Container(
                            alignment: Alignment.centerRight,
                            padding: const EdgeInsets.only(right: 20),
                            decoration: BoxDecoration(
                              color: const Color(0xFFEF4444).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(18),
                            ),
                            child: const Icon(Icons.delete_rounded,
                                color: Color(0xFFEF4444)),
                          ),
                          onDismissed: (_) => _delete(item),
                          child: Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: GestureDetector(
                              onTap: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => ResultScreen(result: item),
                                ),
                              ),
                              child: Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: cs.surfaceContainerHighest
                                      .withOpacity(0.35),
                                  borderRadius: BorderRadius.circular(18),
                                  border: Border.all(
                                      color: cs.outline.withOpacity(0.18)),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // Header
                                    Row(
                                      children: [
                                        // Domain chip
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 10, vertical: 4),
                                          decoration: BoxDecoration(
                                            color: const Color(0xFF7C3AED)
                                                .withOpacity(0.1),
                                            borderRadius:
                                                BorderRadius.circular(12),
                                          ),
                                          child: Text(
                                            item.insightType,
                                            style: GoogleFonts.inter(
                                              fontSize: 11,
                                              fontWeight: FontWeight.w700,
                                              color: const Color(0xFF7C3AED),
                                            ),
                                          ),
                                        ),
                                        const Spacer(),
                                        // Severity dot
                                        Container(
                                          width: 8,
                                          height: 8,
                                          decoration: BoxDecoration(
                                            color: sevColor,
                                            shape: BoxShape.circle,
                                          ),
                                        ),
                                        const SizedBox(width: 5),
                                        Text(
                                          item.severity,
                                          style: GoogleFonts.inter(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w600,
                                            color: sevColor,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 10),
                                    // Insight
                                    Text(
                                      item.insight,
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      style: GoogleFonts.inter(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                        color: cs.onSurface.withOpacity(0.88),
                                        height: 1.5,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    // Footer
                                    Row(
                                      children: [
                                        Icon(Icons.access_time_rounded,
                                            size: 13,
                                            color:
                                                cs.onSurface.withOpacity(0.38)),
                                        const SizedBox(width: 4),
                                        Text(
                                          item.timestamp
                                              .toLocal()
                                              .toString()
                                              .substring(0, 16),
                                          style: GoogleFonts.inter(
                                            fontSize: 12,
                                            color:
                                                cs.onSurface.withOpacity(0.4),
                                          ),
                                        ),
                                        const Spacer(),
                                        Text(
                                          '${item.actions.length} actions',
                                          style: GoogleFonts.inter(
                                            fontSize: 12,
                                            color:
                                                cs.onSurface.withOpacity(0.4),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ).animate().fadeIn(delay: (60 * i).ms).slideY(begin: 0.05),
                          ),
                        );
                      },
                    ),
    );
  }
}
