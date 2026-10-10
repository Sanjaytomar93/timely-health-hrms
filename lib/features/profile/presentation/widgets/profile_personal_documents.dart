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
    ),
    _DocItem(
      title: 'PAN Card',
      id: 'ID: PANCARD',
      description: 'Tax identification document',
    ),
    _DocItem(
      title: '10th Certificate',
      id: 'ID: TENTHCERTIFICATE',
      description: 'Secondary school certificate',
    ),
    _DocItem(
      title: '12th Certificate',
      id: 'ID: TWELFTHCERTIFICATE',
      description: 'Higher Secondary certificate',
    ),
    _DocItem(
      title: 'Graduation Degree',
      id: 'ID: GRADUATIONCERTIFICATE',
      description: 'University degree certificate',
    ),
    _DocItem(
      title: 'Passport Photo',
      id: 'ID: PASSPORTPHOTO',
      description: 'Recent passport photograph',
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
          Container(
            padding: const EdgeInsets.fromLTRB(14, 16, 14, 14),
            decoration: BoxDecoration(
              color: PortalColors.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: PortalColors.border),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const _Header(),
                const SizedBox(height: 12),
                const _SearchField(),
                const SizedBox(height: 10),
                const _StatusDropdown(),
                const SizedBox(height: 12),
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
  });

  final String title;
  final String id;
  final String description;
}

class _Header extends StatelessWidget {
  const _Header();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: [
            const Icon(
              Icons.folder_outlined,
              size: 16,
              color: PortalColors.secondaryText,
            ),
            const SizedBox(width: 6),
            Expanded(
              child: Text(
                'Personal Documents',
                style: portalText(
                  fontSize: 13.5,
                  fontWeight: FontWeight.w700,
                  color: PortalColors.heading,
                  height: 16 / 13.5,
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: PortalColors.purpleTint,
                borderRadius: BorderRadius.circular(999),
              ),
              child: Text(
                '6 Items',
                style: portalText(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: PortalColors.purple,
                  height: 12 / 10,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Text(
          'View and access your uploaded identity and education documents.',
          style: portalText(
            fontSize: 10.5,
            color: PortalColors.muted,
            height: 14 / 10.5,
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
      height: 40,
      child: TextField(
        decoration: InputDecoration(
          hintText: 'Search by name or Description...',
          hintStyle: portalText(fontSize: 11.5, color: const Color(0xFF757575)),
          prefixIcon: const Icon(
            Icons.search,
            size: 16,
            color: PortalColors.muted,
          ),
          prefixIconConstraints: const BoxConstraints(
            minWidth: 36,
            minHeight: 40,
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
          focusedBorder: _border(PortalColors.purple),
        ),
        style: portalText(fontSize: 12, color: PortalColors.heading),
      ),
    );
  }

  static OutlineInputBorder _border([Color? color]) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(11),
      borderSide: BorderSide(color: color ?? PortalColors.border),
    );
  }
}

class _StatusDropdown extends StatelessWidget {
  const _StatusDropdown();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 38,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: PortalColors.background,
        borderRadius: BorderRadius.circular(11),
        border: Border.all(color: PortalColors.border),
      ),
      child: Row(
        children: [
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
        color: PortalColors.surface,
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
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: PortalColors.purpleTint,
                  borderRadius: BorderRadius.circular(9),
                ),
                alignment: Alignment.center,
                child: SvgPicture.asset(
                  'assets/icons/profile/ic_doc_card.svg',
                  width: 16,
                  height: 16,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      item.title,
                      style: portalText(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w700,
                        color: PortalColors.heading,
                        height: 15 / 12.5,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      item.id,
                      style: portalText(
                        fontSize: 10.5,
                        fontWeight: FontWeight.w500,
                        color: PortalColors.muted,
                        height: 13 / 10.5,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      item.description,
                      style: portalText(
                        fontSize: 10.5,
                        color: PortalColors.muted,
                        height: 13 / 10.5,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: PortalColors.orangeTint,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  'Pending',
                  style: portalText(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: PortalColors.orange,
                    height: 12 / 10,
                  ),
                ),
              ),
              const Spacer(),
              Text(
                'Access : N/A',
                style: portalText(
                  fontSize: 10.5,
                  fontWeight: FontWeight.w600,
                  color: PortalColors.muted,
                  height: 13 / 10.5,
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
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
      decoration: BoxDecoration(
        color: PortalColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: PortalColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Text(
                'Banking Vault',
                style: portalText(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: PortalColors.heading,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
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
                    height: 12 / 9.5,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const _FieldBlock(
            label: 'INSTITUTION NAME',
            value: 'Pending Verification',
          ),
          const SizedBox(height: 10),
          const _FieldBlock(
            label: 'ACCOUNT NUMBER',
            value: '•••• •••• •••• 4291',
          ),
          const SizedBox(height: 10),
          const _FieldBlock(label: 'IFSC CODE', value: 'N/A'),
        ],
      ),
    );
  }
}

class _EmergencyHubCard extends StatelessWidget {
  const _EmergencyHubCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
      decoration: BoxDecoration(
        color: PortalColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: PortalColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Text(
                'Emergency Hub',
                style: portalText(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: PortalColors.heading,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
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
                    height: 12 / 9.5,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const _FieldBlock(label: 'CONTACT IDENTITY (NAME)', value: 'RYAN'),
          const SizedBox(height: 10),
          const _FieldBlock(
            label: 'DIRECT SECTOR (PHONE)',
            value: '+91 98765 43210',
          ),
          const SizedBox(height: 10),
          const _FieldBlock(label: 'RELATIONSHIP (NAME)', value: 'N/A'),
        ],
      ),
    );
  }
}

class _FieldBlock extends StatelessWidget {
  const _FieldBlock({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label,
          style: portalText(
            fontSize: 9.5,
            fontWeight: FontWeight.w700,
            color: PortalColors.muted,
            letterSpacing: 0.3,
            height: 12 / 9.5,
          ),
        ),
        const SizedBox(height: 6),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
          decoration: BoxDecoration(
            color: const Color(0xFFF6F5FC),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: PortalColors.border),
          ),
          child: Text(
            value,
            style: portalText(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: PortalColors.secondaryText,
              height: 15 / 12,
            ),
          ),
        ),
      ],
    );
  }
}
