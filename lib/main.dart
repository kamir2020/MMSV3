import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:sqflite/sqflite.dart';
import 'package:upgrader/upgrader.dart';
import 'package:flutter/services.dart';
import 'package:path/path.dart' as ph;
import 'screen-login.dart';

class MyHttpoverrides extends HttpOverrides{
  @override
  HttpClient createHttpClient(SecurityContext? context){
    return super.createHttpClient(context)
      ..badCertificateCallback = (X509Certificate cert, String host, int port)=>true;
  }

}

void main() async{
  await Hive.initFlutter();
  WidgetsFlutterBinding.ensureInitialized();
  HttpOverrides.global=new MyHttpoverrides();
  runApp(MaterialApp(
    theme:
    ThemeData(primaryColor: Colors.red,),
    debugShowCheckedModeBanner: false,
    home: SplashScreen(),
  ));
}

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => new _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {

  @override
  void initState() {
    super.initState();
    //deleteDatabaseFile();
    startTime();
  }

  startTime() async {
    var duration = new Duration(seconds: 5);
    return new Timer(duration,route);
  }

  route() {
    Navigator.pushReplacement(context, MaterialPageRoute(
        builder: (context) => ScreenLogin()
    ));
  }

  Future<void> deleteDatabaseFile() async {
    String dbPath = await getDatabasesPath();
    String path = ph.join(dbPath, 'mms.db');

    await deleteDatabase(path);
    print('Database deleted');
  }

  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Scaffold(
        body: Stack (
          fit: StackFit.expand,
          children: <Widget>[
            Container(
              alignment: Alignment.topCenter,
              decoration: BoxDecoration(color: Colors.grey[200]),
            ),
            Column (
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Expanded (
                  flex: 2,
                  child: Container (
                    child: Column (
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        CircleAvatar(
                          backgroundColor: Colors.transparent,
                          radius: 65.0,
                          child: CircleAvatar(
                            backgroundColor: Colors.white,
                            backgroundImage: AssetImage('images/icon4.png'),
                            radius: 50.0,
                          ),
                        ),
                        Padding(padding: EdgeInsets.only(top: 10.0),
                        ),
                        Text(
                          "Integrated Environmental\nSolution",
                          style: TextStyle(color: Colors.black,fontSize: 24.0,
                            fontWeight: FontWeight.bold,),textAlign: TextAlign.center,
                        ),

                      ],
                    ),
                  ),
                ),
                Expanded(flex: 1,
                  child: Column (
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      CircularProgressIndicator(),
                      Padding(
                        padding: EdgeInsets.only(top: 20.0),
                      ),
                      Text("Site Monitoring App",style: TextStyle(color: Colors.black,
                          fontSize: 18.0,
                          fontWeight: FontWeight.bold)),
                    ],
                  ),)
              ],
            )
          ],
        ),
      ),
    );
  }
}