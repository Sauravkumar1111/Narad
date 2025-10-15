// Jarvis Assistant Flutter App Widget Tests
//
// Tests for the main Jarvis Assistant mobile application functionality.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jarvis_app/main.dart';

void main() {
  testWidgets('Jarvis App loads correctly', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const JarvisApp());

    // Verify that the app title is displayed
    expect(find.text('Jarvis Assistant'), findsOneWidget);
    
    // Verify that the main interface elements are present
    expect(find.text('Start a conversation with Jarvis'), findsOneWidget);
    expect(find.text('Use voice, text, or camera to interact'), findsOneWidget);
    
    // Verify that action buttons are present
    expect(find.byIcon(Icons.star), findsOneWidget); // New Features
    expect(find.byIcon(Icons.videocam), findsOneWidget); // Surveillance
    expect(find.byIcon(Icons.video_settings), findsOneWidget); // Camera Config
    expect(find.byIcon(Icons.settings), findsOneWidget); // Settings
    expect(find.byIcon(Icons.history), findsOneWidget); // History
  });

  testWidgets('Text input field is present and functional', (WidgetTester tester) async {
    await tester.pumpWidget(const JarvisApp());

    // Find the text input field
    final textField = find.byType(TextField);
    expect(textField, findsOneWidget);

    // Test typing in the text field
    await tester.enterText(textField, 'Hello Jarvis');
    await tester.pump();

    // Verify text was entered
    expect(find.text('Hello Jarvis'), findsOneWidget);
  });

  testWidgets('Send button is present', (WidgetTester tester) async {
    await tester.pumpWidget(const JarvisApp());

    // Verify send button is present
    expect(find.byIcon(Icons.send), findsOneWidget);
  });
}
