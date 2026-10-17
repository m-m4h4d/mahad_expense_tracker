import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:spend_wise/main.dart';

void main() {
  testWidgets('logged-out app opens on the login screen', (tester) async {
    SharedPreferences.setMockInitialValues({});

    await tester.pumpWidget(createApp());
    await tester.pumpAndSettle();

    expect(find.widgetWithText(ElevatedButton, 'Login'), findsOneWidget);
    expect(find.text('Don\'t have an account? Sign Up'), findsOneWidget);
  });
}
