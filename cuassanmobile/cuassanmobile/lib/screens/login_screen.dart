import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'register_screen.dart';
import 'forgot_password_screen.dart';
import 'profile_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  TextEditingController emailCtrl = TextEditingController();
  TextEditingController passCtrl = TextEditingController();
  String error = '';
  Future<void> login() async {
    var r = await http.post(Uri.parse('http://127.0.0.1:5000/api/login'),
      headers: {'Content-Type':'application/json'},
      body: jsonEncode({'email': emailCtrl.text, 'password': passCtrl.text}));
    var j = jsonDecode(r.body);
    if(j['token']!=null) {
      Navigator.push(context, MaterialPageRoute(builder:(_)=>ProfileScreen(token:j['token'])));
    } else {
      setState(()=>error=j['error']??'Error');
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding:EdgeInsets.all(20),
        child:Column(children:[
          TextField(controller: emailCtrl, decoration: InputDecoration(hintText:'Email')),
          TextField(controller: passCtrl, decoration: InputDecoration(hintText:'Password'),obscureText:true),
          ElevatedButton(onPressed: login, child:Text('Login')),
          TextButton(onPressed:(){
            Navigator.push(context, MaterialPageRoute(builder:(_)=>RegisterScreen()));
          },child:Text('Create Account')),
          TextButton(onPressed:(){
            Navigator.push(context, MaterialPageRoute(builder:(_)=>ForgotPasswordScreen()));
          },child:Text('Forgot Password?')),
          Text(error)
        ])
      )
    );
  }
}
