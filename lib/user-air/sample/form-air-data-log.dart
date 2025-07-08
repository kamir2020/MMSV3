import 'dart:convert';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../../db_helper.dart';

class SFormAirDataLog extends StatefulWidget {
  _SFormAirDataLog createState() => _SFormAirDataLog();
}

class _SFormAirDataLog extends State<SFormAirDataLog> {

  late String _type = '';
  late int _selectedItem = 0;
  bool connectionStatus = true;

  Item? selectedItem;

  List<Item> items = [
    Item(id: 1, categoryName: 'Sampling'),
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

  Future<List<Map<String, dynamic>>> fetchDataAirFromServer() async {

    final response = await http.get(Uri.parse('https://mmsv2.pstw.com.my/api/air/api-get-air.php?action=display-log-air'));
    if (response.statusCode == 200) {
      List data = json.decode(response.body);
      return List<Map<String, dynamic>>.from(data);
    } else {
      throw Exception('Failed to load data');
    }

  }

  Future<List<Map<String, dynamic>>> fetchDataAirFromLocal() async {
    final db = await DBHelper.initDb();
    final result = await db.rawQuery('''
    SELECT tbl_air_install.stationID,tbl_air_install.timestamp,
    tbl_air_install.statusID,
    tbl_air_station.locationName
    FROM tbl_air_install
      INNER JOIN tbl_air_station ON tbl_air_install.stationID = tbl_air_station.stationID
        ORDER BY tbl_air_install.timestamp DESC
  ''');
    return result;
    //return await db.query('tbl_marine_tarball', orderBy: 'id DESC');
  }


  Widget buildFromServerAir() {
    return SizedBox(
      height: 500,
      child: FutureBuilder<List<Map<String, dynamic>>>(
        future: fetchDataAirFromServer(),
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
                        Text('Status : '),
                        if (item['statusID']=='L1') ... [
                          Text('PSTW Server (Pending)', style: TextStyle(color: Colors.green),),
                        ]
                        else if (item['statusID']=='L2') ... [
                          Text('PSTW Server (Failure)', style: TextStyle(color: Colors.red),),
                        ]
                        else if (item['statusID']=='L3') ... [
                            Text('PSTW Server (Success)', style: TextStyle(color: Colors.blue),),
                        ],
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

  Widget buildFromLocalAir() {
    return SizedBox(
      height: 500,
      child: FutureBuilder<List<Map<String, dynamic>>>(
        future: fetchDataAirFromLocal(),
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
                        Text('Status : '),
                        if (item['statusID']=='L1') ... [
                          Text('Local Server (Pending)', style: TextStyle(color: Colors.green,fontWeight: FontWeight.bold),),
                        ]
                        else if (item['statusID']=='L2') ... [
                          Text('Local Server (Failure)', style: TextStyle(color: Colors.red,fontWeight: FontWeight.bold),),
                        ]
                        else if (item['statusID']=='L3') ... [
                            Text('Local Server (Success)', style: TextStyle(color: Colors.blue,fontWeight: FontWeight.bold),),
                        ],
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
            connectionStatus ? buildFromServerAir() : buildFromLocalAir(),
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