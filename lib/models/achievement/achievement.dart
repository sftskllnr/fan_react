class Achievement {
  final String id;
  final String name;
  final String description;
  final int targetValue;
  final String type;
  bool isUnlocked;
  int progress;
  int streak;

  Achievement({
    required this.id,
    required this.name,
    required this.description,
    required this.targetValue,
    required this.type,
    this.isUnlocked = false,
    this.progress = 0,
    this.streak = 0,
  });

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'description': description,
      'targetValue': targetValue,
      'type': type,
      'isUnlocked': isUnlocked,
      'progress': progress,
      'streak': streak,
    };
  }

  factory Achievement.fromMap(Map<String, dynamic> map, String id) {
    return Achievement(
      id: id,
      name: map['name'] as String,
      description: map['description'] as String,
      targetValue: map['targetValue'] as int,
      type: map['type'] as String,
      isUnlocked: map['isUnlocked'] as bool? ?? false,
      progress: map['progress'] as int? ?? 0,
      streak: map['streak'] as int? ?? 0,
    );
  }

  double get percentage {
    return targetValue > 0
        ? (progress / targetValue * 100).clamp(0.0, 100.0)
        : 0.0;
  }
}
