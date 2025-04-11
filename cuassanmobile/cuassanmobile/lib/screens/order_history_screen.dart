import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class OrderHistoryScreen extends StatefulWidget {
  final String token;
  const OrderHistoryScreen({super.key, required this.token});
  @override
  State<OrderHistoryScreen> createState() => _OrderHistoryScreenState();
}

class _OrderHistoryScreenState extends State<OrderHistoryScreen> {
  List orders=[];
  bool loading=true;
  Future<void> loadOrders() async {
    var prof=await http.get(Uri.parse('http://127.0.0.1:5000/api/profile'),headers:{'Authorization':widget.token});
    var pf=jsonDecode(prof.body);
    if(pf['error']==null){
      var r=await http.get(Uri.parse('http://127.0.0.1:5000/api/orders?user_id='+pf['email']),headers:{'Authorization':widget.token});
      var j=jsonDecode(r.body);
      setState((){orders=j;loading=false;});
    }
  }
  @override
  void initState(){
    super.initState();
    loadOrders();
  }
  @override
  Widget build(BuildContext context){
    if(loading)return Scaffold(body:Center(child:CircularProgressIndicator()));
    return Scaffold(
      appBar:AppBar(title:Text('Order History')),
      body:ListView.builder(
        itemCount:orders.length,
        itemBuilder:(ctx,i){
          var o=orders[i];
          return ListTile(
            title:Text('Order #${o['orderId']}'),
            subtitle:Text('${o['orderDate']} | ${o['status']} | \$${o['total']}')
          );
        }
      )
    );
  }
}
