# F13or Development Rules & Guidelines

## Core Development Principles

### 1. Desktop-First Philosophy
- Design for desktop users, not mobile-adapted interfaces
- Utilize desktop screen real estate effectively
- Implement desktop-native interaction patterns
- Support keyboard-driven workflows
- Provide context menus and right-click functionality

### 2. Flutter Desktop Best Practices

#### Platform Detection & Adaptation
```dart
// Use proper platform detection
if (Platform.isWindows) {
  // Windows-specific implementation
} else if (Platform.isMacOS) {
  // macOS-specific implementation  
} else if (Platform.isLinux) {
  // Linux-specific implementation
}
```

#### Window Management
- Always handle window lifecycle events properly
- Implement window state persistence (size, position)
- Support multi-window workflows where appropriate
- Handle window focus and blur events
- Respect platform-specific window behaviors

#### File System Operations
- Use proper error handling for all file operations
- Implement sandboxing where required by platform
- Use native file dialogs via `file_picker` package
- Handle file watching for real-time updates
- Implement proper file locking mechanisms

### 3. Performance Requirements

#### Memory Management
- Dispose of controllers and streams properly
- Use `AutomaticKeepAliveClientMixin` judiciously
- Implement lazy loading for large data sets
- Monitor memory usage during long sessions
- Use weak references where appropriate

#### UI Responsiveness
- Use `Isolate` for heavy computational tasks
- Implement proper loading states for async operations
- Avoid blocking the UI thread with file operations
- Use `ValueNotifier` for lightweight state changes
- Implement efficient list rendering for large datasets

#### Startup Performance
- Lazy load non-critical widgets
- Implement splash screen for initialization
- Cache frequently accessed data
- Minimize startup dependencies
- Use async initialization patterns

### 4. State Management Rules

#### Simple State (Local Widget State)
- Use `setState` for simple, local widget state
- Prefer `ValueNotifier` for single-value state
- Use `AnimationController` for animation state

#### Complex State (Application-Wide)
- Use Provider/Riverpod for dependency injection
- Implement Repository pattern for data access
- Use Service classes for business logic
- Maintain single source of truth for shared state

#### File System State
- Watch file changes using `FileSystemWatcher`
- Implement optimistic updates for file operations
- Cache file metadata for performance
- Handle file system errors gracefully

### 5. Code Organization Standards

#### Project Structure
```
lib/
├── main.dart
├── app/
│   ├── app.dart
│   └── app_config.dart
├── core/
│   ├── constants/
│   ├── extensions/
│   ├── services/
│   └── utils/
├── features/
│   ├── file_explorer/
│   ├── editor/
│   ├── claude_chat/
│   └── project_management/
├── shared/
│   ├── widgets/
│   ├── themes/
│   └── models/
└── platform/
    ├── windows/
    ├── macos/
    └── linux/
```

#### File Naming Conventions
- Use snake_case for file names
- Use descriptive names that indicate purpose
- Separate widgets, models, and services into appropriate folders
- Platform-specific code goes in `platform/` directory

#### Widget Design Patterns
- Create reusable widgets in `shared/widgets/`
- Implement proper widget composition
- Use const constructors where possible
- Implement proper widget keys for testing

### 6. Testing Requirements

#### Unit Testing
- Test all business logic and services
- Test widget behavior and state changes
- Mock external dependencies (file system, network)
- Achieve minimum 80% code coverage

#### Integration Testing
- Test complete user workflows
- Test cross-platform compatibility
- Test file system operations on all platforms
- Test keyboard shortcuts and accessibility

#### Desktop-Specific Testing
- Test window management functions
- Test file drag-and-drop operations
- Test context menus and native integrations
- Test performance under realistic desktop usage

### 7. Error Handling Standards

#### File System Errors
```dart
try {
  final file = File(path);
  final contents = await file.readAsString();
  return contents;
} catch (e) {
  if (e is FileSystemException) {
    // Handle specific file system errors
    logger.error('File operation failed: ${e.message}');
    throw FileOperationException('Unable to read file: ${e.message}');
  }
  rethrow;
}
```

#### User-Facing Error Messages
- Provide clear, actionable error messages
- Include recovery suggestions where possible
- Log technical details for debugging
- Never expose stack traces to end users

#### Graceful Degradation
- Continue functioning when non-critical features fail
- Provide fallback options for platform-specific features
- Save user work before displaying error dialogs
- Implement retry mechanisms for transient failures

### 8. Accessibility Guidelines

#### Keyboard Navigation
- All UI elements must be keyboard accessible
- Implement logical tab order
- Provide keyboard shortcuts for common actions
- Support platform-specific shortcut conventions

#### Screen Reader Support
- Use semantic widgets and proper labels
- Provide meaningful descriptions for complex widgets
- Implement proper focus management
- Test with platform screen readers

### 9. Security Considerations

#### File System Access
- Validate all file paths before operations
- Sanitize user input for file names
- Respect platform sandboxing requirements
- Implement proper permission handling

#### Data Protection
- Encrypt sensitive configuration data
- Secure API keys and tokens
- Implement secure storage for user preferences
- Handle clipboard data securely

### 10. Forbidden Patterns

#### Anti-Patterns to Avoid
- **No Hot Reload Dependencies**: Avoid code that breaks hot reload
- **No Platform Blocking**: Don't block on platform-specific code
- **No Unhandled Futures**: Always handle async operations properly
- **No Global State Mutation**: Use proper state management patterns
- **No Hardcoded Paths**: Use platform-appropriate path resolution
- **No UI Thread Blocking**: Keep heavy operations off the main thread

#### Code Smells
- Widgets with too many responsibilities
- Deep widget tree nesting (>6 levels)
- Stateful widgets that don't need state
- Missing error handling in async operations
- Platform checks in widget build methods

### 11. Development Workflow

#### Before Starting Implementation
1. Scout analyzes existing code structure
2. Forge designs architecture and patterns
3. Review platform-specific requirements
4. Plan testing strategy with Sentinel

#### During Implementation
1. Follow established architectural patterns
2. Write tests alongside implementation
3. Handle platform differences appropriately
4. Document complex decisions and patterns

#### Before Completing
1. Run `flutter analyze` with zero warnings
2. Test on all target platforms
3. Verify performance requirements
4. Update documentation with Sage

### 12. Platform-Specific Considerations

#### Windows
- Handle file system case insensitivity
- Implement proper Windows path handling
- Support Windows-specific keyboard shortcuts
- Test with Windows Defender and antivirus software

#### macOS
- Follow macOS Human Interface Guidelines
- Implement proper macOS menu integration
- Handle macOS security and privacy permissions
- Support macOS-specific gestures and shortcuts

#### Linux
- Support various Linux distributions
- Handle different window managers
- Implement proper Linux desktop integration
- Test with different themes and icon sets

## Compliance Checklist

Before any code is considered complete, it must pass:

- [ ] Flutter analyze with zero warnings
- [ ] All unit tests passing
- [ ] Integration tests on all platforms
- [ ] Performance benchmarks met
- [ ] Accessibility requirements satisfied
- [ ] Security review completed
- [ ] Documentation updated
- [ ] Platform-specific testing completed

## Emergency Protocols

### Critical Bug Response
1. Immediately stop feature development
2. Isolate the bug with minimal reproduction
3. Implement hotfix if possible
4. Add regression tests
5. Review related code for similar issues

### Performance Issues
1. Profile the application to identify bottlenecks
2. Implement targeted optimizations
3. Verify improvements with benchmarks
4. Document performance characteristics
5. Add performance monitoring for future issues

### Platform Compatibility Problems
1. Test on affected platform immediately
2. Implement platform-specific workarounds
3. Document platform differences
4. Consider long-term architectural solutions
5. Update testing procedures to catch similar issues