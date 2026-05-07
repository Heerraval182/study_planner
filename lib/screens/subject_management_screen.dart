import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/study_provider.dart';
import '../widgets/glass_card.dart';

class SubjectManagementScreen extends StatelessWidget {
  const SubjectManagementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: const Text('Manage Subjects'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12.0),
            child: IconButton(
              icon: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white30),
                ),
                child: const Icon(Icons.add_rounded, color: Colors.white),
              ),
              onPressed: () => _showAddSubjectDialog(context),
            ),
          )
        ],
      ),
      body: Consumer<StudyProvider>(
        builder: (context, provider, child) {
          if (provider.subjects.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.library_books_rounded, size: 80, color: Colors.white.withValues(alpha: 0.2)),
                  const SizedBox(height: 16),
                  const Text('No subjects yet', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white)),
                  const SizedBox(height: 8),
                  const Text('Add your first subject to start planning!', style: TextStyle(color: Colors.white70)),
                ],
              ),
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 100),
            physics: const BouncingScrollPhysics(),
            itemCount: provider.subjects.length,
            itemBuilder: (context, index) {
              final subject = provider.subjects[index];
              return GlassCard(
                margin: const EdgeInsets.only(bottom: 20),
                padding: EdgeInsets.zero,
                child: Theme(
                  data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
                  child: ExpansionTile(
                    iconColor: Colors.white,
                    collapsedIconColor: Colors.white70,
                    tilePadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    leading: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Icon(Icons.menu_book_rounded, color: Theme.of(context).colorScheme.primary),
                    ),
                    title: Text(
                      subject.name,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.white),
                    ),
                    subtitle: Text(
                      '${subject.topics.length} topics • ${(subject.completionPercentage * 100).toInt()}% completed',
                      style: const TextStyle(color: Colors.white60),
                    ),
                    children: [
                      Container(
                        color: Colors.black.withValues(alpha: 0.2),
                        child: Column(
                          children: [
                            ...subject.topics.map((t) => ListTile(
                                  contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 4),
                                  leading: const Icon(Icons.commit_rounded, color: Colors.white50, size: 20),
                                  title: Text(t.name, style: const TextStyle(fontWeight: FontWeight.w600, color: Colors.white)),
                                  subtitle: Text('Est. time: ${t.estimatedHours} hrs', style: const TextStyle(color: Colors.white50)),
                                )),
                            Padding(
                              padding: const EdgeInsets.all(20.0),
                              child: SizedBox(
                                width: double.infinity,
                                child: OutlinedButton.icon(
                                  style: OutlinedButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(vertical: 16),
                                    foregroundColor: Colors.white,
                                    side: BorderSide(color: Colors.white.withValues(alpha: 0.3)),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                  ),
                                  onPressed: () => _showAddTopicDialog(context, subject.id),
                                  icon: const Icon(Icons.add_rounded),
                                  label: const Text('Add New Topic', style: TextStyle(fontWeight: FontWeight.bold)),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 80.0), // Above nav bar
        child: FloatingActionButton.extended(
          onPressed: () => _showAddSubjectDialog(context),
          backgroundColor: Theme.of(context).colorScheme.secondary,
          foregroundColor: Colors.black,
          icon: const Icon(Icons.add_rounded, size: 28),
          label: const Text('New Subject', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        ),
      ),
    );
  }

  void _showAddSubjectDialog(BuildContext context) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1E293B),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24), side: const BorderSide(color: Colors.white24)),
        title: const Text('Add Subject', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
        content: TextField(
          controller: controller,
          style: const TextStyle(color: Colors.white),
          decoration: const InputDecoration(labelText: 'Subject Name'),
          autofocus: true,
        ),
        actionsPadding: const EdgeInsets.all(16),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context), 
            child: const Text('Cancel', style: TextStyle(color: Colors.white70)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Theme.of(context).colorScheme.primary, foregroundColor: Colors.white),
            onPressed: () {
              if (controller.text.isNotEmpty) {
                Provider.of<StudyProvider>(context, listen: false).addSubject(controller.text);
                Navigator.pop(context);
              }
            },
            child: const Text('Add Subject'),
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
        backgroundColor: const Color(0xFF1E293B),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24), side: const BorderSide(color: Colors.white24)),
        title: const Text('Add Topic', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(labelText: 'Topic Name'),
              autofocus: true,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: hoursController,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(labelText: 'Estimated Hours'),
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
            ),
          ],
        ),
        actionsPadding: const EdgeInsets.all(16),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context), 
            child: const Text('Cancel', style: TextStyle(color: Colors.white70)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Theme.of(context).colorScheme.primary, foregroundColor: Colors.white),
            onPressed: () {
              if (nameController.text.isNotEmpty && hoursController.text.isNotEmpty) {
                Provider.of<StudyProvider>(context, listen: false).addTopic(
                  subjectId,
                  nameController.text,
                  double.tryParse(hoursController.text) ?? 1.0,
                );
                Navigator.pop(context);
              }
            },
            child: const Text('Add Topic'),
          )
        ],
      ),
    );
  }
}
