import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/app_state.dart';

class EditorTabs extends StatelessWidget {
  const EditorTabs({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AppState>(
      builder: (context, appState, _) {
        if (appState.openTabs.isEmpty) {
          return Container(
            height: 35,
            decoration: const BoxDecoration(
              color: Color(0xFF252526),
              border: Border(
                bottom: BorderSide(
                  color: Color(0xFF464647),
                  width: 1,
                ),
              ),
            ),
            child: Row(
              children: [
                const SizedBox(width: 12),
                Text(
                  'No files open',
                  style: TextStyle(
                    color: Colors.grey[400],
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          );
        }

        return Container(
          height: 35,
          decoration: const BoxDecoration(
            color: Color(0xFF252526),
            border: Border(
              bottom: BorderSide(
                color: Color(0xFF464647),
                width: 1,
              ),
            ),
          ),
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: appState.openTabs.length,
            itemBuilder: (context, index) {
              final tab = appState.openTabs[index];
              final isActive = tab.id == appState.activeTab?.id;

              return GestureDetector(
                onTap: () => appState.setActiveTab(tab.id),
                child: Container(
                  constraints: const BoxConstraints(maxWidth: 200),
                  decoration: BoxDecoration(
                    color: isActive
                        ? const Color(0xFF1E1E1E)
                        : const Color(0xFF2D2D30),
                    border: Border(
                      right: const BorderSide(
                        color: Color(0xFF464647),
                        width: 1,
                      ),
                      top: BorderSide(
                        color: isActive
                            ? const Color(0xFF007ACC)
                            : Colors.transparent,
                        width: 2,
                      ),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const SizedBox(width: 12),
                      if (tab.isModified)
                        const Padding(
                          padding: EdgeInsets.only(right: 4),
                          child: Icon(
                            Icons.circle,
                            size: 8,
                            color: Color(0xFFCCCCCC),
                          ),
                        ),
                      Flexible(
                        child: Text(
                          tab.fileName,
                          style: TextStyle(
                            color: isActive
                                ? const Color(0xFFCCCCCC)
                                : const Color(0xFF969696),
                            fontSize: 13,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 8),
                      InkWell(
                        onTap: () => appState.closeTab(tab.id),
                        child: const Padding(
                          padding: EdgeInsets.all(4),
                          child: Icon(
                            Icons.close,
                            size: 14,
                            color: Color(0xFF969696),
                          ),
                        ),
                      ),
                      const SizedBox(width: 4),
                    ],
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }
}