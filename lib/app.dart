import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:window_manager/window_manager.dart';
import 'models/app_state.dart';
import 'screens/main_screen.dart';

class F13orApp extends StatefulWidget {
  const F13orApp({super.key});

  @override
  State<F13orApp> createState() => _F13orAppState();
}

class _F13orAppState extends State<F13orApp> with WindowListener {
  late final AppState _appState;

  @override
  void initState() {
    super.initState();
    _appState = AppState();
    windowManager.addListener(this);
  }

  @override
  void dispose() {
    windowManager.removeListener(this);
    super.dispose();
  }

  @override
  void onWindowClose() async {
    // Save session before closing
    await _appState.saveSession();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: _appState,
      child: MaterialApp(
        title: 'F13or',
        debugShowCheckedModeBanner: false,
        theme: ThemeData.dark().copyWith(
          primaryColor: const Color(0xFF007ACC),
          scaffoldBackgroundColor: const Color(0xFF1E1E1E),
          colorScheme: const ColorScheme.dark(
            primary: Color(0xFF007ACC),
            secondary: Color(0xFF007ACC),
            surface: Color(0xFF252526),
            onSurface: Color(0xFFCCCCCC),
          ),
          dividerColor: const Color(0xFF464647),
          textTheme: const TextTheme(
            bodyMedium: TextStyle(color: Color(0xFFCCCCCC)),
          ),
        ),
        home: const MainScreen(),
      ),
    );
  }
}