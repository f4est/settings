import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});
  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  TextEditingController emailCtrl=TextEditingController();
  TextEditingController answerCtrl=TextEditingController();
  TextEditingController newPassCtrl=TextEditingController();
  TextEditingController newPass2Ctrl=TextEditingController();
  String question='';
  bool verified=false;
  String error='';
  Future<void> getQuestion() async {
    var r=await http.post(Uri.parse('http://127.0.0.1:5000/api/forgot-password'),
      headers:{'Content-Type':'application/json'},
      body:jsonEncode({'email':emailCtrl.text}));
    var j=jsonDecode(r.body);
    if(j['secretQuestion']!=null) {
      setState(()=>question=j['secretQuestion']);
    } else {
      setState((){
        question='';
        error=j['error']??'Error';
      });
    }
  }
  Future<void> verifyAnswer() async {
    var r=await http.post(Uri.parse('http://127.0.0.1:5000/api/reset-password'),
      headers:{'Content-Type':'application/json'},
      body:jsonEncode({'email':emailCtrl.text,'secretAnswer':answerCtrl.text}));
    var j=jsonDecode(r.body);
    if(j['verified']==true){
      setState(()=>verified=true);
    } else if(j['error']!=null){
      setState(()=>error=j['error']);
    }
  }
  Future<void> resetPassword() async {
    if(newPassCtrl.text!=newPass2Ctrl.text){
      setState(()=>error='Passwords do not match');
      return;
    }
    var r=await http.post(Uri.parse('http://127.0.0.1:5000/api/reset-password'),
      headers:{'Content-Type':'application/json'},
      body:jsonEncode({
        'email':emailCtrl.text,
        'secretAnswer':answerCtrl.text,
        'newPassword':newPassCtrl.text
      }));
    var j=jsonDecode(r.body);
    if(j['success']==true){
      Navigator.pop(context);
    } else {
      setState(()=>error=j['error']??'Error');
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body:Padding(
        padding:EdgeInsets.all(20),
        child:Column(children:[
          TextField(controller:emailCtrl,decoration:InputDecoration(hintText:'Email'),onSubmitted:(_)=>getQuestion()),
          ElevatedButton(onPressed:getQuestion,child:Text('Send Reset Link')),
          Text(question),
          Visibility(
            visible: question.isNotEmpty,
            child: TextField(controller:answerCtrl,decoration:InputDecoration(hintText:'Secret Answer'))
          ),
          Visibility(
            visible: question.isNotEmpty,
            child: ElevatedButton(onPressed:verifyAnswer,child:Text('Verify Answer'))
          ),
          Visibility(
            visible: verified,
            child: TextField(controller:newPassCtrl,decoration:InputDecoration(hintText:'New Password'),obscureText:true)
          ),
          Visibility(
            visible: verified,
            child: TextField(controller:newPass2Ctrl,decoration:InputDecoration(hintText:'Confirm New Password'),obscureText:true)
          ),
          Visibility(
            visible: verified,
            child: ElevatedButton(onPressed:resetPassword,child:Text('Reset Password'))
          ),
          ElevatedButton(onPressed:()=>Navigator.pop(context),child:Text('Cancel')),
          Text(error)
        ])
      )
    );
  }
}
