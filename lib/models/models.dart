class Math { static int min(int a,int b)=>a<b?a:b; }

class Product {
  final int? id;
  final String name, brand, category, model, sku, barcode, imageUrl;
  final double mrp, sellingPrice, purchasePrice;
  final int quantity, minimumStock;
  final String supplier, warranty, specs;
  const Product({this.id, required this.name, required this.brand, required this.category, required this.model, required this.sku, required this.barcode, required this.imageUrl, required this.mrp, required this.sellingPrice, required this.purchasePrice, required this.quantity, required this.minimumStock, required this.supplier, required this.warranty, required this.specs});
  double get profit=>sellingPrice-purchasePrice;
  double get margin=>sellingPrice==0?0:profit/sellingPrice*100;
  String get status=>quantity==0?'OUT OF STOCK':quantity<=minimumStock?'LOW STOCK':'IN STOCK';
  Map<String,Object?> toMap()=>{'id':id,'name':name,'brand':brand,'category':category,'model':model,'sku':sku,'barcode':barcode,'image_url':imageUrl,'mrp':mrp,'selling_price':sellingPrice,'purchase_price':purchasePrice,'quantity':quantity,'minimum_stock':minimumStock,'supplier':supplier,'warranty':warranty,'specs':specs};
  factory Product.fromMap(Map<String,Object?> m)=>Product(id:m['id'] as int?,name:m['name'] as String,brand:m['brand'] as String,category:m['category'] as String,model:(m['model'] as String?)??'',sku:(m['sku'] as String?)??'',barcode:(m['barcode'] as String?)??'',imageUrl:(m['image_url'] as String?)??'',mrp:(m['mrp'] as num).toDouble(),sellingPrice:(m['selling_price'] as num).toDouble(),purchasePrice:(m['purchase_price'] as num).toDouble(),quantity:(m['quantity'] as num).toInt(),minimumStock:(m['minimum_stock'] as num?)?.toInt()??2,supplier:(m['supplier'] as String?)??'',warranty:(m['warranty'] as String?)??'',specs:(m['specs'] as String?)??'');
}

class StockMovement { final String type; final int quantity; final String product; final DateTime date; final String note; const StockMovement({required this.type,required this.quantity,required this.product,required this.date,required this.note}); }
