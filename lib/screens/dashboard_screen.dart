import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:provider/provider.dart';
import '../providers/study_provider.dart';
import '../models/models.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: CircleAvatar(
              backgroundColor: colorScheme.primary.withValues(alpha: 0.1),
              child: Icon(Icons.person, color: colorScheme.primary),
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
            padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Good Morning,',
                  style: TextStyle(fontSize: 16, color: Colors.black54),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Ready to crush your goals?',
                  style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, height: 1.2),
                ),
                const SizedBox(height: 24),
                GridView.count(
                  crossAxisCount: 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  children: [
                    _buildGradientCard(
                      context, 'Subjects', '$totalSubjects', Icons.menu_book_rounded,
                      [const Color(0xFF4F46E5), const Color(0xFF818CF8)],
                    ),
                    _buildGradientCard(
                      context, 'Completed', '$completedTopics', Icons.task_alt_rounded,
                      [const Color(0xFF10B981), const Color(0xFF34D399)],
                    ),
                    _buildGradientCard(
                      context, 'Pending', '$pendingTopics', Icons.pending_actions_rounded,
                      [const Color(0xFFF59E0B), const Color(0xFFFCD34D)],
                    ),
                    _buildGradientCard(
                      context, 'Sessions', '${provider.sessions.length}', Icons.timer_rounded,
                      [const Color(0xFFEC4899), const Color(0xFFF472B6)],
                    ),
                  ],
                ),
                const SizedBox(height: 32),
                const Text(
                  'Weekly Activity',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                Container(
                  height: 260,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      )
                    ]
                  ),
                  padding: const EdgeInsets.all(20.0),
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
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black54,
                                      fontSize: 13
                                    )
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
                        _buildAnimatedBar(0, 4, colorScheme.primary),
                        _buildAnimatedBar(1, 6, colorScheme.primary),
                        _buildAnimatedBar(2, 3, colorScheme.primary),
                        _buildAnimatedBar(3, 8, colorScheme.primary),
                        _buildAnimatedBar(4, 5, colorScheme.primary),
                        _buildAnimatedBar(5, 7, colorScheme.primary),
                        _buildAnimatedBar(6, 9, colorScheme.primary),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 32),
                if (lowestSubject != null) ...[
                  const Text(
                    'Needs Attention',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFFFFF1F2), Color(0xFFFFE4E6)],
                      ),
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: const Color(0xFFFECDD3), width: 1),
                    ),
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                      leading: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF43F5E).withValues(alpha: 0.1),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.trending_down_rounded, color: Color(0xFFF43F5E)),
                      ),
                      title: Text(
                        lowestSubject.name,
                        style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF881337)),
                      ),
                      subtitle: Text(
                        'Completion: ${(lowestSubject.completionPercentage * 100).toInt()}%',
                        style: const TextStyle(color: Color(0xFFBE123C)),
                      ),
                      trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 16, color: Color(0xFFBE123C)),
                    ),
                  ),
                  const SizedBox(height: 32),
                ]
              ],
            ),
          );
        },
      ),
    );
  }

  BarChartGroupData _buildAnimatedBar(int x, double y, Color color) {
    return BarChartGroupData(
      x: x,
      barRods: [
        BarChartRodData(
          toY: y,
          gradient: LinearGradient(
            colors: [color.withValues(alpha: 0.7), color],
            begin: Alignment.bottomCenter,
            end: Alignment.topCenter,
          ),
          width: 22,
          borderRadius: BorderRadius.circular(6),
          backDrawRodData: BackgroundBarChartRodData(
            show: true,
            toY: 10,
            color: color.withValues(alpha: 0.05),
          ),
        ),
      ],
    );
  }

  Widget _buildGradientCard(BuildContext context, String title, String value, IconData icon, List<Color> gradientColors) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: gradientColors,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: gradientColors.last.withValues(alpha: 0.4),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Icon(icon, color: Colors.white.withValues(alpha: 0.8), size: 28),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: const TextStyle(
                  fontSize: 32, 
                  fontWeight: FontWeight.bold, 
                  color: Colors.white,
                  height: 1.0
                ),
              ),
              const SizedBox(height: 4),
              Text(
                title,
                style: TextStyle(
                  fontSize: 14, 
                  color: Colors.white.withValues(alpha: 0.9),
                  fontWeight: FontWeight.w500
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
