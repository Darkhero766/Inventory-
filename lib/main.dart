import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'data/database.dart';
import 'models/models.dart';
import 'theme/app_theme.dart';

String money(num value) => NumberFormat.currency(locale: 'en_IN', symbol: '₹', decimalDigits: 0).format(value);

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await AppDatabase.instance.db;
  runApp(const InventoryApp());
}

class InventoryApp extends StatelessWidget {
  const InventoryApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Inventory',
      theme: AppTheme.light(),
      home: const AppShell(),
    );
  }
}

class AppShell extends StatefulWidget {
  const AppShell({super.key});
  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int index = 0;
  final pages = const [HomePage(), InventoryPage(), PurchasesPage(), SalesPage(), MorePage()];
  final labels = const ['Home', 'Inventory', 'Purchases', 'Sales', 'More'];
  final icons = const [Icons.home_outlined, Icons.inventory_2_outlined, Icons.local_shipping_outlined, Icons.point_of_sale_outlined, Icons.more_horiz];

  @override
  Widget build(BuildContext context) {
    final wide = MediaQuery.sizeOf(context).width >= 900;
    return Scaffold(
      body: wide
          ? Row(children: [
              NavigationRail(
                selectedIndex: index,
                onDestinationSelected: (value) => setState(() => index = value),
                labelType: NavigationRailLabelType.all,
                leading: const Padding(padding: EdgeInsets.all(20), child: Text('INVENTORY', style: TextStyle(fontWeight: FontWeight.w900, color: AppTheme.blue))),
                destinations: [for (var i = 0; i < labels.length; i++) NavigationRailDestination(icon: Icon(icons[i]), label: Text(labels[i]))],
              ),
              const VerticalDivider(width: 1),
              Expanded(child: pages[index]),
            ])
          : pages[index],
      bottomNavigationBar: wide
          ? null
          : NavigationBar(
              selectedIndex: index,
              onDestinationSelected: (value) => setState(() => index = value),
              destinations: [for (var i = 0; i < labels.length; i++) NavigationDestination(icon: Icon(icons[i]), label: labels[i])],
            ),
    );
  }
}

class PageFrame extends StatelessWidget {
  final Widget child;
  const PageFrame({super.key, required this.child});
  @override
  Widget build(BuildContext context) => SafeArea(child: Center(child: ConstrainedBox(constraints: const BoxConstraints(maxWidth: 1450), child: Padding(padding: const EdgeInsets.all(22), child: child))));
}

class SearchField extends StatelessWidget {
  final ValueChanged<String>? onChanged;
  const SearchField({super.key, this.onChanged});
  @override
  Widget build(BuildContext context) => TextField(onChanged: onChanged, decoration: const InputDecoration(prefixIcon: Icon(Icons.search), hintText: 'Search products, brands, models, SKU or barcode'));
}

class StatusBadge extends StatelessWidget {
  final String status;
  const StatusBadge(this.status, {super.key});
  @override
  Widget build(BuildContext context) {
    final color = status == 'IN STOCK' ? AppTheme.green : status == 'LOW STOCK' ? AppTheme.amber : AppTheme.red;
    return Container(padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5), decoration: BoxDecoration(color: color.withValues(alpha: .1), borderRadius: BorderRadius.circular(20)), child: Text(status, style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.w800)));
  }
}

class SectionTitle extends StatelessWidget {
  final String text;
  const SectionTitle(this.text, {super.key});
  @override
  Widget build(BuildContext context) => Text(text, style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800));
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Product> products = [];
  double sales = 0;
  double purchases = 0;
  double inventoryValue = 0;
  int lowStock = 0;

  @override
  void initState() {
    super.initState();
    load();
  }

  Future<void> load() async {
    final database = await AppDatabase.instance.db;
    final list = await AppDatabase.instance.products();
    final saleRows = await database.rawQuery('SELECT COALESCE(SUM(total),0) AS value FROM sales');
    final purchaseRows = await database.rawQuery('SELECT COALESCE(SUM(total),0) AS value FROM purchases');
    if (!mounted) return;
    setState(() {
      products = list;
      sales = (saleRows.first['value'] as num?)?.toDouble() ?? 0;
      purchases = (purchaseRows.first['value'] as num?)?.toDouble() ?? 0;
      inventoryValue = list.fold<double>(0, (sum, p) => sum + p.quantity * p.purchasePrice);
      lowStock = list.where((p) => p.quantity <= p.minimumStock).length;
    });
  }

  @override
  Widget build(BuildContext context) {
    final categories = const ['Mobile Phones', 'Laptops', 'Televisions', 'Refrigerators', 'Air Conditioners', 'Washing Machines', 'Audio', 'Cameras', 'Printers', 'Networking', 'Storage', 'Accessories'];
    final low = products.where((p) => p.quantity <= p.minimumStock).take(5).toList();
    return PageFrame(child: RefreshIndicator(onRefresh: load, child: ListView(children: [
      Row(children: [Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('Good morning', style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w900)), const Text('ElectroMart Electronics', style: TextStyle(color: AppTheme.muted))])), const Icon(Icons.notifications_none)]),
      const SizedBox(height: 18),
      SearchField(onChanged: (q) { if (q.trim().isNotEmpty) Navigator.push(context, MaterialPageRoute(builder: (_) => InventoryPage(query: q.trim()))); }),
      const SizedBox(height: 26),
      const SectionTitle('Categories'), const SizedBox(height: 12),
      SizedBox(height: 112, child: ListView(scrollDirection: Axis.horizontal, children: [for (final category in categories) Padding(padding: const EdgeInsets.only(right: 10), child: InkWell(onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => InventoryPage(category: category))), borderRadius: BorderRadius.circular(18), child: Container(width: 140, padding: const EdgeInsets.all(14), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(18), border: Border.all(color: const Color(0xffe9ebef))), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Icon(categoryIcon(category), color: AppTheme.blue, size: 30), const Spacer(), Text(category, maxLines: 2, style: const TextStyle(fontWeight: FontWeight.w700))]))))]),
      const SizedBox(height: 26), const SectionTitle('Business snapshot'), const SizedBox(height: 12),
      Wrap(spacing: 12, runSpacing: 12, children: [MetricCard('Sales', money(sales), Icons.point_of_sale_outlined), MetricCard('Purchases', money(purchases), Icons.local_shipping_outlined), MetricCard('Inventory value', money(inventoryValue), Icons.inventory_2_outlined), MetricCard('Low stock', '$lowStock items', Icons.warning_amber_outlined)]),
      const SizedBox(height: 28),
      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [const SectionTitle('Low stock'), TextButton(onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const InventoryPage(lowOnly: true))), child: const Text('View all'))]),
      ...low.map((p) => Card(child: ListTile(leading: CircleAvatar(child: Icon(categoryIcon(p.category))), title: Text('${p.brand} · ${p.name}'), subtitle: Text('${p.quantity} units left · ${p.sku}'), trailing: StatusBadge(p.status), onTap: () => productDetails(context, p, load)))),
      const SizedBox(height: 24), const SectionTitle('Top products'), const SizedBox(height: 12),
      SizedBox(height: 220, child: ListView.separated(scrollDirection: Axis.horizontal, itemCount: products.length > 10 ? 10 : products.length, separatorBuilder: (_, __) => const SizedBox(width: 12), itemBuilder: (_, i) => ProductCard(products[i], width: 205, onTap: () => productDetails(context, products[i], load)))),
    ])));
  }
}

class MetricCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  const MetricCard(this.title, this.value, this.icon, {super.key});
  @override
  Widget build(BuildContext context) => SizedBox(width: 220, child: Card(child: Padding(padding: const EdgeInsets.all(16), child: Row(children: [Icon(icon, color: AppTheme.blue, size: 30), const SizedBox(width: 12), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(title, style: const TextStyle(fontSize: 12, color: AppTheme.muted)), const SizedBox(height: 5), Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900))]))])));
}

class InventoryPage extends StatefulWidget {
  final String? query;
  final String? category;
  final bool lowOnly;
  const InventoryPage({super.key, this.query, this.category, this.lowOnly = false});
  @override
  State<InventoryPage> createState() => _InventoryPageState();
}

class _InventoryPageState extends State<InventoryPage> {
  List<Product> items = [];
  String query = '';
  bool loading = true;
  @override
  void initState() { super.initState(); query = widget.query ?? ''; load(); }
  Future<void> load() async {
    setState(() => loading = true);
    final result = await AppDatabase.instance.products(query: query, category: widget.category);
    if (!mounted) return;
    setState(() { items = widget.lowOnly ? result.where((p) => p.quantity <= p.minimumStock).toList() : result; loading = false; });
  }
  @override
  Widget build(BuildContext context) => PageFrame(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    Row(children: [Expanded(child: Text(widget.category ?? (widget.lowOnly ? 'Low Stock' : 'Inventory'), style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w900))), FilledButton.icon(onPressed: () => productForm(context, onSaved: load), icon: const Icon(Icons.add), label: const Text('Add Product'))]),
    const SizedBox(height: 6), Text('${items.length} products', style: const TextStyle(color: AppTheme.muted)), const SizedBox(height: 14),
    SearchField(onChanged: (value) { query = value; load(); }), const SizedBox(height: 12),
    Expanded(child: loading ? const Center(child: CircularProgressIndicator()) : items.isEmpty ? const EmptyState(title: 'No products found', message: 'Try another search or filter.') : LayoutBuilder(builder: (_, constraints) { final columns = constraints.maxWidth >= 1200 ? 4 : constraints.maxWidth >= 800 ? 3 : 2; return GridView.builder(itemCount: items.length, gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: columns, crossAxisSpacing: 14, mainAxisSpacing: 14, childAspectRatio: .73), itemBuilder: (_, i) => ProductCard(items[i], onTap: () => productDetails(context, items[i], load))); }))
  ]));
}

class ProductCard extends StatelessWidget {
  final Product product;
  final double? width;
  final VoidCallback? onTap;
  const ProductCard(this.product, {super.key, this.width, this.onTap});
  @override
  Widget build(BuildContext context) => SizedBox(width: width, child: Card(child: InkWell(onTap: onTap, borderRadius: BorderRadius.circular(18), child: Padding(padding: const EdgeInsets.all(10), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Expanded(child: Container(width: double.infinity, decoration: BoxDecoration(color: AppTheme.bg, borderRadius: BorderRadius.circular(14)), child: Icon(categoryIcon(product.category), size: 64, color: AppTheme.blue))), const SizedBox(height: 8), Text(product.brand, style: const TextStyle(fontSize: 12, color: AppTheme.muted)), Text(product.name, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.w700)), const SizedBox(height: 5), Text(money(product.sellingPrice), style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w900)), const SizedBox(height: 5), Row(children: [StatusBadge(product.status), const Spacer(), Text('${product.quantity} left', style: const TextStyle(fontSize: 11, color: AppTheme.muted))])]))));
}

Future<void> productDetails(BuildContext context, Product product, VoidCallback refresh) async {
  await showModalBottomSheet<void>(context: context, isScrollControlled: true, showDragHandle: true, builder: (_) => Padding(padding: const EdgeInsets.all(22), child: Wrap(children: [
    Row(children: [Expanded(child: Text(product.name, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900))), StatusBadge(product.status)]),
    Text('${product.brand} · ${product.category}', style: const TextStyle(color: AppTheme.muted)), const SizedBox(height: 15),
    Container(height: 170, width: double.infinity, decoration: BoxDecoration(color: AppTheme.bg, borderRadius: BorderRadius.circular(20)), child: Icon(categoryIcon(product.category), size: 80, color: AppTheme.blue)),
    const SizedBox(height: 15), Text(money(product.sellingPrice), style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w900)),
    Text('Cost ${money(product.purchasePrice)}  •  Profit ${money(product.profit)}  •  Margin ${product.margin.toStringAsFixed(1)}%'),
    const SizedBox(height: 12), Wrap(spacing: 8, runSpacing: 8, children: [Chip(label: Text('Stock ${product.quantity}')), Chip(label: Text('Min ${product.minimumStock}')), Chip(label: Text('SKU ${product.sku}')), Chip(label: Text('Model ${product.model}'))]),
    const SizedBox(height: 12), Row(children: [Expanded(child: OutlinedButton.icon(onPressed: () => adjustStock(context, product, refresh), icon: const Icon(Icons.inventory_2_outlined), label: const Text('Adjust Stock'))), const SizedBox(width: 8), Expanded(child: FilledButton.icon(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.point_of_sale), label: const Text('Sell'))]),
    TextButton.icon(onPressed: () => productForm(context, product: product, onSaved: refresh), icon: const Icon(Icons.edit_outlined), label: const Text('Edit product')),
    ExpansionTile(title: const Text('Stock history'), children: [FutureBuilder<List<Map<String, Object?>>>(future: AppDatabase.instance.movements(product.id!), builder: (_, snapshot) { final rows = snapshot.data ?? []; return Column(children: [for (final row in rows.take(20)) ListTile(title: Text('${row['type']} · ${row['quantity']}'), subtitle: Text('${row['note'] ?? ''}'))]); })]),
  ]));
}

Future<void> adjustStock(BuildContext context, Product product, VoidCallback refresh) async {
  final quantity = TextEditingController();
  final reason = TextEditingController();
  final ok = await showDialog<bool>(context: context, builder: (_) => AlertDialog(title: const Text('Adjust stock'), content: Column(mainAxisSize: MainAxisSize.min, children: [Text('Current stock: ${product.quantity}'), TextField(controller: quantity, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Quantity change', hintText: '+5 or -1')), TextField(controller: reason, decoration: const InputDecoration(labelText: 'Reason'))]), actions: [TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')), FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('Save'))]));
  if (ok != true) return;
  try { await AppDatabase.instance.adjustStock(product, int.tryParse(quantity.text) ?? 0, reason.text.isEmpty ? 'Stock adjustment' : reason.text); refresh(); } catch (error) { if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error.toString()))); }
}

Future<void> productForm(BuildContext context, {Product? product, VoidCallback? onSaved}) async {
  final fields = <String, TextEditingController>{};
  for (final key in ['name', 'brand', 'category', 'model', 'sku', 'barcode', 'purchase', 'selling', 'mrp', 'quantity', 'minimum']) fields[key] = TextEditingController();
  fields['name']!.text = product?.name ?? ''; fields['brand']!.text = product?.brand ?? ''; fields['category']!.text = product?.category ?? ''; fields['model']!.text = product?.model ?? ''; fields['sku']!.text = product?.sku ?? ''; fields['barcode']!.text = product?.barcode ?? '';
  fields['purchase']!.text = product?.purchasePrice.toString() ?? ''; fields['selling']!.text = product?.sellingPrice.toString() ?? ''; fields['mrp']!.text = product?.mrp.toString() ?? ''; fields['quantity']!.text = product?.quantity.toString() ?? '0'; fields['minimum']!.text = product?.minimumStock.toString() ?? '2';
  final saved = await showDialog<bool>(context: context, builder: (_) => AlertDialog(title: Text(product == null ? 'Add product' : 'Edit product'), content: SizedBox(width: 520, child: SingleChildScrollView(child: Column(children: [for (final key in fields.keys) Padding(padding: const EdgeInsets.only(bottom: 8), child: TextField(controller: fields[key], keyboardType: ['purchase', 'selling', 'mrp', 'quantity', 'minimum'].contains(key) ? TextInputType.number : TextInputType.text, decoration: InputDecoration(labelText: key[0].toUpperCase() + key.substring(1)))]))), actions: [TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')), FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('Save'))]));
  if (saved != true) return;
  final values = <String, Object?>{'name': fields['name']!.text.trim(), 'brand': fields['brand']!.text.trim(), 'category': fields['category']!.text.trim(), 'model': fields['model']!.text.trim(), 'sku': fields['sku']!.text.trim(), 'barcode': fields['barcode']!.text.trim(), 'purchase_price': double.tryParse(fields['purchase']!.text) ?? 0, 'selling_price': double.tryParse(fields['selling']!.text) ?? 0, 'mrp': double.tryParse(fields['mrp']!.text) ?? 0, 'quantity': int.tryParse(fields['quantity']!.text) ?? 0, 'minimum_stock': int.tryParse(fields['minimum']!.text) ?? 2, 'supplier': product?.supplier ?? '', 'warranty': product?.warranty ?? '1 Year', 'specs': product?.specs ?? ''};
  try { if (product == null) { await AppDatabase.instance.addProduct(values); } else { await AppDatabase.instance.updateProduct(product.id!, values); } onSaved?.call(); } catch (error) { if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error.toString()))); }
}

class PurchasesPage extends StatelessWidget {
  const PurchasesPage({super.key});
  @override
  Widget build(BuildContext context) => SimpleModulePage(title: 'Purchases', icon: Icons.local_shipping_outlined, description: 'Purchase history, suppliers and incoming stock are stored offline.');
}

class SalesPage extends StatelessWidget {
  const SalesPage({super.key});
  @override
  Widget build(BuildContext context) => SimpleModulePage(title: 'Sales & POS', icon: Icons.point_of_sale_outlined, description: 'Fast checkout, cart and sales workflows are ready for the next module pass.');
}

class MorePage extends StatelessWidget {
  const MorePage({super.key});
  @override
  Widget build(BuildContext context) => PageFrame(child: ListView(children: [Text('More', style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w900)), const SizedBox(height: 18), for (final item in const [('Customers', Icons.people_outline), ('Suppliers', Icons.business_outlined), ('Expenses', Icons.receipt_long_outlined), ('Reports', Icons.bar_chart_outlined), ('Monthly Books', Icons.calendar_month_outlined), ('Warranty', Icons.verified_outlined), ('Dead Stock', Icons.hourglass_empty_outlined), ('Backup & Restore', Icons.backup_outlined), ('Settings', Icons.settings_outlined)]) Card(child: ListTile(leading: Icon(item.$2, color: AppTheme.blue), title: Text(item.$1), trailing: const Icon(Icons.chevron_right)))]));
}

class SimpleModulePage extends StatelessWidget {
  final String title;
  final IconData icon;
  final String description;
  const SimpleModulePage({super.key, required this.title, required this.icon, required this.description});
  @override
  Widget build(BuildContext context) => PageFrame(child: Center(child: Card(child: Padding(padding: const EdgeInsets.all(30), child: Column(mainAxisSize: MainAxisSize.min, children: [Icon(icon, size: 56, color: AppTheme.blue), const SizedBox(height: 14), Text(title, style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w900)), const SizedBox(height: 8), Text(description, textAlign: TextAlign.center, style: const TextStyle(color: AppTheme.muted))]))));
}

class EmptyState extends StatelessWidget {
  final String title;
  final String message;
  const EmptyState({super.key, required this.title, required this.message});
  @override
  Widget build(BuildContext context) => Center(child: Padding(padding: const EdgeInsets.all(30), child: Column(mainAxisSize: MainAxisSize.min, children: [const Icon(Icons.inventory_2_outlined, size: 52, color: AppTheme.muted), const SizedBox(height: 12), Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800)), const SizedBox(height: 6), Text(message, textAlign: TextAlign.center, style: const TextStyle(color: AppTheme.muted))])));
}

IconData categoryIcon(String category) {
  final value = category.toLowerCase();
  if (value.contains('mobile')) return Icons.smartphone;
  if (value.contains('laptop')) return Icons.laptop_mac;
  if (value.contains('television')) return Icons.tv;
  if (value.contains('refrigerator')) return Icons.kitchen;
  if (value.contains('conditioner')) return Icons.ac_unit;
  if (value.contains('washing')) return Icons.local_laundry_service;
  if (value.contains('audio')) return Icons.headphones;
  if (value.contains('camera')) return Icons.camera_alt;
  if (value.contains('printer')) return Icons.print;
  if (value.contains('network')) return Icons.router;
  if (value.contains('storage')) return Icons.storage;
  return Icons.devices_other;
}
