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
        title: const Text('Study Progress', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: Consumer<StudyProvider>(
        builder: (context, provider, child) {
          if (provider.subjects.isEmpty) {
            return const Center(child: Text('No subjects to track.'));
          }
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: provider.subjects.length,
            itemBuilder: (context, index) {
              final subject = provider.subjects[index];
              final progress = subject.completionPercentage;
              
              return Card(
                margin: const EdgeInsets.only(bottom: 16),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            subject.name,
                            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          Text(
                            '${(progress * 100).toInt()}%',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      LinearProgressIndicator(
                        value: progress.isNaN ? 0 : progress,
                        backgroundColor: Colors.grey.shade200,
                        color: Theme.of(context).colorScheme.primary,
                        minHeight: 8,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      const SizedBox(height: 16),
                      const Text('Topics:', style: TextStyle(fontWeight: FontWeight.w600)),
                      ...subject.topics.map((t) => _buildTopicTile(context, subject.id, t, provider)),
                    ],
                  ),
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
    switch (topic.status) {
      case TopicStatus.completed:
        statusColor = Colors.green;
        break;
      case TopicStatus.inProgress:
        statusColor = Colors.orange;
        break;
      case TopicStatus.notStarted:
        statusColor = Colors.grey;
    }

    return ListTile(
      contentPadding: EdgeInsets.zero,
      dense: true,
      leading: Icon(
        topic.status == TopicStatus.completed 
            ? Icons.check_circle 
            : (topic.status == TopicStatus.inProgress ? Icons.timelapse : Icons.circle_outlined),
        color: statusColor,
      ),
      title: Text(topic.name),
      trailing: DropdownButton<TopicStatus>(
        value: topic.status,
        icon: const Icon(Icons.arrow_drop_down, size: 20),
        underline: const SizedBox(),
        style: TextStyle(color: statusColor, fontSize: 12, fontWeight: FontWeight.bold),
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
    );
  }
}
