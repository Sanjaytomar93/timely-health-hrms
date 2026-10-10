import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:timelay_health/core/theme/portal_colors.dart';
import 'package:timelay_health/core/theme/portal_text.dart';
import 'package:timelay_health/features/auth/data/auth_session.dart';
import 'package:timelay_health/features/issues/domain/failures/issue_failure.dart';
import 'package:timelay_health/features/issues/presentation/bloc/issues_cubit.dart';
import 'package:timelay_health/features/issues/presentation/models/issue_ui_model.dart';

Future<bool?> showRaiseIssueSheet(BuildContext context) {
  final cubit = context.read<IssuesCubit>();
  return showDialog<bool>(
    context: context,
    barrierColor: const Color(0x70000000),
    builder: (context) =>
        BlocProvider.value(value: cubit, child: const RaiseIssueSheet()),
  );
}

Future<bool?> showEditIssueSheet(
  BuildContext context, {
  required IssueUiModel issue,
}) {
  final cubit = context.read<IssuesCubit>();
  return showDialog<bool>(
    context: context,
    barrierColor: const Color(0x70000000),
    builder: (context) => BlocProvider.value(
      value: cubit,
      child: RaiseIssueSheet(existing: issue),
    ),
  );
}

class RaiseIssueSheet extends StatefulWidget {
  const RaiseIssueSheet({super.key, this.existing});

  final IssueUiModel? existing;

  @override
  State<RaiseIssueSheet> createState() => _RaiseIssueSheetState();
}

class _RaiseIssueSheetState extends State<RaiseIssueSheet> {
  late final TextEditingController _name;
  late final TextEditingController _department;
  late final TextEditingController _title;
  late final TextEditingController _description;
  String _issueType = 'HR';
  String _priority = 'Medium';
  bool _submitting = false;

  static const _types = ['HR', 'Technical', 'Payroll', 'Other'];
  static const _priorities = ['Low', 'Medium', 'High'];

  @override
  void initState() {
    super.initState();
    final employee = AuthSession.currentEmployee;
    final existing = widget.existing;
    _name = TextEditingController(
      text: existing?.employeeName.isNotEmpty == true
          ? existing!.employeeName
          : employee?.displayName ?? '',
    );
    _department = TextEditingController(
      text: existing?.department.isNotEmpty == true
          ? existing!.department
          : employee?.department ?? '',
    );
    _title = TextEditingController(text: existing?.title ?? '');
    _description = TextEditingController(text: existing?.description ?? '');
    if (existing != null) {
      if (_types.contains(existing.issueType)) {
        _issueType = existing.issueType;
      }
      final priority = existing.priority;
      if (_priorities.any((p) => p.toLowerCase() == priority.toLowerCase())) {
        _priority = _priorities.firstWhere(
          (p) => p.toLowerCase() == priority.toLowerCase(),
        );
      }
    }
  }

  @override
  void dispose() {
    _name.dispose();
    _department.dispose();
    _title.dispose();
    _description.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    setState(() => _submitting = true);
    try {
      final cubit = context.read<IssuesCubit>();
      final existing = widget.existing;
      if (existing == null) {
        await cubit.raiseIssue(
          employeeName: _name.text,
          department: _department.text,
          issueTitle: _title.text,
          issueDescription: _description.text,
          issueType: _issueType,
          priority: _priority,
        );
      } else {
        await cubit.updateIssue(
          issueId: existing.id,
          employeeName: _name.text,
          department: _department.text,
          issueTitle: _title.text,
          issueDescription: _description.text,
          issueType: _issueType,
          priority: _priority,
        );
      }
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            existing == null
                ? 'Issue raised successfully'
                : 'Issue updated successfully',
          ),
          behavior: SnackBarBehavior.floating,
        ),
      );
      Navigator.of(context).pop(true);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            e is IssueFailure ? e.message : 'Failed to raise issue.',
          ),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final dialogWidth = (size.width - 35).clamp(300.0, 405.0);
    final maxHeight = size.height * 0.88;

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 28),
      child: Container(
        width: dialogWidth,
        constraints: BoxConstraints(maxHeight: maxHeight),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(22, 24, 18, 22),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      widget.existing == null
                          ? 'Raise New Issue'
                          : 'Edit Issue',
                      style: portalText(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w700,
                        color: PortalColors.heading,
                        height: 16 / 13.5,
                      ),
                    ),
                  ),
                  InkWell(
                    onTap: _submitting
                        ? null
                        : () => Navigator.of(context).pop(false),
                    borderRadius: BorderRadius.circular(16),
                    child: Container(
                      width: 45,
                      height: 42,
                      decoration: BoxDecoration(
                        color: PortalColors.border,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Icon(Icons.close, size: 20),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const _Label('Employee Name'),
                        const SizedBox(height: 8),
                        _InputField(
                          controller: _name,
                          hint: 'Enter Employee Name',
                          enabled: !_submitting,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const _Label('Department'),
                        const SizedBox(height: 8),
                        _InputField(
                          controller: _department,
                          hint: 'Enter Department',
                          enabled: !_submitting,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              const _Label('Issue Title *'),
              const SizedBox(height: 8),
              _InputField(
                controller: _title,
                hint: 'e.g. Client meeting or sample collection',
                enabled: !_submitting,
              ),
              const SizedBox(height: 16),
              const _Label('Issue Description *'),
              const SizedBox(height: 8),
              _InputField(
                controller: _description,
                hint: 'Detailed Description of the issues',
                height: 137,
                maxLines: 5,
                enabled: !_submitting,
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const _Label('Issue Type'),
                        const SizedBox(height: 8),
                        _DropdownBox(
                          value: _issueType,
                          items: _types,
                          enabled: !_submitting,
                          onChanged: (v) => setState(() => _issueType = v),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const _Label('Priority'),
                        const SizedBox(height: 8),
                        _DropdownBox(
                          value: _priority,
                          items: _priorities,
                          enabled: !_submitting,
                          onChanged: (v) => setState(() => _priority = v),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 28),
              Row(
                children: [
                  Expanded(
                    flex: 5,
                    child: GestureDetector(
                      onTap: _submitting
                          ? null
                          : () => Navigator.of(context).pop(false),
                      child: Container(
                        height: 32,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: PortalColors.muted,
                            width: 0.5,
                          ),
                        ),
                        child: Text(
                          'Cancel',
                          style: portalText(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: PortalColors.heading,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 25),
                  Expanded(
                    flex: 6,
                    child: GestureDetector(
                      onTap: _submitting ? null : _submit,
                      child: Container(
                        height: 32,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          gradient: const LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              PortalColors.purpleMid,
                              PortalColors.purpleSoft,
                            ],
                          ),
                        ),
                        child: _submitting
                            ? const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : Text(
                                widget.existing == null
                                    ? 'Raise Issue'
                                    : 'Update Issue',
                                style: portalText(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                ),
                              ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Label extends StatelessWidget {
  const _Label(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: portalText(
        fontSize: 10,
        fontWeight: FontWeight.w500,
        color: PortalColors.muted,
        height: 12 / 10,
      ),
    );
  }
}

class _InputField extends StatelessWidget {
  const _InputField({
    required this.controller,
    this.hint,
    this.height = 40,
    this.maxLines = 1,
    this.enabled = true,
  });

  final TextEditingController controller;
  final String? hint;
  final double height;
  final int maxLines;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: height,
      padding: EdgeInsets.symmetric(
        horizontal: 15,
        vertical: maxLines > 1 ? 10 : 0,
      ),
      alignment: maxLines > 1 ? Alignment.topLeft : Alignment.centerLeft,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: PortalColors.border),
      ),
      child: TextField(
        controller: controller,
        enabled: enabled,
        maxLines: maxLines,
        style: portalText(
          fontSize: 10,
          fontWeight: FontWeight.w500,
          color: PortalColors.heading,
        ),
        decoration: InputDecoration(
          isDense: true,
          border: InputBorder.none,
          hintText: hint,
          hintStyle: portalText(
            fontSize: 8,
            fontWeight: FontWeight.w300,
            color: const Color(0xFF7E7E7E),
          ),
        ),
      ),
    );
  }
}

class _DropdownBox extends StatelessWidget {
  const _DropdownBox({
    required this.value,
    required this.items,
    required this.onChanged,
    this.enabled = true,
  });

  final String value;
  final List<String> items;
  final ValueChanged<String> onChanged;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      enabled: enabled,
      onSelected: onChanged,
      itemBuilder: (context) => [
        for (final item in items) PopupMenuItem(value: item, child: Text(item)),
      ],
      child: Container(
        height: 40,
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 15),
        alignment: Alignment.centerLeft,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: PortalColors.border),
        ),
        child: Text(
          value,
          style: portalText(
            fontSize: 10,
            fontWeight: FontWeight.w500,
            color: const Color(0xFF7E7E7E),
          ),
        ),
      ),
    );
  }
}
