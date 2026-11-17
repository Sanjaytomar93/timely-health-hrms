import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:timelay_health/core/notifications/download_notification.dart';
import 'package:timelay_health/core/theme/portal_text.dart';
import 'package:timelay_health/features/camp/dashboard/presentation/theme/camp_colors.dart';

enum CampPdfAction { download, share }

Future<CampPdfAction?> showCampPdfActionSheet(BuildContext context) {
  return showModalBottomSheet<CampPdfAction>(
    context: context,
    backgroundColor: Colors.transparent,
    barrierColor: Colors.black.withValues(alpha: 0.45),
    builder: (ctx) {
      final bottom = MediaQuery.paddingOf(ctx).bottom;
      return Padding(
        padding: EdgeInsets.fromLTRB(12, 0, 12, 10 + bottom),
        child: Material(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          clipBehavior: Clip.antiAlias,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 10),
              Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: const Color(0xFFD8DEE6),
                  borderRadius: BorderRadius.circular(99),
                ),
              ),
              const SizedBox(height: 14),
              Text(
                'Export PDF',
                style: portalText(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  color: CampColors.heading,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Choose how you want to save this report',
                style: portalText(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: CampColors.muted,
                ),
              ),
              const SizedBox(height: 12),
              _ActionTile(
                icon: Icons.download_rounded,
                title: 'Download',
                subtitle: 'Save PDF on this device',
                color: CampColors.primary,
                onTap: () => Navigator.pop(ctx, CampPdfAction.download),
              ),
              _ActionTile(
                icon: Icons.share_rounded,
                title: 'Share',
                subtitle: 'Send via WhatsApp, Drive, Files…',
                color: CampColors.green,
                onTap: () => Navigator.pop(ctx, CampPdfAction.share),
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      );
    },
  );
}

class _ActionTile extends StatelessWidget {
  const _ActionTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, color: color, size: 20),
      ),
      title: Text(
        title,
        style: portalText(
          fontSize: 14,
          fontWeight: FontWeight.w700,
          color: CampColors.heading,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: portalText(
          fontSize: 11.5,
          fontWeight: FontWeight.w500,
          color: CampColors.muted,
        ),
      ),
    );
  }
}

class CampPdfDelivery {
  const CampPdfDelivery._();

  static Future<Directory> _downloadDir() async {
    if (Platform.isAndroid) {
      final public = Directory('/storage/emulated/0/Download');
      if (await public.exists()) {
        try {
          final probe = File('${public.path}/.timely_write_probe');
          await probe.writeAsString('ok', flush: true);
          await probe.delete();
          return public;
        } catch (_) {}
      }
    }
    final downloads = await getDownloadsDirectory();
    if (downloads != null) return downloads;
    return getApplicationDocumentsDirectory();
  }

  static Future<String?> deliver({
    required List<int> bytes,
    required String fileName,
    required CampPdfAction action,
    String? subject,
  }) async {
    if (action == CampPdfAction.share) {
      final dir = await getTemporaryDirectory();
      final file = File('${dir.path}/$fileName');
      await file.writeAsBytes(bytes, flush: true);
      await SharePlus.instance.share(
        ShareParams(
          files: [
            XFile(file.path, mimeType: 'application/pdf', name: fileName),
          ],
          subject: subject ?? fileName.replaceAll('.pdf', ''),
        ),
      );
      return null;
    }

    final native = await DownloadNotification.savePdfAndNotify(
      bytes: bytes,
      fileName: fileName,
    );
    if (native != null) return native.path;

    final dir = await _downloadDir();
    final file = File('${dir.path}/$fileName');
    await file.writeAsBytes(bytes, flush: true);
    return file.path;
  }
}
