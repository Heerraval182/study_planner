import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/study_provider.dart';
import '../models/models.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  String _searchQuery = '';
  TopicStatus? _filterStatus;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Search & Filter', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: Consumer<StudyProvider>(
        builder: (context, provider, child) {
          // Gather all topics with their subjects
          final List<Map<String, dynamic>> allTopics = [];
          for (var s in provider.subjects) {
            for (var t in s.topics) {
              allTopics.add({'subject': s, 'topic': t});
            }
          }

          // Filter topics
          final filteredTopics = allTopics.where((item) {
            final topic = item['topic'] as Topic;
            final matchesQuery = topic.name.toLowerCase().contains(_searchQuery.toLowerCase());
            final matchesStatus = _filterStatus == null || topic.status == _filterStatus;
            return matchesQuery && matchesStatus;
          }).toList();

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                TextField(
                  decoration: InputDecoration(
                    hintText: 'Search topics by name...',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor: Colors.grey.shade50,
                  ),
                  onChanged: (val) => setState(() => _searchQuery = val),
                ),
                const SizedBox(height: 16),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      FilterChip(
                        label: const Text('All'),
                        selected: _filterStatus == null,
                        onSelected: (_) => setState(() => _filterStatus = null),
                      ),
                      const SizedBox(width: 8),
                      FilterChip(
                        label: const Text('Completed'),
                        selected: _filterStatus == TopicStatus.completed,
                        onSelected: (_) => setState(() => _filterStatus = TopicStatus.completed),
                      ),
                      const SizedBox(width: 8),
                      FilterChip(
                        label: const Text('Pending'),
                        selected: _filterStatus == TopicStatus.notStarted || _filterStatus == TopicStatus.inProgress,
                        onSelected: (_) {
                          setState(() {
                            // Simplified for demo: just filter by 'notStarted' if "Pending" is tapped.
                            _filterStatus = TopicStatus.notStarted; 
                          });
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                Expanded(
                  child: ListView.builder(
                    itemCount: filteredTopics.length,
                    itemBuilder: (context, index) {
                      final item = filteredTopics[index];
                      final topic = item['topic'] as Topic;
                      final subject = item['subject'] as Subject;
                      
                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        child: ListTile(
                          leading: const CircleAvatar(
                            backgroundColor: Colors.blueAccent,
                            child: Icon(Icons.topic, color: Colors.white),
                          ),
                          title: Text(topic.name),
                          subtitle: Text(subject.name),
                          trailing: Chip(
                            label: Text(
                              topic.status.name,
                              style: const TextStyle(fontSize: 10),
                            ),
                            backgroundColor: topic.status == TopicStatus.completed 
                                ? Colors.green.shade100 
                                : Colors.orange.shade100,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
