import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/study_provider.dart';

class SubjectManagementScreen extends StatelessWidget {
  const SubjectManagementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Subjects', style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle_outline),
            onPressed: () => _showAddSubjectDialog(context),
          )
        ],
      ),
      body: Consumer<StudyProvider>(
        builder: (context, provider, child) {
          if (provider.subjects.isEmpty) {
            return const Center(child: Text('No subjects added yet.'));
          }
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: provider.subjects.length,
            itemBuilder: (context, index) {
              final subject = provider.subjects[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 16),
                child: ExpansionTile(
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.book, color: Theme.of(context).colorScheme.primary),
                  ),
                  title: Text(
                    subject.name,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text('${subject.topics.length} topics added'),
                  children: [
                    ...subject.topics.map((t) => ListTile(
                          title: Text(t.name),
                          subtitle: Text('Est. time: ${t.estimatedHours} hours'),
                        )),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: OutlinedButton.icon(
                        onPressed: () => _showAddTopicDialog(context, subject.id),
                        icon: const Icon(Icons.add),
                        label: const Text('Add Topic'),
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddSubjectDialog(context),
        icon: const Icon(Icons.add),
        label: const Text('Add Subject'),
      ),
    );
  }

  void _showAddSubjectDialog(BuildContext context) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Subject'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(labelText: 'Subject Name'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              if (controller.text.isNotEmpty) {
                Provider.of<StudyProvider>(context, listen: false).addSubject(controller.text);
                Navigator.pop(context);
              } else {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                  content: Text('Please enter a subject name.'),
                  backgroundColor: Colors.red,
                ));
              }
            },
            child: const Text('Add'),
          )
        ],
      ),
    );
  }

  void _showAddTopicDialog(BuildContext context, String subjectId) {
    final nameController = TextEditingController();
    final hoursController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Topic'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: 'Topic Name'),
            ),
            TextField(
              controller: hoursController,
              decoration: const InputDecoration(labelText: 'Estimated Hours'),
              keyboardType: TextInputType.number,
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              if (nameController.text.isNotEmpty && hoursController.text.isNotEmpty) {
                Provider.of<StudyProvider>(context, listen: false).addTopic(
                  subjectId,
                  nameController.text,
                  double.tryParse(hoursController.text) ?? 1.0,
                );
                Navigator.pop(context);
              } else {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                  content: Text('Please enter valid details.'),
                  backgroundColor: Colors.red,
                ));
              }
            },
            child: const Text('Add'),
          )
        ],
      ),
    );
  }
}
