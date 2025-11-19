class Reminder {
  final String id;
  final String title;
  final String content;
  final String? date;

  Reminder({
    required this.id,
    required this.title,
    required this.content,
    this.date,
  });

  factory Reminder.fromJson(Map<String, dynamic> json) {
    return Reminder(
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      content: json['content']?.toString() ?? '',
      date: json['date']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'title': title, 'content': content, 'date': date};
  }
}
