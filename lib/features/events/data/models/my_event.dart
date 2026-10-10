enum EventType {
  birthday('birthday', 'Birthday', '🎂'),
  anniversary('anniversary', 'Anniversary', '🎊'),
  achievement('achievement', 'Achievement', '🏆'),
  appointment('appointment', 'Appointment', '📅'),
  other('other', 'Other', '📌');

  const EventType(this.apiValue, this.label, this.emoji);

  final String apiValue;
  final String label;
  final String emoji;

  static EventType fromApi(String? value) {
    final v = value?.trim().toLowerCase() ?? '';
    return EventType.values.firstWhere(
      (t) => t.apiValue == v,
      orElse: () => EventType.other,
    );
  }
}

enum EventRepeat {
  none('none', 'One time'),
  yearly('yearly', 'Yearly');

  const EventRepeat(this.apiValue, this.label);

  final String apiValue;
  final String label;

  static EventRepeat fromApi(String? value) =>
      value?.trim().toLowerCase() == 'yearly'
      ? EventRepeat.yearly
      : EventRepeat.none;
}

enum EventStatus { upcoming, today, completed }

class MyEvent {
  const MyEvent({
    required this.id,
    required this.title,
    required this.type,
    required this.date,
    required this.reminderBefore,
    required this.repeat,
    required this.notes,
  });

  final String id;
  final String title;
  final EventType type;

  /// Calendar date only (local midnight); the API stores it as UTC midnight.
  final DateTime date;
  final int reminderBefore;
  final EventRepeat repeat;
  final String notes;

  factory MyEvent.fromJson(Map<String, dynamic> json) {
    final parsed = DateTime.tryParse(json['date']?.toString() ?? '')?.toUtc();
    return MyEvent(
      id: (json['_id'] ?? json['id'])?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      type: EventType.fromApi(json['eventType']?.toString()),
      date: parsed == null
          ? _today()
          : DateTime(parsed.year, parsed.month, parsed.day),
      reminderBefore: int.tryParse('${json['reminderBefore'] ?? 0}') ?? 0,
      repeat: EventRepeat.fromApi(json['repeat']?.toString()),
      notes: json['notes']?.toString() ?? '',
    );
  }

  static DateTime _today() {
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day);
  }

  /// Days from today to [date]; negative when the date has passed.
  int get daysFromToday => date.difference(_today()).inDays;

  /// Next date this event happens on or after today (rolls yearly events).
  DateTime get nextOccurrence {
    final today = _today();
    if (repeat != EventRepeat.yearly || !date.isBefore(today)) return date;
    var next = DateTime(today.year, date.month, date.day);
    if (next.isBefore(today)) {
      next = DateTime(today.year + 1, date.month, date.day);
    }
    return next;
  }

  int get daysToNext => nextOccurrence.difference(_today()).inDays;

  EventStatus get status {
    if (daysToNext == 0) return EventStatus.today;
    return daysFromToday > 0 ? EventStatus.upcoming : EventStatus.completed;
  }
}

class EventInput {
  const EventInput({
    required this.title,
    required this.type,
    required this.date,
    required this.reminderBefore,
    required this.repeat,
    required this.notes,
  });

  final String title;
  final EventType type;
  final DateTime date;
  final int reminderBefore;
  final EventRepeat repeat;
  final String notes;

  Map<String, dynamic> toJson({
    required String userId,
    required String userRole,
  }) {
    String two(int v) => v.toString().padLeft(2, '0');
    return {
      'userId': userId,
      'userRole': userRole,
      'title': title.trim(),
      'eventType': type.apiValue,
      'date': '${date.year}-${two(date.month)}-${two(date.day)}',
      'reminderBefore': reminderBefore,
      'repeat': repeat.apiValue,
      'notes': notes.trim(),
    };
  }
}
