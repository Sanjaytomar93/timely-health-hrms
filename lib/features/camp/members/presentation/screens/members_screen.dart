import 'package:flutter/material.dart';
import 'package:timelay_health/features/camp/dashboard/presentation/theme/camp_colors.dart';
import 'package:timelay_health/features/camp/dashboard/presentation/widgets/camp_top_bar.dart';
import 'package:timelay_health/features/camp/members/presentation/models/patient_list_ui.dart';
import 'package:timelay_health/features/camp/members/presentation/screens/patient_detail_screen.dart';
import 'package:timelay_health/features/camp/members/presentation/widgets/add_medical_test_sheet.dart';
import 'package:timelay_health/features/camp/members/presentation/widgets/add_patient_sheet.dart';
import 'package:timelay_health/features/camp/members/presentation/widgets/patient_accordion_card.dart';
import 'package:timelay_health/features/camp/members/presentation/widgets/share_report_sheet.dart';
import 'package:timelay_health/features/camp/members/presentation/widgets/patients_add_new_button.dart';
import 'package:timelay_health/features/camp/members/presentation/widgets/patients_empty_state.dart';
import 'package:timelay_health/features/camp/members/presentation/widgets/patients_filter_chips.dart';
import 'package:timelay_health/features/camp/members/presentation/widgets/patients_hero_header.dart';
import 'package:timelay_health/features/camp/members/presentation/widgets/patients_search_bar.dart';
import 'package:timelay_health/features/camp/members/presentation/widgets/patients_section_header.dart';
import 'package:timelay_health/features/camp/members/presentation/widgets/patients_stat_grid.dart';

class MembersScreen extends StatefulWidget {
  const MembersScreen({super.key});

  @override
  State<MembersScreen> createState() => _MembersScreenState();
}

class _MembersScreenState extends State<MembersScreen> {
  final _data = PatientListUi.demo();
  final _search = TextEditingController();
  String _filter = 'All';
  String _query = '';

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

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

  Map<String, int> get _counts {
    final all = _data.patients;
    return {
      'All': all.length,
      'Female': all.where((p) => p.gender == PatientGender.female).length,
      'Male': all.where((p) => p.gender == PatientGender.male).length,
      'Minors': all.where((p) => p.age < 18).length,
    };
  }

  Future<void> _openAddPatientFlow() async {
    final created = await showAddPatientSheet(context);
    if (created == null || !mounted) return;
    final test = await showAddMedicalTestSheet(
      context,
      campName: created.campName,
      patientName: created.patientName,
    );
    if (test == null || !mounted) return;
    await openPatientDetailScreen(
      context,
      args: PatientDetailArgs(
        name: created.patientName,
        age: created.age,
        gender: created.gender,
        phone: created.phone,
        address: created.address,
        campName: created.campName,
        test: test,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final patients = _filtered;

    return ColoredBox(
      color: CampColors.background,
      child: Column(
        children: [
          const CampTopBar(),
          Expanded(
            child: CustomScrollView(
              physics: const BouncingScrollPhysics(
                parent: AlwaysScrollableScrollPhysics(),
              ),
              slivers: [
                SliverToBoxAdapter(
                  child: PatientsHeroHeader(
                    data: _data,
                    onAddPatient: _openAddPatientFlow,
                  ),
                ),
                SliverToBoxAdapter(
                  child: PatientsStatGrid(stats: _data.stats),
                ),
                SliverToBoxAdapter(
                  child: PatientsSearchBar(
                    controller: _search,
                    onChanged: (v) => setState(() => _query = v),
                  ),
                ),
                SliverToBoxAdapter(
                  child: PatientsFilterChips(
                    selected: _filter,
                    onSelected: (v) => setState(() => _filter = v),
                    counts: _counts,
                  ),
                ),
                const SliverToBoxAdapter(child: SizedBox(height: 4)),
                if (patients.isNotEmpty)
                  SliverToBoxAdapter(
                    child: PatientsSectionHeader(
                      label: _filter == 'All'
                          ? 'All Patients'
                          : '$_filter Patients',
                      count: patients.length,
                    ),
                  ),
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
                        onWhatsApp: () => showShareReportSheet(
                          context,
                          patient: patients[i],
                        ),
                      ),
                      childCount: patients.length,
                    ),
                  ),
                SliverToBoxAdapter(
                  child: PatientsAddNewButton(onTap: _openAddPatientFlow),
                ),
                const SliverToBoxAdapter(child: SizedBox(height: 12)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
