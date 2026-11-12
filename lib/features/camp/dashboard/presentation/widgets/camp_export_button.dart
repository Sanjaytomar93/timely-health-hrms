import 'package:flutter/material.dart';
import 'package:timelay_health/core/theme/portal_text.dart';
import 'package:timelay_health/features/camp/dashboard/presentation/theme/camp_colors.dart';

class CampExportButton extends StatelessWidget {
  const CampExportButton({
    super.key,
    this.onTap,
    this.isLoading = false,
  });

  final VoidCallback? onTap;
  final bool isLoading;

  /// Shared loading + snackbar wrapper for dashboard export actions.
  static Future<void> run(
    State state, {
    required bool isLoading,
    required void Function(bool loading) setLoading,
    required Future<void> Function() action,
  }) async {
    if (isLoading) return;
    setLoading(true);
    try {
      await action();
    } catch (e) {
      if (!state.mounted) return;
      ScaffoldMessenger.of(state.context).showSnackBar(
        SnackBar(
          content: Text('Export failed: $e'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      if (state.mounted) setLoading(false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: CampColors.primaryTint,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        onTap: isLoading ? null : onTap,
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (isLoading)
                const SizedBox(
                  width: 14,
                  height: 14,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: CampColors.primary,
                  ),
                )
              else
                const Icon(
                  Icons.file_download_outlined,
                  size: 15,
                  color: CampColors.primary,
                ),
              const SizedBox(width: 4),
              Text(
                'Export',
                style: portalText(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: CampColors.primary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
