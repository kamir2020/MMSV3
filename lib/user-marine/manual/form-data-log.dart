import 'dart:convert';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:sqflite/sqflite.dart';

import '../../db_helper.dart';

class SFormDataLog extends StatefulWidget {
  _SFormDataLog createState() => _SFormDataLog();
}

class _SFormDataLog extends State<SFormDataLog> {

  late String _type = '';
  late int _selectedItem = 0;
  bool connectionStatus = true;

  Item? selectedItem;

  List<Item> items = [
    Item(id: 1, categoryName: 'In-Situ Sampling'),
    Item(id: 2, categoryName: 'Tarball Sampling'),
    Item(id: 3, categoryName: 'Reports'),
  ];

  final db = DBHelper();

  @override
  void initState() {
    super.initState();
    _checkInternet();
  }

  Future<void> _checkInternet() async {
    var connectivityResult = await Connectivity().checkConnectivity();

    if (connectivityResult == ConnectivityResult.none) {
      setState(() {
        connectionStatus = false;
      });
      return;
    }

    // Check actual internet access
    try {
      final result = await http.get(Uri.parse('https://google.com')).timeout(Duration(seconds: 5));
      if (result.statusCode == 200) {
        setState(() {
          connectionStatus = true;
        });
      } else {
        setState(() {
          connectionStatus = false;
        });
      }
    } catch (e) {
      setState(() {
        connectionStatus = false;
      });
    }
  }

  List<dynamic> dataList = [];
  bool isLoading = true;

  Future<List<Map<String, dynamic>>> fetchDataInSituFromServer() async {

    final response = await http.get(Uri.parse('https://mmsv2.pstw.com.my/api/marine/api-get-marine.php?action=display-log-in-situ'));
    if (response.statusCode == 200) {
      List data = json.decode(response.body);
      return List<Map<String, dynamic>>.from(data);
    } else {
      throw Exception('Failed to load data');
    }

  }

  Future<List<Map<String, dynamic>>> fetchDataInSituFromLocal() async {
    final db = await DBHelper.initDb();
    final result = await db.rawQuery('''
    SELECT tbl_marine_insitu_sampling.stationID,tbl_marine_insitu_sampling.timestamp,
    tbl_marine_station.locationName
    FROM tbl_marine_insitu_sampling
      INNER JOIN tbl_marine_station ON tbl_marine_insitu_sampling.stationID = tbl_marine_station.stationID
        ORDER BY tbl_marine_insitu_sampling.timestamp DESC
  ''');
    return result;
    //return await db.query('tbl_marine_tarball', orderBy: 'id DESC');
  }


  Future<List<Map<String, dynamic>>> fetchDataTarballFromServer() async {

    final response = await http.get(Uri.parse('https://mmsv2.pstw.com.my/api/marine/api-get-marine.php?action=display-log-tarball'));
    if (response.statusCode == 200) {
      List data = json.decode(response.body);
      return List<Map<String, dynamic>>.from(data);
    } else {
      throw Exception('Failed to load data');
    }

  }

  Future<List<Map<String, dynamic>>> fetchDataTarballFromLocal() async {
    final db = await DBHelper.initDb();
    final result = await db.rawQuery('''
    SELECT tbl_marine_tarball.stationID,tbl_marine_tarball.timestamp,
    tbl_tarball_station.locationName
    FROM tbl_marine_tarball
      INNER JOIN tbl_tarball_station ON tbl_marine_tarball.stationID = tbl_tarball_station.stationID
        ORDER BY tbl_marine_tarball.timestamp DESC
  ''');
    return result;
    //return await db.query('tbl_marine_tarball', orderBy: 'id DESC');
  }


  Widget buildFromServerInSitu() {
    return SizedBox(
      height: 500,
      child: FutureBuilder<List<Map<String, dynamic>>>(
        future: fetchDataInSituFromServer(),
        builder: (context,snapshot) {

          if (snapshot.connectionState == ConnectionState.waiting)
            return Center(child: CircularProgressIndicator());
          if (snapshot.hasError)
            return Center(child: Text('Error: ${snapshot.error}'));
          if (!snapshot.hasData || snapshot.data!.isEmpty)
            return Center(child: Text('No data found'));

          final data = snapshot.data!;
          return ListView.builder(
            itemCount: data.length,
            itemBuilder: (context, index) {
              final item = data[index];
              return Padding(
                padding: EdgeInsets.all(5.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(item['stationID'] +" - "+ item['locationName']),
                    SizedBox(height: 5.0,),
                    Text(item['timestamp'].toString(),style: TextStyle(fontWeight: FontWeight.bold),),
                    SizedBox(height: 5.0,),
                    Row(
                      children: [
                        Text('Status :'),
                        Text('Submitted to Server',
                          style: TextStyle(fontWeight: FontWeight.bold),),
                      ],
                    ),
                    SizedBox(height: 10.0,),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget buildFromLocalInSitu() {
    return SizedBox(
      height: 500,
      child: FutureBuilder<List<Map<String, dynamic>>>(
        future: fetchDataInSituFromLocal(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting)
            return Center(child: CircularProgressIndicator());
          if (snapshot.hasError)
            return Center(child: Text('Error: ${snapshot.error}'));
          if (!snapshot.hasData || snapshot.data!.isEmpty)
            return Center(child: Text('No data found'));

          final data = snapshot.data!;
          return ListView.builder(
            itemCount: data.length,
            itemBuilder: (context, index) {
              final item = data[index];
              return Padding(
                padding: EdgeInsets.all(5.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(item['stationID'] +" - "+ item['locationName']),
                    SizedBox(height: 5.0,),
                    Text(item['timestamp'].toString(),style: TextStyle(fontWeight: FontWeight.bold),),
                    SizedBox(height: 5.0,),
                    Row(
                      children: [
                        Text('Status :'),
                        Text('Submitted to Local',
                          style: TextStyle(fontWeight: FontWeight.bold,color: Colors.red),),
                      ],
                    ),
                    SizedBox(height: 10.0,),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget buildFromServerTarball() {
    return SizedBox(
      height: 500,
      child: FutureBuilder<List<Map<String, dynamic>>>(
        future: fetchDataTarballFromServer(),
        builder: (context,snapshot) {

          if (snapshot.connectionState == ConnectionState.waiting)
            return Center(child: CircularProgressIndicator());
          if (snapshot.hasError)
            return Center(child: Text('Error: ${snapshot.error}'));
          if (!snapshot.hasData || snapshot.data!.isEmpty)
            return Center(child: Text('No data found'));

          final data = snapshot.data!;
          return ListView.builder(
            itemCount: data.length,
            itemBuilder: (context, index) {
              final item = data[index];
              return Padding(
                padding: EdgeInsets.all(5.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(item['stationID'] +" - "+ item['locationName']),
                    SizedBox(height: 5.0,),
                    Text(item['timestamp'].toString(),style: TextStyle(fontWeight: FontWeight.bold),),
                    SizedBox(height: 5.0,),
                    Row(
                      children: [
                        Text('Status :'),
                        Text('Submitted to Server',
                          style: TextStyle(fontWeight: FontWeight.bold),),
                      ],
                    ),
                    SizedBox(height: 10.0,),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget buildFromLocalTarball() {
    return SizedBox(
      height: 500,
      child: FutureBuilder<List<Map<String, dynamic>>>(
        future: fetchDataTarballFromLocal(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting)
            return Center(child: CircularProgressIndicator());
          if (snapshot.hasError)
            return Center(child: Text('Error: ${snapshot.error}'));
          if (!snapshot.hasData || snapshot.data!.isEmpty)
            return Center(child: Text('No data found'));

          final data = snapshot.data!;
          return ListView.builder(
            itemCount: data.length,
            itemBuilder: (context, index) {
              final item = data[index];
              return Padding(
                padding: EdgeInsets.all(5.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(item['stationID'] +" - "+ item['locationName']),
                    SizedBox(height: 5.0,),
                    Text(item['timestamp'].toString(),style: TextStyle(fontWeight: FontWeight.bold),),
                    SizedBox(height: 5.0,),
                    Row(
                      children: [
                        Text('Status :'),
                        Text('Submitted to Local',
                          style: TextStyle(fontWeight: FontWeight.bold,color: Colors.red),),
                      ],
                    ),
                    SizedBox(height: 10.0,),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('DATA LOG STATUS',
            style: TextStyle(fontSize: 20,fontWeight: FontWeight.bold),),
          SizedBox(height: 10.0,),

          Text('Keywords',style: TextStyle(fontSize: 15),),
          SizedBox(height: 5.0,),
          TextFormField(
            decoration: InputDecoration(
              hintText: 'Search...',
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(15.0)),
            ),
          ),
          SizedBox(height: 10.0,),

          Text('Category list'),
          SizedBox(height: 5.0,),
          DropdownButtonFormField<Item>(
            decoration: InputDecoration(
              contentPadding: EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10.0),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(15.0)),
            ),
            items: items.map((item) {
              return DropdownMenuItem<Item>(
                value: item,
                child: Text(item.categoryName),
              );
            }).toList(),
            onChanged: (value) {
              setState(() {
                selectedItem = value;
                _selectedItem = selectedItem!.id;
                print('Selected ID: ${selectedItem!.id}');
                print('Selected Name: ${selectedItem!.categoryName}');

              });
            },
            validator: (value) => value == null ? 'Please select an category' : null,
          ),
          SizedBox(height: 10.0,),
          Text('Searching Result...',
            style: TextStyle(fontSize: 18,fontWeight: FontWeight.bold),),

          Divider(),
          if (_selectedItem == 1) ... [
            connectionStatus ? buildFromServerInSitu() : buildFromLocalInSitu(),
          ]

          else if (_selectedItem == 2) ... [
            connectionStatus ? buildFromServerTarball() : buildFromLocalTarball(),
          ]


        ],
      ),
    );
  }

}

class Item {
  final int id;
  final String categoryName;

  Item({required this.id, required this.categoryName});

  @override
  String toString() => categoryName; // Optional: for debugging or display
}