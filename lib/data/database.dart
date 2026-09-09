import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import '../models/models.dart';

class AppDatabase {
  static final AppDatabase instance = AppDatabase._();
  AppDatabase._();
  Database? _db;

  Future<Database> get db async => _db ??= await _open();
  String now() => DateTime.now().toIso8601String();

  Future<Database> _open() async {
    final database = await openDatabase(
      join(await getDatabasesPath(), 'inventory_shop.db'),
      version: 3,
      onCreate: (db, _) async => _createSchema(db),
      onUpgrade: (db, old, _) async {
        if (old < 3) await _createExtraTables(db);
      },
    );
    final count = Sqflite.firstIntValue(await database.rawQuery('SELECT COUNT(*) FROM products')) ?? 0;
    if (count == 0) await _seed(database);
    return database;
  }

  Future<void> _createSchema(Database db) async {
    await db.execute('CREATE TABLE IF NOT EXISTS products(id INTEGER PRIMARY KEY AUTOINCREMENT,name TEXT NOT NULL,brand TEXT NOT NULL,category TEXT NOT NULL,subcategory TEXT,model TEXT,sku TEXT UNIQUE,barcode TEXT UNIQUE,image_url TEXT,mrp REAL NOT NULL,selling_price REAL NOT NULL,purchase_price REAL NOT NULL,quantity INTEGER NOT NULL DEFAULT 0,reserved_quantity INTEGER NOT NULL DEFAULT 0,minimum_stock INTEGER NOT NULL DEFAULT 2,supplier TEXT,warranty TEXT,warranty_start TEXT,gst_rate REAL DEFAULT 18,hsn_code TEXT,location TEXT,rack TEXT,shelf TEXT,serial_tracking INTEGER DEFAULT 0,imei_tracking INTEGER DEFAULT 0,specs TEXT,notes TEXT,archived INTEGER DEFAULT 0,created_at TEXT,updated_at TEXT)');
    await _createExtraTables(db);
  }

  Future<void> _createExtraTables(Database db) async {
    final tables = <String>[
      'CREATE TABLE IF NOT EXISTS categories(id INTEGER PRIMARY KEY AUTOINCREMENT,name TEXT UNIQUE,image TEXT)',
      'CREATE TABLE IF NOT EXISTS brands(id INTEGER PRIMARY KEY AUTOINCREMENT,name TEXT UNIQUE,logo_url TEXT)',
      'CREATE TABLE IF NOT EXISTS suppliers(id INTEGER PRIMARY KEY AUTOINCREMENT,name TEXT,phone TEXT,email TEXT,address TEXT,gstin TEXT)',
      'CREATE TABLE IF NOT EXISTS customers(id INTEGER PRIMARY KEY AUTOINCREMENT,name TEXT,phone TEXT,email TEXT,address TEXT,gstin TEXT)',
      'CREATE TABLE IF NOT EXISTS locations(id INTEGER PRIMARY KEY AUTOINCREMENT,name TEXT UNIQUE)',
      'CREATE TABLE IF NOT EXISTS stock_movements(id INTEGER PRIMARY KEY AUTOINCREMENT,product_id INTEGER,quantity INTEGER,type TEXT,reference_id TEXT,date TEXT,user TEXT,note TEXT,cost REAL)',
      'CREATE TABLE IF NOT EXISTS sales(id INTEGER PRIMARY KEY AUTOINCREMENT,customer_id INTEGER,customer TEXT,date TEXT,subtotal REAL,discount REAL,gst REAL,total REAL,payment TEXT,paid REAL,remaining REAL)',
      'CREATE TABLE IF NOT EXISTS sale_items(id INTEGER PRIMARY KEY AUTOINCREMENT,sale_id INTEGER,product_id INTEGER,quantity INTEGER,price REAL,cost REAL)',
      'CREATE TABLE IF NOT EXISTS purchases(id INTEGER PRIMARY KEY AUTOINCREMENT,supplier_id INTEGER,supplier TEXT,invoice TEXT,date TEXT,subtotal REAL,discount REAL,gst REAL,total REAL,payment TEXT,paid REAL,remaining REAL)',
      'CREATE TABLE IF NOT EXISTS purchase_items(id INTEGER PRIMARY KEY AUTOINCREMENT,purchase_id INTEGER,product_id INTEGER,quantity INTEGER,price REAL)',
      'CREATE TABLE IF NOT EXISTS expenses(id INTEGER PRIMARY KEY AUTOINCREMENT,category TEXT,amount REAL,date TEXT,payment TEXT,note TEXT)',
      'CREATE TABLE IF NOT EXISTS warranties(id INTEGER PRIMARY KEY AUTOINCREMENT,product_id INTEGER,serial TEXT,customer TEXT,purchase_date TEXT,expiry_date TEXT,status TEXT)',
      'CREATE TABLE IF NOT EXISTS serial_numbers(id INTEGER PRIMARY KEY AUTOINCREMENT,product_id INTEGER,serial TEXT UNIQUE,status TEXT,sale_id INTEGER)',
      'CREATE TABLE IF NOT EXISTS imeis(id INTEGER PRIMARY KEY AUTOINCREMENT,product_id INTEGER,imei TEXT UNIQUE,status TEXT,sale_id INTEGER)',
      'CREATE TABLE IF NOT EXISTS settings(key TEXT PRIMARY KEY,value TEXT)',
      'CREATE TABLE IF NOT EXISTS users(id INTEGER PRIMARY KEY AUTOINCREMENT,name TEXT,role TEXT,active INTEGER DEFAULT 1)',
      'CREATE TABLE IF NOT EXISTS audit_logs(id INTEGER PRIMARY KEY AUTOINCREMENT,user TEXT,action TEXT,entity TEXT,entity_id INTEGER,date TEXT,details TEXT)',
    ];
    for (final sql in tables) {
      await db.execute(sql);
    }
    await db.execute('CREATE INDEX IF NOT EXISTS idx_products_search ON products(name,brand,sku,barcode,model)');
    await db.execute('CREATE INDEX IF NOT EXISTS idx_movements_product ON stock_movements(product_id,date)');
    await db.execute('CREATE INDEX IF NOT EXISTS idx_sales_date ON sales(date)');
    await db.execute('CREATE INDEX IF NOT EXISTS idx_purchases_date ON purchases(date)');
  }

  Future<void> _seed(Database db) async {
    final categories = ['Mobile Phones','Laptops','Televisions','Refrigerators','Air Conditioners','Washing Machines','Audio','Cameras','Printers','Networking','Storage','Accessories','Monitors','Gaming','Smartwatches','Kitchen Appliances','Fans','Coolers','Projectors','Power & Cables'];
    final brands = ['Samsung','LG','Sony','Apple','OnePlus','Motorola','Xiaomi','HP','Dell','Lenovo','ASUS','Acer','MSI','Whirlpool','IFB','Bosch','Haier','Voltas','Daikin','Blue Star','JBL','boAt','Bose','Canon','Nikon','Epson','TP-Link','D-Link','Tenda','Logitech','Razer','Kingston','SanDisk','Seagate','Western Digital','Philips','Havells','Bajaj','Crompton','Oppo','Realme'];
    for (final name in categories) await db.insert('categories', {'name': name});
    for (final name in brands) await db.insert('brands', {'name': name});
    for (final name in ['Main Store','Warehouse']) await db.insert('locations', {'name': name});
    for (var i = 1; i <= 20; i++) {
      await db.insert('suppliers', {'name': 'Supplier $i', 'phone': '98${i.toString().padLeft(8, '0')}', 'email': 'supplier$i@example.com', 'address': 'New Delhi, India'});
    }
    for (var i = 1; i <= 100; i++) {
      await db.insert('customers', {'name': i % 7 == 0 ? 'Walk-in Customer' : 'Customer ${i.toString().padLeft(3, '0')}', 'phone': '9${i.toString().padLeft(9, '0')}', 'email': 'customer$i@example.com', 'address': 'Delhi, India'});
    }
    final data = <List<Object>>[
      ['Galaxy S25','Samsung','Mobile Phones','SM-S931',74999,62900,79999], ['Galaxy A56','Samsung','Mobile Phones','SM-A566',41999,34500,45999], ['iPhone 16','Apple','Mobile Phones','A3281',79900,67500,84900], ['OnePlus 13','OnePlus','Mobile Phones','CPH2653',69999,59000,74999], ['Edge 60 Fusion','Motorola','Mobile Phones','XT2503',22999,18800,24999], ['Redmi Note 14','Xiaomi','Mobile Phones','RN14',17999,14500,19999],
      ['Pavilion 15','HP','Laptops','15-eg3050',69999,58500,74999], ['Inspiron 15','Dell','Laptops','3530',58999,49000,62999], ['IdeaPad Slim 5','Lenovo','Laptops','83ER',64999,53500,69999], ['Vivobook 15','ASUS','Laptops','X1504',55999,46800,59999], ['Aspire 5','Acer','Laptops','A515',51999,43500,56999],
      ['55 Crystal UHD Smart TV','Samsung','Televisions','UA55U8000',49999,41500,54999], ['65 Neo QLED','Samsung','Televisions','QA65QN90',139999,117000,154999], ['55 UHD Smart TV','LG','Televisions','55UR7500',52999,44000,57999], ['55 BRAVIA','Sony','Televisions','K-55S30',69999,58500,74999], ['43 Smart TV','TCL','Televisions','43P655',29999,24800,32999],
      ['260L Frost Free','LG','Refrigerators','GL-S292',32999,27500,36999], ['253L Double Door','Samsung','Refrigerators','RT30',30999,25900,34999], ['265L 3 Star','Whirlpool','Refrigerators','IF305',28999,24000,31999],
      ['Tune 770NC','JBL','Audio','JBL770',6999,5100,7999], ['Charge 5','JBL','Audio','CHARGE5',12999,10100,14999], ['WH-CH720N','Sony','Audio','WHCH720',9999,7600,11999], ['Rockerz 450','boAt','Audio','A450',1499,900,1999],
      ['EOS R50','Canon','Cameras','R50',74999,63000,79999], ['Z30','Nikon','Cameras','Z30',69999,59000,74999], ['EcoTank L3250','Epson','Printers','L3250',15999,12800,17999], ['LaserJet 1188','HP','Printers','1188',13999,11200,15999], ['Archer C6','TP-Link','Networking','C6',2499,1800,2999], ['AX1500 Router','D-Link','Networking','R15',3499,2600,3999], ['1TB SSD','Samsung','Storage','870EVO',7999,6500,8999], ['1TB Portable SSD','SanDisk','Storage','SDSSDE',8999,7200,9999], ['2TB HDD','Seagate','Storage','ST2000',5999,4500,6999],
    ];
    for (var i = 0; i < data.length; i++) {
      final e = data[i];
      final quantity = (i % 11) + 1;
      final id = await db.insert('products', {'name': e[0], 'brand': e[1], 'category': e[2], 'model': e[3], 'sku': 'DEMO-${(i + 1).toString().padLeft(4, '0')}', 'barcode': '890100${i.toString().padLeft(5, '0')}', 'mrp': e[6], 'selling_price': e[4], 'purchase_price': e[5], 'quantity': quantity, 'minimum_stock': (i % 4) + 2, 'supplier': 'Supplier ${(i % 20) + 1}', 'warranty': '1 Year', 'gst_rate': 18, 'hsn_code': '8517', 'location': 'Main Store', 'rack': 'Rack ${(i % 5) + 1}', 'shelf': 'Shelf ${(i % 4) + 1}', 'serial_tracking': e[2] == 'Laptops' ? 1 : 0, 'imei_tracking': e[2] == 'Mobile Phones' ? 1 : 0, 'specs': 'Model: ${e[3]}', 'created_at': now(), 'updated_at': now()});
      await db.insert('stock_movements', {'product_id': id, 'quantity': quantity, 'type': 'OPENING_STOCK', 'date': now(), 'user': 'Demo', 'note': 'Demo opening stock', 'cost': e[5]});
    }
    final products = await db.query('products', limit: 40);
    for (var month = 0; month < 6; month++) {
      for (var j = 0; j < Math.min(8, products.length); j++) {
        final p = products[j];
        final price = (p['selling_price'] as num).toDouble();
        final cost = (p['purchase_price'] as num).toDouble();
        final date = DateTime.now().subtract(Duration(days: month * 30 + j + 5)).toIso8601String();
        final sale = await db.insert('sales', {'customer': 'Customer ${month * 8 + j + 1}', 'date': date, 'subtotal': price, 'discount': 0, 'gst': 0, 'total': price, 'payment': j % 3 == 0 ? 'UPI' : 'Cash', 'paid': price, 'remaining': 0});
        await db.insert('sale_items', {'sale_id': sale, 'product_id': p['id'], 'quantity': 1, 'price': price, 'cost': cost});
        await db.insert('stock_movements', {'product_id': p['id'], 'quantity': -1, 'type': 'SALE', 'reference_id': '$sale', 'date': date, 'user': 'Demo', 'note': 'Demo sale', 'cost': cost});
      }
    }
    await db.insert('expenses', {'category': 'Rent', 'amount': 45000, 'date': now(), 'payment': 'Bank Transfer', 'note': 'Demo monthly rent'});
    await db.insert('expenses', {'category': 'Electricity', 'amount': 12000, 'date': now(), 'payment': 'UPI', 'note': 'Demo utility'});
  }

  Future<List<Product>> products({String query = '', String? category, String? brand, bool includeArchived = false}) async {
    final d = await db;
    final where = <String>[];
    final args = <Object?>[];
    if (!includeArchived) where.add('archived=0');
    if (query.trim().isNotEmpty) {
      where.add('(name LIKE ? OR brand LIKE ? OR model LIKE ? OR sku LIKE ? OR barcode LIKE ? OR supplier LIKE ?)');
      args.addAll(List.filled(6, '%${query.trim()}%'));
    }
    if (category != null) { where.add('category=?'); args.add(category); }
    if (brand != null) { where.add('brand=?'); args.add(brand); }
    final rows = await d.query('products', where: where.join(' AND '), whereArgs: args, orderBy: 'name', limit: 500);
    return rows.map(Product.fromMap).toList();
  }

  Future<Product?> product(int id) async {
    final d = await db;
    final rows = await d.query('products', where: 'id=?', whereArgs: [id]);
    return rows.isEmpty ? null : Product.fromMap(rows.first);
  }

  Future<void> audit(String action, String entity, {int? id, String details = ''}) async {
    final d = await db;
    await d.insert('audit_logs', {'user': 'Shop Owner', 'action': action, 'entity': entity, 'entity_id': id, 'date': now(), 'details': details});
  }

  Future<void> adjustStock(int? productId, int delta, String type, String reason) async {
    if (productId == null) throw Exception('Product id is required');
    if (delta == 0) return;
    final d = await db;
    final p = await product(productId);
    if (p == null) throw Exception('Product not found');
    await d.transaction((t) async {
      final next = p.quantity + delta;
      if (next < 0) throw Exception('Stock cannot be negative');
      await t.update('products', {'quantity': next, 'updated_at': now()}, where: 'id=?', whereArgs: [productId]);
      await t.insert('stock_movements', {'product_id': productId, 'quantity': delta, 'type': type, 'date': now(), 'user': 'Shop Owner', 'note': reason, 'cost': p.purchasePrice});
    });
    await audit('Stock adjusted', 'Product', id: productId, details: '$delta: $reason');
  }

  Future<void> addProduct(Map<String, Object?> values) async {
    final d = await db;
    await d.transaction((t) async {
      final id = await t.insert('products', {...values, 'created_at': now(), 'updated_at': now()});
      final quantity = (values['quantity'] as int?) ?? 0;
      if (quantity > 0) await t.insert('stock_movements', {'product_id': id, 'quantity': quantity, 'type': 'OPENING_STOCK', 'date': now(), 'user': 'Shop Owner', 'note': 'Opening stock', 'cost': values['purchase_price']});
    });
  }

  Future<void> updateProduct(int id, Map<String, Object?> values) async {
    final d = await db;
    await d.update('products', {...values, 'updated_at': now()}, where: 'id=?', whereArgs: [id]);
    await audit('Product edited', 'Product', id: id);
  }

  Future<void> archive(int id) async {
    final d = await db;
    await d.update('products', {'archived': 1, 'updated_at': now()}, where: 'id=?', whereArgs: [id]);
    await audit('Product archived', 'Product', id: id);
  }

  Future<void> sellCart(List<Map<String, Object?>> cart, {String customer = 'Walk-in Customer', String payment = 'Cash', double discount = 0, double gst = 0}) async {
    if (cart.isEmpty) return;
    final d = await db;
    await d.transaction((t) async {
      double subtotal = 0;
      for (final item in cart) {
        final rows = await t.query('products', where: 'id=?', whereArgs: [item['product_id']]);
        final quantity = item['quantity'] as int;
        if (rows.isEmpty || (rows.first['quantity'] as int) < quantity) throw Exception('Insufficient stock for ${item['name']}');
        subtotal += (item['price'] as num).toDouble() * quantity;
      }
      final total = subtotal - discount + gst;
      final saleId = await t.insert('sales', {'customer': customer, 'date': now(), 'subtotal': subtotal, 'discount': discount, 'gst': gst, 'total': total, 'payment': payment, 'paid': total, 'remaining': 0});
      for (final item in cart) {
        final id = item['product_id'] as int;
        final quantity = item['quantity'] as int;
        final rows = await t.query('products', where: 'id=?', whereArgs: [id]);
        final cost = (rows.first['purchase_price'] as num).toDouble();
        await t.insert('sale_items', {'sale_id': saleId, 'product_id': id, 'quantity': quantity, 'price': item['price'], 'cost': cost});
        await t.update('products', {'quantity': (rows.first['quantity'] as int) - quantity, 'updated_at': now()}, where: 'id=?', whereArgs: [id]);
        await t.insert('stock_movements', {'product_id': id, 'quantity': -quantity, 'type': 'SALE', 'reference_id': '$saleId', 'date': now(), 'user': 'Shop Owner', 'note': 'POS sale', 'cost': cost});
      }
    });
  }

  Future<void> purchase({required String supplier, required String invoice, required List<Map<String, Object?>> items, required String payment, double discount = 0, double gst = 0, double paid = 0}) async {
    final d = await db;
    await d.transaction((t) async {
      double subtotal = 0;
      for (final item in items) subtotal += (item['price'] as num).toDouble() * (item['quantity'] as int);
      final total = subtotal - discount + gst;
      final purchaseId = await t.insert('purchases', {'supplier': supplier, 'invoice': invoice, 'date': now(), 'subtotal': subtotal, 'discount': discount, 'gst': gst, 'total': total, 'payment': payment, 'paid': paid, 'remaining': total - paid});
      for (final item in items) {
        final id = item['product_id'] as int;
        final quantity = item['quantity'] as int;
        await t.insert('purchase_items', {'purchase_id': purchaseId, 'product_id': id, 'quantity': quantity, 'price': item['price']});
        final rows = await t.query('products', where: 'id=?', whereArgs: [id]);
        if (rows.isNotEmpty) await t.update('products', {'quantity': (rows.first['quantity'] as int) + quantity, 'purchase_price': item['price'], 'updated_at': now()}, where: 'id=?', whereArgs: [id]);
        await t.insert('stock_movements', {'product_id': id, 'quantity': quantity, 'type': 'PURCHASE', 'reference_id': '$purchaseId', 'date': now(), 'user': 'Shop Owner', 'note': 'Purchase $invoice', 'cost': item['price']});
      }
    });
  }

  Future<Map<String, num>> snapshot() async {
    final d = await db;
    final ps = await products();
    final s = await d.rawQuery("SELECT COALESCE(SUM(total),0) v FROM sales WHERE date>=date('now')");
    final p = await d.rawQuery("SELECT COALESCE(SUM(total),0) v FROM purchases WHERE date>=date('now')");
    return {'inventory': ps.fold<num>(0, (a, p) => a + p.purchasePrice * p.quantity), 'selling': ps.fold<num>(0, (a, p) => a + p.sellingPrice * p.quantity), 'sales': s.first['v'] as num, 'purchases': p.first['v'] as num, 'low': ps.where((p) => p.quantity <= p.minimumStock).length};
  }

  Future<List<Map<String, Object?>>> movements(int id) async {
    final d = await db;
    return d.rawQuery('SELECT * FROM stock_movements WHERE product_id=? ORDER BY date DESC LIMIT 100', [id]);
  }
  Future<List<Map<String, Object?>>> sales({int limit = 100}) async => (await db).query('sales', orderBy: 'date DESC', limit: limit);
  Future<List<Map<String, Object?>>> purchases({int limit = 100}) async => (await db).query('purchases', orderBy: 'date DESC', limit: limit);
  Future<List<Map<String, Object?>>> expenses() async => (await db).query('expenses', orderBy: 'date DESC');
  Future<void> addExpense(String category, double amount, String payment, String note) async => (await db).insert('expenses', {'category': category, 'amount': amount, 'date': now(), 'payment': payment, 'note': note});
  Future<Map<String, num>> monthly() async {
    final d = await db;
    final s = await d.rawQuery("SELECT COALESCE(SUM(total),0) v FROM sales WHERE date>=date('now','start of month')");
    final p = await d.rawQuery("SELECT COALESCE(SUM(total),0) v FROM purchases WHERE date>=date('now','start of month')");
    final e = await d.rawQuery("SELECT COALESCE(SUM(amount),0) v FROM expenses WHERE date>=date('now','start of month')");
    final ps = await products();
    final c = await d.rawQuery("SELECT COALESCE(SUM(quantity*cost),0) v FROM sale_items si JOIN sales s ON s.id=si.sale_id WHERE s.date>=date('now','start of month')");
    final sales = s.first['v'] as num, purchases = p.first['v'] as num, expenses = e.first['v'] as num, cogs = c.first['v'] as num;
    return {'sales': sales, 'purchases': purchases, 'expenses': expenses, 'cogs': cogs, 'gross': sales - cogs, 'net': sales - cogs - expenses, 'stock': ps.fold<num>(0, (a, x) => a + x.quantity), 'inventory': ps.fold<num>(0, (a, x) => a + x.purchasePrice * x.quantity)};
  }
}
