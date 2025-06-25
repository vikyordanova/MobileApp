import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:project_beauty/main.dart';

void main() {
  testWidgets('Counter increments smoke test', (WidgetTester tester) async {
    // Зареди целия app, не само WelcomeScreen
    await tester.pumpWidget(const HairTimeApp());

    // Примерна проверка, че Welcome текстът се показва
    expect(find.text('Добре дошли в HairTime!'), findsOneWidget);
  });
}
