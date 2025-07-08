import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:mime/mime.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'package:sqflite/sqflite.dart';
import 'screen-forgot-password.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'db_helper.dart';
import 'screen-register.dart';
import 'user-dashboard.dart';
import 'package:http_parser/http_parser.dart';

class ScreenLogin extends StatefulWidget {
  @override
  _ScreenLogin createState() => new _ScreenLogin();
}

class _ScreenLogin extends State<ScreenLogin> {

  final  _formKey = GlobalKey<FormState>();
  late String _fullname='',_username='', _password='';
  final ct_username = TextEditingController();
  final ct_password = TextEditingController();

  bool _isErrorLogin = false;
  bool _isErrorNRID = false;
  bool _isErrorPassword = false;
  bool _isBtnLogin = true;
  bool _passwordObsecure = true;

  bool isChecked = false;
  late Box box1;

  final db = DBHelper();
  List<dynamic> data = [];

  @override
  void initState() {
    super.initState();
    fetchData();
    createBox();
  }

  void createBox() async {
    box1 = await Hive.openBox('logindata');
    getData();
  }

  void getData() async {
    if (box1.get('email')!=null) {
      ct_username.text = box1.get('email');
    }
    if (box1.get('password')!=null) {
      ct_password.text = box1.get('password');
    }
  }

  void fetchData() async {
    print('AAA');
    List<Map<String, dynamic>> users = await DBHelper.getData();
    for (var user in users) {
      print('Name: ${user['fullname']}');
    }
  }

  Future<void> saveSession(String username,String userID,String levelID,String departID, String fullName) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('email', username);
    await prefs.setString('fullName', fullName);
    await prefs.setString('auth_id', userID);
    await prefs.setString('auth_levelID', levelID);
    await prefs.setString('auth_departID', departID);
  }

  Future<bool> isConnected() async {
    var connectivityResult = await Connectivity().checkConnectivity();
    return connectivityResult != ConnectivityResult.none;
  }

  Future<void> fetchAndSaveSampler() async {
    final url = Uri.parse('https://mmsv2.pstw.com.my/api/api-get.php?action=load-tbl-sampler&username='+_username);
    final response = await http.get(url);

    if (response.statusCode == 200) {

      List<dynamic> samplers = jsonDecode(response.body);
      print(samplers);
      for (var sampler in samplers) {
        db.insertSampler({
          "id": sampler['id'],
          "fullname": sampler['fullname'],
          "email": sampler['username'],
          "userID": sampler['userID'],
        });
      }
      print('data sampler has been save in sqlite');
    } else {
      throw Exception('Failed to load data');
    }
  }

  Future<void> fetchAndSaveCategory() async {
    final url = Uri.parse('https://mmsv2.pstw.com.my/api/api-get.php?action=load-tbl-category');
    final response = await http.get(url);

    if (response.statusCode == 200) {

      List<dynamic> categories = jsonDecode(response.body);
      for (var category in categories) {
        db.insertCategory({
          "id": category['id'],
          "categoryID": category['categoryID'],
          "categoryName": category['categoryName'],
        });
      }
      print('data has been save in sqlite');
    } else {
      throw Exception('Failed to load data');
    }
  }

  Future<void> fetchAndSaveState() async {
    final url = Uri.parse('https://mmsv2.pstw.com.my/api/api-get.php?action=load-tbl-state');
    final response = await http.get(url);

    if (response.statusCode == 200) {

      List<dynamic> states = jsonDecode(response.body);
      for (var state in states) {
        db.insertState({
          "id": state['id'],
          "stateID": state['stateID'],
          "stateName": state['stateName'],
        });
      }
      print('data has been save in sqlite');
    } else {
      throw Exception('Failed to load data');
    }
  }

  Future<void> fetchAndSaveMarineStation() async {
    print('Try');
    final url = Uri.parse('https://mmsv2.pstw.com.my/api/api-get.php?action=load-tbl-marine-station');
    final response = await http.get(url);

    if (response.statusCode == 200) {

      List<dynamic> stations = jsonDecode(response.body);
      for (var station in stations) {
        db.insertMarineStation({
          "id": station['id'],
          "stationID": station['stationID'],
          "stateID": station['stateID'],
          "categoryID": station['categoryID'],
          "locationName": station['locationName'],
          "latitude": station['latitude'],
          "longitude": station['longitude'],
        });
      }
      print('data marine station has been save in sqlite');
    } else {
      throw Exception('Failed to load data');
    }
  }

  Future<void> fetchAndSaveTarballStation() async {
    final url = Uri.parse('https://mmsv2.pstw.com.my/api/api-get.php?action=load-tbl-tarball-station');
    final response = await http.get(url);

    if (response.statusCode == 200) {

      List<dynamic> stations = jsonDecode(response.body);
      for (var station in stations) {
        db.insertTarballStation({
          "id": station['id'],
          "stationID": station['stationID'],
          "stateID": station['stateID'],
          "categoryID": station['categoryID'],
          "locationName": station['locationName'],
          "longitude": station['longitude'],
          "latitude": station['latitude'],
        });
      }
      print('data has been save in sqlite');
    } else {
      throw Exception('Failed to load data');
    }
  }

  Future<void> fetchAndSaveAirStation() async {
    final url = Uri.parse('https://mmsv2.pstw.com.my/api/api-get.php?action=load-tbl-air-station');
    final response = await http.get(url);

    if (response.statusCode == 200) {

      List<dynamic> stations = jsonDecode(response.body);
      for (var station in stations) {
        db.insertAirStation({
          "id": station['id'],
          "stationID": station['stationID'],
          "stateID": station['stateID'],
          "categoryID": station['categoryID'],
          "locationName": station['locationName'],
          "longitude": station['longitude'],
          "latitude": station['latitude'],
        });
      }
      print('data air station  has been save in sqlite');
    } else {
      throw Exception('Failed to load data');
    }
  }

  List<File> imageFiles = [];

  Future<void> pushDataTarballToMySQL() async {

    print('c');
    final Database db = await openDatabase('app.db');
    List<Map<String, dynamic>> records = await db.query('tbl_marine_tarball');
    print("ABC");
    //print(records);
    /*
    final url = Uri.parse('https://mmsv2.pstw.com.my/api/marine/api-push-data.php');

    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'action':'push-marine-tarball','data':records}),
    );

    if (response.statusCode == 200) {

      print("Data pushed successfully!");

      // push image

      Directory baseDir = await getApplicationDocumentsDirectory(); // or external dir
      String parentFolderPath = '${baseDir.path}/tarball'; // Change as needed

      Directory parentDir = Directory(parentFolderPath);
      if (!await parentDir.exists()) {
        print('Parent folder does not exist.');
        return;
      }

      // List all subdirectories
      List<FileSystemEntity> allEntities = parentDir.listSync();
      List<Directory> subfolders = allEntities
          .whereType<Directory>()
          .toList();

      for (var folder in subfolders) {
        List<FileSystemEntity> files = folder.listSync();

        for (var entity in files) {
          if (entity is File) {
            String ext = path.extension(entity.path).toLowerCase();
            if (['.jpg', '.jpeg', '.png'].contains(ext)) {
              await _uploadFile(entity, folderName: path.basename(folder.path));
            }
          }
        }

        // After processing all files, check if folder is empty and delete it
        if (folder.existsSync() && folder.listSync().isEmpty) {
          try {
            await folder.delete();
            setState(() => _log.add('Deleted empty folder: ${folder.path}'));
          } catch (e) {
            setState(() => _log.add('Failed to delete folder: ${folder.path} → $e'));
          }
        }

      }


      // remove data from sqlite
      await db.delete('tbl_marine_tarball'); // Clears all rows from the table
      print("Table 'tbl_marine_tarball' has been emptied.");

    } else {
      print("Error: ${response.body}");
    }*/
  }

  List<String> _log = [];

  Future<void> _uploadFile(File file, {required String folderName}) async {

    String fileName = path.basename(file.path);

    try {
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('https://mmsv2.pstw.com.my/upload-image-local.php'), // 🔁 change this
      );

      request.fields['folder'] = folderName; // send folder name as extra field
      request.files.add(await http.MultipartFile.fromPath(
        'image',
        file.path,
        filename: fileName,
        contentType: MediaType.parse(lookupMimeType(file.path) ?? 'application/octet-stream'),
      ));

      var response = await request.send();
      String responseBody = await response.stream.bytesToString();

      if (response.statusCode == 200 && responseBody.contains("Uploaded")) {
        await file.delete(); // ✅ delete after successful upload
        setState(() => _log.add('$fileName → Uploaded and deleted'));
      } else {
        setState(() => _log.add('$fileName → Upload failed: $responseBody'));
      }

    } catch (e) {
      setState(() => _log.add('Failed: $fileName → $e'));
    }
  }

  void _login() async {

    if ((_username!="")&&(_password!="")) {

      setState(() {
        _isBtnLogin = false;
      });

      if(isChecked) {
        box1.put('email',ct_username.text);
        box1.put('password',ct_password.text);
      }

      if (await isConnected()) {

        var client = http.Client();
        var response = await
        client.post(Uri.parse("https://mmsv2.pstw.com.my/api/api-post.php"), body: {
          "action": "login-user", "username": _username, "password": _password
        });


        var data = json.decode(response.body);

        if (data['status']=='success') {

          await db.insertUser({'fullName': data['fullName'],'email': _username, 'password': _password, 'userID':data['userID'],'levelID':data['levelID'],'departID':data['departID']}); // insert to local storage
          saveSession(_username,data['userID'],data['levelID'],data['departID'],data['fullName']);

          // load data to local server
          fetchAndSaveSampler();
          fetchAndSaveCategory();
          fetchAndSaveState();
          fetchAndSaveMarineStation();
          fetchAndSaveTarballStation();

          fetchAndSaveAirStation();
          // push data from local to server

          pushDataTarballToMySQL();

          Navigator.push(context, new MaterialPageRoute(
              builder: (BuildContext context) => new UserDashboard()),
          );


          /*
        if ((data['levelID']=='L5')&&(data['departID']=='D3')) { // technician marine

          Navigator.push(context, new MaterialPageRoute(
              builder: (BuildContext context) => new UserDashboard()),
          );
        }

        else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Invalid user!',
              style: TextStyle(color: Colors.white),),backgroundColor: Colors.black,),
          );
        }*/

          setState(() {
            _isBtnLogin = true;
          });
        }

        else {

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Invalid username and password!',
              style: TextStyle(color: Colors.white),),backgroundColor: Colors.red,),
          );

          setState(() {
            _isBtnLogin = true;
            _isErrorLogin = true;
            _isErrorNRID = false;
            _isErrorPassword = false;

            ct_username.clear();
            ct_password.clear();
          });
        }
      }

      else {
        print('Login success (offline)');
        // Try offline login
        final user = await db.getUser(_username, _password);
        if (user != null) {

          //print("Login success (offline)");
          //print('User Name: ${user['userID']}');

          saveSession(_username,user['userID'],user['levelID'],user['departID'],user['fullName']);

          Navigator.push(context, new MaterialPageRoute(
              builder: (BuildContext context) => new UserDashboard()),
          );

          setState(() {
            _isBtnLogin = true;
          });

        } else {

          print("No offline data for this user");

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Invalid username and password!',
              style: TextStyle(color: Colors.white),),backgroundColor: Colors.red,),
          );

          setState(() {
            _isBtnLogin = true;
            _isErrorLogin = true;
            _isErrorNRID = false;
            _isErrorPassword = false;

            ct_username.clear();
            ct_password.clear();
          });

        }
      }

    }
    else {
      setState(() {
        _isErrorLogin = false;
      });
    }

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      //backgroundColor: Colors.grey[300],
      body: SingleChildScrollView(
        child: Container(
          height: MediaQuery.of(context).size.height,
          width: MediaQuery.of(context).size.width,
          alignment: Alignment.center,
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircleAvatar(
                  backgroundColor: Colors.white,
                  radius: 55.0,
                  child: CircleAvatar(
                    backgroundColor: Colors.white,
                    backgroundImage: AssetImage('images/icon4.png'),
                    radius: 50.0,
                  ),
                ),
                Text(
                  'Integrated Environmental\nSolution',
                  style: TextStyle(fontSize: 20,fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                _isErrorLogin ? Column(
                  children: [
                    SizedBox(height: 5.0,),
                    Text('Email and password is not match',style: TextStyle(color: Colors.red),),
                  ],
                ) : SizedBox(height: 0.0,),
                SizedBox(
                  height: 20,
                ),
                Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 25.0),
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.grey[200],
                            border: Border.all(color: Colors.white),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.only(left: 20.0),
                            child: TextFormField(
                              controller: ct_username,
                              decoration: InputDecoration(
                                border: InputBorder.none,
                                hintText: 'Username',
                              ),
                              validator: (value) {
                                if (value!.isEmpty) {
                                  setState(() {
                                    _isErrorNRID = true;
                                  });
                                }
                                else {
                                  setState(() {
                                    _isErrorNRID = false;
                                  });
                                }
                              },
                              onSaved: (value) =>
                                  setState(() => _username = value!),
                            ),
                          ),
                        ),
                      ),
                      _isErrorNRID ? Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 45),
                        child: Text('Enter your username',
                          style: TextStyle(color: Colors.red),),
                      ) : SizedBox(height: 0.0,),
                      SizedBox(height: 20,),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 25),
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.grey[200],
                            border: Border.all(color: Colors.white),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.only(left: 20.0),
                            child: TextFormField(
                              controller: ct_password,
                              obscureText: _passwordObsecure,
                              decoration: InputDecoration(
                                border: InputBorder.none,
                                hintText: 'Password',
                                suffixIcon: IconButton(
                                  onPressed: () {
                                    setState(() {
                                      _passwordObsecure = !_passwordObsecure;
                                    });
                                  },
                                  icon: Icon(
                                    _passwordObsecure ?
                                    Icons.visibility_off
                                        : Icons.visibility,
                                  ),
                                ),
                              ),
                              validator: (value) {
                                if (value!.isEmpty) {
                                  setState(() {
                                    _isErrorPassword = true;
                                  });
                                }
                                else {
                                  setState(() {
                                    _isErrorPassword = false;
                                  });
                                }
                              },
                              onSaved: (value) =>
                                  setState(() => _password = value!),
                            ),
                          ),
                        ),
                      ),
                      _isErrorPassword ? Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 45),
                        child: Text('Enter your password',
                          style: TextStyle(color: Colors.red),),
                      ) : SizedBox(height: 0.0,),
                      SizedBox(height: 20,),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 25.0),
                        child: _isBtnLogin ? ElevatedButton(
                          onPressed: () {
                            if (_formKey.currentState!.validate()) {
                              _formKey.currentState!.save();
                              _login();
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue,
                          ),
                          child: Container(
                            padding: EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: Colors.blue,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Center(
                              child: Text(
                                'Login',
                                style: TextStyle(color: Colors.white,fontSize: 15),
                              ),
                            ),
                          ),
                        ): Center(
                          child: CircularProgressIndicator (
                            color: Colors.red,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 15,),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('Remember Me',
                      style: TextStyle(color: Colors.black),),
                    Checkbox(
                      value: isChecked,
                      onChanged: (value) {
                        isChecked = !isChecked;
                        setState(() {

                        });
                      },
                    ),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    TextButton(
                      onPressed: () {
                        Navigator.push(context, new MaterialPageRoute(
                            builder: (BuildContext context) => new ScreenRegister()),
                        );
                      },
                      style: TextButton.styleFrom(
                        minimumSize: Size.zero,
                        padding: EdgeInsets.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      child: Text('New user? Register now', style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                      ),),
                    ),
                    SizedBox(width: 10,),
                    Icon(
                      Icons.supervised_user_circle,
                    ),
                  ],
                ),
                SizedBox(
                  height: 10,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    TextButton(
                      onPressed: () {
                        Navigator.push(context, new MaterialPageRoute(
                            builder: (BuildContext context) => new ScreenForgotPassword()),
                        );
                      },
                      style: TextButton.styleFrom(
                        minimumSize: Size.zero,
                        padding: EdgeInsets.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      child: Text('Forgot password?', style: TextStyle(
                        color: Colors.red,
                        fontWeight: FontWeight.bold,
                      ),),
                    ),
                    SizedBox(width: 10,),
                    Icon(
                      Icons.password,
                    ),
                  ],
                ),
                SizedBox(height: 15,),
              ],
            ),
          ),
        ),
      ),
    );
  }
}