// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:cadastro_alunos/main.dart';

void main() {
  testWidgets('adiciona um aluno a lista', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});
    await tester.pumpWidget(const MyApp());
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField).at(0), 'Ana');
    await tester.enterText(find.byType(TextField).at(1), '20');
    await tester.enterText(find.byType(TextField).at(2), 'ADS');
    await tester.tap(find.text('Adicionar Aluno'));
    await tester.pumpAndSettle();

    expect(find.text('Ana - 20 anos - ADS'), findsOneWidget);
  });
}
