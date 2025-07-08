import 'dart:async';
import 'dart:io';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:image/image.dart' as img;
import 'package:image_picker/image_picker.dart';
import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:simple_barcode_scanner/simple_barcode_scanner.dart';
import 'package:usb_serial/usb_serial.dart';
import '../../object-state.dart';
import 'package:app_mms/object-station-river.dart';
import 'dart:typed_data';
import 'package:path/path.dart' as path;

class SFormRiverSample extends StatefulWidget {
  _SFormRiverSample createState() => _SFormRiverSample();
}

class _SFormRiverSample extends State<SFormRiverSample> {

  bool _isLocation = false;

  TextEditingController _stationID = TextEditingController();
  TextEditingController _sampleDate = TextEditingController();
  TextEditingController _sampleTime = TextEditingController();
  TextEditingController _stateName = TextEditingController();
  TextEditingController _basinName = TextEditingController();
  TextEditingController _riverName = TextEditingController();
  TextEditingController _latitude = TextEditingController();
  TextEditingController _longitude = TextEditingController();
  TextEditingController _barcode = TextEditingController();
  TextEditingController _sondeID = TextEditingController();

  TextEditingController _currentLatitude = TextEditingController();
  TextEditingController _currentLongitude = TextEditingController();

  final TextEditingController _dateCapture = TextEditingController();
  final TextEditingController _timeCapture = TextEditingController();

  final TextEditingController _firstSamplerName = TextEditingController();

  late String? stationID;
  late String? selectedStateName;
  late String? firstSampleName, secondSampleName;
  late String? sampleDate, sampleTime;
  late String? dateCapture, timeCapture;
  late String? riverName, basinName;
  late String? latitude, longitude;
  late String? getLatitude, getLongitude;
  late String? barcode;
  late String _type = '';
  late String _weather = '';
  late String result = '';
  late String? eventRemark, labRemark;
  late String? timestampResult1,timestampResult2;

  bool _form1 = true;
  bool _form2 = false;
  bool _form3 = false;
  bool _form4 = false;

  final _formRiverSample1 = GlobalKey<FormState>();
  final _formRiverSample2 = GlobalKey<FormState>();
  final _formRiverSample3 = GlobalKey<FormState>();
  final _formRiverSample4 = GlobalKey<FormState>();

  List<dynamic> _riverStationList = [];
  Map<String, dynamic>? _selectedStation;

  List<UsbDevice> devices = [];
  UsbPort? port;
  bool isConnected = false;
  StreamSubscription<Uint8List>? inputStreamSubscription;
  late String rawData = "";

  // Sensor data variables
  late String sondeID = '';
  late String doValue1 = "--"; // Oxygen concentration
  late String doValue2 = "--"; // Oxygen saturation
  late String pH = "--";
  late String conductivity = "--";
  late String salinity = "--";
  late String ec = "--"; // Electrical conductivity
  late String temperature = "--";
  late String flowRate = "--";
  late String totalDissolve = "--";
  late String totalSuspended = "--";
  late String tds = "--";
  late String turbidity = "--";
  late String tss = "--";
  late String battery = "--";

  String? stateID;
  StationRiver? selectedStation;
  States? selectedState;

  @override
  void initState() {
    super.initState();
    //_fetchStation();
    _getProfile();

    var now = DateTime.now();
    var formatter = DateFormat('yyyy-MM-dd');
    String formattedDate = formatter.format(now);
    _sampleDate.text = formattedDate;
    _dateCapture.text = formattedDate;


    int timestamp = DateTime.now().millisecondsSinceEpoch;
    DateTime date = DateTime.fromMillisecondsSinceEpoch(timestamp);

    String result1 = DateFormat('yyyy-MM-dd HH:mm:ss').format(date);
    String result2 = DateFormat('yyyyMMdd_HHmmss').format(date);

    String formattedTime = now.hour.toString()+":"+now.minute.toString()+":"+now.second.toString();

    setState(() {
      _sampleTime.text = formattedTime;
      _timeCapture.text = formattedTime;

      timestampResult1 = result1;
      timestampResult2 = result2;
    });

  }

  Future<List<States>> fetchStates() async {
    final response = await http.get(Uri.parse("https://mmsv2.pstw.com.my/api/river/api-get-river.php?action=river-state"));
    if (response.statusCode == 200) {

      final List jsonList = json.decode(response.body);
      return jsonList.map((json) => States.fromJson(json)).toList();

    } else {
      throw Exception('Failed to load items');
    }
  }


  Future<List<StationRiver>> fetchItems() async {
    final response = await http.get(Uri.parse("https://mmsv2.pstw.com.my/api/river/api-get-river.php?action=river-station&stateID="+stateID!));
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      print(data);

      if (data['status']=='success') {

        final List jsonList = data['data'];
        return jsonList.map((json) => StationRiver.fromJson(json)).toList();
      }
      else {
        return [];
      }
    } else {
      throw Exception('Failed to load items');
    }
  }

  Future<void> _getProfile() async {
    final prefs = await SharedPreferences.getInstance();
    //print(prefs.getString('auth_id').toString());

    String url = "https://mmsv2.pstw.com.my/api/api-get.php?action=getProfile&userID="+prefs.getString('auth_id').toString();
    final response = await http.get(Uri.parse(url));
    var responseData = json.decode(response.body);

    setState(() {
      _firstSamplerName.text = responseData['fullname'];
    });

  }

  Future<void> _checkPermissionsAndFetchLocation(BuildContext context) async {
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {

      }
    }

    if (permission == LocationPermission.deniedForever) {

    }

    Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
    setState(() {
      _currentLatitude.text = position.latitude.toString();
      _currentLongitude.text = position.longitude.toString();
    });

    print("Latitude: ${position.latitude}, Longitude: ${position.longitude}");
  }

  final ImagePicker _picker1 = ImagePicker();
  File? _image1;

  Future<void> _takePicture1() async {
    try {
      final XFile? photo = await _picker1.pickImage(
        source: ImageSource.camera,
        maxWidth: 500,
        maxHeight: 200,
        imageQuality: 80,
      );

      if (photo != null) {

        final bytes = await photo.readAsBytes();
        final decodedImage = img.decodeImage(bytes);

        // drawing text
        img.Image? originalImage = img.decodeImage(bytes);

        if (decodedImage != null && decodedImage.width > decodedImage.height) {

          // save string
          img.drawString(originalImage!, img.arial_14, 2, 12, timestampResult1!);

          // Save string to file
          final tempDir = await getTemporaryDirectory();
          final filePath = path.join(tempDir.path, 'edited_${path.basename(photo.path)}');
          final editedFile = File(filePath)..writeAsBytesSync(img.encodeJpg(originalImage));

          setState(() {
            _image1 = File(photo.path);
          });
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Please take a picture in landscape (horizontal) image.")),
          );
        }

      }
    } catch (e) {
      print("Error while capturing image: $e");
    }
  }

  Future<void> _takePicture1a(ImageSource source) async {
    try {
      final XFile? photo = await _picker1.pickImage(source: source);

      if (photo != null) {
        setState(() {
          _image1 = File(photo.path);
        });
      }
    } catch (e) {
      print("Error while capturing image: $e");
    }
  }

  // Function to delete the picture
  Future<void> _deletePicture1() async {
    if (_image1 != null) {
      try {
        await _image1!.delete();
        setState(() {
          _image1 = null; // Reset the image state
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Picture deleted successfully!")),
        );
      } catch (e) {
        print("Error while deleting the picture: $e");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Failed to delete picture!")),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("No picture to delete!")),
      );
    }
  }

  Widget _buildForm1() {
    return Form(
      key: _formRiverSample1,
      child: Column(
        children: [
          Divider(),
          Center(
            child: Text(':: Information Details :: ',style: TextStyle(fontSize: 20,fontWeight: FontWeight.bold),),
          ),
          Divider(),
          SizedBox(height: 10.0,),
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  readOnly: true,
                  controller: _firstSamplerName,
                  decoration: InputDecoration(
                    labelText: '1st Sampler',
                    contentPadding: EdgeInsets.fromLTRB(10.0, 10.0, 20.0, 10.0),
                    border: OutlineInputBorder(),
                  ),
                  onSaved: (value) => setState(() => firstSampleName = value!),
                  validator: (value) {
                    if (value!.isEmpty) {
                      return '1st Sampler';
                    }
                  },
                ),
              ),
            ],
          ),
          SizedBox(height: 10.0,),
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  decoration: InputDecoration(
                    labelText: '2nd Sampler',
                    contentPadding: EdgeInsets.fromLTRB(10.0, 10.0, 20.0, 10.0),
                    border: OutlineInputBorder(),
                  ),
                  onSaved: (value) => setState(() => secondSampleName = value!),
                  validator: (value) {
                    if (value!.isEmpty) {
                      return '2nd Sampler';
                    }
                  },
                ),
              ),
            ],
          ),
          SizedBox(height: 10.0,),
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: _sampleDate,
                  readOnly: true,
                  decoration: InputDecoration(
                    labelText: 'Date',
                    contentPadding: EdgeInsets.fromLTRB(10.0, 10.0, 20.0, 10.0),
                    border: OutlineInputBorder(),
                  ),
                  onSaved: (value) => setState(() => sampleDate = value!),
                ),
              ),
            ],
          ),
          SizedBox(height: 10.0,),
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  readOnly: true,
                  controller: _sampleTime,
                  decoration: InputDecoration(
                    labelText: 'Time',
                    contentPadding: EdgeInsets.fromLTRB(10.0, 10.0, 20.0, 10.0),
                    border: OutlineInputBorder(),
                  ),
                  onSaved: (value) => setState(() => sampleTime = value!),
                ),
              ),
            ],
          ),
          SizedBox(height: 10.0,),
          Row(
            children: [
              Expanded(
                child: DropdownButtonFormField(
                  decoration: InputDecoration(
                    labelText: 'Type',
                    contentPadding: EdgeInsets.fromLTRB(10.0, 10.0, 20.0, 10.0),
                    border: OutlineInputBorder(),
                  ),
                  value: _type.isNotEmpty ? _type : null,
                  items: <String>['Schedule', 'Triennial']
                      .map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _type = value.toString();
                    });
                  },
                  validator: (value) =>
                  value!.isEmpty ? 'type is required' : null,
                ),
              ),
            ],
          ),
          SizedBox(height: 10.0,),
          Row(
            children: [
              Expanded(
                child: DropdownSearch<States>(
                  asyncItems: (filter) => fetchStates(),
                  itemAsString: (States p) => "${p.stateID} - ${p.stateName}", // show product_name only
                  popupProps: PopupProps.menu(
                    showSearchBox: true,
                  ),
                  dropdownDecoratorProps: DropDownDecoratorProps(
                    dropdownSearchDecoration: InputDecoration(
                      labelText: "Choose state",
                      border: OutlineInputBorder(),
                    ),
                  ),
                  onChanged: (States? value) {

                    setState(() {
                      selectedState = value;

                      stateID = selectedState!.stateID;
                      selectedStateName = selectedState!.stateName;

                      print(stateID);
                      _isLocation = true;

                    });
                    //print("Selected: ${value?.stateID}, State: ${value?.stateName}");
                    //print(_selectedStationID);
                  },
                ),
              )
            ],
          ),
          SizedBox(height: 10.0,),
          _isLocation ? Column(
            children: [
              SizedBox(
                height: 10,
              ),
              Row(
                children: [
                  Expanded(
                    child: DropdownSearch<StationRiver>(
                      asyncItems: (filter) => fetchItems(),
                      itemAsString: (StationRiver p) => "${p.stationID} - ${p.riverName}", // show product_name only
                      popupProps: PopupProps.menu(
                        showSearchBox: true,
                        emptyBuilder: (context, searchEntry) => Center(
                          child: Text("No records found"),
                        ),
                      ),
                      dropdownDecoratorProps: DropDownDecoratorProps(
                        dropdownSearchDecoration: InputDecoration(
                          labelText: "Choose station",
                          border: OutlineInputBorder(),
                        ),
                      ),
                      onChanged: (StationRiver? value) {

                        setState(() {
                          selectedStation = value;
                        });

                        _basinName.text = selectedStation!.basinName;
                        _riverName.text = selectedStation!.riverName;
                        _latitude.text = selectedStation!.latitude;
                        _longitude.text = selectedStation!.longitude;

                        _stationID.text = selectedStation!.stationID;
                        stationID = selectedStation!.stationID;

                      },
                    ),
                  )
                ],
              ),
            ],
          ) : SizedBox(),
          SizedBox(height: 10.0,),
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  readOnly: true,
                  controller: _basinName,
                  decoration: InputDecoration(
                    labelText: 'Basin',
                    filled: true,
                    fillColor: Colors.grey[200],
                    contentPadding: EdgeInsets.fromLTRB(10.0, 10.0, 20.0, 10.0),
                    border: OutlineInputBorder(),
                  ),
                  onSaved: (value) => setState(() => basinName = value!),
                ),
              ),
            ],
          ),
          SizedBox(height: 5.0,),
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  readOnly: true,
                  controller: _riverName,
                  decoration: InputDecoration(
                    labelText: 'River',
                    filled: true,
                    fillColor: Colors.grey[200],
                    contentPadding: EdgeInsets.fromLTRB(10.0, 10.0, 20.0, 10.0),
                    border: OutlineInputBorder(),
                  ),
                  onSaved: (value) => setState(() => riverName = value!),
                ),
              ),
            ],
          ),
          SizedBox(
            height: 10.0,
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  children: [
                    TextFormField(
                      readOnly: true,
                      controller: _latitude,
                      decoration: InputDecoration(
                        labelText: 'Latitude',
                        filled: true,
                        fillColor: Colors.grey[200],
                        contentPadding: EdgeInsets.fromLTRB(10.0, 10.0, 20.0, 10.0),
                        border: OutlineInputBorder(),
                      ),
                      onSaved: (value) => setState(() => latitude = value!),
                    ),
                    SizedBox(height: 10.0,),
                    TextFormField(
                      controller: _longitude,
                      readOnly: true,
                      decoration: InputDecoration(
                        labelText: 'Longitude',
                        filled: true,
                        fillColor: Colors.grey[200],
                        contentPadding: EdgeInsets.fromLTRB(10.0, 10.0, 20.0, 10.0),
                        border: OutlineInputBorder(),
                      ),
                      onSaved: (value) => setState(() => longitude = value!),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(
            height: 5.0,
          ),
          SizedBox(
            height: 5,
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextFormField(
                      readOnly: true,
                      controller: _currentLatitude,
                      decoration: InputDecoration(
                        labelText: 'Current Latitude',
                        filled: true,
                        fillColor: Colors.yellow[100],
                        contentPadding: EdgeInsets.fromLTRB(10.0, 10.0, 20.0, 10.0),
                        border: OutlineInputBorder(),
                      ),
                      onSaved: (value) => setState(() => getLatitude = value!),
                    ),
                    SizedBox(height: 10.0,),
                    TextFormField(
                      readOnly: true,
                      controller: _currentLongitude,
                      decoration: InputDecoration(
                        labelText: 'Current Longitude',
                        filled: true,
                        fillColor: Colors.yellow[100],
                        contentPadding: EdgeInsets.fromLTRB(10.0, 10.0, 20.0, 10.0),
                        border: OutlineInputBorder(),
                      ),
                      onSaved: (value) => setState(() => getLongitude = value!),
                    ),
                    TextButton(
                      onPressed: () => _checkPermissionsAndFetchLocation(context),
                      child: Text('>> Get location'),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 10.0,),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TextFormField(
                        readOnly: true,
                        controller: _barcode,
                        decoration: InputDecoration(
                          labelText: 'Barcode',
                          contentPadding: EdgeInsets.fromLTRB(10.0, 10.0, 20.0, 10.0),
                          border: OutlineInputBorder(),
                          filled: true,
                          fillColor: Colors.grey[200],
                        ),
                        onSaved: (value) => setState(() => barcode = value!),
                      ),
                      TextButton(
                        onPressed: () async {
                          String? res = await SimpleBarcodeScanner.scanBarcode(
                            context,
                            barcodeAppBar: const BarcodeAppBar(
                              appBarTitle: 'Test',
                              centerTitle: false,
                              enableBackButton: true,
                              backButtonIcon: Icon(Icons.arrow_back_ios),
                            ),
                            isShowFlashIcon: true,
                            delayMillis: 500,
                            cameraFace: CameraFace.back,
                            scanFormat: ScanFormat.ONLY_BARCODE,
                          );
                          setState(() {
                            result = res as String;
                            _barcode.text = result;
                          });
                        },
                        child: const Text('>> Scan Barcode'),
                      ),
                    ],
                  )
              ),
            ],
          ),
          SizedBox(height: 5.0,),
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue
                  ),
                  onPressed: () {
                    if (_formRiverSample1.currentState!.validate()) {
                      _formRiverSample1.currentState!.save();

                      setState(() {
                        _form1 = false;
                        _form2 = true;
                        _form3 = false;
                        _form4 = false;
                      });
                    }
                  },
                  child: Text('Proceed',style: TextStyle(fontWeight: FontWeight.bold,color: Colors.white),),
                ),
              ),
            ],
          ),
          SizedBox(height: 50,),
        ],
      ),
    );
  }

  Widget _buildForm2() {
    return Form(
      key: _formRiverSample2,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(':: Manual Info',style: TextStyle(fontSize: 20,fontWeight: FontWeight.bold),),
          SizedBox(height: 5.0,),
          Row(
            children: [
              Expanded(
                flex: 2,
                child: Text('Weather'),
              ),
              Expanded(
                flex: 3,
                child: DropdownButtonFormField(
                  decoration: InputDecoration(
                    contentPadding: EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10.0),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(15.0)),
                  ),
                  value: _weather.isNotEmpty ? _weather : null,
                  items: <String>['Clear', 'Rainer']
                      .map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _weather = value.toString();
                    });
                  },
                  validator: (value) =>
                  value!.isEmpty ? 'state is required' : null,
                ),
              ),
            ],
          ),
          SizedBox(height: 5,),
          Row(
            children: [
              Expanded(
                flex: 3,
                child: Text('Photo'),
              ),
              Expanded(
                flex: 2,
                child: Row(
                  children: [
                    Align(
                      alignment: Alignment.centerRight,
                      child: IconButton(
                        onPressed: _takePicture1,
                        icon: Icon(
                          size: 30,
                          Icons.picture_in_picture,
                        ),
                      ),
                    ),
                    Align(
                      alignment: Alignment.centerRight,
                      child: IconButton(
                        onPressed: () {
                          _takePicture1a(ImageSource.gallery);
                        },
                        icon: Icon(
                          size: 30,
                          Icons.collections,
                        ),
                      ),
                    )
                  ],
                ),
              ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              _image1 != null
                  ? Column(
                children: [
                  SingleChildScrollView(
                    //scrollDirection: Axis.horizontal,
                    child: Container(
                      alignment: Alignment.center,
                      child: Center(
                        child: Image.file(
                          _image1!,
                          width: 300,
                          height: 200,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Expanded(
                        child: IconButton(
                          onPressed: _deletePicture1,
                          icon: Icon(
                            size: 40,
                            color: Colors.red,
                            Icons.delete_forever_outlined,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              )
                  : Text("--No image captured yet--",style: TextStyle(fontSize: 12,color: Colors.red),),
            ],
          ),
          SizedBox(height: 5,),
          Row(
            children: [
              Expanded(
                flex: 2,
                child: Text('Event remarks'),
              ),
              Expanded(
                flex: 3,
                child: TextFormField(
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.yellow[100],
                    contentPadding: EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10.0),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(15.0)),
                  ),
                  onSaved: (value) => setState(() => eventRemark = value!),
                ),
              ),
            ],
          ),
          SizedBox(height: 5,),
          Row(
            children: [
              Expanded(
                flex: 2,
                child: Text('Lab remarks'),
              ),
              Expanded(
                flex: 3,
                child: TextFormField(
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.yellow[100],
                    contentPadding: EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10.0),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(15.0)),
                  ),
                  onSaved: (value) => setState(() => labRemark = value!),
                ),
              ),
            ],
          ),
          SizedBox(height: 5.0,),
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue
                  ),
                  onPressed: () {
                    if (_formRiverSample2.currentState!.validate()) {
                      _formRiverSample2.currentState!.save();

                      setState(() {
                        _form1 = false;
                        _form2 = false;
                        _form3 = true;
                        _form4 = false;
                      });
                    }
                  },
                  child: Text('Proceed',style: TextStyle(fontWeight: FontWeight.bold,color: Colors.white),),
                ),
              ),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildForm3() {
    return Form(
      key: _formRiverSample3,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 5.0,),
          Text(':: Station Info',style: TextStyle(fontWeight: FontWeight.bold,fontSize: 18),),
          SizedBox(height: 5.0,),
          Row(
            children: [
              Expanded(
                flex: 2,
                child: Text('Station ID'),
              ),
              Expanded(
                flex: 3,
                child: TextFormField(
                  controller: _stationID,
                  readOnly: true,
                  decoration: InputDecoration(
                    contentPadding: EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10.0),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(15.0)),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 5.0,),
          Row(
            children: [
              Expanded(
                flex: 2,
                child: Text('Name'),
              ),
              Expanded(
                flex: 3,
                child: TextFormField(
                  controller: _riverName,
                  readOnly: true,
                  decoration: InputDecoration(
                    contentPadding: EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10.0),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(15.0)),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 5.0,),
          Row(
            children: [
              Expanded(
                flex: 2,
                child: Text('Latitude'),
              ),
              Expanded(
                flex: 3,
                child: TextFormField(
                  readOnly: true,
                  controller: _currentLatitude,
                  decoration: InputDecoration(
                    contentPadding: EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10.0),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(15.0)),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 5.0,),
          Row(
            children: [
              Expanded(
                flex: 2,
                child: Text('Longitude'),
              ),
              Expanded(
                flex: 3,
                child: TextFormField(
                  controller: _currentLongitude,
                  readOnly: true,
                  decoration: InputDecoration(
                    contentPadding: EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10.0),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(15.0)),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 10.0,),
          Container(
            height: 50,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(15.0),
              color: Colors.yellow,
            ),
            child: Center(
              child: Text('Data capture',style: TextStyle(fontSize: 20,fontWeight: FontWeight.bold),),
            ),
          ),
          SizedBox(height: 5.0,),
          Row(
            children: [
              Expanded(
                child: TextButton(
                  onPressed: () {
                    listDevices();
                  },
                  child: Text('COMMUNICATE VIA SERIAL',textAlign: TextAlign.center,),
                ),
              ),
              SizedBox(width: 10.0,),
              Expanded(
                child: TextButton(
                  onPressed: () {

                  },
                  child: Text('COMMUNICATE VIA BLUETOOTH',textAlign: TextAlign.center,),
                ),
              ),
            ],
          ),
          SizedBox(height: 5.0,),
          Row(
            children: [
              Expanded(
                child: Column(
                  children: [
                    Text("Available Devices " + pH, style: TextStyle(fontWeight: FontWeight.bold,color: Colors.green)),
                    SizedBox(height: 8),
                    DropdownButton<UsbDevice>(
                      hint: Text("Select a device"),
                      onChanged: (UsbDevice? device) {
                        if (device != null) {
                          connectToDevice(device);
                        }
                      },
                      items: devices.map((device) {
                        return DropdownMenuItem(
                          value: device,
                          child: Text(device.productName ?? "Unknown Device"),
                        );
                      }).toList(),
                    ),
                    SizedBox(height: 16),
                  ],
                ),
              ),
            ],
          ),
          /*
        Row(
          children: [
            Expanded(
              child: ElevatedButton(
                onPressed: () {

                },
                child: Text('Start Reading'),
              ),
            ),
          ],
        ),*/
          SizedBox(height: 5.0,),
          Row(
            children: [
              Expanded(
                flex: 2,
                child: Text('Sonde ID'),
              ),
              Expanded(
                flex: 3,
                child: TextFormField(
                  readOnly: true,
                  controller: _sondeID,
                  decoration: InputDecoration(
                    contentPadding: EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10.0),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(15.0)),
                  ),
                  onSaved: (value) => setState(() => sondeID = value!),
                ),
              ),
            ],
          ),
          SizedBox(height: 5.0,),
          Row(
            children: [
              Expanded(
                flex: 2,
                child: Text('Date'),
              ),
              Expanded(
                flex: 3,
                child: TextFormField(
                  readOnly: true,
                  controller: _dateCapture,
                  decoration: InputDecoration(
                    contentPadding: EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10.0),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(15.0)),
                  ),
                  onSaved: (value) => setState(() => dateCapture = value!),
                ),
              ),
            ],
          ),
          SizedBox(height: 5.0,),
          Row(
            children: [
              Expanded(
                flex: 2,
                child: Text('Time'),
              ),
              Expanded(
                flex: 3,
                child: TextFormField(
                  readOnly: true,
                  controller: _timeCapture,
                  decoration: InputDecoration(
                    contentPadding: EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10.0),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(15.0)),
                  ),
                  onSaved: (value) => setState(() => timeCapture = value!),
                ),
              ),
            ],
          ),
          SizedBox(height: 5.0,),
          Container(
            width: MediaQuery.of(context).size.width,
            height: 30,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: Colors.grey[200],
            ),
            child: Text('Parameters',style: TextStyle(fontWeight: FontWeight.bold,fontSize: 18),),
          ),
          SizedBox(height: 5.0,),
          Row(
            children: [
              Expanded(
                flex: 2,
                child: Text('Oxygen concentration (mg/L)'),
              ),
              Expanded(
                flex: 3,
                child: TextFormField(
                  decoration: InputDecoration(
                    contentPadding: EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10.0),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(15.0)),
                  ),
                  onSaved: (value) => setState(() => doValue1 = value!),
                ),
              ),
            ],
          ),
          SizedBox(height: 5.0,),
          Row(
            children: [
              Expanded(
                flex: 2,
                child: Text('Oxygen saturation (% Sat)'),
              ),
              Expanded(
                flex: 3,
                child: TextFormField(
                  decoration: InputDecoration(
                    contentPadding: EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10.0),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(15.0)),
                  ),
                  onSaved: (value) => setState(() => doValue2 = value!),
                ),
              ),
            ],
          ),
          SizedBox(height: 5.0,),
          Row(
            children: [
              Expanded(
                flex: 2,
                child: Text('pH'),
              ),
              Expanded(
                flex: 3,
                child: TextFormField(
                  decoration: InputDecoration(
                    contentPadding: EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10.0),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(15.0)),
                  ),
                  onSaved: (value) => setState(() => pH = value!),
                ),
              ),
            ],
          ),
          SizedBox(height: 5.0,),
          Row(
            children: [
              Expanded(
                flex: 2,
                child: Text('Conductivity (us/cm)'),
              ),
              Expanded(
                flex: 3,
                child: TextFormField(
                  decoration: InputDecoration(
                    contentPadding: EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10.0),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(15.0)),
                  ),
                  onSaved: (value) => setState(() => conductivity = value!),
                ),
              ),
            ],
          ),
          SizedBox(height: 5.0,),
          Row(
            children: [
              Expanded(
                flex: 2,
                child: Text('Salinity (ppt)'),
              ),
              Expanded(
                flex: 3,
                child: TextFormField(
                  decoration: InputDecoration(
                    contentPadding: EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10.0),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(15.0)),
                  ),
                  onSaved: (value) => setState(() => salinity = value!),
                ),
              ),
            ],
          ),
          SizedBox(height: 5.0,),
          Row(
            children: [
              Expanded(
                flex: 2,
                child: Text('Temperature'),
              ),
              Expanded(
                flex: 3,
                child: TextFormField(
                  decoration: InputDecoration(
                    contentPadding: EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10.0),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(15.0)),
                  ),
                  onSaved: (value) => setState(() => temperature = value!),
                ),
              ),
            ],
          ),
          SizedBox(height: 5.0,),
          Row(
            children: [
              Expanded(
                flex: 2,
                child: Text('Turbidity (NTU)'),
              ),
              Expanded(
                flex: 3,
                child: TextFormField(
                  decoration: InputDecoration(
                    contentPadding: EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10.0),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(15.0)),
                  ),
                  onSaved: (value) => setState(() => turbidity = value!),
                ),
              ),
            ],
          ),
          SizedBox(height: 5.0,),
          Row(
            children: [
              Expanded(
                flex: 2,
                child: Text('Flowrate (m/s)'),
              ),
              Expanded(
                flex: 3,
                child: TextFormField(
                  decoration: InputDecoration(
                    contentPadding: EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10.0),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(15.0)),
                  ),
                  onSaved: (value) => setState(() => flowRate = value!),
                ),
              ),
            ],
          ),
          SizedBox(height: 5.0,),
          Row(
            children: [
              Expanded(
                flex: 2,
                child: Text('Total Dissolve Solid'),
              ),
              Expanded(
                flex: 3,
                child: TextFormField(
                  decoration: InputDecoration(
                    contentPadding: EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10.0),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(15.0)),
                  ),
                  onSaved: (value) => setState(() => totalDissolve = value!),
                ),
              ),
            ],
          ),
          SizedBox(height: 5.0,),
          Row(
            children: [
              Expanded(
                flex: 2,
                child: Text('Total Suspended Solid'),
              ),
              Expanded(
                flex: 3,
                child: TextFormField(
                  decoration: InputDecoration(
                    contentPadding: EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10.0),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(15.0)),
                  ),
                  onSaved: (value) => setState(() => totalSuspended = value!),
                ),
              ),
            ],
          ),
          SizedBox(height: 5.0,),
          Row(
            children: [
              Expanded(
                flex: 2,
                child: Text('Battery status'),
              ),
              Expanded(
                flex: 3,
                child: TextFormField(
                  decoration: InputDecoration(
                    contentPadding: EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10.0),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(15.0)),
                  ),
                  onSaved: (value) => setState(() => battery = value!),
                ),
              ),
            ],
          ),
          SizedBox(height: 5.0,),
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue
                  ),
                  onPressed: () {
                    if(_formRiverSample3.currentState!.validate()) {
                      _formRiverSample3.currentState!.save();

                      setState(() {
                        _form1 = false;
                        _form2 = false;
                        _form3 = false;
                        _form4 = true;
                      });
                    }
                  },
                  child: Text('Proceed',style: TextStyle(fontWeight: FontWeight.bold,color: Colors.white),),
                ),
              )
            ],
          )
        ],
      ),
    );
  }

  Widget _buildForm4() {
    return Form(
      key: _formRiverSample4,
      child: Column(
        children: [
          Container(
            height: 50,
            child: Center(
              child: Text(':: REPORT SUMMARY ::',style: TextStyle(fontSize: 20,fontWeight: FontWeight.bold),),
            ),
          ),
          Divider(),
          SizedBox(height: 5.0,),
          Row(
            children: [
              Expanded(
                flex: 2,
                child: Text('Report'),
              ),
              Expanded(
                flex: 3,
                child: Text(''),
              ),
            ],
          ),
          SizedBox(height: 5.0,),
          Row(
            children: [
              Expanded(
                flex: 2,
                child: Text('1st Sampler'),
              ),
              Expanded(
                flex: 3,
                child: Text(firstSampleName!),
              ),
            ],
          ),
          SizedBox(height: 5.0,),
          Row(
            children: [
              Expanded(
                flex: 2,
                child: Text('2nd Sampler'),
              ),
              Expanded(
                flex: 3,
                child: Text(secondSampleName!),
              ),
            ],
          ),
          SizedBox(height: 5.0,),
          Row(
            children: [
              Expanded(
                flex: 2,
                child: Text('Date'),
              ),
              Expanded(
                flex: 3,
                child: Text(sampleDate!),
              ),
            ],
          ),
          SizedBox(height: 5.0,),
          Row(
            children: [
              Expanded(
                flex: 2,
                child: Text('Time'),
              ),
              Expanded(
                flex: 3,
                child: Text(sampleTime!),
              ),
            ],
          ),
          SizedBox(height: 5.0,),
          Row(
            children: [
              Expanded(
                flex: 2,
                child: Text('Sampling type'),
              ),
              Expanded(
                flex: 3,
                child: Text(_type),
              ),
            ],
          ),
          SizedBox(height: 5.0,),
          Row(
            children: [
              Expanded(
                flex: 2,
                child: Text('State'),
              ),
              Expanded(
                flex: 3,
                child: Text(selectedStateName!),
              ),
            ],
          ),
          SizedBox(height: 5.0,),
          Row(
            children: [
              Expanded(
                flex: 2,
                child: Text('Station ID & Name'),
              ),
              Expanded(
                flex: 3,
                child: Text(stationID! +"-"+ riverName!),
              ),
            ],
          ),
          SizedBox(height: 5.0,),
          Row(
            children: [
              Expanded(
                flex: 2,
                child: Text('Location'),
              ),
              Expanded(
                flex: 3,
                child: Text(latitude!+","+longitude!),
              ),
            ],
          ),
          SizedBox(height: 5.0,),
          Row(
            children: [
              Expanded(
                flex: 2,
                child: Text('Current location'),
              ),
              Expanded(
                flex: 3,
                child: Text(getLatitude!+","+getLongitude!),
              ),
            ],
          ),
          SizedBox(height: 5.0,),
          Row(
            children: [
              Expanded(
                flex: 2,
                child: Text('Barcode'),
              ),
              Expanded(
                flex: 3,
                child: Text(barcode!),
              ),
            ],
          ),
          SizedBox(height: 5.0,),
          Container(
            width: MediaQuery.of(context).size.width,
            height: 30,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: Colors.grey[200],
            ),
            child: Text('Parameters',style: TextStyle(fontWeight: FontWeight.bold,fontSize: 18),),
          ),
          SizedBox(height: 5.0,),
          Row(
            children: [
              Expanded(
                flex: 2,
                child: Text('Oxygen concentration (mg/L)'),
              ),
              Expanded(
                flex: 3,
                child: Text(doValue1),
              ),
            ],
          ),
          SizedBox(height: 5.0,),
          Row(
            children: [
              Expanded(
                flex: 2,
                child: Text('Oxygen saturation (% Sat)'),
              ),
              Expanded(
                flex: 3,
                child: Text(doValue2),
              ),
            ],
          ),
          SizedBox(height: 5.0,),
          Row(
            children: [
              Expanded(
                flex: 2,
                child: Text('pH'),
              ),
              Expanded(
                flex: 3,
                child: Text(pH),
              ),
            ],
          ),
          SizedBox(height: 5.0,),
          Row(
            children: [
              Expanded(
                flex: 2,
                child: Text(conductivity),
              ),
              Expanded(
                flex: 3,
                child: Text(''),
              ),
            ],
          ),
          SizedBox(height: 5.0,),
          Row(
            children: [
              Expanded(
                flex: 2,
                child: Text('Salinity (ppt)'),
              ),
              Expanded(
                flex: 3,
                child: Text(salinity),
              ),
            ],
          ),
          SizedBox(height: 5.0,),
          Row(
            children: [
              Expanded(
                flex: 2,
                child: Text('Temparature'),
              ),
              Expanded(
                flex: 3,
                child: Text(temperature),
              ),
            ],
          ),
          SizedBox(height: 5.0,),
          Row(
            children: [
              Expanded(
                flex: 2,
                child: Text('Tubidity (NTU)'),
              ),
              Expanded(
                flex: 3,
                child: Text(turbidity),
              ),
            ],
          ),
          SizedBox(height: 5.0,),
          Row(
            children: [
              Expanded(
                flex: 2,
                child: Text('Flowrate (m/s)'),
              ),
              Expanded(
                flex: 3,
                child: Text(flowRate),
              ),
            ],
          ),
          SizedBox(height: 5.0,),
          Row(
            children: [
              Expanded(
                flex: 2,
                child: Text('Total Dissolve Solid'),
              ),
              Expanded(
                flex: 3,
                child: Text(totalDissolve),
              ),
            ],
          ),
          SizedBox(height: 5.0,),
          Row(
            children: [
              Expanded(
                flex: 2,
                child: Text('Total Suspended Solid'),
              ),
              Expanded(
                flex: 3,
                child: Text(totalSuspended),
              ),
            ],
          ),
          SizedBox(height: 5.0,),
          Row(
            children: [
              Expanded(
                flex: 2,
                child: Text('Battery Status'),
              ),
              Expanded(
                flex: 3,
                child: Text(battery),
              ),
            ],
          ),
          SizedBox(height: 5.0,),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue
                  ),
                  onPressed: () {
                    setState(() {
                      _form1 = false;
                      _form2 = false;
                      _form3 = false;
                      _form4 = false;
                    });
                  },
                  child: Text('Cancel',style: TextStyle(fontWeight: FontWeight.bold,color: Colors.white),),
                ),
              ),
              SizedBox(width: 5.0,),
              Expanded(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue
                  ),
                  onPressed: () {
                    if (_formRiverSample4.currentState!.validate()) {
                      _formRiverSample4.currentState!.save();

                      _sendData();
                    }
                  },
                  child: Text('Submit',style: TextStyle(fontWeight: FontWeight.bold,color: Colors.white),),
                ),
              ),
            ],
          ),
          SizedBox(height: 30,)
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('River: Schedule Sampling',style: TextStyle(fontSize: 18,fontWeight: FontWeight.bold),),
        SizedBox(height: 10,),
        if (_form1 == true) ... [
          _buildForm1(),
        ]
        else if (_form2 == true) ... [
          _buildForm2(),
        ]
        else if (_form3 == true) ... [
            _buildForm3(),
          ]
          else if (_form4 == true) ... [
              _buildForm4(),
            ]
      ],
    );
  }

  /// Lists available USB devices
  Future<void> listDevices() async {
    List<UsbDevice>? availableDevices = await UsbSerial.listDevices();
    setState(() {
      devices = availableDevices ?? [];
    });

  }

  /// Connect to selected USB device
  Future<void> connectToDevice(UsbDevice device) async {

    setState(() {
      _sondeID.text = device.pid.toString();
    });

    port = await device.create();
    if (port == null) {
      print("Failed to open USB serial port!");
      return;
    }

    bool openResult = await port!.open();
    if (!openResult) {
      print("Failed to open connection!");
      return;
    }

    setState(() {
      isConnected = true;
    });

    await port!.setDTR(true);
    await port!.setRTS(true);
    await port!.setPortParameters(9600, 8, UsbPort.STOPBITS_1, UsbPort.PARITY_NONE);

    // Listen for incoming data
    inputStreamSubscription = port!.inputStream?.listen((Uint8List data) {
      String received = String.fromCharCodes(data);
      print("Received Data: $received");
      parseSensorData(received);
      setState(() {
        rawData += received + "\n";
      });
    });

    sendCommand("START_MEASUREMENT"); // Send a command to request data
  }

  /// Parse incoming sensor data
  void parseSensorData(String data) {
    // Example format: "pH:7.2,DO:8.5,Temp:26.1"
    List<String> parts = data.split(',');
    for (var part in parts) {
      if (part.startsWith("pH:")) {
        pH = part.replaceAll("pH:", "").trim();
      } else if (part.startsWith("DO:")) {
        doValue1 = part.replaceAll("DO:", "").trim();
        doValue2 = part.replaceAll("DO:", "").trim();
      } else if (part.startsWith("Temp:")) {
        temperature = part.replaceAll("Temp:", "").trim();
      } else if (part.startsWith("SAL:")) {
        salinity = part.replaceAll("SAL:", "").trim();
      } else if (part.startsWith("EC:")) {
        ec = part.replaceAll("EC:", "").trim();
      } else if (part.startsWith("TDS:")) {
        tds = part.replaceAll("TDS:", "").trim();
      } else if (part.startsWith("TURB:")) {
        turbidity = part.replaceAll("TURB:", "").trim();
      } else if (part.startsWith("TSS:")) {
        tss = part.replaceAll("TSS:", "").trim();
      } else if (part.startsWith("BATT:")) {
        battery = part.replaceAll("BATT:", "").trim();
      }
    }

    setState(() {}); // Refresh UI with new values
  }

  /// Send a command to the sonde
  void sendCommand(String command) {
    if (port != null) {
      String fullCommand = "$command\r\n";
      print("Sending Command: $fullCommand");
      port!.write(Uint8List.fromList(fullCommand.codeUnits));
    }
  }

  /// Disconnect and close the port
  Future<void> disconnect() async {
    await inputStreamSubscription?.cancel();
    await port?.close();
    setState(() {
      isConnected = false;
      rawData = "";
      pH = "--";
      doValue1 = "--";
      temperature = "--";
    });
  }

  void _sendData() async {

    var client = http.Client();
    var response = await
    client.post(Uri.parse("https://mmsv2.pstw.com.my/api/river/api-post-river.php"), body: {
      "action": "river-manual-sampling","reportID": '1111',"firstSampler": firstSampleName!,
      "secondSampler": secondSampleName!,
      "dateController": sampleDate,"timeController": sampleTime,"type":_type,
      "stationName": riverName,"sampleCode": barcode,
      "latitude": getLatitude,"longitude": getLongitude,
      "weather": _weather,
      "event":eventRemark,"lab":labRemark,
      "sondeID":sondeID,"dateCapture":dateCapture,"timeCapture":timeCapture,
      "oxygen1":doValue1,"oxygen2":doValue2,
      "pH":pH,"salinity":salinity,"temp":temperature,
      "turbidity":turbidity,"flowrate":flowRate,
      "totalDissolve":totalDissolve,"totalSuspended":totalSuspended,
      "battery":battery, "stationID":stationID
    });
    var data = json.decode(response.body);

  }

}