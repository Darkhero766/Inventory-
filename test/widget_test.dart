import 'package:flutter_test/flutter_test.dart';
import 'package:inventory_shop/main.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  // Flutter widget tests run on the Dart VM, not on Android/iOS, so the
  // native sqflite database factory is unavailable unless we install the
  // FFI implementation explicitly.
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;

  testWidgets('Inventory app renders its primary navigation', (tester) async {
    await tester.pumpWidget(const InventoryApp());
    await tester.pumpAndSettle();

    expect(find.text('Good morning'), findsOneWidget);
    expect(find.text('Inventory'), findsWidgets);
    expect(find.text('Purchases'), findsOneWidget);
    expect(find.text('Sales'), findsOneWidget);
    expect(find.text('More'), findsOneWidget);
  });
}
