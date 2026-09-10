import 'dart:convert';
import 'package:http/http.dart' as http;

class ProductSuggestion {
  final String title, description, imageUrl, source, sourceUrl, category, brand;
  const ProductSuggestion({required this.title, required this.description, required this.imageUrl, this.source='', this.sourceUrl='', this.category='', this.brand=''});
}

class ProductCatalogService {
  static final Map<String,List<ProductSuggestion>> _cache={};
  static final Map<String,String?> _imageCache={};
  static const blocked={'film','movie','actor','actress','politician','politics','election','president','football','cricket','song','album','novel','person','band','planet','galaxy (astronomy)'};
  static const aliases={
    'Mobile Phones':['mobile','smartphone','phone'],'Laptops':['laptop','notebook'],'Televisions':['television','tv'],'Refrigerators':['refrigerator','fridge'],'Air Conditioners':['air conditioner'],'Washing Machines':['washing machine'],'Audio':['headphone','earbuds','earphone','speaker','audio'],'Cameras':['camera'],'Printers':['printer'],'Networking':['router','network','switch'],'Storage':['ssd','solid-state drive','hard disk','storage'],'Monitors':['monitor','display'],'Gaming':['gaming','game console','graphics card'],'Smartwatches':['smartwatch','watch']};

  static Future<List<ProductSuggestion>> suggest({required String query,String brand='',String category=''}) async {
    final q=query.trim(), b=brand.trim(), c=category.trim();
    if(q.length<2)return const [];
    final key='${b.toLowerCase()}|${c.toLowerCase()}|${q.toLowerCase()}';
    if(_cache.containsKey(key))return _cache[key]!;
    try{
      final uri=Uri.https('en.wikipedia.org','/w/rest.php/v1/search/page',{'q':[b,q,c].where((x)=>x.isNotEmpty).join(' '),'limit':'12'});
      final r=await http.get(uri,headers:const {'Accept':'application/json','Api-User-Agent':'InventoryShop/3.0'}).timeout(const Duration(seconds:6));
      if(r.statusCode!=200)return const [];
      final data=jsonDecode(r.body) as Map<String,dynamic>;
      final pages=data['pages'] as List<dynamic>? ?? const [];
      final out=<ProductSuggestion>[];
      for(final raw in pages){
        final m=raw as Map<String,dynamic>;final title=m['title']?.toString().trim()??'';final desc=m['description']?.toString().trim()??'';if(title.isEmpty)continue;
        final score=_score(title,desc,q,b,c);if(score<=0)continue;
        final h='$title $desc'.toLowerCase();if(blocked.any(h.contains))continue;
        final thumb=m['thumbnail'] as Map<String,dynamic>?;final image=_url(thumb?['url']?.toString()??'');
        out.add(ProductSuggestion(title:title,description:desc.isEmpty?'$b $c':desc,imageUrl:image,source:'Wikipedia',sourceUrl:'https://en.wikipedia.org/wiki/${Uri.encodeComponent(title.replaceAll(' ','_'))}',category:c,brand:b));
      }
      out.sort((a,z)=>_score(z.title,z.description,q,b,c).compareTo(_score(a.title,a.description,q,b,c)));
      final enriched=<ProductSuggestion>[];
      for(final item in out.take(6)){
        var image=item.imageUrl;
        if(image.isEmpty)image=await _commonsImage('${item.brand} ${item.title} ${item.category}'.trim());
        enriched.add(ProductSuggestion(title:item.title,description:item.description,imageUrl:image,source:item.source,sourceUrl:item.sourceUrl,category:item.category,brand:item.brand));
      }
      _cache[key]=enriched;return enriched;
    }catch(_){return const [];}
  }

  static int _score(String title,String desc,String q,String brand,String category){
    final t=title.toLowerCase(),d=desc.toLowerCase();var s=0;final b=brand.toLowerCase();
    if(b.isNotEmpty){if(t.contains(b))s+=100;else if(d.contains(b))s+=35;else return -1000;}
    final a=aliases[category]??(category.isEmpty?const <String>[]:[category.toLowerCase()]);if(a.isNotEmpty){if(a.any((x)=>'$t $d'.contains(x)))s+=60;else return -500;}
    final tokens=q.toLowerCase().split(RegExp(r'[^a-z0-9]+')).where((x)=>x.length>=2);for(final x in tokens){if(t.contains(x))s+=35;if(d.contains(x))s+=8;}if(t==q.toLowerCase())s+=80;if(t.contains(q.toLowerCase()))s+=55;return s;
  }

  static Future<String?> findImage(String query,{String brand='',String category=''}) async {
    final key='${brand.trim()}|${category.trim()}|${query.trim()}'.toLowerCase();if(key.length<3)return null;if(_imageCache.containsKey(key))return _imageCache[key];
    final image=await _commonsImage([brand.trim(),query.trim(),category.trim()].where((x)=>x.isNotEmpty).join(' '));_imageCache[key]=image.isEmpty?null:image;return image.isEmpty?null:image;
  }

  static Future<String> _commonsImage(String query) async {
    if(query.trim().length<3)return '';
    try{
      final uri=Uri.https('commons.wikimedia.org','/w/api.php',{'action':'query','generator':'search','gsrsearch':query,'gsrnamespace':'6','gsrlimit':'8','prop':'imageinfo','iiprop':'url|mime','iiurlwidth':'640','format':'json','origin':'*'});
      final r=await http.get(uri,headers:const {'Accept':'application/json','User-Agent':'InventoryShop/3.0'}).timeout(const Duration(seconds:6));if(r.statusCode!=200)return '';
      final data=jsonDecode(r.body) as Map<String,dynamic>;final queryData=data['query'] as Map<String,dynamic>?;final pages=queryData?['pages'] as Map<String,dynamic>?;if(pages==null)return '';
      final words=query.toLowerCase().split(RegExp(r'[^a-z0-9]+')).where((x)=>x.length>=2).toList();String best='';var bestScore=-1;
      for(final raw in pages.values){final m=raw as Map<String,dynamic>;final title=m['title']?.toString().toLowerCase()??'';final list=m['imageinfo'] as List<dynamic>?;if(list==null||list.isEmpty)continue;final info=list.first as Map<String,dynamic>;final mime=info['mime']?.toString()??'';if(!mime.startsWith('image/'))continue;final url=_url(info['thumburl']?.toString()??info['url']?.toString()??'');if(url.isEmpty)continue;var score=0;for(final w in words){if(title.contains(w))score+=20;}if(title.contains('logo')||title.contains('icon'))score-=20;if(title.contains('portrait')||title.contains('person'))score-=50;if(score>bestScore){bestScore=score;best=url;}}
      return bestScore>0?best:'';
    }catch(_){return '';}
  }
  static String _url(String url)=>url.startsWith('//')?'https:$url':url;
}
