import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:provider/provider.dart';
import '../providers/study_provider.dart';
import '../models/models.dart';
import '../widgets/glass_card.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: const Text('Dashboard'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 20.0),
            child: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white30),
                color: Colors.white.withValues(alpha: 0.1),
              ),
              padding: const EdgeInsets.all(8),
              child: const Icon(Icons.person_rounded, color: Colors.white),
            ),
          )
        ],
      ),
      body: Consumer<StudyProvider>(
        builder: (context, provider, child) {
          int totalSubjects = provider.subjects.length;
          int completedTopics = 0;
          int pendingTopics = 0;
          
          for (var s in provider.subjects) {
            completedTopics += s.topics.where((t) => t.status == TopicStatus.completed).length;
            pendingTopics += s.topics.where((t) => t.status != TopicStatus.completed).length;
          }

          final lowestSubject = provider.lowestCompletionSubject;

          return SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 100),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Good Morning,',
                  style: TextStyle(fontSize: 18, color: Colors.white70),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Ready to crush your goals?',
                  style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, height: 1.2, color: Colors.white),
                ),
                const SizedBox(height: 24),
                GridView.count(
                  crossAxisCount: 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  children: [
                    _buildGlassSummaryCard('Subjects', '$totalSubjects', Icons.menu_book_rounded, const Color(0xFF6366F1)),
                    _buildGlassSummaryCard('Completed', '$completedTopics', Icons.task_alt_rounded, const Color(0xFF14B8A6)),
                    _buildGlassSummaryCard('Pending', '$pendingTopics', Icons.pending_actions_rounded, const Color(0xFFF59E0B)),
                    _buildGlassSummaryCard('Sessions', '${provider.sessions.length}', Icons.timer_rounded, const Color(0xFFD946EF)),
                  ],
                ),
                const SizedBox(height: 32),
                const Text(
                  'Weekly Activity',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
                ),
                const SizedBox(height: 16),
                GlassCard(
                  height: 280,
                  child: BarChart(
                    BarChartData(
                      alignment: BarChartAlignment.spaceAround,
                      maxY: 10,
                      titlesData: FlTitlesData(
                        show: true,
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            getTitlesWidget: (value, meta) {
                              const days = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
                              if (value >= 0 && value < days.length) {
                                return Padding(
                                  padding: const EdgeInsets.only(top: 8.0),
                                  child: Text(
                                    days[value.toInt()], 
                                    style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white70, fontSize: 13)
                                  ),
                                );
                              }
                              return const Text('');
                            },
                          ),
                        ),
                        leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      ),
                      borderData: FlBorderData(show: false),
                      gridData: const FlGridData(show: false),
                      barGroups: [
                        _buildNeonBar(0, 4, const Color(0xFF14B8A6)),
                        _buildNeonBar(1, 6, const Color(0xFF14B8A6)),
                        _buildNeonBar(2, 3, const Color(0xFF14B8A6)),
                        _buildNeonBar(3, 8, const Color(0xFF14B8A6)),
                        _buildNeonBar(4, 5, const Color(0xFF14B8A6)),
                        _buildNeonBar(5, 7, const Color(0xFF14B8A6)),
                        _buildNeonBar(6, 9, const Color(0xFF14B8A6)),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 32),
                if (lowestSubject != null) ...[
                  const Text(
                    'Needs Attention',
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                  const SizedBox(height: 16),
                  GlassCard(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    child: ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF43F5E).withValues(alpha: 0.2),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.trending_down_rounded, color: Color(0xFFFDA4AF)),
                      ),
                      title: Text(
                        lowestSubject.name,
                        style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 18),
                      ),
                      subtitle: Text(
                        'Completion: ${(lowestSubject.completionPercentage * 100).toInt()}%',
                        style: const TextStyle(color: Color(0xFFFDA4AF)),
                      ),
                      trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 16, color: Colors.white54),
                    ),
                  ),
                ]
              ],
            ),
          );
        },
      ),
    );
  }

  BarChartGroupData _buildNeonBar(int x, double y, Color color) {
    return BarChartGroupData(
      x: x,
      barRods: [
        BarChartRodData(
          toY: y,
          gradient: LinearGradient(
            colors: [color.withValues(alpha: 0.6), color],
            begin: Alignment.bottomCenter,
            end: Alignment.topCenter,
          ),
          width: 20,
          borderRadius: BorderRadius.circular(6),
          backDrawRodData: BackgroundBarChartRodData(
            show: true,
            toY: 10,
            color: Colors.white.withValues(alpha: 0.05),
          ),
        ),
      ],
    );
  }

  Widget _buildGlassSummaryCard(String title, String value, IconData icon, Color color) {
    return GlassCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Icon(icon, color: color, size: 32),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: const TextStyle(fontSize: 36, fontWeight: FontWeight.bold, color: Colors.white, height: 1.0),
              ),
              const SizedBox(height: 4),
              Text(
                title,
                style: TextStyle(fontSize: 14, color: Colors.white.withValues(alpha: 0.7), fontWeight: FontWeight.w600),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
