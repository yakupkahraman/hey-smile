class Treatment {
  final String id;
  final String name;
  final DateTime opDate;
  final int grafts;
  final String method;
  final String duration;
  final String anesthesia;
  final String donorCap;
  final int extracted;
  final int remaining;
  final String areas;
  final DateTime firstWash;
  final DateTime followUp;
  final String warnings;

  Treatment({
    required this.id,
    required this.name,
    required this.opDate,
    required this.grafts,
    required this.method,
    required this.duration,
    required this.anesthesia,
    required this.donorCap,
    required this.extracted,
    required this.remaining,
    required this.areas,
    required this.firstWash,
    required this.followUp,
    required this.warnings,
  });
}
