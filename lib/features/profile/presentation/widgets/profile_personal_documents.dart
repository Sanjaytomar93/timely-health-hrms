import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:timelay_health/core/theme/portal_colors.dart';
import 'package:timelay_health/core/theme/portal_text.dart';

class ProfilePersonalDocuments extends StatelessWidget {
  const ProfilePersonalDocuments({super.key});

  static const _docs = [
    _DocItem(
      title: 'Aadhar / National ID',
      id: 'ID: AADHARCARD',
      description: 'Government-issued identity proof',
      tint: Color(0xFFEAF0FD),
      accent: Color(0xFF3B6FE0),
    ),
    _DocItem(
      title: 'PAN Card',
      id: 'ID: PANCARD',
      description: 'Tax identification document',
      tint: PortalColors.orangeTint,
      accent: PortalColors.orange,
    ),
    _DocItem(
      title: '10th Certificate',
      id: 'ID: TENTHCERTIFICATE',
      description: 'Secondary school certificate',
      tint: PortalColors.purpleTint,
      accent: PortalColors.brand,
    ),
    _DocItem(
      title: '12th Certificate',
      id: 'ID: TWELFTHCERTIFICATE',
      description: 'Higher Secondary certificate',
      tint: PortalColors.greenTint,
      accent: PortalColors.green,
    ),
    _DocItem(
      title: 'Graduation Degree',
      id: 'ID: GRADUATIONCERTIFICATE',
      description: 'University degree certificate',
      tint: Color(0xFFEAF0FD),
      accent: Color(0xFF3B6FE0),
    ),
    _DocItem(
      title: 'Passport Photo',
      id: 'ID: PASSPORTPHOTO',
      description: 'Recent passport photograph',
      tint: PortalColors.redTint,
      accent: PortalColors.red,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _SectionCard(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const _Header(),
                const SizedBox(height: 14),
                const _SearchField(),
                const SizedBox(height: 10),
                const _StatusDropdown(),
                const SizedBox(height: 14),
                for (var i = 0; i < _docs.length; i++) ...[
                  if (i > 0) const SizedBox(height: 10),
                  _DocumentCard(item: _docs[i]),
                ],
              ],
            ),
          ),
          const SizedBox(height: 12),
          const _BankingVaultCard(),
          const SizedBox(height: 12),
          const _EmergencyHubCard(),
        ],
      ),
    );
  }
}

class _DocItem {
  const _DocItem({
    required this.title,
    required this.id,
    required this.description,
    required this.tint,
    required this.accent,
  });

  final String title;
  final String id;
  final String description;
  final Color tint;
  final Color accent;
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 16, 14, 14),
      decoration: BoxDecoration(
        color: PortalColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: PortalColors.border),
        boxShadow: [
          BoxShadow(
            color: PortalColors.brand.withValues(alpha: 0.05),
            blurRadius: 14,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: child,
    );
  }
}

class _Header extends StatelessWidget {
  const _Header();

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: PortalColors.purpleTint,
            borderRadius: BorderRadius.circular(11),
          ),
          alignment: Alignment.center,
          child: const Icon(
            Icons.folder_outlined,
            size: 18,
            color: PortalColors.brand,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Personal Documents',
                style: portalText(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: PortalColors.heading,
                  height: 1.2,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                'Identity & education files in one place',
                style: portalText(
                  fontSize: 11,
                  color: PortalColors.muted,
                  height: 1.3,
                ),
              ),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
          decoration: BoxDecoration(
            color: PortalColors.purpleTint,
            borderRadius: BorderRadius.circular(999),
          ),
          child: Text(
            '6 items',
            style: portalText(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: PortalColors.brand,
              height: 1.2,
            ),
          ),
        ),
      ],
    );
  }
}

class _SearchField extends StatelessWidget {
  const _SearchField();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 42,
      child: TextField(
        decoration: InputDecoration(
          hintText: 'Search documents...',
          hintStyle: portalText(fontSize: 12, color: PortalColors.muted),
          prefixIcon: const Icon(
            Icons.search_rounded,
            size: 18,
            color: PortalColors.muted,
          ),
          prefixIconConstraints: const BoxConstraints(
            minWidth: 40,
            minHeight: 42,
          ),
          filled: true,
          fillColor: PortalColors.background,
          isDense: true,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 10,
          ),
          border: _border(),
          enabledBorder: _border(),
          focusedBorder: _border(PortalColors.brand),
        ),
        style: portalText(fontSize: 12.5, color: PortalColors.heading),
      ),
    );
  }

  static OutlineInputBorder _border([Color? color]) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: color ?? PortalColors.border),
    );
  }
}

class _StatusDropdown extends StatelessWidget {
  const _StatusDropdown();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 40,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: PortalColors.background,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: PortalColors.border),
      ),
      child: Row(
        children: [
          Icon(
            Icons.filter_list_rounded,
            size: 16,
            color: PortalColors.muted.withValues(alpha: 0.9),
          ),
          const SizedBox(width: 8),
          Text(
            'All Statuses',
            style: portalText(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: PortalColors.secondaryText,
            ),
          ),
          const Spacer(),
          const Icon(
            Icons.keyboard_arrow_down_rounded,
            size: 18,
            color: PortalColors.muted,
          ),
        ],
      ),
    );
  }
}

class _DocumentCard extends StatelessWidget {
  const _DocumentCard({required this.item});

  final _DocItem item;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
      decoration: BoxDecoration(
        color: PortalColors.background,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: PortalColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: item.tint,
                  borderRadius: BorderRadius.circular(12),
                ),
                alignment: Alignment.center,
                child: SvgPicture.asset(
                  'assets/icons/profile/ic_doc_card.svg',
                  width: 18,
                  height: 18,
                ),
              ),
              const SizedBox(width: 11),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      item.title,
                      style: portalText(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: PortalColors.heading,
                        height: 1.2,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      item.id,
                      style: portalText(
                        fontSize: 10.5,
                        fontWeight: FontWeight.w600,
                        color: item.accent,
                        height: 1.2,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      item.description,
                      style: portalText(
                        fontSize: 11,
                        color: PortalColors.muted,
                        height: 1.3,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                decoration: BoxDecoration(
                  color: PortalColors.orangeTint,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 6,
                      height: 6,
                      decoration: const BoxDecoration(
                        color: PortalColors.orange,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 5),
                    Text(
                      'Pending',
                      style: portalText(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: PortalColors.orange,
                        height: 1.2,
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              Icon(
                Icons.lock_outline_rounded,
                size: 13,
                color: PortalColors.muted.withValues(alpha: 0.85),
              ),
              const SizedBox(width: 4),
              Text(
                'Access: N/A',
                style: portalText(
                  fontSize: 10.5,
                  fontWeight: FontWeight.w600,
                  color: PortalColors.muted,
                  height: 1.2,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _BankingVaultCard extends StatelessWidget {
  const _BankingVaultCard();

  @override
  Widget build(BuildContext context) {
    return _SectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: PortalColors.greenTint,
                  borderRadius: BorderRadius.circular(10),
                ),
                alignment: Alignment.center,
                child: const Icon(
                  Icons.account_balance_outlined,
                  size: 17,
                  color: PortalColors.green,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Banking Vault',
                  style: portalText(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w700,
                    color: PortalColors.heading,
                    height: 1.2,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                decoration: BoxDecoration(
                  color: PortalColors.greenTint,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  'VERIFIED',
                  style: portalText(
                    fontSize: 9.5,
                    fontWeight: FontWeight.w700,
                    color: PortalColors.green,
                    height: 1.2,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          const _FieldBlock(
            label: 'Institution name',
            value: 'Pending Verification',
            icon: Icons.business_outlined,
          ),
          const SizedBox(height: 10),
          const _FieldBlock(
            label: 'Account number',
            value: '•••• •••• •••• 4291',
            icon: Icons.credit_card_outlined,
          ),
          const SizedBox(height: 10),
          const _FieldBlock(
            label: 'IFSC code',
            value: 'N/A',
            icon: Icons.tag_rounded,
          ),
        ],
      ),
    );
  }
}

class _EmergencyHubCard extends StatelessWidget {
  const _EmergencyHubCard();

  @override
  Widget build(BuildContext context) {
    return _SectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: PortalColors.redTint,
                  borderRadius: BorderRadius.circular(10),
                ),
                alignment: Alignment.center,
                child: const Icon(
                  Icons.emergency_outlined,
                  size: 17,
                  color: PortalColors.red,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Emergency Hub',
                  style: portalText(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w700,
                    color: PortalColors.heading,
                    height: 1.2,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                decoration: BoxDecoration(
                  color: PortalColors.redTint,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  'PRIORITY 1',
                  style: portalText(
                    fontSize: 9.5,
                    fontWeight: FontWeight.w700,
                    color: PortalColors.red,
                    height: 1.2,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          const _FieldBlock(
            label: 'Contact name',
            value: 'RYAN',
            icon: Icons.person_outline_rounded,
          ),
          const SizedBox(height: 10),
          const _FieldBlock(
            label: 'Phone number',
            value: '+91 98765 43210',
            icon: Icons.phone_outlined,
          ),
          const SizedBox(height: 10),
          const _FieldBlock(
            label: 'Relationship',
            value: 'N/A',
            icon: Icons.favorite_border_rounded,
          ),
        ],
      ),
    );
  }
}

class _FieldBlock extends StatelessWidget {
  const _FieldBlock({
    required this.label,
    required this.value,
    required this.icon,
  });

  final String label;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label.toUpperCase(),
          style: portalText(
            fontSize: 9.5,
            fontWeight: FontWeight.w700,
            color: PortalColors.muted,
            letterSpacing: 0.4,
            height: 1.2,
          ),
        ),
        const SizedBox(height: 6),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
          decoration: BoxDecoration(
            color: PortalColors.background,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: PortalColors.border),
          ),
          child: Row(
            children: [
              Icon(icon, size: 15, color: PortalColors.muted),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  value,
                  style: portalText(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w600,
                    color: PortalColors.secondaryText,
                    height: 1.2,
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
