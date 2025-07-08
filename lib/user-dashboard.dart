import 'package:app_mms/screen-password.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'db_helper.dart';
import 'my-drawer-header.dart';
import 'package:app_mms/user-main.dart';
import 'screen-login.dart';
import 'user-air/air-sample.dart';
import 'user-marine/marine-manual.dart';
import 'user-marine/marine-investigate.dart';
import 'user-marine/marine-continuos.dart';
import 'user-river/river-sample.dart';
import 'user-river/river-investigate.dart';

void main() {
  runApp(MaterialApp(
    debugShowCheckedModeBanner: false,
    home: UserDashboard(),
  ));
}

class UserDashboard extends StatefulWidget {
  _UserDashboard createState() => _UserDashboard();
}

class _UserDashboard extends State<UserDashboard> {

  final scaffoldKey = GlobalKey<ScaffoldState>();
  late String _name = 'Dashboard';
  late Widget _container = UserMain();

  @override
  void initState() {
    super.initState();
    getSession();
  }

  Future<void> getSession() async {
    final prefs = await SharedPreferences.getInstance();
    print(prefs.getString('auth_id').toString());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey,
      appBar: AppBar(
        backgroundColor: Colors.blue,
        title: Text(_name),
      ),
      drawer: Drawer(
        child: SingleChildScrollView(
          child: Column(
            children: [
              MyHeaderDrawer(),
              ListTile(
                leading: Icon(Icons.dashboard),
                title: const Text('Dashboard'),
                onTap: () {
                  setState(() {
                    _container = UserMain();
                    _name = 'Dashboard';
                  });
                  Navigator.of(context).pop();
                },
              ),
              ExpansionTile(
                title: Text('Marine'),
                leading: Icon(Icons.add_business_rounded),
                childrenPadding: EdgeInsets.only(left: 60),
                children: [
                  ListTile(
                    title: Text('Continuous'),
                    onTap: () {
                      setState(() {
                        _container = MarineContinuos();
                        _name = 'MARINE - Continuos';
                      });
                      Navigator.of(context).pop();
                    },
                  ),
                  ListTile(
                    title: Text('Manual'),
                    onTap: () {
                      setState(() {
                        _name = 'MARINE - Manual';
                        _container = UserMarineManual();
                      });
                      Navigator.of(context).pop();
                    },
                  ),
                  ListTile(
                    title: Text('Investigative Study'),
                    onTap: () {
                      setState(() {
                        _name = 'MARINE - Investigative Study';
                        _container = MarineInvestigate();
                      });
                      Navigator.of(context).pop();
                    },
                  ),
                ],
              ),
              ExpansionTile(
                title: Text('River'),
                leading: Icon(Icons.water),
                childrenPadding: EdgeInsets.only(left: 60),
                children: [
                  ListTile(
                    title: Text('Manual Sampling'),
                    onTap: () {
                      setState(() {
                        _name = 'RIVER - Manual Sampling';
                        _container = UserRiverSample();
                      });
                      Navigator.of(context).pop();
                    },
                  ),
                  ListTile(
                    title: Text('Continuous'),
                    onTap: () {

                    },
                  ),
                  ListTile(
                    title: Text('Investigative Sampling (IS)'),
                    onTap: () {
                      setState(() {
                        _name = 'RIVER - Investigative Sampling (IS)';
                        _container = UserRiverInvestigate();
                      });
                      Navigator.of(context).pop();
                    },
                  ),
                ],
              ),
              ExpansionTile(
                title: Text('Air'),
                leading: Icon(Icons.air),
                childrenPadding: EdgeInsets.only(left: 60),
                children: [
                  ListTile(
                    title: Text('Manual Sampling'),
                    onTap: () {
                      setState(() {
                        _name = 'AIR - Manual Sampling';
                        _container = UserAirSample();
                      });
                      Navigator.of(context).pop();
                    },
                  ),
                  ListTile(
                    title: Text('Continuous'),
                    onTap: () {

                    },
                  ),
                  ListTile(
                    title: Text('Investigative Sampling'),
                    onTap: () {

                    },
                  ),
                ],
              ),
              ListTile(
                leading: Icon(Icons.settings),
                title: const Text('Setting'),
                onTap: () {
                  setState(() {
                    _name = 'Change Password';
                    _container = ScreenPassword();
                  });
                  Navigator.of(context).pop();
                },
              ),
              ListTile(
                leading: Icon(Icons.lock),
                title: const Text('Logout'),
                onTap: () {
                  clearSession();
                  setState(() {
                    Navigator.pushReplacement(context, MaterialPageRoute(
                        builder: (context) => ScreenLogin()
                    ));
                  });
                },
              ),
            ],
          ),
        ),
      ),
      body: Container(
        child: _container,
      ),
    );
  }

  Future<void> clearSession() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_id'); // Removes the specific key
    await prefs.remove('auth_group'); // Removes the specific key
    await prefs.remove('auth_depart'); // Removes the specific key
  }

}