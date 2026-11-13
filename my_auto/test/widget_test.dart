import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:my_auto/core/theme/colors/index.dart';

/// Smoke widget test for AutoRin chrome — does not boot full GraphQL/Firebase MyApp.
void main() {
  testWidgets('branded MaterialApp shell renders without crash', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: PartShopTheme.light,
        home: Scaffold(
          appBar: AppBar(title: const Text('AutoRin')),
          body: const Center(child: Text('Parts marketplace')),
        ),
      ),
    );

    expect(find.text('AutoRin'), findsOneWidget);
    expect(find.text('Parts marketplace'), findsOneWidget);
    expect(find.byType(Scaffold), findsOneWidget);
  });
}
