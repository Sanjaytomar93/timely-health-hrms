import 'package:flutter/material.dart';
import 'package:timelay_health/core/theme/portal_colors.dart';
import 'package:timelay_health/core/theme/portal_text.dart';
import 'package:timelay_health/features/issues/presentation/models/issue_ui_model.dart';

enum IssueDetailAction { edit, delete }

Future<IssueDetailAction?> showIssueDetailsDialog(
  BuildContext context, {
  required IssueUiModel issue,
}) {
  return showDialog<IssueDetailAction>(
    context: context,
    barrierColor: const Color(0x70000000),
    builder: (_) => _IssueDetailsDialog(issue: issue),
  );
}

class _IssueDetailsDialog extends StatelessWidget {
  const _IssueDetailsDialog({required this.issue});

  final IssueUiModel issue;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.white,
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 460),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 14, 8, 12),
                child: Row(
                  children: [
                    const Icon(Icons.info, color: Color(0xFF3B82F6), size: 22),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Issue Details',
                        style: portalText(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: PortalColors.heading,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close, size: 20),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1, color: PortalColors.border),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _field('Issue Title', issue.title),
                    const SizedBox(height: 12),
                    _field('Description', issue.description),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: _field(
                            'Employee',
                            issue.employeeName.isEmpty
                                ? '—'
                                : issue.employeeName,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _field(
                            'Department',
                            issue.department.isEmpty ? '—' : issue.department,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: _pillField(
                            'Issue Type',
                            issue.issueType,
                            const Color(0xFFF1F0F4),
                            const Color(0xFF6B6680),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(child: _priorityField(issue.priority)),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(child: _statusField(issue.status)),
                        const SizedBox(width: 10),
                        Expanded(child: _field('Raised On', issue.raisedOn)),
                      ],
                    ),
                  ],
                ),
              ),
              const Divider(height: 1, color: PortalColors.border),
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 12, 12, 14),
                child: Row(
                  children: [
                    Expanded(
                      child: _action(
                        label: 'Edit',
                        icon: Icons.edit_outlined,
                        fg: PortalColors.green,
                        bg: PortalColors.greenTint,
                        onTap: () =>
                            Navigator.pop(context, IssueDetailAction.edit),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _action(
                        label: 'Delete',
                        icon: Icons.delete_outline,
                        fg: PortalColors.red,
                        bg: PortalColors.redTint,
                        onTap: () =>
                            Navigator.pop(context, IssueDetailAction.delete),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _action(
                        label: 'Close',
                        fg: PortalColors.secondaryText,
                        bg: const Color(0xFFF3F2F7),
                        onTap: () => Navigator.pop(context),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _field(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: portalText(fontSize: 12, color: PortalColors.muted)),
        const SizedBox(height: 6),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          decoration: BoxDecoration(
            color: const Color(0xFFF7F7FB),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: PortalColors.border),
          ),
          child: Text(
            value.isEmpty ? '—' : value,
            style: portalText(
              fontSize: 13.5,
              fontWeight: FontWeight.w600,
              color: PortalColors.heading,
            ),
          ),
        ),
      ],
    );
  }

  Widget _pillField(
    String label,
    String value,
    Color bg,
    Color fg, {
    Widget? leading,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: portalText(fontSize: 12, color: PortalColors.muted)),
        const SizedBox(height: 6),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
          decoration: BoxDecoration(
            color: const Color(0xFFF7F7FB),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: PortalColors.border),
          ),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: bg,
                borderRadius: BorderRadius.circular(999),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (leading != null) ...[leading, const SizedBox(width: 4)],
                  Text(
                    value,
                    style: portalText(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: fg,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _priorityField(String priority) {
    final key = priority.toLowerCase();
    final colors = switch (key) {
      'high' => (const Color(0xFFFDECEC), const Color(0xFFE53935)),
      'medium' => (const Color(0xFFFEF4E3), const Color(0xFFF0A72E)),
      'low' => (PortalColors.greenTint, PortalColors.green),
      _ => (const Color(0xFFF1F0F4), const Color(0xFF6B6680)),
    };
    return _pillField('Priority', priority, colors.$1, colors.$2);
  }

  Widget _statusField(String status) {
    final key = status.toLowerCase();
    final Color color;
    if (key == 'open') {
      color = const Color(0xFF305CEA);
    } else if (key == 'resolved' || key == 'closed') {
      color = PortalColors.green;
    } else {
      color = const Color(0xFF6B6680);
    }
    return _pillField(
      'Status',
      status,
      color.withValues(alpha: 0.12),
      color,
      leading: Container(
        width: 7,
        height: 7,
        decoration: BoxDecoration(color: color, shape: BoxShape.circle),
      ),
    );
  }

  Widget _action({
    required String label,
    required Color fg,
    required Color bg,
    required VoidCallback onTap,
    IconData? icon,
  }) {
    return Material(
      color: bg,
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (icon != null) ...[
                Icon(icon, size: 16, color: fg),
                const SizedBox(width: 6),
              ],
              Text(
                label,
                style: portalText(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: fg,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
