import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server/gmail.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

import 'screen-login.dart';

class ScreenForgotPassword extends StatefulWidget {
  _ScreenForgotPassword createState() => _ScreenForgotPassword();
}

class _ScreenForgotPassword extends State<ScreenForgotPassword> {

  late String email;
  late TextEditingController _email = TextEditingController();

  final  _formKey = GlobalKey<FormState>();
  bool _isBtnRegister = true;


  @override
  void initState() {
    super.initState();
  }

  void sendEmail() async {

    setState(() {
      _isBtnRegister = false;
    });

    final random = Random();
    final characters = 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    String newPassword = '';
    for (int i = 0; i < 8; i++) {
      newPassword += characters[
      random.nextInt(characters.length)]; // Generate a random password
    }

    String username='pstwitdept@gmail.com';
    String password='orfovnkgysytzseo';
    String status = '';

    final smtpServer = gmail(username, password);
    final message = Message()
      ..from = Address(username,'Mail service')
      ..recipients.add(email)
      ..subject = 'MMS: Temporary password'
      ..text = 'Your password : ' + newPassword;

    try {
      await send(message,smtpServer);
      status = 'success';
    } catch (e) {
      print('error');
      status = 'failure';
    }

    if (status=='success') {
      _updateData(email,newPassword);
    }

    else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text("Connection problem",style: TextStyle(color: Colors.red),),
      ));
      setState(() {
        _email.clear();
        _isBtnRegister = true;
      });
    }
  }


  _updateData(String mail,String pwd) async {

    String url = "https://mmsv2.pstw.com.my/api/api-get.php?action=change_password&email="+mail+"&password="+pwd;
    final response = await http.get(Uri.parse(url));
    var data = json.decode(response.body);

    if (data['statusCode']==400) { // success

      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text("Tukar katalaluan berjaya",style: TextStyle(color: Colors.white),),
      ));
      Timer(Duration(seconds: 1), () {
        Navigator.pushAndRemoveUntil(
            context, MaterialPageRoute(builder: (BuildContext context){
          return ScreenLogin();
        }), (r){
          return false;
        });
      });

    }

    else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        backgroundColor: Colors.white,
        content: Text("Emel anda tidak wujud",style: TextStyle(color: Colors.red),),
      ));
      setState(() {
        _email.clear();
        _isBtnRegister = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Forgot Password'),
        backgroundColor: Colors.blue,
      ),
      body: SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.only(top: 10,bottom: 10,left: 15,right: 15),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text('Enter your email address',
                      style: TextStyle(fontWeight: FontWeight.bold,fontSize: 18),),
                  ],
                ),
                SizedBox(
                  height: 5,
                ),
                Text('* Compulsory field', style: TextStyle(color: Colors.red),textAlign: TextAlign.left,),
                SizedBox(
                  height: 10.0,
                ),
                TextFormField(
                  controller: _email,
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.grey[200],
                    border: InputBorder.none,
                    prefixIcon: Icon(
                        Icons.email
                    ),
                    hintText: 'Emel',
                  ),
                  validator: validateEmail,
                  onSaved: (value) => setState(() => email = value!),
                ),
                SizedBox(
                  height: 10.0,
                ),
                _isBtnRegister ? Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          _formKey.currentState!.save();
                          sendEmail();
                        }
                      },
                      style: ButtonStyle(
                        backgroundColor: MaterialStateProperty.all<Color>(Colors.blue),
                      ),
                      child: Text('Submit',style: TextStyle(fontWeight: FontWeight.bold,color: Colors.white),),
                    ),
                    SizedBox(
                      width: 5.0,
                    ),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.push(context, new MaterialPageRoute(
                            builder: (BuildContext context) => new ScreenLogin()),
                        );
                      },
                      style: ButtonStyle(
                        backgroundColor: MaterialStateProperty.all<Color>(Colors.red),
                      ),
                      child: Text('Cancel',style: TextStyle(color: Colors.white,fontWeight: FontWeight.bold),),
                    ),
                  ],
                ): Center(
                  child: CircularProgressIndicator(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String? validateEmail(String? email) {
    if (email!.length==0) {
      return 'Email address';
    }
  }

}