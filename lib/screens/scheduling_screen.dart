import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/study_provider.dart';

class SchedulingScreen extends StatefulWidget {
  const SchedulingScreen({super.key});

  @override
  State<SchedulingScreen> createState() => _SchedulingScreenState();
}

class _SchedulingScreenState extends State<SchedulingScreen> {
  String? _selectedSubjectId;
  String? _selectedTopicId;
  DateTime _selectedDate = DateTime.now();
  TimeOfDay _selectedTime = TimeOfDay.now();
  final _durationController = TextEditingController(text: '1.0');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Schedule Session'),
      ),
      body: Consumer<StudyProvider>(
        builder: (context, provider, child) {
          final subjects = provider.subjects;
          final selectedSubject = subjects.where((s) => s.id == _selectedSubjectId).firstOrNull;
          
          return SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.04),
                        blurRadius: 16,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(Icons.edit_calendar_rounded, color: Theme.of(context).colorScheme.primary),
                          ),
                          const SizedBox(width: 16),
                          const Text(
                            'Plan Your Study',
                            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      DropdownButtonFormField<String>(
                        decoration: const InputDecoration(
                          labelText: 'Select Subject',
                          prefixIcon: Icon(Icons.book_rounded),
                        ),
                        dropdownColor: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        value: _selectedSubjectId,
                        items: subjects.map((s) => DropdownMenuItem(value: s.id, child: Text(s.name))).toList(),
                        onChanged: (val) {
                          setState(() {
                            _selectedSubjectId = val;
                            _selectedTopicId = null;
                          });
                        },
                      ),
                      const SizedBox(height: 16),
                      DropdownButtonFormField<String>(
                        decoration: const InputDecoration(
                          labelText: 'Select Topic',
                          prefixIcon: Icon(Icons.topic_rounded),
                        ),
                        dropdownColor: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        value: _selectedTopicId,
                        items: selectedSubject?.topics.map((t) => DropdownMenuItem(value: t.id, child: Text(t.name))).toList() ?? [],
                        onChanged: (val) => setState(() => _selectedTopicId = val),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: InkWell(
                              borderRadius: BorderRadius.circular(16),
                              onTap: () async {
                                final date = await showDatePicker(
                                  context: context,
                                  initialDate: _selectedDate,
                                  firstDate: DateTime.now(),
                                  lastDate: DateTime.now().add(const Duration(days: 365)),
                                  builder: (context, child) => Theme(
                                    data: Theme.of(context).copyWith(
                                      colorScheme: Theme.of(context).colorScheme,
                                    ),
                                    child: child!,
                                  ),
                                );
                                if (date != null) setState(() => _selectedDate = date);
                              },
                              child: InputDecorator(
                                decoration: const InputDecoration(
                                  labelText: 'Date',
                                  prefixIcon: Icon(Icons.calendar_today_rounded),
                                ),
                                child: Text(DateFormat.MMMEd().format(_selectedDate), style: const TextStyle(fontWeight: FontWeight.w600)),
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: InkWell(
                              borderRadius: BorderRadius.circular(16),
                              onTap: () async {
                                final time = await showTimePicker(
                                  context: context,
                                  initialTime: _selectedTime,
                                );
                                if (time != null) setState(() => _selectedTime = time);
                              },
                              child: InputDecorator(
                                decoration: const InputDecoration(
                                  labelText: 'Time',
                                  prefixIcon: Icon(Icons.access_time_rounded),
                                ),
                                child: Text(_selectedTime.format(context), style: const TextStyle(fontWeight: FontWeight.w600)),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _durationController,
                        decoration: const InputDecoration(
                          labelText: 'Duration (hours)',
                          prefixIcon: Icon(Icons.timer_rounded),
                        ),
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      ),
                      const SizedBox(height: 32),
                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Theme.of(context).colorScheme.primary,
                            foregroundColor: Colors.white,
                            elevation: 8,
                            shadowColor: Theme.of(context).colorScheme.primary.withValues(alpha: 0.4),
                          ),
                          onPressed: () {
                            if (_selectedSubjectId != null && _selectedTopicId != null) {
                              final dt = DateTime(
                                _selectedDate.year, _selectedDate.month, _selectedDate.day,
                                _selectedTime.hour, _selectedTime.minute,
                              );
                              provider.scheduleSession(
                                _selectedSubjectId!,
                                _selectedTopicId!,
                                dt,
                                double.tryParse(_durationController.text) ?? 1.0,
                              );
                              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                                content: Text('Session Scheduled successfully!'),
                                behavior: SnackBarBehavior.floating,
                                backgroundColor: Colors.green,
                              ));
                              setState(() {
                                _selectedSubjectId = null;
                                _selectedTopicId = null;
                              });
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                                content: Text('Please select a subject and a topic.'),
                                backgroundColor: Colors.red,
                                behavior: SnackBarBehavior.floating,
                              ));
                            }
                          },
                          child: const Text('Schedule Session', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),
                if (provider.sessions.isNotEmpty) ...[
                  const Text(
                    'Upcoming Sessions',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  ...provider.sessions.map((session) {
                    final subj = provider.subjects.firstWhere((s) => s.id == session.subjectId);
                    final topic = subj.topics.firstWhere((t) => t.id == session.topicId);
                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.03),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        leading: Container(
                          width: 56,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFF60A5FA), Color(0xFF3B82F6)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(DateFormat.MMM().format(session.date).toUpperCase(), style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.white70)),
                              Text(DateFormat.d().format(session.date), style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                            ],
                          ),
                        ),
                        title: Text('${subj.name} - ${topic.name}', style: const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Row(
                          children: [
                            const Icon(Icons.access_time_rounded, size: 14, color: Colors.grey),
                            const SizedBox(width: 4),
                            Text('${DateFormat.jm().format(session.date)} (${session.durationHours} hrs)'),
                          ],
                        ),
                      ),
                    );
                  }),
                ] else 
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.all(32.0),
                      child: Text('No upcoming sessions.', style: TextStyle(color: Colors.grey.shade500)),
                    )
                  )
              ],
            ),
          );
        },
      ),
    );
  }
}
