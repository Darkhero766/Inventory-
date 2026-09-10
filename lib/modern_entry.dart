import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'data/database.dart';
import 'models/models.dart';
import 'main.dart' as legacy;

const blue = Color(0xFF4B63E6);
const purple = Color(0xFF7659F6);
const green = Color(0xFF18A56B);
const orange = Color(0xFFE28A19);
const ink = Color(0xFF171923);
const muted = Color(0xFF747783);
const bg = Color(0xFFF5F6FA);
String money(num value) => NumberFormat.currency(locale: 'en_IN', symbol: '₹', decimalDigits: 0).format(value);

void main() => runApp(const ModernApp());

class ModernApp extends StatelessWidget {
  const ModernApp({super.key});
  @override
  Widget build(BuildContext context) => MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Inventory POS',
        theme: ThemeData(
          useMaterial3: true,
          scaffoldBackgroundColor: bg,
          colorScheme: ColorScheme.fromSeed(seedColor: blue),
          cardTheme: CardThemeData(
            elevation: 0,
            color: Colors.white,
            margin: EdgeInsets.zero,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
          ),
          navigationBarTheme: NavigationBarThemeData(
            height: 76,
            backgroundColor: Colors.white,
            indicatorColor: blue.withAlpha(22),
            labelTextStyle: const WidgetStatePropertyAll(TextStyle(fontWeight: FontWeight.w800, fontSize: 12)),
          ),
          inputDecorationTheme: InputDecorationTheme(
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(17), borderSide: BorderSide.none),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(17), borderSide: BorderSide.none),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(17), borderSide: const BorderSide(color: blue, width: 1.2)),
          ),
        ),
        home: const Shell(),
      );
}

class Shell extends StatefulWidget {
  const Shell({super.key});
  @override State<Shell> createState() => _ShellState();
}

class _ShellState extends State<Shell> {
  int index = 0;
  static const labels = ['Home', 'Inventory', 'Purchases', 'Sales', 'More'];
  static const icons = [Icons.home_rounded, Icons.inventory_2_rounded, Icons.shopping_bag_rounded, Icons.point_of_sale_rounded, Icons.more_horiz_rounded];

  @override
  Widget build(BuildContext context) {
    final pages = <Widget>[
      const ModernHome(),
      const legacy.InventoryPage(),
      const legacy.PurchasesPage(),
      const ModernSales(),
      const legacy.MorePage(),
    ];
    final wide = MediaQuery.sizeOf(context).width >= 900;
    return Scaffold(
      body: wide
          ? Row(children: [
              Container(
                width: 225,
                color: Colors.white,
                padding: const EdgeInsets.fromLTRB(14, 22, 14, 14),
                child: Column(children: [
                  const _Brand(),
                  const SizedBox(height: 24),
                  Expanded(child: NavigationRail(
                    extended: true,
                    minExtendedWidth: 195,
                    selectedIndex: index,
                    onDestinationSelected: (v) => setState(() => index = v),
                    destinations: [for (var i = 0; i < labels.length; i++) NavigationRailDestination(icon: Icon(icons[i]), selectedIcon: Icon(icons[i]), label: Text(labels[i]))],
                  )),
                  const Text('ElectroMart • Main Store', style: TextStyle(color: muted, fontSize: 10)),
                ]),
              ),
              const VerticalDivider(width: 1),
              Expanded(child: pages[index]),
            ])
          : pages[index],
      bottomNavigationBar: wide ? null : NavigationBar(
        selectedIndex: index,
        onDestinationSelected: (v) => setState(() => index = v),
        destinations: [for (var i = 0; i < labels.length; i++) NavigationDestination(icon: Icon(icons[i]), label: labels[i])],
      ),
    );
  }
}

class _Brand extends StatelessWidget {
  const _Brand();
  @override
  Widget build(BuildContext context) => Row(children: [
        Container(width: 40, height: 40, decoration: BoxDecoration(gradient: const LinearGradient(colors: [blue, purple]), borderRadius: BorderRadius.circular(13)), child: const Icon(Icons.bolt_rounded, color: Colors.white)),
        const SizedBox(width: 10),
        const Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('INVENTORY', style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1)),
          Text('ElectroMart POS', style: TextStyle(color: muted, fontSize: 10)),
        ]),
      ]);
}

class _Frame extends StatelessWidget {
  final Widget child;
  const _Frame({required this.child});
  @override
  Widget build(BuildContext context) => SafeArea(child: Center(child: ConstrainedBox(constraints: const BoxConstraints(maxWidth: 1440), child: Padding(padding: const EdgeInsets.fromLTRB(20, 18, 20, 22), child: child))));
}

class ModernHome extends StatefulWidget {
  const ModernHome({super.key});
  @override State<ModernHome> createState() => _ModernHomeState();
}
class _ModernHomeState extends State<ModernHome> {
  List<Product> products = [];
  Map<String, num> stats = {};
  @override void initState() { super.initState(); load(); }
  Future<void> load() async { try { final p = await AppDatabase.instance.products(); final s = await AppDatabase.instance.snapshot(); if (mounted) setState(() { products = p; stats = s; }); } catch (_) {} }
  @override Widget build(BuildContext context) {
    final low = products.where((p) => p.quantity <= p.minimumStock).take(4).toList();
    return _Frame(child: RefreshIndicator(onRefresh: load, child: ListView(physics: const AlwaysScrollableScrollPhysics(), children: [
      const Text('Good morning', style: TextStyle(fontSize: 30, fontWeight: FontWeight.w900, color: ink, letterSpacing: -1)),
      const SizedBox(height: 4), const Text('Run your shop from one fast workspace.', style: TextStyle(color: muted)),
      const SizedBox(height: 18),
      Row(children: [Expanded(child: _HomeAction('New sale', Icons.point_of_sale_rounded, blue, () {})), const SizedBox(width: 10), Expanded(child: _HomeAction('Add product', Icons.add_box_rounded, purple, () {}))]),
      const SizedBox(height: 24),
      const Text('Business snapshot', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900)), const SizedBox(height: 10),
      LayoutBuilder(builder: (_, c) { final n = c.maxWidth > 1000 ? 4 : c.maxWidth > 600 ? 2 : 1; final w = (c.maxWidth - (n - 1) * 12) / n; return Wrap(spacing: 12, runSpacing: 12, children: [
        SizedBox(width: w, child: _Metric('Today sales', money(stats['sales'] ?? 0), Icons.trending_up_rounded, green)),
        SizedBox(width: w, child: _Metric('Purchases', money(stats['purchases'] ?? 0), Icons.shopping_bag_outlined, purple)),
        SizedBox(width: w, child: _Metric('Inventory value', money(stats['inventory'] ?? 0), Icons.inventory_2_outlined, blue, note: '${products.length} products')),
        SizedBox(width: w, child: _Metric('Low stock', '${stats['low'] ?? 0}', Icons.warning_amber_rounded, orange)),
      ]); }),
      const SizedBox(height: 24),
      const Text('Low stock', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900)), const SizedBox(height: 10),
      if (low.isEmpty) const Card(child: ListTile(leading: Icon(Icons.check_circle_outline, color: green), title: Text('Stock looks healthy'), subtitle: Text('No products need attention.', style: TextStyle(color: muted)))) else ...low.map((p) => Card(margin: const EdgeInsets.only(bottom: 8), child: ListTile(leading: legacy.ProductImage(product: p, size: 48), title: Text('${p.brand} · ${p.name}', maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.w800)), subtitle: Text('${p.quantity} left • ${p.sku}'), trailing: _Badge(p.status)))),
      const SizedBox(height: 24),
      const Text('Products', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900)), const SizedBox(height: 10),
      SizedBox(height: 240, child: products.isEmpty ? const Center(child: Text('No products yet')) : ListView.separated(scrollDirection: Axis.horizontal, itemCount: products.length > 8 ? 8 : products.length, separatorBuilder: (_, __) => const SizedBox(width: 12), itemBuilder: (_, i) => SizedBox(width: 205, child: legacy.ProductCard(products[i])))),
    ])));
  }
}

class _HomeAction extends StatelessWidget { final String label; final IconData icon; final Color color; final VoidCallback onTap; const _HomeAction(this.label, this.icon, this.color, this.onTap); @override Widget build(BuildContext context) => Card(child: InkWell(borderRadius: BorderRadius.circular(20), onTap: onTap, child: Padding(padding: const EdgeInsets.all(14), child: Row(children: [Container(width: 40, height: 40, decoration: BoxDecoration(color: color.withAlpha(18), borderRadius: BorderRadius.circular(12)), child: Icon(icon, color: color)), const SizedBox(width: 10), Expanded(child: Text(label, style: const TextStyle(fontWeight: FontWeight.w900))), const Icon(Icons.arrow_forward_rounded, size: 18, color: muted)])))); }
class _Metric extends StatelessWidget { final String label, value; final IconData icon; final Color color; final String? note; const _Metric(this.label, this.value, this.icon, this.color, {this.note}); @override Widget build(BuildContext context) => Card(child: Padding(padding: const EdgeInsets.all(16), child: Row(children: [Container(width: 42, height: 42, decoration: BoxDecoration(color: color.withAlpha(18), borderRadius: BorderRadius.circular(13)), child: Icon(icon, color: color)), const SizedBox(width: 12), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(label, style: const TextStyle(color: muted, fontSize: 12)), Text(value, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900)), if (note != null) Text(note!, style: const TextStyle(color: muted, fontSize: 11))]))]))); }
class _Badge extends StatelessWidget { final String status; const _Badge(this.status); @override Widget build(BuildContext context) { final color = status == 'IN STOCK' ? green : orange; return Container(padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6), decoration: BoxDecoration(color: color.withAlpha(18), borderRadius: BorderRadius.circular(30)), child: Text(status, style: TextStyle(color: color, fontSize: 9, fontWeight: FontWeight.w900))); } }

class ModernSales extends StatefulWidget {
  const ModernSales({super.key});
  @override State<ModernSales> createState() => _ModernSalesState();
}
class _ModernSalesState extends State<ModernSales> {
  List<Product> products = [];
  String query = '';
  final Map<int, int> cart = {};
  @override void initState() { super.initState(); load(); }
  Future<void> load() async { try { final result = await AppDatabase.instance.products(query: query); if (mounted) setState(() => products = result); } catch (_) {} }
  Product? find(int id) { for (final p in products) { if (p.id == id) return p; } return null; }
  int qty(Product p) => cart[p.id] ?? 0;
  double get total => cart.entries.fold(0, (sum, e) { final p = find(e.key); return sum + (p == null ? 0 : p.sellingPrice * e.value); });
  void add(Product p) { if (p.id == null || p.quantity <= 0) return; final n = qty(p); if (n >= p.quantity) { toast('Only ${p.quantity} available'); return; } setState(() => cart[p.id!] = n + 1); }
  void remove(Product p) { final n = qty(p); if (n <= 1) setState(() => cart.remove(p.id)); else setState(() => cart[p.id!] = n - 1); }
  void toast(String value) { if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(value))); }

  @override Widget build(BuildContext context) {
    final wide = MediaQuery.sizeOf(context).width >= 980;
    return _Frame(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const Text('New sale', style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900, color: ink)),
      const SizedBox(height: 3), const Text('Find product → cart → payment → invoice', style: TextStyle(color: muted)),
      const SizedBox(height: 15),
      TextField(onChanged: (v) { query = v; load(); }, decoration: InputDecoration(prefixIcon: const Icon(Icons.search_rounded), hintText: 'Search product, brand, model or SKU', suffixIcon: IconButton(onPressed: () => scan(context), icon: const Icon(Icons.qr_code_scanner_rounded)))),
      const SizedBox(height: 12),
      Expanded(child: wide ? Row(children: [Expanded(child: grid()), const SizedBox(width: 14), SizedBox(width: 350, child: cartPanel())]) : Column(children: [Expanded(child: grid()), const SizedBox(height: 9), SizedBox(height: 52, width: 290, child: FilledButton.icon(onPressed: cart.isEmpty ? null : () => showModalBottomSheet(context: context, isScrollControlled: true, showDragHandle: true, builder: (_) => SizedBox(height: MediaQuery.sizeOf(context).height * .72, child: Padding(padding: const EdgeInsets.all(15), child: cartPanel()))), icon: const Icon(Icons.shopping_bag_rounded), label: Text(cart.isEmpty ? 'Cart · ₹0' : 'View cart · ${money(total)}')))])),
    ]));
  }

  Widget grid() => LayoutBuilder(builder: (_, c) { if (products.isEmpty) return const Center(child: Text('No sellable products')); final n = c.maxWidth > 1150 ? 4 : c.maxWidth > 720 ? 3 : 2; return GridView.builder(itemCount: products.length, gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: n, crossAxisSpacing: 12, mainAxisSpacing: 12, childAspectRatio: .72), itemBuilder: (_, i) { final p = products[i]; final n = qty(p); return Card(child: Padding(padding: const EdgeInsets.all(9), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Expanded(child: legacy.ProductImage(product: p, size: 170)), Text(p.brand, style: const TextStyle(color: muted, fontSize: 10)), Text(p.name, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.w900)), Row(children: [Expanded(child: Text(money(p.sellingPrice), style: const TextStyle(fontWeight: FontWeight.w900))), if (p.quantity == 0) const Text('OUT', style: TextStyle(color: Color(0xFFE05252), fontWeight: FontWeight.w900)) else n == 0 ? IconButton(onPressed: () => add(p), icon: const Icon(Icons.add_circle, color: blue, size: 34)) : Row(mainAxisSize: MainAxisSize.min, children: [IconButton(onPressed: () => remove(p), icon: const Icon(Icons.remove_circle_outline)), Text('$n'), IconButton(onPressed: () => add(p), icon: const Icon(Icons.add_circle, color: blue))])])]))); }); }

  Widget cartPanel() => Card(child: Padding(padding: const EdgeInsets.all(15), child: Column(children: [Row(children: [const Expanded(child: Text('Current order', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900))), Text('${cart.values.fold<int>(0, (a, b) => a + b)} items', style: const TextStyle(color: muted))]), const SizedBox(height: 8), Expanded(child: cart.isEmpty ? const Center(child: Text('Cart is empty\nTap + to add a product', textAlign: TextAlign.center, style: TextStyle(color: muted))) : ListView.separated(itemCount: cart.length, separatorBuilder: (_, __) => const Divider(height: 1), itemBuilder: (_, i) { final id = cart.keys.elementAt(i); final p = find(id)!; return ListTile(contentPadding: EdgeInsets.zero, leading: legacy.ProductImage(product: p, size: 45), title: Text(p.name, maxLines: 1, overflow: TextOverflow.ellipsis), subtitle: Text('${money(p.sellingPrice)} each'), trailing: Row(mainAxisSize: MainAxisSize.min, children: [IconButton(onPressed: () => remove(p), icon: const Icon(Icons.remove_circle_outline)), Text('${qty(p)}'), IconButton(onPressed: () => add(p), icon: const Icon(Icons.add_circle, color: blue))])); })), const Divider(), Row(children: [const Expanded(child: Text('Total', style: TextStyle(color: muted))), Text(money(total), style: const TextStyle(fontSize: 21, fontWeight: FontWeight.w900))]), const SizedBox(height: 8), Row(children: [Expanded(child: OutlinedButton(onPressed: cart.isEmpty ? null : () => setState(cart.clear), child: const Text('Clear cart'))), const SizedBox(width: 8), Expanded(child: FilledButton(onPressed: cart.isEmpty ? null : () => checkout(context), child: const Text('Checkout')))])]));

  Future<void> checkout(BuildContext context) async {
    String payment = 'Cash';
    final customer = TextEditingController(text: 'Walk-in Customer');
    final ok = await showDialog<bool>(context: context, builder: (_) => StatefulBuilder(builder: (dialog, setDialog) => AlertDialog(title: const Text('Checkout', style: TextStyle(fontWeight: FontWeight.w900)), content: Column(mainAxisSize: MainAxisSize.min, children: [Text(money(total), style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900)), TextField(controller: customer, decoration: const InputDecoration(labelText: 'Customer')), DropdownButtonFormField<String>(initialValue: payment, decoration: const InputDecoration(labelText: 'Payment method'), items: const [DropdownMenuItem(value: 'Cash', child: Text('Cash')), DropdownMenuItem(value: 'UPI', child: Text('UPI')), DropdownMenuItem(value: 'Card', child: Text('Card')), DropdownMenuItem(value: 'Bank transfer', child: Text('Bank transfer')), DropdownMenuItem(value: 'Credit / Due', child: Text('Credit / Due'))], onChanged: (v) => setDialog(() => payment = v!))]), actions: [TextButton(onPressed: () => Navigator.pop(dialog, false), child: const Text('Cancel')), FilledButton(onPressed: () => Navigator.pop(dialog, true), child: const Text('Complete sale'))])));
    if (ok != true) { customer.dispose(); return; }
    try {
      final items = <Map<String, Object?>>[];
      for (final entry in cart.entries) { final p = find(entry.key); if (p != null) items.add({'product_id': p.id!, 'quantity': entry.value, 'price': p.sellingPrice, 'name': p.name}); }
      await AppDatabase.instance.sellCart(items, customer: customer.text.trim().isEmpty ? 'Walk-in Customer' : customer.text.trim(), payment: payment);
      if (!mounted) return;
      setState(cart.clear);
      await load();
      if (context.mounted) await showDialog<void>(context: context, builder: (_) => AlertDialog(title: const Text('✓ Sale completed'), content: Text('Total ${money(total)}\nPaid via $payment\nInventory updated automatically.'), actions: [FilledButton(onPressed: () => Navigator.pop(context), child: const Text('New sale'))]));
    } catch (e) { toast('$e'); }
    customer.dispose();
  }

  Future<void> scan(BuildContext context) async { final controller = TextEditingController(); final value = await showDialog<String>(context: context, builder: (_) => AlertDialog(title: const Text('Find by barcode / SKU'), content: TextField(controller: controller, autofocus: true), actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')), FilledButton(onPressed: () => Navigator.pop(context, controller.text.trim()), child: const Text('Find'))])); controller.dispose(); if (value != null && value.isNotEmpty) { query = value; load(); } }
}
