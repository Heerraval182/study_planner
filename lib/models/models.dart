import 'package:uuid/uuid.dart';
import 'package:hive/hive.dart';

const uuid = Uuid();

enum TopicStatus {
  notStarted,
  inProgress,
  completed
}

class TopicStatusAdapter extends TypeAdapter<TopicStatus> {
  @override
  final int typeId = 0;

  @override
  TopicStatus read(BinaryReader reader) {
    return TopicStatus.values[reader.readByte()];
  }

  @override
  void write(BinaryWriter writer, TopicStatus obj) {
    writer.writeByte(obj.index);
  }
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

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'estimatedHours': estimatedHours,
      'status': status.index,
    };
  }

  factory Topic.fromMap(Map<String, dynamic> map) {
    return Topic(
      id: map['id'],
      name: map['name'],
      estimatedHours: (map['estimatedHours'] as num).toDouble(),
      status: TopicStatus.values[map['status'] ?? 0],
    );
  }
}

class TopicAdapter extends TypeAdapter<Topic> {
  @override
  final int typeId = 1;

  @override
  Topic read(BinaryReader reader) {
    return Topic(
      id: reader.readString(),
      name: reader.readString(),
      estimatedHours: reader.readDouble(),
      status: reader.read(),
    );
  }

  @override
  void write(BinaryWriter writer, Topic obj) {
    writer.writeString(obj.id);
    writer.writeString(obj.name);
    writer.writeDouble(obj.estimatedHours);
    writer.write(obj.status);
  }
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

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'topics': topics.map((t) => t.toMap()).toList(),
    };
  }

  factory Subject.fromMap(Map<String, dynamic> map) {
    return Subject(
      id: map['id'],
      name: map['name'],
      topics: (map['topics'] as List?)
          ?.map((t) => Topic.fromMap(Map<String, dynamic>.from(t)))
          .toList(),
    );
  }

  double get completionPercentage {
    if (topics.isEmpty) return 0.0;
    int completed = topics.where((t) => t.status == TopicStatus.completed).length;
    return completed / topics.length;
  }
}

class SubjectAdapter extends TypeAdapter<Subject> {
  @override
  final int typeId = 2;

  @override
  Subject read(BinaryReader reader) {
    final id = reader.readString();
    final name = reader.readString();
    final topicsList = reader.readList();
    return Subject(
      id: id,
      name: name,
      topics: topicsList.cast<Topic>(),
    );
  }

  @override
  void write(BinaryWriter writer, Subject obj) {
    writer.writeString(obj.id);
    writer.writeString(obj.name);
    writer.writeList(obj.topics);
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

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'subjectId': subjectId,
      'topicId': topicId,
      'date': date.millisecondsSinceEpoch,
      'durationHours': durationHours,
    };
  }

  factory StudySession.fromMap(Map<String, dynamic> map) {
    return StudySession(
      id: map['id'],
      subjectId: map['subjectId'],
      topicId: map['topicId'],
      date: DateTime.fromMillisecondsSinceEpoch(map['date']),
      durationHours: (map['durationHours'] as num).toDouble(),
    );
  }
}

class StudySessionAdapter extends TypeAdapter<StudySession> {
  @override
  final int typeId = 3;

  @override
  StudySession read(BinaryReader reader) {
    return StudySession(
      id: reader.readString(),
      subjectId: reader.readString(),
      topicId: reader.readString(),
      date: DateTime.fromMillisecondsSinceEpoch(reader.readInt()),
      durationHours: reader.readDouble(),
    );
  }

  @override
  void write(BinaryWriter writer, StudySession obj) {
    writer.writeString(obj.id);
    writer.writeString(obj.subjectId);
    writer.writeString(obj.topicId);
    writer.writeInt(obj.date.millisecondsSinceEpoch);
    writer.writeDouble(obj.durationHours);
  }
}
