import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/study_provider.dart';
import '../models/models.dart';

class ProgressScreen extends StatelessWidget {
  const ProgressScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Study Progress'),
      ),
      body: Consumer<StudyProvider>(
        builder: (context, provider, child) {
          if (provider.subjects.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.analytics_rounded, size: 80, color: Colors.grey.shade300),
                  const SizedBox(height: 16),
                  Text('No progress data', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.grey.shade600)),
                  const SizedBox(height: 8),
                  Text('Add subjects and topics to see your progress here.', style: TextStyle(color: Colors.grey.shade500)),
                ],
              ),
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.all(20),
            physics: const BouncingScrollPhysics(),
            itemCount: provider.subjects.length,
            itemBuilder: (context, index) {
              final subject = provider.subjects[index];
              final progress = subject.completionPercentage;
              
              return Container(
                margin: const EdgeInsets.only(bottom: 24),
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
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          subject.name,
                          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            '${(progress * 100).toInt()}%',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: TweenAnimationBuilder<double>(
                        duration: const Duration(milliseconds: 1000),
                        curve: Curves.easeOutCubic,
                        tween: Tween<double>(begin: 0, end: progress.isNaN ? 0 : progress),
                        builder: (context, value, _) => LinearProgressIndicator(
                          value: value,
                          backgroundColor: Colors.grey.shade100,
                          color: Theme.of(context).colorScheme.secondary,
                          minHeight: 12,
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    if (subject.topics.isNotEmpty) ...[
                      const Text('Topics:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      const SizedBox(height: 12),
                      ...subject.topics.map((t) => _buildTopicTile(context, subject.id, t, provider)),
                    ] else
                       const Text('No topics added yet.', style: TextStyle(color: Colors.grey, fontStyle: FontStyle.italic)),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildTopicTile(BuildContext context, String subjectId, Topic topic, StudyProvider provider) {
    Color statusColor;
    Color statusBgColor;
    IconData statusIcon;

    switch (topic.status) {
      case TopicStatus.completed:
        statusColor = const Color(0xFF10B981);
        statusBgColor = const Color(0xFFD1FAE5);
        statusIcon = Icons.check_circle_rounded;
        break;
      case TopicStatus.inProgress:
        statusColor = const Color(0xFFF59E0B);
        statusBgColor = const Color(0xFFFEF3C7);
        statusIcon = Icons.hourglass_top_rounded;
        break;
      case TopicStatus.notStarted:
        statusColor = const Color(0xFF94A3B8);
        statusBgColor = const Color(0xFFF1F5F9);
        statusIcon = Icons.radio_button_unchecked_rounded;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade100, width: 1.5),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(color: statusBgColor, shape: BoxShape.circle),
          child: Icon(statusIcon, color: statusColor, size: 20),
        ),
        title: Text(topic.name, style: const TextStyle(fontWeight: FontWeight.w600)),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            color: statusBgColor,
            borderRadius: BorderRadius.circular(12),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<TopicStatus>(
              value: topic.status,
              icon: Icon(Icons.keyboard_arrow_down_rounded, size: 16, color: statusColor),
              style: TextStyle(color: statusColor, fontSize: 13, fontWeight: FontWeight.bold, fontFamily: 'Outfit'),
              dropdownColor: Colors.white,
              borderRadius: BorderRadius.circular(16),
              items: const [
                DropdownMenuItem(value: TopicStatus.notStarted, child: Text('Not Started')),
                DropdownMenuItem(value: TopicStatus.inProgress, child: Text('In Progress')),
                DropdownMenuItem(value: TopicStatus.completed, child: Text('Completed')),
              ],
              onChanged: (val) {
                if (val != null) {
                  provider.updateTopicStatus(subjectId, topic.id, val);
                }
              },
            ),
          ),
        ),
      ),
    );
  }
}
