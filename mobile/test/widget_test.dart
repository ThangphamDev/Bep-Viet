// This is a basic Flutter widget test for Bếp Việt app.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:bepviet_mobile/main.dart';
import 'package:bepviet_mobile/data/repositories/auth_repository.dart';
import 'package:bepviet_mobile/data/models/user_model.dart';

// Simple mock AuthRepository for testing
class TestAuthRepository implements AuthRepository {
  @override
  bool get isLoggedIn => false;

  @override
  UserModel? get currentUser => null;

  @override
  String? get accessToken => null;

  @override
  Future<AuthResponse> login(String email, String password) async {
    throw UnimplementedError('Test implementation');
  }

  @override
  Future<AuthResponse> register({
    required String email,
    required String password,
    required String name,
    String? region,
    String? subregion,
  }) async {
    throw UnimplementedError('Test implementation');
  }

  @override
  Future<void> logout() async {
    // Test implementation - do nothing
  }

  @override
  Future<UserModel> getUserProfile() async {
    throw UnimplementedError('Test implementation');
  }

  @override
  Future<bool> isTokenValid() async {
    return false;
  }
}

void main() {
  testWidgets('Bếp Việt app smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const BepVietApp());

    // Verify that the app starts with home page
    expect(find.text('Trang chủ'), findsOneWidget);

    // Verify that bottom navigation is present
    expect(find.byType(BottomNavigationBar), findsOneWidget);

    // Verify that all main navigation items are present
    expect(find.text('Trang chủ'), findsOneWidget);
    expect(find.text('Gợi ý'), findsOneWidget);
    expect(find.text('Công thức'), findsOneWidget);
    expect(find.text('Kế hoạch'), findsOneWidget);
    expect(find.text('Tủ lạnh'), findsOneWidget);
    expect(find.text('Cộng đồng'), findsOneWidget);
    expect(find.text('Premium'), findsOneWidget);
  });

  testWidgets('Navigation between tabs works', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const BepVietApp());

    // Tap on the 'Gợi ý' tab
    await tester.tap(find.text('Gợi ý'));
    await tester.pumpAndSettle();

    // Verify that we're on the suggest page
    expect(find.text('Gợi ý'), findsOneWidget);

    // Tap on the 'Công thức' tab
    await tester.tap(find.text('Công thức'));
    await tester.pumpAndSettle();

    // Verify that we're on the recipes page
    expect(find.text('Công thức'), findsOneWidget);

    // Tap on the 'Premium' tab
    await tester.tap(find.text('Premium'));
    await tester.pumpAndSettle();

    // Verify that we're on the premium page
    expect(find.text('Premium'), findsOneWidget);
  });

  testWidgets('Premium features are accessible', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(BepVietApp(authRepository: testAuthRepository));

    // Navigate to Premium tab
    await tester.tap(find.text('Premium'));
    await tester.pumpAndSettle();

    // Verify that premium features are present
    expect(find.text('Tính năng Premium'), findsOneWidget);
    expect(find.text('Hồ sơ gia đình'), findsOneWidget);
    expect(find.text('Cảnh báo sức khỏe'), findsOneWidget);
    expect(find.text('Phân tích chi tiết'), findsOneWidget);
    expect(find.text('Ưu tiên hỗ trợ'), findsOneWidget);
  });
}
