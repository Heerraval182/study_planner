import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/study_provider.dart';
import '../models/models.dart';
import '../widgets/glass_card.dart';

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
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: const Text('Search & Filter'),
      ),
      body: Consumer<StudyProvider>(
        builder: (context, provider, child) {
          final List<Map<String, dynamic>> allTopics = [];
          for (var s in provider.subjects) {
            for (var t in s.topics) {
              allTopics.add({'subject': s, 'topic': t});
            }
          }

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
                TextField(
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(
                    hintText: 'Search topics...',
                    prefixIcon: Icon(Icons.search_rounded, color: Colors.white70),
                  ),
                  onChanged: (val) => setState(() => _searchQuery = val),
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
                              Icon(Icons.search_off_rounded, size: 64, color: Colors.white.withValues(alpha: 0.2)),
                              const SizedBox(height: 16),
                              const Text('No topics found', style: TextStyle(fontSize: 18, color: Colors.white70, fontWeight: FontWeight.bold)),
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
                                statusBgColor = const Color(0xFF10B981).withValues(alpha: 0.2);
                                break;
                              case TopicStatus.inProgress:
                                statusColor = const Color(0xFFF59E0B);
                                statusBgColor = const Color(0xFFF59E0B).withValues(alpha: 0.2);
                                break;
                              case TopicStatus.notStarted:
                              default:
                                statusColor = const Color(0xFF94A3B8);
                                statusBgColor = const Color(0xFF94A3B8).withValues(alpha: 0.2);
                            }

                            return GlassCard(
                              margin: const EdgeInsets.only(bottom: 16),
                              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                              child: ListTile(
                                contentPadding: EdgeInsets.zero,
                                leading: Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.2),
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  child: Icon(Icons.topic_rounded, color: Theme.of(context).colorScheme.primary),
                                ),
                                title: Text(topic.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.white)),
                                subtitle: Padding(
                                  padding: const EdgeInsets.only(top: 4.0),
                                  child: Text(subject.name, style: const TextStyle(fontWeight: FontWeight.w500, color: Colors.white70)),
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
          Icon(icon, size: 16, color: isSelected ? Colors.white : Colors.white70),
          const SizedBox(width: 6),
          Text(label, style: TextStyle(fontWeight: FontWeight.bold, color: isSelected ? Colors.white : Colors.white70)),
        ],
      ),
      selected: isSelected,
      onSelected: (_) => setState(() => _filterStatus = status),
      backgroundColor: Colors.white.withValues(alpha: 0.1),
      selectedColor: Theme.of(context).colorScheme.primary,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: isSelected ? Colors.transparent : Colors.white24, width: 1.0),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
    );
  }
}
