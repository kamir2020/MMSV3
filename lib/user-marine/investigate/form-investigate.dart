import 'dart:async';
import 'dart:io';
import 'dart:math';
import 'dart:typed_data';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:geolocator/geolocator.dart';
import 'dart:ui';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:simple_barcode_scanner/simple_barcode_scanner.dart';
import 'package:usb_serial/usb_serial.dart';
import 'package:path/path.dart' as path;
import '../../object-state.dart';
import '../../object-station.dart';

class SFormInvestigate extends StatefulWidget {
  _SFormInvestigate createState() => _SFormInvestigate();
}

class _SFormInvestigate extends State<SFormInvestigate> {

  bool _isDisplay = false;
  bool _isLocation = false;

  final TextEditingController _firstSamplerName = TextEditingController();
  final TextEditingController _secondSamplerName = TextEditingController();
  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _timeController = TextEditingController();
  TextEditingController _barcode = TextEditingController();
  TextEditingController _sondeID = TextEditingController();

  final TextEditingController _dateCapture = TextEditingController();
  final TextEditingController _timeCapture = TextEditingController();

  TextEditingController _stateName = TextEditingController();
  TextEditingController _categoryName = TextEditingController();
  TextEditingController _latitude = TextEditingController();
  TextEditingController _longitude = TextEditingController();
  final TextEditingController _currentLatitude = TextEditingController();
  final TextEditingController _currentLongitude = TextEditingController();
  final TextEditingController _reportID = TextEditingController();

  TextEditingController _stationID = TextEditingController();
  TextEditingController _stationLatitude = TextEditingController();
  TextEditingController _stationLongitude = TextEditingController();
  TextEditingController _selectedStationName = TextEditingController();

  late String stationID='',stationLatitude='',stationLongitude='';
  late String barcode = '';

  late String? _selectedStateName,_selectedCategoryName;
  late String? latitude,longitude;
  late String? _getLatitude, _getLongitude;

  late String firstSamplerName='',secondSamplerName='',_type = '';
  late String dateController='', timeController='';
  late String dateCapture='', timeCapture='';
  late String eventRemarks='',labRemarks='';

  late String _weather = '',_tide = '',_tarball = '';
  late String _special_1 = 'μ';

  bool _form1 = true;
  bool _form2 = false;
  bool _form3 = false;
  bool _form4 = false;

  final _formInSitu1 = GlobalKey<FormState>();
  final _formInSitu2 = GlobalKey<FormState>();
  final _formInSitu3 = GlobalKey<FormState>();

  final FlutterBluePlus flutterBlue = FlutterBluePlus();
  BluetoothDevice? ysiDevice;
  BluetoothCharacteristic? readCharacteristic;

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
  late String salinity = "--";
  late String ec = "--"; // Electrical conductivity
  late String temperature = "--";
  late String tds = "--";
  late String turbidity = "--";
  late String tss = "--";
  late String battery = "--";

  String result = '';
  String? stateID;

  Station? selectedStation;
  States? selectedState;

  @override
  void initState() {
    super.initState();
    _getProfile();
    _fetchStation();

    _reportID.text = getRandomString(10);

    var now = DateTime.now();
    var formatter = DateFormat('yyyy-MM-dd');
    String formattedDate = formatter.format(now);
    _dateController.text = formattedDate;
    _dateCapture.text = formattedDate;

    String formattedTime = now.hour.toString()+":"+now.minute.toString()+":"+now.second.toString();
    _timeController.text = formattedTime;
    _timeCapture.text = formattedTime;

  }

  static const _chars = 'AaBbCcDdEeFfGgHhIiJjKkLlMmNnOoPpQqRrSsTtUuVvWwXxYyZz1234567890';
  Random _rnd = Random();

  String getRandomString(int length) => String.fromCharCodes(Iterable.generate(
      length, (_) => _chars.codeUnitAt(_rnd.nextInt(_chars.length))));

  List<dynamic> _marineStationList = [];
  Map<String, dynamic>? _selectedStation;

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

  Future<void> _fetchStation() async {

    final response = await http.get(Uri.parse("https://mmsv2.pstw.com.my/api/marine/api-get-marine.php?action=marine-station"));
    if (response.statusCode == 200) {
      setState(() {
        _marineStationList = json.decode(response.body);
      });
    } else {
      throw Exception("Failed to load categories");
    }
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

      // set latitude & longitude
      _stationLatitude.text = position.latitude.toString();
      _stationLongitude.text = position.longitude.toString();

    });

    print("Latitude: ${position.latitude}, Longitude: ${position.longitude}");
  }

  Future<List<States>> fetchStates() async {
    final response = await http.get(Uri.parse("https://mmsv2.pstw.com.my/api/marine/api-get-marine.php?action=marine-state"));
    if (response.statusCode == 200) {

      final List jsonList = json.decode(response.body);
      return jsonList.map((json) => States.fromJson(json)).toList();

    } else {
      throw Exception('Failed to load items');
    }
  }

  Future<List<Station>> fetchItems() async {
    final response = await http.get(Uri.parse("https://mmsv2.pstw.com.my/api/marine/api-get-marine.php?action=marine-tarball-station&stateID="+stateID!));
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      //print(data);

      if (data['status']=='success') {

        final List jsonList = data['data'];
        return jsonList.map((json) => Station.fromJson(json)).toList();
      }
      else {
        return [];
      }
    } else {
      throw Exception('Failed to load items');
    }
  }

  Widget _buildForm1() {
    return Form(
      key: _formInSitu1,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('STUDY SAMPLING',style: TextStyle(fontSize: 18,fontWeight: FontWeight.bold),),
          SizedBox(height: 5.0,),
          Divider(),
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(15.0),
              color: Colors.transparent,
            ),
            child: Text(':: Sampling Information',style: TextStyle(fontSize: 20,fontWeight: FontWeight.bold),),
          ),
          Divider(),
          SizedBox(height: 10.0,),
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: _firstSamplerName,
                  readOnly: true,
                  decoration: InputDecoration(
                    labelText: '1st Sampler',
                    contentPadding: EdgeInsets.fromLTRB(10.0, 10.0, 20.0, 10.0),
                    border: OutlineInputBorder(),
                  ),
                  onSaved: (value) => setState(() => firstSamplerName = value!),
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
                  controller: _secondSamplerName,
                  decoration: InputDecoration(
                    labelText: '2nd Sampler',
                    contentPadding: EdgeInsets.fromLTRB(10.0, 10.0, 20.0, 10.0),
                    border: OutlineInputBorder(),
                  ),
                  onSaved: (value) => setState(() => secondSamplerName = value!),
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
                  controller: _dateController,
                  readOnly: true,
                  decoration: InputDecoration(
                    labelText: 'Date',
                    contentPadding: EdgeInsets.fromLTRB(10.0, 10.0, 20.0, 10.0),
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'Date';
                    }
                  },
                  onSaved: (value) => setState(() => dateController = value!),
                ),
              ),
            ],
          ),
          SizedBox(height: 10.0,),
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: _timeController,
                  readOnly: true,
                  decoration: InputDecoration(
                    labelText: 'Time',
                    contentPadding: EdgeInsets.fromLTRB(10.0, 10.0, 20.0, 10.0),
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'Time';
                    }
                  },
                  onSaved: (value) => setState(() => timeController = value!),
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
                      _selectedStateName = selectedState!.stateName;

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
          SizedBox(height: 5.0,),
          _isLocation ? Column(
            children: [
              SizedBox(
                height: 10,
              ),
              Row(
                children: [
                  Expanded(
                    child: DropdownSearch<Station>(
                      asyncItems: (filter) => fetchItems(),
                      itemAsString: (Station p) => "${p.stationID} - ${p.locationName}", // show product_name only
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
                      onChanged: (Station? value) {

                        setState(() {
                          selectedStation = value;
                        });

                        _categoryName.text = selectedStation!.categoryName;

                        _latitude.text = selectedStation!.latitude;
                        _longitude.text = selectedStation!.longitude;
                        _stationID.text = selectedStation!.stationID;

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
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please select type';
                    }
                    return null; // no error
                  },
                  onChanged: (value) {
                    setState(() {
                      _type = value.toString();
                    });
                  },
                  onSaved: (value) => setState(() => _type = value!),

                ),
              ),
            ],
          ),
          SizedBox(height: 10.0,),
          Row(
            children: [
              Expanded(
                flex: 3,
                child: Column(
                  children: [
                    TextFormField(
                      readOnly: true,
                      controller: _categoryName,
                      decoration: InputDecoration(
                        labelText: 'Category name',
                        filled: true,
                        fillColor: Colors.grey[200],
                        //hintText: 'Category name',
                        contentPadding: EdgeInsets.fromLTRB(10.0, 10.0, 20.0, 10.0),
                        border: OutlineInputBorder(),
                      ),
                      onSaved: (value) => setState(() => _selectedCategoryName = value!),
                      validator: (value) {
                        if (value!.isEmpty) {
                          return 'Category name';
                        }
                      },
                    ),
                  ],
                ),
              )
            ],
          ),
          SizedBox(
            height: 10.0,
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: TextFormField(
                  readOnly: true,
                  controller: _latitude,
                  decoration: InputDecoration(
                    labelText: 'Latitude',
                    filled: true,
                    fillColor: Colors.grey[200],
                    //hintText: 'Latitude',
                    contentPadding: EdgeInsets.fromLTRB(10.0, 10.0, 20.0, 10.0),
                    border: OutlineInputBorder(),
                  ),
                  onSaved: (value) => setState(() => latitude = value!),
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'Latitude';
                    }
                  },
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
                child: TextFormField(
                  readOnly: true,
                  controller: _longitude,
                  decoration: InputDecoration(
                    labelText: 'Longitude',
                    filled: true,
                    fillColor: Colors.grey[200],
                    //hintText: 'Longitude',
                    contentPadding: EdgeInsets.fromLTRB(10.0, 10.0, 20.0, 10.0),
                    border: OutlineInputBorder(),
                  ),
                  onSaved: (value) => setState(() => longitude = value!),
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'Longitude';
                    }
                  },
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
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextFormField(
                      readOnly: true,
                      controller: _currentLatitude,
                      decoration: InputDecoration(
                        hintText: 'Current latitude',
                        filled: true,
                        fillColor: Colors.yellow[100],
                        contentPadding: EdgeInsets.fromLTRB(10.0, 10.0, 20.0, 10.0),
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value!.isEmpty) {
                          return 'Latitude';
                        }
                      },
                      onSaved: (value) => setState(() => _getLatitude = value!),
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
                      controller: _currentLongitude,
                      decoration: InputDecoration(
                        hintText: 'Current longitude',
                        filled: true,
                        fillColor: Colors.yellow[100],
                        contentPadding: EdgeInsets.fromLTRB(10.0, 10.0, 20.0, 10.0),
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value!.isEmpty) {
                          return 'Longitude';
                        }
                      },
                      onSaved: (value) => setState(() => _getLongitude = value!),
                    ),
                    SizedBox(height: 5.0,),
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
                          labelText: 'Sample ID Code',
                          contentPadding: EdgeInsets.fromLTRB(10.0, 10.0, 20.0, 10.0),
                          border: OutlineInputBorder(),
                          filled: true,
                          fillColor: Colors.grey[200],
                        ),
                        validator: (value) {
                          if (value!.isEmpty) {
                            return 'Code';
                          }
                        },
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
                      /*
                      Text('Scan Barcode Result: $result'),
                      const SizedBox(
                        height: 10,
                      ),*/
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
                    backgroundColor: Colors.blue,
                  ),
                  onPressed: () {
                    if (_formInSitu1.currentState!.validate()) {

                      _formInSitu1.currentState!.save();

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

  final ImagePicker _picker1 = ImagePicker();
  final ImagePicker _picker2 = ImagePicker();
  final ImagePicker _picker3 = ImagePicker();
  final ImagePicker _picker4 = ImagePicker();
  final ImagePicker _picker5 = ImagePicker();
  final ImagePicker _picker6 = ImagePicker();

  File? _image1,_image2,_image3,_image4,_image5,_image6;

  Future<void> _takePicture1() async {
    try {
      final XFile? photo = await _picker1.pickImage(
        source: ImageSource.camera,
        maxWidth: 500,
        maxHeight: 200,
        imageQuality: 80,
      );

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

  Future<void> _takePicture2() async {
    try {
      final XFile? photo = await _picker2.pickImage(
        source: ImageSource.camera,
        maxWidth: 500,
        maxHeight: 200,
        imageQuality: 80,
      );

      if (photo != null) {
        setState(() {
          _image2 = File(photo.path);
        });
      }
    } catch (e) {
      print("Error while capturing image: $e");
    }
  }

  // Function to delete the picture
  Future<void> _deletePicture2() async {
    if (_image2 != null) {
      try {
        await _image2!.delete();
        setState(() {
          _image2 = null; // Reset the image state
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

  Future<void> _takePicture3() async {
    try {
      final XFile? photo = await _picker3.pickImage(
        source: ImageSource.camera,
        maxWidth: 500,
        maxHeight: 200,
        imageQuality: 80,
      );

      if (photo != null) {
        setState(() {
          _image3 = File(photo.path);
        });
      }
    } catch (e) {
      print("Error while capturing image: $e");
    }
  }

  // Function to delete the picture
  Future<void> _deletePicture3() async {
    if (_image3 != null) {
      try {
        await _image3!.delete();
        setState(() {
          _image3 = null; // Reset the image state
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

  Future<void> _takePicture4() async {
    try {
      final XFile? photo = await _picker4.pickImage(
        source: ImageSource.camera,
        maxWidth: 500,
        maxHeight: 200,
        imageQuality: 80,
      );

      if (photo != null) {
        setState(() {
          _image4 = File(photo.path);
        });
      }
    } catch (e) {
      print("Error while capturing image: $e");
    }
  }

  // Function to delete the picture
  Future<void> _deletePicture4() async {
    if (_image4 != null) {
      try {
        await _image4!.delete();
        setState(() {
          _image4 = null; // Reset the image state
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

  Future<void> _takePicture5() async {
    try {
      final XFile? photo = await _picker5.pickImage(
        source: ImageSource.camera,
        maxWidth: 500,
        maxHeight: 200,
        imageQuality: 80,
      );

      if (photo != null) {
        setState(() {
          _image5 = File(photo.path);
        });
      }
    } catch (e) {
      print("Error while capturing image: $e");
    }
  }

  // Function to delete the picture
  Future<void> _deletePicture5() async {
    if (_image5 != null) {
      try {
        await _image5!.delete();
        setState(() {
          _image5 = null; // Reset the image state
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

  Future<void> _takePicture6() async {
    try {
      final XFile? photo = await _picker6.pickImage(
        source: ImageSource.camera,
        maxWidth: 500,
        maxHeight: 200,
        imageQuality: 80,
      );

      if (photo != null) {
        setState(() {
          _image6 = File(photo.path);
        });
      }
    } catch (e) {
      print("Error while capturing image: $e");
    }
  }

  // Function to delete the picture
  Future<void> _deletePicture6() async {
    if (_image6 != null) {
      try {
        await _image6!.delete();
        setState(() {
          _image6 = null; // Reset the image state
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

  Widget _buildForm2() {
    return Form(
      key: _formInSitu2,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('On-Site Information',style: TextStyle(fontSize: 20,fontWeight: FontWeight.bold),),
          Divider(),
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
                    contentPadding: EdgeInsets.fromLTRB(10.0, 10.0, 20.0, 10.0),
                    border: OutlineInputBorder(),
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
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Choose weather';
                    }
                    return null; // no error
                  },
                  onSaved: (value) => setState(() => _weather = value!),
                ),
              ),
            ],
          ),
          SizedBox(height: 5.0,),
          Row(
            children: [
              Expanded(
                flex: 2,
                child: Text('Tide-level'),
              ),
              Expanded(
                flex: 3,
                child: DropdownButtonFormField(
                  decoration: InputDecoration(
                    contentPadding: EdgeInsets.fromLTRB(10.0, 10.0, 20.0, 10.0),
                    border: OutlineInputBorder(),
                  ),
                  value: _tide.isNotEmpty ? _tide : null,
                  items: <String>['High', 'Low']
                      .map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _tide = value.toString();
                    });
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Choose tide level';
                    }
                    return null; // no error
                  },
                  onSaved: (value) => setState(() => _tide = value!),
                ),
              ),
            ],
          ),
          SizedBox(height: 5.0,),
          Row(
            children: [
              Expanded(
                flex: 2,
                child: Text('Sea condition'),
              ),
              Expanded(
                flex: 3,
                child: DropdownButtonFormField(
                  decoration: InputDecoration(
                    contentPadding: EdgeInsets.fromLTRB(10.0, 10.0, 20.0, 10.0),
                    border: OutlineInputBorder(),
                  ),
                  value: _tarball.isNotEmpty ? _tarball : null,
                  items: <String>['Calm', 'Moderate Wave', 'High Wave']
                      .map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _tarball = value.toString();
                    });
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Choose sea condition';
                    }
                    return null; // no error
                  },
                  onSaved: (value) => setState(() => _tarball = value!),
                ),
              ),
            ],
          ),
          SizedBox(height: 5,),
          Row(
            children: [
              Expanded(
                flex: 3,
                child: Text('Left side land view'),
              ),
              Expanded(
                flex: 2,
                child: Align(
                  alignment: Alignment.centerRight,
                  child: IconButton(
                    onPressed: _takePicture1,
                    icon: Icon(
                      size: 30,
                      Icons.picture_in_picture,
                    ),
                  ),
                ),
              ),
            ],
          ),
          Row(
            children: [
              _image1 != null
                  ? Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SizedBox(height: 5.0,),
                    Image.file(_image1!), // Display captured image
                    SizedBox(height: 5.0),
                    Align(
                      alignment: Alignment.centerRight,
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
              )
                  : Text("--No image captured yet--",style: TextStyle(fontSize: 12,color: Colors.red),),
            ],
          ),
          SizedBox(height: 5,),

          Row(
            children: [
              Expanded(
                flex: 3,
                child: Text('Right side land view'),
              ),
              Expanded(
                flex: 2,
                child: Align(
                  alignment: Alignment.centerRight,
                  child: IconButton(
                    onPressed: _takePicture2,
                    icon: Icon(
                      size: 30,
                      Icons.picture_in_picture,
                    ),
                  ),
                ),
              ),
            ],
          ),
          Row(
            children: [
              _image2 != null
                  ? Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SizedBox(height: 5.0,),
                    Image.file(_image2!), // Display captured image
                    SizedBox(height: 5.0),
                    Align(
                      alignment: Alignment.centerRight,
                      child: IconButton(
                        onPressed: _deletePicture2,
                        icon: Icon(
                          size: 40,
                          color: Colors.red,
                          Icons.delete_forever_outlined,
                        ),
                      ),
                    ),
                  ],
                ),
              )
                  : Text("--No image captured yet--",style: TextStyle(fontSize: 12,color: Colors.red),),
            ],
          ),
          SizedBox(height: 5,),

          Row(
            children: [
              Expanded(
                flex: 3,
                child: Text('Filling water into sample bottle'),
              ),
              Expanded(
                flex: 2,
                child: Align(
                  alignment: Alignment.centerRight,
                  child: IconButton(
                    onPressed: _takePicture3,
                    icon: Icon(
                      size: 30,
                      Icons.picture_in_picture,
                    ),
                  ),
                ),
              ),
            ],
          ),
          Row(
            children: [
              _image3 != null
                  ? Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SizedBox(height: 5.0,),
                    Image.file(_image3!), // Display captured image
                    SizedBox(height: 5.0),
                    Align(
                      alignment: Alignment.centerRight,
                      child: IconButton(
                        onPressed: _deletePicture3,
                        icon: Icon(
                          size: 40,
                          color: Colors.red,
                          Icons.delete_forever_outlined,
                        ),
                      ),
                    ),
                  ],
                ),
              )
                  : Text("--No image captured yet--",style: TextStyle(fontSize: 12,color: Colors.red),),
            ],
          ),
          SizedBox(height: 5,),

          Row(
            children: [
              Expanded(
                flex: 3,
                child: Text('Seawater in clear glass bottle (Seawater color)'),
              ),
              Expanded(
                flex: 2,
                child: Align(
                  alignment: Alignment.centerRight,
                  child: IconButton(
                    onPressed: _takePicture4,
                    icon: Icon(
                      size: 30,
                      Icons.picture_in_picture,
                    ),
                  ),
                ),
              ),
            ],
          ),
          Row(
            children: [
              _image4 != null
                  ? Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SizedBox(height: 5.0,),
                    Image.file(_image4!), // Display captured image
                    SizedBox(height: 5.0),
                    Align(
                      alignment: Alignment.centerRight,
                      child: IconButton(
                        onPressed: _deletePicture4,
                        icon: Icon(
                          size: 40,
                          color: Colors.red,
                          Icons.delete_forever_outlined,
                        ),
                      ),
                    ),
                  ],
                ),
              )
                  : Text("--No image captured yet--",style: TextStyle(fontSize: 12,color: Colors.red),),
            ],
          ),
          SizedBox(height: 5,),

          Row(
            children: [
              Expanded(
                flex: 3,
                child: Text('Examine preservative in sampling bottle using pH paper'),
              ),
              Expanded(
                flex: 2,
                child: Align(
                  alignment: Alignment.centerRight,
                  child: IconButton(
                    onPressed: _takePicture5,
                    icon: Icon(
                      size: 30,
                      Icons.picture_in_picture,
                    ),
                  ),
                ),
              ),
            ],
          ),
          Row(
            children: [
              _image5 != null
                  ? Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SizedBox(height: 5.0,),
                    Image.file(_image5!), // Display captured image
                    SizedBox(height: 5.0),
                    Align(
                      alignment: Alignment.centerRight,
                      child: IconButton(
                        onPressed: _deletePicture5,
                        icon: Icon(
                          size: 40,
                          color: Colors.red,
                          Icons.delete_forever_outlined,
                        ),
                      ),
                    ),
                  ],
                ),
              )
                  : Text("--No image captured yet--",style: TextStyle(fontSize: 12,color: Colors.red),),
            ],
          ),
          SizedBox(height: 5,),

          Row(
            children: [
              Expanded(
                flex: 2,
                child: Text('Photo (Optional)'),
              ),
              Expanded(
                flex: 3,
                child: Align(
                  alignment: Alignment.centerRight,
                  child: IconButton(
                    onPressed: _takePicture6,
                    icon: Icon(
                      size: 30,
                      Icons.picture_in_picture,
                    ),
                  ),
                ),
              ),
            ],
          ),
          Row(
            children: [
              _image6 != null
                  ? Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SizedBox(height: 5.0,),
                    Image.file(_image6!), // Display captured image
                    SizedBox(height: 5.0),
                    Align(
                      alignment: Alignment.centerRight,
                      child: IconButton(
                        onPressed: _deletePicture6,
                        icon: Icon(
                          size: 40,
                          color: Colors.red,
                          Icons.delete_forever_outlined,
                        ),
                      ),
                    ),
                  ],
                ),
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
                    contentPadding: EdgeInsets.fromLTRB(10.0, 10.0, 20.0, 10.0),
                    border: OutlineInputBorder(),
                  ),
                  onSaved: (value) => setState(() => eventRemarks = value!),
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
                    contentPadding: EdgeInsets.fromLTRB(10.0, 10.0, 20.0, 10.0),
                    border: OutlineInputBorder(),
                  ),
                  onSaved: (value) => setState(() => labRemarks = value!),
                ),
              ),
            ],
          ),
          SizedBox(height: 5.0,),
          Row(
            children: [
              Expanded(
                flex: 2,
                child: Text(''),
              ),
              Expanded(
                flex: 3,
                child: Row(
                  children: [
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue
                      ),
                      onPressed: () {

                      },
                      child: Text('Back',style: TextStyle(fontWeight: FontWeight.bold,color: Colors.white),),
                    ),
                    SizedBox(width: 5.0,),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue
                      ),
                      onPressed: () {
                        if (_formInSitu2.currentState!.validate()) {

                          _formInSitu2.currentState!.save();

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
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 50,),
        ],
      ),
    );
  }

  Widget _buildForm3() {
    return Form(
      key: _formInSitu3,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 50,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(15.0),
            ),
            child: Center(
              child: Text(':: DATA CAPTURE :: ',style: TextStyle(fontSize: 20,fontWeight: FontWeight.bold),),
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
                    //scanDevices();
                  },
                  child: Text('COMMUNICATE VIA BLUETOOTH',textAlign: TextAlign.center,),
                ),
              ),
            ],
          ),
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

          Text("Live Sensor Data", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Text('pH' + pH),
              Text('DO' + doValue1),
              Text('Temp' + temperature),
            ],
          ),
          SizedBox(height: 5.0,),
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
              // list bluetooth
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
                  controller: _sondeID,
                  decoration: InputDecoration(
                    contentPadding: EdgeInsets.fromLTRB(10.0, 10.0, 20.0, 10.0),
                    border: OutlineInputBorder(),
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
                    contentPadding: EdgeInsets.fromLTRB(10.0, 10.0, 20.0, 10.0),
                    border: OutlineInputBorder(),
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
                    contentPadding: EdgeInsets.fromLTRB(10.0, 10.0, 20.0, 10.0),
                    border: OutlineInputBorder(),
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
                flex: 3,
                child: Text('Oxygen concentration'),
              ),
              Expanded(
                flex: 2,
                child: TextFormField(
                  decoration: InputDecoration(
                    contentPadding: EdgeInsets.fromLTRB(10.0, 10.0, 20.0, 10.0),
                    border: OutlineInputBorder(),
                  ),
                  onSaved: (value) => setState(() => doValue1 = value!),
                ),
              ),
              Expanded(
                flex: 2,
                child: Text(' (mg/L)'),
              ),
            ],
          ),
          SizedBox(height: 5.0,),
          Row(
            children: [
              Expanded(
                flex: 3,
                child: Text('Oxygen saturation'),
              ),
              Expanded(
                flex: 2,
                child: TextFormField(
                  decoration: InputDecoration(
                    contentPadding: EdgeInsets.fromLTRB(10.0, 10.0, 20.0, 10.0),
                    border: OutlineInputBorder(),
                  ),
                  onSaved: (value) => setState(() => doValue2 = value!),
                ),
              ),
              Expanded(
                flex: 2,
                child: Text(' (% sat)'),
              ),
            ],
          ),
          SizedBox(height: 5.0,),
          Row(
            children: [
              Expanded(
                flex: 3,
                child: Text(' pH'),
              ),
              Expanded(
                flex: 2,
                child: TextFormField(
                  decoration: InputDecoration(
                    contentPadding: EdgeInsets.fromLTRB(10.0, 10.0, 20.0, 10.0),
                    border: OutlineInputBorder(),
                  ),
                  onSaved: (value) => setState(() => pH = value!),
                ),
              ),
              Expanded(
                flex: 2,
                child: Text(''),
              ),
            ],
          ),
          SizedBox(height: 5.0,),
          Row(
            children: [
              Expanded(
                flex: 3,
                child: Text(' Salinity'),
              ),
              Expanded(
                flex: 2,
                child: TextFormField(
                  decoration: InputDecoration(
                    contentPadding: EdgeInsets.fromLTRB(10.0, 10.0, 20.0, 10.0),
                    border: OutlineInputBorder(),
                  ),
                  onSaved: (value) => setState(() => salinity = value!),
                ),
              ),
              Expanded(
                flex: 2,
                child: Text(' (g/L - ppt)'),
              ),
            ],
          ),
          SizedBox(height: 5.0,),
          Row(
            children: [
              Expanded(
                flex: 3,
                child: Text('Electrical Conductivity'),
              ),
              Expanded(
                flex: 2,
                child: TextFormField(
                  decoration: InputDecoration(
                    contentPadding: EdgeInsets.fromLTRB(10.0, 10.0, 20.0, 10.0),
                    border: OutlineInputBorder(),
                  ),
                  onSaved: (value) => setState(() => ec = value!),
                ),
              ),
              Expanded(
                flex: 2,
                child: Text(' ('+_special_1 + 's/cm)'),
              ),
            ],
          ),
          SizedBox(height: 5.0,),
          Row(
            children: [
              Expanded(
                flex: 3,
                child: Text('Temperature'),
              ),
              Expanded(
                flex: 2,
                child: TextFormField(
                  decoration: InputDecoration(
                    contentPadding: EdgeInsets.fromLTRB(10.0, 10.0, 20.0, 10.0),
                    border: OutlineInputBorder(),
                  ),
                  onSaved: (value) => setState(() => temperature = value!),
                ),
              ),
              Expanded(
                flex: 2,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(' ('),
                        RichText(
                          text: TextSpan(
                            style: const TextStyle(color: Colors.black),
                            children: [
                              WidgetSpan(
                                child: Transform.translate(
                                  offset: const Offset(0.0, -8.0),
                                  child: const Text(
                                    'o', style: TextStyle(fontSize: 10, color: Colors.black),
                                  ),
                                ),
                              ),
                              const TextSpan(
                                text: 'C',
                              ),
                            ],
                          ),
                        ),
                        Text(' )'),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 5.0,),
          Row(
            children: [
              Expanded(
                flex: 3,
                child: Text('TDS'),
              ),
              Expanded(
                flex: 2,
                child: TextFormField(
                  decoration: InputDecoration(
                    contentPadding: EdgeInsets.fromLTRB(10.0, 10.0, 20.0, 10.0),
                    border: OutlineInputBorder(),
                  ),
                  onSaved: (value) => setState(() => tds = value!),
                ),
              ),
              Expanded(
                flex: 2,
                child: Text(' (mg/L)'),
              ),
            ],
          ),
          SizedBox(height: 5.0,),
          Row(
            children: [
              Expanded(
                flex: 3,
                child: Text('Turbidity'),
              ),
              Expanded(
                flex: 2,
                child: TextFormField(
                  decoration: InputDecoration(
                    contentPadding: EdgeInsets.fromLTRB(10.0, 10.0, 20.0, 10.0),
                    border: OutlineInputBorder(),
                  ),
                  onSaved: (value) => setState(() => turbidity = value!),
                ),
              ),
              Expanded(
                flex: 2,
                child: Text(' (NTU)'),
              ),
            ],
          ),
          SizedBox(height: 5.0,),
          Row(
            children: [
              Expanded(
                flex: 3,
                child: Text('TSS'),
              ),
              Expanded(
                flex: 2,
                child: TextFormField(
                  decoration: InputDecoration(
                    contentPadding: EdgeInsets.fromLTRB(10.0, 10.0, 20.0, 10.0),
                    border: OutlineInputBorder(),
                  ),
                  onSaved: (value) => setState(() => tss = value!),
                ),
              ),
              Expanded(
                flex: 2,
                child: Text(' (mg/L)'),
              ),
            ],
          ),
          SizedBox(height: 5.0,),
          Row(
            children: [
              Expanded(
                flex: 3,
                child: Text('Battery status'),
              ),
              Expanded(
                flex: 2,
                child: TextFormField(
                  decoration: InputDecoration(
                    contentPadding: EdgeInsets.fromLTRB(10.0, 10.0, 20.0, 10.0),
                    border: OutlineInputBorder(),
                  ),
                  onSaved: (value) => setState(() => battery = value!),
                ),
              ),
              Expanded(
                flex: 2,
                child: Text(' (V)'),
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
            child: Text('Station Info',style: TextStyle(fontWeight: FontWeight.bold,fontSize: 18),),
          ),
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
                  readOnly: true,
                  controller: _stationID,
                  decoration: InputDecoration(
                    contentPadding: EdgeInsets.fromLTRB(10.0, 10.0, 20.0, 10.0),
                    border: OutlineInputBorder(),
                  ),
                  onSaved: (value) => setState(() => stationID = value!),
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
                  controller: _stationLatitude,
                  decoration: InputDecoration(
                    contentPadding: EdgeInsets.fromLTRB(10.0, 10.0, 20.0, 10.0),
                    border: OutlineInputBorder(),
                  ),
                  onSaved: (value) => setState(() => stationLatitude = value!),
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
                  readOnly: true,
                  controller: _stationLongitude,
                  decoration: InputDecoration(
                    contentPadding: EdgeInsets.fromLTRB(10.0, 10.0, 20.0, 10.0),
                    border: OutlineInputBorder(),
                  ),
                  onSaved: (value) => setState(() => stationLongitude = value!),
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

                  },
                  child: Text('Back',style: TextStyle(fontWeight: FontWeight.bold,color: Colors.white),),
                ),
              ),
              SizedBox(width: 5.0,),
              Expanded(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue
                  ),
                  onPressed: () {
                    if (_formInSitu3.currentState!.validate()) {

                      _formInSitu3.currentState!.save();

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
              ),
            ],
          ),
          SizedBox(height: 50.0,),
        ],
      ),
    );
  }

  Widget _buildForm4() {
    return Column(
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
              child: Text('Report ID',style: TextStyle(fontWeight: FontWeight.bold),),
            ),
            Expanded(
              flex: 3,
              child: Text(_reportID.text),
            ),
          ],
        ),
        SizedBox(height: 5.0,),
        Row(
          children: [
            Expanded(
              flex: 2,
              child: Text('1st Sampler',style: TextStyle(fontWeight: FontWeight.bold),),
            ),
            Expanded(
              flex: 3,
              child: Text(firstSamplerName),
            ),
          ],
        ),
        SizedBox(height: 5.0,),
        Row(
          children: [
            Expanded(
              flex: 2,
              child: Text('2nd Sampler',style: TextStyle(fontWeight: FontWeight.bold),),
            ),
            Expanded(
              flex: 3,
              child: Text(secondSamplerName),
            ),
          ],
        ),
        SizedBox(height: 5.0,),
        Row(
          children: [
            Expanded(
              flex: 2,
              child: Text('Date',style: TextStyle(fontWeight: FontWeight.bold),),
            ),
            Expanded(
              flex: 3,
              child: Text(dateController),
            ),
          ],
        ),
        SizedBox(height: 5.0,),
        Row(
          children: [
            Expanded(
              flex: 2,
              child: Text('Time',style: TextStyle(fontWeight: FontWeight.bold),),
            ),
            Expanded(
              flex: 3,
              child: Text(timeController),
            ),
          ],
        ),
        SizedBox(height: 5.0,),
        Row(
          children: [
            Expanded(
              flex: 2,
              child: Text('Sampling Type',style: TextStyle(fontWeight: FontWeight.bold),),
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
              child: Text('State',style: TextStyle(fontWeight: FontWeight.bold),),
            ),
            Expanded(
              flex: 3,
              child: Text(_selectedStateName!),
            ),
          ],
        ),
        SizedBox(height: 5.0,),
        Row(
          children: [
            Expanded(
              flex: 2,
              child: Text('Station Category',style: TextStyle(fontWeight: FontWeight.bold),),
            ),
            Expanded(
              flex: 3,
              child: Text(_selectedCategoryName!),
            ),
          ],
        ),
        SizedBox(height: 5.0,),
        Row(
          children: [
            Expanded(
              flex: 2,
              child: Text('Station ID & Name',style: TextStyle(fontWeight: FontWeight.bold),),
            ),
            Expanded(
              flex: 3,
              child: Text(stationID! + " & " + _selectedStateName!),
            ),
          ],
        ),
        SizedBox(height: 5.0,),
        Row(
          children: [
            Expanded(
              flex: 2,
              child: Text('Location',style: TextStyle(fontWeight: FontWeight.bold),),
            ),
            Expanded(
              flex: 3,
              child: Text(latitude! + " - " + longitude!),
            ),
          ],
        ),
        SizedBox(height: 5.0,),
        Row(
          children: [
            Expanded(
              flex: 2,
              child: Text('Current Location',style: TextStyle(fontWeight: FontWeight.bold),),
            ),
            Expanded(
              flex: 3,
              child: Text(_getLatitude! +" - "+ _getLongitude!),
            ),
          ],
        ),
        SizedBox(height: 5.0,),
        Row(
          children: [
            Expanded(
              flex: 2,
              child: Text('Sample ID Code',style: TextStyle(fontWeight: FontWeight.bold),),
            ),
            Expanded(
              flex: 3,
              child: Text(barcode),
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
              child: Text('Oxygen concentration',style: TextStyle(fontWeight: FontWeight.bold),),
            ),
            Expanded(
              flex: 2,
              child: Text(doValue1,textAlign: TextAlign.center,),
            ),
            Expanded(
              flex: 1,
              child: Text('(mg/L)'),
            ),
          ],
        ),
        SizedBox(height: 5.0,),
        Row(
          children: [
            Expanded(
              flex: 2,
              child: Text('Oxygen saturation',style: TextStyle(fontWeight: FontWeight.bold),),
            ),
            Expanded(
              flex: 2,
              child: Text(doValue2,textAlign: TextAlign.center,),
            ),
            Expanded(
              flex: 1,
              child: Text('(% sat)'),
            ),
          ],
        ),
        SizedBox(height: 5.0,),
        Row(
          children: [
            Expanded(
              flex: 2,
              child: Text('pH',style: TextStyle(fontWeight: FontWeight.bold),),
            ),
            Expanded(
              flex: 2,
              child: Text(pH,textAlign: TextAlign.center,),
            ),
            Expanded(
              flex: 1,
              child: Text(''),
            ),
          ],
        ),
        SizedBox(height: 5.0,),
        Row(
          children: [
            Expanded(
              flex: 2,
              child: Text('Salinity',style: TextStyle(fontWeight: FontWeight.bold),),
            ),
            Expanded(
              flex: 2,
              child: Text(salinity,textAlign: TextAlign.center,),
            ),
            Expanded(
              flex: 1,
              child: Text('(g/L - ppt)'),
            ),
          ],
        ),
        SizedBox(height: 5.0,),
        Row(
          children: [
            Expanded(
              flex: 2,
              child: Text('Electrical Conductivity',style: TextStyle(fontWeight: FontWeight.bold),),
            ),
            Expanded(
              flex: 2,
              child: Text(ec,textAlign: TextAlign.center,),
            ),
            Expanded(
              flex: 1,
              child: Text('('+_special_1 + 's/cm)'),
            ),
          ],
        ),
        SizedBox(height: 5.0,),
        Row(
          children: [
            Expanded(
              flex: 2,
              child: Text('Temperature',style: TextStyle(fontWeight: FontWeight.bold),),
            ),
            Expanded(
              flex: 2,
              child: Text(temperature,textAlign: TextAlign.center,),
            ),
            Expanded(
              flex: 1,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text('('),
                      RichText(
                        text: TextSpan(
                          style: const TextStyle(color: Colors.black),
                          children: [
                            WidgetSpan(
                              child: Transform.translate(
                                offset: const Offset(0.0, -8.0),
                                child: const Text(
                                  'o', style: TextStyle(fontSize: 10, color: Colors.black),
                                ),
                              ),
                            ),
                            const TextSpan(
                              text: 'C',
                            ),
                          ],
                        ),
                      ),
                      Text(')'),
                    ],
                  )
                ],
              ),
            ),
          ],
        ),
        SizedBox(height: 5.0,),
        Row(
          children: [
            Expanded(
              flex: 2,
              child: Text('TDS',style: TextStyle(fontWeight: FontWeight.bold),),
            ),
            Expanded(
              flex: 2,
              child: Text(tds,textAlign: TextAlign.center,),
            ),
            Expanded(
              flex: 1,
              child: Text('(mg/L)'),
            ),
          ],
        ),
        SizedBox(height: 5.0,),
        Row(
          children: [
            Expanded(
              flex: 2,
              child: Text('Turbidity',style: TextStyle(fontWeight: FontWeight.bold),),
            ),
            Expanded(
              flex: 2,
              child: Text(turbidity,textAlign: TextAlign.center,),
            ),
            Expanded(
              flex: 1,
              child: Text('(NTU)'),
            ),
          ],
        ),
        SizedBox(height: 5.0,),
        Row(
          children: [
            Expanded(
              flex: 2,
              child: Text('TSS',style: TextStyle(fontWeight: FontWeight.bold),),
            ),
            Expanded(
              flex: 2,
              child: Text(tss,textAlign: TextAlign.center,),
            ),
            Expanded(
              flex: 1,
              child: Text('(mg/L)'),
            ),
          ],
        ),
        SizedBox(height: 5.0,),
        Row(
          children: [
            Expanded(
              flex: 2,
              child: Text('Battery status',style: TextStyle(fontWeight: FontWeight.bold),),
            ),
            Expanded(
              flex: 2,
              child: Text(battery,textAlign: TextAlign.center,),
            ),
            Expanded(
              flex: 1,
              child: Text('(V)'),
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
                  _sendData();
                },
                child: Text('Submit',style: TextStyle(fontWeight: FontWeight.bold,color: Colors.white),),
              ),
            ),
          ],
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return _isDisplay ? Container(
      height: MediaQuery.of(context).size.height,
      alignment: Alignment.center,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          CircularProgressIndicator(),
          Text('Data transferred in progress...please wait')
        ],
      ),
    ) : Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
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

    setState(() {
      _isDisplay = true;
    });

    var client = http.Client();
    var response = await
    client.post(Uri.parse("https://mmsv2.pstw.com.my/api/marine/api-post-marine.php"), body: {
      "action": "marine-study-sampling","reportID": _reportID.text.toString(),"firstSampler": firstSamplerName,
      "secondSampler": secondSamplerName,
      "dateController": dateController,"timeController": timeController,"type":_type,
      "stationName": _selectedStationName.text.toString(),"sampleCode": barcode,
      "latitude": _getLatitude,"longitude": _getLongitude,
      "weather": _weather,"tide": _tide,"condition":_tarball,
      "event":eventRemarks,"lab":labRemarks,
      "sondeID":sondeID,"dateCapture":dateCapture,"timeCapture":timeCapture,
      "oxygen1":doValue1,"oxygen2":doValue2,
      "pH":pH,"salinity":salinity,"ec":ec,"temp":temperature,
      "tds":tds,"turbidity":turbidity,"tss":tss,"battery":battery,
      "stationID":stationID
    });
    var data = json.decode(response.body);
    //print(data);

    if (data['statusCode']==404) {

      // upload picture
      if (_image1 != null) { // upload image 1
        final uri = Uri.parse("https://mmsv2.pstw.com.my/upload-image.php?action=marine_study_sampling&id="+stationID+"&description=left_side");
        var request = http.MultipartRequest('POST', uri);
        request.files.add(await http.MultipartFile.fromPath(
          'image',
          _image1!.path,
          filename: path.basename(_image1!.path),
        ));

        var response1 = await request.send();
      }

      // upload picture
      if (_image2 != null) { // upload image 2
        final uri = Uri.parse("https://mmsv2.pstw.com.my/upload-image.php?action=marine_study_sampling&id="+stationID+"&description=right_side");
        var request = http.MultipartRequest('POST', uri);
        request.files.add(await http.MultipartFile.fromPath(
          'image',
          _image2!.path,
          filename: path.basename(_image2!.path),
        ));

        var response1 = await request.send();
      }

      // upload picture
      if (_image3 != null) { // upload image 3
        final uri = Uri.parse("https://mmsv2.pstw.com.my/upload-image.php?action=marine_study_sampling&id="+stationID+"&description=filling_water");
        var request = http.MultipartRequest('POST', uri);
        request.files.add(await http.MultipartFile.fromPath(
          'image',
          _image3!.path,
          filename: path.basename(_image3!.path),
        ));

        var response1 = await request.send();
      }

      // upload picture
      if (_image4 != null) { // upload image 4
        final uri = Uri.parse("https://mmsv2.pstw.com.my/upload-image.php?action=marine_study_sampling&id="+stationID+"&description=seawater_in_clear_glass");
        var request = http.MultipartRequest('POST', uri);
        request.files.add(await http.MultipartFile.fromPath(
          'image',
          _image4!.path,
          filename: path.basename(_image4!.path),
        ));

        var response1 = await request.send();
      }

      // upload picture
      if (_image5 != null) { // upload image 25
        final uri = Uri.parse("https://mmsv2.pstw.com.my/upload-image.php?action=marine_study_sampling&id="+stationID+"&description=examine_preservative");
        var request = http.MultipartRequest('POST', uri);
        request.files.add(await http.MultipartFile.fromPath(
          'image',
          _image5!.path,
          filename: path.basename(_image5!.path),
        ));

        var response1 = await request.send();
      }

      // upload picture
      if (_image6 != null) { // upload image 6
        final uri = Uri.parse("https://mmsv2.pstw.com.my/upload-image.php?action=marine_study_sampling&id="+stationID+"&description=optional");
        var request = http.MultipartRequest('POST', uri);
        request.files.add(await http.MultipartFile.fromPath(
          'image',
          _image6!.path,
          filename: path.basename(_image6!.path),
        ));

        var response1 = await request.send();
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Data has been saved!",
          style: TextStyle(fontWeight: FontWeight.bold,color: Colors.white),),backgroundColor: Colors.black,),
      );

      setState(() {

        _secondSamplerName.clear();
        _selectedStation = null;
        _latitude.clear();
        _longitude.clear();
        _currentLatitude.clear();
        _currentLongitude.clear();
        _type = "";
        _barcode.clear();

        _stateName.clear();
        _categoryName.clear();
        _latitude.clear();
        _longitude.clear();
        _stationID.clear();
        _stationLatitude.clear();
        _stationLongitude.clear();
        _selectedStationName.clear();

        _isDisplay = false;
        _form1 = true;
        _form2 = false;
        _form3 = false;
        _form4 = false;
      });

    }

    else {

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Data failed to save",
          style: TextStyle(fontWeight: FontWeight.bold,color: Colors.white),),backgroundColor: Colors.red,),
      );

      setState(() {

        _secondSamplerName.clear();
        _selectedStation = null;
        _latitude.clear();
        _longitude.clear();
        _currentLatitude.clear();
        _currentLongitude.clear();
        _type = "";
        _barcode.clear();

        _stateName.clear();
        _categoryName.clear();
        _latitude.clear();
        _longitude.clear();
        _stationID.clear();
        _stationLatitude.clear();
        _stationLongitude.clear();
        _selectedStationName.clear();

        _isDisplay = false;
        _form1 = true;
        _form2 = false;
        _form3 = false;
        _form4 = false;

      });

    }

  }

}

