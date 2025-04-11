import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:typed_data';
import 'product_detail_screen.dart';

class CatalogScreen extends StatefulWidget {
  final String token;
  const CatalogScreen({super.key, required this.token});
  @override
  State<CatalogScreen> createState() => _CatalogScreenState();
}

class _CatalogScreenState extends State<CatalogScreen> {
  TextEditingController searchCtrl=TextEditingController();
  List products=[];
  bool loading=true;
  List selectedCats=[];
  List allCats=['Croissants','Bread','Desserts'];
  List favorites=[];
  Future<void> loadProducts() async {
    setState(()=>loading=true);
    var url='http://127.0.0.1:5000/api/products?search=${searchCtrl.text}';
    for(var c in selectedCats){
      url+='&cat=$c';
    }
    var r=await http.get(Uri.parse(url));
    var j=jsonDecode(r.body);
    setState((){products=j;loading=false;});
  }
  @override
  void initState(){
    super.initState();
    loadProducts();
  }
  void toggleFav(int pid){
    setState((){
      if(favorites.contains(pid)) favorites.remove(pid); else favorites.add(pid);
    });
  }
  Widget catChip(String cat){
    bool sel=selectedCats.contains(cat);
    return FilterChip(
      label:Text(cat),
      selected:sel,
      onSelected:(v){
        setState((){
          if(v) selectedCats.add(cat); else selectedCats.remove(cat);
        });
        loadProducts();
      }
    );
  }
  @override
  Widget build(BuildContext context){
    return Scaffold(
      appBar:AppBar(title:Text('Catalog'),actions:[
        IconButton(icon:Icon(Icons.search),onPressed:loadProducts)
      ]),
      body:Column(children:[
        Padding(
          padding:EdgeInsets.all(8),
          child:TextField(
            controller:searchCtrl,
            decoration:InputDecoration(
              labelText:'Search',
              suffixIcon:IconButton(
                icon:Icon(Icons.clear),
                onPressed:(){
                  searchCtrl.clear();
                  loadProducts();
                }
              )
            ),
            onSubmitted:(_)=>loadProducts(),
          )
        ),
        SingleChildScrollView(
          scrollDirection:Axis.horizontal,
          child:Row(
            children:allCats.map((c)=>Padding(
              padding:EdgeInsets.only(right:8),
              child:catChip(c)
            )).toList()
          )
        ),
        ElevatedButton(onPressed:(){
          setState((){
            searchCtrl.clear();
            selectedCats.clear();
          });
          loadProducts();
        },child:Text('Clear Filters')),
        Expanded(
          child:loading?Center(child:CircularProgressIndicator())
            :ListView.builder(
              itemCount:products.length,
              itemBuilder:(ctx,i){
                var p=products[i];
                var isFav=favorites.contains(p['id']);
                Uint8List? img;
                if(p['imageBase64']!=null){
                  img=base64Decode(p['imageBase64']);
                }
                return ListTile(
                  leading:img==null?Icon(Icons.image):Image.memory(img,width:50,height:50),
                  title:Text(p['name']),
                  subtitle:Text('${p['category']} | \$${p['price']}'),
                  trailing:IconButton(
                    icon:Icon(isFav?Icons.favorite:Icons.favorite_border),
                    onPressed:()=>toggleFav(p['id'])
                  ),
                  onTap:(){
                    Navigator.push(context,MaterialPageRoute(
                      builder:(_)=>ProductDetailScreen(token:widget.token,productId:p['id'])
                    ));
                  }
                );
              }
            )
        )
      ])
    );
  }
}
