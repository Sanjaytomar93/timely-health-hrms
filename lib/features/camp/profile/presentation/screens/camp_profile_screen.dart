import 'package:flutter/material.dart';
import 'package:timelay_health/features/camp/dashboard/presentation/theme/camp_colors.dart';
import 'package:timelay_health/features/camp/dashboard/presentation/widgets/camp_top_bar.dart';
import 'package:timelay_health/features/camp/members/presentation/widgets/member_tokens.dart';

class CampProfileScreen extends StatefulWidget {
  const CampProfileScreen({super.key});

  @override
  State<CampProfileScreen> createState() => _CampProfileScreenState();
}

class _CampProfileScreenState extends State<CampProfileScreen> {
  final _weight = TextEditingController(text: '71.8');
  final _height = TextEditingController(text: '162');
  final _sugar = TextEditingController(text: '129');
  final _bpSys = TextEditingController(text: '135');
  final _bpDia = TextEditingController(text: '80');
  String _sugarType = 'Random';

  @override
  void dispose() {
    _weight.dispose();
    _height.dispose();
    _sugar.dispose();
    _bpSys.dispose();
    _bpDia.dispose();
    super.dispose();
  }

  double? get _bmi {
    final w = double.tryParse(_weight.text.trim());
    final h = double.tryParse(_height.text.trim());
    if (w == null || h == null || h <= 0) return null;
    final meters = h / 100;
    return w / (meters * meters);
  }

  ({String label, Color color, Color bg}) get _bmiMeta {
    final bmi = _bmi;
    if (bmi == null) {
      return (
        label: '—',
        color: kMemberMuted,
        bg: const Color(0xFFF3F2F7),
      );
    }
    if (bmi < 18.5) {
      return (
        label: 'Underweight',
        color: const Color(0xFF185FA5),
        bg: const Color(0xFFE8F1FB),
      );
    }
    if (bmi < 25) {
      return (
        label: 'Healthy',
        color: const Color(0xFF0F6E56),
        bg: const Color(0xFFE8F7F2),
      );
    }
    if (bmi < 30) {
      return (
        label: 'Overweight',
        color: const Color(0xFFB45309),
        bg: const Color(0xFFFFF3E6),
      );
    }
    return (
      label: 'Obese',
      color: const Color(0xFFE0483E),
      bg: const Color(0xFFFDECEC),
    );
  }

  void _updateVitals() {
    setState(() {});
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Vitals updated successfully'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bmi = _bmi;
    final meta = _bmiMeta;

    return ColoredBox(
      color: CampColors.background,
      child: Column(
        children: [
          const CampTopBar(),
          Expanded(
            child: ListView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(14, 12, 14, 24),
              children: [
                const _IdentityCard(
                  initials: 'RA',
                  name: 'Ravi',
                  meta: '28 years · Male',
                  phone: 'Ph: 9045326754',
                  location: 'Hyderabad',
                ),
                const SizedBox(height: 12),
                _StatsGrid(
                  weight: '${_weight.text} kg',
                  height: '${_height.text} cm',
                  sugar: '${_sugar.text} mg/dL',
                  sugarType: _sugarType,
                  bp: '${_bpSys.text}/${_bpDia.text}',
                ),
                const SizedBox(height: 12),
                _ClinicalVitalsCard(
                  weight: _weight,
                  height: _height,
                  sugar: _sugar,
                  bpSys: _bpSys,
                  bpDia: _bpDia,
                  sugarType: _sugarType,
                  onSugarTypeChanged: (v) => setState(() => _sugarType = v),
                  bmi: bmi,
                  bmiLabel: meta.label,
                  bmiColor: meta.color,
                  bmiBg: meta.bg,
                  onChanged: () => setState(() {}),
                  onUpdate: _updateVitals,
                ),
                const SizedBox(height: 16),
                const _RecentEntries(),
                const SizedBox(height: 12),
                _MedicalHistory(
                  weight: _weight.text,
                  height: _height.text,
                  sugar: _sugar.text,
                  sugarType: _sugarType,
                  bp: '${_bpSys.text}/${_bpDia.text}',
                  bmiLabel: meta.label,
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Health report download started'),
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    },
                    icon: const Icon(Icons.download_rounded, size: 18),
                    label: const Text(
                      'Download health report',
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF18AC96),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _IdentityCard extends StatelessWidget {
  const _IdentityCard({
    required this.initials,
    required this.name,
    required this.meta,
    required this.phone,
    required this.location,
  });

  final String initials;
  final String name;
  final String meta;
  final String phone;
  final String location;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF1A1635), kMemberPrimary, Color(0xFF4B4285)],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: kMemberPrimary.withValues(alpha: 0.28),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 54,
            height: 54,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.18),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.white.withValues(alpha: 0.22)),
            ),
            child: Text(
              initials,
              style: const TextStyle(
                fontFamily: 'Inter',
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  meta,
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 12.5,
                    color: Colors.white.withValues(alpha: 0.85),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  phone,
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 12.5,
                    color: Colors.white.withValues(alpha: 0.85),
                  ),
                ),
                Text(
                  location,
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 12.5,
                    color: Colors.white.withValues(alpha: 0.85),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StatsGrid extends StatelessWidget {
  const _StatsGrid({
    required this.weight,
    required this.height,
    required this.sugar,
    required this.sugarType,
    required this.bp,
  });

  final String weight;
  final String height;
  final String sugar;
  final String sugarType;
  final String bp;

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 10,
      crossAxisSpacing: 10,
      childAspectRatio: 1.55,
      children: [
        _StatCard(
          icon: Icons.monitor_weight_outlined,
          tint: const Color(0xFFF0EEF8),
          iconColor: kMemberPrimary,
          value: weight,
          label: 'Weight',
        ),
        _StatCard(
          icon: Icons.height_rounded,
          tint: const Color(0xFFE8F1FB),
          iconColor: const Color(0xFF185FA5),
          value: height,
          label: 'Height',
        ),
        _StatCard(
          icon: Icons.water_drop_rounded,
          tint: const Color(0xFFFFF3E6),
          iconColor: const Color(0xFFD97706),
          value: sugar,
          label: 'Sugar ($sugarType)',
        ),
        _StatCard(
          icon: Icons.monitor_heart_outlined,
          tint: const Color(0xFFE8F7F2),
          iconColor: const Color(0xFF0F6E56),
          value: bp,
          label: 'Blood pressure',
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.icon,
    required this.tint,
    required this.iconColor,
    required this.value,
    required this.label,
  });

  final IconData icon;
  final Color tint;
  final Color iconColor;
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: kMemberBorder),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 30,
            height: 30,
            decoration: BoxDecoration(
              color: tint,
              borderRadius: BorderRadius.circular(9),
            ),
            child: Icon(icon, size: 16, color: iconColor),
          ),
          const Spacer(),
          Text(
            value,
            style: const TextStyle(
              fontFamily: 'Inter',
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: kMemberHeading,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontFamily: 'Inter',
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: kMemberMuted,
            ),
          ),
        ],
      ),
    );
  }
}

class _ClinicalVitalsCard extends StatelessWidget {
  const _ClinicalVitalsCard({
    required this.weight,
    required this.height,
    required this.sugar,
    required this.bpSys,
    required this.bpDia,
    required this.sugarType,
    required this.onSugarTypeChanged,
    required this.bmi,
    required this.bmiLabel,
    required this.bmiColor,
    required this.bmiBg,
    required this.onChanged,
    required this.onUpdate,
  });

  final TextEditingController weight;
  final TextEditingController height;
  final TextEditingController sugar;
  final TextEditingController bpSys;
  final TextEditingController bpDia;
  final String sugarType;
  final ValueChanged<String> onSugarTypeChanged;
  final double? bmi;
  final String bmiLabel;
  final Color bmiColor;
  final Color bmiBg;
  final VoidCallback onChanged;
  final VoidCallback onUpdate;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: kMemberBorder),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Clinical vitals',
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 15,
              fontWeight: FontWeight.w800,
              color: kMemberHeading,
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: _Field(
                  label: 'Weight (kg)',
                  controller: weight,
                  onChanged: (_) => onChanged(),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _Field(
                  label: 'Height (cm)',
                  controller: height,
                  onChanged: (_) => onChanged(),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _BmiBanner(
            value: bmi,
            label: bmiLabel,
            color: bmiColor,
            bg: bmiBg,
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _SugarField(
                  controller: sugar,
                  sugarType: sugarType,
                  onTypeChanged: onSugarTypeChanged,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _BpField(sys: bpSys, dia: bpDia),
              ),
            ],
          ),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            height: 46,
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [kMemberPrimary, kMemberPrimaryLight],
                ),
                borderRadius: BorderRadius.circular(13),
                boxShadow: [
                  BoxShadow(
                    color: kMemberPrimary.withValues(alpha: 0.28),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: onUpdate,
                  borderRadius: BorderRadius.circular(13),
                  child: const Center(
                    child: Text(
                      'Update vitals',
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
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

class _BmiBanner extends StatelessWidget {
  const _BmiBanner({
    required this.value,
    required this.label,
    required this.color,
    required this.bg,
  });

  final double? value;
  final String label;
  final Color color;
  final Color bg;

  @override
  Widget build(BuildContext context) {
    final bmi = value ?? 0;
    final progress = ((bmi.clamp(15, 35) - 15) / 20).clamp(0.0, 1.0);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                value?.toStringAsFixed(1) ?? '—',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  color: color,
                  height: 1,
                ),
              ),
              const SizedBox(width: 8),
              Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Text(
                  'BMI · $label',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: color,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            '18.5 – 24.9 is healthy',
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 11.5,
              color: color.withValues(alpha: 0.85),
            ),
          ),
          const SizedBox(height: 10),
          LayoutBuilder(
            builder: (context, constraints) {
              final x = (constraints.maxWidth - 14) * progress;
              return SizedBox(
                height: 14,
                child: Stack(
                  alignment: Alignment.centerLeft,
                  children: [
                    Container(
                      height: 8,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(6),
                        gradient: const LinearGradient(
                          colors: [
                            Color(0xFF60A5FA),
                            Color(0xFF34D399),
                            Color(0xFFFBBF24),
                            Color(0xFFF87171),
                          ],
                        ),
                      ),
                    ),
                    Positioned(
                      left: x,
                      child: Container(
                        width: 14,
                        height: 14,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          border: Border.all(color: color, width: 2.5),
                          boxShadow: [
                            BoxShadow(
                              color: color.withValues(alpha: 0.35),
                              blurRadius: 6,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _Field extends StatelessWidget {
  const _Field({
    required this.label,
    required this.controller,
    this.onChanged,
  });

  final String label;
  final TextEditingController controller;
  final ValueChanged<String>? onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontFamily: 'Inter',
            fontSize: 11.5,
            fontWeight: FontWeight.w700,
            color: kMemberMuted,
          ),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          onChanged: onChanged,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          style: const TextStyle(
            fontFamily: 'Inter',
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: kMemberHeading,
          ),
          decoration: InputDecoration(
            filled: true,
            fillColor: const Color(0xFFF7F6FB),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: kMemberBorder),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: kMemberBorder),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: kMemberPrimary, width: 1.2),
            ),
          ),
        ),
      ],
    );
  }
}

class _SugarField extends StatelessWidget {
  const _SugarField({
    required this.controller,
    required this.sugarType,
    required this.onTypeChanged,
  });

  final TextEditingController controller;
  final String sugarType;
  final ValueChanged<String> onTypeChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Sugar (mg/dL)',
          style: TextStyle(
            fontFamily: 'Inter',
            fontSize: 11.5,
            fontWeight: FontWeight.w700,
            color: kMemberMuted,
          ),
        ),
        const SizedBox(height: 6),
        Container(
          height: 48,
          padding: const EdgeInsets.only(left: 10, right: 6),
          decoration: BoxDecoration(
            color: const Color(0xFFF7F6FB),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: kMemberBorder),
          ),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: controller,
                  keyboardType: TextInputType.number,
                  style: const TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: kMemberHeading,
                  ),
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6),
                decoration: BoxDecoration(
                  color: kMemberPrimary.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: sugarType,
                    isDense: true,
                    icon: const Icon(
                      Icons.keyboard_arrow_down_rounded,
                      size: 16,
                      color: kMemberPrimary,
                    ),
                    style: const TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 11.5,
                      fontWeight: FontWeight.w800,
                      color: kMemberPrimary,
                    ),
                    items: const [
                      DropdownMenuItem(value: 'Fasting', child: Text('Fasting')),
                      DropdownMenuItem(value: 'Random', child: Text('Random')),
                      DropdownMenuItem(value: 'PP', child: Text('PP')),
                    ],
                    onChanged: (v) {
                      if (v != null) onTypeChanged(v);
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _BpField extends StatelessWidget {
  const _BpField({required this.sys, required this.dia});

  final TextEditingController sys;
  final TextEditingController dia;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'BP (Sys/Dia)',
          style: TextStyle(
            fontFamily: 'Inter',
            fontSize: 11.5,
            fontWeight: FontWeight.w700,
            color: kMemberMuted,
          ),
        ),
        const SizedBox(height: 6),
        Container(
          height: 48,
          decoration: BoxDecoration(
            color: const Color(0xFFF7F6FB),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: kMemberBorder),
          ),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: sys,
                  keyboardType: TextInputType.number,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: kMemberHeading,
                  ),
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
              ),
              const Text(
                '/',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w800,
                  color: kMemberMuted,
                ),
              ),
              Expanded(
                child: TextField(
                  controller: dia,
                  keyboardType: TextInputType.number,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: kMemberHeading,
                  ),
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _RecentEntries extends StatelessWidget {
  const _RecentEntries();

  static const _items = [
    ('20/01/2026, 13:35:18', 'BP: 135/80'),
    ('20/01/2026, 13:35:18', 'Sugar: 129 mg/dL (Random)'),
    ('20/01/2026, 13:35:18', 'Height: 162 cm'),
    ('20/01/2026, 13:35:18', 'Weight: 71.8 kg'),
  ];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 8),
      child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'RECENT ENTRIES',
          style: TextStyle(
            fontFamily: 'Inter',
            fontSize: 11,
            fontWeight: FontWeight.w800,
            color: kMemberMuted,
            letterSpacing: 0.6,
          ),
        ),
        const SizedBox(height: 10),
        ..._items.map(
          (e) => Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 8,
                  height: 8,
                  margin: const EdgeInsets.only(top: 5),
                  decoration: const BoxDecoration(
                    color: kMemberPrimary,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: RichText(
                    text: TextSpan(
                      style: const TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 12.5,
                        height: 1.35,
                      ),
                      children: [
                        TextSpan(
                          text: '${e.$1}  ',
                          style: const TextStyle(
                            color: kMemberMuted,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        TextSpan(
                          text: e.$2,
                          style: const TextStyle(
                            color: kMemberHeading,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    ),
    );
  }
}

class _MedicalHistory extends StatelessWidget {
  const _MedicalHistory({
    required this.weight,
    required this.height,
    required this.sugar,
    required this.sugarType,
    required this.bp,
    required this.bmiLabel,
  });

  final String weight;
  final String height;
  final String sugar;
  final String sugarType;
  final String bp;
  final String bmiLabel;

  @override
  Widget build(BuildContext context) {
    final items = [
      _Hist(
        icon: Icons.monitor_heart_outlined,
        tint: const Color(0xFFFFE8EC),
        iconColor: const Color(0xFFE0483E),
        title: 'BP',
        value: bp,
        time: '20/01/2026, 13:35:18',
        tag: 'High',
        tagBg: const Color(0xFFFDECEC),
        tagFg: const Color(0xFFE0483E),
      ),
      _Hist(
        icon: Icons.water_drop_rounded,
        tint: const Color(0xFFFFF3E6),
        iconColor: const Color(0xFFD97706),
        title: 'Sugar',
        value: '$sugar mg/dL',
        time: '20/01/2026, 13:35:18',
        tag: sugarType,
        tagBg: const Color(0xFFFFF3E6),
        tagFg: const Color(0xFFD97706),
      ),
      _Hist(
        icon: Icons.height_rounded,
        tint: const Color(0xFFE8F1FB),
        iconColor: const Color(0xFF185FA5),
        title: 'Height',
        value: '$height cm',
        time: '20/01/2026, 13:35:18',
      ),
      _Hist(
        icon: Icons.monitor_weight_outlined,
        tint: const Color(0xFFF0EEF8),
        iconColor: kMemberPrimary,
        title: 'Weight',
        value: '$weight kg',
        time: '20/01/2026, 13:35:18',
        tag: '$bmiLabel BMI',
        tagBg: const Color(0xFFFFF3E6),
        tagFg: const Color(0xFFB45309),
      ),
    ];

    return Container(
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: kMemberBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Medical history',
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 15,
              fontWeight: FontWeight.w800,
              color: kMemberHeading,
            ),
          ),
          const SizedBox(height: 12),
          ...items.map((e) => _HistoryTile(item: e)),
        ],
      ),
    );
  }
}

class _Hist {
  const _Hist({
    required this.icon,
    required this.tint,
    required this.iconColor,
    required this.title,
    required this.value,
    required this.time,
    this.tag,
    this.tagBg,
    this.tagFg,
  });

  final IconData icon;
  final Color tint;
  final Color iconColor;
  final String title;
  final String value;
  final String time;
  final String? tag;
  final Color? tagBg;
  final Color? tagFg;
}

class _HistoryTile extends StatelessWidget {
  const _HistoryTile({required this.item});

  final _Hist item;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F7FC),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: kMemberBorder),
      ),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: item.tint,
              borderRadius: BorderRadius.circular(11),
            ),
            child: Icon(item.icon, size: 18, color: item.iconColor),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${item.title}  ·  ${item.value}',
                  style: const TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    color: kMemberHeading,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  item.time,
                  style: const TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 11,
                    color: kMemberMuted,
                  ),
                ),
              ],
            ),
          ),
          if (item.tag != null)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: item.tagBg,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                item.tag!,
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 10.5,
                  fontWeight: FontWeight.w800,
                  color: item.tagFg,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
