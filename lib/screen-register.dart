import 'dart:async';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'screen-login.dart';

class ScreenRegister extends StatefulWidget {
  _ScreenRegister createState() => _ScreenRegister();
}

class _ScreenRegister extends State<ScreenRegister> {

  bool btnRegister = false;
  late String? fullName, email, password;
  late String? selectGroupID,selectDepartID;
  TextEditingController _fullName = TextEditingController();
  final _formRegister = GlobalKey<FormState>();

  // List of dropdown items
  final List<DropdownItemGroup> _itemGroup = [
    DropdownItemGroup(id: 'L1', name: 'Management'),
    DropdownItemGroup(id: 'L2', name: 'Manager'),
    DropdownItemGroup(id: 'L3', name: 'Executive'),
    DropdownItemGroup(id: 'L4', name: 'Engineer'),
    DropdownItemGroup(id: 'L5', name: 'Technician'),
    DropdownItemGroup(id: 'L6', name: 'QAQC'),
    DropdownItemGroup(id: 'L7', name: 'Inventory Master'),
    DropdownItemGroup(id: 'L8', name: 'IT'),
  ];

  DropdownItemGroup? _selectedItemGroup;

  // List of dropdown items
  final List<DropdownItemDepart> _itemDepart = [
    DropdownItemDepart(id: 'D1', name: 'Air'),
    DropdownItemDepart(id: 'D2', name: 'River'),
    DropdownItemDepart(id: 'D3', name: 'Marine'),
    DropdownItemDepart(id: 'D4', name: 'IT'),
    DropdownItemDepart(id: 'D5', name: 'Management'),
  ];

  DropdownItemDepart? _selectedItemDepart;

  @override
  void initState() {
    super.initState();
  }

  void _functionRegister() async {

    setState(() {
      btnRegister = true;
    });

    var client = http.Client();
    var response = await
    client.post(Uri.parse("https://mmsv2.pstw.com.my/api/api-post.php"), body: {
      "action": "register-user","fullName": fullName,"username": email,"pwd": password,
      "levelID": selectGroupID,"departID": selectDepartID,
    });
    var data = json.decode(response.body);

    if (data['statusCode']==200) {

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Registration success!',
          style: TextStyle(color: Colors.white),),backgroundColor: Colors.black,),
      );

      Timer(Duration(seconds: 1), () {
        Navigator.pushAndRemoveUntil(
            context, MaterialPageRoute(builder: (BuildContext context){
          return ScreenLogin();
        }), (r){
          return false;
        });
      });

      setState(() {
        btnRegister = false;
      });
    }

    else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Registration fail!',
          style: TextStyle(color: Colors.white),),backgroundColor: Colors.red,),
      );

      setState(() {
        btnRegister = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue[100],
        automaticallyImplyLeading: false,
        leadingWidth: 120,
        leading: ElevatedButton.icon(
          onPressed: () => Navigator.push(context,
              MaterialPageRoute(builder: (context) =>
                  ScreenLogin())),
          icon: Icon(Icons.arrow_left_sharp),
          label: Text('Back'),
          style: ElevatedButton.styleFrom(
            elevation: 0,
            backgroundColor: Colors.transparent,
          ),
        ),
        title: const Text('Registration'),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(5.0),
        child: Form(
          key: _formRegister,
          child: Column(
            children: [
              SizedBox(height: 10.0,),
              TextFormField(
                controller: _fullName,
                inputFormatters: [],
                decoration: InputDecoration(
                  hintText: 'Akmal Muhammad',
                  contentPadding: EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10.0),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(15.0)),
                ),
                onChanged: (value) {
                  _fullName.value = TextEditingValue(
                      text: value.toUpperCase(),
                      selection: _fullName.selection
                  );
                },
                validator: validateName,
                onSaved: (value) => setState(() => fullName = value!),
              ),
              SizedBox(height: 5.0,),
              TextFormField(
                decoration: InputDecoration(
                  hintText: 'Email',
                  contentPadding: EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10.0),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(15.0)),
                ),
                validator: validateEmail,
                onSaved: (value) => setState(() => email = value!),
              ),
              SizedBox(height: 5.0,),
              TextFormField(
                obscureText: true,
                decoration: InputDecoration(
                  hintText: 'Password',
                  contentPadding: EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10.0),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(15.0)),
                ),
                validator: validatePassword,
                onSaved: (value) => setState(() => password = value!),
              ),
              SizedBox(height: 5.0,),
              DropdownButtonFormField<DropdownItemGroup>(
                decoration: InputDecoration(
                  contentPadding: EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10.0),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(15.0)),
                ),
                value: _selectedItemGroup,
                items: _itemGroup.map((DropdownItemGroup item) {
                  return DropdownMenuItem<DropdownItemGroup>(
                    value: item,
                    child: Text(item.name), // Display the name in the dropdown
                  );
                }).toList(),
                onChanged: (DropdownItemGroup? newValue) {
                  setState(() {
                    _selectedItemGroup = newValue;
                    selectGroupID = _selectedItemGroup!.id;
                  });
                },
                validator: (value) {
                  if (value == null) {
                    return 'Please choose your position';
                  }
                  return null;
                },
              ),
              SizedBox(height: 5.0,),
              DropdownButtonFormField<DropdownItemDepart>(
                decoration: InputDecoration(
                  contentPadding: EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10.0),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(15.0)),
                ),
                value: _selectedItemDepart,
                items: _itemDepart.map((DropdownItemDepart item) {
                  return DropdownMenuItem<DropdownItemDepart>(
                    value: item,
                    child: Text(item.name), // Display the name in the dropdown
                  );
                }).toList(),
                onChanged: (DropdownItemDepart? newValue) {
                  setState(() {
                    _selectedItemDepart = newValue;
                    selectDepartID = _selectedItemDepart!.id;
                  });
                },
                validator: (value) {
                  if (value == null) {
                    return 'Please choose your department';
                  }
                  return null;
                },
              ),
              SizedBox(height: 5.0,),
              btnRegister ? Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(height: 10.0,),
                  CircularProgressIndicator(),
                  Text('Registration in progress...',textAlign: TextAlign.center,),
                ],
              ) :
              Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            if (_formRegister.currentState!.validate()) {
                              _formRegister.currentState!.save();
                              _functionRegister();
                            }
                          },
                          child: Text('Register'),
                        ),
                      )
                    ],
                  ),
                  Center(
                    child: TextButton(
                      onPressed: () {
                        Navigator.pushAndRemoveUntil(
                            context, MaterialPageRoute(builder: (BuildContext context){
                          return ScreenLogin();
                        }), (r){
                          return false;
                        });
                      },
                      child: Text('Already register. Login'),
                    ),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }


  String? validateEmail(String? email) {

    //final gmailRegex = RegExp(r'^[a-zA-Z0-9._%+-]+@(transwater\.com|pstw\.com)$', caseSensitive: false);

    final gmailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@(transwater|pstw)\.[a-zA-Z]{2,}$',
      caseSensitive: false,
    );

    if (email == null || email.isEmpty) return 'Please enter an email';
    if (!gmailRegex.hasMatch(email)) return 'Only @transwater or @pstw allowed';
    return null;

  }

  String? validateName(String? name) {
    if (name!.length==0) {
      return 'Enter your name';
    }
  }

  String? validatePassword(String? password) {
    if ((password!.length==0)||(password.length<8)) {
      return 'Invalid password (at least 8 character)';
    }
  }
}

// Model class for dropdown item
class DropdownItemGroup {
  final String id;
  final String name;

  DropdownItemGroup({required this.id, required this.name});

  @override
  String toString() {
    return name; // This will display the name in the dropdown.
  }
}

class DropdownItemDepart {
  final String id;
  final String name;

  DropdownItemDepart({required this.id, required this.name});

  @override
  String toString() {
    return name; // This will display the name in the dropdown.
  }
}