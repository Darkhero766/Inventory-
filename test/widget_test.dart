import 'package:flutter_test/flutter_test.dart';
import 'package:inventory_shop/main.dart';

void main() {
  testWidgets('Inventory app renders its primary navigation', (tester) async {
    await tester.pumpWidget(const InventoryApp());
    // HomePage loads SQLite data asynchronously. A plain widget test does not
    // provide the native sqflite plugin, so consume that expected platform
    // exception while still verifying the rendered UI.
    tester.takeException();

    expect(find.text('Good morning'), findsOneWidget);
    expect(find.text('Inventory'), findsWidgets);
  });
}
