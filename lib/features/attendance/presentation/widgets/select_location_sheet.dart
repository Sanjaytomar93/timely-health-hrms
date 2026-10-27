import 'package:flutter/material.dart';
import 'package:timelay_health/core/theme/portal_colors.dart';
import 'package:timelay_health/core/theme/portal_text.dart';
import 'package:timelay_health/features/attendance/domain/entities/employee_location_assignment.dart';

Future<EmployeeLocationAssignment?> showSelectLocationSheet(
  BuildContext context, {
  required Future<List<EmployeeLocationAssignment>> Function() loadLocations,
  String? selectedId,
}) {
  return showModalBottomSheet<EmployeeLocationAssignment>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    backgroundColor: Colors.transparent,
    barrierColor: Colors.black.withValues(alpha: 0.44),
    builder: (_) => _SelectLocationSheet(
      loadLocations: loadLocations,
      selectedId: selectedId,
    ),
  );
}

class _SelectLocationSheet extends StatefulWidget {
  const _SelectLocationSheet({
    required this.loadLocations,
    required this.selectedId,
  });

  final Future<List<EmployeeLocationAssignment>> Function() loadLocations;
  final String? selectedId;

  @override
  State<_SelectLocationSheet> createState() => _SelectLocationSheetState();
}

class _SelectLocationSheetState extends State<_SelectLocationSheet> {
  late Future<List<EmployeeLocationAssignment>> _future;
  String _query = '';

  @override
  void initState() {
    super.initState();
    _future = widget.loadLocations();
  }

  void _retry() => setState(() => _future = widget.loadLocations());

  List<EmployeeLocationAssignment> _filter(
    List<EmployeeLocationAssignment> all,
  ) {
    final q = _query.trim().toLowerCase();
    if (q.isEmpty) return all;
    return all
        .where(
          (l) =>
              l.name.toLowerCase().contains(q) ||
              l.fullAddress.toLowerCase().contains(q),
        )
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);
    return Padding(
      padding: EdgeInsets.only(bottom: media.viewInsets.bottom),
      child: Container(
        height: media.size.height * 0.8,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          children: [
            const SizedBox(height: 10),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: PortalColors.border,
                borderRadius: BorderRadius.circular(999),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 14, 10, 12),
              child: Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: PortalColors.brandTint,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.apartment_rounded,
                      color: PortalColors.brand,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Select Location',
                      style: portalText(
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(
                      Icons.close_rounded,
                      color: PortalColors.muted,
                    ),
                  ),
                ],
              ),
            ),
            const Divider(height: 1, color: PortalColors.border),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
              child: TextField(
                onChanged: (v) => setState(() => _query = v),
                textInputAction: TextInputAction.search,
                style: portalText(fontSize: 14),
                decoration: InputDecoration(
                  hintText: 'Search location...',
                  hintStyle: portalText(
                    fontSize: 14,
                    color: PortalColors.muted,
                  ),
                  prefixIcon: const Icon(
                    Icons.search_rounded,
                    color: PortalColors.muted,
                    size: 20,
                  ),
                  isDense: true,
                  filled: true,
                  fillColor: PortalColors.background,
                  contentPadding: const EdgeInsets.symmetric(vertical: 13),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: PortalColors.border),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: PortalColors.border),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(
                      color: PortalColors.brandLight,
                      width: 1.4,
                    ),
                  ),
                ),
              ),
            ),
            Expanded(
              child: FutureBuilder<List<EmployeeLocationAssignment>>(
                future: _future,
                builder: (context, snapshot) {
                  if (snapshot.connectionState != ConnectionState.done) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.hasError) {
                    return _Message(
                      icon: Icons.cloud_off_rounded,
                      text: snapshot.error.toString(),
                      onRetry: _retry,
                    );
                  }
                  final items = _filter(snapshot.data ?? const []);
                  if (items.isEmpty) {
                    return const _Message(
                      icon: Icons.location_searching_rounded,
                      text: 'No locations found',
                    );
                  }
                  return ListView.separated(
                    padding: EdgeInsets.fromLTRB(
                      16,
                      4,
                      16,
                      16 + media.padding.bottom,
                    ),
                    itemCount: items.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 10),
                    itemBuilder: (context, i) {
                      final location = items[i];
                      return _LocationCard(
                        location: location,
                        selected: location.id == widget.selectedId,
                        onTap: () => Navigator.pop(context, location),
                      );
                    },
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

class _LocationCard extends StatelessWidget {
  const _LocationCard({
    required this.location,
    required this.selected,
    required this.onTap,
  });

  final EmployeeLocationAssignment location;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final address = location.fullAddress.replaceAll(RegExp(r'\s+'), ' ').trim();
    return Material(
      color: selected ? PortalColors.brandTint : Colors.white,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.fromLTRB(14, 13, 12, 14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: selected ? PortalColors.brandLight : PortalColors.border,
              width: selected ? 1.4 : 1,
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: selected ? Colors.white : PortalColors.background,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.location_on_rounded,
                  color: PortalColors.brand,
                  size: 18,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      location.name,
                      style: portalText(
                        fontSize: 14.5,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    if (address.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        address,
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                        style: portalText(
                          fontSize: 12,
                          color: PortalColors.muted,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              if (selected) ...[
                const SizedBox(width: 8),
                const Icon(
                  Icons.check_circle_rounded,
                  color: PortalColors.green,
                  size: 20,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _Message extends StatelessWidget {
  const _Message({required this.icon, required this.text, this.onRetry});

  final IconData icon;
  final String text;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 40, color: PortalColors.muted),
            const SizedBox(height: 10),
            Text(
              text,
              textAlign: TextAlign.center,
              style: portalText(fontSize: 13, color: PortalColors.secondaryText),
            ),
            if (onRetry != null) ...[
              const SizedBox(height: 12),
              TextButton(onPressed: onRetry, child: const Text('Retry')),
            ],
          ],
        ),
      ),
    );
  }
}
