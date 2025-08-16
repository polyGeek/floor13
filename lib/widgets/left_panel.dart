import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/app_state.dart';
import 'file_explorer/file_tree.dart';

class LeftPanel extends StatelessWidget {
  const LeftPanel({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();

    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFF252526),
        border: Border(
          right: BorderSide(
            color: Color(0xFF464647),
            width: 1,
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                const Text(
                  'EXPLORER',
                  style: TextStyle(
                    color: Color(0xFF969696),
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.5,
                  ),
                ),
                const Spacer(),
                if (appState.activeProject != null)
                  Text(
                    appState.activeProject!.name,
                    style: const TextStyle(
                      color: Color(0xFF969696),
                      fontSize: 11,
                    ),
                  ),
              ],
            ),
          ),
          const Divider(
            color: Color(0xFF464647),
            height: 1,
          ),
          Expanded(
            child: FileTree(
              onFileSelected: (path) {
                appState.openFile(path);
              },
              onFileDoubleClick: (path) {
                appState.openFile(path);
              },
            ),
          ),
        ],
      ),
    );
  }
}