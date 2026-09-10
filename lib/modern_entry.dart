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
          cardTheme: CardThemeData(elevation: 0, color: Colors.white, margin: EdgeInsets.zero, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20))),
          navigationBarTheme: NavigationBarThemeData(height: 76, backgroundColor: Colors.white, indicatorColor: blue.withAlpha(22), labelTextStyle: const WidgetStatePropertyAll(TextStyle(fontWeight: FontWeight.w800, fontSize: 12))),
          inputDecorationTheme: InputDecorationTheme(filled: true, fillColor: Colors.white, contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14), border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none), enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none), focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: blue, width: 1.2))),
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
    final pages = <Widget>[const Home(), const legacy.InventoryPage(), const legacy.PurchasesPage(), const Sales(), const legacy.MorePage()];
    final wide = MediaQuery.sizeOf(context).width >= 900;
    return Scaffold(
      body: wide
          ? Row(children: [
              Container(width: 225, color: Colors.white, padding: const EdgeInsets.fromLTRB(14, 22, 14, 14), child: Column(children: [const Brand(), const SizedBox(height: 24), Expanded(child: NavigationRail(extended: true, minExtendedWidth: 195, selectedIndex: index, onDestinationSelected: (v) => setState(() => index = v), destinations: [for (var i = 0; i < labels.length; i++) NavigationRailDestination(icon: Icon(icons[i]), selectedIcon: Icon(icons[i]), label: Text(labels[i]))])), const Text('ElectroMart • Main Store', style: TextStyle(color: muted, fontSize: 10))])),
              const VerticalDivider(width: 1),
              Expanded(child: pages[index]),
            ])
          : pages[index],
      bottomNavigationBar: wide ? null : NavigationBar(selectedIndex: index, onDestinationSelected: (v) => setState(() => index = v), destinations: [for (var i = 0; i < labels.length; i++) NavigationDestination(icon: Icon(icons[i]), label: labels[i])]),
    );
  }
}

class Brand extends StatelessWidget {
  const Brand({super.key});
  @override Widget build(BuildContext context) => Row(children: [Container(width: 40, height: 40, decoration: BoxDecoration(gradient: const LinearGradient(colors: [blue, purple]), borderRadius: BorderRadius.circular(13)), child: const Icon(Icons.bolt_rounded, color: Colors.white)), const SizedBox(width: 10), const Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('INVENTORY', style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1)), Text('ElectroMart POS', style: TextStyle(color: muted, fontSize: 10))])]);
}

class Home extends StatefulWidget {
  const Home({super.key});
  @override State<Home> createState() => _HomeState();
}
class _HomeState extends State<Home> {
  List<Product> products = [];
  Map<String, num> stats = {};
  @override void initState() { super.initState(); load(); }
  Future<void> load() async { try { final p = await AppDatabase.instance.products(); final s = await AppDatabase.instance.snapshot(); if (mounted) setState(() { products = p; stats = s; }); } catch (_) {} }
  @override Widget build(BuildContext context) => SafeArea(child: Padding(padding: const EdgeInsets.fromLTRB(20, 18, 20, 22), child: RefreshIndicator(onRefresh: load, child: ListView(children: [
    const Text('Good morning', style: TextStyle(fontSize: 30, fontWeight: FontWeight.w900, color: ink, letterSpacing: -1)),
    const SizedBox(height: 4), const Text('Run your shop from one fast workspace.', style: TextStyle(color: muted)),
    const SizedBox(height: 20),
    Row(children: [Expanded(child: _HomeAction('New sale', Icons.point_of_sale_rounded, blue)), const SizedBox(width: 10), Expanded(child: _HomeAction('Add product', Icons.add_box_rounded, purple))]),
    const SizedBox(height: 24),
    const Text('Business snapshot', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900)), const SizedBox(height: 10),
    Wrap(spacing: 12, runSpacing: 12, children: [
      _Metric('Today sales', money(stats['sales'] ?? 0), Icons.trending_up_rounded, green),
      _Metric('Purchases', money(stats['purchases'] ?? 0), Icons.shopping_bag_outlined, purple),
      _Metric('Inventory value', money(stats['inventory'] ?? 0), Icons.inventory_2_outlined, blue, note: '${products.length} products'),
      _Metric('Low stock', '${stats['low'] ?? 0}', Icons.warning_amber_rounded, orange),
    ]),
    const SizedBox(height: 24),
    const Text('Products', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900)), const SizedBox(height: 10),
    SizedBox(height: 245, child: products.isEmpty ? const Center(child: Text('No products yet')) : ListView.separated(scrollDirection: Axis.horizontal, itemCount: products.length > 8 ? 8 : products.length, separatorBuilder: (_, __) => const SizedBox(width: 12), itemBuilder: (_, i) => SizedBox(width: 205, child: legacy.ProductCard(products[i])))),
  ]))));
}
class _HomeAction extends StatelessWidget { final String text; final IconData icon; final Color color; const _HomeAction(this.text, this.icon, this.color); @override Widget build(BuildContext context) => Card(child: Padding(padding: const EdgeInsets.all(15), child: Row(children: [Container(width: 40, height: 40, decoration: BoxDecoration(color: color.withAlpha(18), borderRadius: BorderRadius.circular(12)), child: Icon(icon, color: color)), const SizedBox(width: 10), Expanded(child: Text(text, style: const TextStyle(fontWeight: FontWeight.w900))), const Icon(Icons.arrow_forward_rounded, color: muted)]))); }
class _Metric extends StatelessWidget { final String label, value; final IconData icon; final Color color; final String? note; const _Metric(this.label, this.value, this.icon, this.color, {this.note}); @override Widget build(BuildContext context) => SizedBox(width: 250, child: Card(child: Padding(padding: const EdgeInsets.all(16), child: Row(children: [Container(width: 42, height: 42, decoration: BoxDecoration(color: color.withAlpha(18), borderRadius: BorderRadius.circular(13)), child: Icon(icon, color: color)), const SizedBox(width: 12), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(label, style: const TextStyle(color: muted, fontSize: 12)), Text(value, style: const TextStyle(fontSize: 19, fontWeight: FontWeight.w900)), if (note != null) Text(note!, style: const TextStyle(color: muted, fontSize: 11))]))])))); }

class Sales extends StatefulWidget {
  const Sales({super.key});
  @override State<Sales> createState() => _SalesState();
}
class _SalesState extends State<Sales> {
  List<Product> products = [];
  final Map<int, int> cart = {};
  String query = '';
  @override void initState() { super.initState(); load(); }
  Future<void> load() async { try { final result = await AppDatabase.instance.products(query: query); if (mounted) setState(() => products = result); } catch (_) {} }
  Product? product(int id) { for (final item in products) { if (item.id == id) return item; } return null; }
  int quantity(Product p) => cart[p.id] ?? 0;
  double get total => cart.entries.fold(0, (sum, e) { final p = product(e.key); return sum + (p == null ? 0 : p.sellingPrice * e.value); });
  void add(Product p) { if (p.id == null || p.quantity <= 0) return; final current = quantity(p); if (current >= p.quantity) { snack('Only ${p.quantity} available'); return; } setState(() => cart[p.id!] = current + 1); }
  void remove(Product p) { final current = quantity(p); if (current <= 1) setState(() => cart.remove(p.id)); else setState(() => cart[p.id!] = current - 1); }
  void snack(String text) { if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text))); }

  @override Widget build(BuildContext context) {
    return SafeArea(child: Padding(padding: const EdgeInsets.fromLTRB(20, 18, 20, 18), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const Text('New sale', style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900, color: ink)),
      const Text('Find product → cart → payment → invoice', style: TextStyle(color: muted)),
      const SizedBox(height: 15),
      TextField(onChanged: (value) { query = value; load(); }, decoration: InputDecoration(prefixIcon: const Icon(Icons.search_rounded), hintText: 'Search product, brand, model or SKU', suffixIcon: IconButton(onPressed: () => scan(context), icon: const Icon(Icons.qr_code_scanner_rounded)))),
      const SizedBox(height: 12),
      Expanded(child: LayoutBuilder(builder: (_, constraints) {
        final wide = constraints.maxWidth >= 900;
        final productsView = GridView.builder(itemCount: products.length, gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: constraints.maxWidth >= 1150 ? 4 : constraints.maxWidth >= 600 ? 3 : 2, crossAxisSpacing: 12, mainAxisSpacing: 12, childAspectRatio: .72), itemBuilder: (_, i) => _SellCard(product: products[i], quantity: quantity(products[i]), onAdd: () => add(products[i]), onRemove: () => remove(products[i])));
        if (wide) return Row(children: [Expanded(child: productsView), const SizedBox(width: 14), SizedBox(width: 350, child: _CartPanel(cart: cart, products: products, total: total, onAdd: add, onRemove: remove, onClear: () => setState(cart.clear), onCheckout: () => checkout(context))]);
        return Column(children: [Expanded(child: productsView), const SizedBox(height: 10), SizedBox(height: 52, width: 290, child: FilledButton.icon(onPressed: cart.isEmpty ? null : () => showCart(context), icon: const Icon(Icons.shopping_bag_rounded), label: Text(cart.isEmpty ? 'Cart · ₹0' : 'View cart · ${money(total)}')))]);
      })),
    ])));
  }

  Future<void> showCart(BuildContext context) async { await showModalBottomSheet<void>(context: context, isScrollControlled: true, showDragHandle: true, builder: (_) => SizedBox(height: MediaQuery.sizeOf(context).height * .75, child: Padding(padding: const EdgeInsets.all(16), child: _CartPanel(cart: cart, products: products, total: total, onAdd: add, onRemove: remove, onClear: () => setState(cart.clear), onCheckout: () { Navigator.pop(context); checkout(context); })))); }
  Future<void> scan(BuildContext context) async { final controller = TextEditingController(); final value = await showDialog<String>(context: context, builder: (_) => AlertDialog(title: const Text('Find by barcode / SKU'), content: TextField(controller: controller, autofocus: true), actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')), FilledButton(onPressed: () => Navigator.pop(context, controller.text.trim()), child: const Text('Find'))])); controller.dispose(); if (value != null && value.isNotEmpty) { query = value; load(); } }
  Future<void> checkout(BuildContext context) async {
    String payment = 'Cash';
    final customer = TextEditingController(text: 'Walk-in Customer');
    final ok = await showDialog<bool>(context: context, builder: (_) => StatefulBuilder(builder: (dialog, setDialog) => AlertDialog(title: const Text('Checkout', style: TextStyle(fontWeight: FontWeight.w900)), content: Column(mainAxisSize: MainAxisSize.min, children: [Text(money(total), style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900)), TextField(controller: customer, decoration: const InputDecoration(labelText: 'Customer')), DropdownButtonFormField<String>(initialValue: payment, decoration: const InputDecoration(labelText: 'Payment method'), items: const [DropdownMenuItem(value: 'Cash', child: Text('Cash')), DropdownMenuItem(value: 'UPI', child: Text('UPI')), DropdownMenuItem(value: 'Card', child: Text('Card')), DropdownMenuItem(value: 'Bank transfer', child: Text('Bank transfer')), DropdownMenuItem(value: 'Credit / Due', child: Text('Credit / Due'))], onChanged: (v) => setDialog(() => payment = v!))]), actions: [TextButton(onPressed: () => Navigator.pop(dialog, false), child: const Text('Cancel')), FilledButton(onPressed: () => Navigator.pop(dialog, true), child: const Text('Complete sale'))])));
    if (ok != true) { customer.dispose(); return; }
    try {
      final items = <Map<String, Object?>>[];
      for (final entry in cart.entries) { final p = product(entry.key); if (p != null) items.add({'product_id': p.id!, 'quantity': entry.value, 'price': p.sellingPrice, 'name': p.name}); }
      await AppDatabase.instance.sellCart(items, customer: customer.text.trim().isEmpty ? 'Walk-in Customer' : customer.text.trim(), payment: payment);
      if (mounted) { setState(cart.clear); await load(); }
      if (context.mounted) await showDialog<void>(context: context, builder: (_) => AlertDialog(title: const Text('✓ Sale completed'), content: Text('Total ${money(total)}\nPaid via $payment\nInventory updated automatically.'), actions: [FilledButton(onPressed: () => Navigator.pop(context), child: const Text('New sale'))]));
    } catch (error) { snack('$error'); }
    customer.dispose();
  }
}

class _SellCard extends StatelessWidget {
  final Product product;
  final int quantity;
  final VoidCallback onAdd, onRemove;
  const _SellCard({required this.product, required this.quantity, required this.onAdd, required this.onRemove});
  @override Widget build(BuildContext context) => Card(child: Padding(padding: const EdgeInsets.all(9), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Expanded(child: legacy.ProductImage(product: product, size: 170)), Text(product.brand, style: const TextStyle(color: muted, fontSize: 10)), Text(product.name, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.w900)), Row(children: [Expanded(child: Text(money(product.sellingPrice), style: const TextStyle(fontWeight: FontWeight.w900))), if (product.quantity == 0) const Text('OUT', style: TextStyle(color: Color(0xFFE05252), fontWeight: FontWeight.w900)) else if (quantity == 0) IconButton(onPressed: onAdd, icon: const Icon(Icons.add_circle, color: blue, size: 34)) else Row(mainAxisSize: MainAxisSize.min, children: [IconButton(onPressed: onRemove, icon: const Icon(Icons.remove_circle_outline)), Text('$quantity'), IconButton(onPressed: onAdd, icon: const Icon(Icons.add_circle, color: blue))])])]));
}

class _CartPanel extends StatelessWidget {
  final Map<int, int> cart;
  final List<Product> products;
  final double total;
  final void Function(Product) onAdd;
  final void Function(Product) onRemove;
  final VoidCallback onClear, onCheckout;
  const _CartPanel({required this.cart, required this.products, required this.total, required this.onAdd, required this.onRemove, required this.onClear, required this.onCheckout});
  Product? find(int id) { for (final p in products) { if (p.id == id) return p; } return null; }
  @override Widget build(BuildContext context) => Card(child: Padding(padding: const EdgeInsets.all(15), child: Column(children: [Row(children: [const Expanded(child: Text('Current order', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900))), Text('${cart.values.fold<int>(0, (a, b) => a + b)} items', style: const TextStyle(color: muted))]), const SizedBox(height: 8), Expanded(child: cart.isEmpty ? const Center(child: Text('Cart is empty\nTap + to add a product', textAlign: TextAlign.center, style: TextStyle(color: muted))) : ListView.separated(itemCount: cart.length, separatorBuilder: (_, __) => const Divider(height: 1), itemBuilder: (_, i) { final id = cart.keys.elementAt(i); final p = find(id); if (p == null) return const SizedBox.shrink(); return ListTile(contentPadding: EdgeInsets.zero, leading: legacy.ProductImage(product: p, size: 45), title: Text(p.name, maxLines: 1, overflow: TextOverflow.ellipsis), subtitle: Text('${money(p.sellingPrice)} each'), trailing: Row(mainAxisSize: MainAxisSize.min, children: [IconButton(onPressed: () => onRemove(p), icon: const Icon(Icons.remove_circle_outline)), Text('${cart[id]}'), IconButton(onPressed: () => onAdd(p), icon: const Icon(Icons.add_circle, color: blue))])); })), const Divider(), Row(children: [const Expanded(child: Text('Total', style: TextStyle(color: muted))), Text(money(total), style: const TextStyle(fontSize: 21, fontWeight: FontWeight.w900))]), const SizedBox(height: 8), Row(children: [Expanded(child: OutlinedButton(onPressed: cart.isEmpty ? null : onClear, child: const Text('Clear cart'))), const SizedBox(width: 8), Expanded(child: FilledButton(onPressed: cart.isEmpty ? null : onCheckout, child: const Text('Checkout')))])])));
}
