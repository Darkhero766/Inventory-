import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'data/database.dart';
import 'models/models.dart';

const _primary = Color(0xFF3155E7);
const _ink = Color(0xFF171923);
const _muted = Color(0xFF737784);
const _surface = Color(0xFFFFFFFF);
const _background = Color(0xFFF5F6FA);

String money(num value) => NumberFormat.currency(
      locale: 'en_IN',
      symbol: '₹',
      decimalDigits: 0,
    ).format(value);

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const InventoryApp(loadDatabase: true));
}

class InventoryApp extends StatelessWidget {
  final bool loadDatabase;

  const InventoryApp({super.key, this.loadDatabase = false});

  @override
  Widget build(BuildContext context) {
    final scheme = ColorScheme.fromSeed(
      seedColor: _primary,
      brightness: Brightness.light,
    );
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Inventory',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: scheme,
        scaffoldBackgroundColor: _background,
        fontFamily: 'Inter',
        textTheme: const TextTheme(
          headlineLarge: TextStyle(fontSize: 32, fontWeight: FontWeight.w900, color: _ink, letterSpacing: -1),
          headlineMedium: TextStyle(fontSize: 26, fontWeight: FontWeight.w900, color: _ink, letterSpacing: -.6),
          titleLarge: TextStyle(fontSize: 19, fontWeight: FontWeight.w800, color: _ink),
          titleMedium: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: _ink),
          bodyMedium: TextStyle(fontSize: 14, color: _muted),
        ),
        cardTheme: CardThemeData(
          elevation: 0,
          color: _surface,
          margin: EdgeInsets.zero,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        ),
        navigationBarTheme: NavigationBarThemeData(
          height: 78,
          backgroundColor: Colors.white,
          indicatorColor: _primary.withAlpha(18),
          labelTextStyle: const WidgetStatePropertyAll(TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
        ),
        navigationRailTheme: NavigationRailThemeData(
          backgroundColor: Colors.white,
          indicatorColor: _primary.withAlpha(20),
          selectedIconTheme: const IconThemeData(color: _primary),
          selectedLabelTextStyle: const TextStyle(color: _primary, fontWeight: FontWeight.w800),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
          hintStyle: const TextStyle(color: Color(0xFF9A9DA6), fontSize: 14),
          prefixIconColor: _muted,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: _primary, width: 1.3),
          ),
        ),
      ),
      home: AppShell(loadDatabase: loadDatabase),
    );
  }
}

class AppShell extends StatefulWidget {
  final bool loadDatabase;
  const AppShell({super.key, this.loadDatabase = false});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int index = 0;

  static const labels = ['Home', 'Inventory', 'Purchases', 'Sales', 'More'];
  static const icons = [
    Icons.home_rounded,
    Icons.inventory_2_rounded,
    Icons.shopping_bag_rounded,
    Icons.point_of_sale_rounded,
    Icons.more_horiz_rounded,
  ];

  @override
  Widget build(BuildContext context) {
    final wide = MediaQuery.sizeOf(context).width >= 900;
    final pages = [
      HomePage(loadDatabase: widget.loadDatabase),
      const InventoryPage(),
      const PurchasesPage(),
      const SalesPage(),
      const MorePage(),
    ];

    return Scaffold(
      body: wide
          ? Row(
              children: [
                SizedBox(
                  width: 228,
                  child: Column(
                    children: [
                      const SizedBox(height: 30),
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 22),
                        child: _BrandLockup(compact: false),
                      ),
                      const SizedBox(height: 32),
                      Expanded(
                        child: NavigationRail(
                          extended: true,
                          minExtendedWidth: 228,
                          selectedIndex: index,
                          onDestinationSelected: (value) => setState(() => index = value),
                          destinations: [
                            for (var i = 0; i < labels.length; i++)
                              NavigationRailDestination(
                                icon: Icon(icons[i]),
                                selectedIcon: Icon(icons[i]),
                                label: Text(labels[i]),
                              ),
                          ],
                        ),
                      ),
                      const Padding(
                        padding: EdgeInsets.all(18),
                        child: Text('ElectroMart • v1.0', style: TextStyle(color: _muted, fontSize: 11)),
                      ),
                    ],
                  ),
                ),
                const VerticalDivider(width: 1, thickness: 1),
                Expanded(child: pages[index]),
              ],
            )
          : pages[index],
      bottomNavigationBar: wide
          ? null
          : NavigationBar(
              selectedIndex: index,
              onDestinationSelected: (value) => setState(() => index = value),
              destinations: [
                for (var i = 0; i < labels.length; i++)
                  NavigationDestination(icon: Icon(icons[i]), label: labels[i]),
              ],
            ),
    );
  }
}

class _BrandLockup extends StatelessWidget {
  final bool compact;
  const _BrandLockup({required this.compact});

  @override
  Widget build(BuildContext context) => Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: compact ? 38 : 42,
            height: compact ? 38 : 42,
            decoration: BoxDecoration(
              gradient: const LinearGradient(colors: [_primary, Color(0xFF6B7FFF)]),
              borderRadius: BorderRadius.circular(13),
            ),
            child: const Icon(Icons.bolt_rounded, color: Colors.white),
          ),
          const SizedBox(width: 11),
          if (!compact)
            const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('INVENTORY', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w900, letterSpacing: 1)),
                Text('ElectroMart', style: TextStyle(fontSize: 11, color: _muted)),
              ],
            ),
        ],
      );
}

class Frame extends StatelessWidget {
  final Widget child;
  const Frame({super.key, required this.child});

  @override
  Widget build(BuildContext context) => SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1480),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(22, 22, 22, 24),
              child: child,
            ),
          ),
        ),
      );
}

class PageHeader extends StatelessWidget {
  final String title;
  final String? subtitle;
  final Widget? action;
  final Widget? leading;

  const PageHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.action,
    this.leading,
  });

  @override
  Widget build(BuildContext context) => LayoutBuilder(
        builder: (context, constraints) {
          final compact = constraints.maxWidth < 600;
          final heading = Row(
            children: [
              if (leading != null) ...[leading!, const SizedBox(width: 12)],
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: Theme.of(context).textTheme.headlineMedium),
                    if (subtitle != null) ...[
                      const SizedBox(height: 3),
                      Text(subtitle!, style: const TextStyle(color: _muted, fontSize: 13)),
                    ],
                  ],
                ),
              ),
            ],
          );
          if (action == null) return heading;
          if (compact) {
            return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [heading, const SizedBox(height: 14), action!]);
          }
          return Row(children: [Expanded(child: heading), action!]);
        },
      );
}

class SearchBox extends StatelessWidget {
  final String hint;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onScan;
  const SearchBox({super.key, required this.hint, this.onChanged, this.onScan});

  @override
  Widget build(BuildContext context) => TextField(
        onChanged: onChanged,
        decoration: InputDecoration(
          prefixIcon: const Icon(Icons.search_rounded),
          hintText: hint,
          suffixIcon: onScan == null
              ? null
              : IconButton(onPressed: onScan, icon: const Icon(Icons.qr_code_scanner_rounded)),
        ),
      );
}

class StatusBadge extends StatelessWidget {
  final String status;
  const StatusBadge(this.status, {super.key});

  @override
  Widget build(BuildContext context) {
    final ok = status == 'IN STOCK';
    final low = status == 'LOW STOCK';
    final color = ok ? const Color(0xFF2E9B62) : low ? const Color(0xFFE18B20) : const Color(0xFFD84C4C);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(color: color.withAlpha(18), borderRadius: BorderRadius.circular(30)),
      child: Text(status, style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: .3)),
    );
  }
}

class SectionTitle extends StatelessWidget {
  final String title;
  final String? action;
  final VoidCallback? onAction;
  const SectionTitle(this.title, {super.key, this.action, this.onAction});

  @override
  Widget build(BuildContext context) => Row(
        children: [
          Expanded(child: Text(title, style: Theme.of(context).textTheme.titleLarge)),
          if (action != null) TextButton(onPressed: onAction, child: Text(action!)),
        ],
      );
}

class HomePage extends StatefulWidget {
  final bool loadDatabase;
  const HomePage({super.key, this.loadDatabase = true});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Product> products = [];
  double sales = 0;
  double purchases = 0;
  bool loading = false;

  @override
  void initState() {
    super.initState();
    if (widget.loadDatabase) load();
  }

  Future<void> load() async {
    if (mounted) setState(() => loading = true);
    try {
      final db = await AppDatabase.instance.db;
      final list = await AppDatabase.instance.products();
      final s = await db.rawQuery('SELECT COALESCE(SUM(total),0) value FROM sales');
      final p = await db.rawQuery('SELECT COALESCE(SUM(total),0) value FROM purchases');
      if (!mounted) return;
      setState(() {
        products = list;
        sales = (s.first['value'] as num?)?.toDouble() ?? 0;
        purchases = (p.first['value'] as num?)?.toDouble() ?? 0;
        loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        products = [];
        sales = 0;
        purchases = 0;
        loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final low = products.where((p) => p.quantity <= p.minimumStock).take(5).toList();
    final inventoryValue = products.fold<double>(0, (sum, p) => sum + p.quantity * p.purchasePrice);
    return Frame(
      child: RefreshIndicator(
        onRefresh: load,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Good morning', style: Theme.of(context).textTheme.headlineLarge),
                      const SizedBox(height: 4),
                      const Text('Here is what is happening at ElectroMart today.', style: TextStyle(color: _muted)),
                    ],
                  ),
                ),
                if (MediaQuery.sizeOf(context).width > 600)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 10),
                    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14)),
                    child: const Row(children: [Icon(Icons.storefront_rounded, size: 18), SizedBox(width: 8), Text('Main Store', style: TextStyle(fontWeight: FontWeight.w700))]),
                  ),
              ],
            ),
            const SizedBox(height: 20),
            SearchBox(hint: 'Search products, brands, models, SKU or barcode', onScan: () {}),
            const SizedBox(height: 22),
            _HeroBanner(products: products.length),
            const SizedBox(height: 24),
            const SectionTitle('Business snapshot'),
            const SizedBox(height: 11),
            LayoutBuilder(
              builder: (_, c) {
                final columns = c.maxWidth >= 1100 ? 4 : c.maxWidth >= 650 ? 2 : 1;
                final width = (c.maxWidth - (columns - 1) * 12) / columns;
                return Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: [
                    SizedBox(width: width, child: MetricCard(title: 'Total sales', value: money(sales), icon: Icons.trending_up_rounded, note: 'All recorded sales')),
                    SizedBox(width: width, child: MetricCard(title: 'Purchases', value: money(purchases), icon: Icons.shopping_bag_outlined, note: 'Supplier purchases')),
                    SizedBox(width: width, child: MetricCard(title: 'Inventory value', value: money(inventoryValue), icon: Icons.inventory_2_outlined, note: '${products.length} products')),
                    SizedBox(width: width, child: MetricCard(title: 'Low stock', value: '${low.length}', icon: Icons.warning_amber_rounded, note: 'Needs attention', warning: low.isNotEmpty)),
                  ],
                );
              },
            ),
            const SizedBox(height: 26),
            SectionTitle('Categories', action: 'View inventory', onAction: () {}),
            const SizedBox(height: 10),
            SizedBox(
              height: 108,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: _categories.length,
                separatorBuilder: (_, __) => const SizedBox(width: 10),
                itemBuilder: (_, i) => _CategoryCard(_categories[i].$1, _categories[i].$2),
              ),
            ),
            const SizedBox(height: 26),
            SectionTitle('Low stock', action: low.isEmpty ? null : 'Review items', onAction: () {}),
            const SizedBox(height: 10),
            if (low.isEmpty)
              const _EmptyCard(icon: Icons.inventory_2_outlined, title: 'Stock looks healthy', subtitle: 'No products are below their minimum stock level.')
            else
              for (final p in low) _LowStockTile(product: p),
            const SizedBox(height: 26),
            const SectionTitle('Recently stocked'),
            const SizedBox(height: 10),
            SizedBox(
              height: 238,
              child: products.isEmpty
                  ? const _EmptyCard(icon: Icons.devices_other_outlined, title: 'No products yet', subtitle: 'Add your first product from Inventory.')
                  : ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: products.length > 8 ? 8 : products.length,
                      separatorBuilder: (_, __) => const SizedBox(width: 12),
                      itemBuilder: (_, i) => ProductCard(products[i]),
                    ),
            ),
            const SizedBox(height: 16),
            if (loading) const LinearProgressIndicator(minHeight: 2),
          ],
        ),
      ),
    );
  }
}

class _HeroBanner extends StatelessWidget {
  final int products;
  const _HeroBanner({required this.products});

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(22),
        decoration: BoxDecoration(
          gradient: const LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [Color(0xFF111522), Color(0xFF253C9D)]),
          borderRadius: BorderRadius.circular(24),
        ),
        child: Row(
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(color: Colors.white.withAlpha(18), borderRadius: BorderRadius.circular(16)),
              child: const Icon(Icons.dashboard_customize_rounded, color: Colors.white),
            ),
            const SizedBox(width: 15),
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const Text('Your store at a glance', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w900)),
                const SizedBox(height: 4),
                Text('$products products • Keep stock, sales and purchases under control.', style: TextStyle(color: Colors.white.withAlpha(190), fontSize: 12)),
              ]),
            ),
            if (MediaQuery.sizeOf(context).width > 600)
              FilledButton.tonalIcon(onPressed: () {}, icon: const Icon(Icons.add), label: const Text('Add product')),
          ],
        ),
      );
}

class MetricCard extends StatelessWidget {
  final String title;
  final String value;
  final String note;
  final IconData icon;
  final bool warning;
  const MetricCard({super.key, required this.title, required this.value, required this.icon, required this.note, this.warning = false});

  @override
  Widget build(BuildContext context) => Card(
        child: Padding(
          padding: const EdgeInsets.all(17),
          child: Row(children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(color: (warning ? const Color(0xFFE18B20) : _primary).withAlpha(15), borderRadius: BorderRadius.circular(14)),
              child: Icon(icon, color: warning ? const Color(0xFFE18B20) : _primary),
            ),
            const SizedBox(width: 12),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(title, style: const TextStyle(color: _muted, fontSize: 12)),
              const SizedBox(height: 3),
              Text(value, style: const TextStyle(color: _ink, fontSize: 21, fontWeight: FontWeight.w900)),
              const SizedBox(height: 2),
              Text(note, style: const TextStyle(color: _muted, fontSize: 10)),
            ])),
          ]),
        ),
      );
}

class _CategoryCard extends StatelessWidget {
  final String name;
  final IconData icon;
  const _CategoryCard(this.name, this.icon);

  @override
  Widget build(BuildContext context) => Container(
        width: 142,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(18), border: Border.all(color: const Color(0xFFE9EAF0))),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Container(width: 38, height: 38, decoration: BoxDecoration(color: _primary.withAlpha(12), borderRadius: BorderRadius.circular(12)), child: Icon(icon, color: _primary, size: 20)),
          const Spacer(),
          Text(name, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 12)),
        ]),
      );
}

class _LowStockTile extends StatelessWidget {
  final Product product;
  const _LowStockTile({required this.product});

  @override
  Widget build(BuildContext context) => Card(
        margin: const EdgeInsets.only(bottom: 8),
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 4),
          leading: Container(width: 42, height: 42, decoration: BoxDecoration(color: _background, borderRadius: BorderRadius.circular(12)), child: Icon(categoryIcon(product.category), color: _ink)),
          title: Text('${product.brand} · ${product.name}', style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14)),
          subtitle: Text('${product.quantity} units left • ${product.sku}', style: const TextStyle(fontSize: 11)),
          trailing: StatusBadge(product.status),
        ),
      );
}

class _EmptyCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  const _EmptyCard({required this.icon, required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) => Card(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Row(children: [
            Container(width: 48, height: 48, decoration: BoxDecoration(color: _background, borderRadius: BorderRadius.circular(14)), child: Icon(icon, color: _muted)),
            const SizedBox(width: 14),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(title, style: const TextStyle(fontWeight: FontWeight.w800)), const SizedBox(height: 3), Text(subtitle, style: const TextStyle(color: _muted, fontSize: 12))])),
          ]),
        ),
      );
}

class InventoryPage extends StatefulWidget {
  const InventoryPage({super.key, this.query, this.category});
  final String? query;
  final String? category;

  @override
  State<InventoryPage> createState() => _InventoryPageState();
}

class _InventoryPageState extends State<InventoryPage> {
  List<Product> items = [];
  String query = '';
  bool loading = true;

  @override
  void initState() {
    super.initState();
    query = widget.query ?? '';
    load();
  }

  Future<void> load() async {
    try {
      final result = await AppDatabase.instance.products(query: query, category: widget.category);
      if (!mounted) return;
      setState(() { items = result; loading = false; });
    } catch (_) {
      if (mounted) setState(() { items = []; loading = false; });
    }
  }

  @override
  Widget build(BuildContext context) => Frame(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          PageHeader(
            title: widget.category ?? 'Inventory',
            subtitle: '${items.length} products in your catalog',
            action: FilledButton.icon(onPressed: () => showProductForm(context), icon: const Icon(Icons.add_rounded), label: const Text('Add product')),
          ),
          const SizedBox(height: 18),
          SearchBox(hint: 'Search products, brands, SKU or barcode', onChanged: (value) { query = value; load(); }, onScan: () {}),
          const SizedBox(height: 12),
          Row(children: [
            _FilterPill(label: 'All products', selected: widget.category == null),
            const SizedBox(width: 8),
            const _FilterPill(label: 'Low stock'),
            const SizedBox(width: 8),
            const _FilterPill(label: 'Out of stock'),
            const Spacer(),
            Text('${items.length} results', style: const TextStyle(color: _muted, fontSize: 12)),
          ]),
          const SizedBox(height: 14),
          Expanded(
            child: loading
                ? const Center(child: CircularProgressIndicator())
                : items.isEmpty
                    ? const _EmptyCard(icon: Icons.inventory_2_outlined, title: 'No products found', subtitle: 'Try another search or add a new product.')
                    : LayoutBuilder(builder: (_, c) {
                        final columns = c.maxWidth >= 1250 ? 4 : c.maxWidth >= 760 ? 3 : 2;
                        return GridView.builder(
                          itemCount: items.length,
                          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: columns, crossAxisSpacing: 14, mainAxisSpacing: 14, childAspectRatio: .78),
                          itemBuilder: (_, i) => ProductCard(items[i], onTap: () => showProductDetails(context, items[i], load)),
                        );
                      }),
          ),
        ]),
      );

  Future<void> showProductForm(BuildContext context) async {
    final name = TextEditingController();
    final brand = TextEditingController();
    final category = TextEditingController(text: 'Accessories');
    final model = TextEditingController();
    final sku = TextEditingController(text: 'NEW-${DateTime.now().millisecondsSinceEpoch % 100000}');
    final purchase = TextEditingController();
    final selling = TextEditingController();
    final mrp = TextEditingController();
    final quantity = TextEditingController(text: '0');
    final minimum = TextEditingController(text: '2');
    final formKey = GlobalKey<FormState>();

    final saved = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Add product', style: TextStyle(fontWeight: FontWeight.w900)),
        content: SizedBox(
          width: 540,
          child: Form(
            key: formKey,
            child: SingleChildScrollView(child: Column(children: [
              field(name, 'Product name'), field(brand, 'Brand'), field(category, 'Category'), field(model, 'Model'), field(sku, 'SKU'),
              Row(children: [Expanded(child: field(purchase, 'Purchase price', number: true)), const SizedBox(width: 10), Expanded(child: field(selling, 'Selling price', number: true))]),
              Row(children: [Expanded(child: field(mrp, 'MRP', number: true)), const SizedBox(width: 10), Expanded(child: field(quantity, 'Quantity', number: true))]),
              field(minimum, 'Minimum stock', number: true),
            ])),
          ),
        ),
        actions: [TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')), FilledButton(onPressed: () { if (formKey.currentState!.validate()) Navigator.pop(context, true); }, child: const Text('Save product'))],
      ),
    );
    if (saved != true) return;
    try {
      await AppDatabase.instance.addProduct({
        'name': name.text.trim(), 'brand': brand.text.trim(), 'category': category.text.trim(), 'model': model.text.trim(), 'sku': sku.text.trim(), 'barcode': '', 'image_url': '',
        'mrp': double.tryParse(mrp.text) ?? 0, 'selling_price': double.tryParse(selling.text) ?? 0, 'purchase_price': double.tryParse(purchase.text) ?? 0,
        'quantity': int.tryParse(quantity.text) ?? 0, 'minimum_stock': int.tryParse(minimum.text) ?? 2, 'supplier': '', 'warranty': '', 'gst_rate': 18, 'hsn_code': '',
        'location': 'Main Store', 'rack': '', 'shelf': '', 'serial_tracking': 0, 'imei_tracking': 0, 'specs': '', 'notes': '', 'archived': 0,
      });
      await load();
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Could not save product: $e')));
    }
  }

  Widget field(TextEditingController controller, String label, {bool number = false}) => Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: TextFormField(
          controller: controller,
          keyboardType: number ? const TextInputType.numberWithOptions(decimal: true) : null,
          validator: (value) => value == null || value.trim().isEmpty ? 'Required' : null,
          decoration: InputDecoration(labelText: label),
        ),
      );
}

class _FilterPill extends StatelessWidget {
  final String label;
  final bool selected;
  const _FilterPill({required this.label, this.selected = false});

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(color: selected ? _primary.withAlpha(14) : Colors.white, borderRadius: BorderRadius.circular(30), border: Border.all(color: selected ? _primary.withAlpha(35) : const Color(0xFFE7E8ED))),
        child: Text(label, style: TextStyle(fontSize: 11, color: selected ? _primary : _muted, fontWeight: FontWeight.w800)),
      );
}

class ProductCard extends StatelessWidget {
  final Product product;
  final VoidCallback? onTap;
  const ProductCard(this.product, {super.key, this.onTap});

  @override
  Widget build(BuildContext context) => Card(
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Expanded(
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(color: _background, borderRadius: BorderRadius.circular(16)),
                  child: Center(child: Icon(categoryIcon(product.category), size: 58, color: _ink)),
                ),
              ),
              const SizedBox(height: 12),
              Text(product.brand, style: const TextStyle(color: _muted, fontSize: 11, fontWeight: FontWeight.w700)),
              const SizedBox(height: 3),
              Text(product.name, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 14)),
              const SizedBox(height: 7),
              Row(children: [Expanded(child: Text(money(product.sellingPrice), style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 17))), StatusBadge(product.status)]),
              const SizedBox(height: 6),
              Text('Stock ${product.quantity} • ${product.sku}', maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(color: _muted, fontSize: 10)),
            ]),
          ),
        ),
      );
}

Future<void> showProductDetails(BuildContext context, Product p, Future<void> Function() refresh) async {
  await showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (_) => SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(22, 0, 22, 24),
        child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [Container(width: 56, height: 56, decoration: BoxDecoration(color: _background, borderRadius: BorderRadius.circular(16)), child: Icon(categoryIcon(p.category), size: 30)), const SizedBox(width: 13), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(p.name, style: const TextStyle(fontSize: 19, fontWeight: FontWeight.w900)), Text('${p.brand} • ${p.sku}', style: const TextStyle(color: _muted, fontSize: 12))])), StatusBadge(p.status)]),
          const SizedBox(height: 18),
          Row(children: [Expanded(child: _DetailStat('Selling', money(p.sellingPrice))), Expanded(child: _DetailStat('Purchase', money(p.purchasePrice))), Expanded(child: _DetailStat('Stock', '${p.quantity}'))]),
          const SizedBox(height: 18),
          Row(children: [Expanded(child: OutlinedButton.icon(onPressed: () async { Navigator.pop(context); await AppDatabase.instance.adjustStock(p.id, 1, 'ADJUSTMENT', 'Manual stock addition'); await refresh(); }, icon: const Icon(Icons.add), label: const Text('Add stock'))), const SizedBox(width: 10), Expanded(child: FilledButton.icon(onPressed: () async { Navigator.pop(context); await AppDatabase.instance.adjustStock(p.id, -1, 'ADJUSTMENT', 'Manual stock removal'); await refresh(); }, icon: const Icon(Icons.remove), label: const Text('Remove stock')))]),
        ]),
      ),
    ),
  );
}

class _DetailStat extends StatelessWidget {
  final String title;
  final String value;
  const _DetailStat(this.title, this.value);
  @override
  Widget build(BuildContext context) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(title, style: const TextStyle(color: _muted, fontSize: 11)), const SizedBox(height: 4), Text(value, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 15))]);
}

class PurchasesPage extends StatelessWidget {
  const PurchasesPage({super.key});

  @override
  Widget build(BuildContext context) => Frame(
        child: ListView(children: [
          const PageHeader(title: 'Purchases', subtitle: 'Receive stock and manage supplier invoices'),
          const SizedBox(height: 18),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(22)),
            child: const Row(children: [Icon(Icons.local_shipping_rounded, size: 30, color: _primary), SizedBox(width: 14), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('Stock receiving', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w900)), SizedBox(height: 3), Text('Create purchase invoices and increase stock atomically.', style: TextStyle(color: _muted, fontSize: 12))])),]),
          ),
          const SizedBox(height: 16),
          const FeatureTile(icon: Icons.add_shopping_cart_rounded, title: 'New Purchase', subtitle: 'Create a purchase and receive products into stock', accent: _primary),
          const FeatureTile(icon: Icons.business_rounded, title: 'Suppliers', subtitle: 'Manage suppliers, invoices and outstanding payments', accent: Color(0xFF7B57D1)),
          const FeatureTile(icon: Icons.receipt_long_rounded, title: 'Purchase History', subtitle: 'Review previous purchases, quantities and costs', accent: Color(0xFFE18B20)),
        ]),
      );
}

class SalesPage extends StatefulWidget {
  const SalesPage({super.key});
  @override
  State<SalesPage> createState() => _SalesPageState();
}

class _SalesPageState extends State<SalesPage> {
  List<Product> products = [];
  final cart = <Map<String, Object?>>[];

  @override
  void initState() { super.initState(); load(); }

  Future<void> load() async {
    try {
      final result = await AppDatabase.instance.products();
      if (mounted) setState(() => products = result);
    } catch (_) {
      if (mounted) setState(() => products = []);
    }
  }

  void add(Product p) {
    if (p.quantity <= 0) return;
    final i = cart.indexWhere((x) => x['product_id'] == p.id);
    if (i >= 0) {
      final q = cart[i]['quantity'] as int;
      if (q < p.quantity) cart[i]['quantity'] = q + 1;
    } else {
      cart.add({'product_id': p.id, 'quantity': 1, 'price': p.sellingPrice, 'name': p.name});
    }
    setState(() {});
  }

  void removeAt(int index) { cart.removeAt(index); setState(() {}); }

  Future<void> checkout() async {
    try {
      await AppDatabase.instance.sellCart(cart);
      if (!mounted) return;
      setState(cart.clear);
      await load();
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Sale completed and stock updated.')));
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
    }
  }

  @override
  Widget build(BuildContext context) {
    final total = cart.fold<double>(0, (sum, x) => sum + (x['price'] as num).toDouble() * (x['quantity'] as int));
    final wide = MediaQuery.sizeOf(context).width >= 950;
    return Frame(
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const PageHeader(title: 'Sales', subtitle: 'Fast point of sale for your shop'),
        const SizedBox(height: 17),
        SearchBox(hint: 'Search product to add to order', onChanged: (_) {}, onScan: () {}),
        const SizedBox(height: 14),
        Expanded(
          child: wide
              ? Row(children: [Expanded(child: _salesGrid()), const SizedBox(width: 16), SizedBox(width: 355, child: _cartPanel(total))])
              : Column(children: [Expanded(child: _salesGrid()), const SizedBox(height: 10), SizedBox(height: 72, width: double.infinity, child: FilledButton.icon(onPressed: cart.isEmpty ? null : () => _showMobileCart(total), icon: const Icon(Icons.shopping_bag_rounded), label: Text(cart.isEmpty ? 'Cart • ₹0' : 'View cart • ${money(total)}')))]),
        ),
      ]),
    );
  }

  Widget _salesGrid() => products.isEmpty
      ? const _EmptyCard(icon: Icons.point_of_sale_rounded, title: 'No sellable products', subtitle: 'Add products with available stock to start a sale.')
      : LayoutBuilder(builder: (_, c) {
          final columns = c.maxWidth >= 1200 ? 4 : c.maxWidth >= 760 ? 3 : 2;
          return GridView.builder(
            itemCount: products.length,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: columns, crossAxisSpacing: 12, mainAxisSpacing: 12, childAspectRatio: .82),
            itemBuilder: (_, i) => _SellProductCard(product: products[i], onAdd: () => add(products[i])),
          );
        });

  Widget _cartPanel(double total) => Card(
        child: Padding(
          padding: const EdgeInsets.all(17),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [const Expanded(child: Text('Current order', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900))), if (cart.isNotEmpty) Text('${cart.length} items', style: const TextStyle(color: _muted, fontSize: 11))]),
            const SizedBox(height: 12),
            Expanded(child: cart.isEmpty ? const _EmptyCard(icon: Icons.shopping_bag_outlined, title: 'Your cart is empty', subtitle: 'Tap a product to add it to the order.') : ListView.separated(itemCount: cart.length, separatorBuilder: (_, __) => const Divider(height: 1), itemBuilder: (_, i) { final x = cart[i]; return ListTile(contentPadding: EdgeInsets.zero, title: Text(x['name'].toString(), maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 12)), subtitle: Text('${x['quantity']} × ${money(x['price'] as num)}', style: const TextStyle(fontSize: 11)), trailing: IconButton(onPressed: () => removeAt(i), icon: const Icon(Icons.close, size: 18))); })),
            const Divider(),
            Row(children: [const Expanded(child: Text('Total', style: TextStyle(color: _muted))), Text(money(total), style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 22))]),
            const SizedBox(height: 11),
            SizedBox(width: double.infinity, height: 48, child: FilledButton(onPressed: cart.isEmpty ? null : checkout, child: const Text('Complete sale'))),
          ]),
        ),
      );

  void _showMobileCart(double total) => showModalBottomSheet<void>(context: context, showDragHandle: true, builder: (_) => SafeArea(child: Padding(padding: const EdgeInsets.all(18), child: SizedBox(height: 430, child: _cartPanel(total)))));
}

class _SellProductCard extends StatelessWidget {
  final Product product;
  final VoidCallback onAdd;
  const _SellProductCard({required this.product, required this.onAdd});

  @override
  Widget build(BuildContext context) => Card(
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: product.quantity <= 0 ? null : onAdd,
          child: Padding(
            padding: const EdgeInsets.all(13),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Expanded(child: Container(width: double.infinity, decoration: BoxDecoration(color: _background, borderRadius: BorderRadius.circular(16)), child: Center(child: Icon(categoryIcon(product.category), size: 54, color: _ink)))),
              const SizedBox(height: 10),
              Text(product.brand, style: const TextStyle(color: _muted, fontSize: 11)),
              Text(product.name, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w900)),
              const SizedBox(height: 6),
              Row(children: [Expanded(child: Text(money(product.sellingPrice), style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900))), if (product.quantity > 0) const Icon(Icons.add_circle_rounded, color: _primary, size: 24) else const StatusBadge('OUT OF STOCK')]),
            ]),
          ),
        ),
      );
}

class MorePage extends StatelessWidget {
  const MorePage({super.key});

  @override
  Widget build(BuildContext context) => Frame(
        child: ListView(children: [
          const PageHeader(title: 'More', subtitle: 'Business tools, reports and settings'),
          const SizedBox(height: 18),
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(color: _ink, borderRadius: BorderRadius.circular(22)),
            child: const Row(children: [Icon(Icons.settings_suggest_rounded, color: Colors.white, size: 30), SizedBox(width: 13), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('ElectroMart Electronics', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 16)), SizedBox(height: 3), Text('Main Store • GST enabled', style: TextStyle(color: Color(0xFFB7BBC8), fontSize: 11))])), Icon(Icons.chevron_right_rounded, color: Colors.white)]),
          ),
          const SizedBox(height: 16),
          const FeatureTile(icon: Icons.people_alt_outlined, title: 'Customers', subtitle: 'Customer profiles, invoices and balances', accent: _primary),
          const FeatureTile(icon: Icons.local_shipping_outlined, title: 'Suppliers', subtitle: 'Supplier history and payments', accent: Color(0xFF7B57D1)),
          const FeatureTile(icon: Icons.receipt_long_outlined, title: 'Expenses', subtitle: 'Track operating expenses', accent: Color(0xFFE18B20)),
          const FeatureTile(icon: Icons.bar_chart_rounded, title: 'Reports & analytics', subtitle: 'Sales, profit, inventory and stock movement', accent: Color(0xFF2E9B62)),
          const FeatureTile(icon: Icons.backup_rounded, title: 'Backup & Restore', subtitle: 'Protect your local shop database', accent: Color(0xFF3D7DD8)),
          const FeatureTile(icon: Icons.settings_outlined, title: 'Settings', subtitle: 'Shop profile, GST, inventory and users', accent: _muted),
        ]),
      );
}

class FeatureTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color accent;
  const FeatureTile({super.key, required this.icon, required this.title, required this.subtitle, this.accent = _primary});

  @override
  Widget build(BuildContext context) => Card(
        margin: const EdgeInsets.only(bottom: 9),
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
          leading: Container(width: 44, height: 44, decoration: BoxDecoration(color: accent.withAlpha(14), borderRadius: BorderRadius.circular(13)), child: Icon(icon, color: accent)),
          title: Text(title, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14)),
          subtitle: Text(subtitle, style: const TextStyle(fontSize: 11, color: _muted)),
          trailing: const Icon(Icons.chevron_right_rounded, color: _muted),
        ),
      );
}


const _categories = <(String, IconData)>[
  ('Mobile Phones', Icons.smartphone_rounded),
  ('Laptops', Icons.laptop_mac_rounded),
  ('Televisions', Icons.tv_rounded),
  ('Refrigerators', Icons.kitchen_rounded),
  ('Audio', Icons.headphones_rounded),
  ('Cameras', Icons.photo_camera_rounded),
  ('Printers', Icons.print_rounded),
  ('Networking', Icons.router_rounded),
];

IconData categoryIcon(String category) {
  final c = category.toLowerCase();
  if (c.contains('mobile')) return Icons.smartphone_outlined;
  if (c.contains('laptop')) return Icons.laptop_mac_outlined;
  if (c.contains('television') || c == 'tv') return Icons.tv_outlined;
  if (c.contains('refriger')) return Icons.kitchen_outlined;
  if (c.contains('air condition')) return Icons.ac_unit_outlined;
  if (c.contains('washing')) return Icons.local_laundry_service_outlined;
  if (c.contains('audio')) return Icons.headphones_outlined;
  if (c.contains('camera')) return Icons.photo_camera_outlined;
  if (c.contains('printer')) return Icons.print_outlined;
  if (c.contains('network')) return Icons.router_outlined;
  if (c.contains('storage')) return Icons.storage_outlined;
  if (c.contains('gaming')) return Icons.sports_esports_outlined;
  return Icons.devices_other_outlined;
}
