class Project {
  final String id;
  final String name;
  final String path;
  final DateTime createdAt;
  final DateTime lastOpened;
  final List<String> openFiles;
  final String? activeFile;

  Project({
    required this.id,
    required this.name,
    required this.path,
    required this.createdAt,
    required this.lastOpened,
    this.openFiles = const [],
    this.activeFile,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'path': path,
      'createdAt': createdAt.toIso8601String(),
      'lastOpened': lastOpened.toIso8601String(),
      'openFiles': openFiles,
      'activeFile': activeFile,
    };
  }

  factory Project.fromJson(Map<String, dynamic> json) {
    return Project(
      id: json['id'],
      name: json['name'],
      path: json['path'],
      createdAt: DateTime.parse(json['createdAt']),
      lastOpened: DateTime.parse(json['lastOpened']),
      openFiles: (json['openFiles'] as List<dynamic>?)?.cast<String>() ?? [],
      activeFile: json['activeFile'] as String?,
    );
  }

  Project copyWith({
    String? id,
    String? name,
    String? path,
    DateTime? createdAt,
    DateTime? lastOpened,
    List<String>? openFiles,
    String? activeFile,
  }) {
    return Project(
      id: id ?? this.id,
      name: name ?? this.name,
      path: path ?? this.path,
      createdAt: createdAt ?? this.createdAt,
      lastOpened: lastOpened ?? this.lastOpened,
      openFiles: openFiles ?? this.openFiles,
      activeFile: activeFile ?? this.activeFile,
    );
  }
}