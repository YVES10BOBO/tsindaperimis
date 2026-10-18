import 'package:flutter/material.dart';

import '../core/app_colors.dart';
import 'exam_screens.dart';
import 'home_screen.dart';
import 'more_screen.dart';
import 'practice_screens.dart';
import 'progress_screen.dart';

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _index = 0;

  void _openTab(int i) => setState(() => _index = i);

  @override
  Widget build(BuildContext context) {
    final List<Widget> tabs = <Widget>[
      HomeScreen(onOpenTab: _openTab),
      PracticeHomeScreen(),
      ExamIntroScreen(),
      ProgressScreen(),
      MoreScreen(),
    ];

    return Scaffold(
      body: IndexedStack(index: _index, children: tabs),
      bottomNavigationBar: DecoratedBox(
        decoration: BoxDecoration(
          border: Border(top: BorderSide(color: AppColors.border)),
        ),
        child: BottomNavigationBar(
          currentIndex: _index,
          onTap: _openTab,
          type: BottomNavigationBarType.fixed,
          backgroundColor: AppColors.surface,
          elevation: 0,
          selectedItemColor: AppColors.primary,
          unselectedItemColor: AppColors.muted,
          selectedFontSize: 12,
          unselectedFontSize: 12,
          items: <BottomNavigationBarItem>[
            BottomNavigationBarItem(icon: Icon(Icons.home_outlined), activeIcon: Icon(Icons.home), label: 'Ahabanza'),
            BottomNavigationBarItem(icon: Icon(Icons.edit_note_outlined), activeIcon: Icon(Icons.edit_note), label: 'Imyitozo'),
            BottomNavigationBarItem(icon: Icon(Icons.assignment_outlined), activeIcon: Icon(Icons.assignment), label: 'Ikizamini'),
            BottomNavigationBarItem(icon: Icon(Icons.insights_outlined), activeIcon: Icon(Icons.insights), label: 'Iterambere'),
            BottomNavigationBarItem(icon: Icon(Icons.menu), activeIcon: Icon(Icons.menu_open), label: 'Ibindi'),
          ],
        ),
      ),
    );
  }
}
