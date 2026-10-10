class Holiday {
  const Holiday({
    required this.id,
    required this.name,
    required this.totalDays,
    required this.type,
    required this.state,
    required this.isActive,
    this.fromDate,
    this.toDate,
  });

  final String id;
  final String name;
  final DateTime? fromDate;
  final DateTime? toDate;
  final int totalDays;
  final String type;
  final String state;
  final bool isActive;
}
