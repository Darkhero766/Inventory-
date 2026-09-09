import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'data/database.dart';
import 'models/models.dart';

const _ink = Color(0xFF10131A);
const _muted = Color(0xFF737985);
const _surface = Color(0xFFF5F6F8);
const _blue = Color(0xFF3155E7);
const _green = Color(0xFF14966A);
const _orange = Color(0xFFE58A22);

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
    final scheme = ColorScheme.fromSeed(seedColor: _blue, brightness: Brightness.light);
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Inventory',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: scheme,
        scaffoldBackgroundColor: _surface,
        fontFamily: 'Inter',
        textTheme: Theme.of(context).textTheme.apply(bodyColor: _ink, displayColor: _ink),
        cardTheme: const CardThemeData(
          elevation: 0,
          margin: EdgeInsets.zero,
          color: Colors.white,
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 15),
          prefixIconColor: _muted,
          hintStyle: const TextStyle(color: _muted),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(16)),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(16)),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(16)),
            borderSide: BorderSide(color: _blue, width: 1.5),
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
    Icons.space_dashboard_outlined,
    Icons.inventory_2_outlined,
    Icons.shopping_bag_outlined,
    Icons.point_of_sale_outlined,
    Icons.more_horiz,
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
                _SideNav(
                  selected: index,
                  onSelected: (value) => setState(() => index = value),
                ),
                const VerticalDivider(width: 1),
                Expanded(child: pages[index]),
              ],
            )
          : pages[index],
      bottomNavigationBar: wide
          ? null
          : NavigationBar(
              height: 72,
              backgroundColor: Colors.white,
              indicatorColor: _blue.withAlpha(24),
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

class _SideNav extends StatelessWidget {
  final int selected;
  final ValueChanged<int> onSelected;

  const _SideNav({required this.selected, required this.onSelected});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 238,
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(16, 22, 16, 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(
              children: [
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: _ink,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.bolt_rounded, color: Colors.white),
                ),
                const SizedBox(width: 10),
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('INVENTORY', style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1.2)),
                    Text('ElectroMart', style: TextStyle(fontSize: 11, color: _muted)),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 28),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 12),
            child: Text('WORKSPACE', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: _muted, letterSpacing: 1.3)),
          ),
          const SizedBox(height: 8),
          for (var i = 0; i < AppShell.labels.length; i++)
            _NavItem(
              icon: AppShell.icons[i],
              label: AppShell.labels[i],
              selected: selected == i,
              onTap: () => onSelected(i),
            ),
          const Spacer(),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: _surface,
              borderRadius: BorderRadius.circular(18),
            ),
            child: const Row(
              children: [
                CircleAvatar(radius: 18, child: Icon(Icons.person_outline, size: 20)),
                SizedBox(width: 10),
                Expanded(child: Text('Shop Owner', style: TextStyle(fontWeight: FontWeight.w700))),
                Icon(Icons.more_horiz, color: _muted),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _NavItem({required this.icon, required this.label, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 5),
      child: Material(
        color: selected ? _ink : Colors.transparent,
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(14),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            child: Row(
              children: [
                Icon(icon, size: 21, color: selected ? Colors.white : _muted),
                const SizedBox(width: 12),
                Text(label, style: TextStyle(fontWeight: selected ? FontWeight.w800 : FontWeight.w600, color: selected ? Colors.white : _ink)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class Frame extends StatelessWidget {
  final Widget child;

  const Frame({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1500),
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: MediaQuery.sizeOf(context).width < 600 ? 16 : 28,
              vertical: 22,
            ),
            child: child,
          ),
        ),
      ),
    );
  }
}

class PageHeader extends StatelessWidget {
  final String title;
  final String? subtitle;
  final Widget? action;

  const PageHeader({super.key, required this.title, this.subtitle, this.action});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w900, letterSpacing: -0.7)),
              if (subtitle != null) ...[
                const SizedBox(height: 4),
                Text(subtitle!, style: const TextStyle(color: _muted)),
              ],
            ],
          ),
        ),
        if (action != null) action!,
      ],
    );
  }
}

class StatusBadge extends StatelessWidget {
  final String status;

  const StatusBadge(this.status, {super.key});

  @override
  Widget build(BuildContext context) {
    final color = status == 'IN STOCK' ? _green : status == 'LOW STOCK' ? _orange : Colors.red;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(color: color.withAlpha(22), borderRadius: BorderRadius.circular(30)),
      child: Text(status, style: TextStyle(color: color, fontSize: 9.5, fontWeight: FontWeight.w900, letterSpacing: .2)),
    );
  }
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
      setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final low = products.where((p) => p.quantity <= p.minimumStock).take(5).toList();
    final inventoryValue = products.fold<double>(0, (sum, p) => sum + p.quantity * p.purchasePrice);
    final wide = MediaQuery.sizeOf(context).width >= 900;

    return Frame(
      child: RefreshIndicator(
        onRefresh: load,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          children: [
            _DashboardHero(
              sales: sales,
              inventoryValue: inventoryValue,
              loading: loading,
            ),
            const SizedBox(height: 22),
            _SectionTitle(title: 'Quick actions', trailing: const Text('Today', style: TextStyle(color: _muted, fontSize: 12))),
            const SizedBox(height: 12),
            _QuickActions(wide: wide),
            const SizedBox(height: 24),
            _SectionTitle(title: 'Business overview', trailing: Text(DateFormat('d MMM yyyy').format(DateTime.now()), style: const TextStyle(color: _muted, fontSize: 12))),
            const SizedBox(height: 12),
            _StatsGrid(sales: sales, purchases: purchases, inventoryValue: inventoryValue, lowStock: low.length),
            const SizedBox(height: 26),
            _SectionTitle(title: 'Browse inventory', trailing: const Text('8 categories', style: TextStyle(color: _muted, fontSize: 12))),
            const SizedBox(height: 12),
            _CategoryStrip(),
            const SizedBox(height: 26),
            if (wide)
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(child: _LowStockPanel(items: low)),
                  const SizedBox(width: 18),
                  Expanded(child: _TopProductsPanel(products: products.take(6).toList())),
                ],
              )
            else ...[
              _LowStockPanel(items: low),
              const SizedBox(height: 18),
              _TopProductsPanel(products: products.take(6).toList()),
            ],
            const SizedBox(height: 28),
          ],
        ),
      ),
    );
  }
}

class _DashboardHero extends StatelessWidget {
  final double sales;
  final double inventoryValue;
  final bool loading;

  const _DashboardHero({required this.sales, required this.inventoryValue, required this.loading});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: _ink,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [BoxShadow(color: Colors.black.withAlpha(18), blurRadius: 24, offset: const Offset(0, 10))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Good morning', style: TextStyle(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.w600)),
                    SizedBox(height: 5),
                    Text('Run your store at a glance.', style: TextStyle(color: Colors.white, fontSize: 27, fontWeight: FontWeight.w900, letterSpacing: -.8)),
                    SizedBox(height: 5),
                    Text('ElectroMart Electronics · Main Store', style: TextStyle(color: Colors.white54, fontSize: 12)),
                  ],
                ),
              ),
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(color: Colors.white.withAlpha(18), borderRadius: BorderRadius.circular(14)),
                child: const Icon(Icons.notifications_none_rounded, color: Colors.white),
              ),
            ],
          ),
          const SizedBox(height: 22),
          TextField(
            decoration: InputDecoration(
              filled: true,
              fillColor: Colors.white.withAlpha(14),
              hintText: 'Search products, brands, models, SKU or barcode',
              hintStyle: const TextStyle(color: Colors.white54),
              prefixIcon: const Icon(Icons.search_rounded, color: Colors.white70),
              suffixIcon: Container(
                margin: const EdgeInsets.all(8),
                decoration: BoxDecoration(color: Colors.white.withAlpha(18), borderRadius: BorderRadius.circular(10)),
                child: const Icon(Icons.qr_code_scanner_rounded, color: Colors.white70, size: 20),
              ),
              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide(color: Colors.white.withAlpha(18))),
              focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: const BorderSide(color: Colors.white38)),
            ),
          ),
          const SizedBox(height: 18),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              _HeroMetric(label: 'Today sales', value: loading ? '—' : money(sales), icon: Icons.trending_up_rounded),
              _HeroMetric(label: 'Stock value', value: loading ? '—' : money(inventoryValue), icon: Icons.inventory_2_outlined),
            ],
          ),
        ],
      ),
    );
  }
}

class _HeroMetric extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;

  const _HeroMetric({required this.label, required this.value, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
      decoration: BoxDecoration(color: Colors.white.withAlpha(12), borderRadius: BorderRadius.circular(15)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 17, color: Colors.white70),
          const SizedBox(width: 8),
          Text(label, style: const TextStyle(color: Colors.white54, fontSize: 11)),
          const SizedBox(width: 8),
          Text(value, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900)),
        ],
      ),
    );
  }
}

class _QuickActions extends StatelessWidget {
  final bool wide;

  const _QuickActions({required this.wide});

  @override
  Widget build(BuildContext context) {
    final actions = [
      ('New sale', Icons.point_of_sale_rounded, _blue),
      ('Add stock', Icons.add_box_outlined, _green),
      ('New purchase', Icons.shopping_bag_outlined, _orange),
      ('Scan barcode', Icons.qr_code_scanner_rounded, _ink),
    ];
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: [
        for (final a in actions)
          SizedBox(
            width: wide ? 190 : 155,
            child: FilledButton.tonalIcon(
              onPressed: () {},
              icon: Icon(a.$2, size: 19),
              label: Text(a.$1),
              style: FilledButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: _ink,
                padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 15),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
              ),
            ),
          ),
      ],
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  final Widget? trailing;

  const _SectionTitle({required this.title, this.trailing});

  @override
  Widget build(BuildContext context) => Row(
        children: [
          Expanded(child: Text(title, style: const TextStyle(fontSize: 19, fontWeight: FontWeight.w900, letterSpacing: -.3))),
          if (trailing != null) trailing!,
        ],
      );
}

class _StatsGrid extends StatelessWidget {
  final double sales;
  final double purchases;
  final double inventoryValue;
  final int lowStock;

  const _StatsGrid({required this.sales, required this.purchases, required this.inventoryValue, required this.lowStock});

  @override
  Widget build(BuildContext context) {
    final stats = [
      ('Sales', money(sales), Icons.trending_up_rounded, _green),
      ('Purchases', money(purchases), Icons.shopping_bag_outlined, _blue),
      ('Inventory value', money(inventoryValue), Icons.inventory_2_outlined, _ink),
      ('Low stock', '$lowStock items', Icons.warning_amber_rounded, _orange),
    ];
    return LayoutBuilder(
      builder: (_, c) {
        final columns = c.maxWidth >= 1000 ? 4 : c.maxWidth >= 620 ? 2 : 1;
        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: stats.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: columns, crossAxisSpacing: 12, mainAxisSpacing: 12, childAspectRatio: columns == 1 ? 4.2 : 2.1),
          itemBuilder: (_, i) {
            final s = stats[i];
            return _StatCard(title: s.$1, value: s.$2, icon: s.$3, accent: s.$4);
          },
        );
      },
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color accent;

  const _StatCard({required this.title, required this.value, required this.icon, required this.accent});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(width: 42, height: 42, decoration: BoxDecoration(color: accent.withAlpha(18), borderRadius: BorderRadius.circular(13)), child: Icon(icon, color: accent, size: 21)),
            const SizedBox(width: 12),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.center, children: [Text(title, style: const TextStyle(color: _muted, fontSize: 11)), const SizedBox(height: 4), Text(value, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900))])),
          ],
        ),
      ),
    );
  }
}

class _CategoryStrip extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    const categories = ['Mobile Phones', 'Laptops', 'Televisions', 'Refrigerators', 'Audio', 'Cameras', 'Printers', 'Networking'];
    return SizedBox(
      height: 104,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: categories.length,
        separatorBuilder: (_, __) => const SizedBox(width: 10),
        itemBuilder: (_, i) => Container(
          width: 142,
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(18), border: Border.all(color: Colors.black.withAlpha(5))),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Container(width: 38, height: 38, decoration: BoxDecoration(color: _blue.withAlpha(12), borderRadius: BorderRadius.circular(12)), child: Icon(categoryIcon(categories[i]), color: _blue, size: 20)), const Spacer(), Text(categories[i], maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 12))]),
        ),
      ),
    );
  }
}

class _LowStockPanel extends StatelessWidget {
  final List<Product> items;

  const _LowStockPanel({required this.items});

  @override
  Widget build(BuildContext context) {
    return _Panel(
      title: 'Low stock',
      action: TextButton(onPressed: () {}, child: const Text('View all')),
      child: items.isEmpty
          ? const Padding(padding: EdgeInsets.all(24), child: Text('Everything looks healthy.', style: TextStyle(color: _muted)))
          : Column(children: [for (final p in items) _ProductRow(product: p, compact: true)]),
    );
  }
}

class _TopProductsPanel extends StatelessWidget {
  final List<Product> products;

  const _TopProductsPanel({required this.products});

  @override
  Widget build(BuildContext context) {
    return _Panel(
      title: 'Top products',
      action: TextButton(onPressed: () {}, child: const Text('Inventory')),
      child: products.isEmpty
          ? const Padding(padding: EdgeInsets.all(24), child: Text('Products will appear here after loading data.', style: TextStyle(color: _muted)))
          : Column(children: [for (final p in products) _ProductRow(product: p)]),
    );
  }
}

class _Panel extends StatelessWidget {
  final String title;
  final Widget? action;
  final Widget child;

  const _Panel({required this.title, this.action, required this.child});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 15, 16, 10),
        child: Column(
          children: [
            Row(children: [Expanded(child: Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900))), if (action != null) action!]),
            const Divider(height: 12),
            child,
          ],
        ),
      ),
    );
  }
}

class _ProductRow extends StatelessWidget {
  final Product product;
  final bool compact;

  const _ProductRow({required this.product, this.compact = false});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 7),
      child: Row(
        children: [
          _ProductThumb(product: product, size: 42),
          const SizedBox(width: 11),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(product.name, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 12.5)), const SizedBox(height: 3), Text('${product.brand} · ${product.sku}', maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(color: _muted, fontSize: 10.5))])),
          const SizedBox(width: 8),
          if (compact) Column(crossAxisAlignment: CrossAxisAlignment.end, children: [Text('${product.quantity}', style: const TextStyle(fontWeight: FontWeight.w900)), const Text('left', style: TextStyle(color: _muted, fontSize: 9))]) else Text(money(product.sellingPrice), style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 12)),
        ],
      ),
    );
  }
}

class _ProductThumb extends StatelessWidget {
  final Product product;
  final double size;

  const _ProductThumb({required this.product, this.size = 62});

  @override
  Widget build(BuildContext context) {
    if (product.imageUrl.trim().isNotEmpty) {
      return ClipRRect(borderRadius: BorderRadius.circular(13), child: Image.network(product.imageUrl, width: size, height: size, fit: BoxFit.cover, errorBuilder: (_, __, ___) => _fallback()));
    }
    return _fallback();
  }

  Widget _fallback() => Container(width: size, height: size, decoration: BoxDecoration(color: _surface, borderRadius: BorderRadius.circular(13)), child: Icon(categoryIcon(product.category), color: _blue, size: size * .42));
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
      if (mounted) setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Frame(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          PageHeader(title: widget.category ?? 'Inventory', subtitle: '${items.length} products', action: FilledButton.icon(onPressed: () => showProductForm(context), icon: const Icon(Icons.add), label: const Text('Add product'))),
          const SizedBox(height: 18),
          Wrap(spacing: 10, runSpacing: 10, children: [SizedBox(width: 360, child: TextField(onChanged: (value) { query = value; load(); }, decoration: const InputDecoration(prefixIcon: Icon(Icons.search), hintText: 'Search name, brand, model, SKU...'))), _FilterChip(label: 'All products', icon: Icons.tune_outlined), _FilterChip(label: 'Low stock', icon: Icons.warning_amber_outlined), _FilterChip(label: 'In stock', icon: Icons.check_circle_outline)]),
          const SizedBox(height: 16),
          Expanded(child: loading ? const Center(child: CircularProgressIndicator()) : items.isEmpty ? _EmptyState(onAdd: () => showProductForm(context)) : LayoutBuilder(builder: (_, c) { final columns = c.maxWidth >= 1200 ? 4 : c.maxWidth >= 760 ? 3 : 2; return GridView.builder(itemCount: items.length, gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: columns, crossAxisSpacing: 14, mainAxisSpacing: 14, childAspectRatio: .72), itemBuilder: (_, i) => ProductCard(items[i], onTap: () => showProductDetails(context, items[i], load)); })) ,
        ],
      ),
    );
  }

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
    final saved = await showDialog<bool>(context: context, builder: (_) => AlertDialog(title: const Text('Add product'), content: SizedBox(width: 520, child: Form(key: formKey, child: SingleChildScrollView(child: Column(children: [field(name, 'Product name'), field(brand, 'Brand'), field(category, 'Category'), field(model, 'Model'), field(sku, 'SKU'), Row(children: [Expanded(child: field(purchase, 'Purchase price', number: true)), const SizedBox(width: 10), Expanded(child: field(selling, 'Selling price', number: true))]), Row(children: [Expanded(child: field(mrp, 'MRP', number: true)), const SizedBox(width: 10), Expanded(child: field(quantity, 'Quantity', number: true))]), field(minimum, 'Minimum stock', number: true)])))), actions: [TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')), FilledButton(onPressed: () { if (formKey.currentState!.validate()) Navigator.pop(context, true); }, child: const Text('Save'))]));
    if (saved != true) return;
    await AppDatabase.instance.addProduct({'name': name.text.trim(), 'brand': brand.text.trim(), 'category': category.text.trim(), 'model': model.text.trim(), 'sku': sku.text.trim(), 'barcode': '', 'image_url': '', 'mrp': double.tryParse(mrp.text) ?? 0, 'selling_price': double.tryParse(selling.text) ?? 0, 'purchase_price': double.tryParse(purchase.text) ?? 0, 'quantity': int.tryParse(quantity.text) ?? 0, 'minimum_stock': int.tryParse(minimum.text) ?? 2, 'supplier': '', 'warranty': '', 'gst_rate': 18, 'hsn_code': '', 'location': 'Main Store', 'rack': '', 'shelf': '', 'serial_tracking': 0, 'imei_tracking': 0, 'specs': '', 'notes': '', 'archived': 0});
    await load();
  }

  Widget field(TextEditingController controller, String label, {bool number = false}) => Padding(padding: const EdgeInsets.only(bottom: 10), child: TextFormField(controller: controller, keyboardType: number ? const TextInputType.numberWithOptions(decimal: true) : null, validator: (value) => value == null || value.trim().isEmpty ? 'Required' : null, decoration: InputDecoration(labelText: label)));
}

class _FilterChip extends StatelessWidget {
  final String label;
  final IconData icon;
  const _FilterChip({required this.label, required this.icon});
  @override
  Widget build(BuildContext context) => OutlinedButton.icon(onPressed: () {}, icon: Icon(icon, size: 17), label: Text(label), style: OutlinedButton.styleFrom(backgroundColor: Colors.white, foregroundColor: _ink, side: BorderSide(color: Colors.black.withAlpha(10)), padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 15), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15))));
}

class _EmptyState extends StatelessWidget {
  final VoidCallback onAdd;
  const _EmptyState({required this.onAdd});
  @override
  Widget build(BuildContext context) => Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [Container(width: 70, height: 70, decoration: BoxDecoration(color: _blue.withAlpha(12), shape: BoxShape.circle), child: const Icon(Icons.inventory_2_outlined, color: _blue, size: 32)), const SizedBox(height: 14), const Text('No products found', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)), const SizedBox(height: 6), const Text('Try another search or add your first product.', style: TextStyle(color: _muted)), const SizedBox(height: 14), FilledButton.icon(onPressed: onAdd, icon: const Icon(Icons.add), label: const Text('Add product'))]));
}

class ProductCard extends StatelessWidget {
  final Product product;
  final VoidCallback? onTap;

  const ProductCard(this.product, {super.key, this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Expanded(child: Stack(children: [Center(child: _ProductThumb(product: product, size: 120)), Positioned(top: 0, right: 0, child: StatusBadge(product.status))])),
            const SizedBox(height: 8),
            Text(product.brand, style: const TextStyle(color: _muted, fontSize: 10.5, fontWeight: FontWeight.w700)),
            const SizedBox(height: 3),
            Text(product.name, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 13)),
            const SizedBox(height: 8),
            Row(children: [Expanded(child: Text(money(product.sellingPrice), style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w900))), Text('${product.quantity} left', style: const TextStyle(color: _muted, fontSize: 10))]),
          ]),
        ),
      ),
    );
  }
}

Future<void> showProductDetails(BuildContext context, Product p, Future<void> Function() refresh) async {
  await showModalBottomSheet<void>(context: context, isScrollControlled: true, backgroundColor: Colors.white, shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(28))), builder: (_) => SafeArea(child: Padding(padding: const EdgeInsets.fromLTRB(22, 16, 22, 22), child: Wrap(children: [Center(child: Container(width: 42, height: 4, decoration: BoxDecoration(color: Colors.black12, borderRadius: BorderRadius.circular(4)))), const SizedBox(height: 16), Row(children: [_ProductThumb(product: p, size: 72), const SizedBox(width: 14), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(p.name, style: const TextStyle(fontSize: 19, fontWeight: FontWeight.w900)), Text('${p.brand} · ${p.sku}', style: const TextStyle(color: _muted, fontSize: 12)), const SizedBox(height: 7), StatusBadge(p.status)]))]), const SizedBox(height: 18), _DetailLine('Selling price', money(p.sellingPrice)), _DetailLine('Purchase price', money(p.purchasePrice)), _DetailLine('Stock', '${p.quantity} units'), _DetailLine('Margin', '${p.margin.toStringAsFixed(1)}%'), const SizedBox(height: 14), Row(children: [Expanded(child: OutlinedButton.icon(onPressed: () async { Navigator.pop(context); await AppDatabase.instance.adjustStock(p.id, 1, 'ADJUSTMENT', 'Manual stock addition'); await refresh(); }, icon: const Icon(Icons.add), label: const Text('Add stock'))), const SizedBox(width: 10), Expanded(child: FilledButton.icon(onPressed: () async { Navigator.pop(context); await AppDatabase.instance.adjustStock(p.id, -1, 'ADJUSTMENT', 'Manual stock removal'); await refresh(); }, icon: const Icon(Icons.remove), label: const Text('Remove stock')))])]))));
}

class _DetailLine extends StatelessWidget {
  final String label;
  final String value;
  const _DetailLine(this.label, this.value);
  @override
  Widget build(BuildContext context) => Padding(padding: const EdgeInsets.symmetric(vertical: 7), child: Row(children: [Expanded(child: Text(label, style: const TextStyle(color: _muted))), Text(value, style: const TextStyle(fontWeight: FontWeight.w800))]));
}

class PurchasesPage extends StatelessWidget {
  const PurchasesPage({super.key});

  @override
  Widget build(BuildContext context) => Frame(child: ListView(children: [const PageHeader(title: 'Purchases', subtitle: 'Receive stock, manage suppliers and track invoices'), const SizedBox(height: 20), _PurchaseHero(), const SizedBox(height: 20), LayoutBuilder(builder: (_, c) { final columns = c.maxWidth > 900 ? 3 : 1; final tiles = [_FeatureCard(icon: Icons.add_shopping_cart_rounded, title: 'New purchase', subtitle: 'Receive stock and update inventory in one flow.'), _FeatureCard(icon: Icons.local_shipping_outlined, title: 'Suppliers', subtitle: 'Contacts, invoices, balances and purchase history.'), _FeatureCard(icon: Icons.history_rounded, title: 'Purchase history', subtitle: 'Review previous purchases, costs and payment status.')]; return GridView.count(shrinkWrap: true, physics: const NeverScrollableScrollPhysics(), crossAxisCount: columns, crossAxisSpacing: 14, mainAxisSpacing: 14, childAspectRatio: columns == 1 ? 3.3 : 1.45, children: tiles; })]));
}

class _PurchaseHero extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Container(padding: const EdgeInsets.all(20), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(22)), child: Row(children: [Container(width: 48, height: 48, decoration: BoxDecoration(color: _blue.withAlpha(14), borderRadius: BorderRadius.circular(14)), child: const Icon(Icons.local_shipping_outlined, color: _blue)), const SizedBox(width: 14), const Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('Stock coming in?', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16)), SizedBox(height: 4), Text('Create a purchase order and keep quantities, costs and supplier records aligned.', style: TextStyle(color: _muted, fontSize: 12))])), FilledButton.icon(onPressed: () {}, icon: const Icon(Icons.add), label: const Text('New purchase'))]));
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

  Future<void> load() async { try { final result = await AppDatabase.instance.products(); if (mounted) setState(() => products = result); } catch (_) {} }

  void add(Product p) {
    if (p.quantity <= 0) return;
    final i = cart.indexWhere((x) => x['product_id'] == p.id);
    if (i >= 0) { final q = cart[i]['quantity'] as int; if (q < p.quantity) cart[i]['quantity'] = q + 1; }
    else { cart.add({'product_id': p.id, 'quantity': 1, 'price': p.sellingPrice, 'name': p.name}); }
    setState(() {});
  }

  Future<void> checkout() async {
    try { await AppDatabase.instance.sellCart(cart); if (!mounted) return; setState(cart.clear); await load(); ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Sale completed and stock updated.'))); }
    catch (e) { if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString()))); }
  }

  @override
  Widget build(BuildContext context) {
    final total = cart.fold<double>(0, (sum, x) => sum + (x['price'] as num).toDouble() * (x['quantity'] as int));
    final wide = MediaQuery.sizeOf(context).width >= 900;
    final grid = Expanded(child: GridView.builder(itemCount: products.length, gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: MediaQuery.sizeOf(context).width >= 1200 ? 4 : 2, crossAxisSpacing: 12, mainAxisSpacing: 12, childAspectRatio: .8), itemBuilder: (_, i) => ProductCard(products[i], onTap: () => add(products[i]))));
    final cartPanel = _CartPanel(cart: cart, total: total, checkout: checkout);
    return Frame(child: Column(children: [PageHeader(title: 'Sales', subtitle: 'Fast point of sale'), const SizedBox(height: 16), Expanded(child: wide ? Row(children: [grid, const SizedBox(width: 16), SizedBox(width: 350, child: cartPanel)]) : Column(children: [grid, const SizedBox(height: 10), SizedBox(width: double.infinity, child: FilledButton(onPressed: cart.isEmpty ? null : checkout, child: Text('Cart · ${money(total)}')))]))]));
  }
}

class _CartPanel extends StatelessWidget {
  final List<Map<String, Object?>> cart;
  final double total;
  final VoidCallback checkout;
  const _CartPanel({required this.cart, required this.total, required this.checkout});
  @override
  Widget build(BuildContext context) => Card(child: Padding(padding: const EdgeInsets.all(16), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Row(children: [const Expanded(child: Text('Current sale', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900))), Container(padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5), decoration: BoxDecoration(color: _surface, borderRadius: BorderRadius.circular(20)), child: Text('${cart.length} items', style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w800)))]), const SizedBox(height: 12), Expanded(child: cart.isEmpty ? const Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Icons.point_of_sale_outlined, size: 42, color: _muted), SizedBox(height: 8), Text('Tap a product to add it', style: TextStyle(color: _muted))])) : ListView(children: [for (final x in cart) ListTile(contentPadding: EdgeInsets.zero, title: Text(x['name'].toString(), maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.w700)), subtitle: Text('${x['quantity']} × ${money(x['price'] as num)}'), trailing: Text(money((x['price'] as num) * (x['quantity'] as int)), style: const TextStyle(fontWeight: FontWeight.w800)))])), const Divider(), Row(children: [const Expanded(child: Text('Total', style: TextStyle(color: _muted))), Text(money(total), style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900))]), const SizedBox(height: 12), SizedBox(width: double.infinity, child: FilledButton(onPressed: cart.isEmpty ? null : checkout, child: const Text('Complete sale')))])));
}

class MorePage extends StatelessWidget {
  const MorePage({super.key});
  @override
  Widget build(BuildContext context) => Frame(child: ListView(children: [const PageHeader(title: 'More', subtitle: 'Business tools and settings'), const SizedBox(height: 20), LayoutBuilder(builder: (_, c) { final columns = c.maxWidth > 900 ? 3 : 1; final tiles = [_FeatureCard(icon: Icons.people_outline, title: 'Customers', subtitle: 'Customer profiles, invoices and balances.'), _FeatureCard(icon: Icons.local_shipping_outlined, title: 'Suppliers', subtitle: 'Supplier contacts, purchase history and payments.'), _FeatureCard(icon: Icons.receipt_long_outlined, title: 'Expenses', subtitle: 'Track operating expenses and payment methods.'), _FeatureCard(icon: Icons.bar_chart_outlined, title: 'Reports', subtitle: 'Sales, profit, stock and movement analytics.'), _FeatureCard(icon: Icons.backup_outlined, title: 'Backup & restore', subtitle: 'Protect and restore your local shop database.'), _FeatureCard(icon: Icons.settings_outlined, title: 'Settings', subtitle: 'Shop profile, GST, inventory and users.')]; return GridView.count(shrinkWrap: true, physics: const NeverScrollableScrollPhysics(), crossAxisCount: columns, crossAxisSpacing: 14, mainAxisSpacing: 14, childAspectRatio: columns == 1 ? 3.3 : 1.55, children: tiles; })]));
}

class _FeatureCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  const _FeatureCard({required this.icon, required this.title, required this.subtitle});
  @override
  Widget build(BuildContext context) => Card(child: InkWell(borderRadius: BorderRadius.circular(20), onTap: () {}, child: Padding(padding: const EdgeInsets.all(17), child: Row(children: [Container(width: 44, height: 44, decoration: BoxDecoration(color: _blue.withAlpha(12), borderRadius: BorderRadius.circular(13)), child: Icon(icon, color: _blue, size: 21)), const SizedBox(width: 13), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.center, children: [Text(title, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 13)), const SizedBox(height: 5), Text(subtitle, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(color: _muted, fontSize: 11))])), const Icon(Icons.chevron_right_rounded, color: _muted)]))));
}

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
  if (c.contains('watch')) return Icons.watch_outlined;
  if (c.contains('monitor')) return Icons.monitor_outlined;
  if (c.contains('kitchen')) return Icons.blender_outlined;
  return Icons.devices_other_outlined;
}
