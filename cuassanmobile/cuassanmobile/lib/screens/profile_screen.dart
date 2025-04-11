import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:typed_data';
import 'address_screen.dart';
import 'order_history_screen.dart';
import 'catalog_screen.dart';

class ProfileScreen extends StatefulWidget {
  final String token;
  const ProfileScreen({super.key, required this.token});
  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String firstName='';
  String lastName='';
  String email='';
  String phone='';
  bool subscribe=false;
  String deliveryMethod='Pickup';
  Uint8List? profileImage;
  bool loading=true;
  Future<void> loadProfile() async {
    var r=await http.get(Uri.parse('http://127.0.0.1:5000/api/profile'),headers:{'Authorization':widget.token});
    var j=jsonDecode(r.body);
    if(j['error']==null){
      setState(() {
        firstName=j['firstName'];
        lastName=j['lastName'];
        email=j['email'];
        phone=j['phone'];
        subscribe=j['subscribe'];
        deliveryMethod=j['deliveryMethod'];
        if(j['profileImageBase64']!=null) {
          profileImage=base64Decode(j['profileImageBase64']);
        }
        loading=false;
      });
    }
  }
  @override
  void initState(){
    super.initState();
    loadProfile();
  }
  Widget textRow(String lbl,String val,Function(String)onSubmit){
    TextEditingController c=TextEditingController(text:val);
    return Row(children:[
      Expanded(child:Text(lbl)),
      Expanded(child:TextField(
        controller:c,
        onSubmitted:(v){onSubmit(v);}
      ))
    ]);
  }
  Future<void> saveProfile(Map<String,dynamic> data) async {
    var req=http.MultipartRequest('PUT',Uri.parse('http://127.0.0.1:5000/api/profile'));
    req.headers['Authorization']=widget.token;
    data.forEach((k,v){
      if(k!='profileImage') req.fields[k]=v.toString();
    });
    if(data['profileImage']!=null){
      req.files.add(await http.MultipartFile.fromPath('profileImage',data['profileImage']));
    }
    var res=await req.send();
    var b=await res.stream.bytesToString();
    var j=jsonDecode(b);
    if(j['error']==null){
      setState(() {
        firstName=j['firstName'];
        lastName=j['lastName'];
        phone=j['phone'];
        subscribe=j['subscribe'];
        deliveryMethod=j['deliveryMethod'];
        if(j['profileImageBase64']!=null){
          profileImage=base64Decode(j['profileImageBase64']);
        }
      });
    }
  }
  @override
  Widget build(BuildContext context){
    if(loading) return Scaffold(body:Center(child:CircularProgressIndicator()));
    return Scaffold(
      appBar:AppBar(title:Text('Profile')),
      body:SingleChildScrollView(
        padding:EdgeInsets.all(20),
        child:Column(children:[
          textRow('First Name',firstName,(v){saveProfile({'firstName':v});}),
          textRow('Last Name',lastName,(v){saveProfile({'lastName':v});}),
          Text('Email: $email'),
          textRow('Phone',phone,(v){saveProfile({'phone':v});}),
          SwitchListTile(
            title:Text('Subscribe'),
            value:subscribe,
            onChanged:(v){
              saveProfile({'subscribe':v?1:0});
              setState(()=>subscribe=v);
            }
          ),
          Row(children:[
            Radio<String>(value:'Pickup',groupValue:deliveryMethod,onChanged:(v){
              saveProfile({'deliveryMethod':v});
              setState(()=>deliveryMethod=v??'');
            }),
            Text('Pickup'),
            Radio<String>(value:'Delivery',groupValue:deliveryMethod,onChanged:(v){
              saveProfile({'deliveryMethod':v});
              setState(()=>deliveryMethod=v??'');
            }),
            Text('Delivery')
          ]),
          profileImage==null?Container(width:100,height:100,color:Colors.grey):Image.memory(profileImage!,width:100,height:100),
          ElevatedButton(
            onPressed:(){
              Navigator.push(context,MaterialPageRoute(builder:(_)=>AddressScreen(token:widget.token)));
            },
            child:Text('Manage Addresses')
          ),
          ElevatedButton(
            onPressed:(){
              Navigator.push(context,MaterialPageRoute(builder:(_)=>OrderHistoryScreen(token:widget.token)));
            },
            child:Text('Order History')
          ),
          ElevatedButton(
            onPressed:(){
              Navigator.push(context,MaterialPageRoute(builder:(_)=>CatalogScreen(token:widget.token)));
            },
            child:Text('Go to Catalog')
          )
        ])
      )
    );
  }
}
