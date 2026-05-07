import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';
import '../models/models.dart';

class StudyProvider with ChangeNotifier {
  late Box<Subject> _subjectsBox;
  late Box<StudySession> _sessionsBox;

  StudyProvider() {
    _subjectsBox = Hive.box<Subject>('subjectsBox');
    _sessionsBox = Hive.box<StudySession>('sessionsBox');
    
    // If the database is empty, we can optionally load some mock data
    if (_subjectsBox.isEmpty) {
      _initMockData();
    }
  }

  List<Subject> get subjects => _subjectsBox.values.toList();
  List<StudySession> get sessions => _sessionsBox.values.toList()..sort((a, b) => a.date.compareTo(b.date));

  void _initMockData() {
    final math = Subject(name: 'Mathematics');
    math.topics.add(Topic(name: 'Algebra', estimatedHours: 2.0, status: TopicStatus.completed));
    math.topics.add(Topic(name: 'Calculus', estimatedHours: 3.0, status: TopicStatus.inProgress));
    
    final physics = Subject(name: 'Physics');
    physics.topics.add(Topic(name: 'Quantum Mechanics', estimatedHours: 5.0));

    _subjectsBox.put(math.id, math);
    _subjectsBox.put(physics.id, physics);
    
    final session = StudySession(
      subjectId: math.id,
      topicId: math.topics[1].id,
      date: DateTime.now().add(const Duration(days: 1)),
      durationHours: 2.0,
    );
    _sessionsBox.put(session.id, session);
  }

  // Subject Management
  void addSubject(String name) {
    final newSubject = Subject(name: name);
    _subjectsBox.put(newSubject.id, newSubject);
    notifyListeners();
  }

  void addTopic(String subjectId, String topicName, double hours) {
    final subject = _subjectsBox.get(subjectId);
    if (subject != null) {
      subject.topics.add(Topic(name: topicName, estimatedHours: hours));
      _subjectsBox.put(subject.id, subject); // Save back to Hive
      notifyListeners();
    }
  }

  // Progress Tracking
  void updateTopicStatus(String subjectId, String topicId, TopicStatus status) {
    final subject = _subjectsBox.get(subjectId);
    if (subject != null) {
      final topicIndex = subject.topics.indexWhere((t) => t.id == topicId);
      if (topicIndex != -1) {
        subject.topics[topicIndex].status = status;
        _subjectsBox.put(subject.id, subject); // Save back to Hive
        notifyListeners();
      }
    }
  }

  // Scheduling
  void scheduleSession(String subjectId, String topicId, DateTime date, double duration) {
    final session = StudySession(
      subjectId: subjectId,
      topicId: topicId,
      date: date,
      durationHours: duration,
    );
    _sessionsBox.put(session.id, session);
    notifyListeners();
  }

  // Priority logic
  Subject? get lowestCompletionSubject {
    if (_subjectsBox.isEmpty) return null;
    return _subjectsBox.values.reduce((curr, next) => 
        curr.completionPercentage < next.completionPercentage ? curr : next);
  }
}
