import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import '../models/models.dart';

class AppDatabase {
  static final AppDatabase instance = AppDatabase._();
  AppDatabase._();
  Database? _db;
  Future<Database> get db async => _db ??= await _open();

  Future<Database> _open() async {
    final database = await openDatabase(join(await getDatabasesPath(), 'inventory_shop.db'), version: 1, onCreate: (db, v) async {
      await db.execute('''CREATE TABLE products(id INTEGER PRIMARY KEY AUTOINCREMENT,name TEXT NOT NULL,brand TEXT NOT NULL,category TEXT NOT NULL,model TEXT,sku TEXT UNIQUE,barcode TEXT UNIQUE,image_url TEXT,mrp REAL NOT NULL,selling_price REAL NOT NULL,purchase_price REAL NOT NULL,quantity INTEGER NOT NULL DEFAULT 0,minimum_stock INTEGER NOT NULL DEFAULT 2,supplier TEXT,warranty TEXT,specs TEXT,created_at TEXT,updated_at TEXT)''');
      await db.execute('CREATE TABLE stock_movements(id INTEGER PRIMARY KEY AUTOINCREMENT,product_id INTEGER,quantity INTEGER,type TEXT,reference_id TEXT,date TEXT,note TEXT,cost REAL)');
      await db.execute('CREATE TABLE sales(id INTEGER PRIMARY KEY AUTOINCREMENT,customer TEXT,date TEXT,total REAL,payment TEXT)');
      await db.execute('CREATE TABLE sale_items(id INTEGER PRIMARY KEY AUTOINCREMENT,sale_id INTEGER,product_id INTEGER,quantity INTEGER,price REAL,cost REAL)');
      await db.execute('CREATE TABLE purchases(id INTEGER PRIMARY KEY AUTOINCREMENT,supplier TEXT,invoice TEXT,date TEXT,total REAL,payment TEXT)');
      await db.execute('CREATE TABLE expenses(id INTEGER PRIMARY KEY AUTOINCREMENT,category TEXT,amount REAL,date TEXT,payment TEXT,note TEXT)');
      await db.execute('CREATE TABLE settings(key TEXT PRIMARY KEY,value TEXT)');
    });
    if ((await database.query('products')).isEmpty) await _seed(database);
    return database;
  }

  Future<void> _seed(Database db) async {
    final brands = ['Samsung','LG','Sony','Apple','OnePlus','Motorola','Xiaomi','HP','Dell','Lenovo','ASUS','Acer','Whirlpool','IFB','Bosch','Haier','Voltas','Daikin','Blue Star','JBL','boAt','Bose','Canon','Nikon','Epson','TP-Link','D-Link','Logitech','Razer','Kingston','SanDisk','Seagate','Philips','Havells','Bajaj','Crompton'];
    final categories = ['Mobile Phones','Laptops','Televisions','Refrigerators','Air Conditioners','Washing Machines','Audio','Cameras','Printers','Networking','Storage','Accessories'];
    final products = <List<Object?>>[];
    final examples = [
      ['Galaxy S25','Samsung','Mobile Phones','SM-S931','74999','62900','79999'],['Galaxy A56','Samsung','Mobile Phones','SM-A566','41999','34500','45999'],['iPhone 16','Apple','Mobile Phones','A3281','79900','67500','84900'],['OnePlus 13','OnePlus','Mobile Phones','CPH2653','69999','59000','74999'],['Edge 60 Fusion','Motorola','Mobile Phones','XT2503','22999','18800','24999'],
      ['55 Crystal UHD Smart TV','Samsung','Televisions','UA55U8000','49999','41500','54999'],['65 Neo QLED','Samsung','Televisions','QA65QN90','139999','117000','154999'],['55 UHD Smart TV','LG','Televisions','55UR7500','52999','44000','57999'],['55 BRAVIA','Sony','Televisions','K-55S30','69999','58500','74999'],['43 Smart TV','TCL','Televisions','43P655','29999','24800','32999'],
      ['260L Frost Free','LG','Refrigerators','GL-S292','32999','27500','36999'],['253L Double Door','Samsung','Refrigerators','RT30','30999','25900','34999'],['265L 3 Star','Whirlpool','Refrigerators','IF305','28999','24000','31999'],
      ['Pavilion 15','HP','Laptops','15-eg3050','69999','58500','74999'],['Inspiron 15','Dell','Laptops','3530','58999','49000','62999'],['IdeaPad Slim 5','Lenovo','Laptops','83ER','64999','53500','69999'],['Vivobook 15','ASUS','Laptops','X1504','55999','46800','59999'],['Aspire 5','Acer','Laptops','A515','51999','43500','56999'],
      ['Tune 770NC','JBL','Audio','JBL770','6999','5100','7999'],['Charge 5','JBL','Audio','CHARGE5','12999','10100','14999'],['Soundbar 2.1','Sony','Audio','HT-S20R','14999','11900','16999'],['Rockerz 450','boAt','Audio','A450','1499','900','1999'],
      ['EOS R50','Canon','Cameras','R50','74999','63000','79999'],['Z30','Nikon','Cameras','Z30','69999','59000','74999'],['EcoTank L3250','Epson','Printers','L3250','15999','12800','17999'],['LaserJet 1188','HP','Printers','1188','13999','11200','15999'],['Archer C6','TP-Link','Networking','C6','2499','1800','2999'],['AX1500 Router','D-Link','Networking','R15','3499','2600','3999'],['1TB SSD','Samsung','Storage','870EVO','7999','6500','8999'],['1TB Portable SSD','SanDisk','Storage','SDSSDE','8999','7200','9999'],['2TB HDD','Seagate','Storage','ST2000','5999','4500','6999']];
    for (var i=0;i<examples.length;i++) { final e=examples[i]; products.add([e[0],e[1],e[2],e[3],'DEMO-${(i+1).toString().padLeft(4,'0')}',e[6],e[4],e[5],(i%9)+1,(i%4)+2,'ABC Electronics','1 Year','Model: ${e[3]}']); }
    for (var i=0;i<products.length;i++) { final p=products[i]; final id=await db.insert('products', {'name':p[0],'brand':p[1],'category':p[2],'model':p[3],'sku':p[4],'barcode':'890100${i.toString().padLeft(5,'0')}','mrp':double.parse(p[5].toString()),'selling_price':double.parse(p[6].toString()),'purchase_price':double.parse(p[7].toString()),'quantity':p[8],'minimum_stock':p[9],'supplier':p[10],'warranty':p[11],'specs':p[12],'created_at':DateTime.now().toIso8601String(),'updated_at':DateTime.now().toIso8601String()}); await db.insert('stock_movements', {'product_id':id,'quantity':p[8],'type':'OPENING_STOCK','date':DateTime.now().toIso8601String(),'note':'Demo opening stock','cost':p[7]}); }
    for (final b in brands) { await db.insert('settings', {'key':'brand_$b','value':b}); }
    for (final c in categories) { await db.insert('settings', {'key':'category_$c','value':c}); }
  }

  Future<List<Product>> products({String query='', String? category, String? brand}) async { final d=await db; final where=<String>[]; final args=<Object?>[]; if(query.isNotEmpty){where.add('(name LIKE ? OR brand LIKE ? OR model LIKE ? OR sku LIKE ? OR barcode LIKE ?)'); args.addAll(['%$query%','%$query%','%$query%','%$query%','%$query%']);} if(category!=null){where.add('category=?');args.add(category);} if(brand!=null){where.add('brand=?');args.add(brand);} final rows=await d.query('products',where:where.isEmpty?null:where.join(' AND '),whereArgs:args,orderBy:'name'); return rows.map(Product.fromMap).toList(); }
  Future<void> adjustStock(Product p,int delta,String reason) async { final d=await db; await d.transaction((txn) async { final next=p.quantity+delta; if(next<0) throw Exception('Stock cannot be negative'); await txn.update('products',{'quantity':next,'updated_at':DateTime.now().toIso8601String()},where:'id=?',whereArgs:[p.id]); await txn.insert('stock_movements',{'product_id':p.id,'quantity':delta,'type':'ADJUSTMENT','date':DateTime.now().toIso8601String(),'note':reason,'cost':p.purchasePrice}); }); }
  Future<void> sell(Product p,int qty,{String customer='Walk-in Customer',String payment='Cash'}) async { if(qty<=0||qty>p.quantity) throw Exception('Insufficient stock'); final d=await db; await d.transaction((txn) async { final sale=await txn.insert('sales',{'customer':customer,'date':DateTime.now().toIso8601String(),'total':p.sellingPrice*qty,'payment':payment}); await txn.insert('sale_items',{'sale_id':sale,'product_id':p.id,'quantity':qty,'price':p.sellingPrice,'cost':p.purchasePrice}); await txn.update('products',{'quantity':p.quantity-qty,'updated_at':DateTime.now().toIso8601String()},where:'id=?',whereArgs:[p.id]); await txn.insert('stock_movements',{'product_id':p.id,'quantity':-qty,'type':'SALE','reference_id':'$sale','date':DateTime.now().toIso8601String(),'note':'POS sale','cost':p.purchasePrice}); }); }
  Future<Map<String,num>> snapshot() async { final d=await db; final ps=await products(); final sales=await d.rawQuery('SELECT COALESCE(SUM(total),0) total FROM sales WHERE date >= ?', [DateTime.now().toIso8601String().substring(0,10)]); final purchases=await d.rawQuery('SELECT COALESCE(SUM(total),0) total FROM purchases WHERE date >= ?', [DateTime.now().toIso8601String().substring(0,10)]); return {'inventory':ps.fold<num>(0,(a,p)=>a+p.purchasePrice*p.quantity),'sales':(sales.first['total'] as num),'purchases':(purchases.first['total'] as num),'low':ps.where((p)=>p.quantity<=p.minimumStock).length}; }
}
