import 'package:equatable/equatable.dart';
import 'package:timelay_health/core/utils/time_format.dart';
import 'package:timelay_health/features/letters/domain/entities/letter.dart';

enum LetterType {
  experience('Experience'),
  relieving('Relieving'),
  resignation('Resignation');

  const LetterType(this.label);

  final String label;

  static LetterType? fromApi(String value) {
    switch (value.trim().toLowerCase()) {
      case 'experience':
        return LetterType.experience;
      case 'relieving':
        return LetterType.relieving;
      case 'resignation':
        return LetterType.resignation;
    }
    return null;
  }
}

class EmployeeLetter extends Equatable {
  const EmployeeLetter({
    required this.id,
    required this.type,
    required this.employeeName,
    required this.employeeId,
    required this.designation,
    required this.periodLabel,
    required this.status,
    required this.sentOnDate,
    required this.sentOnTime,
    this.fileUrl,
    this.details = '',
  });

  final String id;
  final LetterType type;
  final String employeeName;
  final String employeeId;
  final String designation;
  final String periodLabel;
  final String status;
  final String sentOnDate;
  final String sentOnTime;
  final String? fileUrl;
  final String details;

  bool get isSent => status.toLowerCase() == 'sent';

  bool get hasFile => fileUrl != null && fileUrl!.isNotEmpty;

  String get fileName {
    final safeName = employeeName.trim().isEmpty
        ? employeeId
        : employeeName.trim().replaceAll(RegExp(r'\s+'), '_');
    return '${type.label}_Letter_$safeName.pdf';
  }

  @override
  List<Object?> get props => [
    id,
    type,
    employeeName,
    employeeId,
    designation,
    periodLabel,
    status,
    sentOnDate,
    sentOnTime,
    fileUrl,
    details,
  ];
}

class LetterUiMapper {
  const LetterUiMapper._();

  static const _months = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];

  static List<EmployeeLetter> toUiList(List<Letter> letters) {
    final sorted = [...letters]
      ..sort((a, b) {
        final ad = a.sentAt ?? DateTime.fromMillisecondsSinceEpoch(0);
        final bd = b.sentAt ?? DateTime.fromMillisecondsSinceEpoch(0);
        return bd.compareTo(ad);
      });
    return [for (final letter in sorted) ?toUi(letter)];
  }

  static EmployeeLetter? toUi(Letter letter) {
    final type = LetterType.fromApi(letter.letterType);
    if (type == null) return null;
    final sentAt = letter.sentAt?.toLocal();
    return EmployeeLetter(
      id: letter.id,
      type: type,
      employeeName: letter.employeeName,
      employeeId: letter.employeeId,
      designation: letter.designation,
      periodLabel: _period(letter.joiningDate, letter.relievingDate),
      status: letter.status.isEmpty ? 'sent' : letter.status,
      sentOnDate: sentAt == null
          ? '—'
          : '${sentAt.day.toString().padLeft(2, '0')} '
                '${_months[sentAt.month - 1]} ${sentAt.year}',
      sentOnTime: TimeFormat.clock(sentAt),
      fileUrl: letter.fileUrl.isEmpty ? null : letter.fileUrl,
      details: letter.details,
    );
  }

  static String _period(String from, String to) {
    if (from.isEmpty && to.isEmpty) return '—';
    return '${from.isEmpty ? '—' : from} → ${to.isEmpty ? '—' : to}';
  }
}
