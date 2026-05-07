import 'package:flutter/material.dart';

class ProgressScreen extends StatelessWidget {
  const ProgressScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Study Progress', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: 3,
        itemBuilder: (context, index) {
          final subjects = ['Mathematics', 'Physics', 'Computer Science'];
          final progress = [0.8, 0.4, 0.1];
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
                        subjects[index],
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        '${(progress[index] * 100).toInt()}%',
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
                    value: progress[index],
                    backgroundColor: Colors.grey.shade200,
                    color: Theme.of(context).colorScheme.primary,
                    minHeight: 8,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  const SizedBox(height: 16),
                  const Text('Topics:', style: TextStyle(fontWeight: FontWeight.w600)),
                  _buildTopicTile('Topic 1', 'Completed', Colors.green),
                  _buildTopicTile('Topic 2', 'In Progress', Colors.orange),
                  _buildTopicTile('Topic 3', 'Not Started', Colors.grey),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildTopicTile(String title, String status, Color statusColor) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      dense: true,
      leading: Icon(
        status == 'Completed' ? Icons.check_circle : (status == 'In Progress' ? Icons.timelapse : Icons.circle_outlined),
        color: statusColor,
      ),
      title: Text(title),
      trailing: DropdownButton<String>(
        value: status,
        icon: const Icon(Icons.arrow_drop_down, size: 20),
        underline: const SizedBox(),
        style: TextStyle(color: statusColor, fontSize: 12, fontWeight: FontWeight.bold),
        items: ['Not Started', 'In Progress', 'Completed']
            .map((s) => DropdownMenuItem(value: s, child: Text(s)))
            .toList(),
        onChanged: (val) {},
      ),
    );
  }
}
