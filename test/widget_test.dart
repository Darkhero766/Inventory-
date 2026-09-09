import 'package:flutter_test/flutter_test.dart';
import 'package:inventory_shop/main.dart';

void main() {
  testWidgets('Inventory app renders navigation', (tester) async {
    await tester.pumpWidget(const InventoryApp());
    expect(find.text('Good morning'), findsOneWidget);
    expect(find.text('Inventory'), findsWidgets);
  });
}
