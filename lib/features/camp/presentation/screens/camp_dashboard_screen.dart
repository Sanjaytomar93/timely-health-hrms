import 'package:flutter/material.dart';
import 'package:timelay_health/core/theme/portal_text.dart';
import 'package:timelay_health/features/camp/presentation/models/camp_dashboard_ui.dart';
import 'package:timelay_health/features/camp/presentation/theme/camp_colors.dart';
import 'package:timelay_health/features/camp/presentation/widgets/camp_dashboard_sections.dart';
import 'package:timelay_health/features/camp/presentation/widgets/camp_top_bar.dart';

class CampDashboardScreen extends StatefulWidget {
  const CampDashboardScreen({super.key});

  @override
  State<CampDashboardScreen> createState() => _CampDashboardScreenState();
}

class _CampDashboardScreenState extends State<CampDashboardScreen> {
  final _data = CampDashboardUi.demo();
  DateTime? _from;
  DateTime? _to;
  bool _showSugar = false;

  Future<void> _pickDate({required bool isFrom}) async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: (isFrom ? _from : _to) ?? now,
      firstDate: DateTime(now.year - 3),
      lastDate: DateTime(now.year + 1),
    );
    if (picked == null || !mounted) return;
    setState(() {
      if (isFrom) {
        _from = picked;
      } else {
        _to = picked;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: CampColors.background,
      child: Column(
        children: [
          const CampTopBar(),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.only(bottom: 24),
              children: [
                CampHeroWithStats(data: _data),
                CampDateFilterCard(
                  from: _from,
                  to: _to,
                  onPickFrom: () => _pickDate(isFrom: true),
                  onPickTo: () => _pickDate(isFrom: false),
                  onReset: () => setState(() {
                    _from = null;
                    _to = null;
                  }),
                ),
                CampDistributionCard(data: _data),
                CampBmiCard(items: _data.bmi),
                CampBpAnalysisCard(
                  data: _data,
                  showSugar: _showSugar,
                  onToggle: (v) => setState(() => _showSugar = v),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class CampPlaceholderTab extends StatelessWidget {
  const CampPlaceholderTab({super.key, required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: CampColors.background,
      child: Column(
        children: [
          const CampTopBar(),
          Expanded(
            child: Center(
              child: Text(
                '$title coming soon',
                style: portalText(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: CampColors.muted,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
