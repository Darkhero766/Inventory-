import 'package:flutter_test/flutter_test.dart';
import 'package:inventory_shop/main.dart';

void main() {
  testWidgets('Inventory app renders its primary navigation', (tester) async {
    await tester.pumpWidget(const InventoryApp());
    await tester.pump();

    expect(find.text('Inventory'), findsWidgets);
    expect(find.text('Purchases'), findsWidgets);
    expect(find.text('Sales'), findsWidgets);
    expect(find.text('More'), findsWidgets);
    expect(find.text('Good morning'), findsOneWidget);
  });
}
