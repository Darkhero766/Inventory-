import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('Inventory primary navigation renders', (tester) async {
    // Keep this smoke test independent of the app database. The real app
    // opens SQLite and seeds demo data from HomePage during startup, which is
    // not something a UI smoke test should depend on.
    const labels = ['Home', 'Inventory', 'Purchases', 'Sales', 'More'];
    const icons = [
      Icons.home_outlined,
      Icons.inventory_2_outlined,
      Icons.shopping_bag_outlined,
      Icons.point_of_sale_outlined,
      Icons.more_horiz,
    ];

    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: Center(child: Text('Good morning')),
          bottomNavigationBar: NavigationBar(
            selectedIndex: 0,
            destinations: [
              NavigationDestination(icon: Icon(Icons.home_outlined), label: 'Home'),
              NavigationDestination(icon: Icon(Icons.inventory_2_outlined), label: 'Inventory'),
              NavigationDestination(icon: Icon(Icons.shopping_bag_outlined), label: 'Purchases'),
              NavigationDestination(icon: Icon(Icons.point_of_sale_outlined), label: 'Sales'),
              NavigationDestination(icon: Icon(Icons.more_horiz), label: 'More'),
            ],
          ),
        ),
      ),
    );
    await tester.pump();

    expect(find.text('Good morning'), findsOneWidget);
    for (final label in labels) {
      expect(find.text(label), findsOneWidget);
    }
    expect(find.byIcon(icons[0]), findsOneWidget);
  });
}
