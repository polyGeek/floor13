class EditorTab {
  final String id;
  final String filePath;
  final String fileName;
  final bool isPermanent;
  final bool isModified;
  final String content;

  EditorTab({
    required this.id,
    required this.filePath,
    required this.fileName,
    this.isPermanent = false,
    this.isModified = false,
    this.content = '',
  });

  EditorTab copyWith({
    String? id,
    String? filePath,
    String? fileName,
    bool? isPermanent,
    bool? isModified,
    String? content,
  }) {
    return EditorTab(
      id: id ?? this.id,
      filePath: filePath ?? this.filePath,
      fileName: fileName ?? this.fileName,
      isPermanent: isPermanent ?? this.isPermanent,
      isModified: isModified ?? this.isModified,
      content: content ?? this.content,
    );
  }
}