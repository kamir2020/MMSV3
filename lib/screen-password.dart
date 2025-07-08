import 'dart:async';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class ScreenPassword extends StatefulWidget {
  _ScreenPassword createState() => _ScreenPassword();
}

class _ScreenPassword extends State<ScreenPassword> {

  bool _isBtnRSetting = true;
  final  _formKey = GlobalKey<FormState>();
  final _newPassword = TextEditingController();
  late String? newPassword;

  void _changePassword() async {

    final prefs = await SharedPreferences.getInstance();
    String id = prefs.getString('auth_id').toString();

    setState(() {
      _isBtnRSetting = false;
    });

    String url = "https://mmsv2.pstw.com.my/api/api-get.php?action=new_password&userID="+id+"&password="+newPassword!;
    final response = await http.get(Uri.parse(url));
    var data = json.decode(response.body);

    if (data['statusCode']==400) { // success

      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text("Your password has been changed",style: TextStyle(color: Colors.white),),
      ));
      setState(() {
        _newPassword.clear();
      });
    }

    else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        backgroundColor: Colors.white,
        content: Text("Password is invalid, try again",style: TextStyle(color: Colors.red),),
      ));
      setState(() {
        _newPassword.clear();
      });
    }

    setState(() {
      _isBtnRSetting = true;
    });

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                    Text('Enter your new password',
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
                  obscureText: true,
                  controller: _newPassword,
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.grey[200],
                    border: InputBorder.none,
                    prefixIcon: Icon(
                        Icons.lock
                    ),
                    hintText: 'New password',
                  ),
                  validator: validatePassword,
                  onSaved: (value) => setState(() => newPassword = value!),
                ),
                SizedBox(
                  height: 10.0,
                ),
                _isBtnRSetting ? Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          _formKey.currentState!.save();
                          _changePassword();
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
                        /*
                        Navigator.push(context, new MaterialPageRoute(
                            builder: (BuildContext context) => new ScreenLogin()),
                        );*/
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

  String? validatePassword(String? password) {
    if (password!.length<8) {
      return 'Invalid password (must be more than 8 character)';
    }
  }
}