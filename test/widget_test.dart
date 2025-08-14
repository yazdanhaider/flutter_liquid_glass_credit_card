// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_test/flutter_test.dart';

import 'package:flutter_liquid_glass_credit_card/main.dart';

void main() {
  testWidgets('Credit card app loads successfully', (
    WidgetTester tester,
  ) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const LiquidGlassCreditCardApp());

    // Verify that our credit card app loads with the expected title.
    expect(find.text('Liquid Glass'), findsOneWidget);
    expect(find.text('Credit Card'), findsOneWidget);

    // Verify that card input fields are present.
    expect(find.text('Card Number'), findsOneWidget);
    expect(find.text('Card Holder Name'), findsOneWidget);
    expect(find.text('Expiry'), findsOneWidget);
    expect(find.text('CVV'), findsOneWidget);
  });
}
