import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:sqflite/sqflite.dart';

import 'data/database.dart';
import 'models/models.dart';
import 'services/product_catalog_service.dart';

const primary = Color(0xFF4B63E6);
const purple = Color(0xFF7659F6);
const green = Color(0xFF18A56B);
const orange = Color(0xFFE28A19);
const red = Color(0xFFE05252);
const ink = Color(0xFF171923);
const muted = Color(0xFF747783);
const background = Color(0xFFF5F6FA);

String money(num value) => NumberFormat.currency(
      locale: 'en_IN',
      symbol: '₹',
      decimalDigits: 0,
    ).format(value);

void main() => runApp(const ModernApp());

class ModernApp extends StatelessWidget {
  const ModernApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Inventory POS',
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: background,
        colorScheme: ColorScheme.fromSeed(seedColor: primary),
        cardTheme: CardThemeData(
          elevation: 0,
          color: Colors.white,
          margin: EdgeInsets.zero,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
        ),
        navigationBarTheme: NavigationBarThemeData(
          height: 76,
          backgroundColor: Colors.white,
          indicatorColor: primary.withAlpha(22),
          labelTextStyle: const WidgetStatePropertyAll(
            TextStyle(fontWeight: FontWeight.w800, fontSize: 12),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 15, vertical: 14),
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
            borderSide: const BorderSide(color: primary, width: 1.2),
          ),
        ),
      ),
      home: const Shell(),
    );
  }
}

class Shell extends StatefulWidget {
  const Shell({super.key});

  @override
  State<Shell> createState() => _ShellState();
}

class _ShellState extends State<Shell> {
  int selected = 0;

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
    final pages = <Widget>[
      HomePage(
        onInventory: () => setState(() => selected = 1),
        onSales: () => setState(() => selected = 3),
      ),
      const InventoryPage(),
      const PurchasesPage(),
      const SalesPage(),
      const MorePage(),
    ];
    final wide = MediaQuery.sizeOf(context).width >= 900;

    return Scaffold(
      body: wide
          ? Row(
              children: [
                Container(
                  width: 225,
                  color: Colors.white,
                  padding: const EdgeInsets.fromLTRB(14, 22, 14, 14),
                  child: Column(
                    children: [
                      const Brand(),
                      const SizedBox(height: 24),
                      Expanded(
                        child: NavigationRail(
                          extended: true,
                          minExtendedWidth: 195,
                          selectedIndex: selected,
                          onDestinationSelected: (value) =>
                              setState(() => selected = value),
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
                      const Text(
                        'ElectroMart • Main Store',
                        style: TextStyle(color: muted, fontSize: 10),
                      ),
                    ],
                  ),
                ),
                const VerticalDivider(width: 1),
                Expanded(child: pages[selected]),
              ],
            )
          : pages[selected],
      bottomNavigationBar: wide
          ? null
          : NavigationBar(
              selectedIndex: selected,
              onDestinationSelected: (value) =>
                  setState(() => selected = value),
              destinations: [
                for (var i = 0; i < labels.length; i++)
                  NavigationDestination(
                    icon: Icon(icons[i]),
                    label: labels[i],
                  ),
              ],
            ),
    );
  }
}

class Brand extends StatelessWidget {
  const Brand({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            gradient: const LinearGradient(colors: [primary, purple]),
            borderRadius: BorderRadius.circular(13),
          ),
          child: const Icon(Icons.bolt_rounded, color: Colors.white),
        ),
        const SizedBox(width: 10),
        const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('INVENTORY',
                style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1)),
            Text('ElectroMart POS',
                style: TextStyle(color: muted, fontSize: 10)),
          ],
        ),
      ],
    );
  }
}

class PageFrame extends StatelessWidget {
  final Widget child;
  const PageFrame({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1440),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 18, 20, 22),
            child: child,
          ),
        ),
      ),
    );
  }
}

class PageHeader extends StatelessWidget {
  final String title;
  final String subtitle;
  final Widget? action;

  const PageHeader({
    super.key,
    required this.title,
    required this.subtitle,
    this.action,
  });

  @override
  Widget build(BuildContext context) {
    final heading = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title,
            style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w900,
                color: ink,
                letterSpacing: -.8)),
        const SizedBox(height: 3),
        Text(subtitle, style: const TextStyle(color: muted)),
      ],
    );

    if (action == null) return heading;
    return LayoutBuilder(
      builder: (_, constraints) {
        if (constraints.maxWidth < 620) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [heading, const SizedBox(height: 12), action!],
          );
        }
        return Row(children: [Expanded(child: heading), action!]);
      },
    );
  }
}

class SearchField extends StatelessWidget {
  final String hint;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onScan;

  const SearchField({
    super.key,
    required this.hint,
    this.onChanged,
    this.onScan,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      onChanged: onChanged,
      decoration: InputDecoration(
        prefixIcon: const Icon(Icons.search_rounded),
        hintText: hint,
        suffixIcon: onScan == null
            ? null
            : IconButton(
                tooltip: 'Barcode / SKU',
                onPressed: onScan,
                icon: const Icon(Icons.qr_code_scanner_rounded),
              ),
      ),
    );
  }
}

class StatusBadge extends StatelessWidget {
  final String status;
  const StatusBadge(this.status, {super.key});

  @override
  Widget build(BuildContext context) {
    final color = status == 'IN STOCK'
        ? green
        : status == 'LOW STOCK'
            ? orange
            : red;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
      decoration: BoxDecoration(
        color: color.withAlpha(18),
        borderRadius: BorderRadius.circular(30),
      ),
      child: Text(
        status,
        style: TextStyle(color: color, fontSize: 9, fontWeight: FontWeight.w900),
      ),
    );
  }
}

class ProductImage extends StatefulWidget {
  final Product product;
  final double size;

  const ProductImage({
    super.key,
    required this.product,
    this.size = 120,
  });

  @override
  State<ProductImage> createState() => _ProductImageState();
}

class _ProductImageState extends State<ProductImage> {
  String? url;

  @override
  void initState() {
    super.initState();
    url = widget.product.imageUrl.trim().isEmpty
        ? null
        : widget.product.imageUrl.trim();
    if (url == null) _findImage();
  }

  Future<void> _findImage() async {
    final found = await ProductCatalogService.findImage(
      '${widget.product.brand} ${widget.product.name} ${widget.product.model}',
      brand: widget.product.brand,
      category: widget.product.category,
    );
    if (mounted && found != null && found.isNotEmpty) {
      setState(() => url = found);
    }
  }

  @override
  Widget build(BuildContext context) {
    final fallback = Container(
      width: widget.size,
      height: widget.size,
      decoration: BoxDecoration(
        color: const Color(0xFFF1F3F8),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Icon(
        categoryIcon(widget.product.category),
        size: widget.size * .32,
        color: ink,
      ),
    );

    if (url == null) return fallback;
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: Image.network(
        url!,
        width: widget.size,
        height: widget.size,
        fit: BoxFit.contain,
        errorBuilder: (_, __, ___) => fallback,
        loadingBuilder: (_, child, progress) =>
            progress == null ? child : fallback,
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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: ProductImage(product: product, size: 180)),
              const SizedBox(height: 8),
              Text(product.brand,
                  style: const TextStyle(color: muted, fontSize: 10)),
              Text(
                product.name,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style:
                    const TextStyle(fontWeight: FontWeight.w900, fontSize: 14),
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  Expanded(
                    child: Text(money(product.sellingPrice),
                        style: const TextStyle(
                            fontWeight: FontWeight.w900, fontSize: 16)),
                  ),
                  StatusBadge(product.status),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class HomePage extends StatefulWidget {
  final VoidCallback onInventory;
  final VoidCallback onSales;

  const HomePage({
    super.key,
    required this.onInventory,
    required this.onSales,
  });

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Product> products = [];
  Map<String, num> stats = {};
  bool loading = true;

  @override
  void initState() {
    super.initState();
    load();
  }

  Future<void> load() async {
    try {
      final p = await AppDatabase.instance.products();
      final s = await AppDatabase.instance.snapshot();
      if (mounted) {
        setState(() {
          products = p;
          stats = s;
          loading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final low = products.where((p) => p.quantity <= p.minimumStock).take(4);
    return PageFrame(
      child: RefreshIndicator(
        onRefresh: load,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          children: [
            const Text('Good morning',
                style: TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.w900,
                    color: ink,
                    letterSpacing: -1)),
            const SizedBox(height: 4),
            const Text('Run your shop from one fast workspace.',
                style: TextStyle(color: muted)),
            const SizedBox(height: 18),
            Row(
              children: [
                Expanded(
                    child: QuickAction(
                        'New sale', Icons.point_of_sale_rounded, primary,
                        widget.onSales)),
                const SizedBox(width: 10),
                Expanded(
                    child: QuickAction(
                        'Add product', Icons.add_box_rounded, purple,
                        widget.onInventory)),
              ],
            ),
            const SizedBox(height: 24),
            const Text('Business snapshot',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900)),
            const SizedBox(height: 10),
            LayoutBuilder(builder: (_, constraints) {
              final columns = constraints.maxWidth > 1000
                  ? 4
                  : constraints.maxWidth > 600
                      ? 2
                      : 1;
              final width =
                  (constraints.maxWidth - (columns - 1) * 12) / columns;
              return Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  SizedBox(
                      width: width,
                      child: MetricCard('Today sales',
                          money(stats['sales'] ?? 0), Icons.trending_up, green)),
                  SizedBox(
                      width: width,
                      child: MetricCard('Purchases',
                          money(stats['purchases'] ?? 0), Icons.shopping_bag,
                          purple)),
                  SizedBox(
                      width: width,
                      child: MetricCard(
                          'Inventory value',
                          money(stats['inventory'] ?? 0),
                          Icons.inventory_2,
                          primary,
                          note: '${products.length} products')),
                  SizedBox(
                      width: width,
                      child: MetricCard('Low stock', '${stats['low'] ?? 0}',
                          Icons.warning_amber_rounded, orange)),
                ],
              );
            }),
            const SizedBox(height: 24),
            const Text('Low stock',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900)),
            const SizedBox(height: 10),
            if (low.isEmpty)
              const EmptyCard('Stock looks healthy',
                  'No products need attention.', Icons.check_circle_outline)
            else
              ...low.map((p) => Card(
                    margin: const EdgeInsets.only(bottom: 8),
                    child: ListTile(
                      leading: ProductImage(product: p, size: 46),
                      title: Text('${p.brand} · ${p.name}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                              fontWeight: FontWeight.w800, fontSize: 13)),
                      subtitle: Text('${p.quantity} left • ${p.sku}'),
                      trailing: StatusBadge(p.status),
                    ),
                  )),
            const SizedBox(height: 24),
            Row(children: [
              const Expanded(
                  child: Text('Products',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.w900))),
              TextButton(onPressed: widget.onInventory, child: const Text('View inventory')),
            ]),
            const SizedBox(height: 8),
            SizedBox(
              height: 240,
              child: loading
                  ? const Center(child: CircularProgressIndicator())
                  : products.isEmpty
                      ? const EmptyCard('No products yet',
                          'Add your first product from Inventory.', Icons.devices)
                      : ListView.separated(
                          scrollDirection: Axis.horizontal,
                          itemCount: products.length > 8 ? 8 : products.length,
                          separatorBuilder: (_, __) => const SizedBox(width: 12),
                          itemBuilder: (_, i) => SizedBox(
                              width: 205, child: ProductCard(products[i]))),
            ),
          ],
        ),
      ),
    );
  }
}

class QuickAction extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const QuickAction(this.label, this.icon, this.color, this.onTap,
      {super.key});

  @override
  Widget build(BuildContext context) => Card(
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(children: [
              Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                      color: color.withAlpha(18),
                      borderRadius: BorderRadius.circular(12)),
                  child: Icon(icon, color: color)),
              const SizedBox(width: 10),
              Expanded(
                  child: Text(label,
                      style: const TextStyle(fontWeight: FontWeight.w900))),
              const Icon(Icons.arrow_forward_rounded, size: 18, color: muted),
            ]),
          ),
        ),
      );
}

class MetricCard extends StatelessWidget {
  final String label, value;
  final IconData icon;
  final Color color;
  final String? note;

  const MetricCard(this.label, this.value, this.icon, this.color,
      {super.key, this.note});

  @override
  Widget build(BuildContext context) => Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(children: [
            Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                    color: color.withAlpha(18),
                    borderRadius: BorderRadius.circular(13)),
                child: Icon(icon, color: color)),
            const SizedBox(width: 12),
            Expanded(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                  Text(label,
                      style: const TextStyle(color: muted, fontSize: 12)),
                  Text(value,
                      style: const TextStyle(
                          fontSize: 20, fontWeight: FontWeight.w900)),
                  if (note != null)
                    Text(note!,
                        style: const TextStyle(color: muted, fontSize: 11)),
                ])),
          ]),
        ),
      );
}

class EmptyCard extends StatelessWidget {
  final String title, subtitle;
  final IconData icon;
  const EmptyCard(this.title, this.subtitle, this.icon, {super.key});

  @override
  Widget build(BuildContext context) => Card(
        child: Padding(
          padding: const EdgeInsets.all(22),
          child: Row(children: [
            Icon(icon, color: muted, size: 40),
            const SizedBox(width: 14),
            Expanded(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                  Text(title,
                      style: const TextStyle(fontWeight: FontWeight.w900)),
                  Text(subtitle,
                      style: const TextStyle(color: muted, fontSize: 12)),
                ])),
          ]),
        ),
      );
}

class InventoryPage extends StatefulWidget {
  const InventoryPage({super.key});
  @override
  State<InventoryPage> createState() => _InventoryPageState();
}

class _InventoryPageState extends State<InventoryPage> {
  List<Product> products = [];
  String query = '';
  bool loading = true;

  @override
  void initState() {
    super.initState();
    load();
  }

  Future<void> load() async {
    try {
      final result = await AppDatabase.instance.products(query: query);
      if (mounted) {
        setState(() {
          products = result;
          loading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) => PageFrame(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          PageHeader(
            title: 'Inventory',
            subtitle: '${products.length} products in your catalog',
            action: FilledButton.icon(
                onPressed: () => addProduct(context),
                icon: const Icon(Icons.add),
                label: const Text('Add product')),
          ),
          const SizedBox(height: 15),
          SearchField(
              hint: 'Search product, brand, model, SKU or barcode',
              onChanged: (value) {
                query = value;
                load();
              },
              onScan: () => scan(context)),
          const SizedBox(height: 12),
          Expanded(
            child: loading
                ? const Center(child: CircularProgressIndicator())
                : products.isEmpty
                    ? const EmptyCard('No products found',
                        'Try another search or add a product.', Icons.inventory_2)
                    : LayoutBuilder(builder: (_, constraints) {
                        final columns = constraints.maxWidth > 1200
                            ? 4
                            : constraints.maxWidth > 760
                                ? 3
                                : 2;
                        return GridView.builder(
                          itemCount: products.length,
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: columns,
                            crossAxisSpacing: 12,
                            mainAxisSpacing: 12,
                            childAspectRatio: .76,
                          ),
                          itemBuilder: (_, i) => ProductCard(
                            products[i],
                            onTap: () => details(context, products[i]),
                          ),
                        );
                      }),
          ),
        ]),
      );

  Future<void> scan(BuildContext context) async {
    final controller = TextEditingController();
    final value = await showDialog<String>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Find by SKU / barcode'),
        content: TextField(controller: controller, autofocus: true),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          FilledButton(onPressed: () => Navigator.pop(context, controller.text.trim()), child: const Text('Find')),
        ],
      ),
    );
    controller.dispose();
    if (value != null && value.isNotEmpty) {
      query = value;
      load();
    }
  }

  Future<void> details(BuildContext context, Product product) async {
    await showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (_) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Row(children: [
              ProductImage(product: product, size: 70),
              const SizedBox(width: 12),
              Expanded(child: Text(product.name, style: const TextStyle(fontSize: 19, fontWeight: FontWeight.w900))),
              StatusBadge(product.status),
            ]),
            const SizedBox(height: 15),
            Row(children: [
              Expanded(child: Text('Selling\n${money(product.sellingPrice)}')),
              Expanded(child: Text('Purchase\n${money(product.purchasePrice)}')),
              Expanded(child: Text('Stock\n${product.quantity}')),
            ]),
            const SizedBox(height: 15),
            Row(children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () async {
                    Navigator.pop(context);
                    await AppDatabase.instance.adjustStock(product.id, 1, 'ADJUSTMENT', 'Manual addition');
                    load();
                  },
                  icon: const Icon(Icons.add),
                  label: const Text('Add stock'),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: FilledButton.icon(
                  onPressed: product.quantity == 0
                      ? null
                      : () async {
                          Navigator.pop(context);
                          await AppDatabase.instance.adjustStock(product.id, -1, 'ADJUSTMENT', 'Manual removal');
                          load();
                        },
                  icon: const Icon(Icons.remove),
                  label: const Text('Remove stock'),
                ),
              ),
            ]),
          ]),
        ),
      ),
    );
  }

  Future<void> addProduct(BuildContext context) async {
    final draft = await showDialog<ProductDraft>(
      context: context,
      builder: (_) => const AddProductDialog(),
    );
    if (draft == null) return;
    try {
      await AppDatabase.instance.addProduct(draft.toMap());
      await load();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Product added to inventory.')));
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('$error')));
      }
    }
  }
}

class ProductDraft {
  final String name, brand, category, model, sku, imageUrl;
  final double purchase, selling, mrp;
  final int quantity, minimum;

  const ProductDraft({
    required this.name,
    required this.brand,
    required this.category,
    required this.model,
    required this.sku,
    required this.imageUrl,
    required this.purchase,
    required this.selling,
    required this.mrp,
    required this.quantity,
    required this.minimum,
  });

  Map<String, Object?> toMap() => {
        'name': name,
        'brand': brand,
        'category': category,
        'model': model,
        'sku': sku,
        'barcode': '',
        'image_url': imageUrl,
        'mrp': mrp,
        'selling_price': selling,
        'purchase_price': purchase,
        'quantity': quantity,
        'minimum_stock': minimum,
        'supplier': '',
        'warranty': '1 Year',
        'gst_rate': 18,
        'hsn_code': '',
        'location': 'Main Store',
        'rack': '',
        'shelf': '',
        'serial_tracking': 0,
        'imei_tracking': category == 'Mobile Phones' ? 1 : 0,
        'specs': '',
        'notes': '',
        'archived': 0,
      };
}

class AddProductDialog extends StatefulWidget {
  const AddProductDialog({super.key});
  @override
  State<AddProductDialog> createState() => _AddProductDialogState();
}

class _AddProductDialogState extends State<AddProductDialog> {
  final formKey = GlobalKey<FormState>();
  final name = TextEditingController();
  final model = TextEditingController();
  final sku = TextEditingController(text: 'NEW-${DateTime.now().millisecondsSinceEpoch % 100000}');
  final purchase = TextEditingController();
  final selling = TextEditingController();
  final mrp = TextEditingController();
  final quantity = TextEditingController(text: '0');
  final minimum = TextEditingController(text: '2');

  String brand = 'Samsung';
  String category = 'Mobile Phones';
  String imageUrl = '';
  bool searching = false;
  List<ProductSuggestion> suggestions = [];

  static const brands = [
    'Samsung','LG','Sony','Apple','OnePlus','Motorola','Xiaomi','HP','Dell','Lenovo','ASUS','Acer','Whirlpool','IFB','Bosch','Haier','JBL','boAt','Bose','Canon','Nikon','Epson','TP-Link','Logitech','Razer','Kingston','SanDisk','Seagate','Western Digital','Philips','Oppo','Realme'
  ];
  static const categories = [
    'Mobile Phones','Laptops','Televisions','Refrigerators','Air Conditioners','Washing Machines','Audio','Cameras','Printers','Networking','Storage','Accessories','Monitors','Gaming','Smartwatches','Kitchen Appliances','Fans','Coolers','Projectors','Power & Cables'
  ];

  @override
  void dispose() {
    for (final controller in [name, model, sku, purchase, selling, mrp, quantity, minimum]) {
      controller.dispose();
    }
    super.dispose();
  }

  Future<void> searchInternet(String value) async {
    if (value.trim().length < 2) {
      setState(() => suggestions = []);
      return;
    }
    setState(() => searching = true);
    final result = await ProductCatalogService.suggest(
      query: value,
      brand: brand,
      category: category,
    );
    if (mounted) {
      setState(() {
        suggestions = result;
        searching = false;
      });
    }
  }

  void choose(ProductSuggestion suggestion) {
    name.text = suggestion.title;
    model.text = suggestion.title;
    imageUrl = suggestion.imageUrl;
    setState(() => suggestions = []);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Add product', style: TextStyle(fontWeight: FontWeight.w900)),
          SizedBox(height: 3),
          Text('Choose type + brand, then search for the model.', style: TextStyle(color: muted, fontSize: 12)),
        ],
      ),
      content: SizedBox(
        width: 650,
        child: Form(
          key: formKey,
          child: SingleChildScrollView(
            child: Column(children: [
              Row(children: [
                Expanded(child: dropdown('Product type', category, categories, (v) => setState(() => category = v!))),
                const SizedBox(width: 10),
                Expanded(child: dropdown('Brand', brand, brands, (v) => setState(() => brand = v!))),
              ]),
              const SizedBox(height: 10),
              TextFormField(
                controller: name,
                onChanged: searchInternet,
                validator: (value) => value == null || value.trim().isEmpty ? 'Enter a model' : null,
                decoration: const InputDecoration(
                  labelText: 'Product / model name',
                  hintText: 'e.g. Galaxy S25 Ultra',
                  prefixIcon: Icon(Icons.auto_awesome_rounded),
                ),
              ),
              if (searching) const Padding(padding: EdgeInsets.only(top: 8), child: LinearProgressIndicator(minHeight: 2)),
              if (suggestions.isNotEmpty)
                Card(
                  color: const Color(0xFFF8F9FD),
                  child: Column(children: [
                    const ListTile(
                      title: Text('Relevant product suggestions', style: TextStyle(fontWeight: FontWeight.w900)),
                      subtitle: Text('Filtered by brand + category.'),
                    ),
                    for (final suggestion in suggestions.take(5))
                      ListTile(
                        onTap: () => choose(suggestion),
                        leading: SizedBox(
                          width: 50,
                          height: 50,
                          child: suggestion.imageUrl.isEmpty
                              ? const Icon(Icons.devices_other)
                              : Image.network(suggestion.imageUrl, fit: BoxFit.contain, errorBuilder: (_, __, ___) => const Icon(Icons.devices_other)),
                        ),
                        title: Text(suggestion.title, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.w800)),
                        subtitle: Text(suggestion.description, maxLines: 2, overflow: TextOverflow.ellipsis),
                        trailing: const Icon(Icons.add_circle, color: primary),
                      ),
                  ]),
                ),
              Row(children: [
                Expanded(child: field(model, 'Model / variant')),
                const SizedBox(width: 10),
                Expanded(child: field(sku, 'SKU')),
              ]),
              if (imageUrl.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Container(
                    height: 130,
                    width: double.infinity,
                    decoration: BoxDecoration(color: background, borderRadius: BorderRadius.circular(16)),
                    child: Image.network(imageUrl, fit: BoxFit.contain, errorBuilder: (_, __, ___) => const Icon(Icons.image_not_supported_outlined)),
                  ),
                ),
              Row(children: [
                Expanded(child: field(purchase, 'Purchase price', number: true)),
                const SizedBox(width: 10),
                Expanded(child: field(selling, 'Selling price', number: true)),
              ]),
              Row(children: [
                Expanded(child: field(mrp, 'MRP', number: true)),
                const SizedBox(width: 8),
                Expanded(child: field(quantity, 'Opening stock', number: true)),
                const SizedBox(width: 8),
                Expanded(child: field(minimum, 'Min. stock', number: true)),
              ]),
            ]),
          ),
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
        FilledButton.icon(
          onPressed: () {
            if (!formKey.currentState!.validate()) return;
            Navigator.pop(
              context,
              ProductDraft(
                name: name.text.trim(),
                brand: brand,
                category: category,
                model: model.text.trim(),
                sku: sku.text.trim(),
                imageUrl: imageUrl,
                purchase: double.tryParse(purchase.text) ?? 0,
                selling: double.tryParse(selling.text) ?? 0,
                mrp: double.tryParse(mrp.text) ?? 0,
                quantity: int.tryParse(quantity.text) ?? 0,
                minimum: int.tryParse(minimum.text) ?? 2,
              ),
            );
          },
          icon: const Icon(Icons.check),
          label: const Text('Save product'),
        ),
      ],
    );
  }

  Widget dropdown(String label, String value, List<String> values, ValueChanged<String?> onChanged) =>
      DropdownButtonFormField<String>(
        initialValue: value,
        isExpanded: true,
        decoration: InputDecoration(labelText: label),
        items: [for (final item in values) DropdownMenuItem(value: item, child: Text(item, overflow: TextOverflow.ellipsis))],
        onChanged: onChanged,
      );

  Widget field(TextEditingController controller, String label, {bool number = false}) => Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: TextFormField(
          controller: controller,
          keyboardType: number ? const TextInputType.numberWithOptions(decimal: true) : null,
          validator: (value) => value == null || value.trim().isEmpty ? 'Required' : null,
          decoration: InputDecoration(labelText: label),
        ),
      );
}

class SalesPage extends StatefulWidget {
  const SalesPage({super.key});
  @override
  State<SalesPage> createState() => _SalesPageState();
}

class CartLine {
  final Product product;
  int quantity;
  CartLine(this.product, this.quantity);
}

class _SalesPageState extends State<SalesPage> {
  List<Product> products = [];
  String query = '';
  final List<CartLine> cart = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    load();
  }

  Future<void> load() async {
    try {
      final result = await AppDatabase.instance.products(query: query);
      if (mounted) setState(() { products = result; loading = false; });
    } catch (_) {
      if (mounted) setState(() => loading = false);
    }
  }

  CartLine? lineFor(Product product) {
    for (final line in cart) {
      if (line.product.id == product.id) return line;
    }
    return null;
  }

  double get total => cart.fold(0, (sum, line) => sum + line.product.sellingPrice * line.quantity);

  void add(Product product) {
    if (product.quantity <= 0) return;
    final line = lineFor(product);
    if (line == null) {
      setState(() => cart.add(CartLine(product, 1)));
    } else if (line.quantity < product.quantity) {
      setState(() => line.quantity++);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Only ${product.quantity} available')));
    }
  }

  void remove(Product product) {
    final line = lineFor(product);
    if (line == null) return;
    setState(() {
      if (line.quantity <= 1) cart.remove(line);
      else line.quantity--;
    });
  }

  @override
  Widget build(BuildContext context) {
    final wide = MediaQuery.sizeOf(context).width >= 980;
    return PageFrame(
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const PageHeader(title: 'New sale', subtitle: 'Find product → cart → payment → invoice'),
        const SizedBox(height: 15),
        SearchField(
          hint: 'Search product, brand, model or SKU',
          onChanged: (value) { query = value; load(); },
          onScan: () => scan(context),
        ),
        const SizedBox(height: 12),
        Expanded(
          child: wide
              ? Row(children: [Expanded(child: productGrid()), const SizedBox(width: 14), SizedBox(width: 350, child: cartPanel())])
              : Column(children: [Expanded(child: productGrid()), const SizedBox(height: 9), cartButton(context)]),
        ),
      ]),
    );
  }

  Widget productGrid() {
    if (loading) return const Center(child: CircularProgressIndicator());
    if (products.isEmpty) return const EmptyCard('No sellable products', 'Add products with stock to start.', Icons.point_of_sale_rounded);
    return LayoutBuilder(builder: (_, constraints) {
      final columns = constraints.maxWidth > 1150 ? 4 : constraints.maxWidth > 720 ? 3 : 2;
      return GridView.builder(
        itemCount: products.length,
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: columns, crossAxisSpacing: 12, mainAxisSpacing: 12, childAspectRatio: .72),
        itemBuilder: (_, i) {
          final product = products[i];
          final line = lineFor(product);
          return Card(
            child: Padding(
              padding: const EdgeInsets.all(9),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Expanded(child: ProductImage(product: product, size: 170)),
                Text(product.brand, style: const TextStyle(color: muted, fontSize: 10)),
                Text(product.name, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.w900)),
                Row(children: [
                  Expanded(child: Text(money(product.sellingPrice), style: const TextStyle(fontWeight: FontWeight.w900))),
                  if (product.quantity == 0)
                    const StatusBadge('OUT OF STOCK')
                  else if (line == null)
                    IconButton(onPressed: () => add(product), icon: const Icon(Icons.add_circle, color: primary, size: 34))
                  else
                    Row(mainAxisSize: MainAxisSize.min, children: [
                      IconButton(onPressed: () => remove(product), icon: const Icon(Icons.remove_circle_outline)),
                      Text('${line.quantity}', style: const TextStyle(fontWeight: FontWeight.w900)),
                      IconButton(onPressed: () => add(product), icon: const Icon(Icons.add_circle, color: primary)),
                    ]),
                ]),
              ]),
            ),
          );
        },
      );
    });
  }

  Widget cartButton(BuildContext context) => SizedBox(
        height: 52,
        width: MediaQuery.sizeOf(context).width > 450 ? 290 : double.infinity,
        child: FilledButton.icon(
          onPressed: cart.isEmpty
              ? null
              : () => showModalBottomSheet<void>(
                    context: context,
                    isScrollControlled: true,
                    showDragHandle: true,
                    builder: (_) => SizedBox(
                      height: MediaQuery.sizeOf(context).height * .72,
                      child: Padding(padding: const EdgeInsets.all(15), child: cartPanel()),
                    ),
                  ),
          icon: const Icon(Icons.shopping_bag_rounded),
          label: Text(cart.isEmpty ? 'Cart · ₹0' : 'View cart · ${money(total)}'),
        ),
      );

  Widget cartPanel() => Card(
        child: Padding(
          padding: const EdgeInsets.all(15),
          child: Column(children: [
            Row(children: [
              const Expanded(child: Text('Current order', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900))),
              Text('${cart.fold<int>(0, (sum, line) => sum + line.quantity)} items', style: const TextStyle(color: muted)),
            ]),
            const SizedBox(height: 8),
            Expanded(
              child: cart.isEmpty
                  ? const EmptyCard('Cart is empty', 'Tap + to add a product.', Icons.shopping_bag_outlined)
                  : ListView.separated(
                      itemCount: cart.length,
                      separatorBuilder: (_, __) => const Divider(height: 1),
                      itemBuilder: (_, i) {
                        final line = cart[i];
                        return ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: ProductImage(product: line.product, size: 45),
                          title: Text(line.product.name, maxLines: 1, overflow: TextOverflow.ellipsis),
                          subtitle: Text('${money(line.product.sellingPrice)} each'),
                          trailing: Row(mainAxisSize: MainAxisSize.min, children: [
                            IconButton(onPressed: () => remove(line.product), icon: const Icon(Icons.remove_circle_outline)),
                            Text('${line.quantity}'),
                            IconButton(onPressed: () => add(line.product), icon: const Icon(Icons.add_circle, color: primary)),
                          ]),
                        );
                      },
                    ),
            ),
            const Divider(),
            Row(children: [const Expanded(child: Text('Total', style: TextStyle(color: muted))), Text(money(total), style: const TextStyle(fontSize: 21, fontWeight: FontWeight.w900))]),
            const SizedBox(height: 8),
            Row(children: [
              Expanded(child: OutlinedButton(onPressed: cart.isEmpty ? null : () => setState(cart.clear), child: const Text('Clear cart'))),
              const SizedBox(width: 8),
              Expanded(child: FilledButton(onPressed: cart.isEmpty ? null : () => checkout(context), child: const Text('Checkout'))),
            ]),
          ]),
        ),
      );

  Future<void> scan(BuildContext context) async {
    final controller = TextEditingController();
    final value = await showDialog<String>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Find by barcode / SKU'),
        content: TextField(controller: controller, autofocus: true),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          FilledButton(onPressed: () => Navigator.pop(context, controller.text.trim()), child: const Text('Find')),
        ],
      ),
    );
    controller.dispose();
    if (value != null && value.isNotEmpty) { query = value; load(); }
  }

  Future<void> checkout(BuildContext context) async {
    final customer = TextEditingController(text: 'Walk-in Customer');
    String payment = 'Cash';
    final result = await showDialog<bool>(
      context: context,
      builder: (_) => StatefulBuilder(builder: (dialogContext, setDialog) => AlertDialog(
        title: const Text('Checkout', style: TextStyle(fontWeight: FontWeight.w900)),
        content: Column(mainAxisSize: MainAxisSize.min, children: [
          Text(money(total), style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900)),
          TextField(controller: customer, decoration: const InputDecoration(labelText: 'Customer')),
          DropdownButtonFormField<String>(
            initialValue: payment,
            decoration: const InputDecoration(labelText: 'Payment method'),
            items: const [
              DropdownMenuItem(value: 'Cash', child: Text('Cash')),
              DropdownMenuItem(value: 'UPI', child: Text('UPI')),
              DropdownMenuItem(value: 'Card', child: Text('Card')),
              DropdownMenuItem(value: 'Bank transfer', child: Text('Bank transfer')),
              DropdownMenuItem(value: 'Credit / Due', child: Text('Credit / Due')),
            ],
            onChanged: (value) => setDialog(() => payment = value!),
          ),
        ]),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dialogContext, false), child: const Text('Cancel')),
          FilledButton(onPressed: () => Navigator.pop(dialogContext, true), child: const Text('Complete sale')),
        ],
      )),
    );

    if (result != true) { customer.dispose(); return; }
    try {
      final items = cart.map((line) => <String, Object?>{
            'product_id': line.product.id!,
            'quantity': line.quantity,
            'price': line.product.sellingPrice,
            'name': line.product.name,
          }).toList();
      await AppDatabase.instance.sellCart(
        items,
        customer: customer.text.trim().isEmpty ? 'Walk-in Customer' : customer.text.trim(),
        payment: payment,
      );
      if (!mounted) return;
      setState(cart.clear);
      await load();
      if (context.mounted) {
        await showDialog<void>(
          context: context,
          builder: (_) => AlertDialog(
            title: const Text('✓ Sale completed'),
            content: Text('Total ${money(total)}\nPaid via $payment\nInventory updated automatically.'),
            actions: [FilledButton(onPressed: () => Navigator.pop(context), child: const Text('New sale'))],
          ),
        );
      }
    } catch (error) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$error')));
    } finally {
      customer.dispose();
    }
  }
}

class PurchasesPage extends StatefulWidget {
  const PurchasesPage({super.key});
  @override
  State<PurchasesPage> createState() => _PurchasesPageState();
}

class _PurchasesPageState extends State<PurchasesPage> {
  List<Map<String, Object?>> rows = [];

  @override
  void initState() { super.initState(); load(); }

  Future<void> load() async {
    final result = await AppDatabase.instance.purchases();
    if (mounted) setState(() => rows = result);
  }

  @override
  Widget build(BuildContext context) => PageFrame(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          PageHeader(
            title: 'Purchases',
            subtitle: 'Receive stock and manage supplier invoices.',
            action: FilledButton.icon(onPressed: () => newPurchase(context), icon: const Icon(Icons.add), label: const Text('New purchase')),
          ),
          const SizedBox(height: 15),
          Expanded(
            child: rows.isEmpty
                ? const EmptyCard('No purchases yet', 'Receive your first supplier order.', Icons.shopping_bag_outlined)
                : ListView.separated(
                    itemCount: rows.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 8),
                    itemBuilder: (_, i) {
                      final row = rows[i];
                      return Card(child: ListTile(
                        title: Text(row['invoice']?.toString() ?? 'Purchase', style: const TextStyle(fontWeight: FontWeight.w900)),
                        subtitle: Text('${row['supplier'] ?? 'Supplier'} • ${row['date'] ?? ''}'),
                        trailing: Text(money((row['total'] as num?) ?? 0), style: const TextStyle(fontWeight: FontWeight.w900)),
                      ));
                    },
                  ),
          ),
        ]),
      );

  Future<void> newPurchase(BuildContext context) async {
    final products = await AppDatabase.instance.products();
    if (products.isEmpty) return;
    Product selected = products.first;
    final supplier = TextEditingController();
    final quantity = TextEditingController(text: '1');
    final price = TextEditingController();

    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => StatefulBuilder(builder: (dialogContext, setDialog) => AlertDialog(
        title: const Text('New purchase'),
        content: Column(mainAxisSize: MainAxisSize.min, children: [
          TextField(controller: supplier, decoration: const InputDecoration(labelText: 'Supplier')),
          DropdownButtonFormField<Product>(
            initialValue: selected,
            isExpanded: true,
            decoration: const InputDecoration(labelText: 'Product'),
            items: [for (final p in products) DropdownMenuItem(value: p, child: Text('${p.brand} ${p.name}', overflow: TextOverflow.ellipsis))],
            onChanged: (value) => setDialog(() => selected = value!),
          ),
          TextField(controller: quantity, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Quantity')),
          TextField(controller: price, keyboardType: const TextInputType.numberWithOptions(decimal: true), decoration: const InputDecoration(labelText: 'Cost per unit')),
        ]),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dialogContext, false), child: const Text('Cancel')),
          FilledButton(onPressed: () => Navigator.pop(dialogContext, true), child: const Text('Receive stock')),
        ],
      )),
    );

    if (ok == true) {
      final q = int.tryParse(quantity.text) ?? 0;
      final cost = double.tryParse(price.text) ?? selected.purchasePrice;
      await AppDatabase.instance.purchase(
        supplier: supplier.text.trim().isEmpty ? 'Supplier' : supplier.text.trim(),
        invoice: 'PO-${DateTime.now().millisecondsSinceEpoch % 100000}',
        items: [{'product_id': selected.id!, 'quantity': q, 'price': cost}],
        payment: 'Cash',
        paid: cost * q,
      );
      await load();
    }
    supplier.dispose();
    quantity.dispose();
    price.dispose();
  }
}

class MorePage extends StatelessWidget {
  const MorePage({super.key});

  @override
  Widget build(BuildContext context) => PageFrame(
        child: ListView(children: [
          const PageHeader(title: 'More', subtitle: 'Customers, suppliers, expenses, reports and settings.'),
          const SizedBox(height: 16),
          ToolTile('Customers', 'Customer profiles and balances', Icons.people_alt_outlined, primary, () => openList(context, 'Customers', 'customers', Icons.people_alt_outlined)),
          ToolTile('Suppliers', 'Supplier records and purchase history', Icons.local_shipping_outlined, purple, () => openList(context, 'Suppliers', 'suppliers', Icons.local_shipping_outlined)),
          ToolTile('Expenses', 'Track shop operating costs', Icons.receipt_long_outlined, orange, () => addExpense(context)),
          ToolTile('Reports & analytics', 'Sales, profit, expenses and stock', Icons.bar_chart_rounded, green, () => showReport(context)),
          ToolTile('Backup & Restore', 'Inspect local shop data', Icons.backup_rounded, const Color(0xFF3D7DD8), () => showBackup(context)),
          ToolTile('Settings', 'Shop profile and preferences', Icons.settings_outlined, muted, () => showSettings(context)),
        ]),
      );
}

class ToolTile extends StatelessWidget {
  final String title, subtitle;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
  const ToolTile(this.title, this.subtitle, this.icon, this.color, this.onTap, {super.key});

  @override
  Widget build(BuildContext context) => Card(
        margin: const EdgeInsets.only(bottom: 9),
        child: ListTile(
          onTap: onTap,
          leading: Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(color: color.withAlpha(17), borderRadius: BorderRadius.circular(13)),
            child: Icon(icon, color: color),
          ),
          title: Text(title, style: const TextStyle(fontWeight: FontWeight.w800)),
          subtitle: Text(subtitle, style: const TextStyle(color: muted, fontSize: 11)),
          trailing: const Icon(Icons.chevron_right_rounded, color: muted),
        ),
      );
}

Future<void> openList(BuildContext context, String title, String table, IconData icon) async {
  final rows = await AppDatabase.instance.db.then((db) => db.query(table, limit: 100));
  if (!context.mounted) return;
  await Navigator.push(context, MaterialPageRoute(builder: (_) => SimpleListPage(title: title, icon: icon, rows: rows)));
}

class SimpleListPage extends StatelessWidget {
  final String title;
  final IconData icon;
  final List<Map<String, Object?>> rows;
  const SimpleListPage({super.key, required this.title, required this.icon, required this.rows});

  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: background,
        appBar: AppBar(backgroundColor: background, title: Text(title, style: const TextStyle(fontWeight: FontWeight.w900))),
        body: ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: rows.length,
          itemBuilder: (_, i) {
            final values = rows[i].values.where((value) => value != null && value.toString().isNotEmpty).take(4).map((value) => value.toString()).toList();
            return Card(
              margin: const EdgeInsets.only(bottom: 8),
              child: ListTile(
                leading: CircleAvatar(backgroundColor: primary.withAlpha(18), child: Icon(icon, color: primary)),
                title: Text(values.isEmpty ? 'Record' : values.first, style: const TextStyle(fontWeight: FontWeight.w800)),
                subtitle: Text(values.skip(1).join(' • ')),
              ),
            );
          },
        ),
      );
}

Future<void> addExpense(BuildContext context) async {
  final category = TextEditingController(text: 'Other');
  final amount = TextEditingController();
  final note = TextEditingController();
  final ok = await showDialog<bool>(
    context: context,
    builder: (_) => AlertDialog(
      title: const Text('Add expense'),
      content: Column(mainAxisSize: MainAxisSize.min, children: [
        TextField(controller: category, decoration: const InputDecoration(labelText: 'Category')),
        TextField(controller: amount, keyboardType: const TextInputType.numberWithOptions(decimal: true), decoration: const InputDecoration(labelText: 'Amount')),
        TextField(controller: note, decoration: const InputDecoration(labelText: 'Notes')),
      ]),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
        FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('Save')),
      ],
    ),
  );
  if (ok == true) {
    await AppDatabase.instance.addExpense(category.text, double.tryParse(amount.text) ?? 0, 'Cash', note.text);
  }
  category.dispose(); amount.dispose(); note.dispose();
}

Future<void> showReport(BuildContext context) async {
  final data = await AppDatabase.instance.monthly();
  if (!context.mounted) return;
  await showModalBottomSheet<void>(
    context: context,
    showDragHandle: true,
    builder: (_) => Padding(
      padding: const EdgeInsets.all(20),
      child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('This month', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900)),
        for (final entry in <String, num>{
          'Sales': data['sales'] ?? 0,
          'COGS': data['cogs'] ?? 0,
          'Gross profit': data['gross'] ?? 0,
          'Expenses': data['expenses'] ?? 0,
          'Net profit': data['net'] ?? 0,
          'Inventory': data['inventory'] ?? 0,
        }.entries)
          Padding(padding: const EdgeInsets.symmetric(vertical: 6), child: Row(children: [Expanded(child: Text(entry.key, style: const TextStyle(color: muted))), Text(money(entry.value), style: const TextStyle(fontWeight: FontWeight.w900))])),
      ],
    ),
  );
}

Future<void> showBackup(BuildContext context) async {
  final db = await AppDatabase.instance.db;
  final count = Sqflite.firstIntValue(await db.rawQuery('SELECT COUNT(*) FROM products')) ?? 0;
  if (!context.mounted) return;
  await showDialog<void>(
    context: context,
    builder: (_) => AlertDialog(
      title: const Text('Backup & Restore'),
      content: Text('$count products are stored locally. The live database is available on this device.'),
      actions: [FilledButton(onPressed: () => Navigator.pop(context), child: const Text('Close'))],
    ),
  );
}

Future<void> showSettings(BuildContext context) async {
  final db = await AppDatabase.instance.db;
  final rows = await db.query('settings', where: 'key=?', whereArgs: ['shop_name'], limit: 1);
  final controller = TextEditingController(text: rows.isEmpty ? 'ElectroMart' : rows.first['value']?.toString() ?? 'ElectroMart');
  if (!context.mounted) return;
  await showDialog<void>(
    context: context,
    builder: (_) => AlertDialog(
      title: const Text('Settings'),
      content: TextField(controller: controller, decoration: const InputDecoration(labelText: 'Shop name')),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
        FilledButton(
          onPressed: () async {
            await db.insert('settings', {'key': 'shop_name', 'value': controller.text.trim()}, conflictAlgorithm: ConflictAlgorithm.replace);
            if (context.mounted) Navigator.pop(context);
          },
          child: const Text('Save'),
        ),
      ],
    ),
  );
  controller.dispose();
}

IconData categoryIcon(String category) {
  switch (category) {
    case 'Mobile Phones': return Icons.phone_android_rounded;
    case 'Laptops': return Icons.laptop_mac_rounded;
    case 'Televisions': return Icons.tv_rounded;
    case 'Refrigerators': return Icons.kitchen_rounded;
    case 'Audio': return Icons.headphones_rounded;
    case 'Cameras': return Icons.photo_camera_rounded;
    case 'Printers': return Icons.print_rounded;
    case 'Storage': return Icons.storage_rounded;
    default: return Icons.devices_other_rounded;
  }
}
