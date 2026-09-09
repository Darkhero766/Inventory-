import 'dart:io';
import 'package:csv/csv.dart';
import 'package:excel/excel.dart';
import 'package:path/path.dart' as path;
import '../data/database.dart';

class ExportService {
  static Future<File> inventoryCsv(String directory) async {
    final products=await AppDatabase.instance.products(includeArchived:true);
    final rows=<List<dynamic>>[['Product Name','Brand','Category','Model','SKU','Barcode','MRP','Selling Price','Purchase Price','Quantity','Minimum Stock','Supplier','Warranty']];
    rows.addAll(products.map((p)=>[p.name,p.brand,p.category,p.model,p.sku,p.barcode,p.mrp,p.sellingPrice,p.purchasePrice,p.quantity,p.minimumStock,p.supplier,p.warranty]));
    final file=File(path.join(directory,'inventory_${DateTime.now().millisecondsSinceEpoch}.csv'));
    await file.writeAsString(const ListToCsvConverter().convert(rows));
    return file;
  }
  static Future<File> inventoryExcel(String directory) async {
    final products=await AppDatabase.instance.products(includeArchived:true);
    final book=Excel.createExcel();
    final sheet=book['Inventory'];
    final headers=['Product Name','Brand','Category','Model','SKU','Barcode','MRP','Selling Price','Purchase Price','Quantity','Minimum Stock','Supplier','Warranty'];
    for(var i=0;i<headers.length;i++)sheet.cell(CellIndex.indexByColumnRow(columnIndex:i,rowIndex:0)).value=TextCellValue(headers[i]);
    for(var r=0;r<products.length;r++){final p=products[r];final values=[p.name,p.brand,p.category,p.model,p.sku,p.barcode,p.mrp,p.sellingPrice,p.purchasePrice,p.quantity,p.minimumStock,p.supplier,p.warranty];for(var col=0;col<values.length;col++){final v=values[col];final cell=sheet.cell(CellIndex.indexByColumnRow(columnIndex:col,rowIndex:r+1));cell.value=v is num?DoubleCellValue(v.toDouble()):TextCellValue('$v');}}
    final bytes=book.encode();if(bytes==null)throw Exception('Unable to create Excel file');final file=File(path.join(directory,'inventory_${DateTime.now().millisecondsSinceEpoch}.xlsx'));await file.writeAsBytes(bytes);return file;
  }
}
