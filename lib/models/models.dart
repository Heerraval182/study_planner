import 'package:uuid/uuid.dart';

const uuid = Uuid();

enum TopicStatus {
  notStarted,
  inProgress,
  completed
}

class Topic {
  final String id;
  String name;
  double estimatedHours;
  TopicStatus status;

  Topic({
    String? id,
    required this.name,
    required this.estimatedHours,
    this.status = TopicStatus.notStarted,
  }) : id = id ?? uuid.v4();
}

class Subject {
  final String id;
  String name;
  List<Topic> topics;

  Subject({
    String? id,
    required this.name,
    List<Topic>? topics,
  })  : id = id ?? uuid.v4(),
        topics = topics ?? [];

  double get completionPercentage {
    if (topics.isEmpty) return 0.0;
    int completed = topics.where((t) => t.status == TopicStatus.completed).length;
    return completed / topics.length;
  }
}

class StudySession {
  final String id;
  String subjectId;
  String topicId;
  DateTime date;
  double durationHours;

  StudySession({
    String? id,
    required this.subjectId,
    required this.topicId,
    required this.date,
    required this.durationHours,
  }) : id = id ?? uuid.v4();
}
