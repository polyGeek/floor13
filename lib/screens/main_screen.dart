import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:split_view/split_view.dart';
import '../models/app_state.dart';
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
}

// Intent classes for keyboard shortcuts
class SaveIntent extends Intent {
  const SaveIntent();
}

class SaveAllIntent extends Intent {
  const SaveAllIntent();
}

class CloseTabIntent extends Intent {
  const CloseTabIntent();

  @override
  Widget build(BuildContext context) {
    return Shortcuts(
      shortcuts: <LogicalKeySet, Intent>{
        // Save shortcuts
        LogicalKeySet(LogicalKeyboardKey.control, LogicalKeyboardKey.keyS):
            const SaveIntent(),
        LogicalKeySet(LogicalKeyboardKey.control, LogicalKeyboardKey.shift,
            LogicalKeyboardKey.keyS): const SaveAllIntent(),
        // Close tab
        LogicalKeySet(LogicalKeyboardKey.control, LogicalKeyboardKey.keyW):
            const CloseTabIntent(),
      },
      child: Actions(
        actions: <Type, Action<Intent>>{
          SaveIntent: CallbackAction<SaveIntent>(
            onInvoke: (SaveIntent intent) {
              final appState = context.read<AppState>();
              appState.saveCurrentFile();
              return null;
            },
          ),
          SaveAllIntent: CallbackAction<SaveAllIntent>(
            onInvoke: (SaveAllIntent intent) {
              final appState = context.read<AppState>();
              appState.saveAllFiles();
              return null;
            },
          ),
          CloseTabIntent: CallbackAction<CloseTabIntent>(
            onInvoke: (CloseTabIntent intent) {
              final appState = context.read<AppState>();
              if (appState.activeTab != null) {
                appState.closeTab(appState.activeTab!.id);
              }
              return null;
            },
          ),
        },
        child: Focus(
          autofocus: true,
          child: Scaffold(
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
          ),
        ),
      ),
    );
  }
}