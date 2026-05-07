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
        title: const Text('Schedule Session', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: Consumer<StudyProvider>(
        builder: (context, provider, child) {
          final subjects = provider.subjects;
          final selectedSubject = subjects.where((s) => s.id == _selectedSubjectId).firstOrNull;
          
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Plan Your Study',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 16),
                        DropdownButtonFormField<String>(
                          decoration: const InputDecoration(
                            labelText: 'Select Subject',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.book),
                          ),
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
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.topic),
                          ),
                          value: _selectedTopicId,
                          items: selectedSubject?.topics.map((t) => DropdownMenuItem(value: t.id, child: Text(t.name))).toList() ?? [],
                          onChanged: (val) => setState(() => _selectedTopicId = val),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: InkWell(
                                onTap: () async {
                                  final date = await showDatePicker(
                                    context: context,
                                    initialDate: _selectedDate,
                                    firstDate: DateTime.now(),
                                    lastDate: DateTime.now().add(const Duration(days: 365)),
                                  );
                                  if (date != null) setState(() => _selectedDate = date);
                                },
                                child: InputDecorator(
                                  decoration: const InputDecoration(
                                    labelText: 'Date',
                                    border: OutlineInputBorder(),
                                    prefixIcon: Icon(Icons.calendar_today),
                                  ),
                                  child: Text(DateFormat.yMMMd().format(_selectedDate)),
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: InkWell(
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
                                    border: OutlineInputBorder(),
                                    prefixIcon: Icon(Icons.access_time),
                                  ),
                                  child: Text(_selectedTime.format(context)),
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
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.timer),
                          ),
                          keyboardType: TextInputType.number,
                        ),
                        const SizedBox(height: 24),
                        SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Theme.of(context).colorScheme.primary,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
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
                                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Session Scheduled!')));
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                                  content: Text('Please select a subject and a topic.'),
                                  backgroundColor: Colors.red,
                                ));
                              }
                            },
                            child: const Text('Schedule Session', style: TextStyle(fontSize: 16)),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                const Text(
                  'Upcoming Sessions',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                ...provider.sessions.map((session) {
                  final subj = provider.subjects.firstWhere((s) => s.id == session.subjectId);
                  final topic = subj.topics.firstWhere((t) => t.id == session.topicId);
                  return Card(
                    child: ListTile(
                      leading: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.blue.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(DateFormat.MMM().format(session.date), style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.blue)),
                            Text(DateFormat.d().format(session.date), style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ),
                      title: Text('${subj.name} - ${topic.name}'),
                      subtitle: Text('${DateFormat.jm().format(session.date)} (${session.durationHours} hrs)'),
                    ),
                  );
                }),
              ],
            ),
          );
        },
      ),
    );
  }
}
