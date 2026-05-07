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
        title: const Text('Search & Filter'),
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
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Column(
              children: [
                const SizedBox(height: 8),
                Container(
                  decoration: BoxDecoration(
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 20,
                        offset: const Offset(0, 4),
                      )
                    ],
                  ),
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: 'Search topics...',
                      prefixIcon: const Icon(Icons.search_rounded),
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(vertical: 20),
                    ),
                    onChanged: (val) => setState(() => _searchQuery = val),
                  ),
                ),
                const SizedBox(height: 24),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  child: Row(
                    children: [
                      _buildFilterChip('All', null, Icons.all_inclusive_rounded, _filterStatus == null),
                      const SizedBox(width: 12),
                      _buildFilterChip('Completed', TopicStatus.completed, Icons.check_circle_rounded, _filterStatus == TopicStatus.completed),
                      const SizedBox(width: 12),
                      _buildFilterChip('Pending', TopicStatus.notStarted, Icons.pending_actions_rounded, _filterStatus == TopicStatus.notStarted),
                      const SizedBox(width: 12),
                      _buildFilterChip('In Progress', TopicStatus.inProgress, Icons.hourglass_top_rounded, _filterStatus == TopicStatus.inProgress),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                Expanded(
                  child: filteredTopics.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.search_off_rounded, size: 64, color: Colors.grey.shade300),
                              const SizedBox(height: 16),
                              Text('No topics found', style: TextStyle(fontSize: 18, color: Colors.grey.shade600, fontWeight: FontWeight.bold)),
                            ],
                          ),
                        )
                      : ListView.builder(
                          physics: const BouncingScrollPhysics(),
                          itemCount: filteredTopics.length,
                          itemBuilder: (context, index) {
                            final item = filteredTopics[index];
                            final topic = item['topic'] as Topic;
                            final subject = item['subject'] as Subject;
                            
                            Color statusColor;
                            Color statusBgColor;
                            switch (topic.status) {
                              case TopicStatus.completed:
                                statusColor = const Color(0xFF10B981);
                                statusBgColor = const Color(0xFFD1FAE5);
                                break;
                              case TopicStatus.inProgress:
                                statusColor = const Color(0xFFF59E0B);
                                statusBgColor = const Color(0xFFFEF3C7);
                                break;
                              case TopicStatus.notStarted:
                              default:
                                statusColor = const Color(0xFF94A3B8);
                                statusBgColor = const Color(0xFFF1F5F9);
                            }

                            return Container(
                              margin: const EdgeInsets.only(bottom: 16),
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
                                contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                                leading: Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  child: Icon(Icons.topic_rounded, color: Theme.of(context).colorScheme.primary),
                                ),
                                title: Text(topic.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                                subtitle: Padding(
                                  padding: const EdgeInsets.only(top: 4.0),
                                  child: Text(subject.name, style: const TextStyle(fontWeight: FontWeight.w500)),
                                ),
                                trailing: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: statusBgColor,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    topic.status.name,
                                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: statusColor),
                                  ),
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

  Widget _buildFilterChip(String label, TopicStatus? status, IconData icon, bool isSelected) {
    return FilterChip(
      showCheckmark: false,
      label: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon, 
            size: 16, 
            color: isSelected ? Colors.white : Colors.grey.shade600
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: isSelected ? Colors.white : Colors.grey.shade700,
            ),
          ),
        ],
      ),
      selected: isSelected,
      onSelected: (_) => setState(() => _filterStatus = status),
      backgroundColor: Colors.white,
      selectedColor: Theme.of(context).colorScheme.primary,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: isSelected ? Colors.transparent : Colors.grey.shade200,
          width: 1.5,
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
    );
  }
}
