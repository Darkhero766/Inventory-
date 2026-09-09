import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'data/database.dart';
import 'models/models.dart';
import 'services/product_catalog_service.dart';

const _primary = Color(0xFF3D5AFE);
const _purple = Color(0xFF7C4DFF);
const _teal = Color(0xFF00B8A9);
const _orange = Color(0xFFF59E0B);
const _ink = Color(0xFF171923);
const _muted = Color(0xFF777B87);
const _background = Color(0xFFF4F6FA);

String money(num value) => NumberFormat.currency(locale: 'en_IN', symbol: '₹', decimalDigits: 0).format(value);

void main() => runApp(const InventoryApp(loadDatabase: true));

class InventoryApp extends StatelessWidget {
  final bool loadDatabase;
  const InventoryApp({super.key, this.loadDatabase = false});
  @override
  Widget build(BuildContext context) => MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Inventory',
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(seedColor: _primary),
          scaffoldBackgroundColor: _background,
          fontFamily: 'Inter',
          textTheme: const TextTheme(
            headlineLarge: TextStyle(fontSize: 31, fontWeight: FontWeight.w900, color: _ink, letterSpacing: -1),
            headlineMedium: TextStyle(fontSize: 26, fontWeight: FontWeight.w900, color: _ink, letterSpacing: -.7),
            titleLarge: TextStyle(fontSize: 19, fontWeight: FontWeight.w900, color: _ink),
            titleMedium: TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: _ink),
            bodyMedium: TextStyle(fontSize: 14, color: _muted),
          ),
          cardTheme: CardThemeData(elevation: 0, color: Colors.white, margin: EdgeInsets.zero, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22))),
          navigationBarTheme: NavigationBarThemeData(height: 78, backgroundColor: Colors.white, indicatorColor: _primary.withAlpha(22), labelTextStyle: const WidgetStatePropertyAll(TextStyle(fontSize: 12, fontWeight: FontWeight.w800))),
          inputDecorationTheme: InputDecorationTheme(
            filled: true, fillColor: Colors.white, contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15), hintStyle: const TextStyle(color: Color(0xFF9B9FAA), fontSize: 14),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(17), borderSide: BorderSide.none),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(17), borderSide: BorderSide.none),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(17), borderSide: const BorderSide(color: _primary, width: 1.4)),
          ),
        ),
        home: AppShell(loadDatabase: loadDatabase),
      );
}

class AppShell extends StatefulWidget {
  final bool loadDatabase;
  const AppShell({super.key, this.loadDatabase = false});
  @override State<AppShell> createState() => _AppShellState();
}
class _AppShellState extends State<AppShell> {
  int index = 0;
  static const labels = ['Home', 'Inventory', 'Purchases', 'Sales', 'More'];
  static const icons = [Icons.home_rounded, Icons.inventory_2_rounded, Icons.shopping_bag_rounded, Icons.point_of_sale_rounded, Icons.more_horiz_rounded];
  @override
  Widget build(BuildContext context) {
    final wide = MediaQuery.sizeOf(context).width >= 900;
    final pages = [
      HomePage(loadDatabase: widget.loadDatabase, onInventory: () => setState(() => index = 1)),
      const InventoryPage(), const PurchasesPage(), const SalesPage(), const MorePage(),
    ];
    return Scaffold(
      body: wide
          ? Row(children: [
              SizedBox(width: 232, child: SafeArea(child: Column(children: [
                const SizedBox(height: 22), const Padding(padding: EdgeInsets.symmetric(horizontal: 22), child: _BrandLockup()), const SizedBox(height: 28),
                Expanded(child: NavigationRail(extended: true, minExtendedWidth: 232, selectedIndex: index, onDestinationSelected: (v) => setState(() => index = v), destinations: [for (var i = 0; i < labels.length; i++) NavigationRailDestination(icon: Icon(icons[i]), selectedIcon: Icon(icons[i]), label: Text(labels[i]))])),
                const Padding(padding: EdgeInsets.all(18), child: Text('ElectroMart • 2.1', style: TextStyle(color: _muted, fontSize: 11))),
              ]))),
              const VerticalDivider(width: 1), Expanded(child: pages[index]),
            ])
          : pages[index],
      bottomNavigationBar: wide ? null : NavigationBar(selectedIndex: index, onDestinationSelected: (v) => setState(() => index = v), destinations: [for (var i = 0; i < labels.length; i++) NavigationDestination(icon: Icon(icons[i]), label: labels[i])]),
    );
  }
}

class _BrandLockup extends StatelessWidget {
  const _BrandLockup();
  @override Widget build(BuildContext context) => Row(mainAxisSize: MainAxisSize.min, children: [
    Container(width: 42, height: 42, decoration: BoxDecoration(gradient: const LinearGradient(colors: [_primary, _purple]), borderRadius: BorderRadius.circular(14)), child: const Icon(Icons.bolt_rounded, color: Colors.white)),
    const SizedBox(width: 11), const Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('INVENTORY', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w900, letterSpacing: 1)), Text('ElectroMart', style: TextStyle(fontSize: 11, color: _muted))]),
  ]);
}
class Frame extends StatelessWidget { final Widget child; const Frame({super.key, required this.child}); @override Widget build(BuildContext context) => SafeArea(child: Center(child: ConstrainedBox(constraints: const BoxConstraints(maxWidth: 1480), child: Padding(padding: const EdgeInsets.fromLTRB(22, 20, 22, 24), child: child)))); }
class PageHeader extends StatelessWidget { final String title; final String? subtitle; final Widget? action; const PageHeader({super.key, required this.title, this.subtitle, this.action}); @override Widget build(BuildContext context) => LayoutBuilder(builder: (_, c) { final h = Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(title, style: Theme.of(context).textTheme.headlineMedium), if (subtitle != null) ...[const SizedBox(height: 3), Text(subtitle!, style: const TextStyle(color: _muted))]]); if (action == null) return h; if (c.maxWidth < 620) return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [h, const SizedBox(height: 13), action!]); return Row(children: [Expanded(child: h), action!]); }); }
class SearchBox extends StatelessWidget { final String hint; final ValueChanged<String>? onChanged; final VoidCallback? onScan; const SearchBox({super.key, required this.hint, this.onChanged, this.onScan}); @override Widget build(BuildContext context) => TextField(onChanged: onChanged, decoration: InputDecoration(prefixIcon: const Icon(Icons.search_rounded), hintText: hint, suffixIcon: onScan == null ? null : IconButton(tooltip: 'Scan barcode', onPressed: onScan, icon: const Icon(Icons.qr_code_scanner_rounded)))); }
class StatusBadge extends StatelessWidget { final String status; const StatusBadge(this.status, {super.key}); @override Widget build(BuildContext context) { final color = status == 'IN STOCK' ? const Color(0xFF2E9B62) : status == 'LOW STOCK' ? _orange : const Color(0xFFE04B4B); return Container(padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6), decoration: BoxDecoration(color: color.withAlpha(20), borderRadius: BorderRadius.circular(30)), child: Text(status, style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.w900))); } }

class HomePage extends StatefulWidget {
  final bool loadDatabase; final VoidCallback? onInventory;
  const HomePage({super.key, this.loadDatabase = true, this.onInventory});
  @override State<HomePage> createState() => _HomePageState();
}
class _HomePageState extends State<HomePage> {
  List<Product> products = []; double sales = 0, purchases = 0; bool loading = false;
  @override void initState() { super.initState(); if (widget.loadDatabase) load(); }
  Future<void> load() async {
    if (mounted) setState(() => loading = true);
    try {
      final db = await AppDatabase.instance.db; final list = await AppDatabase.instance.products();
      final s = await db.rawQuery('SELECT COALESCE(SUM(total),0) value FROM sales'); final p = await db.rawQuery('SELECT COALESCE(SUM(total),0) value FROM purchases');
      if (!mounted) return; setState(() { products = list; sales = (s.first['value'] as num?)?.toDouble() ?? 0; purchases = (p.first['value'] as num?)?.toDouble() ?? 0; loading = false; });
    } catch (_) { if (mounted) setState(() => loading = false); }
  }
  @override Widget build(BuildContext context) {
    final low = products.where((p) => p.quantity <= p.minimumStock).take(5).toList(); final value = products.fold<double>(0, (sum, p) => sum + p.quantity * p.purchasePrice);
    return Frame(child: RefreshIndicator(onRefresh: load, child: ListView(physics: const AlwaysScrollableScrollPhysics(), children: [
      Row(children: [Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('Good morning', style: Theme.of(context).textTheme.headlineLarge), const SizedBox(height: 4), const Text('Your shop at a glance.', style: TextStyle(color: _muted))])), if (MediaQuery.sizeOf(context).width > 650) const _StoreChip()]),
      const SizedBox(height: 18), SearchBox(hint: 'Search products, brands, models, SKU or barcode', onScan: () {}), const SizedBox(height: 18), _HeroBanner(products: products.length, onAdd: widget.onInventory), const SizedBox(height: 24),
      const _SectionTitle(title: 'Business snapshot'), const SizedBox(height: 11),
      LayoutBuilder(builder: (_, c) { final columns = c.maxWidth >= 1100 ? 4 : c.maxWidth >= 650 ? 2 : 1; final width = (c.maxWidth - (columns - 1) * 12) / columns; return Wrap(spacing: 12, runSpacing: 12, children: [
        SizedBox(width: width, child: _Metric(title: 'Total sales', value: money(sales), icon: Icons.trending_up_rounded, accent: _teal)), SizedBox(width: width, child: _Metric(title: 'Purchases', value: money(purchases), icon: Icons.shopping_bag_outlined, accent: _purple)), SizedBox(width: width, child: _Metric(title: 'Inventory value', value: money(value), icon: Icons.inventory_2_outlined, accent: _primary, note: '${products.length} products')), SizedBox(width: width, child: _Metric(title: 'Low stock', value: '${low.length}', icon: Icons.warning_amber_rounded, accent: _orange, note: 'Needs attention')),
      ]); }),
      const SizedBox(height: 26), _SectionTitle(title: 'Categories', action: 'View inventory', onAction: widget.onInventory), const SizedBox(height: 10), SizedBox(height: 112, child: ListView.separated(scrollDirection: Axis.horizontal, itemCount: _categories.length, separatorBuilder: (_, __) => const SizedBox(width: 10), itemBuilder: (_, i) => _CategoryCard(_categories[i].$1, _categories[i].$2, _categories[i].$3))),
      const SizedBox(height: 26), _SectionTitle(title: 'Low stock', action: low.isEmpty ? null : 'Review items'), const SizedBox(height: 10), if (low.isEmpty) const _EmptyCard(icon: Icons.check_circle_outline_rounded, title: 'Stock looks healthy', subtitle: 'No products need attention right now.') else for (final p in low) _LowStockTile(product: p),
      const SizedBox(height: 26), const _SectionTitle(title: 'Recently stocked'), const SizedBox(height: 10), SizedBox(height: 246, child: products.isEmpty ? const _EmptyCard(icon: Icons.devices_other_outlined, title: 'No products yet', subtitle: 'Add your first product from Inventory.') : ListView.separated(scrollDirection: Axis.horizontal, itemCount: products.length > 8 ? 8 : products.length, separatorBuilder: (_, __) => const SizedBox(width: 12), itemBuilder: (_, i) => SizedBox(width: 205, child: ProductCard(products[i])))),
      if (loading) const Padding(padding: EdgeInsets.only(top: 10), child: LinearProgressIndicator(minHeight: 2)),
    ])));
  }
}
class _StoreChip extends StatelessWidget { const _StoreChip(); @override Widget build(BuildContext context) => Container(padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 10), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(15)), child: const Row(children: [Icon(Icons.storefront_rounded, size: 18, color: _primary), SizedBox(width: 8), Text('Main Store', style: TextStyle(fontWeight: FontWeight.w800))])); }
class _HeroBanner extends StatelessWidget { final int products; final VoidCallback? onAdd; const _HeroBanner({required this.products, this.onAdd}); @override Widget build(BuildContext context) => Container(padding: const EdgeInsets.fromLTRB(20, 20, 14, 20), decoration: BoxDecoration(gradient: const LinearGradient(colors: [Color(0xFF1B1F3B), Color(0xFF3D5AFE)]), borderRadius: BorderRadius.circular(24)), child: Row(children: [Container(width: 52, height: 52, decoration: BoxDecoration(color: Colors.white.withAlpha(22), borderRadius: BorderRadius.circular(16)), child: const Icon(Icons.auto_awesome_rounded, color: Colors.white)), const SizedBox(width: 14), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [const Text('Everything in one place', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w900)), const SizedBox(height: 4), Text('$products products • inventory, POS and stock control', style: TextStyle(color: Colors.white.withAlpha(200), fontSize: 12))])), if (MediaQuery.sizeOf(context).width > 600) FilledButton.tonalIcon(onPressed: onAdd, icon: const Icon(Icons.add_rounded), label: const Text('Add product'))])); }
class _Metric extends StatelessWidget { final String title, value; final String? note; final IconData icon; final Color accent; const _Metric({required this.title, required this.value, required this.icon, required this.accent, this.note}); @override Widget build(BuildContext context) => Card(child: Padding(padding: const EdgeInsets.all(17), child: Row(children: [Container(width: 44, height: 44, decoration: BoxDecoration(color: accent.withAlpha(18), borderRadius: BorderRadius.circular(14)), child: Icon(icon, color: accent)), const SizedBox(width: 12), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(title, style: const TextStyle(color: _muted, fontSize: 12)), const SizedBox(height: 3), Text(value, style: const TextStyle(fontSize: 21, fontWeight: FontWeight.w900, color: _ink)), if (note != null) Text(note!, style: const TextStyle(color: _muted, fontSize: 10))]))]))); }
class _SectionTitle extends StatelessWidget { final String title; final String? action; final VoidCallback? onAction; const _SectionTitle({required this.title, this.action, this.onAction}); @override Widget build(BuildContext context) => Row(children: [Expanded(child: Text(title, style: Theme.of(context).textTheme.titleLarge)), if (action != null) TextButton(onPressed: onAction, child: Text(action!))]); }
class _CategoryCard extends StatelessWidget { final String name; final IconData icon; final Color accent; const _CategoryCard(this.name, this.icon, this.accent); @override Widget build(BuildContext context) => Container(width: 148, padding: const EdgeInsets.all(14), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(19), border: Border.all(color: accent.withAlpha(28))), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Container(width: 40, height: 40, decoration: BoxDecoration(color: accent.withAlpha(18), borderRadius: BorderRadius.circular(13)), child: Icon(icon, color: accent, size: 21)), const Spacer(), Text(name, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 12))])); }
class _LowStockTile extends StatelessWidget { final Product product; const _LowStockTile({required this.product}); @override Widget build(BuildContext context) => Card(margin: const EdgeInsets.only(bottom: 8), child: ListTile(contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4), leading: ProductImage(product: product, size: 46, radius: 13), title: Text('${product.brand} · ${product.name}', style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14)), subtitle: Text('${product.quantity} units left • ${product.sku}', style: const TextStyle(fontSize: 11)), trailing: StatusBadge(product.status))); }
class _EmptyCard extends StatelessWidget { final IconData icon; final String title, subtitle; const _EmptyCard({required this.icon, required this.title, required this.subtitle}); @override Widget build(BuildContext context) => Card(child: Padding(padding: const EdgeInsets.all(22), child: Row(children: [Container(width: 48, height: 48, decoration: BoxDecoration(color: _background, borderRadius: BorderRadius.circular(14)), child: Icon(icon, color: _muted)), const SizedBox(width: 14), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(title, style: const TextStyle(fontWeight: FontWeight.w800)), const SizedBox(height: 3), Text(subtitle, style: const TextStyle(color: _muted, fontSize: 12))]))]))); }

class ProductImage extends StatefulWidget { final Product product; final double size, radius; const ProductImage({super.key, required this.product, this.size = 120, this.radius = 18}); @override State<ProductImage> createState() => _ProductImageState(); }
class _ProductImageState extends State<ProductImage> {
  String? url;
  @override void initState() { super.initState(); url = widget.product.imageUrl.trim().isEmpty ? null : widget.product.imageUrl; if (url == null) _lookup(); }
  Future<void> _lookup() async { final found = await ProductCatalogService.findImage('${widget.product.brand} ${widget.product.name}'); if (mounted) setState(() => url = found); }
  @override Widget build(BuildContext context) { final fallback = Container(width: widget.size, height: widget.size, decoration: BoxDecoration(color: _background, borderRadius: BorderRadius.circular(widget.radius)), child: Icon(categoryIcon(widget.product.category), size: widget.size * .42, color: _ink)); if (url == null || url!.isEmpty) return fallback; return ClipRRect(borderRadius: BorderRadius.circular(widget.radius), child: Image.network(url!, width: widget.size, height: widget.size, fit: BoxFit.cover, errorBuilder: (_, __, ___) => fallback, loadingBuilder: (_, child, progress) => progress == null ? child : fallback)); }
}
class ProductCard extends StatelessWidget { final Product product; final VoidCallback? onTap; const ProductCard(this.product, {super.key, this.onTap}); @override Widget build(BuildContext context) => Card(clipBehavior: Clip.antiAlias, child: InkWell(onTap: onTap, child: Padding(padding: const EdgeInsets.all(12), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Expanded(child: ProductImage(product: product, size: 180, radius: 17)), const SizedBox(height: 11), Text(product.brand, style: const TextStyle(color: _muted, fontSize: 11, fontWeight: FontWeight.w700)), const SizedBox(height: 2), Text(product.name, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 14)), const SizedBox(height: 7), Row(children: [Expanded(child: Text(money(product.sellingPrice), style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 17))), StatusBadge(product.status)])])))); }

class InventoryPage extends StatefulWidget { const InventoryPage({super.key, this.query, this.category}); final String? query, category; @override State<InventoryPage> createState() => _InventoryPageState(); }
class _InventoryPageState extends State<InventoryPage> {
  List<Product> items = []; String query = ''; bool loading = true;
  @override void initState() { super.initState(); query = widget.query ?? ''; load(); }
  Future<void> load() async { try { final result = await AppDatabase.instance.products(query: query, category: widget.category); if (mounted) setState(() { items = result; loading = false; }); } catch (_) { if (mounted) setState(() { items = []; loading = false; }); } }
  @override Widget build(BuildContext context) => Frame(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    PageHeader(title: widget.category ?? 'Inventory', subtitle: '${items.length} products in your catalog', action: FilledButton.icon(onPressed: () => _showProductForm(context), icon: const Icon(Icons.add_rounded), label: const Text('Add product'))), const SizedBox(height: 17),
    SearchBox(hint: 'Search products, brands, models, SKU or barcode', onChanged: (v) { query = v; load(); }, onScan: () {}), const SizedBox(height: 13),
    Row(children: [const _FilterPill(label: 'All products', selected: true), const SizedBox(width: 8), const _FilterPill(label: 'Low stock'), const SizedBox(width: 8), const _FilterPill(label: 'Out of stock'), const Spacer(), Text('${items.length} results', style: const TextStyle(color: _muted, fontSize: 12))]), const SizedBox(height: 14),
    Expanded(child: loading ? const Center(child: CircularProgressIndicator()) : items.isEmpty ? const _EmptyCard(icon: Icons.inventory_2_outlined, title: 'No products found', subtitle: 'Try another search or add a new product.') : LayoutBuilder(builder: (_, c) { final columns = c.maxWidth >= 1250 ? 4 : c.maxWidth >= 760 ? 3 : 2; return GridView.builder(itemCount: items.length, gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: columns, crossAxisSpacing: 14, mainAxisSpacing: 14, childAspectRatio: .77), itemBuilder: (_, i) => ProductCard(items[i], onTap: () => showProductDetails(context, items[i], load))); })),
  ]));
  Future<void> _showProductForm(BuildContext context) async { final draft = await showDialog<_ProductDraft>(context: context, builder: (_) => const _ProductFormDialog()); if (draft == null) return; try { await AppDatabase.instance.addProduct(draft.toMap()); await load(); if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Product added to inventory.'))); } catch (e) { if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Could not save product: $e'))); } }
}
class _FilterPill extends StatelessWidget { final String label; final bool selected; const _FilterPill({required this.label, this.selected = false}); @override Widget build(BuildContext context) => Container(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8), decoration: BoxDecoration(color: selected ? _primary.withAlpha(14) : Colors.white, borderRadius: BorderRadius.circular(30), border: Border.all(color: selected ? _primary.withAlpha(38) : const Color(0xFFE6E8EF))), child: Text(label, style: TextStyle(color: selected ? _primary : _muted, fontWeight: FontWeight.w800, fontSize: 11))); }

class _ProductDraft {
  final String name, brand, category, model, sku, imageUrl; final double purchase, selling, mrp; final int quantity, minimum;
  const _ProductDraft({required this.name, required this.brand, required this.category, required this.model, required this.sku, required this.imageUrl, required this.purchase, required this.selling, required this.mrp, required this.quantity, required this.minimum});
  Map<String, Object?> toMap() => {'name': name, 'brand': brand, 'category': category, 'model': model, 'sku': sku, 'barcode': '', 'image_url': imageUrl, 'mrp': mrp, 'selling_price': selling, 'purchase_price': purchase, 'quantity': quantity, 'minimum_stock': minimum, 'supplier': '', 'warranty': '1 Year', 'gst_rate': 18, 'hsn_code': '', 'location': 'Main Store', 'rack': '', 'shelf': '', 'serial_tracking': 0, 'imei_tracking': category == 'Mobile Phones' ? 1 : 0, 'specs': '', 'notes': '', 'archived': 0};
}
class _ProductFormDialog extends StatefulWidget { const _ProductFormDialog(); @override State<_ProductFormDialog> createState() => _ProductFormDialogState(); }
class _ProductFormDialogState extends State<_ProductFormDialog> {
  final formKey = GlobalKey<FormState>();
  final name = TextEditingController(), model = TextEditingController(), sku = TextEditingController(text: 'NEW-${DateTime.now().millisecondsSinceEpoch % 100000}'), purchase = TextEditingController(), selling = TextEditingController(), mrp = TextEditingController(), quantity = TextEditingController(text: '0'), minimum = TextEditingController(text: '2');
  String brand = 'Samsung', category = 'Mobile Phones', imageUrl = ''; List<ProductSuggestion> suggestions = const []; bool searching = false;
  static const brands = ['Samsung','LG','Sony','Apple','OnePlus','Motorola','Xiaomi','HP','Dell','Lenovo','ASUS','Acer','MSI','Whirlpool','IFB','Bosch','Haier','Voltas','Daikin','Blue Star','JBL','boAt','Bose','Canon','Nikon','Epson','TP-Link','D-Link','Tenda','Logitech','Razer','Kingston','SanDisk','Seagate','Western Digital','Philips','Havells','Bajaj','Crompton','Oppo','Realme'];
  static const categories = ['Mobile Phones','Laptops','Televisions','Refrigerators','Air Conditioners','Washing Machines','Audio','Cameras','Printers','Networking','Storage','Accessories','Monitors','Gaming','Smartwatches','Kitchen Appliances','Fans','Coolers','Projectors','Power & Cables'];
  @override void dispose() { for (final c in [name, model, sku, purchase, selling, mrp, quantity, minimum]) { c.dispose(); } super.dispose(); }
  Future<void> searchInternet(String value) async { if (value.trim().length < 3) { if (mounted) setState(() => suggestions = const []); return; } setState(() => searching = true); final result = await ProductCatalogService.suggest(query: value, brand: brand, category: category); if (mounted) setState(() { suggestions = result; searching = false; }); }
  void choose(ProductSuggestion item) { name.text = item.title; model.text = item.title; imageUrl = item.imageUrl; setState(() => suggestions = const []); }
  @override Widget build(BuildContext context) => AlertDialog(
    title: const Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('Add product', style: TextStyle(fontWeight: FontWeight.w900)), SizedBox(height: 3), Text('Choose type + brand first, then enter the model.', style: TextStyle(fontSize: 12, color: _muted, fontWeight: FontWeight.normal))]),
    content: SizedBox(width: 620, child: Form(key: formKey, child: SingleChildScrollView(child: Column(children: [
      Row(children: [Expanded(child: _dropdown('Product type', category, categories, (v) => setState(() => category = v!))), const SizedBox(width: 10), Expanded(child: _dropdown('Brand', brand, brands, (v) => setState(() => brand = v!)))]), const SizedBox(height: 10),
      TextFormField(controller: name, onChanged: searchInternet, validator: (v) => v == null || v.trim().isEmpty ? 'Enter a product/model name' : null, decoration: const InputDecoration(labelText: 'Product / model name', hintText: 'e.g. Galaxy S25 Ultra', prefixIcon: Icon(Icons.auto_awesome_rounded))),
      if (searching) const Padding(padding: EdgeInsets.only(top: 9), child: LinearProgressIndicator(minHeight: 2)),
      if (suggestions.isNotEmpty) Container(margin: const EdgeInsets.only(top: 8, bottom: 8), decoration: BoxDecoration(color: const Color(0xFFF8F9FD), borderRadius: BorderRadius.circular(16), border: Border.all(color: const Color(0xFFE4E7F0))), child: Column(children: [const ListTile(dense: true, leading: Icon(Icons.language_rounded, color: _primary), title: Text('Internet suggestions', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 13)), subtitle: Text('Tap a result to fill the model and image.', style: TextStyle(fontSize: 11))), for (final item in suggestions.take(4)) ListTile(onTap: () => choose(item), leading: item.imageUrl.isEmpty ? const CircleAvatar(child: Icon(Icons.devices_other_rounded)) : CircleAvatar(backgroundImage: NetworkImage(item.imageUrl)), title: Text(item.title, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.w800)), subtitle: Text(item.description.isEmpty ? 'Internet result' : item.description, maxLines: 2, overflow: TextOverflow.ellipsis), trailing: const Icon(Icons.add_circle_outline_rounded, color: _primary))])),
      Row(children: [Expanded(child: _field(model, 'Model / variant')), const SizedBox(width: 10), Expanded(child: _field(sku, 'SKU'))]),
      if (imageUrl.isNotEmpty) Padding(padding: const EdgeInsets.only(bottom: 10), child: Container(height: 120, width: double.infinity, clipBehavior: Clip.antiAlias, decoration: BoxDecoration(color: _background, borderRadius: BorderRadius.circular(17)), child: Image.network(imageUrl, fit: BoxFit.cover, errorBuilder: (_, __, ___) => const Center(child: Icon(Icons.image_not_supported_outlined))))),
      Row(children: [Expanded(child: _field(purchase, 'Purchase price', number: true)), const SizedBox(width: 10), Expanded(child: _field(selling, 'Selling price', number: true))]),
      Row(children: [Expanded(child: _field(mrp, 'MRP', number: true)), const SizedBox(width: 10), Expanded(child: _field(quantity, 'Opening stock', number: true)), const SizedBox(width: 10), Expanded(child: _field(minimum, 'Min. stock', number: true))]),
    ]))),
    actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')), FilledButton.icon(onPressed: () { if (!formKey.currentState!.validate()) return; Navigator.pop(context, _ProductDraft(name: name.text.trim(), brand: brand, category: category, model: model.text.trim(), sku: sku.text.trim(), imageUrl: imageUrl, purchase: double.tryParse(purchase.text) ?? 0, selling: double.tryParse(selling.text) ?? 0, mrp: double.tryParse(mrp.text) ?? 0, quantity: int.tryParse(quantity.text) ?? 0, minimum: int.tryParse(minimum.text) ?? 2)); }, icon: const Icon(Icons.check_rounded), label: const Text('Save product'))],
  );
  Widget _dropdown(String label, String value, List<String> values, ValueChanged<String?> onChanged) => DropdownButtonFormField<String>(value: value, isExpanded: true, decoration: InputDecoration(labelText: label), items: [for (final item in values) DropdownMenuItem(value: item, child: Text(item))], onChanged: onChanged);
  Widget _field(TextEditingController controller, String label, {bool number = false}) => Padding(padding: const EdgeInsets.only(bottom: 10), child: TextFormField(controller: controller, keyboardType: number ? const TextInputType.numberWithOptions(decimal: true) : null, validator: (v) => v == null || v.trim().isEmpty ? 'Required' : null, decoration: InputDecoration(labelText: label)));
}

Future<void> showProductDetails(BuildContext context, Product p, Future<void> Function() refresh) async => showModalBottomSheet<void>(context: context, isScrollControlled: true, showDragHandle: true, builder: (_) => SafeArea(child: Padding(padding: const EdgeInsets.fromLTRB(22, 0, 22, 24), child: Column(mainAxisSize: MainAxisSize.min, children: [Row(children: [ProductImage(product: p, size: 68, radius: 18), const SizedBox(width: 13), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(p.name, style: const TextStyle(fontSize: 19, fontWeight: FontWeight.w900)), Text('${p.brand} • ${p.sku}', style: const TextStyle(color: _muted, fontSize: 12))])), StatusBadge(p.status)]), const SizedBox(height: 18), Row(children: [Expanded(child: _DetailStat('Selling', money(p.sellingPrice))), Expanded(child: _DetailStat('Purchase', money(p.purchasePrice))), Expanded(child: _DetailStat('Stock', '${p.quantity}'))]), const SizedBox(height: 18), Row(children: [Expanded(child: OutlinedButton.icon(onPressed: () async { Navigator.pop(context); await AppDatabase.instance.adjustStock(p.id, 1, 'ADJUSTMENT', 'Manual stock addition'); await refresh(); }, icon: const Icon(Icons.add), label: const Text('Add stock'))), const SizedBox(width: 10), Expanded(child: FilledButton.icon(onPressed: () async { Navigator.pop(context); await AppDatabase.instance.adjustStock(p.id, -1, 'ADJUSTMENT', 'Manual stock removal'); await refresh(); }, icon: const Icon(Icons.remove), label: const Text('Remove stock')))]), ]))));
class _DetailStat extends StatelessWidget { final String title, value; const _DetailStat(this.title, this.value); @override Widget build(BuildContext context) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(title, style: const TextStyle(color: _muted, fontSize: 11)), const SizedBox(height: 4), Text(value, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 15))]); }

class SalesPage extends StatefulWidget { const SalesPage({super.key}); @override State<SalesPage> createState() => _SalesPageState(); }
class _SalesPageState extends State<SalesPage> {
  List<Product> products = []; final cart = <Map<String, Object?>>[]; String query = '';
  @override void initState() { super.initState(); load(); }
  Future<void> load() async { try { final r = await AppDatabase.instance.products(query: query); if (mounted) setState(() => products = r); } catch (_) { if (mounted) setState(() => products = []); } }
  void add(Product p) { if (p.quantity <= 0) return; final i = cart.indexWhere((x) => x['product_id'] == p.id); if (i >= 0) { final q = cart[i]['quantity'] as int; if (q < p.quantity) cart[i]['quantity'] = q + 1; } else { cart.add({'product_id': p.id, 'quantity': 1, 'price': p.sellingPrice, 'name': p.name}); } setState(() {}); }
  Future<void> checkout() async { try { await AppDatabase.instance.sellCart(cart); if (!mounted) return; setState(cart.clear); await load(); ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Sale completed and stock updated.'))); } catch (e) { if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString()))); } }
  @override Widget build(BuildContext context) { final total = cart.fold<double>(0, (sum, x) => sum + (x['price'] as num).toDouble() * (x['quantity'] as int)); final wide = MediaQuery.sizeOf(context).width >= 950; return Frame(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [const PageHeader(title: 'Sales', subtitle: 'Fast point of sale for your shop'), const SizedBox(height: 16), SearchBox(hint: 'Search product to add to order', onChanged: (v) { query = v; load(); }, onScan: () {}), const SizedBox(height: 14), Expanded(child: wide ? Row(children: [Expanded(child: _salesGrid()), const SizedBox(width: 16), SizedBox(width: 350, child: _CartPanel(cart: cart, total: total, onRemove: (i) => setState(() => cart.removeAt(i)), onCheckout: checkout))]) : Column(children: [Expanded(child: _salesGrid()), const SizedBox(height: 10), Center(child: SizedBox(width: (MediaQuery.sizeOf(context).width - 44).clamp(0, 330), height: 58, child: _CartButton(total: total, enabled: cart.isNotEmpty, onTap: () => _showMobileCart(total))))]))])); }
  Widget _salesGrid() => products.isEmpty ? const _EmptyCard(icon: Icons.point_of_sale_rounded, title: 'No sellable products', subtitle: 'Add products with available stock to start a sale.') : LayoutBuilder(builder: (_, c) { final columns = c.maxWidth >= 1200 ? 4 : c.maxWidth >= 760 ? 3 : 2; return GridView.builder(itemCount: products.length, gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: columns, crossAxisSpacing: 12, mainAxisSpacing: 12, childAspectRatio: .82), itemBuilder: (_, i) => _SellProductCard(product: products[i], onAdd: () => add(products[i]))); });
  void _showMobileCart(double total) => showModalBottomSheet<void>(context: context, showDragHandle: true, builder: (_) => SafeArea(child: Padding(padding: const EdgeInsets.all(18), child: SizedBox(height: 430, child: _CartPanel(cart: cart, total: total, onRemove: (i) => setState(() => cart.removeAt(i)), onCheckout: checkout))));
}
class _CartButton extends StatelessWidget { final double total; final bool enabled; final VoidCallback onTap; const _CartButton({required this.total, required this.enabled, required this.onTap}); @override Widget build(BuildContext context) => DecoratedBox(decoration: BoxDecoration(gradient: enabled ? const LinearGradient(colors: [_primary, _purple]) : const LinearGradient(colors: [Color(0xFFDDE1EC), Color(0xFFC9CEDA)]), borderRadius: BorderRadius.circular(30)), child: Material(color: Colors.transparent, child: InkWell(borderRadius: BorderRadius.circular(30), onTap: enabled ? onTap : null, child: Center(child: Text(enabled ? 'View cart • ${money(total)}' : 'Cart • ₹0', style: TextStyle(color: enabled ? Colors.white : _muted, fontWeight: FontWeight.w900)))))); }
class _SellProductCard extends StatelessWidget { final Product product; final VoidCallback onAdd; const _SellProductCard({required this.product, required this.onAdd}); @override Widget build(BuildContext context) => Card(clipBehavior: Clip.antiAlias, child: InkWell(onTap: product.quantity <= 0 ? null : onAdd, child: Padding(padding: const EdgeInsets.all(12), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Expanded(child: ProductImage(product: product, size: 170, radius: 17)), const SizedBox(height: 10), Text(product.brand, style: const TextStyle(color: _muted, fontSize: 11)), Text(product.name, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w900)), const SizedBox(height: 6), Row(children: [Expanded(child: Text(money(product.sellingPrice), style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900))), if (product.quantity > 0) Container(width: 34, height: 34, decoration: const BoxDecoration(color: _primary, shape: BoxShape.circle), child: const Icon(Icons.add_rounded, color: Colors.white)) else const StatusBadge('OUT OF STOCK')])])))); }
class _CartPanel extends StatelessWidget { final List<Map<String, Object?>> cart; final double total; final ValueChanged<int> onRemove; final VoidCallback onCheckout; const _CartPanel({required this.cart, required this.total, required this.onRemove, required this.onCheckout}); @override Widget build(BuildContext context) => Card(child: Padding(padding: const EdgeInsets.all(17), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Row(children: [const Expanded(child: Text('Current order', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900))), if (cart.isNotEmpty) Text('${cart.length} items', style: const TextStyle(color: _muted, fontSize: 11))]), const SizedBox(height: 12), Expanded(child: cart.isEmpty ? const _EmptyCard(icon: Icons.shopping_bag_outlined, title: 'Your cart is empty', subtitle: 'Tap + on a product to add it.') : ListView.separated(itemCount: cart.length, separatorBuilder: (_, __) => const Divider(height: 1), itemBuilder: (_, i) { final x = cart[i]; return ListTile(contentPadding: EdgeInsets.zero, title: Text(x['name'].toString(), maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 12)), subtitle: Text('${x['quantity']} × ${money(x['price'] as num)}', style: const TextStyle(fontSize: 11)), trailing: IconButton(onPressed: () => onRemove(i), icon: const Icon(Icons.close, size: 18))); })), const Divider(), Row(children: [const Expanded(child: Text('Total', style: TextStyle(color: _muted))), Text(money(total), style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 22))]), const SizedBox(height: 11), SizedBox(width: double.infinity, height: 48, child: FilledButton(onPressed: cart.isEmpty ? null : onCheckout, child: const Text('Complete sale')))]))); }

class PurchasesPage extends StatelessWidget { const PurchasesPage({super.key}); @override Widget build(BuildContext context) => const Frame(child: ListView(children: [PageHeader(title: 'Purchases', subtitle: 'Receive stock and manage supplier invoices'), SizedBox(height: 18), _FeatureTile(icon: Icons.add_shopping_cart_rounded, title: 'New purchase', subtitle: 'Create a purchase and receive stock.', accent: _primary), _FeatureTile(icon: Icons.business_rounded, title: 'Suppliers', subtitle: 'Manage suppliers and outstanding payments.', accent: _purple), _FeatureTile(icon: Icons.receipt_long_rounded, title: 'Purchase history', subtitle: 'Review previous purchases and costs.', accent: _orange)])); }
class MorePage extends StatelessWidget { const MorePage({super.key}); @override Widget build(BuildContext context) => const Frame(child: ListView(children: [PageHeader(title: 'More', subtitle: 'Business tools, reports and settings'), SizedBox(height: 18), _FeatureTile(icon: Icons.people_alt_outlined, title: 'Customers', subtitle: 'Customer profiles, invoices and balances.', accent: _primary), _FeatureTile(icon: Icons.local_shipping_outlined, title: 'Suppliers', subtitle: 'Supplier history and payments.', accent: _purple), _FeatureTile(icon: Icons.receipt_long_outlined, title: 'Expenses', subtitle: 'Track operating expenses.', accent: _orange), _FeatureTile(icon: Icons.bar_chart_rounded, title: 'Reports & analytics', subtitle: 'Sales, profit and inventory insights.', accent: _teal), _FeatureTile(icon: Icons.backup_rounded, title: 'Backup & Restore', subtitle: 'Protect your local shop database.', accent: Color(0xFF3D7DD8)), _FeatureTile(icon: Icons.settings_outlined, title: 'Settings', subtitle: 'Shop profile, GST, inventory and users.', accent: _muted)])); }
class _FeatureTile extends StatelessWidget { final IconData icon; final String title, subtitle; final Color accent; const _FeatureTile({required this.icon, required this.title, required this.subtitle, required this.accent}); @override Widget build(BuildContext context) => Card(margin: const EdgeInsets.only(bottom: 9), child: ListTile(contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6), leading: Container(width: 44, height: 44, decoration: BoxDecoration(color: accent.withAlpha(16), borderRadius: BorderRadius.circular(13)), child: Icon(icon, color: accent)), title: Text(title, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14)), subtitle: Text(subtitle, style: const TextStyle(fontSize: 11, color: _muted)), trailing: const Icon(Icons.chevron_right_rounded, color: _muted))); }

const _categories = <(String, IconData, Color)>[
  ('Mobile Phones', Icons.smartphone_rounded, _primary), ('Laptops', Icons.laptop_mac_rounded, _purple), ('Televisions', Icons.tv_rounded, _teal), ('Refrigerators', Icons.kitchen_rounded, _orange), ('Audio', Icons.headphones_rounded, Color(0xFFE85AAD)), ('Cameras', Icons.photo_camera_rounded, Color(0xFF3D7DD8)), ('Printers', Icons.print_rounded, Color(0xFF6B7280)), ('Networking', Icons.router_rounded, Color(0xFF00A884)),
];
IconData categoryIcon(String category) { final c = category.toLowerCase(); if (c.contains('mobile')) return Icons.smartphone_outlined; if (c.contains('laptop')) return Icons.laptop_mac_outlined; if (c.contains('television') || c == 'tv') return Icons.tv_outlined; if (c.contains('refriger')) return Icons.kitchen_outlined; if (c.contains('air condition')) return Icons.ac_unit_outlined; if (c.contains('washing')) return Icons.local_laundry_service_outlined; if (c.contains('audio')) return Icons.headphones_outlined; if (c.contains('camera')) return Icons.photo_camera_outlined; if (c.contains('printer')) return Icons.print_outlined; if (c.contains('network')) return Icons.router_outlined; if (c.contains('storage')) return Icons.storage_outlined; if (c.contains('gaming')) return Icons.sports_esports_outlined; return Icons.devices_other_outlined; }
