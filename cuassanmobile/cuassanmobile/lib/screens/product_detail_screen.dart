import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:typed_data';
import 'cart_screen.dart';

class ProductDetailScreen extends StatefulWidget {
  final String token;
  final int productId;
  const ProductDetailScreen({super.key, required this.token, required this.productId});
  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  Map product={};
  bool loading=true;
  int quantity=1;
  bool glaze=false;
  bool extraFill=false;
  double total=0;
  Future<void> loadProduct() async {
    var r=await http.get(Uri.parse('http://127.0.0.1:5000/api/products/${widget.productId}'));
    var j=jsonDecode(r.body);
    if(j['error']==null){
      setState(()=>{
        product=j,
        total=j['price']
      });
    }
    setState(()=>loading=false);
  }
  void updateTotal() {
    if(product.isEmpty)return;
    double baseP=product['price'];
    double extra=0;
    if(glaze) extra+=0.5;
    if(extraFill) extra+=0.7;
    setState(()=>total=(baseP+extra)*quantity);
  }
  void addCart(){
    CartSingleton().addItem({
      'productId':product['id'],
      'name':product['name'],
      'price':(total/quantity),
      'quantity':quantity,
      'glaze':glaze,
      'extraFill':extraFill,
      'subtotal':total
    });
    Navigator.push(context,MaterialPageRoute(builder:(_)=>CartScreen(token:widget.token)));
  }
  @override
  void initState(){
    super.initState();
    loadProduct();
  }
  @override
  Widget build(BuildContext context){
    if(loading)return Scaffold(body:Center(child:CircularProgressIndicator()));
    Uint8List? img;
    if(product['imageBase64']!=null){
      img=base64Decode(product['imageBase64']);
    }
    return Scaffold(
      appBar:AppBar(title:Text(product['name']??'Product Detail')),
      body:Padding(
        padding:EdgeInsets.all(16),
        child:Column(children:[
          img==null?Icon(Icons.image,size:100):Image.memory(img,width:150,height:150),
          Text('${product['name']} - \$${product['price']}'),
          Text('Category: ${product['category']}'),
          Row(children:[
            Text('Quantity:'),
            IconButton(icon:Icon(Icons.remove),onPressed:(){
              if(quantity>1){
                setState(()=>quantity--);
                updateTotal();
              }
            }),
            Text('$quantity'),
            IconButton(icon:Icon(Icons.add),onPressed:(){
              setState(()=>quantity++);
              updateTotal();
            })
          ]),
          Row(children:[
            Checkbox(value:glaze,onChanged:(v){
              setState(()=>glaze=v??false);
              updateTotal();
            }),
            Text('Add glaze (+0.50)')
          ]),
          Row(children:[
            Checkbox(value:extraFill,onChanged:(v){
              setState(()=>extraFill=v??false);
              updateTotal();
            }),
            Text('Extra filling (+0.70)')
          ]),
          Text('Total: \$${total.toStringAsFixed(2)}'),
          ElevatedButton(onPressed:addCart,child:Text('Add to Cart'))
        ])
      )
    );
  }
}

class CartSingleton {
  static final CartSingleton _instance=CartSingleton._internal();
  factory CartSingleton(){return _instance;}
  CartSingleton._internal();
  List<Map> items=[];
  void addItem(Map i){items.add(i);}
  void removeItem(int idx){items.removeAt(idx);}
  void clear(){items.clear();}
}
