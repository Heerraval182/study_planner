import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/study_provider.dart';
import '../widgets/glass_card.dart';

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
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: const Text('Schedule Session'),
      ),
      body: Consumer<StudyProvider>(
        builder: (context, provider, child) {
          final subjects = provider.subjects;
          final selectedSubject = subjects.where((s) => s.id == _selectedSubjectId).firstOrNull;
          
          return SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 100),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                GlassCard(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(Icons.edit_calendar_rounded, color: Theme.of(context).colorScheme.primary),
                          ),
                          const SizedBox(width: 16),
                          const Text(
                            'Plan Your Study',
                            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      DropdownButtonFormField<String>(
                        decoration: const InputDecoration(labelText: 'Select Subject', prefixIcon: Icon(Icons.book_rounded, color: Colors.white70)),
                        dropdownColor: const Color(0xFF1E293B),
                        style: const TextStyle(color: Colors.white, fontSize: 16),
                        value: _selectedSubjectId,
                        items: subjects.map((s) => DropdownMenuItem(value: s.id, child: Text(s.name))).toList(),
                        onChanged: (val) => setState(() { _selectedSubjectId = val; _selectedTopicId = null; }),
                      ),
                      const SizedBox(height: 16),
                      DropdownButtonFormField<String>(
                        decoration: const InputDecoration(labelText: 'Select Topic', prefixIcon: Icon(Icons.topic_rounded, color: Colors.white70)),
                        dropdownColor: const Color(0xFF1E293B),
                        style: const TextStyle(color: Colors.white, fontSize: 16),
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
                                  context: context, initialDate: _selectedDate, firstDate: DateTime.now(), lastDate: DateTime.now().add(const Duration(days: 365)),
                                );
                                if (date != null) setState(() => _selectedDate = date);
                              },
                              child: InputDecorator(
                                decoration: const InputDecoration(labelText: 'Date', prefixIcon: Icon(Icons.calendar_today_rounded, color: Colors.white70)),
                                child: Text(DateFormat.MMMEd().format(_selectedDate), style: const TextStyle(fontWeight: FontWeight.w600, color: Colors.white)),
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: InkWell(
                              borderRadius: BorderRadius.circular(16),
                              onTap: () async {
                                final time = await showTimePicker(context: context, initialTime: _selectedTime);
                                if (time != null) setState(() => _selectedTime = time);
                              },
                              child: InputDecorator(
                                decoration: const InputDecoration(labelText: 'Time', prefixIcon: Icon(Icons.access_time_rounded, color: Colors.white70)),
                                child: Text(_selectedTime.format(context), style: const TextStyle(fontWeight: FontWeight.w600, color: Colors.white)),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _durationController,
                        style: const TextStyle(color: Colors.white),
                        decoration: const InputDecoration(labelText: 'Duration (hours)', prefixIcon: Icon(Icons.timer_rounded, color: Colors.white70)),
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
                          ),
                          onPressed: () {
                            if (_selectedSubjectId != null && _selectedTopicId != null) {
                              final dt = DateTime(_selectedDate.year, _selectedDate.month, _selectedDate.day, _selectedTime.hour, _selectedTime.minute);
                              provider.scheduleSession(_selectedSubjectId!, _selectedTopicId!, dt, double.tryParse(_durationController.text) ?? 1.0);
                              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Session Scheduled successfully!'), backgroundColor: Colors.green));
                              setState(() { _selectedSubjectId = null; _selectedTopicId = null; });
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
                  const Text('Upcoming Sessions', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white)),
                  const SizedBox(height: 16),
                  ...provider.sessions.map((session) {
                    final subj = provider.subjects.firstWhere((s) => s.id == session.subjectId);
                    final topic = subj.topics.firstWhere((t) => t.id == session.topicId);
                    return GlassCard(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      child: ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: Container(
                          width: 56,
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.secondary.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(DateFormat.MMM().format(session.date).toUpperCase(), style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.secondary)),
                              Text(DateFormat.d().format(session.date), style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                            ],
                          ),
                        ),
                        title: Text('${subj.name} - ${topic.name}', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
                        subtitle: Row(
                          children: [
                            const Icon(Icons.access_time_rounded, size: 14, color: Colors.white50),
                            const SizedBox(width: 4),
                            Text('${DateFormat.jm().format(session.date)} (${session.durationHours} hrs)', style: const TextStyle(color: Colors.white70)),
                          ],
                        ),
                      ),
                    );
                  }),
                ]
              ],
            ),
          );
        },
      ),
    );
  }
}
