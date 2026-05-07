import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/models.dart';

class StudyProvider with ChangeNotifier {
  late Box<Subject> _subjectsBox;
  late Box<StudySession> _sessionsBox;
  final _db = FirebaseFirestore.instance;

  StudyProvider() {
    _subjectsBox = Hive.box<Subject>('subjectsBox');
    _sessionsBox = Hive.box<StudySession>('sessionsBox');
    
    // Attempt to sync from Firestore on startup
    syncFromFirestore();

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
    _db.collection('subjects').doc(newSubject.id).set(newSubject.toMap());
    notifyListeners();
  }

  void addTopic(String subjectId, String topicName, double hours) {
    final subject = _subjectsBox.get(subjectId);
    if (subject != null) {
      subject.topics.add(Topic(name: topicName, estimatedHours: hours));
      _subjectsBox.put(subject.id, subject); // Save back to Hive
      _db.collection('subjects').doc(subject.id).set(subject.toMap());
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
        _db.collection('subjects').doc(subject.id).set(subject.toMap());
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
    _db.collection('sessions').doc(session.id).set(session.toMap());
    notifyListeners();
  }

  Future<void> syncFromFirestore() async {
    try {
      final subjectsSnap = await _db.collection('subjects').get();
      for (var doc in subjectsSnap.docs) {
        final subject = Subject.fromMap(doc.data());
        _subjectsBox.put(subject.id, subject);
      }

      final sessionsSnap = await _db.collection('sessions').get();
      for (var doc in sessionsSnap.docs) {
        final session = StudySession.fromMap(doc.data());
        _sessionsBox.put(session.id, session);
      }
      notifyListeners();
    } catch (e) {
      debugPrint('Firestore sync failed: $e');
    }
  }

  // Priority logic
  Subject? get lowestCompletionSubject {
    if (_subjectsBox.isEmpty) return null;
    return _subjectsBox.values.reduce((curr, next) => 
        curr.completionPercentage < next.completionPercentage ? curr : next);
  }
}
