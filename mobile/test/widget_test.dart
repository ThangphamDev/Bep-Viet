// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

import 'package:bepviet_mobile/main.dart';
import 'package:bepviet_mobile/data/repositories/auth_repository.dart';

void main() {
  testWidgets('App loads correctly', (WidgetTester tester) async {
    // Create a mock AuthRepository for testing
    final mockAuthRepository = MockAuthRepository();

    // Build our app and trigger a frame.
    await tester.pumpWidget(BepVietApp(authRepository: mockAuthRepository));

    // Verify that the app loads without errors
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}

// Mock class for AuthRepository
class MockAuthRepository extends Mock implements AuthRepository {}
