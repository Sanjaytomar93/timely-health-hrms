import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:timelay_health/features/camp/dashboard/presentation/theme/camp_colors.dart';
import 'package:timelay_health/features/camp/dashboard/presentation/widgets/camp_top_bar.dart';
import 'package:timelay_health/features/camp/patients/presentation/bloc/patients_cubit.dart';
import 'package:timelay_health/features/camp/patients/presentation/bloc/patients_state.dart';
import 'package:timelay_health/features/camp/patients/presentation/models/patient_list_ui.dart';
import 'package:timelay_health/features/camp/patients/presentation/screens/post_create_patient_screen.dart';
import 'package:timelay_health/features/camp/patients/presentation/widgets/add_patient_sheet.dart';
import 'package:timelay_health/features/camp/patients/presentation/widgets/delete_patient_dialog.dart';
import 'package:timelay_health/features/camp/patients/presentation/widgets/patient_accordion_card.dart';
import 'package:timelay_health/features/camp/patients/presentation/widgets/patients_empty_state.dart';
import 'package:timelay_health/features/camp/patients/presentation/widgets/patients_filter_chips.dart';
import 'package:timelay_health/features/camp/patients/presentation/widgets/patients_hero_header.dart';
import 'package:timelay_health/features/camp/patients/presentation/widgets/patients_search_bar.dart';
import 'package:timelay_health/features/camp/patients/presentation/widgets/patients_section_header.dart';
import 'package:timelay_health/features/camp/patients/presentation/widgets/patients_stat_grid.dart';
import 'package:timelay_health/features/camp/patients/presentation/widgets/share_report_sheet.dart';
import 'package:timelay_health/features/camp/shared/camp_shimmer.dart';

class PatientsScreen extends StatelessWidget {
  const PatientsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => PatientsCubit()..load(),
      child: const _PatientsView(),
    );
  }
}

class _PatientsView extends StatefulWidget {
  const _PatientsView();

  @override
  State<_PatientsView> createState() => _PatientsViewState();
}

class _PatientsViewState extends State<_PatientsView> {
  final _search = TextEditingController();
  final _scroll = ScrollController();

  @override
  void initState() {
    super.initState();
    _scroll.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scroll
      ..removeListener(_onScroll)
      ..dispose();
    _search.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!_scroll.hasClients) return;
    final pos = _scroll.position;
    if (pos.pixels < pos.maxScrollExtent - 240) return;
    context.read<PatientsCubit>().loadMore();
  }

  Map<String, int> _counts(List<PatientUi> all) {
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
    await openPostCreatePatientScreen(context, patient: created);
    if (!mounted) return;
    context.read<PatientsCubit>().load(keepExisting: true);
  }

  Future<void> _onDeletePatient(PatientUi patient) async {
    final deleted = await showDeletePatientDialog(context, patient: patient);
    if (!deleted || !mounted) return;
    context.read<PatientsCubit>().load(keepExisting: true);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${patient.name} deleted.'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: CampColors.background,
      child: Column(
        children: [
          const CampTopBar(),
          Expanded(
            child: BlocBuilder<PatientsCubit, PatientsState>(
              builder: (context, state) {
                final loading =
                    state is PatientsLoading && state.data.patients.isEmpty;

                if (loading) {
                  return const CampPatientsShimmer();
                }

                final data = state.data;
                final patients = state.patients;

                return RefreshIndicator(
                  onRefresh: () =>
                      context.read<PatientsCubit>().load(keepExisting: true),
                  child: CustomScrollView(
                    controller: _scroll,
                    physics: const BouncingScrollPhysics(
                      parent: AlwaysScrollableScrollPhysics(),
                    ),
                    slivers: [
                      SliverToBoxAdapter(
                        child: PatientsHeroHeader(
                          data: data,
                          onAddPatient: _openAddPatientFlow,
                        ),
                      ),
                      if (data.stats.isNotEmpty)
                        SliverToBoxAdapter(
                          child: PatientsStatGrid(stats: data.stats),
                        ),
                      SliverToBoxAdapter(
                        child: PatientsSearchBar(
                          controller: _search,
                          onChanged: (v) =>
                              context.read<PatientsCubit>().setSearch(v),
                        ),
                      ),
                      SliverToBoxAdapter(
                        child: PatientsFilterChips(
                          selected: state.filter,
                          onSelected: (v) =>
                              context.read<PatientsCubit>().setFilter(v),
                          counts: _counts(data.patients),
                        ),
                      ),
                      if (state is PatientsFailureState &&
                          data.patients.isEmpty)
                        SliverToBoxAdapter(
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(18, 12, 18, 8),
                            child: Text(
                              state.message,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontSize: 12,
                                color: CampColors.muted,
                              ),
                            ),
                          ),
                        ),
                      const SliverToBoxAdapter(child: SizedBox(height: 4)),
                      if (patients.isNotEmpty)
                        SliverToBoxAdapter(
                          child: PatientsSectionHeader(
                            label: state.filter == 'All'
                                ? 'All Patients'
                                : '${state.filter} Patients',
                            count: state.filteredCount,
                          ),
                        ),
                      if (patients.isEmpty &&
                          state is! PatientsFailureState)
                        const SliverFillRemaining(
                          hasScrollBody: false,
                          child: PatientsEmptyState(),
                        )
                      else if (patients.isNotEmpty)
                        SliverList(
                          delegate: SliverChildBuilderDelegate(
                            (context, i) => PatientAccordionCard(
                              patient: patients[i],
                              index: i,
                              onView: () {},
                              onEdit: () {},
                              onDelete: () => _onDeletePatient(patients[i]),
                              onWhatsApp: () => showShareReportSheet(
                                context,
                                patient: patients[i],
                              ),
                            ),
                            childCount: patients.length,
                          ),
                        ),
                      const SliverToBoxAdapter(child: SizedBox(height: 12)),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
