import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'data/database.dart';
import 'models/models.dart';

String money(num value) => NumberFormat.currency(locale: 'en_IN', symbol: '₹', decimalDigits: 0).format(value);

void main() async {
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
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: const Color(0xFF3155E7),
        scaffoldBackgroundColor: const Color(0xFFF7F8FA),
        fontFamily: 'Inter',
        cardTheme: const CardThemeData(elevation: 0, margin: EdgeInsets.zero),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(16)),
            borderSide: BorderSide.none,
          ),
        ),
      ),
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
  final icons = const [
    Icons.home_outlined,
    Icons.inventory_2_outlined,
    Icons.shopping_bag_outlined,
    Icons.point_of_sale_outlined,
    Icons.more_horiz,
  ];

  @override
  Widget build(BuildContext context) {
    final wide = MediaQuery.sizeOf(context).width >= 900;
    return Scaffold(
      body: wide
          ? Row(
              children: [
                NavigationRail(
                  selectedIndex: index,
                  onDestinationSelected: (value) => setState(() => index = value),
                  labelType: NavigationRailLabelType.all,
                  leading: const Padding(
                    padding: EdgeInsets.all(20),
                    child: Text('INVENTORY', style: TextStyle(fontWeight: FontWeight.w900)),
                  ),
                  destinations: [
                    for (var i = 0; i < labels.length; i++)
                      NavigationRailDestination(icon: Icon(icons[i]), label: Text(labels[i])),
                  ],
                ),
                const VerticalDivider(width: 1),
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

class Frame extends StatelessWidget {
  final Widget child;
  const Frame({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1450),
          child: Padding(padding: const EdgeInsets.all(20), child: child),
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
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w900)),
              if (subtitle != null) Text(subtitle!, style: const TextStyle(color: Colors.grey)),
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
    Color color;
    if (status == 'IN STOCK') {
      color = Colors.green;
    } else if (status == 'LOW STOCK') {
      color = Colors.orange;
    } else {
      color = Colors.red;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(color: color.withAlpha(24), borderRadius: BorderRadius.circular(20)),
      child: Text(status, style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.w800)),
    );
  }
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

  @override
  void initState() {
    super.initState();
    load();
  }

  Future<void> load() async {
    final db = await AppDatabase.instance.db;
    final list = await AppDatabase.instance.products();
    final s = await db.rawQuery('SELECT COALESCE(SUM(total),0) value FROM sales');
    final p = await db.rawQuery('SELECT COALESCE(SUM(total),0) value FROM purchases');
    if (!mounted) return;
    setState(() {
      products = list;
      sales = (s.first['value'] as num?)?.toDouble() ?? 0;
      purchases = (p.first['value'] as num?)?.toDouble() ?? 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    final low = products.where((p) => p.quantity <= p.minimumStock).take(5).toList();
    final inventoryValue = products.fold<double>(0, (sum, p) => sum + p.quantity * p.purchasePrice);
    return Frame(
      child: RefreshIndicator(
        onRefresh: load,
        child: ListView(
          children: [
            const Text('Good morning', style: TextStyle(fontSize: 30, fontWeight: FontWeight.w900)),
            const Text('ElectroMart Electronics', style: TextStyle(color: Colors.grey)),
            const SizedBox(height: 18),
            const TextField(decoration: InputDecoration(prefixIcon: Icon(Icons.search), hintText: 'Search products, brands, models, SKU or barcode')),
            const SizedBox(height: 26),
            const Text('Categories', style: TextStyle(fontSize: 21, fontWeight: FontWeight.w800)),
            const SizedBox(height: 12),
            SizedBox(
              height: 104,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  for (final c in const ['Mobile Phones', 'Laptops', 'Televisions', 'Refrigerators', 'Audio', 'Cameras', 'Printers', 'Networking'])
                    Padding(
                      padding: const EdgeInsets.only(right: 10),
                      child: Container(
                        width: 140,
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(18)),
                        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          Icon(categoryIcon(c), size: 30),
                          const Spacer(),
                          Text(c, maxLines: 2, style: const TextStyle(fontWeight: FontWeight.w700)),
                        ]),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 26),
            const Text('Business snapshot', style: TextStyle(fontSize: 21, fontWeight: FontWeight.w800)),
            const SizedBox(height: 12),
            Wrap(spacing: 12, runSpacing: 12, children: [
              Metric('Sales', money(sales), Icons.point_of_sale_outlined),
              Metric('Purchases', money(purchases), Icons.shopping_bag_outlined),
              Metric('Inventory value', money(inventoryValue), Icons.inventory_2_outlined),
              Metric('Low stock', '${low.length} items', Icons.warning_amber_outlined),
            ]),
            const SizedBox(height: 26),
            Row(children: [
              const Expanded(child: Text('Low stock', style: TextStyle(fontSize: 21, fontWeight: FontWeight.w800))),
              TextButton(onPressed: () {}, child: const Text('View all')),
            ]),
            for (final p in low)
              Card(
                child: ListTile(
                  leading: CircleAvatar(child: Icon(categoryIcon(p.category))),
                  title: Text('${p.brand} · ${p.name}'),
                  subtitle: Text('${p.quantity} units left · ${p.sku}'),
                  trailing: StatusBadge(p.status),
                ),
              ),
            const SizedBox(height: 20),
            const Text('Top products', style: TextStyle(fontSize: 21, fontWeight: FontWeight.w800)),
            const SizedBox(height: 12),
            SizedBox(
              height: 210,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: products.length > 10 ? 10 : products.length,
                separatorBuilder: (_, __) => const SizedBox(width: 12),
                itemBuilder: (_, i) => ProductCard(products[i]),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class Metric extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  const Metric(this.title, this.value, this.icon, {super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 220,
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(children: [
            Icon(icon, size: 30),
            const SizedBox(width: 12),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(title, style: const TextStyle(color: Colors.grey, fontSize: 12)),
              const SizedBox(height: 5),
              Text(value, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 18)),
            ])),
          ]),
        ),
      ),
    );
  }
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
    final result = await AppDatabase.instance.products(query: query, category: widget.category);
    if (!mounted) return;
    setState(() {
      items = result;
      loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Frame(
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        PageHeader(
          title: widget.category ?? 'Inventory',
          subtitle: '${items.length} products',
          action: FilledButton.icon(onPressed: () => showProductForm(context), icon: const Icon(Icons.add), label: const Text('Add Product')),
        ),
        const SizedBox(height: 16),
        TextField(
          controller: TextEditingController(text: query),
          onChanged: (value) {
            query = value;
            load();
          },
          decoration: const InputDecoration(prefixIcon: Icon(Icons.search), hintText: 'Search products, brands, SKU or barcode'),
        ),
        const SizedBox(height: 14),
        Expanded(
          child: loading
              ? const Center(child: CircularProgressIndicator())
              : items.isEmpty
                  ? const Center(child: Text('No products found'))
                  : GridView.builder(
                      itemCount: items.length,
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: MediaQuery.sizeOf(context).width >= 1200 ? 4 : 2,
                        crossAxisSpacing: 14,
                        mainAxisSpacing: 14,
                        childAspectRatio: .76,
                      ),
                      itemBuilder: (_, i) => ProductCard(items[i], onTap: () => showProductDetails(context, items[i], load)),
                    ),
        ),
      ],),
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
    final saved = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Add product'),
        content: SizedBox(
          width: 520,
          child: Form(
            key: formKey,
            child: SingleChildScrollView(
              child: Column(children: [
                field(name, 'Product name'), field(brand, 'Brand'), field(category, 'Category'), field(model, 'Model'), field(sku, 'SKU'),
                Row(children: [Expanded(child: field(purchase, 'Purchase price', number: true)), const SizedBox(width: 10), Expanded(child: field(selling, 'Selling price', number: true))]),
                Row(children: [Expanded(child: field(mrp, 'MRP', number: true)), const SizedBox(width: 10), Expanded(child: field(quantity, 'Quantity', number: true))]),
                field(minimum, 'Minimum stock', number: true),
              ]),
            ),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          FilledButton(onPressed: () { if (formKey.currentState!.validate()) Navigator.pop(context, true); }, child: const Text('Save')),
        ],
      ),
    );
    if (saved != true) return;
    await AppDatabase.instance.addProduct({
      'name': name.text.trim(), 'brand': brand.text.trim(), 'category': category.text.trim(), 'model': model.text.trim(), 'sku': sku.text.trim(), 'barcode': '',
      'image_url': '', 'mrp': double.tryParse(mrp.text) ?? 0, 'selling_price': double.tryParse(selling.text) ?? 0, 'purchase_price': double.tryParse(purchase.text) ?? 0,
      'quantity': int.tryParse(quantity.text) ?? 0, 'minimum_stock': int.tryParse(minimum.text) ?? 2, 'supplier': '', 'warranty': '', 'gst_rate': 18, 'hsn_code': '',
      'location': 'Main Store', 'rack': '', 'shelf': '', 'serial_tracking': 0, 'imei_tracking': 0, 'specs': '', 'notes': '', 'archived': 0,
    });
    await load();
  }

  Widget field(TextEditingController controller, String label, {bool number = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: TextFormField(
        controller: controller,
        keyboardType: number ? const TextInputType.numberWithOptions(decimal: true) : null,
        validator: (value) => value == null || value.trim().isEmpty ? 'Required' : null,
        decoration: InputDecoration(labelText: label),
      ),
    );
  }
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
          padding: const EdgeInsets.all(10),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Expanded(
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(color: const Color(0xFFF0F2F6), borderRadius: BorderRadius.circular(14)),
                child: Icon(categoryIcon(product.category), size: 64),
              ),
            ),
            const SizedBox(height: 9),
            Text(product.brand, style: const TextStyle(color: Colors.grey, fontSize: 12)),
            Text(product.name, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.w800)),
            const SizedBox(height: 5),
            Text(money(product.sellingPrice), style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900)),
            const SizedBox(height: 5),
            Row(children: [StatusBadge(product.status), const Spacer(), Text('${product.quantity} left', style: const TextStyle(color: Colors.grey, fontSize: 11))]),
          ]),
        ),
      ),
    );
  }
}

Future<void> showProductDetails(BuildContext context, Product product, VoidCallback refresh) async {
  await showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (_) => Padding(
      padding: const EdgeInsets.all(22),
      child: Wrap(children: [
        Row(children: [Expanded(child: Text(product.name, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900))), StatusBadge(product.status)]),
        Text('${product.brand} · ${product.category}', style: const TextStyle(color: Colors.grey)),
        const SizedBox(height: 16),
        Container(height: 170, width: double.infinity, decoration: BoxDecoration(color: const Color(0xFFF0F2F6), borderRadius: BorderRadius.circular(20)), child: Icon(categoryIcon(product.category), size: 80)),
        const SizedBox(height: 16),
        Text(money(product.sellingPrice), style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w900)),
        Text('Cost ${money(product.purchasePrice)}  •  Profit ${money(product.profit)}  •  Margin ${product.margin.toStringAsFixed(1)}%'),
        const SizedBox(height: 12),
        Wrap(spacing: 8, children: [Chip(label: Text('Stock ${product.quantity}')), Chip(label: Text('Min ${product.minimumStock}')), Chip(label: Text('SKU ${product.sku}'))]),
        const SizedBox(height: 12),
        Row(children: [
          Expanded(child: OutlinedButton.icon(onPressed: () => adjustStock(context, product, refresh), icon: const Icon(Icons.inventory_2_outlined), label: const Text('Adjust Stock'))),
          const SizedBox(width: 8),
          Expanded(child: FilledButton.icon(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.point_of_sale), label: const Text('Sell'))),
        ]),
      ]),
    ),
  );
}

Future<void> adjustStock(BuildContext context, Product product, VoidCallback refresh) async {
  final controller = TextEditingController();
  final reason = TextEditingController();
  final ok = await showDialog<bool>(
    context: context,
    builder: (_) => AlertDialog(
      title: const Text('Adjust stock'),
      content: Column(mainAxisSize: MainAxisSize.min, children: [
        Text('Current stock: ${product.quantity}'),
        TextField(controller: controller, keyboardType: const TextInputType.numberWithOptions(signed: true), decoration: const InputDecoration(labelText: 'Quantity change', hintText: '+5 or -1')),
        TextField(controller: reason, decoration: const InputDecoration(labelText: 'Reason')),
      ]),
      actions: [TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')), FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('Save'))],
    ),
  );
  if (ok != true) return;
  try {
    await AppDatabase.instance.adjustStock(product, int.tryParse(controller.text) ?? 0, reason.text.trim().isEmpty ? 'Stock adjustment' : reason.text.trim());
    refresh();
  } catch (e) {
    if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
  }
}

class PurchasesPage extends StatelessWidget {
  const PurchasesPage({super.key});
  @override
  Widget build(BuildContext context) => Frame(child: ListView(children: const [PageHeader(title: 'Purchases', subtitle: 'Receive stock and manage supplier invoices'), SizedBox(height: 20), FeatureTile(icon: Icons.add_shopping_cart, title: 'New Purchase', subtitle: 'Create a purchase and increase stock atomically'), FeatureTile(icon: Icons.local_shipping_outlined, title: 'Suppliers', subtitle: 'Manage suppliers, invoices and outstanding payments'), FeatureTile(icon: Icons.history, title: 'Purchase History', subtitle: 'Review previous purchases and costs')]));
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
    final result = await AppDatabase.instance.products();
    if (mounted) setState(() => products = result);
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
    return Frame(child: Column(children: [
      const PageHeader(title: 'Sales', subtitle: 'Fast point of sale'),
      const SizedBox(height: 16),
      Expanded(child: Row(children: [
        Expanded(child: GridView.builder(itemCount: products.length, gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: MediaQuery.sizeOf(context).width >= 1200 ? 4 : 2, crossAxisSpacing: 12, mainAxisSpacing: 12, childAspectRatio: .9), itemBuilder: (_, i) => InkWell(onTap: () => add(products[i]), child: ProductCard(products[i])))),
        const SizedBox(width: 16),
        SizedBox(width: MediaQuery.sizeOf(context).width >= 900 ? 340 : 0, child: MediaQuery.sizeOf(context).width >= 900 ? Card(child: Padding(padding: const EdgeInsets.all(16), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [const Text('Cart', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900)), const SizedBox(height: 12), Expanded(child: ListView(children: [for (final x in cart) ListTile(title: Text(x['name'].toString()), subtitle: Text('${x['quantity']} × ${money(x['price'] as num)}'))])), const Divider(), Text('Total ${money(total)}', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900)), const SizedBox(height: 10), SizedBox(width: double.infinity, child: FilledButton(onPressed: cart.isEmpty ? null : checkout, child: const Text('Complete Sale')))])) : null),
      ])),
    ]));
  }
}

class MorePage extends StatelessWidget {
  const MorePage({super.key});
  @override
  Widget build(BuildContext context) => Frame(child: ListView(children: const [PageHeader(title: 'More', subtitle: 'Business tools and settings'), SizedBox(height: 18), FeatureTile(icon: Icons.people_outline, title: 'Customers', subtitle: 'Customer profiles, invoices and balances'), FeatureTile(icon: Icons.local_shipping_outlined, title: 'Suppliers', subtitle: 'Supplier history and payments'), FeatureTile(icon: Icons.receipt_long_outlined, title: 'Expenses', subtitle: 'Track operating expenses'), FeatureTile(icon: Icons.bar_chart_outlined, title: 'Reports', subtitle: 'Sales, profit, inventory and stock movement'), FeatureTile(icon: Icons.backup_outlined, title: 'Backup & Restore', subtitle: 'Protect your local shop database'), FeatureTile(icon: Icons.settings_outlined, title: 'Settings', subtitle: 'Shop profile, GST, inventory and users')]));
}

class FeatureTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  const FeatureTile({super.key, required this.icon, required this.title, required this.subtitle});
  @override
  Widget build(BuildContext context) => Card(margin: const EdgeInsets.only(bottom: 10), child: ListTile(leading: CircleAvatar(child: Icon(icon)), title: Text(title, style: const TextStyle(fontWeight: FontWeight.w800)), subtitle: Text(subtitle), trailing: const Icon(Icons.chevron_right)));
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
  return Icons.devices_other_outlined;
}
