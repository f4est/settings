import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});
  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  TextEditingController firstName=TextEditingController();
  TextEditingController lastName=TextEditingController();
  TextEditingController email=TextEditingController();
  TextEditingController pass=TextEditingController();
  TextEditingController pass2=TextEditingController();
  TextEditingController phone=TextEditingController();
  TextEditingController secretAnswer=TextEditingController();
  String selectedQuestion='';
  bool subscribe=false;
  String deliveryMethod='Pickup';
  bool loading=false;
  String error='';
  Future<void> register() async {
    if(pass.text!=pass2.text) {
      setState(()=>error='Passwords do not match');
      return;
    }
    setState(()=>loading=true);
    var r=await http.post(Uri.parse('http://127.0.0.1:5000/api/register'),
      headers:{'Content-Type':'application/json'},
      body:jsonEncode({
        'firstName':firstName.text,'lastName':lastName.text,'email':email.text,
        'password':pass.text,'phone':phone.text,'secretQuestion':selectedQuestion,
        'secretAnswer':secretAnswer.text,'subscribe':subscribe?1:0,'deliveryMethod':deliveryMethod
      }));
    var j=jsonDecode(r.body);
    setState(()=>loading=false);
    if(j['success']==true) {
      Navigator.pop(context);
    } else {
      setState(()=>error='Registration failed');
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body:SingleChildScrollView(
        padding:EdgeInsets.all(20),
        child:Column(children:[
          TextField(controller:firstName,decoration:InputDecoration(hintText:'First Name')),
          TextField(controller:lastName,decoration:InputDecoration(hintText:'Last Name')),
          TextField(controller:email,decoration:InputDecoration(hintText:'Email')),
          TextField(controller:pass,decoration:InputDecoration(hintText:'Password'),obscureText:true),
          TextField(controller:pass2,decoration:InputDecoration(hintText:'Confirm Password'),obscureText:true),
          TextField(controller:phone,decoration:InputDecoration(hintText:'Phone')),
          DropdownButton<String>(
            value: selectedQuestion.isEmpty?null:selectedQuestion,
            items:[
              'What is your mother\'s maiden name?',
              'What is your pet\'s name?',
              'Your secret phrase?'
            ].map((e)=>DropdownMenuItem(value:e,child:Text(e))).toList(),
            hint:Text('Secret Question'),
            onChanged:(v){setState(()=>selectedQuestion=v??'');}
          ),
          TextField(controller:secretAnswer,decoration:InputDecoration(hintText:'Secret Answer')),
          Row(children:[
            Checkbox(value:subscribe,onChanged:(v){setState(()=>subscribe=v??false);}),
            Text('Subscribe to Mailing List')
          ]),
          Row(children:[
            Radio<String>(value:'Pickup',groupValue:deliveryMethod,onChanged:(v){setState(()=>deliveryMethod=v??'');}),
            Text('Pickup'),
            Radio<String>(value:'Delivery',groupValue:deliveryMethod,onChanged:(v){setState(()=>deliveryMethod=v??'');}),
            Text('Delivery')
          ]),
          ElevatedButton(onPressed:loading?null:register,child:Text('Register')),
          ElevatedButton(onPressed:()=>Navigator.pop(context),child:Text('Cancel')),
          Text(error)
        ])
      )
    );
  }
}
