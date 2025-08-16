import 'package:flutter/material.dart';
import 'package:split_view/split_view.dart';
import '../widgets/project_tabs.dart';
import '../widgets/left_panel.dart';
import '../widgets/center_panel.dart';
import '../widgets/right_panel.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  final _splitViewController = SplitViewController(
    limits: [
      WeightLimit(min: 0.15, max: 0.5),
      WeightLimit(min: 0.3, max: 0.7),
      WeightLimit(min: 0.15, max: 0.5),
    ],
    weights: [0.2, 0.5, 0.3],
  );

  @override
  void dispose() {
    _splitViewController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1E1E1E),
      body: Column(
        children: [
          const ProjectTabs(),
          Expanded(
            child: SplitView(
              viewMode: SplitViewMode.Horizontal,
              controller: _splitViewController,
              gripSize: 2,
              gripColor: const Color(0xFF464647),
              gripColorActive: const Color(0xFF007ACC),
              children: const [
                LeftPanel(),
                CenterPanel(),
                RightPanel(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}