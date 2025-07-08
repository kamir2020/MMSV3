import 'dart:convert';
import 'dart:io';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:flutter_email_sender/flutter_email_sender.dart';
import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server/gmail.dart';
import 'package:mime/mime.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../db_helper.dart';
import '../../object-class/local-object-location.dart';
import '../../object-class/local-object-state.dart';
import 'package:http/http.dart' as http;

class SFormImageRequest extends StatefulWidget {
  _SFormImageRequest createState() => _SFormImageRequest();
}

class _SFormImageRequest extends State<SFormImageRequest> {

  bool _isLocation = false;
  bool _isResult = false;

  late String? email;
  late String? _selectedStateID, _selectedStateName;
  late String? _selectedStationID,_selectedStationName;
  late int _selectedItemId=1;
  late String _type = '';
  Item? selectedItem;

  final TextEditingController _startDate = TextEditingController();
  final TextEditingController _endDate = TextEditingController();

  final _formImageRequest = GlobalKey<FormState>();

  List<Item> items = [
    Item(id: 1, categoryName: 'In-Situ Sampling'),
    Item(id: 2, categoryName: 'Tarball Sampling'),
    //Item(id: 3, categoryName: 'Reports'),
  ];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _loadState();
    _getProfile();
  }

  void _getProfile() async {
    final prefs = await SharedPreferences.getInstance();

    setState(() {
      email = prefs.get("email").toString();
    });

  }

  Future<void> chooseStartDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        _startDate.text = "${picked.toLocal()}".split(' ')[0]; // yyyy-MM-dd
      });
    }
  }

  Future<void> chooseEndDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        _endDate.text = "${picked.toLocal()}".split(' ')[0]; // yyyy-MM-dd
      });
    }
  }

  List<localState> state1 = [];
  localState? selectedLocalState;

  Future<void> _loadState() async {
    final data = await DBHelper.getState();
    setState(() {
      state1 = data;
    });
  }

  List<localLocation> location1 = [];
  localLocation? selectedLocalLocation;

  Future<void> _loadLocation(int? id, String? stateID) async {

    if (id==1) {  // in-situ sampling
      print('in-situ');
      final data = await DBHelper.getLocationMarine(stateID,'');

      setState(() {
        location1 = data;
        _isLocation = true;
      });

    }
    else if (id==2) { //
      print('tarball');// tarball sampling
      final data = await DBHelper.getLocation(stateID,'');

      setState(() {
        location1 = data;
        _isLocation = true;
      });
    }
  }


  Future<File> downloadImage(String imageUrl) async {
    final response = await http.get(Uri.parse(imageUrl));
    if (response.statusCode == 200) {
      final tempDir = await getTemporaryDirectory();
      final fileName = path.basename(imageUrl);
      final file = File('${tempDir.path}/$fileName');
      await file.writeAsBytes(response.bodyBytes);
      return file;
    } else {
      throw Exception('Failed to download image');
    }
  }

  Future<List<String>> fetchImageUrls(String folder, String keyword) async {
    final url = 'https://mmsv2.pstw.com.my/request-image.php?folder='+folder+'&keyword='+keyword;
    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      return List<String>.from(jsonDecode(response.body));
    }
    return [];
  }

  Future<List<File>> downloadImages(List<String> urls) async {
    final directory = await getApplicationDocumentsDirectory();
    List<File> files = [];

    for (String url in urls) {
      try {
        final response = await http.get(Uri.parse(url));
        if (response.statusCode == 200) {
          final filename = url.split('/').last;
          final file = File('${directory.path}/$filename');
          await file.writeAsBytes(response.bodyBytes);
          files.add(file);
        }
      } catch (e) {
        print('Download error: $e');
      }
    }
    return files;
  }

  Future<void> sendEmail(List<File> attachments) async {

    final username = 'pstwitdept@gmail.com';
    final password = 'orfovnkgysytzseo'; // Use App Password if using Gmail

    final smtpServer = gmail(username, password);

    final message = Message()
      ..from = Address('pstwitdept@gmail.com', 'MMS-Image Request')
      ..recipients.add(email!)
      ..subject = 'Filtered Images Attached'
      ..text = 'Please find the filtered images attached.'
      ..attachments = attachments.map((f) => FileAttachment(f)).toList();

    try {
      final sendReport = await send(message, smtpServer);
      print('Email send');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Email has been sent")),
      );
    } catch (e) {
      print('Email error');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Email failure.",),backgroundColor: Colors.red,),
      );
    }
  }

  Future<void> handleSend(String folder, String keyword) async {
    final urls = await fetchImageUrls(folder, keyword);
    final files = await downloadImages(urls);
    if (files.isNotEmpty) {
      await sendEmail(files);
    } else {
      print('No matching images found.');
    }
  }


  Widget buildForm() {
    return Form(
      key: _formImageRequest,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /*
        Text('Keywords',style: TextStyle(fontSize: 15),),
        SizedBox(height: 5.0,),
        TextFormField(
          decoration: InputDecoration(
            hintText: 'Search...',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(15.0)),
          ),
        ),
        SizedBox(height: 10.0,),*/

          Text('Photo list'),
          SizedBox(height: 5.0,),
          DropdownButtonFormField<Item>(
            decoration: InputDecoration(
              contentPadding: EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10.0),
              border: OutlineInputBorder(),
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
                _selectedItemId = selectedItem!.id;

                _isLocation = false;
                selectedLocalState = null;

                print('Selected ID: ${selectedItem!.id}');
                print('Selected Name: ${selectedItem!.categoryName}');

              });
            },
            validator: (value) => value == null ? 'Please select an category' : null,
          ),
          SizedBox(height: 10.0,),

          Text('Start date: '),
          SizedBox(height: 5.0,),
          TextFormField(
            controller: _startDate,
            decoration: InputDecoration(
              //labelText: 'Select Date',
              suffixIcon: Icon(Icons.calendar_today),
              border: OutlineInputBorder(),
            ),
            readOnly: true,
            onTap: () => chooseStartDate(context),
          ),
          SizedBox(height: 10.0,),

          Text('End date: '),
          SizedBox(height: 5.0,),
          TextFormField(
            controller: _endDate,
            decoration: InputDecoration(
              //labelText: 'End Date',
              suffixIcon: Icon(Icons.calendar_today),
              border: OutlineInputBorder(),
            ),
            readOnly: true,
            onTap: () => chooseEndDate(context),
          ),
          SizedBox(height: 10.0,),

          Text('State'),
          SizedBox(height: 5.0,),
          Row(
            children: [
              Expanded(
                child: DropdownSearch<localState>(
                  items: state1,
                  selectedItem: selectedLocalState,
                  itemAsString: (localState u) => "${u.stateName}", // optional
                  popupProps: PopupProps.menu(showSearchBox: true),
                  dropdownDecoratorProps: DropDownDecoratorProps(
                    dropdownSearchDecoration: InputDecoration(
                      //labelText: "Select state",
                      border: OutlineInputBorder(),
                    ),
                  ),
                  onChanged: (localState? value) {
                    setState(() {
                      selectedLocalState = value;
                      _selectedStateID = selectedLocalState!.stateID;
                      _selectedStateName = selectedLocalState!.stateName;
                      _loadLocation(_selectedItemId,_selectedStateID);
                    });
                    if (value != null) {
                      print("Selected ID: ${value.stateID}, Name: ${value.stateName}");
                    }
                  },
                ),
              ),
            ],
          ),
          SizedBox(height: 10.0,),

          _isLocation ? Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Location'),
              SizedBox(height: 5.0,),
              DropdownSearch<localLocation>(
                items: location1,
                selectedItem: selectedLocalLocation,
                itemAsString: (localLocation u) => "${u.stationID} - ${u.locationName}", // optional
                popupProps: PopupProps.menu(
                  showSearchBox: true,
                  emptyBuilder: (context, searchEntry) => Center(
                    child: Text("No records found"),
                  ),
                ),
                dropdownDecoratorProps: DropDownDecoratorProps(
                  dropdownSearchDecoration: InputDecoration(
                    //labelText: "Select location",
                    border: OutlineInputBorder(),
                  ),
                ),

                onChanged: (localLocation? value) {
                  setState(() {
                    selectedLocalLocation = value;
                  });
                  if (value != null) {
                    print("Name: ${value.locationName}");

                    _selectedStationID = selectedLocalLocation!.stationID;
                    _selectedStationName = selectedLocalLocation!.locationName;
                  }
                },
              ),
            ],
          ):SizedBox(height: 0.0,),

          SizedBox(height: 10.0,),
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue
                  ),
                  onPressed: () {

                  },
                  child: Text('Reset',
                    style: TextStyle(fontSize: 15,color: Colors.white,fontWeight: FontWeight.bold),),
                ),
              ),
              SizedBox(width: 10.0,),
              Expanded(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue
                  ),
                  onPressed: () {
                      if (_formImageRequest.currentState!.validate()) {
                        _formImageRequest.currentState!.save();
                        _searchImageFromServer();
                      }
                  },
                  child: Text('Search (PSTW)',
                    style: TextStyle(fontSize: 15,color: Colors.white,fontWeight: FontWeight.bold),),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget buildResult() {
    return SizedBox(
      height: 500,
      child: FutureBuilder<List<Map<String, dynamic>>>(
        future: _retrieveImageFromServer(),
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
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {
                              if (_selectedItemId==1) {
                                String folder = "images/marine/manual_in_situ/"+item['stationID'];
                                handleSend(folder,item['stationID']);
                              }

                              else if (_selectedItemId==2) {
                                String folder = "images/marine/manual_tarball/"+item['stationID'];
                                handleSend(folder,item['stationID']);
                              }
                            },
                            child: Text('Send Email'),
                          ),
                        ),
                        SizedBox(width: 10.0,),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {

                            },
                            child: Text('Download'),
                          ),
                        ),
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
        children: [
          Text('IMAGE REQUEST',
            style: TextStyle(fontSize: 20,fontWeight: FontWeight.bold),),
          buildForm(),
          _isResult ? buildResult() : Text('No.. search result'),
        ],
      ),
    );
  }

  void _searchImageFromServer() {
    setState(() {
      _isResult = true;
    });
  }

  List<dynamic> dataList = [];
  bool isLoading = true;

  Future<List<Map<String, dynamic>>> _retrieveImageFromServer() async {

    final response = await http.get(Uri.parse('https://mmsv2.pstw.com.my/api/marine/api-get-marine.php?action=image-request&id='+_selectedItemId.toString()+'&stationID='+_selectedStationID!));

    if (response.statusCode == 200) {
      List data = json.decode(response.body);
      return List<Map<String, dynamic>>.from(data);
    } else {
      throw Exception('Failed to load data');
    }

  }

}

class Item {
  final int id;
  final String categoryName;

  Item({required this.id, required this.categoryName});

  @override
  String toString() => categoryName; // Optional: for debugging or display
}