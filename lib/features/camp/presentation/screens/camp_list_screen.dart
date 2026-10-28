import 'package:flutter/material.dart';
import 'package:timelay_health/features/camp/presentation/models/camp_list_ui.dart';
import 'package:timelay_health/features/camp/presentation/theme/camp_colors.dart';
import 'package:timelay_health/features/camp/presentation/widgets/camp_list_widgets.dart';

class CampListScreen extends StatefulWidget {
  const CampListScreen({super.key});

  @override
  State<CampListScreen> createState() => _CampListScreenState();
}

class _CampListScreenState extends State<CampListScreen> {
  final _data = CampListUi.demo();
  final _search = TextEditingController();
  String _filter = 'All camps';
  String _query = '';

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  List<CampItemUi> get _filtered {
    return _data.camps.where((c) {
      final q = _query.trim().toLowerCase();
      final matchesQuery = q.isEmpty ||
          c.name.toLowerCase().contains(q) ||
          c.location.toLowerCase().contains(q);
      final matchesFilter = switch (_filter) {
        'Today' => c.status == CampListStatus.today,
        'Live' => c.status == CampListStatus.live,
        'Upcoming' => c.status == CampListStatus.upcoming,
        'Completed' => c.status == CampListStatus.completed,
        _ => true,
      };
      return matchesQuery && matchesFilter;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final camps = _filtered;
    final today = camps.where((c) => c.status == CampListStatus.today).toList();
    final completed =
        camps.where((c) => c.status == CampListStatus.completed).toList();
    final other = camps
        .where(
          (c) =>
              c.status != CampListStatus.today &&
              c.status != CampListStatus.completed,
        )
        .toList();

    return ColoredBox(
      color: CampColors.background,
      child: Column(
        children: [
          const CampListTopBar(),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.only(bottom: 24),
              children: [
                CampListSearchBar(
                  controller: _search,
                  onChanged: (v) => setState(() => _query = v),
                ),
                CampListStatStrip(stats: _data.stats),
                CampListFilterChips(
                  selected: _filter,
                  onSelected: (v) => setState(() => _filter = v),
                ),
                if (today.isNotEmpty) ...[
                  CampListSectionHeader(
                    title: 'Active today',
                    count: today.length,
                  ),
                  for (final c in today) CampListCard(camp: c),
                ],
                if (completed.isNotEmpty) ...[
                  CampListSectionHeader(
                    title: 'Completed',
                    count: completed.length,
                  ),
                  for (final c in completed) CampListCard(camp: c),
                ],
                if (other.isNotEmpty) ...[
                  CampListSectionHeader(
                    title: 'More camps',
                    count: other.length,
                  ),
                  for (final c in other) CampListCard(camp: c),
                ],
                if (camps.isEmpty)
                  const Padding(
                    padding: EdgeInsets.all(40),
                    child: Center(
                      child: Text(
                        'No camps found',
                        style: TextStyle(fontSize: 13, color: CampColors.muted),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
