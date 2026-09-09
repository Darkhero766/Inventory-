import 'dart:io';
import 'package:csv/csv.dart';
import 'package:excel/excel.dart';
import '../data/database.dart';

class ImportResult { final int valid, invalid; final List<String> errors; const ImportResult({required this.valid,required this.invalid,required this.errors}); }

class ImportService {
  static Future<ImportResult> csv(File file) async {
    final rows=const CsvToListConverter().convert(await file.readAsString());
    return _apply(rows);
  }
  static Future<ImportResult> excel(File file) async {
    final book=Excel.decodeBytes(await file.readAsBytes());
    final sheet=book.tables.values.first;
    final rows=sheet.rows.map((r)=>r.map((c)=>c?.value??'').toList()).toList();
    return _apply(rows);
  }
  static Future<ImportResult> _apply(List<List<dynamic>> rows) async {
    if(rows.isEmpty)return const ImportResult(valid:0,invalid:0,errors:['The file is empty.']);
    final headers=rows.first.map((x)=>'$x'.trim().toLowerCase()).toList();
    final required=['product name','category','brand','sku','purchase price','selling price','quantity'];
    final missing=required.where((x)=>!headers.contains(x)).toList();
    if(missing.isNotEmpty)return ImportResult(valid:0,invalid:rows.length-1,errors:['Missing columns: ${missing.join(', ')}']);
    int valid=0,invalid=0;final errors=<String>[];
    String value(List<dynamic> r,String key){final i=headers.indexOf(key);return i>=0&&i<r.length?'${r[i]}'.trim():'';}
    for(var row=1;row<rows.length;row++){
      final r=rows[row];final name=value(r,'product name'),category=value(r,'category'),brand=value(r,'brand'),sku=value(r,'sku');
      final buy=double.tryParse(value(r,'purchase price')),sell=double.tryParse(value(r,'selling price')),qty=int.tryParse(value(r,'quantity'));
      if(name.isEmpty||category.isEmpty||brand.isEmpty||sku.isEmpty||buy==null||sell==null||qty==null||qty<0){invalid++;errors.add('Row ${row+1}: invalid required field or numeric value.');continue;}
      try{await AppDatabase.instance.addProduct({'name':name,'brand':brand,'category':category,'model':value(r,'model'),'sku':sku,'barcode':value(r,'barcode'),'mrp':double.tryParse(value(r,'mrp'))??sell,'selling_price':sell,'purchase_price':buy,'quantity':qty,'minimum_stock':int.tryParse(value(r,'minimum stock'))??2,'supplier':value(r,'supplier'),'warranty':value(r,'warranty'),'gst_rate':double.tryParse(value(r,'gst'))??18,'hsn_code':value(r,'hsn'),'specs':value(r,'specifications')});valid++;}catch(e){invalid++;errors.add('Row ${row+1}: $e');}
    }
    return ImportResult(valid:valid,invalid:invalid,errors:errors.take(50).toList());
  }
}
