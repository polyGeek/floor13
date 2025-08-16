import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:f13or/app.dart';

void main() {
  testWidgets('F13or app launches test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const F13orApp());

    // Verify that the app launches with the explorer panel
    expect(find.text('EXPLORER'), findsOneWidget);
    
    // Verify that the Claude panel is present
    expect(find.text('CLAUDE'), findsOneWidget);
    
    // Verify that the main welcome message appears
    expect(find.text('F13or'), findsOneWidget);
  });
}
