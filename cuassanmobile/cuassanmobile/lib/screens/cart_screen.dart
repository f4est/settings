import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'order_history_screen.dart';
import 'product_detail_screen.dart';

class CartScreen extends StatefulWidget {
  final String token;
  const CartScreen({super.key, required this.token});
  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  List<Map> items=[];
  double total=0;
  bool loading=false;
  @override
  void initState(){
    super.initState();
    items=CartSingleton().items;
    calcTotal();
  }
  void calcTotal(){
    double t=0;
    for(var i in items){
      t+=i['subtotal'];
    }
    setState(()=>total=t);
  }
  Future<void> checkout() async {
    setState(()=>loading=true);
    var pf=await http.get(Uri.parse('http://127.0.0.1:5000/api/profile'),headers:{'Authorization':widget.token});
    var p=jsonDecode(pf.body);
    if(p['error']==null){
      var userEmail=p['email'];
      var r=await http.post(Uri.parse('http://127.0.0.1:5000/api/orders'),
        headers:{'Content-Type':'application/json','Authorization':widget.token},
        body:jsonEncode({'userId':userEmail,'total':total}));
      var jr=jsonDecode(r.body);
      if(jr['success']==true){
        var orderId=jr['orderId'];
        var line=items.map((e){
          return {
            'productId':e['productId'],
            'quantity':e['quantity'],
            'price':e['price']
          };
        }).toList();
        await http.post(Uri.parse('http://127.0.0.1:5000/api/order-items'),
          headers:{'Content-Type':'application/json','Authorization':widget.token},
          body:jsonEncode({'orderId':orderId,'items':line}));
        CartSingleton().clear();
      }
    }
    setState(()=>loading=false);
    Navigator.pushReplacement(context,MaterialPageRoute(builder:(_)=>OrderHistoryScreen(token:widget.token)));
  }
  @override
  Widget build(BuildContext context){
    return Scaffold(
      appBar:AppBar(title:Text('Your Cart')),
      body:loading?Center(child:CircularProgressIndicator())
      :Column(children:[
        Expanded(child:ListView.builder(
          itemCount:items.length,
          itemBuilder:(ctx,i){
            var it=items[i];
            return ListTile(
              title:Text('${it['name']} x${it['quantity']}'),
              subtitle:Text('${it['glaze']?'Glaze; ':''}${it['extraFill']?'Extra fill; ':''}\$${it['subtotal']}'),
              trailing:IconButton(icon:Icon(Icons.delete),onPressed:(){
                CartSingleton().removeItem(i);
                setState(()=>items=CartSingleton().items);
                calcTotal();
              })
            );
          }
        )),
        Padding(
          padding:EdgeInsets.all(16),
          child:Column(children:[
            Text('Total: \$${total.toStringAsFixed(2)}'),
            ElevatedButton(onPressed:items.isEmpty?null:checkout,child:Text('Checkout'))
          ])
        )
      ])
    );
  }
}
