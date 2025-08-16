import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../models/app_state.dart';
import 'editor/editor_tabs.dart';
import 'editor/code_editor.dart';

class CenterPanel extends StatelessWidget {
  const CenterPanel({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFF1E1E1E),
      child: Consumer<AppState>(
        builder: (context, appState, _) {
          return Shortcuts(
            shortcuts: <LogicalKeySet, Intent>{
              LogicalKeySet(LogicalKeyboardKey.control, LogicalKeyboardKey.keyS):
                  const SaveFileIntent(),
              LogicalKeySet(LogicalKeyboardKey.control, LogicalKeyboardKey.shift,
                  LogicalKeyboardKey.keyS): const SaveAllFilesIntent(),
            },
            child: Actions(
              actions: <Type, Action<Intent>>{
                SaveFileIntent: CallbackAction<SaveFileIntent>(
                  onInvoke: (SaveFileIntent intent) {
                    if (appState.activeTab != null) {
                      appState.saveFile(
                        appState.activeTab!.filePath,
                        appState.activeTab!.content,
                      );
                    }
                    return null;
                  },
                ),
                SaveAllFilesIntent: CallbackAction<SaveAllFilesIntent>(
                  onInvoke: (SaveAllFilesIntent intent) {
                    appState.saveAllFiles();
                    return null;
                  },
                ),
              },
              child: Column(
                children: [
                  const EditorTabs(),
                  Expanded(
                    child: appState.activeTab != null
                        ? CodeEditor(tab: appState.activeTab!)
                        : Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.code,
                                  size: 64,
                                  color: Colors.grey[700],
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  'F13or',
                                  style: TextStyle(
                                    color: Colors.grey[600],
                                    fontSize: 24,
                                    fontWeight: FontWeight.w300,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  appState.activeProject != null
                                      ? 'Select a file to edit'
                                      : 'Open a project to get started',
                                  style: TextStyle(
                                    color: Colors.grey[600],
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class SaveFileIntent extends Intent {
  const SaveFileIntent();
}

class SaveAllFilesIntent extends Intent {
  const SaveAllFilesIntent();
}