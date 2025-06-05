class Task {
  final int? id;
  final String title;
  final String description;
  final String status;
  final String sentiment;

  Task({
    this.id,
    required this.title,
    required this.description,
    required this.status,
    required this.sentiment,
  });

  Task copyWith({
    int? id,
    String? title,
    String? description,
    String? status,
    String? sentiment,
  }) {
    return Task(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      status: status ?? this.status,
      sentiment: sentiment ?? this.sentiment,
    );
  }

  factory Task.fromMap(Map<String, dynamic> map) {
    return Task(
      id: map['id'] as int?,
      title: map['title'] as String,
      description: map['description'] as String,
      status: map['status'] as String,
      sentiment: map['sentiment'] as String,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'status': status,
      'sentiment': sentiment,
    };
  }
} 