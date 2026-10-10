import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:timelay_health/core/theme/portal_colors.dart';
import 'package:timelay_health/core/theme/portal_text.dart';
import 'package:timelay_health/core/widgets/shimmer.dart';
import 'package:timelay_health/features/issues/domain/failures/issue_failure.dart';
import 'package:timelay_health/features/issues/presentation/bloc/issues_cubit.dart';
import 'package:timelay_health/features/issues/presentation/bloc/issues_state.dart';
import 'package:timelay_health/features/issues/presentation/models/issue_ui_model.dart';
import 'package:timelay_health/features/issues/presentation/widgets/issue_details_dialog.dart';
import 'package:timelay_health/features/issues/presentation/widgets/raise_issue_sheet.dart';
import 'package:timelay_health/features/holidays/presentation/widgets/top_calendar_button.dart';
import 'package:timelay_health/features/notifications/presentation/widgets/top_notification_button.dart';
import 'package:timelay_health/core/widgets/portal_back_button.dart';
import 'package:timelay_health/core/widgets/portal_safe_area.dart';

class IssuesScreen extends StatelessWidget {
  const IssuesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => IssuesCubit()..load(),
      child: const _IssuesView(),
    );
  }
}

class _IssuesView extends StatefulWidget {
  const _IssuesView();

  @override
  State<_IssuesView> createState() => _IssuesViewState();
}

class _IssuesViewState extends State<_IssuesView> {
  final _search = TextEditingController();

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  Future<void> _confirmDelete(BuildContext context, IssueUiModel issue) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Are you sure?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed != true || !context.mounted) return;

    try {
      await context.read<IssuesCubit>().deleteIssue(issue.id);
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Issue deleted successfully'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            e is IssueFailure ? e.message : 'Failed to delete issue.',
          ),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Future<void> _openDetails(IssueUiModel issue) async {
    final action = await showIssueDetailsDialog(context, issue: issue);
    if (!mounted || action == null) return;
    if (action == IssueDetailAction.edit) {
      showEditIssueSheet(context, issue: issue);
    } else {
      _confirmDelete(context, issue);
    }
  }

  void _resetFilters() {
    _search.clear();
    context.read<IssuesCubit>().resetFilters();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: PortalColors.background,
      floatingActionButton: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(10),
        child: Ink(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [PortalColors.purpleMid, PortalColors.purpleSoft],
            ),
          ),
          child: InkWell(
            onTap: () => showRaiseIssueSheet(context),
            borderRadius: BorderRadius.circular(10),
            child: SizedBox(
              width: 72,
              height: 64,
              child: Center(
                child: Text(
                  '+',
                  style: portalText(
                    fontSize: 36,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                    height: 44 / 36,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      body: PortalSafeArea(
        bottom: false,
        child: Column(
          children: [
            const _IssuesAppBar(),
            Expanded(
              child: BlocBuilder<IssuesCubit, IssuesState>(
                builder: (context, state) {
                  final loading =
                      state is IssuesInitial || state is IssuesLoading;
                  final failure = state is IssuesFailureState ? state : null;
                  final showSpinner = loading && state.allIssues.isEmpty;
                  final showError = failure != null && state.allIssues.isEmpty;

                  return RefreshIndicator(
                    color: PortalColors.purple,
                    onRefresh: () =>
                        context.read<IssuesCubit>().load(keepExisting: true),
                    child: ListView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.only(bottom: 96),
                      children: [
                        const _IssuesHeader(),
                        const _ActionRow(),
                        _TotalChip(total: state.allIssues.length),
                        _SearchField(
                          controller: _search,
                          onChanged: context.read<IssuesCubit>().setSearch,
                        ),
                        _FiltersCard(
                          priority: state.priority,
                          status: state.status,
                          type: state.type,
                          onPriority: context.read<IssuesCubit>().setPriority,
                          onStatus: context.read<IssuesCubit>().setStatus,
                          onType: context.read<IssuesCubit>().setType,
                          onReset: _resetFilters,
                        ),
                        const _IssuesListHeader(),
                        if (showSpinner)
                          const ShimmerCardList(itemCount: 4)
                        else if (showError)
                          _IssuesError(
                            message: failure.message,
                            onRetry: () => context.read<IssuesCubit>().load(),
                          )
                        else
                          ...state.issues.map(
                            (issue) => _IssueCard(
                              issue: issue,
                              onView: () => _openDetails(issue),
                              onEdit: () =>
                                  showEditIssueSheet(context, issue: issue),
                              onDelete: () => _confirmDelete(context, issue),
                            ),
                          ),
                        _ShowingFooter(
                          showing: state.issues.length,
                          total: state.allIssues.length,
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _IssuesAppBar extends StatelessWidget {
  const _IssuesAppBar();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: PortalColors.surface,
      padding: const EdgeInsets.fromLTRB(18, 12, 18, 12),
      child: Row(
        children: [
          const PortalBackButton(),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'My Issues',
              style: portalText(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: PortalColors.heading,
                letterSpacing: 0.2,
                height: 21 / 13,
              ),
            ),
          ),
          const TopNotificationButton(
            asset: 'assets/icons/issues/ic_notification.svg',
          ),
          const SizedBox(width: 14),
          const TopCalendarButton(
            asset: 'assets/icons/issues/ic_notification_cal.svg',
          ),
        ],
      ),
    );
  }
}

class _IssuesHeader extends StatelessWidget {
  const _IssuesHeader();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 16, 18, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text.rich(
            TextSpan(
              children: [
                TextSpan(
                  text: 'My ',
                  style: portalText(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: PortalColors.heading,
                    height: 19 / 16,
                  ),
                ),
                TextSpan(
                  text: 'Issues',
                  style: portalText(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: PortalColors.purple,
                    height: 19 / 16,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Track and manage your reported issues.',
            style: portalText(
              fontSize: 10.5,
              fontWeight: FontWeight.w400,
              color: PortalColors.muted,
              height: 13 / 10.5,
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionRow extends StatelessWidget {
  const _ActionRow();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(25, 20, 14, 0),
      child: Row(
        children: [
          Expanded(
            flex: 210,
            child: Material(
              color: Colors.transparent,
              borderRadius: BorderRadius.circular(12),
              child: Ink(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [PortalColors.purpleMid, PortalColors.purpleSoft],
                  ),
                ),
                child: InkWell(
                  onTap: () => showRaiseIssueSheet(context),
                  borderRadius: BorderRadius.circular(12),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    child: Center(
                      child: Text(
                        '+ Raise issues',
                        style: portalText(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                          height: 17 / 14,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 20),
          Expanded(
            flex: 171,
            child: Container(
              decoration: BoxDecoration(
                color: PortalColors.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0x5426204A)),
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () {},
                  borderRadius: BorderRadius.circular(12),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SvgPicture.asset(
                          'assets/icons/issues/ic_filter.svg',
                          width: 18,
                          height: 18,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Filter',
                          style: portalText(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF939393),
                            height: 17 / 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TotalChip extends StatelessWidget {
  const _TotalChip({required this.total});

  final int total;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.fromLTRB(26, 16, 0, 0),
        padding: const EdgeInsets.symmetric(horizontal: 31, vertical: 10),
        decoration: BoxDecoration(
          color: PortalColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0x5426204A)),
        ),
        child: Text(
          'Total : $total',
          style: portalText(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF939393),
            height: 17 / 14,
          ),
        ),
      ),
    );
  }
}

class _SearchField extends StatelessWidget {
  const _SearchField({required this.controller, required this.onChanged});

  final TextEditingController controller;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(17, 16, 18, 0),
      child: TextField(
        controller: controller,
        onChanged: onChanged,
        decoration: InputDecoration(
          hintText: 'Search by purpose, outcome, or remark...',
          hintStyle: portalText(
            fontSize: 11.3,
            color: const Color(0xFF757575),
            height: 14 / 11.3,
          ),
          prefixIcon: Padding(
            padding: const EdgeInsets.only(left: 12, right: 8),
            child: SvgPicture.asset(
              'assets/icons/issues/ic_search.svg',
              width: 12,
              height: 13,
            ),
          ),
          prefixIconConstraints: const BoxConstraints(
            minWidth: 32,
            minHeight: 0,
          ),
          filled: true,
          fillColor: PortalColors.surface,
          isDense: true,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 12,
          ),
          border: _border(),
          enabledBorder: _border(),
          focusedBorder: _border(PortalColors.purple),
        ),
        style: portalText(
          fontSize: 12,
          color: PortalColors.heading,
          height: 1.2,
        ),
      ),
    );
  }

  OutlineInputBorder _border([Color? color]) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(11),
      borderSide: BorderSide(color: color ?? PortalColors.border),
    );
  }
}

class _FiltersCard extends StatelessWidget {
  const _FiltersCard({
    required this.priority,
    required this.status,
    required this.type,
    required this.onPriority,
    required this.onStatus,
    required this.onType,
    required this.onReset,
  });

  final String priority;
  final String status;
  final String type;
  final ValueChanged<String> onPriority;
  final ValueChanged<String> onStatus;
  final ValueChanged<String> onType;
  final VoidCallback onReset;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(10, 21, 10, 0),
      padding: const EdgeInsets.fromLTRB(17, 18, 17, 24),
      decoration: BoxDecoration(
        color: PortalColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: PortalColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '▽ Filters & Actions',
            style: portalText(
              fontSize: 13.5,
              fontWeight: FontWeight.w700,
              color: PortalColors.heading,
              height: 16 / 13.5,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Search and filter records by date, status, and location.',
            style: portalText(
              fontSize: 10.5,
              fontWeight: FontWeight.w400,
              color: PortalColors.muted,
              height: 13 / 10.5,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'PRIORITY',
            style: portalText(
              fontSize: 10.5,
              fontWeight: FontWeight.w700,
              color: PortalColors.muted,
              letterSpacing: 0.3,
              height: 13 / 10.5,
            ),
          ),
          const SizedBox(height: 5),
          _DropdownField(
            value: priority,
            items: const ['All', 'High', 'Medium', 'Low'],
            onChanged: onPriority,
          ),
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'STATUS',
                      style: portalText(
                        fontSize: 10.5,
                        fontWeight: FontWeight.w700,
                        color: PortalColors.muted,
                        letterSpacing: 0.3,
                        height: 13 / 10.5,
                      ),
                    ),
                    const SizedBox(height: 5),
                    _DropdownField(
                      value: status,
                      items: const [
                        'All Status',
                        'Open',
                        'In Progress',
                        'Resolved',
                      ],
                      onChanged: onStatus,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'TYPE',
                      style: portalText(
                        fontSize: 10.5,
                        fontWeight: FontWeight.w700,
                        color: PortalColors.muted,
                        letterSpacing: 0.3,
                        height: 13 / 10.5,
                      ),
                    ),
                    const SizedBox(height: 5),
                    _DropdownField(
                      value: type,
                      items: const ['All', 'Technical', 'HR', 'Other'],
                      onChanged: onType,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Center(
            child: Material(
              color: const Color(0xFFE4E4E4),
              borderRadius: BorderRadius.circular(10),
              child: InkWell(
                onTap: onReset,
                borderRadius: BorderRadius.circular(10),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 42,
                    vertical: 8,
                  ),
                  child: Text(
                    'Reset Filter',
                    style: portalText(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                      height: 13 / 11,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DropdownField extends StatelessWidget {
  const _DropdownField({
    required this.value,
    required this.items,
    required this.onChanged,
  });

  final String value;
  final List<String> items;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 36,
      padding: const EdgeInsets.symmetric(horizontal: 13),
      decoration: BoxDecoration(
        color: PortalColors.background,
        borderRadius: BorderRadius.circular(11),
        border: Border.all(color: PortalColors.border),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          isExpanded: true,
          icon: Text(
            '⌄',
            style: portalText(
              fontSize: 12,
              color: PortalColors.muted,
              height: 15 / 12,
            ),
          ),
          style: portalText(
            fontSize: 12,
            fontWeight: FontWeight.w400,
            color: PortalColors.muted,
            height: 15 / 12,
          ),
          dropdownColor: PortalColors.surface,
          items: [
            for (final item in items)
              DropdownMenuItem(value: item, child: Text(item)),
          ],
          onChanged: (v) {
            if (v != null) onChanged(v);
          },
        ),
      ),
    );
  }
}

class _IssuesListHeader extends StatelessWidget {
  const _IssuesListHeader();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 30, 18, 0),
      child: Text(
        'Issues List',
        style: portalText(
          fontSize: 13.5,
          fontWeight: FontWeight.w700,
          color: PortalColors.heading,
          height: 16 / 13.5,
        ),
      ),
    );
  }
}

class _IssueCard extends StatelessWidget {
  const _IssueCard({
    required this.issue,
    required this.onView,
    required this.onEdit,
    required this.onDelete,
  });

  final IssueUiModel issue;
  final VoidCallback onView;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final typeColors = _typeTagColors();
    final priorityColors = _priorityTagColors(issue.priority);
    final statusColors = _statusTagColors(issue.status);

    return Container(
      margin: const EdgeInsets.fromLTRB(10, 18, 10, 0),
      padding: const EdgeInsets.fromLTRB(12, 18, 12, 12),
      decoration: BoxDecoration(
        color: PortalColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: PortalColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            issue.title,
            style: portalText(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: PortalColors.heading,
              height: 16 / 13,
            ),
          ),
          const SizedBox(height: 1),
          Text(
            issue.description,
            style: portalText(
              fontSize: 10.5,
              fontWeight: FontWeight.w400,
              color: PortalColors.muted,
              height: 13 / 10.5,
            ),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [
              _Tag(
                label: issue.issueType,
                background: typeColors.$1,
                color: typeColors.$2,
              ),
              _Tag(
                label: issue.priority,
                background: priorityColors.$1,
                color: priorityColors.$2,
              ),
              _Tag(
                label: issue.status,
                background: statusColors.$1,
                color: statusColors.$2,
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            decoration: const BoxDecoration(
              border: Border(top: BorderSide(color: PortalColors.border)),
            ),
            padding: const EdgeInsets.only(top: 9),
            child: Row(
              children: [
                Text(
                  issue.dateLabel,
                  style: portalText(
                    fontSize: 10.5,
                    fontWeight: FontWeight.w400,
                    color: PortalColors.muted,
                    height: 13 / 10.5,
                  ),
                ),
                const Spacer(),
                SizedBox(
                  width: 96,
                  height: 19,
                  child: Stack(
                    children: [
                      SvgPicture.asset(
                        'assets/icons/issues/frame_36_actions.svg',
                        width: 96,
                        height: 19,
                      ),
                      Positioned(
                        left: 0,
                        top: 0,
                        bottom: 0,
                        width: 32,
                        child: GestureDetector(
                          behavior: HitTestBehavior.opaque,
                          onTap: onView,
                        ),
                      ),
                      Positioned(
                        left: 32,
                        top: 0,
                        bottom: 0,
                        width: 32,
                        child: GestureDetector(
                          behavior: HitTestBehavior.opaque,
                          onTap: onEdit,
                        ),
                      ),
                      Positioned(
                        right: 0,
                        top: 0,
                        bottom: 0,
                        width: 32,
                        child: GestureDetector(
                          behavior: HitTestBehavior.opaque,
                          onTap: onDelete,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  (Color, Color) _typeTagColors() {
    return (const Color(0xFFF1F0F4), const Color(0xFF6B6680));
  }

  (Color, Color) _priorityTagColors(String priority) {
    switch (priority.toLowerCase()) {
      case 'high':
        return (const Color(0xFFFDECEC), const Color(0xFFE53935));
      case 'medium':
        return (const Color(0xFFFEF4E3), const Color(0xFFF0A72E));
      case 'low':
        return (const Color(0xFFE7F7F0), const Color(0xFF1FA971));
      default:
        return (const Color(0xFFF1F0F4), const Color(0xFF6B6680));
    }
  }

  (Color, Color) _statusTagColors(String status) {
    final normalized = status.toLowerCase();
    if (normalized == 'resolved' || normalized == 'closed') {
      return (const Color(0xFFE7F7F0), const Color(0xFF1FA971));
    }
    if (normalized == 'open') {
      return (const Color(0xFFE8F0FE), const Color(0xFF305CEA));
    }
    return (const Color(0xFFF1F0F4), const Color(0xFF6B6680));
  }
}

class _Tag extends StatelessWidget {
  const _Tag({
    required this.label,
    required this.background,
    required this.color,
  });

  final String label;
  final Color background;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(9, 4, 9, 6),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: portalText(
          fontSize: 9.5,
          fontWeight: FontWeight.w700,
          color: color,
          height: 11 / 9.5,
        ),
      ),
    );
  }
}

class _ShowingFooter extends StatelessWidget {
  const _ShowingFooter({required this.showing, required this.total});

  final int showing;
  final int total;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 24, 18, 0),
      child: Center(
        child: Text.rich(
          TextSpan(
            children: [
              TextSpan(
                text: 'Showing ',
                style: portalText(
                  fontSize: 10,
                  fontWeight: FontWeight.w400,
                  color: PortalColors.muted,
                  height: 12 / 10,
                ),
              ),
              TextSpan(
                text: '$showing',
                style: portalText(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: PortalColors.muted,
                  height: 12 / 10,
                ),
              ),
              TextSpan(
                text: ' of ',
                style: portalText(
                  fontSize: 10,
                  fontWeight: FontWeight.w400,
                  color: PortalColors.muted,
                  height: 12 / 10,
                ),
              ),
              TextSpan(
                text: '$total',
                style: portalText(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: PortalColors.muted,
                  height: 12 / 10,
                ),
              ),
              TextSpan(
                text: ' Issues',
                style: portalText(
                  fontSize: 10,
                  fontWeight: FontWeight.w400,
                  color: PortalColors.muted,
                  height: 12 / 10,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _IssuesError extends StatelessWidget {
  const _IssuesError({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 48, 18, 0),
      child: Column(
        children: [
          Text(
            message,
            textAlign: TextAlign.center,
            style: portalText(
              fontSize: 12,
              color: PortalColors.muted,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 16),
          Material(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(10),
            child: Ink(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [PortalColors.purpleMid, PortalColors.purpleSoft],
                ),
              ),
              child: InkWell(
                onTap: onRetry,
                borderRadius: BorderRadius.circular(10),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 10,
                  ),
                  child: Text(
                    'Retry',
                    style: portalText(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
