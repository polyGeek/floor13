import 'package:flutter/material.dart';
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
                const SizedBox(width: 12),
                Text(
                  'No projects open',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 13,
                  ),
                ),
                const Spacer(),
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
              ],
            );
          }

          return Row(
            children: [
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
            ],
          );
        },
      ),
    );
  }
}