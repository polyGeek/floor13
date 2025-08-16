import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:file_picker/file_picker.dart';
import '../models/app_state.dart';

class ProjectTabs extends StatelessWidget {
  const ProjectTabs({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 40,
      decoration: const BoxDecoration(
        color: Color(0xFF2D2D30),
        border: Border(
          bottom: BorderSide(
            color: Color(0xFF464647),
            width: 1,
          ),
        ),
      ),
      child: Consumer<AppState>(
        builder: (context, appState, _) {
          if (appState.openProjects.isEmpty) {
            return Row(
              children: [
                // Add button on far left
                IconButton(
                  icon: const Icon(Icons.add, size: 18),
                  onPressed: () async {
                    String? selectedDirectory = await FilePicker.platform.getDirectoryPath();
                    if (selectedDirectory != null) {
                      appState.openProject(selectedDirectory);
                    }
                  },
                  tooltip: 'Open Project',
                ),
                const SizedBox(width: 12),
                Text(
                  'No projects open',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 13,
                  ),
                ),
                const Spacer(),
                // Contextual tools on the right
                _buildContextualTools(context, appState),
              ],
            );
          }

          return Row(
            children: [
              // Add button on far left
              IconButton(
                icon: const Icon(Icons.add, size: 18),
                onPressed: () async {
                  String? selectedDirectory = await FilePicker.platform.getDirectoryPath();
                  if (selectedDirectory != null) {
                    appState.openProject(selectedDirectory);
                  }
                },
                tooltip: 'Open Project',
              ),
              // Project tabs
              Expanded(
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: appState.openProjects.length,
                  itemBuilder: (context, index) {
                    final project = appState.openProjects[index];
                    final isActive = project.id == appState.activeProject?.id;

                    return GestureDetector(
                      onTap: () => appState.switchProject(project.id),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        decoration: BoxDecoration(
                          color: isActive
                              ? const Color(0xFF1E1E1E)
                              : const Color(0xFF2D2D30),
                          border: Border(
                            right: const BorderSide(
                              color: Color(0xFF464647),
                              width: 1,
                            ),
                            bottom: BorderSide(
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
                            Center(
                              child: Text(
                                project.name,
                                style: TextStyle(
                                  color: isActive
                                      ? const Color(0xFFCCCCCC)
                                      : const Color(0xFF969696),
                                  fontSize: 13,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            InkWell(
                              onTap: () => appState.closeProject(project.id),
                              child: const Icon(
                                Icons.close,
                                size: 14,
                                color: Color(0xFF969696),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              // Contextual tools on the right
              _buildContextualTools(context, appState),
            ],
          );
        },
      ),
    );
  }

  Widget _buildContextualTools(BuildContext context, AppState appState) {
    final hasActiveTab = appState.activeTab != null;
    final hasModifiedFiles = appState.activeTab?.isModified ?? false;
    
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Save button
        Tooltip(
          message: 'Save (Ctrl+S)\nDouble-click: Save All (Ctrl+Shift+S)',
          child: InkWell(
            onTap: hasActiveTab ? () {
              // Save current file
              appState.saveCurrentFile();
            } : null,
            onDoubleTap: hasActiveTab ? () {
              // Save all files
              appState.saveAllFiles();
            } : null,
            child: Container(
              padding: const EdgeInsets.all(8),
              child: Icon(
                Icons.save,
                size: 18,
                color: hasActiveTab 
                  ? (hasModifiedFiles ? const Color(0xFFFFCC00) : const Color(0xFF969696))
                  : const Color(0xFF505050),
              ),
            ),
          ),
        ),
        // Undo button
        Tooltip(
          message: 'Undo (Ctrl+Z)',
          child: InkWell(
            onTap: hasActiveTab ? () {
              // Trigger undo
              final undoIntent = const UndoTextIntent(SelectionChangedCause.keyboard);
              Actions.invoke(context, undoIntent);
            } : null,
            child: Container(
              padding: const EdgeInsets.all(8),
              child: Icon(
                Icons.undo,
                size: 18,
                color: hasActiveTab ? const Color(0xFF969696) : const Color(0xFF505050),
              ),
            ),
          ),
        ),
        // Redo button
        Tooltip(
          message: 'Redo (Ctrl+Y)',
          child: InkWell(
            onTap: hasActiveTab ? () {
              // Trigger redo
              final redoIntent = const RedoTextIntent(SelectionChangedCause.keyboard);
              Actions.invoke(context, redoIntent);
            } : null,
            child: Container(
              padding: const EdgeInsets.all(8),
              child: Icon(
                Icons.redo,
                size: 18,
                color: hasActiveTab ? const Color(0xFF969696) : const Color(0xFF505050),
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),
      ],
    );
  }
}