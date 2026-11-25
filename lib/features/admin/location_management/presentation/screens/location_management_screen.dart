import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:timelay_health/core/theme/portal_colors.dart';
import 'package:timelay_health/core/theme/portal_text.dart';
import 'package:timelay_health/core/widgets/portal_safe_area.dart';
import 'package:timelay_health/features/admin/location_management/data/datasources/location_remote_datasource.dart';
import 'package:timelay_health/features/admin/location_management/data/models/location_item_model.dart';
import 'package:timelay_health/features/dashboard/presentation/screens/employee_home_shell.dart';
import 'package:timelay_health/features/dashboard/presentation/widgets/employee_bottom_nav.dart';
import 'package:timelay_health/features/dashboard/presentation/widgets/home_side_drawer.dart';
import 'package:timelay_health/features/holidays/presentation/widgets/top_calendar_button.dart';
import 'package:timelay_health/features/notifications/presentation/widgets/top_notification_button.dart';

class LocationManagementScreen extends StatefulWidget {
  const LocationManagementScreen({super.key});

  @override
  State<LocationManagementScreen> createState() =>
      _LocationManagementScreenState();
}

class _LocationManagementScreenState extends State<LocationManagementScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final TextEditingController _searchController = TextEditingController();
  final LocationRemoteDataSource _datasource = LocationRemoteDataSource();

  late List<LocationItem> _locations;
  bool _isLoading = false;
  String _searchQuery = '';
  String _selectedCity = 'All Cities';
  String _selectedState = 'All States';
  String _selectedPin = 'All Pins';

  List<String> get _cities {
    final set = <String>{'All Cities'};
    for (final l in _locations) {
      if (l.city.trim().isNotEmpty) set.add(l.city.trim());
    }
    set.addAll(['Hyderabad', '530016 / Vizag', 'Secunderabad', 'Vijayawada']);
    return set.toList();
  }

  List<String> get _states {
    final set = <String>{'All States'};
    for (final l in _locations) {
      final s = l.state.split(RegExp(r'\s+')).first.trim();
      if (s.isNotEmpty) set.add(s);
    }
    set.addAll(['Telangana', 'AP.', 'Karnataka', 'Maharashtra']);
    return set.toList();
  }

  List<String> get _pins {
    final set = <String>{'All Pins'};
    for (final l in _locations) {
      if (l.pinCode.trim().isNotEmpty) set.add(l.pinCode.trim());
    }
    set.addAll(['500081', '500073', '530016']);
    return set.toList();
  }

  @override
  void initState() {
    super.initState();
    _locations = List<LocationItem>.from(LocationItem.sampleLocations());
    _loadLocations();
  }

  Future<void> _loadLocations() async {
    setState(() => _isLoading = true);
    try {
      final data = await _datasource.getAllLocations();
      if (!mounted) return;
      setState(() {
        _locations = data;
        _isLoading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<LocationItem> get _filteredLocations {
    return _locations.where((loc) {
      if (_selectedCity != 'All Cities') {
        if (!loc.city.toLowerCase().contains(_selectedCity.toLowerCase())) {
          return false;
        }
      }

      if (_selectedState != 'All States') {
        if (!loc.state.toLowerCase().contains(_selectedState.toLowerCase())) {
          return false;
        }
      }

      if (_selectedPin != 'All Pins') {
        if (!loc.pinCode.contains(_selectedPin)) {
          return false;
        }
      }

      if (_searchQuery.trim().isNotEmpty) {
        final q = _searchQuery.trim().toLowerCase();
        final match = loc.name.toLowerCase().contains(q) ||
            loc.address.toLowerCase().contains(q) ||
            loc.city.toLowerCase().contains(q) ||
            loc.state.toLowerCase().contains(q) ||
            loc.pinCode.toLowerCase().contains(q) ||
            loc.badgeType.label.toLowerCase().contains(q);
        if (!match) return false;
      }

      return true;
    }).toList();
  }

  int get _totalLocations => _locations.length;
  int get _activeLocations => _locations.where((l) => l.isActive).length;

  int get _uniqueCities {
    final set = <String>{};
    for (final l in _locations) {
      final c = l.city.split('/').last.trim();
      set.add(c.toLowerCase());
    }
    return set.length;
  }

  int get _uniqueStates {
    final set = <String>{};
    for (final l in _locations) {
      final s = l.state.split(RegExp(r'\s+')).first.trim();
      set.add(s.toLowerCase());
    }
    return set.length;
  }

  void _toggleLocationActive(LocationItem item, bool val) {
    HapticFeedback.lightImpact();
    setState(() {
      final index = _locations.indexWhere((l) => l.id == item.id);
      if (index != -1) {
        _locations[index] = _locations[index].copyWith(isActive: val);
      }
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          '${item.name} is now ${val ? "Active" : "Inactive"}',
        ),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _copyToClipboard(String text, String label) {
    HapticFeedback.lightImpact();
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$label copied: $text'),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _viewLocationDetails(LocationItem item) {
    showModalBottomSheet<void>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: item.badgeType.iconBg,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  alignment: Alignment.center,
                  child: Icon(item.badgeType.icon,
                      size: 20, color: item.badgeType.iconColor),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.name,
                        style: portalText(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: PortalColors.heading,
                        ),
                      ),
                      Text(
                        'Branch Type: ${item.badgeType.label}',
                        style: portalText(
                          fontSize: 12,
                          color: PortalColors.muted,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: item.isActive
                        ? const Color(0xFFECFDF5)
                        : const Color(0xFFFEF2F2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    item.isActive ? 'Active' : 'Inactive',
                    style: portalText(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: item.isActive
                          ? const Color(0xFF059669)
                          : const Color(0xFFDC2626),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Divider(height: 1, color: Color(0xFFE2E8F0)),
            const SizedBox(height: 14),
            Text(
              'Full Address:',
              style: portalText(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: PortalColors.muted,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              item.address,
              style: portalText(
                fontSize: 13.5,
                fontWeight: FontWeight.w500,
                color: const Color(0xFF334155),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Text(
                  'Geo Coordinates: ',
                  style: portalText(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: PortalColors.muted,
                  ),
                ),
                Text(
                  '${item.latitude}, ${item.longitude}',
                  style: portalText(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w700,
                    color: PortalColors.brandLight,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _editLocation(LocationItem item) {
    final nameCtrl = TextEditingController(text: item.name);
    final addrCtrl = TextEditingController(text: item.address);

    showDialog<void>(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          'Edit Location',
          style: portalText(
            fontSize: 16,
            fontWeight: FontWeight.w800,
            color: PortalColors.heading,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameCtrl,
              decoration: InputDecoration(
                labelText: 'Branch Name',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: addrCtrl,
              maxLines: 2,
              decoration: InputDecoration(
                labelText: 'Address',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogCtx),
            child: Text('Cancel', style: portalText(color: PortalColors.muted)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: PortalColors.brand,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            onPressed: () {
              setState(() {
                final idx = _locations.indexWhere((l) => l.id == item.id);
                if (idx != -1) {
                  _locations[idx] = _locations[idx].copyWith(
                    name: nameCtrl.text.trim(),
                    address: addrCtrl.text.trim(),
                  );
                }
              });
              Navigator.pop(dialogCtx);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Branch updated successfully'),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            child: Text(
              'Save',
              style:
                  portalText(color: Colors.white, fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }

  void _deleteLocation(LocationItem item) {
    showDialog<void>(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          'Delete Location?',
          style: portalText(
            fontSize: 16,
            fontWeight: FontWeight.w800,
            color: PortalColors.heading,
          ),
        ),
        content: Text(
          'Are you sure you want to delete "${item.name}"?',
          style: portalText(fontSize: 13, color: const Color(0xFF64748B)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogCtx),
            child: Text('Cancel', style: portalText(color: PortalColors.muted)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFDC2626),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            onPressed: () {
              setState(() {
                _locations.removeWhere((l) => l.id == item.id);
              });
              Navigator.pop(dialogCtx);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Deleted "${item.name}"'),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            child: Text(
              'Delete',
              style:
                  portalText(color: Colors.white, fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }

  void _clearAllFilters() {
    setState(() {
      _searchController.clear();
      _searchQuery = '';
      _selectedCity = 'All Cities';
      _selectedState = 'All States';
      _selectedPin = 'All Pins';
    });
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _filteredLocations;
    final hasActiveFilter = _searchQuery.isNotEmpty ||
        _selectedCity != 'All Cities' ||
        _selectedState != 'All States' ||
        _selectedPin != 'All Pins';

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: const Color(0xFFF8FAFC),
      drawer: const HomeSideDrawer(),
      drawerScrimColor: PortalColors.brand.withValues(alpha: 0.28),
      body: PortalSafeArea(
        bottom: false,
        child: Column(
          children: [
            _buildAttendanceStyleAppBar(),
            if (_isLoading)
              const LinearProgressIndicator(
                minHeight: 2.5,
                backgroundColor: Colors.transparent,
                valueColor: AlwaysStoppedAnimation<Color>(PortalColors.brand),
              ),
            Expanded(
              child: RefreshIndicator(
                color: PortalColors.brand,
                onRefresh: _loadLocations,
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(16, 14, 16, 32),
                  physics: const AlwaysScrollableScrollPhysics(),
                  children: [
                    _buildSearchBarAnd3Filters(),
                    if (hasActiveFilter) ...[
                      const SizedBox(height: 8),
                      _buildActiveFiltersChips(),
                    ],
                    const SizedBox(height: 14),
                    _build4StatCards(),
                    const SizedBox(height: 18),
                    _buildSectionHeader(filtered.length),
                    const SizedBox(height: 12),
                    if (filtered.isEmpty)
                      _buildEmptyState()
                    else
                      ...filtered.map((item) => _buildBranchCard(item)),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: EmployeeBottomNav(
        currentIndex: 0,
        onTap: (i) => EmployeeHomeShell.goToTab(context, i),
      ),
    );
  }

  Widget _buildAttendanceStyleAppBar() {
    return Container(
      decoration: BoxDecoration(
        color: PortalColors.surface,
        border: const Border(bottom: BorderSide(color: PortalColors.border)),
        boxShadow: [
          BoxShadow(
            color: PortalColors.brand.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.fromLTRB(18, 12, 18, 12),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => _scaffoldKey.currentState?.openDrawer(),
            behavior: HitTestBehavior.opaque,
            child: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: PortalColors.brandTint,
                borderRadius: BorderRadius.circular(12),
              ),
              alignment: Alignment.center,
              child: SvgPicture.asset(
                'assets/icons/top_bar/ic_top_menu.svg',
                width: 18,
                height: 18,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Location Management',
                  style: portalText(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: PortalColors.heading,
                    letterSpacing: 0.1,
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Manage all office locations & geo-fencing',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: portalText(
                    fontSize: 11.5,
                    color: PortalColors.muted,
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          const TopNotificationButton(),
          const SizedBox(width: 12),
          const TopCalendarButton(),
        ],
      ),
    );
  }

  Widget _buildSearchBarAnd3Filters() {
    final hasCity = _selectedCity != 'All Cities';
    final hasState = _selectedState != 'All States';
    final hasPin = _selectedPin != 'All Pins';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: double.infinity,
          height: 44,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: const Color(0xFFE2E8F0)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.02),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          padding: const EdgeInsets.symmetric(horizontal: 14),
          alignment: Alignment.center,
          child: Row(
            children: [
              const Icon(Icons.search_rounded,
                  size: 20, color: Color(0xFF64748B)),
              const SizedBox(width: 8),
              Expanded(
                child: TextField(
                  controller: _searchController,
                  onChanged: (val) {
                    setState(() {
                      _searchQuery = val;
                    });
                  },
                  style: portalText(fontSize: 13, color: PortalColors.heading),
                  decoration: InputDecoration(
                    hintText: 'Search locations, city, pin...',
                    hintStyle: portalText(
                      fontSize: 13,
                      color: const Color(0xFF94A3B8),
                    ),
                    isDense: true,
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
              ),
              if (_searchController.text.isNotEmpty)
                GestureDetector(
                  onTap: () {
                    _searchController.clear();
                    setState(() => _searchQuery = '');
                  },
                  child: const Icon(Icons.close_rounded,
                      size: 18, color: Color(0xFF94A3B8)),
                ),
            ],
          ),
        ),

        const SizedBox(height: 10),

        Row(
          children: [
            Expanded(
              child: PopupMenuButton<String>(
                offset: const Offset(0, 42),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: const BorderSide(color: Color(0xFFE2E8F0)),
                ),
                color: Colors.white,
                elevation: 4,
                onSelected: (val) {
                  setState(() => _selectedCity = val);
                },
                itemBuilder: (context) => _cities.map((c) {
                  final isSelected = c == _selectedCity;
                  return PopupMenuItem<String>(
                    value: c,
                    height: 38,
                    child: Text(
                      c,
                      style: portalText(
                        fontSize: 13,
                        fontWeight:
                            isSelected ? FontWeight.w700 : FontWeight.w500,
                        color: isSelected
                            ? PortalColors.brand
                            : const Color(0xFF334155),
                      ),
                    ),
                  );
                }).toList(),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  height: 40,
                  padding: const EdgeInsets.symmetric(horizontal: 9),
                  decoration: BoxDecoration(
                    color: hasCity ? PortalColors.brandTint : Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color:
                          hasCity ? PortalColors.brand : const Color(0xFFE2E8F0),
                      width: hasCity ? 1.4 : 1.0,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.02),
                        blurRadius: 4,
                        offset: const Offset(0, 1),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.apartment_rounded,
                        size: 15,
                        color: hasCity
                            ? PortalColors.brand
                            : const Color(0xFF64748B),
                      ),
                      const SizedBox(width: 5),
                      Expanded(
                        child: Text(
                          _selectedCity == 'All Cities' ? 'City' : _selectedCity,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: portalText(
                            fontSize: 12,
                            fontWeight:
                                hasCity ? FontWeight.w700 : FontWeight.w600,
                            color: hasCity
                                ? PortalColors.brand
                                : const Color(0xFF334155),
                          ),
                        ),
                      ),
                      if (hasCity)
                        GestureDetector(
                          onTap: () {
                            setState(() => _selectedCity = 'All Cities');
                          },
                          behavior: HitTestBehavior.opaque,
                          child: Container(
                            padding: const EdgeInsets.all(2),
                            decoration: BoxDecoration(
                              color: PortalColors.brand.withValues(alpha: 0.12),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.close_rounded,
                                size: 12, color: PortalColors.brand),
                          ),
                        )
                      else
                        const Icon(Icons.keyboard_arrow_down_rounded,
                            size: 16, color: Color(0xFF94A3B8)),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),

            Expanded(
              child: PopupMenuButton<String>(
                offset: const Offset(0, 42),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: const BorderSide(color: Color(0xFFE2E8F0)),
                ),
                color: Colors.white,
                elevation: 4,
                onSelected: (val) {
                  setState(() => _selectedState = val);
                },
                itemBuilder: (context) => _states.map((s) {
                  final isSelected = s == _selectedState;
                  return PopupMenuItem<String>(
                    value: s,
                    height: 38,
                    child: Text(
                      s,
                      style: portalText(
                        fontSize: 13,
                        fontWeight:
                            isSelected ? FontWeight.w700 : FontWeight.w500,
                        color: isSelected
                            ? PortalColors.brand
                            : const Color(0xFF334155),
                      ),
                    ),
                  );
                }).toList(),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  height: 40,
                  padding: const EdgeInsets.symmetric(horizontal: 9),
                  decoration: BoxDecoration(
                    color: hasState ? PortalColors.brandTint : Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color:
                          hasState ? PortalColors.brand : const Color(0xFFE2E8F0),
                      width: hasState ? 1.4 : 1.0,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.02),
                        blurRadius: 4,
                        offset: const Offset(0, 1),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.location_on_outlined,
                        size: 15,
                        color: hasState
                            ? PortalColors.brand
                            : const Color(0xFF64748B),
                      ),
                      const SizedBox(width: 5),
                      Expanded(
                        child: Text(
                          _selectedState == 'All States'
                              ? 'State'
                              : _selectedState,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: portalText(
                            fontSize: 12,
                            fontWeight:
                                hasState ? FontWeight.w700 : FontWeight.w600,
                            color: hasState
                                ? PortalColors.brand
                                : const Color(0xFF334155),
                          ),
                        ),
                      ),
                      if (hasState)
                        GestureDetector(
                          onTap: () {
                            setState(() => _selectedState = 'All States');
                          },
                          behavior: HitTestBehavior.opaque,
                          child: Container(
                            padding: const EdgeInsets.all(2),
                            decoration: BoxDecoration(
                              color: PortalColors.brand.withValues(alpha: 0.12),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.close_rounded,
                                size: 12, color: PortalColors.brand),
                          ),
                        )
                      else
                        const Icon(Icons.keyboard_arrow_down_rounded,
                            size: 16, color: Color(0xFF94A3B8)),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),

            Expanded(
              child: PopupMenuButton<String>(
                offset: const Offset(0, 42),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: const BorderSide(color: Color(0xFFE2E8F0)),
                ),
                color: Colors.white,
                elevation: 4,
                onSelected: (val) {
                  setState(() => _selectedPin = val);
                },
                itemBuilder: (context) => _pins.map((p) {
                  final isSelected = p == _selectedPin;
                  return PopupMenuItem<String>(
                    value: p,
                    height: 38,
                    child: Text(
                      p,
                      style: portalText(
                        fontSize: 13,
                        fontWeight:
                            isSelected ? FontWeight.w700 : FontWeight.w500,
                        color: isSelected
                            ? PortalColors.brand
                            : const Color(0xFF334155),
                      ),
                    ),
                  );
                }).toList(),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  height: 40,
                  padding: const EdgeInsets.symmetric(horizontal: 9),
                  decoration: BoxDecoration(
                    color: hasPin ? PortalColors.brandTint : Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color:
                          hasPin ? PortalColors.brand : const Color(0xFFE2E8F0),
                      width: hasPin ? 1.4 : 1.0,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.02),
                        blurRadius: 4,
                        offset: const Offset(0, 1),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.pin_drop_outlined,
                        size: 15,
                        color: hasPin
                            ? PortalColors.brand
                            : const Color(0xFF64748B),
                      ),
                      const SizedBox(width: 5),
                      Expanded(
                        child: Text(
                          _selectedPin == 'All Pins' ? 'Pin Code' : _selectedPin,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: portalText(
                            fontSize: 12,
                            fontWeight:
                                hasPin ? FontWeight.w700 : FontWeight.w600,
                            color: hasPin
                                ? PortalColors.brand
                                : const Color(0xFF334155),
                          ),
                        ),
                      ),
                      if (hasPin)
                        GestureDetector(
                          onTap: () {
                            setState(() => _selectedPin = 'All Pins');
                          },
                          behavior: HitTestBehavior.opaque,
                          child: Container(
                            padding: const EdgeInsets.all(2),
                            decoration: BoxDecoration(
                              color: PortalColors.brand.withValues(alpha: 0.12),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.close_rounded,
                                size: 12, color: PortalColors.brand),
                          ),
                        )
                      else
                        const Icon(Icons.keyboard_arrow_down_rounded,
                            size: 16, color: Color(0xFF94A3B8)),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActiveFiltersChips() {
    return Row(
      children: [
        Text(
          'Active:',
          style: portalText(fontSize: 11, color: PortalColors.muted),
        ),
        const SizedBox(width: 6),
        Expanded(
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                if (_selectedCity != 'All Cities')
                  _buildChip('City: $_selectedCity',
                      () => setState(() => _selectedCity = 'All Cities')),
                if (_selectedState != 'All States')
                  _buildChip('State: $_selectedState',
                      () => setState(() => _selectedState = 'All States')),
                if (_selectedPin != 'All Pins')
                  _buildChip('PIN: $_selectedPin',
                      () => setState(() => _selectedPin = 'All Pins')),
                if (_searchQuery.isNotEmpty)
                  _buildChip('Search: "$_searchQuery"', () {
                    _searchController.clear();
                    setState(() => _searchQuery = '');
                  }),
                GestureDetector(
                  onTap: _clearAllFilters,
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      'Clear all',
                      style: portalText(
                        fontSize: 10.5,
                        fontWeight: FontWeight.w700,
                        color: PortalColors.brand,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildChip(String label, VoidCallback onRemove) {
    return Container(
      margin: const EdgeInsets.only(right: 6),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: PortalColors.brandTint,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: PortalColors.border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: portalText(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: PortalColors.brand,
            ),
          ),
          const SizedBox(width: 4),
          GestureDetector(
            onTap: onRemove,
            child: const Icon(Icons.close, size: 12, color: PortalColors.brand),
          ),
        ],
      ),
    );
  }

  Widget _build4StatCards() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildLocationStatCard(
                title: 'TOTAL LOCATIONS',
                value: '$_totalLocations',
                icon: Icons.location_on_outlined,
                iconColor: const Color(0xFF2563EB),
                iconBg: const Color(0xFFEFF6FF),
              ),
            ),
            const SizedBox(width: 12),

            Expanded(
              child: _buildLocationStatCard(
                title: 'ACTIVE LOCATIONS',
                value: '$_activeLocations',
                hasGreenDot: true,
                icon: Icons.electric_bolt_rounded,
                iconColor: const Color(0xFF059669),
                iconBg: const Color(0xFFECFDF5),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildLocationStatCard(
                title: 'UNIQUE CITIES',
                value: '$_uniqueCities',
                icon: Icons.apartment_rounded,
                iconColor: const Color(0xFFD97706),
                iconBg: const Color(0xFFFEF3C7),
              ),
            ),
            const SizedBox(width: 12),

            Expanded(
              child: _buildLocationStatCard(
                title: 'UNIQUE STATES',
                value: '$_uniqueStates',
                icon: Icons.map_outlined,
                iconColor: const Color(0xFF7C3AED),
                iconBg: const Color(0xFFF5F3FF),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildLocationStatCard({
    required String title,
    required String value,
    bool hasGreenDot = false,
    required IconData icon,
    required Color iconColor,
    required Color iconBg,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: portalText(
              fontSize: 10.5,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF64748B),
              letterSpacing: 0.4,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    value,
                    style: portalText(
                      fontSize: 26,
                      fontWeight: FontWeight.w900,
                      color: const Color(0xFF0F172A),
                      height: 1.0,
                    ),
                  ),
                  if (hasGreenDot) ...[
                    const SizedBox(width: 4),
                    Container(
                      width: 6,
                      height: 6,
                      decoration: const BoxDecoration(
                        color: Color(0xFF10B981),
                        shape: BoxShape.circle,
                      ),
                    ),
                  ],
                ],
              ),
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: iconBg,
                  borderRadius: BorderRadius.circular(12),
                ),
                alignment: Alignment.center,
                child: Icon(icon, size: 20, color: iconColor),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(int count) {
    return Row(
      children: [
        Text(
          'CONFIGURED BRANCHES',
          style: portalText(
            fontSize: 13,
            fontWeight: FontWeight.w800,
            color: const Color(0xFF1E293B),
            letterSpacing: 0.4,
          ),
        ),
        const SizedBox(width: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
          decoration: BoxDecoration(
            color: const Color(0xFFE2E8F0),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(
            '$count',
            style: portalText(
              fontSize: 11,
              fontWeight: FontWeight.w800,
              color: const Color(0xFF475569),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBranchCard(LocationItem item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: item.badgeType.iconBg,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: item.badgeType.iconColor.withValues(alpha: 0.15),
                  ),
                ),
                alignment: Alignment.center,
                child: Icon(
                  item.badgeType.icon,
                  size: 22,
                  color: item.badgeType.iconColor,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            item.name,
                            style: portalText(
                              fontSize: 14.5,
                              fontWeight: FontWeight.w800,
                              color: const Color(0xFF0F172A),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: item.badgeType.badgeBg,
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(
                              color: item.badgeType.badgeColor
                                  .withValues(alpha: 0.3),
                            ),
                          ),
                          child: Text(
                            item.badgeType.label,
                            style: portalText(
                              fontSize: 9.5,
                              fontWeight: FontWeight.w800,
                              color: item.badgeType.badgeColor,
                              letterSpacing: 0.3,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 3),
                    Text(
                      item.address,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: portalText(
                        fontSize: 11.5,
                        color: const Color(0xFF64748B),
                        height: 1.2,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 6),
              CupertinoSwitch(
                value: item.isActive,
                activeColor: PortalColors.brand,
                onChanged: (val) => _toggleLocationActive(item, val),
              ),
            ],
          ),

          const SizedBox(height: 12),

          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 5,
                      height: 5,
                      decoration: const BoxDecoration(
                        color: Color(0xFF10B981),
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 5),
                    Text(
                      item.city,
                      style: portalText(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF334155),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),

              Flexible(
                child: Text(
                  item.state,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: portalText(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFF64748B),
                  ),
                ),
              ),
              const SizedBox(width: 8),

              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: Text(
                  'PIN ${item.pinCode}',
                  style: portalText(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF475569),
                    letterSpacing: 0.3,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),
          const Divider(height: 1, color: Color(0xFFF1F5F9)),
          const SizedBox(height: 8),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              GestureDetector(
                onTap: () => _copyToClipboard(
                    '${item.latitude}, ${item.longitude}', 'Coordinates'),
                child: Row(
                  children: [
                    const Icon(
                      Icons.location_on_outlined,
                      size: 14,
                      color: PortalColors.brandLight,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${item.latitude},  ${item.longitude}',
                      style: portalText(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w600,
                        color: PortalColors.brandLight,
                      ),
                    ),
                  ],
                ),
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  GestureDetector(
                    onTap: () => _viewLocationDetails(item),
                    child: Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        color: const Color(0xFFF8FAFC),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: const Color(0xFFE2E8F0)),
                      ),
                      alignment: Alignment.center,
                      child: const Icon(
                        Icons.visibility_outlined,
                        size: 14,
                        color: Color(0xFF64748B),
                      ),
                    ),
                  ),
                  const SizedBox(width: 6),

                  GestureDetector(
                    onTap: () => _editLocation(item),
                    child: Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        color: const Color(0xFFF8FAFC),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: const Color(0xFFE2E8F0)),
                      ),
                      alignment: Alignment.center,
                      child: const Icon(
                        Icons.edit_outlined,
                        size: 14,
                        color: PortalColors.brandLight,
                      ),
                    ),
                  ),
                  const SizedBox(width: 6),

                  GestureDetector(
                    onTap: () => _deleteLocation(item),
                    child: Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        color: const Color(0xFFFEF2F2),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: const Color(0xFFFEE2E2)),
                      ),
                      alignment: Alignment.center,
                      child: const Icon(
                        Icons.delete_outline_rounded,
                        size: 14,
                        color: Color(0xFFDC2626),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
      alignment: Alignment.center,
      child: Column(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: const BoxDecoration(
              color: Color(0xFFF1F5F9),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.location_off_outlined,
              size: 28,
              color: Color(0xFF94A3B8),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'No locations found',
            style: portalText(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: PortalColors.heading,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Try adjusting your search or filters',
            style: portalText(
              fontSize: 12,
              color: PortalColors.muted,
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _clearAllFilters,
            style: ElevatedButton.styleFrom(
              backgroundColor: PortalColors.brand,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            ),
            child: Text(
              'Reset Filters',
              style: portalText(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}
