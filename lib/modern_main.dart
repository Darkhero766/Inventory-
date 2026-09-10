import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'data/database.dart';
import 'models/models.dart';
import 'services/product_catalog_service.dart';

const _blue = Color(0xFF4B63E6);
const _purple = Color(0xFF7659F6);
const _green = Color(0xFF18A56B);
const _orange = Color(0xFFE28A19);
const _red = Color(0xFFE05252);
const _ink = Color(0xFF171923);
const _muted = Color(0xFF747783);
const _bg = Color(0xFFF5F6FA);

String money(num value) => NumberFormat.currency(locale: 'en_IN', symbol: '₹', decimalDigits: 0).format(value);

void main() => runApp(const InventoryModernApp());

class InventoryModernApp extends StatelessWidget {
  const InventoryModernApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Inventory POS',
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: _bg,
        colorScheme: ColorScheme.fromSeed(seedColor: _blue),
        fontFamily: 'Inter',
        cardTheme: CardThemeData(elevation: 0, color: Colors.white, margin: EdgeInsets.zero, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22))),
        navigationBarTheme: NavigationBarThemeData(height: 76, backgroundColor: Colors.white, indicatorColor: _blue.withAlpha(22), labelTextStyle: const WidgetStatePropertyAll(TextStyle(fontWeight: FontWeight.w800, fontSize: 12))),
        inputDecorationTheme: InputDecorationTheme(
          filled: true, fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(17), borderSide: BorderSide.none),
          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(17), borderSide: BorderSide.none),
          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(17), borderSide: const BorderSide(color: _blue, width: 1.2)),
        ),
      ),
      home: const ModernShell(),
    );
  }
}

class ModernShell extends StatefulWidget {
  const ModernShell({super.key});
  @override
  State<ModernShell> createState() => _ModernShellState();
}

class _ModernShellState extends State<ModernShell> {
  int tab = 0;
  static const labels = ['Home', 'Inventory', 'Purchases', 'Sales', 'More'];
  static const icons = [Icons.home_rounded, Icons.inventory_2_rounded, Icons.shopping_bag_rounded, Icons.point_of_sale_rounded, Icons.more_horiz_rounded];

  void go(int value) => setState(() => tab = value);

  @override
  Widget build(BuildContext context) {
    final pages = <Widget>[
      ModernHome(onInventory: () => go(1), onSales: () => go(3)),
      const ModernInventory(),
      const ModernPurchases(),
      const ModernSales(),
      const ModernMore(),
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
                  const SizedBox(height: 26),
                  Expanded(child: NavigationRail(
                    extended: true, minExtendedWidth: 198,
                    selectedIndex: tab,
                    onDestinationSelected: go,
                    destinations: [for (var i = 0; i < labels.length; i++) NavigationRailDestination(icon: Icon(icons[i]), selectedIcon: Icon(icons[i]), label: Text(labels[i]))],
                  )),
                  const Text('ElectroMart • Main Store', style: TextStyle(color: _muted, fontSize: 10)),
                ]),
              ),
              const VerticalDivider(width: 1),
              Expanded(child: pages[tab]),
            ])
          : pages[tab],
      bottomNavigationBar: wide ? null : NavigationBar(selectedIndex: tab, onDestinationSelected: go, destinations: [for (var i = 0; i < labels.length; i++) NavigationDestination(icon: Icon(icons[i]), label: labels[i])]),
    );
  }
}

class _Brand extends StatelessWidget {
  const _Brand();
  @override
  Widget build(BuildContext context) => Row(children: [
    Container(width: 40, height: 40, decoration: BoxDecoration(gradient: const LinearGradient(colors: [_blue, _purple]), borderRadius: BorderRadius.circular(13)), child: const Icon(Icons.bolt_rounded, color: Colors.white)),
    const SizedBox(width: 10),
    const Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('INVENTORY', style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1)), Text('ElectroMart POS', style: TextStyle(color: _muted, fontSize: 10))]),
  ]);
}

class _Page extends StatelessWidget {
  final Widget child;
  const _Page({required this.child});
  @override
  Widget build(BuildContext context) => SafeArea(child: Center(child: ConstrainedBox(constraints: const BoxConstraints(maxWidth: 1440), child: Padding(padding: const EdgeInsets.fromLTRB(20, 18, 20, 22), child: child))));
}

class _Header extends StatelessWidget {
  final String title, subtitle;
  final Widget? action;
  const _Header(this.title, this.subtitle, {this.action});
  @override
  Widget build(BuildContext context) => LayoutBuilder(builder: (_, c) {
    final heading = Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(title, style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w900, color: _ink, letterSpacing: -.8)), const SizedBox(height: 3), Text(subtitle, style: const TextStyle(color: _muted))]);
    if (action == null) return heading;
    if (c.maxWidth < 620) return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [heading, const SizedBox(height: 12), action!]);
    return Row(children: [Expanded(child: heading), action!]);
  });
}

class _Search extends StatelessWidget {
  final String hint;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onScan;
  const _Search({required this.hint, this.onChanged, this.onScan});
  @override
  Widget build(BuildContext context) => TextField(onChanged: onChanged, textInputAction: TextInputAction.search, decoration: InputDecoration(prefixIcon: const Icon(Icons.search_rounded), hintText: hint, suffixIcon: onScan == null ? null : IconButton(tooltip: 'Barcode / SKU', onPressed: onScan, icon: const Icon(Icons.qr_code_scanner_rounded))));
}

class ModernHome extends StatefulWidget {
  final VoidCallback onInventory, onSales;
  const ModernHome({super.key, required this.onInventory, required this.onSales});
  @override
  State<ModernHome> createState() => _ModernHomeState();
}

class _ModernHomeState extends State<ModernHome> {
  List<Product> products = [];
  Map<String, num> stats = {};
  bool loading = true;
  @override
  void initState() { super.initState(); _load(); }
  Future<void> _load() async {
    try { final p = await AppDatabase.instance.products(); final s = await AppDatabase.instance.snapshot(); if (mounted) setState(() { products = p; stats = s; loading = false; }); }
    catch (_) { if (mounted) setState(() => loading = false); }
  }
  @override
  Widget build(BuildContext context) {
    final low = products.where((p) => p.quantity <= p.minimumStock).take(4).toList();
    return _Page(child: RefreshIndicator(onRefresh: _load, child: ListView(physics: const AlwaysScrollableScrollPhysics(), children: [
      Row(children: [const Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('Good morning', style: TextStyle(fontSize: 30, fontWeight: FontWeight.w900, color: _ink, letterSpacing: -1)), SizedBox(height: 4), Text('Run your shop from one fast workspace.', style: TextStyle(color: _muted))])), if (MediaQuery.sizeOf(context).width > 650) const _StorePill()]),
      const SizedBox(height: 18),
      _QuickActions(onInventory: widget.onInventory, onSales: widget.onSales),
      const SizedBox(height: 22),
      const Text('Business snapshot', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900)),
      const SizedBox(height: 10),
      LayoutBuilder(builder: (_, c) { final cols = c.maxWidth >= 1050 ? 4 : c.maxWidth >= 600 ? 2 : 1; final w = (c.maxWidth - (cols - 1) * 12) / cols; return Wrap(spacing: 12, runSpacing: 12, children: [SizedBox(width: w, child: _Metric('Today sales', money(stats['sales'] ?? 0), Icons.trending_up_rounded, _green)), SizedBox(width: w, child: _Metric('Purchases', money(stats['purchases'] ?? 0), Icons.shopping_bag_outlined, _purple)), SizedBox(width: w, child: _Metric('Inventory value', money(stats['inventory'] ?? 0), Icons.inventory_2_outlined, _blue, note: '${products.length} products')), SizedBox(width: w, child: _Metric('Low stock', '${stats['low'] ?? 0}', Icons.warning_amber_rounded, _orange, note: 'Needs attention'))]); }),
      const SizedBox(height: 24),
      const Text('Low stock', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900)),
      const SizedBox(height: 10),
      if (low.isEmpty) const _Empty(title: 'Stock looks healthy', subtitle: 'No products need attention right now.', icon: Icons.check_circle_outline_rounded) else ...[for (final p in low) _Low(p)],
      const SizedBox(height: 24),
      Row(children: [const Expanded(child: Text('Products', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900))), TextButton(onPressed: widget.onInventory, child: const Text('View inventory'))]),
      const SizedBox(height: 8),
      if (loading) const LinearProgressIndicator(minHeight: 2) else SizedBox(height: 245, child: products.isEmpty ? const _Empty(title: 'No products yet', subtitle: 'Add your first product from Inventory.', icon: Icons.devices_other_rounded) : ListView.separated(scrollDirection: Axis.horizontal, itemCount: products.length > 8 ? 8 : products.length, separatorBuilder: (_, __) => const SizedBox(width: 12), itemBuilder: (_, i) => SizedBox(width: 205, child: _ProductCard(products[i])))),
    ])));
  }
}

class _StorePill extends StatelessWidget { const _StorePill(); @override Widget build(BuildContext context) => Container(padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 10), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(15)), child: const Row(children: [Icon(Icons.storefront_rounded, size: 18, color: _blue), SizedBox(width: 8), Text('Main Store', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 12))])); }

class _QuickActions extends StatelessWidget {
  final VoidCallback onInventory, onSales;
  const _QuickActions({required this.onInventory, required this.onSales});
  @override
  Widget build(BuildContext context) => Row(children: [Expanded(child: _Action(label: 'New sale', icon: Icons.point_of_sale_rounded, color: _blue, onTap: onSales)), const SizedBox(width: 10), Expanded(child: _Action(label: 'Add product', icon: Icons.add_box_rounded, color: _purple, onTap: onInventory))]);
}

class _Action extends StatelessWidget { final String label; final IconData icon; final Color color; final VoidCallback onTap; const _Action({required this.label, required this.icon, required this.color, required this.onTap}); @override Widget build(BuildContext context) => Material(color: Colors.white, borderRadius: BorderRadius.circular(19), child: InkWell(borderRadius: BorderRadius.circular(19), onTap: onTap, child: Padding(padding: const EdgeInsets.all(15), child: Row(children: [Container(width: 38, height: 38, decoration: BoxDecoration(color: color.withAlpha(18), borderRadius: BorderRadius.circular(12)), child: Icon(icon, color: color, size: 20)), const SizedBox(width: 10), Expanded(child: Text(label, style: const TextStyle(fontWeight: FontWeight.w900))), const Icon(Icons.arrow_forward_rounded, size: 18, color: _muted)])))); }

class _Metric extends StatelessWidget { final String label, value; final String? note; final IconData icon; final Color color; const _Metric(this.label, this.value, this.icon, this.color, {this.note}); @override Widget build(BuildContext context) => Card(child: Padding(padding: const EdgeInsets.all(16), child: Row(children: [Container(width: 42, height: 42, decoration: BoxDecoration(color: color.withAlpha(18), borderRadius: BorderRadius.circular(13)), child: Icon(icon, color: color)), const SizedBox(width: 12), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(label, style: const TextStyle(color: _muted, fontSize: 12)), const SizedBox(height: 3), Text(value, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900)), if (note != null) Text(note!, style: const TextStyle(color: _muted, fontSize: 11))]))]))); }

class _Low extends StatelessWidget { final Product p; const _Low(this.p); @override Widget build(BuildContext context) => Card(margin: const EdgeInsets.only(bottom: 8), child: ListTile(contentPadding: const EdgeInsets.symmetric(horizontal: 13, vertical: 3), leading: ProductImage(product: p, size: 48, radius: 14), title: Text('${p.brand} · ${p.name}', maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13)), subtitle: Text('${p.quantity} left • ${p.sku}', style: const TextStyle(fontSize: 11)), trailing: _Badge(p.status))); }

class _Empty extends StatelessWidget { final String title, subtitle; final IconData icon; const _Empty({required this.title, required this.subtitle, required this.icon}); @override Widget build(BuildContext context) => Card(child: Padding(padding: const EdgeInsets.all(22), child: Row(children: [Container(width: 46, height: 46, decoration: BoxDecoration(color: _bg, borderRadius: BorderRadius.circular(14)), child: Icon(icon, color: _muted)), const SizedBox(width: 13), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(title, style: const TextStyle(fontWeight: FontWeight.w900)), const SizedBox(height: 3), Text(subtitle, style: const TextStyle(color: _muted, fontSize: 12))]))]))); }

class _Badge extends StatelessWidget { final String value; const _Badge(this.value); @override Widget build(BuildContext context) { final c = value == 'IN STOCK' ? _green : value == 'LOW STOCK' ? _orange : _red; return Container(padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6), decoration: BoxDecoration(color: c.withAlpha(18), borderRadius: BorderRadius.circular(30)), child: Text(value, style: TextStyle(color: c, fontSize: 9, fontWeight: FontWeight.w900))); } }

class ProductImage extends StatefulWidget {
  final Product product; final double size, radius;
  const ProductImage({super.key, required this.product, this.size = 120, this.radius = 18});
  @override State<ProductImage> createState() => _ProductImageState();
}
class _ProductImageState extends State<ProductImage> {
  String? url;
  @override void initState() { super.initState(); url = widget.product.imageUrl.trim().isEmpty ? null : widget.product.imageUrl.trim(); if (url == null) _find(); }
  Future<void> _find() async { final found = await ProductCatalogService.findImage('${widget.product.brand} ${widget.product.name} ${widget.product.model}', brand: widget.product.brand, category: widget.product.category); if (mounted && found != null) setState(() => url = found); }
  @override Widget build(BuildContext context) { final fallback = Container(width: widget.size, height: widget.size, decoration: BoxDecoration(color: const Color(0xFFF1F3F8), borderRadius: BorderRadius.circular(widget.radius)), child: Icon(_categoryIcon(widget.product.category), size: widget.size * .32, color: _ink)); if (url == null) return fallback; return ClipRRect(borderRadius: BorderRadius.circular(widget.radius), child: Image.network(url!, width: widget.size, height: widget.size, fit: BoxFit.contain, errorBuilder: (_, __, ___) => fallback, loadingBuilder: (_, child, progress) => progress == null ? child : fallback)); }
}

class _ProductCard extends StatelessWidget { final Product p; final VoidCallback? onTap; const _ProductCard(this.p, {this.onTap}); @override Widget build(BuildContext context) => Card(clipBehavior: Clip.antiAlias, child: InkWell(onTap: onTap, child: Padding(padding: const EdgeInsets.all(10), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Expanded(child: ProductImage(product: p, size: 180, radius: 16)), const SizedBox(height: 9), Text(p.brand, style: const TextStyle(color: _muted, fontSize: 11)), Text(p.name, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 14)), const SizedBox(height: 5), Text(money(p.sellingPrice), style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16))])))); }

class ModernInventory extends StatefulWidget { const ModernInventory({super.key}); @override State<ModernInventory> createState() => _ModernInventoryState(); }
class _ModernInventoryState extends State<ModernInventory> {
  List<Product> products = []; String query = ''; bool loading = true;
  @override void initState() { super.initState(); _load(); }
  Future<void> _load() async { try { final r = await AppDatabase.instance.products(query: query); if (mounted) setState(() { products = r; loading = false; }); } catch (_) { if (mounted) setState(() { products = []; loading = false; }); } }
  @override Widget build(BuildContext context) => _Page(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    _Header('Inventory', '${products.length} products in your catalog', action: FilledButton.icon(onPressed: () => _addProduct(context), icon: const Icon(Icons.add_rounded), label: const Text('Add product'))),
    const SizedBox(height: 15),
    _Search(hint: 'Search product, brand, model, SKU or barcode', onChanged: (v) { query = v; _load(); }, onScan: () => _skuDialog(context)),
    const SizedBox(height: 13),
    Expanded(child: loading ? const Center(child: CircularProgressIndicator()) : products.isEmpty ? const _Empty(title: 'No products found', subtitle: 'Try another search or add a product.', icon: Icons.inventory_2_outlined) : LayoutBuilder(builder: (_, c) { final cols = c.maxWidth >= 1200 ? 4 : c.maxWidth >= 760 ? 3 : 2; return GridView.builder(itemCount: products.length, gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: cols, crossAxisSpacing: 12, mainAxisSpacing: 12, childAspectRatio: .76), itemBuilder: (_, i) => _ProductCard(products[i], onTap: () => _details(context, products[i]))); })),
  ]));

  Future<void> _skuDialog(BuildContext context) async { final c = TextEditingController(); final value = await showDialog<String>(context: context, builder: (_) => AlertDialog(title: const Text('Find by SKU / barcode'), content: TextField(controller: c, autofocus: true, decoration: const InputDecoration(labelText: 'SKU or barcode')), actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')), FilledButton(onPressed: () => Navigator.pop(context, c.text.trim()), child: const Text('Find'))])); c.dispose(); if (value != null && value.isNotEmpty) { query = value; _load(); } }

  Future<void> _details(BuildContext context, Product p) async { await showModalBottomSheet<void>(context: context, isScrollControlled: true, showDragHandle: true, builder: (_) => SafeArea(child: Padding(padding: const EdgeInsets.fromLTRB(20, 0, 20, 24), child: Column(mainAxisSize: MainAxisSize.min, children: [Row(children: [ProductImage(product: p, size: 76, radius: 18), const SizedBox(width: 13), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(p.name, style: const TextStyle(fontSize: 19, fontWeight: FontWeight.w900)), Text('${p.brand} • ${p.sku}', style: const TextStyle(color: _muted, fontSize: 12))])), _Badge(p.status)]), const SizedBox(height: 18), Row(children: [Expanded(child: _SmallStat('Selling', money(p.sellingPrice))), Expanded(child: _SmallStat('Purchase', money(p.purchasePrice))), Expanded(child: _SmallStat('Stock', '${p.quantity}'))]), const SizedBox(height: 16), Row(children: [Expanded(child: OutlinedButton.icon(onPressed: () async { Navigator.pop(context); await AppDatabase.instance.adjustStock(p.id, 1, 'ADJUSTMENT', 'Manual stock addition'); _load(); }, icon: const Icon(Icons.add), label: const Text('Add stock'))), const SizedBox(width: 10), Expanded(child: FilledButton.icon(onPressed: p.quantity == 0 ? null : () async { Navigator.pop(context); await AppDatabase.instance.adjustStock(p.id, -1, 'ADJUSTMENT', 'Manual stock removal'); _load(); }, icon: const Icon(Icons.remove), label: const Text('Remove stock')))])])))); }

  Future<void> _addProduct(BuildContext context) async { final draft = await showDialog<_Draft>(context: context, builder: (_) => const _AddProductDialog()); if (draft == null) return; try { await AppDatabase.instance.addProduct(draft.map); await _load(); if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Product added.'))); } catch (e) { if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Could not add product: $e'))); } }
}

class _SmallStat extends StatelessWidget { final String label, value; const _SmallStat(this.label, this.value); @override Widget build(BuildContext context) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(label, style: const TextStyle(color: _muted, fontSize: 11)), const SizedBox(height: 2), Text(value, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16))]); }

class _Draft {
  final String name, brand, category, model, sku, imageUrl; final double purchase, selling, mrp; final int quantity, minimum;
  const _Draft({required this.name, required this.brand, required this.category, required this.model, required this.sku, required this.imageUrl, required this.purchase, required this.selling, required this.mrp, required this.quantity, required this.minimum});
  Map<String, Object?> get map => {'name': name, 'brand': brand, 'category': category, 'model': model, 'sku': sku, 'barcode': '', 'image_url': imageUrl, 'mrp': mrp, 'selling_price': selling, 'purchase_price': purchase, 'quantity': quantity, 'minimum_stock': minimum, 'supplier': '', 'warranty': '1 Year', 'gst_rate': 18, 'hsn_code': '', 'location': 'Main Store', 'rack': '', 'shelf': '', 'serial_tracking': 0, 'imei_tracking': category == 'Mobile Phones' ? 1 : 0, 'specs': '', 'notes': '', 'archived': 0};
}

class _AddProductDialog extends StatefulWidget { const _AddProductDialog(); @override State<_AddProductDialog> createState() => _AddProductDialogState(); }
class _AddProductDialogState extends State<_AddProductDialog> {
  final form = GlobalKey<FormState>(); final name = TextEditingController(); final model = TextEditingController(); final sku = TextEditingController(text: 'NEW-${DateTime.now().millisecondsSinceEpoch % 100000}'); final purchase = TextEditingController(); final selling = TextEditingController(); final mrp = TextEditingController(); final quantity = TextEditingController(text: '0'); final minimum = TextEditingController(text: '2');
  String brand = 'Samsung', category = 'Mobile Phones', imageUrl = ''; bool searching = false; List<ProductSuggestion> suggestions = const [];
  static const brands = ['Samsung','LG','Sony','Apple','OnePlus','Motorola','Xiaomi','HP','Dell','Lenovo','ASUS','Acer','MSI','Whirlpool','IFB','Bosch','Haier','Voltas','Daikin','Blue Star','JBL','boAt','Bose','Canon','Nikon','Epson','TP-Link','D-Link','Tenda','Logitech','Razer','Kingston','SanDisk','Seagate','Western Digital','Philips','Havells','Bajaj','Crompton','Oppo','Realme'];
  static const categories = ['Mobile Phones','Laptops','Televisions','Refrigerators','Air Conditioners','Washing Machines','Audio','Cameras','Printers','Networking','Storage','Accessories','Monitors','Gaming','Smartwatches','Kitchen Appliances','Fans','Coolers','Projectors','Power & Cables'];
  @override void dispose() { for (final c in [name, model, sku, purchase, selling, mrp, quantity, minimum]) { c.dispose(); } super.dispose(); }
  Future<void> _search(String value) async { if (value.trim().length < 2) { setState(() => suggestions = const []); return; } setState(() => searching = true); final r = await ProductCatalogService.suggest(query: value, brand: brand, category: category); if (mounted) setState(() { suggestions = r; searching = false; }); }
  void _choose(ProductSuggestion s) { name.text = s.title; model.text = s.title; imageUrl = s.imageUrl; setState(() => suggestions = const []); }
  @override Widget build(BuildContext context) => AlertDialog(title: const Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('Add product', style: TextStyle(fontWeight: FontWeight.w900)), SizedBox(height: 3), Text('Pick type + brand, then search for the model.', style: TextStyle(color: _muted, fontSize: 12))]), content: SizedBox(width: 650, child: Form(key: form, child: SingleChildScrollView(child: Column(children: [
    Row(children: [Expanded(child: _drop('Product type', category, categories, (v) => setState(() => category = v!))), const SizedBox(width: 10), Expanded(child: _drop('Brand', brand, brands, (v) => setState(() => brand = v!)))]), const SizedBox(height: 10),
    TextFormField(controller: name, onChanged: _search, validator: (v) => v == null || v.trim().isEmpty ? 'Enter a model' : null, decoration: const InputDecoration(labelText: 'Product / model name', hintText: 'e.g. Galaxy S25 Ultra', prefixIcon: Icon(Icons.auto_awesome_rounded))),
    if (searching) const Padding(padding: EdgeInsets.only(top: 8), child: LinearProgressIndicator(minHeight: 2)),
    if (suggestions.isNotEmpty) Container(margin: const EdgeInsets.only(top: 8, bottom: 8), decoration: BoxDecoration(color: const Color(0xFFF8F9FD), borderRadius: BorderRadius.circular(16)), child: Column(children: [const ListTile(leading: Icon(Icons.language_rounded, color: _blue), title: Text('Relevant product suggestions', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 13)), subtitle: Text('Ranked by brand, category and model match.', style: TextStyle(fontSize: 11))), for (final s in suggestions.take(5)) ListTile(onTap: () => _choose(s), leading: SizedBox(width: 48, height: 48, child: s.imageUrl.isEmpty ? const Icon(Icons.devices_other_rounded) : Image.network(s.imageUrl, fit: BoxFit.contain, errorBuilder: (_, __, ___) => const Icon(Icons.devices_other_rounded))), title: Text(s.title, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.w800)), subtitle: Text(s.description.isEmpty ? '${s.brand} • ${s.category}' : s.description, maxLines: 2, overflow: TextOverflow.ellipsis), trailing: const Icon(Icons.add_circle_outline_rounded, color: _blue))]))),
    Row(children: [Expanded(child: _field(model, 'Model / variant')), const SizedBox(width: 10), Expanded(child: _field(sku, 'SKU'))]),
    if (imageUrl.isNotEmpty) Padding(padding: const EdgeInsets.only(bottom: 10), child: Container(height: 140, width: double.infinity, decoration: BoxDecoration(color: const Color(0xFFF1F3F8), borderRadius: BorderRadius.circular(17)), child: Image.network(imageUrl, fit: BoxFit.contain, errorBuilder: (_, __, ___) => const Icon(Icons.image_not_supported_outlined)))),
    Row(children: [Expanded(child: _field(purchase, 'Purchase price', number: true)), const SizedBox(width: 10), Expanded(child: _field(selling, 'Selling price', number: true))]),
    Row(children: [Expanded(child: _field(mrp, 'MRP', number: true)), const SizedBox(width: 10), Expanded(child: _field(quantity, 'Opening stock', number: true)), const SizedBox(width: 10), Expanded(child: _field(minimum, 'Min. stock', number: true))]),
  ]))), actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')), FilledButton.icon(onPressed: () { if (!form.currentState!.validate()) return; Navigator.pop(context, _Draft(name: name.text.trim(), brand: brand, category: category, model: model.text.trim(), sku: sku.text.trim(), imageUrl: imageUrl, purchase: double.tryParse(purchase.text) ?? 0, selling: double.tryParse(selling.text) ?? 0, mrp: double.tryParse(mrp.text) ?? 0, quantity: int.tryParse(quantity.text) ?? 0, minimum: int.tryParse(minimum.text) ?? 2)); }, icon: const Icon(Icons.check_rounded), label: const Text('Save product'))]);
  Widget _drop(String label, String value, List<String> values, ValueChanged<String?> changed) => DropdownButtonFormField<String>(initialValue: value, isExpanded: true, decoration: InputDecoration(labelText: label), items: [for (final v in values) DropdownMenuItem(value: v, child: Text(v, overflow: TextOverflow.ellipsis))], onChanged: changed);
  Widget _field(TextEditingController c, String label, {bool number = false}) => Padding(padding: const EdgeInsets.only(bottom: 10), child: TextFormField(controller: c, keyboardType: number ? const TextInputType.numberWithOptions(decimal: true) : null, validator: (v) => v == null || v.trim().isEmpty ? 'Required' : null, decoration: InputDecoration(labelText: label)));
}

class ModernSales extends StatefulWidget { const ModernSales({super.key}); @override State<ModernSales> createState() => _ModernSalesState(); }
class _ModernSalesState extends State<ModernSales> {
  List<Product> products = []; String query = ''; final Map<int, int> cart = {}; bool loading = true;
  @override void initState() { super.initState(); _load(); }
  Future<void> _load() async { try { final r = await AppDatabase.instance.products(query: query); if (mounted) setState(() { products = r; loading = false; }); } catch (_) { if (mounted) setState(() { products = []; loading = false; }); } }
  Product? _product(int id) { for (final p in products) { if (p.id == id) return p; } return null; }
  int _qty(Product p) => cart[p.id!] ?? 0;
  double get total { double t = 0; for (final e in cart.entries) { final p = _product(e.key); if (p != null) t += p.sellingPrice * e.value; } return t; }
  void _add(Product p) { final id = p.id; if (id == null || p.quantity <= 0) return; final q = _qty(p); if (q >= p.quantity) { _toast('Only ${p.quantity} available'); return; } setState(() => cart[id] = q + 1); _toast('${p.name} added to cart'); }
  void _minus(Product p) { final id = p.id; if (id == null) return; final q = _qty(p); if (q <= 1) setState(() => cart.remove(id)); else setState(() => cart[id] = q - 1); }
  void _clear() => setState(cart.clear);
  @override Widget build(BuildContext context) { final wide = MediaQuery.sizeOf(context).width >= 980; return _Page(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    const _Header('New sale', 'Find products, build the bill and checkout fast.'), const SizedBox(height: 15),
    _Search(hint: 'Search product, brand, model or SKU', onChanged: (v) { query = v; _load(); }, onScan: () => _scan(context)), const SizedBox(height: 13),
    Expanded(child: wide ? Row(children: [Expanded(child: _grid()), const SizedBox(width: 14), SizedBox(width: 350, child: _cartPanel())]) : Column(children: [Expanded(child: _grid()), const SizedBox(height: 10), _cartBar(context)])),
  ])); }
  Widget _grid() => loading ? const Center(child: CircularProgressIndicator()) : products.isEmpty ? const _Empty(title: 'No sellable products', subtitle: 'Add products with available stock.', icon: Icons.point_of_sale_rounded) : LayoutBuilder(builder: (_, c) { final cols = c.maxWidth >= 1150 ? 4 : c.maxWidth >= 720 ? 3 : 2; return GridView.builder(itemCount: products.length, gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: cols, crossAxisSpacing: 12, mainAxisSpacing: 12, childAspectRatio: .72), itemBuilder: (_, i) => _SellCard(p: products[i], qty: _qty(products[i]), onAdd: () => _add(products[i]), onMinus: () => _minus(products[i]))); });
  Widget _cartBar(BuildContext context) => SafeArea(child: Align(alignment: Alignment.center, child: SizedBox(width: MediaQuery.sizeOf(context).width > 450 ? 290 : double.infinity, height: 52, child: FilledButton.icon(onPressed: cart.isEmpty ? null : () => showModalBottomSheet<void>(context: context, isScrollControlled: true, showDragHandle: true, builder: (_) => SizedBox(height: MediaQuery.sizeOf(context).height * .72, child: Padding(padding: const EdgeInsets.all(16), child: _cartPanel()))), icon: const Icon(Icons.shopping_bag_rounded), label: Text(cart.isEmpty ? 'Cart · ₹0' : 'View cart · ${money(total)}'))));
  Widget _cartPanel() => Card(child: Padding(padding: const EdgeInsets.all(16), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Row(children: [const Expanded(child: Text('Current order', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900))), if (cart.isNotEmpty) Text('${cart.values.fold<int>(0, (a, b) => a + b)} items', style: const TextStyle(color: _muted, fontSize: 11))]), const SizedBox(height: 10), Expanded(child: cart.isEmpty ? const _Empty(title: 'Cart is empty', subtitle: 'Tap + to add a product.', icon: Icons.shopping_bag_outlined) : ListView.separated(itemCount: cart.length, separatorBuilder: (_, __) => const Divider(height: 1), itemBuilder: (_, i) { final id = cart.keys.elementAt(i); final p = _product(id)!; final q = cart[id]!; return ListTile(contentPadding: EdgeInsets.zero, leading: ProductImage(product: p, size: 46, radius: 12), title: Text(p.name, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 12)), subtitle: Text('${money(p.sellingPrice)} each', style: const TextStyle(fontSize: 11)), trailing: Row(mainAxisSize: MainAxisSize.min, children: [IconButton(onPressed: () => _minus(p), icon: const Icon(Icons.remove_circle_outline)), Text('$q', style: const TextStyle(fontWeight: FontWeight.w900)), IconButton(onPressed: () => _add(p), icon: const Icon(Icons.add_circle_outline, color: _blue))]); })), const Divider(), Row(children: [const Expanded(child: Text('Total', style: TextStyle(color: _muted))), Text(money(total), style: const TextStyle(fontSize: 21, fontWeight: FontWeight.w900))]), const SizedBox(height: 10), Row(children: [Expanded(child: OutlinedButton(onPressed: cart.isEmpty ? null : _clear, child: const Text('Clear cart'))), const SizedBox(width: 10), Expanded(child: FilledButton(onPressed: cart.isEmpty ? null : () => _checkout(context), child: const Text('Checkout')))])])));
  Future<void> _checkout(BuildContext context) async { final customer = TextEditingController(text: 'Walk-in Customer'); String payment = 'Cash'; final received = TextEditingController(text: total.toStringAsFixed(0)); final ok = await showDialog<bool>(context: context, builder: (_) => StatefulBuilder(builder: (context, setDialog) => AlertDialog(title: const Text('Checkout', style: TextStyle(fontWeight: FontWeight.w900)), content: Column(mainAxisSize: MainAxisSize.min, children: [Text('Total ${money(total)}', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900)), const SizedBox(height: 12), TextField(controller: customer, decoration: const InputDecoration(labelText: 'Customer', prefixIcon: Icon(Icons.person_outline))), const SizedBox(height: 10), DropdownButtonFormField<String>(initialValue: payment, decoration: const InputDecoration(labelText: 'Payment method'), items: const [DropdownMenuItem(value: 'Cash', child: Text('Cash')), DropdownMenuItem(value: 'UPI', child: Text('UPI')), DropdownMenuItem(value: 'Card', child: Text('Card')), DropdownMenuItem(value: 'Bank transfer', child: Text('Bank transfer')), DropdownMenuItem(value: 'Credit / Due', child: Text('Credit / Due'))], onChanged: (v) => setDialog(() => payment = v!)), const SizedBox(height: 10), if (payment == 'Cash') TextField(controller: received, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Amount received')), if (payment == 'Credit / Due') const Align(alignment: Alignment.centerLeft, child: Text('The full amount will be recorded as due.', style: TextStyle(color: _muted, fontSize: 12))) ]), actions: [TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')), FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('Complete sale'))]))); if (ok != true) { customer.dispose(); received.dispose(); return; } try { final items = <Map<String, Object?>>[]; for (final e in cart.entries) { final p = _product(e.key); if (p != null) items.add({'product_id': p.id!, 'quantity': e.value, 'price': p.sellingPrice, 'name': p.name}); } await AppDatabase.instance.sellCart(items, customer: customer.text.trim().isEmpty ? 'Walk-in Customer' : customer.text.trim(), payment: payment); if (!mounted) return; setState(cart.clear); await _load(); final change = payment == 'Cash' ? (double.tryParse(received.text) ?? total) - total : 0; if (context.mounted) await showDialog<void>(context: context, builder: (_) => AlertDialog(title: const Text('Sale completed', style: TextStyle(fontWeight: FontWeight.w900)), content: Column(mainAxisSize: MainAxisSize.min, children: [const Icon(Icons.check_circle_rounded, color: _green, size: 54), const SizedBox(height: 10), Text(money(total), style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w900)), Text('Paid via $payment', style: const TextStyle(color: _muted)), if (payment == 'Cash') Text('Change ${money(change < 0 ? 0 : change)}', style: const TextStyle(fontWeight: FontWeight.w800)), const SizedBox(height: 10), const Text('Inventory was updated automatically.', style: TextStyle(color: _muted, fontSize: 12))]), actions: [FilledButton(onPressed: () => Navigator.pop(context), child: const Text('New sale'))])); } catch (e) { if (mounted) _toast(e.toString()); } customer.dispose(); received.dispose(); }
  Future<void> _scan(BuildContext context) async { final c = TextEditingController(); final v = await showDialog<String>(context: context, builder: (_) => AlertDialog(title: const Text('Scan / enter barcode'), content: TextField(controller: c, autofocus: true, decoration: const InputDecoration(labelText: 'Barcode or SKU')), actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')), FilledButton(onPressed: () => Navigator.pop(context, c.text.trim()), child: const Text('Find'))])); c.dispose(); if (v != null && v.isNotEmpty) { query = v; _load(); } }
  void _toast(String text) { if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text))); }
}

class _SellCard extends StatelessWidget { final Product p; final int qty; final VoidCallback onAdd, onMinus; const _SellCard({required this.p, required this.qty, required this.onAdd, required this.onMinus}); @override Widget build(BuildContext context) => Card(clipBehavior: Clip.antiAlias, child: Padding(padding: const EdgeInsets.all(9), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Expanded(child: ProductImage(product: p, size: 170, radius: 16)), const SizedBox(height: 7), Text(p.brand, style: const TextStyle(color: _muted, fontSize: 10)), Text(p.name, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 13)), const SizedBox(height: 4), Row(children: [Expanded(child: Text(money(p.sellingPrice), style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16))), if (p.quantity == 0) const _Badge('OUT OF STOCK') else qty == 0 ? IconButton(onPressed: onAdd, icon: const Icon(Icons.add_circle, color: _blue, size: 34)) : Row(mainAxisSize: MainAxisSize.min, children: [IconButton(onPressed: onMinus, icon: const Icon(Icons.remove_circle_outline, size: 25)), Text('$qty', style: const TextStyle(fontWeight: FontWeight.w900)), IconButton(onPressed: onAdd, icon: const Icon(Icons.add_circle, color: _blue, size: 28))])])]))); }

class ModernPurchases extends StatefulWidget { const ModernPurchases({super.key}); @override State<ModernPurchases> createState() => _ModernPurchasesState(); }
class _ModernPurchasesState extends State<ModernPurchases> {
  List<Map<String, Object?>> rows = [];
  @override void initState() { super.initState(); _load(); }
  Future<void> _load() async { try { final r = await AppDatabase.instance.purchases(); if (mounted) setState(() => rows = r); } catch (_) {} }
  @override Widget build(BuildContext context) => _Page(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [_Header('Purchases', 'Receive stock and manage supplier invoices.', action: FilledButton.icon(onPressed: () => _newPurchase(context), icon: const Icon(Icons.add_rounded), label: const Text('New purchase'))), const SizedBox(height: 16), Expanded(child: rows.isEmpty ? const _Empty(title: 'No purchases yet', subtitle: 'Create a purchase to receive stock.', icon: Icons.shopping_bag_outlined) : ListView.separated(itemCount: rows.length, separatorBuilder: (_, __) => const SizedBox(height: 8), itemBuilder: (_, i) { final r = rows[i]; return Card(child: ListTile(title: Text(r['invoice']?.toString().isEmpty == true ? 'Purchase' : r['invoice'].toString(), style: const TextStyle(fontWeight: FontWeight.w900)), subtitle: Text('${r['supplier'] ?? 'Supplier'} • ${r['date'] ?? ''}'), trailing: Text(money((r['total'] as num?) ?? 0), style: const TextStyle(fontWeight: FontWeight.w900))); })))]));
  Future<void> _newPurchase(BuildContext context) async { final supplier = TextEditingController(); final invoice = TextEditingController(text: 'PO-${DateTime.now().millisecondsSinceEpoch % 100000}'); final price = TextEditingController(); final qty = TextEditingController(text: '1'); final productList = await AppDatabase.instance.products(); Product? selected = productList.isEmpty ? null : productList.first; final ok = await showDialog<bool>(context: context, builder: (_) => StatefulBuilder(builder: (context, set) => AlertDialog(title: const Text('New purchase', style: TextStyle(fontWeight: FontWeight.w900)), content: SingleChildScrollView(child: Column(mainAxisSize: MainAxisSize.min, children: [TextField(controller: supplier, decoration: const InputDecoration(labelText: 'Supplier')), TextField(controller: invoice, decoration: const InputDecoration(labelText: 'Invoice')), const SizedBox(height: 8), DropdownButtonFormField<Product>(initialValue: selected, isExpanded: true, decoration: const InputDecoration(labelText: 'Product'), items: [for (final p in productList) DropdownMenuItem(value: p, child: Text('${p.brand} ${p.name}', overflow: TextOverflow.ellipsis))], onChanged: (v) => set(() => selected = v)), TextField(controller: qty, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Quantity')), TextField(controller: price, keyboardType: const TextInputType.numberWithOptions(decimal: true), decoration: const InputDecoration(labelText: 'Cost per unit'))])), actions: [TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')), FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('Receive stock'))]))); if (ok == true && selected != null) { try { final q = int.tryParse(qty.text) ?? 0; final cost = double.tryParse(price.text) ?? selected!.purchasePrice; await AppDatabase.instance.purchase(supplier: supplier.text.trim().isEmpty ? 'Supplier' : supplier.text.trim(), invoice: invoice.text.trim(), items: [{'product_id': selected!.id!, 'quantity': q, 'price': cost}], payment: 'Cash', paid: cost * q); await _load(); } catch (e) { if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString()))); } } supplier.dispose(); invoice.dispose(); price.dispose(); qty.dispose(); }
}

class ModernMore extends StatelessWidget { const ModernMore({super.key}); @override Widget build(BuildContext context) => _Page(child: ListView(children: [const _Header('More', 'Customers, suppliers, expenses, reports and settings.'), const SizedBox(height: 18), _Tool(title: 'Customers', subtitle: 'Customer profiles and balances', icon: Icons.people_alt_outlined, color: _blue, onTap: () => _customers(context)), _Tool(title: 'Suppliers', subtitle: 'Supplier records and purchase history', icon: Icons.local_shipping_outlined, color: _purple, onTap: () => _suppliers(context)), _Tool(title: 'Expenses', subtitle: 'Track shop operating costs', icon: Icons.receipt_long_outlined, color: _orange, onTap: () => _expenses(context)), _Tool(title: 'Reports & analytics', subtitle: 'Sales, gross profit, expenses and stock', icon: Icons.bar_chart_rounded, color: _green, onTap: () => _reports(context)), _Tool(title: 'Backup & Restore', subtitle: 'Export and protect your shop data', icon: Icons.backup_rounded, color: const Color(0xFF3D7DD8), onTap: () => _backup(context)), _Tool(title: 'Settings', subtitle: 'Shop profile and preferences', icon: Icons.settings_outlined, color: _muted, onTap: () => _settings(context))])); }

class _Tool extends StatelessWidget { final String title, subtitle; final IconData icon; final Color color; final VoidCallback onTap; const _Tool({required this.title, required this.subtitle, required this.icon, required this.color, required this.onTap}); @override Widget build(BuildContext context) => Card(margin: const EdgeInsets.only(bottom: 9), child: ListTile(onTap: onTap, contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6), leading: Container(width: 44, height: 44, decoration: BoxDecoration(color: color.withAlpha(17), borderRadius: BorderRadius.circular(13)), child: Icon(icon, color: color)), title: Text(title, style: const TextStyle(fontWeight: FontWeight.w800)), subtitle: Text(subtitle, style: const TextStyle(color: _muted, fontSize: 11)), trailing: const Icon(Icons.chevron_right_rounded, color: _muted))); }

Future<void> _customers(BuildContext context) async { final d = await AppDatabase.instance.db; final rows = await d.query('customers', orderBy: 'name', limit: 100); if (!context.mounted) return; await Navigator.push(context, MaterialPageRoute(builder: (_) => _SimpleListPage(title: 'Customers', icon: Icons.people_alt_outlined, rows: rows, columns: const ['name','phone','email']))); }
Future<void> _suppliers(BuildContext context) async { final d = await AppDatabase.instance.db; final rows = await d.query('suppliers', orderBy: 'name', limit: 100); if (!context.mounted) return; await Navigator.push(context, MaterialPageRoute(builder: (_) => _SimpleListPage(title: 'Suppliers', icon: Icons.local_shipping_outlined, rows: rows, columns: const ['name','phone','gstin']))); }
Future<void> _expenses(BuildContext context) async { await showDialog<void>(context: context, builder: (_) => const _ExpenseDialog()); }
Future<void> _reports(BuildContext context) async { final m = await AppDatabase.instance.monthly(); if (!context.mounted) return; await showModalBottomSheet<void>(context: context, showDragHandle: true, builder: (_) => Padding(padding: const EdgeInsets.all(20), child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [const Text('This month', style: TextStyle(fontSize: 21, fontWeight: FontWeight.w900)), const SizedBox(height: 14), _ReportRow('Sales', money(m['sales'] ?? 0)), _ReportRow('Cost of goods', money(m['cogs'] ?? 0)), _ReportRow('Gross profit', money(m['gross'] ?? 0)), _ReportRow('Expenses', money(m['expenses'] ?? 0)), _ReportRow('Net profit', money(m['net'] ?? 0)), _ReportRow('Inventory value', money(m['inventory'] ?? 0))]))); }
Future<void> _backup(BuildContext context) async { final d = await AppDatabase.instance.db; final counts = <String, int>{}; for (final t in ['products','sales','purchases','customers','suppliers','expenses']) { final n = Sqflite.firstIntValue(await d.rawQuery('SELECT COUNT(*) FROM $t')) ?? 0; counts[t] = n; } if (!context.mounted) return; await showDialog<void>(context: context, builder: (_) => AlertDialog(title: const Text('Backup & Restore', style: TextStyle(fontWeight: FontWeight.w900)), content: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [const Text('Local database is healthy and available on this device.'), const SizedBox(height: 12), for (final e in counts.entries) Text('${e.key}: ${e.value} records', style: const TextStyle(color: _muted)), const SizedBox(height: 12), const Text('A file export can be added without changing the live database.', style: TextStyle(fontSize: 11, color: _muted))]), actions: [FilledButton(onPressed: () => Navigator.pop(context), child: const Text('Close'))])); }
Future<void> _settings(BuildContext context) async { final d = await AppDatabase.instance.db; final name = TextEditingController(text: (await d.query('settings', where: 'key=?', whereArgs: ['shop_name'], limit: 1)).firstOrNull?['value']?.toString() ?? 'ElectroMart'); if (!context.mounted) return; await showDialog<void>(context: context, builder: (_) => AlertDialog(title: const Text('Settings', style: TextStyle(fontWeight: FontWeight.w900)), content: TextField(controller: name, decoration: const InputDecoration(labelText: 'Shop name')), actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')), FilledButton(onPressed: () async { await d.insert('settings', {'key': 'shop_name', 'value': name.text.trim()}, conflictAlgorithm: ConflictAlgorithm.replace); if (context.mounted) Navigator.pop(context); }, child: const Text('Save'))])); name.dispose(); }

class _SimpleListPage extends StatelessWidget { final String title; final IconData icon; final List<Map<String, Object?>> rows; final List<String> columns; const _SimpleListPage({required this.title, required this.icon, required this.rows, required this.columns}); @override Widget build(BuildContext context) => Scaffold(backgroundColor: _bg, appBar: AppBar(title: Text(title, style: const TextStyle(fontWeight: FontWeight.w900)), backgroundColor: _bg), body: ListView.builder(padding: const EdgeInsets.all(16), itemCount: rows.length, itemBuilder: (_, i) { final r = rows[i]; return Card(margin: const EdgeInsets.only(bottom: 8), child: ListTile(leading: CircleAvatar(backgroundColor: _blue.withAlpha(18), child: Icon(icon, color: _blue, size: 20)), title: Text(r[columns.first]?.toString() ?? '—', style: const TextStyle(fontWeight: FontWeight.w800)), subtitle: Text(columns.skip(1).map((c) => r[c]?.toString() ?? '').where((x) => x.isNotEmpty).join(' • '))); })); }

class _ReportRow extends StatelessWidget { final String label, value; const _ReportRow(this.label, this.value); @override Widget build(BuildContext context) => Padding(padding: const EdgeInsets.symmetric(vertical: 7), child: Row(children: [Expanded(child: Text(label, style: const TextStyle(color: _muted))), Text(value, style: const TextStyle(fontWeight: FontWeight.w900))])); }

class _ExpenseDialog extends StatefulWidget { const _ExpenseDialog(); @override State<_ExpenseDialog> createState() => _ExpenseDialogState(); }
class _ExpenseDialogState extends State<_ExpenseDialog> { final category = TextEditingController(text: 'Other'); final amount = TextEditingController(); final note = TextEditingController(); @override void dispose() { category.dispose(); amount.dispose(); note.dispose(); super.dispose(); } @override Widget build(BuildContext context) => AlertDialog(title: const Text('Add expense', style: TextStyle(fontWeight: FontWeight.w900)), content: Column(mainAxisSize: MainAxisSize.min, children: [TextField(controller: category, decoration: const InputDecoration(labelText: 'Category')), TextField(controller: amount, keyboardType: const TextInputType.numberWithOptions(decimal: true), decoration: const InputDecoration(labelText: 'Amount')), TextField(controller: note, decoration: const InputDecoration(labelText: 'Notes'))]), actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')), FilledButton(onPressed: () async { final value = double.tryParse(amount.text) ?? 0; if (value <= 0) return; await AppDatabase.instance.addExpense(category.text.trim().isEmpty ? 'Other' : category.text.trim(), value, 'Cash', note.text.trim()); if (context.mounted) Navigator.pop(context); }, child: const Text('Save expense'))]); }

int _categoryIcon(String category) { switch (category) { case 'Mobile Phones': return Icons.phone_android_rounded; case 'Laptops': return Icons.laptop_mac_rounded; case 'Televisions': return Icons.tv_rounded; case 'Refrigerators': return Icons.kitchen_rounded; case 'Audio': return Icons.headphones_rounded; case 'Cameras': return Icons.photo_camera_rounded; case 'Printers': return Icons.print_rounded; case 'Storage': return Icons.storage_rounded; default: return Icons.devices_other_rounded; } }
