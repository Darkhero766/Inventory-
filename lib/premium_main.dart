import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

import 'data/database.dart';
import 'models/models.dart';
import 'services/product_catalog_service.dart';

const _blue = Color(0xFF4F63D8);
const _violet = Color(0xFF7C5CFC);
const _green = Color(0xFF20B486);
const _orange = Color(0xFFF0A21A);
const _red = Color(0xFFE45B6A);
const _ink = Color(0xFF181A24);
const _muted = Color(0xFF747785);
const _surface = Color(0xFFFFFFFF);
const _background = Color(0xFFF4F6FB);

String pmoney(num value) => NumberFormat.currency(
      locale: 'en_IN',
      symbol: '₹',
      decimalDigits: 0,
    ).format(value);

void main() => runApp(const PremiumInventoryApp());

class PremiumInventoryApp extends StatelessWidget {
  const PremiumInventoryApp({super.key});

  @override
  Widget build(BuildContext context) {
    final scheme = ColorScheme.fromSeed(seedColor: _blue);
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Inventory POS',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: scheme,
        scaffoldBackgroundColor: _background,
        fontFamily: 'Inter',
        cardTheme: CardThemeData(
          elevation: 0,
          color: _surface,
          margin: EdgeInsets.zero,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: _surface,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
          hintStyle: const TextStyle(color: Color(0xFFA0A3AF)),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(18), borderSide: BorderSide.none),
          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(18), borderSide: BorderSide.none),
          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(18), borderSide: const BorderSide(color: _blue, width: 1.2)),
        ),
      ),
      home: const PremiumShell(),
    );
  }
}

class PremiumShell extends StatefulWidget {
  const PremiumShell({super.key});
  @override
  State<PremiumShell> createState() => _PremiumShellState();
}

class _PremiumShellState extends State<PremiumShell> {
  int index = 0;
  final pages = const [PremiumHome(), PremiumInventory(), PremiumPurchases(), PremiumSales(), PremiumMore()];
  final labels = const ['Home', 'Inventory', 'Purchases', 'Sales', 'More'];
  final icons = const [Icons.home_rounded, Icons.inventory_2_rounded, Icons.shopping_bag_rounded, Icons.point_of_sale_rounded, Icons.more_horiz_rounded];

  @override
  Widget build(BuildContext context) {
    final wide = MediaQuery.sizeOf(context).width >= 900;
    return Scaffold(
      body: wide
          ? Row(children: [
              SafeArea(
                child: Container(
                  width: 230,
                  padding: const EdgeInsets.all(16),
                  color: _surface,
                  child: Column(children: [
                    const _Logo(),
                    const SizedBox(height: 28),
                    Expanded(
                      child: NavigationRail(
                        extended: true,
                        minExtendedWidth: 200,
                        selectedIndex: index,
                        onDestinationSelected: (v) => setState(() => index = v),
                        destinations: [
                          for (var i = 0; i < labels.length; i++)
                            NavigationRailDestination(icon: Icon(icons[i]), selectedIcon: Icon(icons[i]), label: Text(labels[i])),
                        ],
                      ),
                    ),
                    const Text('ElectroMart • Main Store', style: TextStyle(fontSize: 10, color: _muted)),
                  ]),
                ),
              ),
              const VerticalDivider(width: 1),
              Expanded(child: pages[index]),
            ])
          : pages[index],
      bottomNavigationBar: wide
          ? null
          : NavigationBar(
              selectedIndex: index,
              onDestinationSelected: (v) => setState(() => index = v),
              destinations: [for (var i = 0; i < labels.length; i++) NavigationDestination(icon: Icon(icons[i]), label: labels[i])],
            ),
    );
  }
}

class _Logo extends StatelessWidget {
  const _Logo();
  @override
  Widget build(BuildContext context) => Row(children: [
        Container(width: 42, height: 42, decoration: BoxDecoration(gradient: const LinearGradient(colors: [_blue, _violet]), borderRadius: BorderRadius.circular(14)), child: const Icon(Icons.bolt_rounded, color: Colors.white)),
        const SizedBox(width: 10),
        const Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('INVENTORY', style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1)),
          Text('ElectroMart', style: TextStyle(fontSize: 10, color: _muted)),
        ]),
      ]);
}

class _Page extends StatelessWidget {
  final Widget child;
  const _Page({required this.child});
  @override
  Widget build(BuildContext context) => SafeArea(child: Center(child: ConstrainedBox(constraints: const BoxConstraints(maxWidth: 1440), child: Padding(padding: const EdgeInsets.fromLTRB(18, 18, 18, 24), child: child))));
}

class _Header extends StatelessWidget {
  final String title;
  final String subtitle;
  final Widget? action;
  const _Header({required this.title, required this.subtitle, this.action});
  @override
  Widget build(BuildContext context) => LayoutBuilder(builder: (_, c) {
        final heading = Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(title, style: const TextStyle(fontSize: 29, fontWeight: FontWeight.w900, color: _ink, letterSpacing: -.8)),
          const SizedBox(height: 3),
          Text(subtitle, style: const TextStyle(color: _muted)),
        ]);
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
  Widget build(BuildContext context) => TextField(onChanged: onChanged, decoration: InputDecoration(prefixIcon: const Icon(Icons.search_rounded), hintText: hint, suffixIcon: onScan == null ? null : IconButton(onPressed: onScan, tooltip: 'Barcode / SKU', icon: const Icon(Icons.qr_code_scanner_rounded))));
}

class PremiumHome extends StatefulWidget {
  const PremiumHome({super.key});
  @override
  State<PremiumHome> createState() => _PremiumHomeState();
}

class _PremiumHomeState extends State<PremiumHome> {
  List<Product> products = const [];
  Map<String, num> stats = const {};
  bool loading = true;

  @override
  void initState() { super.initState(); refresh(); }
  Future<void> refresh() async {
    try {
      final result = await Future.wait([AppDatabase.instance.products(), AppDatabase.instance.snapshot()]);
      if (!mounted) return;
      setState(() { products = result[0] as List<Product>; stats = result[1] as Map<String, num>; loading = false; });
    } catch (_) { if (mounted) setState(() => loading = false); }
  }

  @override
  Widget build(BuildContext context) {
    final low = products.where((p) => p.quantity <= p.minimumStock).take(5).toList();
    return _Page(child: RefreshIndicator(onRefresh: refresh, child: ListView(physics: const AlwaysScrollableScrollPhysics(), children: [
      const _Header(title: 'Good morning', subtitle: 'Run your shop from one clean counter.'),
      const SizedBox(height: 18),
      _QuickActionStrip(onSale: () => _go(context, 3), onAdd: () => _go(context, 1)),
      const SizedBox(height: 20),
      LayoutBuilder(builder: (_, c) {
        final columns = c.maxWidth > 1100 ? 4 : c.maxWidth > 650 ? 2 : 1;
        final width = (c.maxWidth - (columns - 1) * 12) / columns;
        return Wrap(spacing: 12, runSpacing: 12, children: [
          SizedBox(width: width, child: _StatCard('Today sales', pmoney(stats['sales'] ?? 0), Icons.trending_up_rounded, _green)),
          SizedBox(width: width, child: _StatCard('Purchases', pmoney(stats['purchases'] ?? 0), Icons.shopping_bag_outlined, _violet)),
          SizedBox(width: width, child: _StatCard('Inventory value', pmoney(stats['inventory'] ?? 0), Icons.inventory_2_outlined, _blue, note: '${products.length} products')),
          SizedBox(width: width, child: _StatCard('Low stock', '${stats['low'] ?? 0}', Icons.warning_amber_rounded, _orange, note: 'Needs attention')),
        ]);
      }),
      const SizedBox(height: 24),
      const Text('Low stock', style: TextStyle(fontSize: 19, fontWeight: FontWeight.w900, color: _ink)),
      const SizedBox(height: 10),
      if (low.isEmpty) const _Empty(title: 'Stock looks healthy', subtitle: 'Nothing needs attention right now.', icon: Icons.check_circle_outline_rounded)
      else for (final p in low) _ProductRow(product: p),
      const SizedBox(height: 24),
      const Text('Your catalog', style: TextStyle(fontSize: 19, fontWeight: FontWeight.w900, color: _ink)),
      const SizedBox(height: 10),
      SizedBox(height: 240, child: products.isEmpty ? const _Empty(title: 'No products yet', subtitle: 'Add your first product from Inventory.', icon: Icons.devices_other_rounded) : ListView.separated(scrollDirection: Axis.horizontal, itemCount: products.length.clamp(0, 8), separatorBuilder: (_, __) => const SizedBox(width: 12), itemBuilder: (_, i) => SizedBox(width: 205, child: _ProductCard(product: products[i])))),
      if (loading) const Padding(padding: EdgeInsets.only(top: 12), child: LinearProgressIndicator(minHeight: 2)),
    ])));
  }

  void _go(BuildContext context, int index) {
    final shell = context.findAncestorStateOfType<_PremiumShellState>();
    shell?.setState(() => shell.index = index);
  }
}

class _QuickActionStrip extends StatelessWidget {
  final VoidCallback onSale;
  final VoidCallback onAdd;
  const _QuickActionStrip({required this.onSale, required this.onAdd});
  @override
  Widget build(BuildContext context) => Card(child: Padding(padding: const EdgeInsets.all(14), child: Wrap(spacing: 10, runSpacing: 10, children: [
    FilledButton.icon(onPressed: onSale, icon: const Icon(Icons.point_of_sale_rounded), label: const Text('New sale')),
    OutlinedButton.icon(onPressed: onAdd, icon: const Icon(Icons.add_rounded), label: const Text('Add product')),
  ])));
}

class _StatCard extends StatelessWidget {
  final String title, value;
  final IconData icon;
  final Color accent;
  final String? note;
  const _StatCard(this.title, this.value, this.icon, this.accent, {this.note});
  @override
  Widget build(BuildContext context) => Card(child: Padding(padding: const EdgeInsets.all(16), child: Row(children: [Container(width: 45, height: 45, decoration: BoxDecoration(color: accent.withAlpha(20), borderRadius: BorderRadius.circular(15)), child: Icon(icon, color: accent)), const SizedBox(width: 12), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(title, style: const TextStyle(color: _muted, fontSize: 12)), const SizedBox(height: 3), Text(value, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: _ink)), if (note != null) Text(note!, style: const TextStyle(color: _muted, fontSize: 10))]))])));
}

class PremiumInventory extends StatefulWidget {
  const PremiumInventory({super.key});
  @override
  State<PremiumInventory> createState() => _PremiumInventoryState();
}

class _PremiumInventoryState extends State<PremiumInventory> {
  List<Product> items = const [];
  String query = '';
  String filter = 'All';
  bool loading = true;
  @override
  void initState() { super.initState(); refresh(); }
  Future<void> refresh() async { try { final r = await AppDatabase.instance.products(query: query); if (mounted) setState(() { items = r; loading = false; }); } catch (_) { if (mounted) setState(() { items = []; loading = false; }); } }
  List<Product> get visible => filter == 'Low stock' ? items.where((p) => p.quantity > 0 && p.quantity <= p.minimumStock).toList() : filter == 'Out of stock' ? items.where((p) => p.quantity == 0).toList() : items;

  @override
  Widget build(BuildContext context) => _Page(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    _Header(title: 'Inventory', subtitle: '${visible.length} products in your catalog', action: FilledButton.icon(onPressed: () => _addProduct(context), icon: const Icon(Icons.add_rounded), label: const Text('Add product'))),
    const SizedBox(height: 15),
    _Search(hint: 'Search name, brand, model, SKU or barcode', onChanged: (v) { query = v; refresh(); }, onScan: () => _barcode(context)),
    const SizedBox(height: 10),
    SingleChildScrollView(scrollDirection: Axis.horizontal, child: Row(children: [for (final f in ['All', 'Low stock', 'Out of stock']) Padding(padding: const EdgeInsets.only(right: 8), child: ChoiceChip(label: Text(f == 'All' ? 'All products' : f), selected: filter == f, onSelected: (_) => setState(() => filter = f)))])),
    const SizedBox(height: 12),
    Expanded(child: loading ? const Center(child: CircularProgressIndicator()) : visible.isEmpty ? const _Empty(title: 'No products found', subtitle: 'Try another search or add a product.', icon: Icons.inventory_2_outlined) : LayoutBuilder(builder: (_, c) { final columns = c.maxWidth > 1150 ? 4 : c.maxWidth > 700 ? 3 : 2; return GridView.builder(itemCount: visible.length, gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: columns, crossAxisSpacing: 12, mainAxisSpacing: 12, childAspectRatio: .72), itemBuilder: (_, i) => _ProductCard(product: visible[i], onTap: () => _details(context, visible[i]))); })),
  ]));

  Future<void> _addProduct(BuildContext context) async {
    final draft = await showModalBottomSheet<_PremiumDraft>(context: context, isScrollControlled: true, showDragHandle: true, builder: (_) => const _AddProductSheet());
    if (draft == null) return;
    try { await AppDatabase.instance.addProduct(draft.toMap()); await refresh(); if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Product added to inventory'))); } catch (e) { if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Could not save product: $e'))); }
  }
  Future<void> _barcode(BuildContext context) async { final c = TextEditingController(); final value = await showDialog<String>(context: context, builder: (_) => AlertDialog(title: const Text('Find by barcode / SKU'), content: TextField(controller: c, autofocus: true, decoration: const InputDecoration(labelText: 'Barcode or SKU')), actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')), FilledButton(onPressed: () => Navigator.pop(context, c.text.trim()), child: const Text('Find'))])); c.dispose(); if (value?.isNotEmpty == true) { query = value!; refresh(); } }
  Future<void> _details(BuildContext context, Product p) async { await showModalBottomSheet<void>(context: context, showDragHandle: true, isScrollControlled: true, builder: (_) => _ProductDetails(product: p, refresh: refresh)); }
}

class _PremiumDraft {
  final String name, brand, category, model, sku, imageUrl;
  final double purchase, selling, mrp;
  final int quantity, minimum;
  const _PremiumDraft({required this.name, required this.brand, required this.category, required this.model, required this.sku, required this.imageUrl, required this.purchase, required this.selling, required this.mrp, required this.quantity, required this.minimum});
  Map<String, Object?> toMap() => {'name': name, 'brand': brand, 'category': category, 'model': model, 'sku': sku, 'barcode': '', 'image_url': imageUrl, 'mrp': mrp, 'selling_price': selling, 'purchase_price': purchase, 'quantity': quantity, 'minimum_stock': minimum, 'supplier': '', 'warranty': '1 Year', 'gst_rate': 18, 'hsn_code': '', 'location': 'Main Store', 'rack': '', 'shelf': '', 'serial_tracking': 0, 'imei_tracking': category == 'Mobile Phones' ? 1 : 0, 'specs': '', 'notes': '', 'archived': 0};
}

class _AddProductSheet extends StatefulWidget {
  const _AddProductSheet();
  @override
  State<_AddProductSheet> createState() => _AddProductSheetState();
}

class _AddProductSheetState extends State<_AddProductSheet> {
  final key = GlobalKey<FormState>();
  final name = TextEditingController();
  final model = TextEditingController();
  final sku = TextEditingController(text: 'SKU-${DateTime.now().millisecondsSinceEpoch % 100000}');
  final purchase = TextEditingController();
  final selling = TextEditingController();
  final mrp = TextEditingController();
  final quantity = TextEditingController(text: '1');
  final minimum = TextEditingController(text: '2');
  String brand = 'Samsung';
  String category = 'Mobile Phones';
  String imageUrl = '';
  List<ProductSuggestion> suggestions = const [];
  bool searching = false;
  static const brands = ['Samsung','LG','Sony','Apple','OnePlus','Motorola','Xiaomi','HP','Dell','Lenovo','ASUS','Acer','MSI','Whirlpool','IFB','Bosch','Haier','Voltas','Daikin','Blue Star','JBL','boAt','Bose','Canon','Nikon','Epson','TP-Link','D-Link','Tenda','Logitech','Razer','Kingston','SanDisk','Seagate','Western Digital','Philips','Havells','Bajaj','Crompton','Oppo','Realme'];
  static const categories = ['Mobile Phones','Laptops','Televisions','Refrigerators','Air Conditioners','Washing Machines','Audio','Cameras','Printers','Networking','Storage','Accessories','Monitors','Gaming','Smartwatches','Kitchen Appliances','Fans','Coolers','Projectors','Power & Cables'];
  @override
  void dispose() { for (final c in [name, model, sku, purchase, selling, mrp, quantity, minimum]) c.dispose(); super.dispose(); }
  Future<void> searchInternet(String value) async { if (value.trim().length < 2) { if (mounted) setState(() => suggestions = const []); return; } setState(() => searching = true); final result = await ProductCatalogService.suggest(query: value, brand: brand, category: category); if (mounted) setState(() { suggestions = result; searching = false; }); }
  void choose(ProductSuggestion item) { name.text = item.title; model.text = item.title; imageUrl = item.imageUrl; setState(() => suggestions = const []); }

  @override
  Widget build(BuildContext context) => Padding(padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom), child: DraggableScrollableSheet(initialChildSize: .9, maxChildSize: .98, minChildSize: .65, expand: false, builder: (_, scroll) => Material(color: _background, child: Form(key: key, child: ListView(controller: scroll, padding: const EdgeInsets.fromLTRB(18, 0, 18, 28), children: [
    const Text('Add product', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: _ink)),
    const SizedBox(height: 4),
    const Text('Choose product type and brand first, then pick a verified model suggestion.', style: TextStyle(color: _muted)),
    const SizedBox(height: 18),
    Row(children: [Expanded(child: _select('Product type', category, categories, (v) => setState(() => category = v!))), const SizedBox(width: 10), Expanded(child: _select('Brand', brand, brands, (v) => setState(() => brand = v!)))]),
    const SizedBox(height: 12),
    TextFormField(controller: name, onChanged: searchInternet, validator: (v) => v == null || v.trim().isEmpty ? 'Product name is required' : null, decoration: const InputDecoration(labelText: 'Product / model name', hintText: 'e.g. Galaxy S25 Ultra', prefixIcon: Icon(Icons.auto_awesome_rounded))),
    if (searching) const Padding(padding: EdgeInsets.only(top: 8), child: LinearProgressIndicator(minHeight: 2)),
    if (suggestions.isNotEmpty) ...[const SizedBox(height: 10), Card(child: Column(children: [const ListTile(title: Text('Internet product suggestions', style: TextStyle(fontWeight: FontWeight.w900)), subtitle: Text('Results are filtered by your brand and product type.')), for (final item in suggestions.take(5)) ListTile(onTap: () => choose(item), leading: _SuggestionImage(item.imageUrl), title: Text(item.title, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.w800)), subtitle: Text(item.description, maxLines: 2, overflow: TextOverflow.ellipsis), trailing: const Icon(Icons.add_circle_outline_rounded, color: _blue))]))],
    if (imageUrl.isNotEmpty) Padding(padding: const EdgeInsets.only(top: 12), child: ClipRRect(borderRadius: BorderRadius.circular(20), child: Container(height: 170, color: _surface, child: Image.network(imageUrl, fit: BoxFit.contain, errorBuilder: (_, __, ___) => const Icon(Icons.image_not_supported_outlined, size: 40))))),
    const SizedBox(height: 12),
    Row(children: [Expanded(child: _field(model, 'Model / variant')), const SizedBox(width: 10), Expanded(child: _field(sku, 'SKU'))]),
    Row(children: [Expanded(child: _field(purchase, 'Purchase price', number: true)), const SizedBox(width: 10), Expanded(child: _field(selling, 'Selling price', number: true))]),
    Row(children: [Expanded(child: _field(mrp, 'MRP', number: true)), const SizedBox(width: 10), Expanded(child: _field(quantity, 'Opening stock', number: true)), const SizedBox(width: 10), Expanded(child: _field(minimum, 'Minimum stock', number: true))]),
    const SizedBox(height: 8),
    SizedBox(height: 52, child: FilledButton.icon(onPressed: () { if (!key.currentState!.validate()) return; Navigator.pop(context, _PremiumDraft(name: name.text.trim(), brand: brand, category: category, model: model.text.trim(), sku: sku.text.trim(), imageUrl: imageUrl, purchase: double.tryParse(purchase.text) ?? 0, selling: double.tryParse(selling.text) ?? 0, mrp: double.tryParse(mrp.text) ?? 0, quantity: int.tryParse(quantity.text) ?? 0, minimum: int.tryParse(minimum.text) ?? 2)); }, icon: const Icon(Icons.check_rounded), label: const Text('Save product'))),
  ]))));

  Widget _select(String label, String value, List<String> values, ValueChanged<String?> onChanged) => DropdownButtonFormField<String>(initialValue: value, isExpanded: true, decoration: InputDecoration(labelText: label), items: [for (final v in values) DropdownMenuItem(value: v, child: Text(v, overflow: TextOverflow.ellipsis))], onChanged: onChanged);
  Widget _field(TextEditingController c, String label, {bool number = false}) => Padding(padding: const EdgeInsets.only(bottom: 10), child: TextFormField(controller: c, keyboardType: number ? const TextInputType.numberWithOptions(decimal: true) : null, validator: (v) => v == null || v.trim().isEmpty ? 'Required' : null, decoration: InputDecoration(labelText: label)));
}

class _SuggestionImage extends StatelessWidget {
  final String url;
  const _SuggestionImage(this.url);
  @override
  Widget build(BuildContext context) => SizedBox(width: 54, height: 54, child: ClipRRect(borderRadius: BorderRadius.circular(12), child: url.isEmpty ? const ColoredBox(color: _background, child: Icon(Icons.devices_other_rounded)) : Image.network(url, fit: BoxFit.contain, errorBuilder: (_, __, ___) => const ColoredBox(color: _background, child: Icon(Icons.devices_other_rounded)))));
}

class PremiumSales extends StatefulWidget {
  const PremiumSales({super.key});
  @override
  State<PremiumSales> createState() => _PremiumSalesState();
}

class _PremiumSalesState extends State<PremiumSales> {
  List<Product> products = const [];
  final cart = <Map<String, Object?>>[];
  String query = '';
  @override
  void initState() { super.initState(); refresh(); }
  Future<void> refresh() async { try { final r = await AppDatabase.instance.products(query: query); if (mounted) setState(() => products = r); } catch (_) {} }
  int quantityFor(int id) { final i = cart.indexWhere((x) => x['product_id'] == id); return i < 0 ? 0 : cart[i]['quantity'] as int; }
  void add(Product p) { if (p.quantity <= quantityFor(p.id!)) return; final i = cart.indexWhere((x) => x['product_id'] == p.id); if (i < 0) { cart.add({'product_id': p.id!, 'quantity': 1, 'price': p.sellingPrice, 'name': p.name, 'image_url': p.imageUrl}); } else { cart[i]['quantity'] = (cart[i]['quantity'] as int) + 1; } setState(() {}); }
  void change(Product p, int delta) { final i = cart.indexWhere((x) => x['product_id'] == p.id); if (i < 0) return; final next = (cart[i]['quantity'] as int) + delta; if (next <= 0) cart.removeAt(i); else if (next <= p.quantity) cart[i]['quantity'] = next; setState(() {}); }
  double get total => cart.fold(0, (sum, x) => sum + (x['price'] as num).toDouble() * (x['quantity'] as int));

  @override
  Widget build(BuildContext context) => _Page(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    const _Header(title: 'New sale', subtitle: 'Find → add → checkout. Built for a fast counter.'),
    const SizedBox(height: 15),
    _Search(hint: 'Search product, brand, model or SKU', onChanged: (v) { query = v; refresh(); }, onScan: () => _scan(context)),
    const SizedBox(height: 12),
    Expanded(child: LayoutBuilder(builder: (_, c) { final wide = c.maxWidth >= 900; final grid = _grid(); return wide ? Row(children: [Expanded(child: grid), const SizedBox(width: 14), SizedBox(width: 330, child: _CartPanel(cart: cart, total: total, products: products, onChange: change, onClear: () => setState(cart.clear), onCheckout: () => _checkout(context)))]) : Column(children: [Expanded(child: grid), const SizedBox(height: 10), _MiniCartButton(count: cart.fold(0, (s, x) => s + (x['quantity'] as int)), total: total, onTap: () => _showCart(context))]); })),
  ]));

  Widget _grid() => products.isEmpty ? const _Empty(title: 'No sellable products', subtitle: 'Add stock in Inventory to start a sale.', icon: Icons.point_of_sale_rounded) : LayoutBuilder(builder: (_, c) { final columns = c.maxWidth > 1150 ? 4 : c.maxWidth > 700 ? 3 : 2; return GridView.builder(itemCount: products.length, gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: columns, crossAxisSpacing: 12, mainAxisSpacing: 12, childAspectRatio: .72), itemBuilder: (_, i) { final p = products[i]; return _SaleProduct(product: p, count: quantityFor(p.id!), onAdd: () => add(p), onMinus: () => change(p, -1)); }); });
  Future<void> _scan(BuildContext context) async { final c = TextEditingController(); final v = await showDialog<String>(context: context, builder: (_) => AlertDialog(title: const Text('Find product'), content: TextField(controller: c, autofocus: true, decoration: const InputDecoration(labelText: 'Barcode or SKU')), actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')), FilledButton(onPressed: () => Navigator.pop(context, c.text.trim()), child: const Text('Find'))])); c.dispose(); if (v?.isNotEmpty == true) { query = v!; refresh(); } }
  void _showCart(BuildContext context) => showModalBottomSheet<void>(context: context, isScrollControlled: true, showDragHandle: true, builder: (_) => SafeArea(child: SizedBox(height: MediaQuery.sizeOf(context).height * .72, child: Padding(padding: const EdgeInsets.all(16), child: _CartPanel(cart: cart, total: total, products: products, onChange: change, onClear: () => setState(cart.clear), onCheckout: () { Navigator.pop(context); _checkout(context); }))));
  Future<void> _checkout(BuildContext context) async {
    if (cart.isEmpty) return;
    final customer = TextEditingController(text: 'Walk-in Customer');
    String payment = 'Cash';
    final ok = await showDialog<bool>(context: context, builder: (_) => StatefulBuilder(builder: (context, setDialog) => AlertDialog(title: const Text('Checkout', style: TextStyle(fontWeight: FontWeight.w900)), content: SingleChildScrollView(child: Column(mainAxisSize: MainAxisSize.min, children: [Text('Total ${pmoney(total)}', style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900)), const SizedBox(height: 14), TextField(controller: customer, decoration: const InputDecoration(labelText: 'Customer (optional)')), const SizedBox(height: 10), DropdownButtonFormField<String>(initialValue: payment, decoration: const InputDecoration(labelText: 'Payment method'), items: const [DropdownMenuItem(value: 'Cash', child: Text('Cash')), DropdownMenuItem(value: 'UPI', child: Text('UPI')), DropdownMenuItem(value: 'Card', child: Text('Card')), DropdownMenuItem(value: 'Bank transfer', child: Text('Bank transfer')), DropdownMenuItem(value: 'Credit / Due', child: Text('Credit / Due'))], onChanged: (v) => setDialog(() => payment = v ?? 'Cash'))])), actions: [TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')), FilledButton.icon(onPressed: () => Navigator.pop(context, true), icon: const Icon(Icons.check_rounded), label: const Text('Complete sale'))])));
    if (ok != true) { customer.dispose(); return; }
    try { await AppDatabase.instance.sellCart(cart, customer: customer.text.trim().isEmpty ? 'Walk-in Customer' : customer.text.trim(), payment: payment); customer.dispose(); if (!mounted) return; setState(cart.clear); await refresh(); ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Sale completed • stock updated'))); } catch (e) { customer.dispose(); if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Sale failed: $e'))); }
  }
}

class _SaleProduct extends StatelessWidget {
  final Product product;
  final int count;
  final VoidCallback onAdd;
  final VoidCallback onMinus;
  const _SaleProduct({required this.product, required this.count, required this.onAdd, required this.onMinus});
  @override
  Widget build(BuildContext context) => Card(clipBehavior: Clip.antiAlias, child: Padding(padding: const EdgeInsets.all(10), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Expanded(child: _RemoteImage(product: product, radius: 18)), const SizedBox(height: 9), Text(product.brand, style: const TextStyle(color: _muted, fontSize: 11)), Text(product.name, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 14)), const SizedBox(height: 5), Row(children: [Expanded(child: Text(pmoney(product.sellingPrice), style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16))), if (count == 0) IconButton(onPressed: product.quantity == 0 ? null : onAdd, style: IconButton.styleFrom(backgroundColor: product.quantity == 0 ? Colors.grey.shade200 : _blue, foregroundColor: Colors.white), icon: const Icon(Icons.add_rounded)) else Row(children: [IconButton(onPressed: onMinus, icon: const Icon(Icons.remove_circle_outline_rounded)), Text('$count', style: const TextStyle(fontWeight: FontWeight.w900)), IconButton(onPressed: count >= product.quantity ? null : onAdd, icon: const Icon(Icons.add_circle_rounded, color: _blue))])])])));
}

class _MiniCartButton extends StatelessWidget {
  final int count;
  final double total;
  final VoidCallback onTap;
  const _MiniCartButton({required this.count, required this.total, required this.onTap});
  @override
  Widget build(BuildContext context) => SizedBox(height: 48, child: Align(alignment: Alignment.centerRight, child: FilledButton.tonalIcon(onPressed: count == 0 ? null : onTap, icon: const Icon(Icons.shopping_bag_outlined), label: Text(count == 0 ? 'Cart · ₹0' : '$count items · ${pmoney(total)}'))));
}

class _CartPanel extends StatelessWidget {
  final List<Map<String, Object?>> cart;
  final List<Product> products;
  final double total;
  final void Function(Product, int) onChange;
  final VoidCallback onClear;
  final VoidCallback onCheckout;
  const _CartPanel({required this.cart, required this.products, required this.total, required this.onChange, required this.onClear, required this.onCheckout});
  @override
  Widget build(BuildContext context) => Card(child: Padding(padding: const EdgeInsets.all(15), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Row(children: [const Expanded(child: Text('Current order', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900))), if (cart.isNotEmpty) TextButton(onPressed: onClear, child: const Text('Clear'))]), const SizedBox(height: 8), Expanded(child: cart.isEmpty ? const _Empty(title: 'Cart is empty', subtitle: 'Add a product to start billing.', icon: Icons.shopping_bag_outlined) : ListView.separated(itemCount: cart.length, separatorBuilder: (_, __) => const Divider(height: 1), itemBuilder: (_, i) { final x = cart[i]; final id = x['product_id'] as int; final p = products.where((p) => p.id == id).firstOrNull; return ListTile(contentPadding: EdgeInsets.zero, leading: _SuggestionImage(x['image_url']?.toString() ?? ''), title: Text(x['name'].toString(), maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.w800)), subtitle: Text('${x['quantity']} × ${pmoney(x['price'] as num)}'), trailing: p == null ? IconButton(onPressed: () {}, icon: const Icon(Icons.delete_outline)) : Row(mainAxisSize: MainAxisSize.min, children: [IconButton(onPressed: () => onChange(p, -1), icon: const Icon(Icons.remove_circle_outline)), Text('${x['quantity']}', style: const TextStyle(fontWeight: FontWeight.w900)), IconButton(onPressed: () => onChange(p, 1), icon: const Icon(Icons.add_circle_outline, color: _blue))]); }))]), const Divider(), Row(children: [const Expanded(child: Text('Total', style: TextStyle(color: _muted))), Text(pmoney(total), style: const TextStyle(fontSize: 21, fontWeight: FontWeight.w900))]), const SizedBox(height: 10), SizedBox(width: double.infinity, height: 50, child: FilledButton(onPressed: cart.isEmpty ? null : onCheckout, child: const Text('Checkout')))])));
}

class PremiumPurchases extends StatelessWidget {
  const PremiumPurchases({super.key});
  @override
  Widget build(BuildContext context) => _Page(child: ListView(children: [const _Header(title: 'Purchases', subtitle: 'Receive stock and keep supplier costs organised.'), const SizedBox(height: 18), _ActionTile(icon: Icons.add_shopping_cart_rounded, title: 'New purchase', subtitle: 'Receive stock into an existing product.', color: _blue, onTap: () => _newPurchase(context)), _ActionTile(icon: Icons.business_rounded, title: 'Suppliers', subtitle: 'Manage supplier contacts and balances.', color: _violet, onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const _SuppliersPage()))), _ActionTile(icon: Icons.receipt_long_rounded, title: 'Purchase history', subtitle: 'Review supplier invoices and totals.', color: _orange, onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const _PurchaseHistoryPage())))]));
  Future<void> _newPurchase(BuildContext context) async { final products = await AppDatabase.instance.products(); if (!context.mounted) return; await showModalBottomSheet<void>(context: context, showDragHandle: true, isScrollControlled: true, builder: (_) => _PurchaseSheet(products: products)); }
}

class _PurchaseSheet extends StatefulWidget {
  final List<Product> products;
  const _PurchaseSheet({required this.products});
  @override
  State<_PurchaseSheet> createState() => _PurchaseSheetState();
}
class _PurchaseSheetState extends State<_PurchaseSheet> {
  Product? product;
  final qty = TextEditingController(text: '1');
  final price = TextEditingController();
  final supplier = TextEditingController(text: 'Supplier');
  final invoice = TextEditingController(text: 'PUR-${DateTime.now().millisecondsSinceEpoch % 100000}');
  @override
  void dispose() { qty.dispose(); price.dispose(); supplier.dispose(); invoice.dispose(); super.dispose(); }
  @override
  Widget build(BuildContext context) => Padding(padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom), child: SingleChildScrollView(padding: const EdgeInsets.all(18), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [const Text('New purchase', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900)), const SizedBox(height: 16), DropdownButtonFormField<Product>(initialValue: product, decoration: const InputDecoration(labelText: 'Product'), items: [for (final p in widget.products) DropdownMenuItem(value: p, child: Text('${p.brand} · ${p.name}', overflow: TextOverflow.ellipsis))], onChanged: (v) => setState(() { product = v; price.text = v?.purchasePrice.toStringAsFixed(0) ?? ''; })), const SizedBox(height: 10), Row(children: [Expanded(child: TextField(controller: qty, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Quantity'))), const SizedBox(width: 10), Expanded(child: TextField(controller: price, keyboardType: const TextInputType.numberWithOptions(decimal: true), decoration: const InputDecoration(labelText: 'Unit cost'))]), const SizedBox(height: 10), TextField(controller: supplier, decoration: const InputDecoration(labelText: 'Supplier')), const SizedBox(height: 10), TextField(controller: invoice, decoration: const InputDecoration(labelText: 'Invoice')), const SizedBox(height: 18), SizedBox(width: double.infinity, height: 50, child: FilledButton(onPressed: product == null ? null : () async { await AppDatabase.instance.purchase(supplier: supplier.text.trim(), invoice: invoice.text.trim(), payment: 'Cash', paid: (double.tryParse(price.text) ?? 0) * (int.tryParse(qty.text) ?? 0), items: [{'product_id': product!.id!, 'quantity': int.tryParse(qty.text) ?? 0, 'price': double.tryParse(price.text) ?? 0}]); if (context.mounted) Navigator.pop(context); }, child: const Text('Receive stock')))])));
}

class _PurchaseHistoryPage extends StatefulWidget { const _PurchaseHistoryPage(); @override State<_PurchaseHistoryPage> createState() => _PurchaseHistoryPageState(); }
class _PurchaseHistoryPageState extends State<_PurchaseHistoryPage> { List<Map<String,Object?>> rows = const []; @override void initState(){super.initState();load();} Future<void> load() async { final r=await AppDatabase.instance.purchases(); if(mounted)setState(()=>rows=r); } @override Widget build(BuildContext context)=>Scaffold(appBar:AppBar(title:const Text('Purchase history')),body:ListView.builder(padding:const EdgeInsets.all(16),itemCount:rows.length,itemBuilder:(_,i){final r=rows[i];return Card(child:ListTile(title:Text('${r['supplier']}',style:const TextStyle(fontWeight:FontWeight.w800)),subtitle:Text('${r['invoice']} • ${r['date']}'),trailing:Text(pmoney(r['total'] as num),style:const TextStyle(fontWeight:FontWeight.w900)));}));} }

class PremiumMore extends StatelessWidget {
  const PremiumMore({super.key});
  @override
  Widget build(BuildContext context) => _Page(child: ListView(children: [const _Header(title: 'More', subtitle: 'Customers, suppliers, expenses, reports and settings.'), const SizedBox(height: 18), _ActionTile(icon: Icons.people_alt_outlined, title: 'Customers', subtitle: 'Profiles, purchase history and balances.', color: _blue, onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const _CustomersPage()))), _ActionTile(icon: Icons.local_shipping_outlined, title: 'Suppliers', subtitle: 'Supplier contacts and purchase history.', color: _violet, onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const _SuppliersPage()))), _ActionTile(icon: Icons.receipt_long_outlined, title: 'Expenses', subtitle: 'Record rent, electricity, salary and more.', color: _orange, onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const _ExpensesPage()))), _ActionTile(icon: Icons.bar_chart_rounded, title: 'Reports & analytics', subtitle: 'Monthly sales, gross profit, expenses and stock.', color: _green, onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const _ReportsPage()))), _ActionTile(icon: Icons.backup_rounded, title: 'Backup & Restore', subtitle: 'Copy your shop data as JSON.', color: const Color(0xFF3D7DD8), onTap: () => _backup(context)), _ActionTile(icon: Icons.settings_outlined, title: 'Settings', subtitle: 'Shop profile and default preferences.', color: _muted, onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const _SettingsPage())))]));
  Future<void> _backup(BuildContext context) async { final db = await AppDatabase.instance.db; final products = await db.query('products'); final customers = await db.query('customers'); final suppliers = await db.query('suppliers'); final data = {'products': products, 'customers': customers, 'suppliers': suppliers}; await Clipboard.setData(ClipboardData(text: data.toString())); if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Backup JSON copied to clipboard'))); }
}

class _ActionTile extends StatelessWidget { final IconData icon; final String title, subtitle; final Color color; final VoidCallback onTap; const _ActionTile({required this.icon, required this.title, required this.subtitle, required this.color, required this.onTap}); @override Widget build(BuildContext context)=>Card(margin:const EdgeInsets.only(bottom:10),child:ListTile(onTap:onTap,contentPadding:const EdgeInsets.symmetric(horizontal:16,vertical:7),leading:Container(width:46,height:46,decoration:BoxDecoration(color:color.withAlpha(18),borderRadius:BorderRadius.circular(14)),child:Icon(icon,color:color)),title:Text(title,style:const TextStyle(fontWeight:FontWeight.w900)),subtitle:Text(subtitle,style:const TextStyle(color:_muted,fontSize:12)),trailing:const Icon(Icons.chevron_right_rounded,color:_muted))); }

class _CustomersPage extends StatefulWidget { const _CustomersPage(); @override State<_CustomersPage> createState()=>_CustomersPageState(); }
class _CustomersPageState extends State<_CustomersPage>{List<Map<String,Object?>> rows=const[];final name=TextEditingController();final phone=TextEditingController();@override void initState(){super.initState();load();}@override void dispose(){name.dispose();phone.dispose();super.dispose();}Future<void>load()async{final r=await(AppDatabase.instance.db).then((d)=>d.query('customers',orderBy:'name',limit:500));if(mounted)setState(()=>rows=r);}Future<void>add()async{await showDialog<void>(context:context,builder:(_)=>AlertDialog(title:const Text('Add customer'),content:Column(mainAxisSize:MainAxisSize.min,children:[TextField(controller:name,decoration:const InputDecoration(labelText:'Name')),const SizedBox(height:8),TextField(controller:phone,keyboardType:TextInputType.phone,decoration:const InputDecoration(labelText:'Phone'))]),actions:[TextButton(onPressed:()=>Navigator.pop(context),child:const Text('Cancel')),FilledButton(onPressed:()async{await(AppDatabase.instance.db).then((d)=>d.insert('customers',{'name':name.text.trim(),'phone':phone.text.trim()}));name.clear();phone.clear();if(context.mounted)Navigator.pop(context);load();},child:const Text('Save'))]));}@override Widget build(BuildContext context)=>Scaffold(appBar:AppBar(title:const Text('Customers'),actions:[IconButton(onPressed:add,icon:const Icon(Icons.add_rounded))]),body:ListView.builder(padding:const EdgeInsets.all(14),itemCount:rows.length,itemBuilder:(_,i){final r=rows[i];return Card(child:ListTile(leading:const CircleAvatar(child:Icon(Icons.person_outline)),title:Text('${r['name']}',style:const TextStyle(fontWeight:FontWeight.w800)),subtitle:Text('${r['phone'] ?? ''}'),));}));}

class _SuppliersPage extends StatefulWidget { const _SuppliersPage(); @override State<_SuppliersPage> createState()=>_SuppliersPageState(); }
class _SuppliersPageState extends State<_SuppliersPage>{List<Map<String,Object?>> rows=const[];@override void initState(){super.initState();load();}Future<void>load()async{final r=await(AppDatabase.instance.db).then((d)=>d.query('suppliers',orderBy:'name',limit:500));if(mounted)setState(()=>rows=r);}@override Widget build(BuildContext context)=>Scaffold(appBar:AppBar(title:const Text('Suppliers')),body:ListView.builder(padding:const EdgeInsets.all(14),itemCount:rows.length,itemBuilder:(_,i){final r=rows[i];return Card(child:ListTile(leading:const CircleAvatar(child:Icon(Icons.local_shipping_outlined)),title:Text('${r['name']}',style:const TextStyle(fontWeight:FontWeight.w800)),subtitle:Text('${r['phone'] ?? ''} • ${r['email'] ?? ''}'))); }));}

class _ExpensesPage extends StatefulWidget { const _ExpensesPage(); @override State<_ExpensesPage> createState()=>_ExpensesPageState(); }
class _ExpensesPageState extends State<_ExpensesPage>{List<Map<String,Object?>> rows=const[];final amount=TextEditingController();String category='Other';String payment='Cash';@override void initState(){super.initState();load();}@override void dispose(){amount.dispose();super.dispose();}Future<void>load()async{final r=await AppDatabase.instance.expenses();if(mounted)setState(()=>rows=r);}Future<void>add()async{await showDialog<void>(context:context,builder:(_)=>StatefulBuilder(builder:(context,set){return AlertDialog(title:const Text('Add expense'),content:Column(mainAxisSize:MainAxisSize.min,children:[DropdownButtonFormField<String>(initialValue:category,items:const['Rent','Electricity','Salary','Transport','Repairs','Marketing','Other'].map((x)=>DropdownMenuItem(value:x,child:Text(x))).toList(),onChanged:(v)=>set(()=>category=v??'Other')),const SizedBox(height:8),TextField(controller:amount,keyboardType:const TextInputType.numberWithOptions(decimal:true),decoration:const InputDecoration(labelText:'Amount')),const SizedBox(height:8),DropdownButtonFormField<String>(initialValue:payment,items:const['Cash','UPI','Card','Bank transfer'].map((x)=>DropdownMenuItem(value:x,child:Text(x))).toList(),onChanged:(v)=>set(()=>payment=v??'Cash'))]),actions:[TextButton(onPressed:()=>Navigator.pop(context),child:const Text('Cancel')),FilledButton(onPressed:()async{await AppDatabase.instance.addExpense(category,double.tryParse(amount.text)??0,payment,'');amount.clear();if(context.mounted)Navigator.pop(context);load();},child:const Text('Save'))]);}));}@override Widget build(BuildContext context)=>Scaffold(appBar:AppBar(title:const Text('Expenses'),actions:[IconButton(onPressed:add,icon:const Icon(Icons.add_rounded))]),body:ListView.builder(padding:const EdgeInsets.all(14),itemCount:rows.length,itemBuilder:(_,i){final r=rows[i];return Card(child:ListTile(title:Text('${r['category']}',style:const TextStyle(fontWeight:FontWeight.w800)),subtitle:Text('${r['date']} • ${r['payment']}'),trailing:Text(pmoney(r['amount'] as num),style:const TextStyle(fontWeight:FontWeight.w900)));}));}

class _ReportsPage extends StatefulWidget { const _ReportsPage(); @override State<_ReportsPage> createState()=>_ReportsPageState(); }
class _ReportsPageState extends State<_ReportsPage>{Map<String,num> data=const{};@override void initState(){super.initState();load();}Future<void>load()async{final r=await AppDatabase.instance.monthly();if(mounted)setState(()=>data=r);}@override Widget build(BuildContext context)=>Scaffold(appBar:AppBar(title:const Text('Reports & analytics')),body:ListView(padding:const EdgeInsets.all(16),children:[_ReportCard('Sales this month',pmoney(data['sales']??0),_green),_ReportCard('Gross profit',pmoney(data['gross']??0),_blue),_ReportCard('Expenses',pmoney(data['expenses']??0),_orange),_ReportCard('Net profit',pmoney(data['net']??0),_violet),_ReportCard('Inventory value',pmoney(data['inventory']??0),_blue),_ReportCard('Units in stock','${data['stock']??0}',_green)]));}
class _ReportCard extends StatelessWidget{final String title,value;final Color color;const _ReportCard(this.title,this.value,this.color);@override Widget build(BuildContext context)=>Card(margin:const EdgeInsets.only(bottom:10),child:ListTile(leading:Container(width:44,height:44,decoration:BoxDecoration(color:color.withAlpha(18),borderRadius:BorderRadius.circular(14)),child:Icon(Icons.insights_rounded,color:color)),title:Text(title,style:const TextStyle(color:_muted)),subtitle:Text(value,style:const TextStyle(fontSize:22,fontWeight:FontWeight.w900,color:_ink))));}

class _SettingsPage extends StatefulWidget{const _SettingsPage();@override State<_SettingsPage>createState()=>_SettingsPageState();}
class _SettingsPageState extends State<_SettingsPage>{final shop=TextEditingController(text:'ElectroMart');final gst=TextEditingController(text:'18');@override void dispose(){shop.dispose();gst.dispose();super.dispose();}Future<void>save()async{final d=await AppDatabase.instance.db;await d.insert('settings',{'key':'shop_name','value':shop.text.trim()},conflictAlgorithm:ConflictAlgorithm.replace);await d.insert('settings',{'key':'default_gst','value':gst.text.trim()},conflictAlgorithm:ConflictAlgorithm.replace);if(mounted)ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content:Text('Settings saved')));}@override Widget build(BuildContext context)=>Scaffold(appBar:AppBar(title:const Text('Settings')),body:ListView(padding:const EdgeInsets.all(16),children:[const Text('Shop profile',style:TextStyle(fontSize:19,fontWeight:FontWeight.w900)),const SizedBox(height:10),TextField(controller:shop,decoration:const InputDecoration(labelText:'Shop name')),const SizedBox(height:10),TextField(controller:gst,keyboardType:TextInputType.number,decoration:const InputDecoration(labelText:'Default GST %')),const SizedBox(height:16),SizedBox(height:50,child:FilledButton(onPressed:save,child:const Text('Save settings')))]));}

class _ProductDetails extends StatelessWidget { final Product product; final Future<void> Function() refresh; const _ProductDetails({required this.product,required this.refresh});@override Widget build(BuildContext context)=>SafeArea(child:Padding(padding:const EdgeInsets.fromLTRB(18,0,18,24),child:Column(mainAxisSize:MainAxisSize.min,children:[Row(children:[_RemoteImage(product:product,size:74,radius:18),const SizedBox(width:12),Expanded(child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[Text(product.name,style:const TextStyle(fontSize:20,fontWeight:FontWeight.w900)),Text('${product.brand} • ${product.sku}',style:const TextStyle(color:_muted))])),_Status(product.status)]),const SizedBox(height:18),Row(children:[Expanded(child:_MiniStat('Selling',pmoney(product.sellingPrice))),Expanded(child:_MiniStat('Purchase',pmoney(product.purchasePrice))),Expanded(child:_MiniStat('Stock','${product.quantity}'))]),const SizedBox(height:18),Row(children:[Expanded(child:OutlinedButton.icon(onPressed:()async{Navigator.pop(context);await AppDatabase.instance.adjustStock(product.id,1,'ADJUSTMENT','Manual stock addition');await refresh();},icon:const Icon(Icons.add),label:const Text('Add stock'))),const SizedBox(width:10),Expanded(child:OutlinedButton.icon(onPressed:product.quantity==0?null:()async{Navigator.pop(context);await AppDatabase.instance.adjustStock(product.id,-1,'ADJUSTMENT','Manual stock removal');await refresh();},icon:const Icon(Icons.remove),label:const Text('Remove stock')))])])));
}
class _MiniStat extends StatelessWidget{final String title,value;const _MiniStat(this.title,this.value);@override Widget build(BuildContext context)=>Column(crossAxisAlignment:CrossAxisAlignment.start,children:[Text(title,style:const TextStyle(color:_muted,fontSize:11)),const SizedBox(height:4),Text(value,style:const TextStyle(fontWeight:FontWeight.w900))]);}

class _ProductCard extends StatelessWidget { final Product product; final VoidCallback? onTap; const _ProductCard({required this.product,this.onTap}); @override Widget build(BuildContext context)=>Card(clipBehavior:Clip.antiAlias,child:InkWell(onTap:onTap,child:Padding(padding:const EdgeInsets.all(10),child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[Expanded(child:_RemoteImage(product:product,radius:18)),const SizedBox(height:9),Text(product.brand,style:const TextStyle(color:_muted,fontSize:11)),Text(product.name,maxLines:2,overflow:TextOverflow.ellipsis,style:const TextStyle(fontWeight:FontWeight.w900)),const SizedBox(height:5),Row(children:[Expanded(child:Text(pmoney(product.sellingPrice),style:const TextStyle(fontWeight:FontWeight.w900,fontSize:16))),_Status(product.status)])]))));}

class _RemoteImage extends StatefulWidget { final Product? product; final double size; final double radius; const _RemoteImage({this.product,this.size=180,this.radius=18}); @override State<_RemoteImage> createState()=>_RemoteImageState(); }
class _RemoteImageState extends State<_RemoteImage>{String? url;@override void initState(){super.initState();url=widget.product?.imageUrl.trim();if(url==null||url!.isEmpty)_load();}Future<void>_load()async{final p=widget.product;if(p==null)return;final u=await ProductCatalogService.findImage(p.name,brand:p.brand,category:p.category);if(mounted&&u!=null)setState(()=>url=u);}@override Widget build(BuildContext context){final fallback=Container(width:widget.size,height:widget.size,decoration:BoxDecoration(color:const Color(0xFFF1F3F8),borderRadius:BorderRadius.circular(widget.radius)),child:Icon(_categoryIcon(widget.product?.category??''),size:widget.size*.28,color:_ink));if(url==null||url!.isEmpty)return fallback;return ClipRRect(borderRadius:BorderRadius.circular(widget.radius),child:Image.network(url!,width:widget.size,height:widget.size,fit:BoxFit.contain,errorBuilder:(_,__,___)=>fallback,loadingBuilder:(_,child,p)=>p==null?child:fallback));}}

class _ProductRow extends StatelessWidget{final Product product;const _ProductRow({required this.product});@override Widget build(BuildContext context)=>Card(margin:const EdgeInsets.only(bottom:8),child:ListTile(leading:_RemoteImage(product:product,size:48,radius:13),title:Text('${product.brand} · ${product.name}',style:const TextStyle(fontWeight:FontWeight.w800)),subtitle:Text('${product.quantity} units left • ${product.sku}'),trailing:_Status(product.status)));}
class _Status extends StatelessWidget{final String value;const _Status(this.value);@override Widget build(BuildContext context){final c=value=='IN STOCK'?_green:value=='LOW STOCK'?_orange:_red;return Container(padding:const EdgeInsets.symmetric(horizontal:9,vertical:6),decoration:BoxDecoration(color:c.withAlpha(18),borderRadius:BorderRadius.circular(30)),child:Text(value,style:TextStyle(color:c,fontSize:9,fontWeight:FontWeight.w900)));}}
class _Empty extends StatelessWidget{final String title,subtitle;final IconData icon;const _Empty({required this.title,required this.subtitle,required this.icon});@override Widget build(BuildContext context)=>Card(child:Padding(padding:const EdgeInsets.all(22),child:Row(children:[Container(width:48,height:48,decoration:BoxDecoration(color:_background,borderRadius:BorderRadius.circular(15)),child:Icon(icon,color:_muted)),const SizedBox(width:14),Expanded(child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[Text(title,style:const TextStyle(fontWeight:FontWeight.w900)),const SizedBox(height:3),Text(subtitle,style:const TextStyle(color:_muted,fontSize:12))]))]));}

IconData _categoryIcon(String value){final c=value.toLowerCase();if(c.contains('mobile'))return Icons.smartphone_outlined;if(c.contains('laptop'))return Icons.laptop_mac_outlined;if(c.contains('television'))return Icons.tv_outlined;if(c.contains('refriger'))return Icons.kitchen_outlined;if(c.contains('audio'))return Icons.headphones_outlined;if(c.contains('camera'))return Icons.photo_camera_outlined;if(c.contains('printer'))return Icons.print_outlined;if(c.contains('network'))return Icons.router_outlined;if(c.contains('storage'))return Icons.storage_outlined;return Icons.devices_other_outlined;}

extension<T> on Iterable<T>{T? get firstOrNull=>isEmpty?null:first;}
