import 'package:flutter/material.dart';
import 'dart:ui';
import '../widgets/background_wrapper.dart';
import 'dashboard_screen.dart';
import 'subject_management_screen.dart';
import 'scheduling_screen.dart';
import 'progress_screen.dart';
import 'search_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = const [
    DashboardScreen(),
    SubjectManagementScreen(),
    SchedulingScreen(),
    ProgressScreen(),
    SearchScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return BackgroundWrapper(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        extendBody: true,
        body: AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          switchInCurve: Curves.easeIn,
          switchOutCurve: Curves.easeOut,
          child: _screens[_currentIndex],
        ),
        bottomNavigationBar: Padding(
          padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(30),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.1),
                  border: Border.all(color: Colors.white.withValues(alpha: 0.2), width: 1.5),
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.3),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    )
                  ]
                ),
                child: NavigationBar(
                  selectedIndex: _currentIndex,
                  onDestinationSelected: (index) => setState(() => _currentIndex = index),
                  backgroundColor: Colors.transparent,
                  elevation: 0,
                  indicatorColor: Theme.of(context).colorScheme.secondary.withValues(alpha: 0.3),
                  destinations: const [
                    NavigationDestination(
                      icon: Icon(Icons.space_dashboard_outlined, color: Colors.white70),
                      selectedIcon: Icon(Icons.space_dashboard_rounded, color: Colors.white),
                      label: 'Home',
                    ),
                    NavigationDestination(
                      icon: Icon(Icons.library_books_outlined, color: Colors.white70),
                      selectedIcon: Icon(Icons.library_books_rounded, color: Colors.white),
                      label: 'Subjects',
                    ),
                    NavigationDestination(
                      icon: Icon(Icons.calendar_month_outlined, color: Colors.white70),
                      selectedIcon: Icon(Icons.calendar_month_rounded, color: Colors.white),
                      label: 'Schedule',
                    ),
                    NavigationDestination(
                      icon: Icon(Icons.insights_outlined, color: Colors.white70),
                      selectedIcon: Icon(Icons.insights_rounded, color: Colors.white),
                      label: 'Progress',
                    ),
                    NavigationDestination(
                      icon: Icon(Icons.search_rounded, color: Colors.white70),
                      selectedIcon: Icon(Icons.search_rounded, color: Colors.white),
                      label: 'Search',
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
