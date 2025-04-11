import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class AddressScreen extends StatefulWidget {
  final String token;
  const AddressScreen({super.key, required this.token});
  @override
  State<AddressScreen> createState() => _AddressScreenState();
}

class _AddressScreenState extends State<AddressScreen> {
  List addresses=[];
  bool loading=true;
  Future<void> loadAddresses() async {
    var r=await http.get(Uri.parse('http://127.0.0.1:5000/api/addresses'),headers:{'Authorization':widget.token});
    var j=jsonDecode(r.body);
    setState((){addresses=j;loading=false;});
  }
  Future<void> saveAddress(int? id,String label,String fullAddress,bool preferred) async {
    if(id==null){
      await http.post(Uri.parse('http://127.0.0.1:5000/api/addresses'),
        headers:{'Content-Type':'application/json','Authorization':widget.token},
        body:jsonEncode({'label':label,'fullAddress':fullAddress,'preferred':preferred?1:0}));
    } else {
      await http.put(Uri.parse('http://127.0.0.1:5000/api/addresses/$id'),
        headers:{'Content-Type':'application/json','Authorization':widget.token},
        body:jsonEncode({'label':label,'fullAddress':fullAddress,'preferred':preferred?1:0}));
    }
    loadAddresses();
  }
  Future<void> deleteAddress(int id) async {
    await http.delete(Uri.parse('http://127.0.0.1:5000/api/addresses/$id'),headers:{'Authorization':widget.token});
    loadAddresses();
  }
  @override
  void initState(){
    super.initState();
    loadAddresses();
  }
  @override
  Widget build(BuildContext context){
    if(loading)return Scaffold(body:Center(child:CircularProgressIndicator()));
    return Scaffold(
      appBar:AppBar(title:Text('Addresses')),
      body:ListView.builder(
        itemCount:addresses.length+1,
        itemBuilder:(ctx,i){
          if(i<addresses.length){
            var a=addresses[i];
            return ListTile(
              title:Text(a['label']),
              subtitle:Text(a['fullAddress']),
              trailing:a['preferred']?Icon(Icons.star):null,
              onTap:(){
                showDialog(context:context,builder:(_){
                  TextEditingController labelCtrl=TextEditingController(text:a['label']);
                  TextEditingController addrCtrl=TextEditingController(text:a['fullAddress']);
                  bool pr=a['preferred'];
                  return AlertDialog(
                    title:Text('Edit Address'),
                    content:Column(mainAxisSize:MainAxisSize.min,children:[
                      TextField(controller:labelCtrl,decoration:InputDecoration(hintText:'Label')),
                      TextField(controller:addrCtrl,decoration:InputDecoration(hintText:'Full Address')),
                      CheckboxListTile(value:pr,onChanged:(v){pr=v??false;},title:Text('Preferred'))
                    ]),
                    actions:[
                      TextButton(onPressed:()=>Navigator.pop(context),child:Text('Cancel')),
                      TextButton(onPressed:(){
                        saveAddress(a['id'],labelCtrl.text,addrCtrl.text,pr);
                        Navigator.pop(context);
                      },child:Text('Save')),
                      TextButton(onPressed:(){
                        deleteAddress(a['id']);
                        Navigator.pop(context);
                      },child:Text('Delete'))
                    ]
                  );
                });
              }
            );
          } else {
            return ListTile(
              leading:Icon(Icons.add),
              title:Text('Add New Address'),
              onTap:(){
                showDialog(context:context,builder:(_){
                  TextEditingController labelCtrl=TextEditingController();
                  TextEditingController addrCtrl=TextEditingController();
                  bool pr=false;
                  return AlertDialog(
                    title:Text('New Address'),
                    content:Column(mainAxisSize:MainAxisSize.min,children:[
                      TextField(controller:labelCtrl,decoration:InputDecoration(hintText:'Label')),
                      TextField(controller:addrCtrl,decoration:InputDecoration(hintText:'Full Address')),
                      CheckboxListTile(value:pr,onChanged:(v){pr=v??false;},title:Text('Preferred'))
                    ]),
                    actions:[
                      TextButton(onPressed:()=>Navigator.pop(context),child:Text('Cancel')),
                      TextButton(onPressed:(){
                        saveAddress(null,labelCtrl.text,addrCtrl.text,pr);
                        Navigator.pop(context);
                      },child:Text('Add'))
                    ]
                  );
                });
              }
            );
          }
        }
      )
    );
  }
}
