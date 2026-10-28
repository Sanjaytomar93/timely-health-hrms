import 'package:flutter/material.dart';
import 'package:timelay_health/features/camp/presentation/models/patient_list_ui.dart';
import 'package:timelay_health/features/camp/presentation/theme/camp_colors.dart';
import 'package:timelay_health/features/camp/presentation/widgets/camp_top_bar.dart';
import 'package:timelay_health/features/camp/presentation/widgets/patient_widgets.dart';

class PatientsScreen extends StatefulWidget {
  const PatientsScreen({super.key});

  @override
  State<PatientsScreen> createState() => _PatientsScreenState();
}

class _PatientsScreenState extends State<PatientsScreen> {
  final _data = PatientListUi.demo();
  final _search = TextEditingController();
  String _filter = 'All';
  String _query = '';

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  // ── Filtered list ────────────────────────────────────────────
  List<PatientUi> get _filtered {
    return _data.patients.where((p) {
      final q = _query.trim().toLowerCase();
      final matchesQuery = q.isEmpty ||
          p.name.toLowerCase().contains(q) ||
          p.phone.toLowerCase().contains(q) ||
          (p.campTag?.toLowerCase().contains(q) ?? false);

      final matchesFilter = switch (_filter) {
        'Female' => p.gender == PatientGender.female,
        'Male' => p.gender == PatientGender.male,
        'Minors' => p.age < 18,
        _ => true,
      };

      return matchesQuery && matchesFilter;
    }).toList();
  }

  // ── Count badges for filter chips ────────────────────────────
  Map<String, int> get _counts {
    final all = _data.patients;
    return {
      'All': all.length,
      'Female': all.where((p) => p.gender == PatientGender.female).length,
      'Male': all.where((p) => p.gender == PatientGender.male).length,
      'Minors': all.where((p) => p.age < 18).length,
    };
  }

  @override
  Widget build(BuildContext context) {
    final patients = _filtered;

    return ColoredBox(
      color: CampColors.background,
      child: Column(
        children: [
          // ── Shared top bar ─────────────────────────────────
          const CampTopBar(),

          // ── Scrollable body ────────────────────────────────
          Expanded(
            child: CustomScrollView(
              physics: const BouncingScrollPhysics(
                parent: AlwaysScrollableScrollPhysics(),
              ),
              slivers: [
                // ── Gradient hero banner
                SliverToBoxAdapter(
                  child: PatientsHeroHeader(data: _data),
                ),

                // ── Stat grid (below hero, in-flow)
                SliverToBoxAdapter(
                  child: PatientsStatGrid(stats: _data.stats),
                ),

                // ── Search bar
                SliverToBoxAdapter(
                  child: PatientsSearchBar(
                    controller: _search,
                    onChanged: (v) => setState(() => _query = v),
                  ),
                ),

                // ── Filter chips with counts
                SliverToBoxAdapter(
                  child: PatientsFilterChips(
                    selected: _filter,
                    onSelected: (v) => setState(() => _filter = v),
                    counts: _counts,
                  ),
                ),

                const SliverToBoxAdapter(child: SizedBox(height: 4)),

                // ── Section header
                if (patients.isNotEmpty)
                  SliverToBoxAdapter(
                    child: PatientsSectionHeader(
                      label: _filter == 'All'
                          ? 'All Patients'
                          : '$_filter Patients',
                      count: patients.length,
                    ),
                  ),

                // ── Accordion patient cards
                if (patients.isEmpty)
                  const SliverFillRemaining(
                    hasScrollBody: false,
                    child: PatientsEmptyState(),
                  )
                else
                  SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, i) => PatientAccordionCard(
                        patient: patients[i],
                        index: i,
                        onView: () {},
                        onEdit: () {},
                        onDelete: () {},
                      ),
                      childCount: patients.length,
                    ),
                  ),

                // ── Add new patient CTA
                SliverToBoxAdapter(
                  child: PatientsAddNewButton(onTap: () {}),
                ),

                // Bottom padding for nav bar
                const SliverToBoxAdapter(child: SizedBox(height: 12)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
