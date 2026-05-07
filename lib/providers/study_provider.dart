import 'package:flutter/foundation.dart';
import '../models/models.dart';

class StudyProvider with ChangeNotifier {
  final List<Subject> _subjects = [];
  final List<StudySession> _sessions = [];

  List<Subject> get subjects => [..._subjects];
  List<StudySession> get sessions => [..._sessions];

  // Initialize with some mock data for development
  StudyProvider() {
    _initMockData();
  }

  void _initMockData() {
    final math = Subject(name: 'Mathematics');
    math.topics.add(Topic(name: 'Algebra', estimatedHours: 2.0, status: TopicStatus.completed));
    math.topics.add(Topic(name: 'Calculus', estimatedHours: 3.0, status: TopicStatus.inProgress));
    
    final physics = Subject(name: 'Physics');
    physics.topics.add(Topic(name: 'Quantum Mechanics', estimatedHours: 5.0));

    _subjects.addAll([math, physics]);
    
    _sessions.add(StudySession(
      subjectId: math.id,
      topicId: math.topics[1].id,
      date: DateTime.now().add(const Duration(days: 1)),
      durationHours: 2.0,
    ));
  }

  // Subject Management
  void addSubject(String name) {
    _subjects.add(Subject(name: name));
    notifyListeners();
  }

  void addTopic(String subjectId, String topicName, double hours) {
    final subject = _subjects.firstWhere((s) => s.id == subjectId);
    subject.topics.add(Topic(name: topicName, estimatedHours: hours));
    notifyListeners();
  }

  // Progress Tracking
  void updateTopicStatus(String subjectId, String topicId, TopicStatus status) {
    final subject = _subjects.firstWhere((s) => s.id == subjectId);
    final topic = subject.topics.firstWhere((t) => t.id == topicId);
    topic.status = status;
    notifyListeners();
  }

  // Scheduling
  void scheduleSession(String subjectId, String topicId, DateTime date, double duration) {
    _sessions.add(StudySession(
      subjectId: subjectId,
      topicId: topicId,
      date: date,
      durationHours: duration,
    ));
    _sessions.sort((a, b) => a.date.compareTo(b.date));
    notifyListeners();
  }

  // Priority logic
  Subject? get lowestCompletionSubject {
    if (_subjects.isEmpty) return null;
    return _subjects.reduce((curr, next) => 
        curr.completionPercentage < next.completionPercentage ? curr : next);
  }
}
