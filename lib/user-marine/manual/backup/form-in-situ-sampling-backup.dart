import 'dart:async';
import 'dart:io';
import 'dart:math';
import 'dart:typed_data';
import 'package:app_settings/app_settings.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_blue_classic/flutter_blue_classic.dart';
//import 'package:flutter_blue_plus/flutter_blue_plus.dart';
//import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import 'package:geolocator/geolocator.dart';
import 'dart:ui';
import 'package:http/http.dart' as http;
import 'package:image/image.dart' as img;
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server/gmail.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:simple_barcode_scanner/simple_barcode_scanner.dart';
import 'package:usb_serial/transaction.dart';
import 'package:usb_serial/usb_serial.dart';
import 'package:path/path.dart' as path;
import '../../../bluetooth/bluetooth_manager.dart';
import '../../../bluetooth/widget/bluetooth_device_list_dialog.dart';
import '../../../db_helper.dart';
import '../../../object-class/local-object-distinct-location.dart';
import '../../../object-class/local-object-location.dart';
import '../../../object-class/local-object-state.dart';
import '../../../object-class/local-object-user.dart';
import '../../../object-state.dart';
import '../../../object-station.dart';
import '../../../serial_manager.dart';
import '../../../widget/serial_port_list_dialog.dart';

class SFormInSituSampleBackup extends StatefulWidget {
  _SFormInSituSampleBackup createState() => _SFormInSituSampleBackup();
}

class _SFormInSituSampleBackup extends State<SFormInSituSampleBackup> {

  bool _isDisplay = false;
  bool _isCategory = false;
  bool _isLocation = false;
  bool _isDeviceUSB = false;
  bool _isDeviceBluetooth = false;

  final TextEditingController _firstSamplerName = TextEditingController();
  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _timeController = TextEditingController();
  TextEditingController _barcode = TextEditingController();
  TextEditingController _sondeID = TextEditingController();

  final TextEditingController _dateCapture = TextEditingController();
  final TextEditingController _timeCapture = TextEditingController();

  TextEditingController _stateName = TextEditingController();
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

  late String firstSamplerName='',secondSamplerName='',_type = 'Schedule';
  late String dateController='', timeController='';
  late String dateCapture='', timeCapture='';
  late String eventRemarks='',labRemarks='';

  late String? timestampResult1,timestampResult2;
  double _distanceDevice = 0;

  late String _weather = '',_tide = '',_tarball = '';
  late String _special_1 = 'μ';

  bool _form1 = true;
  bool _form2 = false;
  bool _form3 = false;
  bool _form4 = false;

  final _formInSitu1 = GlobalKey<FormState>();
  final _formInSitu2 = GlobalKey<FormState>();
  final _formInSitu3 = GlobalKey<FormState>();
  final _formInSitu4 = GlobalKey<FormState>();

  //final FlutterBluePlus flutterBlue = FlutterBluePlus();
  //BluetoothDevice? ysiDevice;
  //BluetoothCharacteristic? readCharacteristic;

  //List<UsbDevice> devices = [];
  UsbPort? port;
  bool isConnected = false;
  StreamSubscription<Uint8List>? inputStreamSubscription;
  late String rawData = "";

  final List<String> items = ['Schedule'];
  late String selectedItem = 'Schedule';

  TextEditingController _uuidData = TextEditingController();
  TextEditingController _doData1 = TextEditingController();
  TextEditingController _doData2 = TextEditingController();
  TextEditingController _phData = TextEditingController();
  TextEditingController _sanilityData = TextEditingController();
  TextEditingController _ecData = TextEditingController();
  TextEditingController _tempData = TextEditingController();
  TextEditingController _tdsData = TextEditingController();
  TextEditingController _turbidityData = TextEditingController();
  TextEditingController _tssData = TextEditingController();
  TextEditingController _batteryData = TextEditingController();

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
  String? stateID,categoryID;

  Station? selectedStation;
  States? selectedState;

  bool connectionStatus = true;
  final db = DBHelper();

  // declration bluetooth
  final BluetoothManager _bluetoothManager = BluetoothManager();
  bool _isLoadingBluetooth = false;

  Map<String, double> _latestReadingsBluetooth = {};

  final List<String> displayedKeys = ['Sonde ID','Oxygen Concentration',
  'Oxygen Saturation','pH', 'Salinity', 'EC', 'Temperature',
    'TDS','Turbidity','TSS','Battery Status'];

  final Map<String, TextEditingController> _controllers = {};

  @override
  void initState() {
    super.initState();
    _checkInternet();
    _getProfile();
    _loadSampler();
    _loadState();

    _reportID.text = getRandomString(10);

    var now = DateTime.now();
    var formatter = DateFormat('yyyy-MM-dd');
    String formattedDate = formatter.format(now);
    String formattedTime = DateFormat('HH:mm:ss').format(now);

    _dateController.text = formattedDate;
    _dateCapture.text = formattedDate;

    //String formattedTime = now.hour.toString()+":"+now.minute.toString()+":"+now.second.toString();
    _timeController.text = formattedTime;
    _timeCapture.text = formattedTime;

    int timestamp = DateTime.now().millisecondsSinceEpoch;
    DateTime date = DateTime.fromMillisecondsSinceEpoch(timestamp);
    String result1 = DateFormat('yyyy-MM-dd HH:mm:ss').format(date);
    String result2 = DateFormat('yyyyMMdd_HHmmss').format(date);

    setState(() {
      timestampResult1 = result1;
      timestampResult2 = result2;
    });

    _timeController.text = formattedTime;

  }

  void _onRequestBluetooth() {

    _requestPermissions().then((_) => _scanBluetooth());
    // bluetooth connection
  }

  void _scanBluetooth() {

    setState(() {
      _isDeviceUSB = false;
      _isDeviceBluetooth = true;
    });

    // Initialize controllers for each key
    for (var key in displayedKeys) {
      _controllers[key] = TextEditingController();
    }

    _bluetoothManager.connectionState.addListener(() {
      if (mounted) setState(() {});
    });

    // Listen for incoming data and store it in our "mailbox".
    _bluetoothManager.dataStream.listen((Map<String, double> readings) {
      if (mounted) {
        setState(() {

          _latestReadingsBluetooth = readings;

          readings.forEach((key, value) {
            if (_controllers.containsKey(key)) {
              _controllers[key]!.text = value.toStringAsFixed(2);
            }
          });

        });
      }
    });

  }

  Future<void> _requestPermissions() async {
    await [
      Permission.bluetooth,
      Permission.bluetoothScan,
      Permission.bluetoothConnect,
      Permission.locationWhenInUse,
    ].request();
  }

  void _connectToBluetooth() async {
    setState(() => _isLoadingBluetooth = true);

    // Get the list of paired devices.
    final devices = await _bluetoothManager.getPairedDevices();

    if (devices.isEmpty && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("No paired usb devices found.")));
      setState(() => _isLoadingBluetooth = false);
      return;
    }

    // Show the selection dialog.
    final selectedDevice = await showBluetoothDeviceListDialog(context: context, devices: devices);

    if (selectedDevice != null) {
      // If a device is selected, connect to it.
      await _bluetoothManager.connect(selectedDevice);
      // If connection is successful, start the auto-refresh.
      if (_bluetoothManager.connectionState.value == BluetoothConnectionState.connected) {
        _bluetoothManager.startAutoReading(interval: const Duration(seconds: 5));
      }
    }

    setState(() => _isLoadingBluetooth = false);
  }


  @override
  void dispose() {
    _bluetoothManager.dispose();
    super.dispose();
  }

  List<String> emailList = [];

  Future<void> fetchEmails() async {
    final response = await http.get(Uri.parse('https://mmsv2.pstw.com.my/api/marine/api-get-marine.php?action=marine-email'));

    if (response.statusCode == 200) {
      final List<dynamic> emails = jsonDecode(response.body);
      setState(() {
        emailList = emails.cast<String>();
      });
      print(emailList);
    } else {
      print('Failed to fetch emails');
    }
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
          fetchEmails();
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

  static const _chars = 'AaBbCcDdEeFfGgHhIiJjKkLlMmNnOoPpQqRrSsTtUuVvWwXxYyZz1234567890';
  Random _rnd = Random();

  String getRandomString(int length) => String.fromCharCodes(Iterable.generate(
      length, (_) => _chars.codeUnitAt(_rnd.nextInt(_chars.length))));

  List<dynamic> _marineStationList = [];
  Map<String, dynamic>? _selectedStation;

  Future<void> _getProfile() async {
    final prefs = await SharedPreferences.getInstance();

    setState(() {
      _firstSamplerName.text = prefs.getString("fullName").toString();
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

      // set latitude & longitude
      _stationLatitude.text = position.latitude.toString();
      _stationLongitude.text = position.longitude.toString();

    });

    double result = calculateDistance(double.parse(_latitude.text),double.parse(_longitude.text),double.parse(_currentLatitude.text),double.parse(_currentLongitude.text));

    setState(() {
      _distanceDevice = result;
    });
    _showDistance(context, result.toString());

    print("Latitude: ${position.latitude}, Longitude: ${position.longitude}");
  }

  void _showDistance(BuildContext context, String result) {

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Distance;'),
        content: Text('Distance between the two locations is ' + result + ' KM'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('OK'),
          ),
        ],
      ),
    );
  }

  double calculateDistance(double lat1, double lon1, double lat2, double lon2) {
    const earthRadius = 6371; // Radius of the Earth in km

    final dLat = _degreesToRadians(lat2 - lat1);
    final dLon = _degreesToRadians(lon2 - lon1);

    final a = sin(dLat / 2) * sin(dLat / 2) +
        cos(_degreesToRadians(lat1)) *
            cos(_degreesToRadians(lat2)) *
            sin(dLon / 2) * sin(dLon / 2);

    final c = 2 * atan2(sqrt(a), sqrt(1 - a));

    return earthRadius * c; // Distance in km
  }

  double _degreesToRadians(double degree) {
    return degree * pi / 180;
  }

  List<localUser> sampler1 = [];
  localUser? selectedLocalSampler;

  Future<void> _loadSampler() async {
    final data = await DBHelper.getSampler();
    setState(() {
      sampler1 = data;
    });
  }

  List<localState> state1 = [];
  localState? selectedLocalState;

  Future<void> _loadState() async {
    final data = await DBHelper.getState();
    setState(() {
      state1 = data;
    });
  }

  List<localDistinctLocation> category1 = [];
  localDistinctLocation? selectedLocalCategory;

  Future<void> _loadCategory(String? stateID) async {
    final data = await DBHelper.getCategoryInSitu(stateID);
    setState(() {
      category1 = data;
    });
  }

  List<localLocation> location1 = [];
  localLocation? selectedLocalLocation;

  Future<void> _loadLocation(String? stateID, String? categoryID) async {
    final data = await DBHelper.getLocationMarine(stateID,categoryID);
    setState(() {
      _isLocation = true;
      location1 = data;
    });
  }

  Widget _buildForm1() {
    return Form(
      key: _formInSitu1,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('IN-SITU SAMPLING',style: TextStyle(fontSize: 18,fontWeight: FontWeight.bold),),
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
                child: DropdownSearch<localUser>(
                  items: sampler1,
                  selectedItem: selectedLocalSampler,
                  itemAsString: (localUser u) => "${u.fullname}", // optional
                  popupProps: PopupProps.menu(showSearchBox: true),
                  dropdownDecoratorProps: DropDownDecoratorProps(
                    dropdownSearchDecoration: InputDecoration(
                      labelText: "2nd sampler",
                      border: OutlineInputBorder(),
                    ),
                  ),
                  onChanged: (localUser? value) {
                    setState(() {
                      selectedLocalSampler = value;
                      secondSamplerName = selectedLocalSampler!.fullname;
                    });
                    if (value != null) {
                      print("Name: ${value.fullname}");
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
                child: DropdownSearch<localState>(
                  items: state1,
                  selectedItem: selectedLocalState,
                  itemAsString: (localState u) => "${u.stateName}", // optional
                  popupProps: PopupProps.menu(showSearchBox: true),
                  dropdownDecoratorProps: DropDownDecoratorProps(
                    dropdownSearchDecoration: InputDecoration(
                      labelText: "Select state",
                      border: OutlineInputBorder(),
                    ),
                  ),
                  onChanged: (localState? value) {
                    setState(() {
                      selectedLocalState = value;
                      stateID = selectedLocalState!.stateID;
                      _selectedStateName = selectedLocalState!.stateName;

                      selectedLocalCategory = null;
                      _isCategory = true;
                      _isLocation = false;

                      _loadCategory(stateID);
                      //_loadLocation(stateID);
                    });
                    if (value != null) {
                      print("Selected ID: ${value.stateID}, Name: ${value.stateName}");
                    }
                  },
                ),
              ),
            ],
          ),
          _isCategory ? Column(
            children: [
              SizedBox(height: 10.0,),
              Row(
                children: [
                  Expanded(
                    child: DropdownSearch<localDistinctLocation>(
                      items: category1,
                      selectedItem: selectedLocalCategory,
                      itemAsString: (localDistinctLocation u) => "${u.categoryName}", // optional
                      popupProps: PopupProps.menu(showSearchBox: true),
                      dropdownDecoratorProps: DropDownDecoratorProps(
                        dropdownSearchDecoration: InputDecoration(
                          labelText: "Select category",
                          border: OutlineInputBorder(),
                        ),
                      ),
                      onChanged: (localDistinctLocation? value) {
                        setState(() {
                          selectedLocalCategory = value;
                          categoryID = selectedLocalCategory!.categoryID;
                          _selectedCategoryName = selectedLocalCategory!.categoryName;

                          selectedLocalLocation = null;
                          _loadLocation(stateID,categoryID);
                        });
                        if (value != null) {
                          print("Selected ID: ${value.categoryID}, Name: ${value.categoryName}");
                        }
                      },
                    ),
                  ),
                ],
              )
            ],
          ) : SizedBox(width: 0.0,),
          _isLocation ? Column(
            children: [
              SizedBox(height: 10.0,),
              Row(
                children: [
                  Expanded(
                    child: DropdownSearch<localLocation>(
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
                          labelText: "Select location",
                          border: OutlineInputBorder(),
                        ),
                      ),

                      onChanged: (localLocation? value) {
                        setState(() {
                          selectedLocalLocation = value;
                        });
                        if (value != null) {
                          print("Name: ${value.locationName}");

                          _selectedCategoryName = selectedLocalLocation!.categoryName;
                          _latitude.text = selectedLocalLocation!.latitude;
                          _longitude.text = selectedLocalLocation!.longitude;
                          _stationID.text = selectedLocalLocation!.stationID;

                        }
                      },
                    ),
                  ),
                ],
              ),
            ],
          ):SizedBox(height: 0.0,),
          SizedBox(height: 10.0,),
          Row(
            children: [
              Expanded(
                child: DropdownButtonFormField<String>(
                  value: selectedItem, // Set default value here
                  decoration: InputDecoration(
                    labelText: 'Type',
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (String? newValue) {
                    setState(() {
                      selectedItem = newValue!;
                      _type = selectedItem;
                      print(selectedItem);
                    });
                  },
                  items: items.map((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                  validator: (value) => value == null ? 'Please select a type' : null,
                ),
              ),
            ],
          ),
          SizedBox(height: 10.0,),
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
  final ImagePicker _picker7 = ImagePicker();
  final ImagePicker _picker8 = ImagePicker();
  final ImagePicker _picker9 = ImagePicker();

  File? _image1,_image2,_image3,_image4,_image5,_image6,_image7,_image8,_image9;
  late String _img1='',_img2='',_img3='',_img4='';

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
            //_image1 = File(photo.path);
            _img1 = '';
            _image1 = editedFile;
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
            //_image1 = File(photo.path);
            _img2 = '';
            _image2 = editedFile;
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
            //_image1 = File(photo.path);
            _img3 = '';
            _image3 = editedFile;
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
            //_image1 = File(photo.path);
            _img4 = '';
            _image4 = editedFile;
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
            //_image1 = File(photo.path);
            _image5 = editedFile;
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
            //_image1 = File(photo.path);
            _image6 = editedFile;
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

  Future<void> _takePicture7() async {
    try {
      final XFile? photo = await _picker7.pickImage(
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
            //_image1 = File(photo.path);
            _image7 = editedFile;
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

  // Function to delete the picture
  Future<void> _deletePicture7() async {
    if (_image7 != null) {
      try {
        await _image7!.delete();
        setState(() {
          _image7 = null; // Reset the image state
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

  Future<void> _takePicture8() async {
    try {
      final XFile? photo = await _picker8.pickImage(
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
            //_image1 = File(photo.path);
            _image8 = editedFile;
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

  // Function to delete the picture
  Future<void> _deletePicture8() async {
    if (_image8 != null) {
      try {
        await _image8!.delete();
        setState(() {
          _image8 = null; // Reset the image state
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

  Future<void> _takePicture9() async {
    try {
      final XFile? photo = await _picker9.pickImage(
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
            //_image1 = File(photo.path);
            _image9 = editedFile;
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

  // Function to delete the picture
  Future<void> _deletePicture9() async {
    if (_image9 != null) {
      try {
        await _image9!.delete();
        setState(() {
          _image9 = null; // Reset the image state
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
          _image1 == null ? Text(_img1,style: TextStyle(color: Colors.red,fontWeight: FontWeight.bold),)
              : SizedBox(width: 1.0,),
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
          _image2 == null ? Text(_img2,style: TextStyle(color: Colors.red,fontWeight: FontWeight.bold),)
              : SizedBox(width: 1.0,),
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
          _image3 == null ? Text(_img3,style: TextStyle(color: Colors.red,fontWeight: FontWeight.bold),)
              : SizedBox(width: 1.0,),
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
          _image4 == null ? Text(_img4,style: TextStyle(color: Colors.red,fontWeight: FontWeight.bold),)
              : SizedBox(width: 1.0,),
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
                child: Text('Photo (Optional 1)'),
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
                child: Text('Photo (Optional 2)'),
              ),
              Expanded(
                flex: 3,
                child: Align(
                  alignment: Alignment.centerRight,
                  child: IconButton(
                    onPressed: _takePicture7,
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
              _image7 != null
                  ? Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SizedBox(height: 5.0,),
                    Image.file(_image7!), // Display captured image
                    SizedBox(height: 5.0),
                    Align(
                      alignment: Alignment.centerRight,
                      child: IconButton(
                        onPressed: _deletePicture7,
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

          SizedBox(height: 5.0,),

          Row(
            children: [
              Expanded(
                flex: 2,
                child: Text('Photo (Optional 3)'),
              ),
              Expanded(
                flex: 3,
                child: Align(
                  alignment: Alignment.centerRight,
                  child: IconButton(
                    onPressed: _takePicture8,
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
              _image8 != null
                  ? Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SizedBox(height: 5.0,),
                    Image.file(_image8!), // Display captured image
                    SizedBox(height: 5.0),
                    Align(
                      alignment: Alignment.centerRight,
                      child: IconButton(
                        onPressed: _deletePicture8,
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

          SizedBox(height: 5.0,),

          Row(
            children: [
              Expanded(
                flex: 2,
                child: Text('Photo (Optional 4)'),
              ),
              Expanded(
                flex: 3,
                child: Align(
                  alignment: Alignment.centerRight,
                  child: IconButton(
                    onPressed: _takePicture9,
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
              _image9 != null
                  ? Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SizedBox(height: 5.0,),
                    Image.file(_image9!), // Display captured image
                    SizedBox(height: 5.0),
                    Align(
                      alignment: Alignment.centerRight,
                      child: IconButton(
                        onPressed: _deletePicture9,
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

          SizedBox(height: 5.0,),

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
                        setState(() {
                          _form1 = true;
                          _form2 = false;
                          _form3 = false;
                          _form4 = false;
                        });
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

                          if (_image1==null) {
                            setState(() {
                              _img1 = 'IMAGE IS REQUIRED?';
                            });
                          }
                          if (_image2==null) {
                            setState(() {
                              _img2 = 'IMAGE IS REQUIRED?';
                            });
                          }
                          if (_image3==null) {
                            setState(() {
                              _img3 = 'IMAGE IS REQUIRED?';
                            });
                          }
                          if (_image4==null) {
                            setState(() {
                              _img4 = 'IMAGE IS REQUIRED?';
                            });
                          }
                          else {
                            setState(() {
                              _form1 = false;
                              _form2 = false;
                              _form3 = true;
                              _form4 = false;
                            });
                          }

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

  final SerialManager _serialManager = SerialManager();
  bool _isLoading = false;
  Map<String, double> _latestReadings = {};
  String _statusMessage = '';

  static const platform = MethodChannel('com.example.usb_serial_pl2303/usb');

  void _connectToSerial() {
    setState(() {
      _isDeviceUSB = true;
      _isDeviceBluetooth = false;
    });

    _serialManager.connectionState.addListener(() {
      if (mounted) setState(() {});
    });
    _serialManager.dataStream.listen((Map<String, double> readings) {
      if (mounted) {
        setState(() {
          _latestReadings = readings;
          _statusMessage = 'Data received successfully';
        });
      }
    });
    _listDevices();

  }

  Future<void> _listDevices() async {
    try {
      List<UsbDevice> devices = await UsbSerial.listDevices();
      for (UsbDevice device in devices) {
        print('Device: ${device.productName}, VID: ${device.vid}, PID: ${device.pid}, Manufacturer: ${device.manufacturerName}, DeviceId: ${device.deviceId}');
      }
    } catch (e) {
      print("Error listing devices: $e");
    }
  }

  Future<bool> requestUsbPermission(UsbDevice device) async {
    try {
      final result = await platform.invokeMethod('requestUsbPermission', {
        'deviceName': device.productName ?? 'Unknown Device',
        'vid': device.vid,
        'pid': device.pid,
      });
      print("Permission requested for ${device.productName}: $result");
      if (mounted) {
        setState(() {
          _statusMessage = 'Permission requested for ${device.productName}';
        });
      }
      return result == true;
    } on PlatformException catch (e) {
      print("Failed to request USB permission: ${e.message}");
      if (mounted) {
        setState(() {
          _statusMessage = 'Failed to request permission: ${e.message}';
        });
      }
      return false;
    }
  }

  void _connectToDevice() async {
    setState(() => _isLoading = true);
    final devices = await _serialManager.getAvailableDevices();
    if (devices.isEmpty && mounted) {
      setState(() {
        _statusMessage = 'No serial devices found';
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("No serial devices found.")));
      return;
    }
    final selectedDevice = await showSerialPortListDialog(context: context, devices: devices);
    if (selectedDevice != null) {
      bool permissionGranted = await requestUsbPermission(selectedDevice);
      if (permissionGranted) {
        try {
          await _serialManager.connect(selectedDevice);
          if (_serialManager.connectionState.value == SerialConnectionState.connected && mounted) {
            setState(() {
              _statusMessage = 'Connected to ${selectedDevice.productName}';
            });
            _serialManager.startAutoReading(interval: const Duration(seconds: 5));
          }
        } catch (e) {
          if (mounted) {
            setState(() {
              _statusMessage = 'Connection failed: $e';
            });
          }
        }
      } else {
        if (mounted) {
          setState(() {
            _statusMessage = 'Permission not granted for ${selectedDevice.productName}';
          });
        }
      }
    }
    if (mounted) {
      setState(() => _isLoading = false);
    }
  }

  // bluetooth connection

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
                    _connectToSerial();
                  },
                  child: Text('COMMUNICATE VIA SERIAL',textAlign: TextAlign.center,),
                ),
              ),
              SizedBox(width: 10.0,),
              Expanded(
                child: TextButton(
                  onPressed: () {
                    _onRequestBluetooth();
                    //_startBluetooth();
                  },
                  child: Text('COMMUNICATE VIA BLUETOOTH',textAlign: TextAlign.center,),
                ),
              ),
            ],
          ),
          SizedBox(height: 5.0,),

          _isDeviceUSB ? Row(
            children: [
              Expanded(
                child: Column(
                  children: [
                    SizedBox(height: 8),
                    //Text("Available Devices:", style: TextStyle(fontWeight: FontWeight.bold)),
                    const Text("Connect to Sonde via Serial", style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 5),
                    ValueListenableBuilder<SerialConnectionState>(
                      valueListenable: _serialManager.connectionState,
                      builder: (context, state, child) {
                        Color statusColor = Colors.red;
                        String statusText = "Disconnected";
                        if (state == SerialConnectionState.connected) {
                          statusColor = Colors.green;
                          statusText = "Connected to ${_serialManager.connectedDeviceName}";
                        } else if (state == SerialConnectionState.connecting) {
                          statusColor = Colors.orange;
                          statusText = "Connecting...";
                        }
                        return Text(statusText, style: TextStyle(color: statusColor, fontWeight: FontWeight.bold, fontSize: 16));
                      },
                    ),
                    SizedBox(height: 5),
                    Text(_statusMessage, style: const TextStyle(fontSize: 14, color: Colors.grey)),
                    SizedBox(height: 5),
                    _isLoading
                        ? const CircularProgressIndicator()
                        : ElevatedButton.icon(
                      icon: const Icon(Icons.usb),
                      label: Text(_serialManager.connectionState.value == SerialConnectionState.connected ? 'Disconnect' : 'Connect to Serial Device'),
                      onPressed: () {
                        if (_serialManager.connectionState.value == SerialConnectionState.connected) {
                          _serialManager.disconnect();
                          setState(() {
                            _statusMessage = 'Disconnected';
                          });
                        } else {
                          _connectToDevice();
                        }
                      },
                    ),
                  ],
                ),
              ),
            ],
          ) : SizedBox(width: 0.0,),

          // bluetooth display
          _isDeviceBluetooth ? Center(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text("Connect to Sonde via Bluetooth", style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                ValueListenableBuilder<BluetoothConnectionState>(
                  valueListenable: _bluetoothManager.connectionState,
                  builder: (context, state, child) {
                    Color statusColor = Colors.red;
                    String statusText = "Disconnected";
                    if (state == BluetoothConnectionState.connected) {
                      statusColor = Colors.green;
                      statusText = "Connected to ${_bluetoothManager.connectedDeviceName}";
                    } else if (state == BluetoothConnectionState.connecting) {
                      statusColor = Colors.orange;
                      statusText = "Connecting...";
                    }
                    return Text(statusText, style: TextStyle(color: statusColor, fontWeight: FontWeight.bold, fontSize: 16));
                  },
                ),
                SizedBox(height: 5),
                _isLoadingBluetooth
                    ? const CircularProgressIndicator()
                    : ElevatedButton.icon(
                  icon: const Icon(Icons.bluetooth_searching),
                  label: Text(_bluetoothManager.connectionState.value == BluetoothConnectionState.connected ? 'Disconnect' : 'Connect to Bluetooth Device'),
                  onPressed: () {
                    if (_bluetoothManager.connectionState.value == BluetoothConnectionState.connected) {
                      _bluetoothManager.disconnect();
                    } else {
                      _connectToBluetooth();
                    }
                  },
                ),
                SizedBox(height: 5.0,),
              ],
            ),
          ) : SizedBox(width: 1.0,),
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
                  controller: _uuidData,
                  decoration: InputDecoration(
                    contentPadding: EdgeInsets.fromLTRB(0.0, 10.0, 20.0, 10.0),
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return "Required"; // Error shown below field
                    }
                    return null; // No error
                  },
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
          _latestReadingsBluetooth.isEmpty
              ? const Text("Connect and wait for auto-refresh...", style: TextStyle(fontSize: 16, fontStyle: FontStyle.italic))
              : Column(
            // Dynamically create a Text widget for each reading in the map
            children: _latestReadingsBluetooth.entries.
            where((entry) => displayedKeys.contains(entry.key)).
            map((entry) {
              return Row(
                    children: [
                      Expanded(
                        flex: 2,
                        child: Text(entry.key),
                      ),
                      Expanded(
                        flex: 3,
                        child: TextFormField(
                          controller: _controllers[entry.key],
                          readOnly: true,
                          initialValue: entry.value.toStringAsFixed(2),
                          decoration: InputDecoration(
                            labelText: entry.key,
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ),
                    ],
                  );
                /*
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(entry.key, style: const TextStyle(fontSize: 16)),
                          Text(
                            entry.value.toStringAsFixed(2),
                            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),*/
            }).toList(),
          ),
          /*
          Row(
            children: [
              Expanded(
                flex: 3,
                child: Text('Oxygen concentration'),
              ),
              Expanded(
                flex: 2,
                child: TextFormField(
                  readOnly: true,
                  controller: _doData1,
                  decoration: InputDecoration(
                    contentPadding: EdgeInsets.fromLTRB(0.0, 10.0, 20.0, 10.0),
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return "Required"; // Error shown below field
                    }
                    return null; // No error
                  },
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
                  readOnly: true,
                  controller: _doData2,
                  decoration: InputDecoration(
                    contentPadding: EdgeInsets.fromLTRB(0.0, 10.0, 20.0, 10.0),
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return "Required"; // Error shown below field
                    }
                    return null; // No error
                  },
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
                  readOnly: true,
                  controller: _phData,
                  decoration: InputDecoration(
                    contentPadding: EdgeInsets.fromLTRB(0.0, 10.0, 20.0, 10.0),
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return "Required"; // Error shown below field
                    }
                    return null; // No error
                  },
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
                  readOnly: true,
                  controller: _sanilityData,
                  decoration: InputDecoration(
                    contentPadding: EdgeInsets.fromLTRB(0.0, 10.0, 20.0, 10.0),
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return "Required"; // Error shown below field
                    }
                    return null; // No error
                  },
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
                  readOnly: true,
                  controller: _ecData,
                  decoration: InputDecoration(
                    contentPadding: EdgeInsets.fromLTRB(0.0, 10.0, 20.0, 10.0),
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return "Required"; // Error shown below field
                    }
                    return null; // No error
                  },
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
                  readOnly: true,
                  controller: _tempData,
                  decoration: InputDecoration(
                    contentPadding: EdgeInsets.fromLTRB(0.0, 10.0, 20.0, 10.0),
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return "Required"; // Error shown below field
                    }
                    return null; // No error
                  },
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
                  readOnly: true,
                  controller: _tdsData,
                  decoration: InputDecoration(
                    contentPadding: EdgeInsets.fromLTRB(0.0, 10.0, 20.0, 10.0),
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return "Required"; // Error shown below field
                    }
                    return null; // No error
                  },
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
                  readOnly: true,
                  controller: _turbidityData,
                  decoration: InputDecoration(
                    contentPadding: EdgeInsets.fromLTRB(0.0, 10.0, 20.0, 10.0),
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return "Required"; // Error shown below field
                    }
                    return null; // No error
                  },
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
                  readOnly: true,
                  controller: _tssData,
                  decoration: InputDecoration(
                    contentPadding: EdgeInsets.fromLTRB(0.0, 10.0, 20.0, 10.0),
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return "Required"; // Error shown below field
                    }
                    return null; // No error
                  },
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
                  readOnly: true,
                  controller: _batteryData,
                  decoration: InputDecoration(
                    contentPadding: EdgeInsets.fromLTRB(0.0, 10.0, 20.0, 10.0),
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return "Required"; // Error shown below field
                    }
                    return null; // No error
                  },
                  onSaved: (value) => setState(() => battery = value!),
                ),
              ),
              Expanded(
                flex: 2,
                child: Text(' (V)'),
              ),
            ],
          ),*/
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
                    setState(() {
                      _form1 = false;
                      _form2 = true;
                      _form3 = false;
                      _form4 = false;
                    });
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
    return Form(
      key: _formInSitu4,
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
                      _form1 = true;
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
                child: connectionStatus ? ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue
                  ),
                  onPressed: () {
                    if (_formInSitu4.currentState!.validate()) {
                      _formInSitu4.currentState!.save();
                      _sendDataServer();
                    }
                  },
                  child: Text('Send PSTW/ADC',style: TextStyle(fontWeight: FontWeight.bold,color: Colors.white),),
                ) :
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue
                  ),
                  onPressed: () {
                    _sendDataLocalStorage();
                  },
                  child: Text('Submit Local Storage',style: TextStyle(fontWeight: FontWeight.bold,color: Colors.white),),
                ),
              ),
            ],
          ),
        ],
      ),
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



  double bytesToFloat(List<int> bytes) {
    var buffer = Uint8List.fromList(bytes).buffer;
    return ByteData.view(buffer).getFloat32(0, Endian.little);
  }

  /*
  /// Lists available USB devices
  void scanAndConnect() async {

    setState(() {
      _isLoading = true;
    });

    FlutterBluePlus.adapterState.listen((BluetoothAdapterState state) {
      if (state != BluetoothAdapterState.on) {
        _showBluetoothDialog();
      }


      FlutterBluePlus.startScan(timeout: Duration(seconds: 5));

      // Listen for scan results
      FlutterBluePlus.scanResults.listen((results) async {
        for (ScanResult r in results) {
          print('Found device: ${r.device.advName}');

          // Match by name or service UUID
          // if (r.device.advName.contains("YSI") || r.device.advName.contains("SONDES")) {
          if (r.device.advName.contains("YSI")) {

            setState(() {
              _devices = results;
            });

            await FlutterBluePlus.stopScan();
            await r.device.connect();

            print("Connected to ${r.device.advName}");

            // Discover services
            List<BluetoothService> services = await r.device.discoverServices();
            for (BluetoothService service in services) {
              for (BluetoothCharacteristic c in service.characteristics) {

                // set parameter
                final uuid = c.uuid.toString();

                List<int> dissolvedOxygenData = await c.read();
                double dissolvedOxygenValue = bytesToFloat(dissolvedOxygenData);

                List<int> phData = await c.read();
                double phValue = bytesToFloat(phData);

                List<int> salinityData = await c.read();
                double salinityValue = bytesToFloat(salinityData);

                List<int> ecData = await c.read();
                double ecValue = bytesToFloat(ecData);

                List<int> tempData = await c.read();
                double temperatureValue = bytesToFloat(tempData);

                List<int> tdsData = await c.read();
                double tdsValue = bytesToFloat(tdsData);

                List<int> turbidityData = await c.read();
                double turbidityValue = bytesToFloat(turbidityData);

                List<int> tssData = await c.read();
                double tssValue = bytesToFloat(tssData);

                List<int> batteryData = await c.read();
                int batteryLevelValue = batteryData[0];

                setState(() {

                  _uuidData.text = c.uuid.toString();
                  _doData1.text = dissolvedOxygenValue.toString();
                  _doData2.text = dissolvedOxygenValue.toString();
                  _phData.text = phValue.toString();
                  _sanilityData.text = salinityValue.toString();
                  _ecData.text = ecValue.toString();
                  _tempData.text = temperatureValue.toString();
                  _tdsData.text = tdsValue.toString();
                  _turbidityData.text = turbidityValue.toString();
                  _tssData.text = tssValue.toString();
                  _batteryData.text = batteryLevelValue.toString();

                  _isLoading = false;

                });

                if (c.properties.read) {
                  var value = await c.read();
                  print("Read value: $value");
                }
                if (c.properties.notify) {
                  await c.setNotifyValue(true);
                  c.onValueReceived.listen((value) {
                    print("Notification: $value");
                  });
                }
              }
            }
          }
        }
      });

      Future.delayed(Duration(seconds: 6), () {
        FlutterBluePlus.stopScan();
        if (_devices.isEmpty) {
          print('no device...');

          String ID = generateRandomSondeID();
          double dissolvedOxygenTemp = generateRandomDO();
          double phValue = generateRandomPH();
          double salinityValue = generateRandomSalinity();
          double ecValue = generateRandomEC();
          double temperatureData = generateRandomTemperature();
          double tdsValue = generateRandomTDS();
          double turbidityValue = generateRandomTurbidity();
          double tssValue = generateRandomTSS();
          int batteryLevel = generateRandomBatteryLevel();

          setState(() {

            _uuidData.text = ID;
            _doData1.text = dissolvedOxygenTemp.toString();
            _doData2.text = dissolvedOxygenTemp.toString();
            _phData.text = phValue.toString();
            _sanilityData.text = salinityValue.toString();
            _ecData.text = ecValue.toString();
            _tempData.text = temperatureData.toString();
            _tdsData.text = tdsValue.toString();
            _turbidityData.text = turbidityValue.toString();
            _tssData.text = tssValue.toString();
            _batteryData.text = batteryLevel.toString();

            _isLoading = false;
          });

        }
      });


    });

  }*/

  String generateRandomSondeID({int length = 8}) {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    Random random = Random();

    return List.generate(length, (index) => chars[random.nextInt(chars.length)]).join();
  }

  double generateRandomDO() {
    Random random = Random();
    return double.parse((random.nextDouble() * 14.0).toStringAsFixed(2));
  }

  double generateRandomPH() {
    Random random = Random();
    double ph = 6.0 + random.nextDouble() * 3.0;
    return double.parse(ph.toStringAsFixed(2));
  }

  double generateRandomSalinity() {
    Random random = Random();
    double salinity = 30.0 + random.nextDouble() * 10.0; // 30.0 to 40.0 ppt
    return double.parse(salinity.toStringAsFixed(2));
  }

  double generateRandomEC() {
    Random random = Random();
    double ec = 1000.0 + random.nextDouble() * 49000.0;
    return double.parse(ec.toStringAsFixed(2));
  }

  double generateRandomTemperature() {
    Random random = Random();
    double temp = 10.0 + random.nextDouble() * 25.0;
    return double.parse(temp.toStringAsFixed(2));
  }

  double generateRandomTDS() {
    Random random = Random();
    double tds = 100.0 + random.nextDouble() * 4900.0;
    return double.parse(tds.toStringAsFixed(2));
  }

  double generateRandomTurbidity() {
    Random random = Random();
    double turbidity = random.nextDouble() * 300.0;
    return double.parse(turbidity.toStringAsFixed(2));
  }

  double generateRandomTSS() {
    Random random = Random();
    double tss = random.nextDouble() * 1000.0;
    return double.parse(tss.toStringAsFixed(2));
  }

  int generateRandomBatteryLevel() {
    Random random = Random();
    return random.nextInt(101); // Generates integer from 0 to 100
  }

  void _showBluetoothDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Bluetooth is OFF"),
          content: Text("Please turn on Bluetooth to connect to the device."),
          actions: [
            TextButton(
              child: Text("Open Settings"),
              onPressed: () {
                Navigator.of(context).pop();
                AppSettings.openAppSettings(); // Opens Bluetooth settings
              },
            ),
            TextButton(
              child: Text("Cancel"),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        );
      },
    );
  }

  final FlutterBlueClassic bluetooth = FlutterBlueClassic();
  List<BluetoothDevice> bondedDevices = [];


  void _sendDataServer() async {

    /*
    final data = {
      'pH': _controllers['pH']?.text,
      'Salinity': _controllers['Salinity']?.text,
      'EC': _controllers['EC']?.text,
      'Temperature': _controllers['Temperature']?.text,
      'OxygenConcentration': _controllers['Oxygen Concentration']?.text,
      'OxygenSaturation': _controllers['Oxygen Saturation']?.text,
      'TDS': _controllers['TDS']?.text,
      'Turbidity': _controllers['Turbidity']?.text,
      'TSS': _controllers['TSS']?.text,
      'BatteryStatus': _controllers['Battery Status']?.text,
    };*/

    setState(() {
      _isDisplay = true;
    });

    var client = http.Client();
    var response = await
    client.post(Uri.parse("https://mmsv2.pstw.com.my/api/marine/api-post-marine.php"), body: {
      "action": "marine-insitu-sampling","reportID": _reportID.text.toString(),"firstSampler": firstSamplerName,
      "secondSampler": secondSamplerName,
      "dateController": dateController,"timeController": timeController,"type":_type,
      "stationName": _selectedStationName.text.toString(),"sampleCode": barcode,
      "latitude": _getLatitude,"longitude": _getLongitude,
      "distance":_distanceDevice.toString(),
      "weather": _weather,"tide": _tide,"condition":_tarball,
      "event":eventRemarks,"lab":labRemarks,
      "sondeID":sondeID,"dateCapture":dateCapture,"timeCapture":timeCapture,
      "oxygen1":doValue1,"oxygen2":doValue2,
      "pH":pH,"salinity":salinity,"ec":ec,"temp":temperature,
      "tds":tds,"turbidity":turbidity,"tss":tss,"battery":battery,
      "stationID":stationID,"timestamp":timestampResult1!
    });
    var data = json.decode(response.body);
    //print(data);

    if (data['statusCode']==404) {

      // email notification
      if (_distanceDevice > 50) {

        final smtpServer = gmail('pstwitdept@gmail.com', 'orfovnkgysytzseo'); // Use an App Password

        for (String email in emailList) {
          final message = Message()
            ..from = Address('pstwitdept@gmail.com', 'Notification : ')
            ..recipients.add(email)
            ..subject = 'MMS: Monitoring distance'
            ..text = '1st Sampler Name : ' + firstSamplerName.toString() +
                '\n2nd Sampler : ' + secondSamplerName.toString() +
                '\nStation ID : ' + stationID +
                '\nLocation Name : ' + _selectedStationName.toString() +
                '\nDistance : ' + _distanceDevice.toString();

          try {
            final sendReport = await send(message, smtpServer);
            print('Email sent to $email: ' + sendReport.toString());
          } catch (e) {
            print('Error sending email to $email: $e');
          }
        }

      }

      // upload picture
      if (_image1 != null) { // upload image 1
        final uri = Uri.parse("https://mmsv2.pstw.com.my/upload-image.php?action=marine_in_situ&id="+stationID+"&timestamp="+timestampResult2!+"&description=left_side");
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
        final uri = Uri.parse("https://mmsv2.pstw.com.my/upload-image.php?action=marine_in_situ&id="+stationID+"&timestamp="+timestampResult2!+"&description=right_side");
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
        final uri = Uri.parse("https://mmsv2.pstw.com.my/upload-image.php?action=marine_in_situ&id="+stationID+"&timestamp="+timestampResult2!+"&description=filling_water");
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
        final uri = Uri.parse("https://mmsv2.pstw.com.my/upload-image.php?action=marine_in_situ&id="+stationID+"&timestamp="+timestampResult2!+"&description=seawater_in_clear_glass");
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
        final uri = Uri.parse("https://mmsv2.pstw.com.my/upload-image.php?action=marine_in_situ&id="+stationID+"&timestamp="+timestampResult2!+"&description=examine_preservative");
        var request = http.MultipartRequest('POST', uri);
        request.files.add(await http.MultipartFile.fromPath(
          'image',
          _image5!.path,
          filename: path.basename(_image5!.path),
        ));

        var response1 = await request.send();
      }

      // upload picture optional 1
      if (_image6 != null) { // upload image 6
        final uri = Uri.parse("https://mmsv2.pstw.com.my/upload-image.php?action=marine_in_situ&id="+stationID+"&timestamp="+timestampResult2!+"&description=optional1");
        var request = http.MultipartRequest('POST', uri);
        request.files.add(await http.MultipartFile.fromPath(
          'image',
          _image6!.path,
          filename: path.basename(_image6!.path),
        ));

        var response1 = await request.send();
      }

      // upload picture optional 2
      if (_image7 != null) { // upload image 7
        final uri = Uri.parse("https://mmsv2.pstw.com.my/upload-image.php?action=marine_in_situ&id="+stationID+"&timestamp="+timestampResult2!+"&description=optional2");
        var request = http.MultipartRequest('POST', uri);
        request.files.add(await http.MultipartFile.fromPath(
          'image',
          _image7!.path,
          filename: path.basename(_image7!.path),
        ));

        var response1 = await request.send();
      }

      // upload picture optional 3
      if (_image8 != null) { // upload image 8
        final uri = Uri.parse("https://mmsv2.pstw.com.my/upload-image.php?action=marine_in_situ&id="+stationID+"&timestamp="+timestampResult2!+"&description=optional3");
        var request = http.MultipartRequest('POST', uri);
        request.files.add(await http.MultipartFile.fromPath(
          'image',
          _image8!.path,
          filename: path.basename(_image8!.path),
        ));

        var response1 = await request.send();
      }

      // upload picture optional 4
      if (_image9 != null) { // upload image 9
        final uri = Uri.parse("https://mmsv2.pstw.com.my/upload-image.php?action=marine_in_situ&id="+stationID+"&timestamp="+timestampResult2!+"&description=optional4");
        var request = http.MultipartRequest('POST', uri);
        request.files.add(await http.MultipartFile.fromPath(
          'image',
          _image9!.path,
          filename: path.basename(_image9!.path),
        ));

        var response1 = await request.send();
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Data has been saved!",
          style: TextStyle(fontWeight: FontWeight.bold,color: Colors.white),),backgroundColor: Colors.black,),
      );

      setState(() {

        firstSamplerName = '';
        secondSamplerName = '';
        selectedLocalSampler = null;

        _latitude.clear();
        _longitude.clear();
        _currentLatitude.clear();
        _currentLongitude.clear();
        _type = "";
        _barcode.clear();

        _stateName.clear();
        _latitude.clear();
        _longitude.clear();
        _stationID.clear();
        _stationLatitude.clear();
        _stationLongitude.clear();
        _selectedStationName.clear();

        selectedLocalState = null;
        _isDisplay = false;
        _isCategory = false;
        _isLocation = false;

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

        firstSamplerName = '';
        secondSamplerName = '';
        selectedLocalSampler = null;

        _latitude.clear();
        _longitude.clear();
        _currentLatitude.clear();
        _currentLongitude.clear();
        _type = "";
        _barcode.clear();

        _stateName.clear();
        _latitude.clear();
        _longitude.clear();
        _stationID.clear();
        _stationLatitude.clear();
        _stationLongitude.clear();
        _selectedStationName.clear();

        selectedLocalState = null;
        _isDisplay = false;
        _isCategory = false;
        _isLocation = false;

        _form1 = true;
        _form2 = false;
        _form3 = false;
        _form4 = false;

      });

    }

  }

  void _sendDataLocalStorage() async {


    final data = {
    'pH': _controllers['pH']?.text,
    'Salinity': _controllers['Salinity']?.text,
    'EC': _controllers['EC']?.text,
    'Temperature': _controllers['Temperature']?.text,
    'OxygenConcentration': _controllers['Oxygen Concentration']?.text,
    'OxygenSaturation': _controllers['Oxygen Saturation']?.text,
    'TDS': _controllers['TDS']?.text,
    'Turbidity': _controllers['Turbidity']?.text,
    'TSS': _controllers['TSS']?.text,
    'BatteryStatus': _controllers['Battery Status']?.text,
    };

    setState(() {
      _isDisplay = true;
    });

    bool success = await db.insertDataMarineInSitu(
      tableName: 'tbl_marine_insitu_sampling',
      values: {
        'reportID': _reportID.text.toString(),
        'firstSampler': firstSamplerName,
        'secondSampler': secondSamplerName,
        'dateController': dateController,
        'timeController': timeController,
        'type': _type,
        'stationName': _selectedStationName.text.toString(),
        'sampleCode': barcode,
        'latitude': _getLatitude,
        'longitude': _getLatitude,
        'distance':_distanceDevice.toString(),
        'weather': _getLatitude!,
        'tide': _getLongitude!,
        'sea': _weather,
        'eventRemarks': eventRemarks,
        'labRemarks': labRemarks,
        'sondeID': sondeID,
        'dateCapture': dateCapture,
        'timeCapture': timeCapture,
        'oxygen1': doValue1,
        'oxygen2': doValue2,
        'pH': pH,
        'sanility': salinity,
        'ec': ec,
        'temperature': temperature,
        'tds': tds,
        'turbidity': turbidity,
        'tss': tss,
        'battery': battery,
        'stationID': stationID,
        'timestamp': timestampResult1!,
      },
    );

    if (success == true) {

      // upload image
      if (_image1 != null) { // upload image 1

        File? _savedImage;
        File imageFile = File(_image1!.path);

        // Get app directory
        Directory appDir = await getApplicationDocumentsDirectory();

        // Create custom folder
        String folderName = "manual_in-situ/"+stationID;
        Directory customDir = Directory('${appDir.path}/$folderName');
        if (!await customDir.exists()) {
          await customDir.create(recursive: true);
        }

        // Create full image path
        //String fileName = path.basename(_image1!.path);
        String fileExtension = path.extension(_image1!.path);
        String fileName = stationID+'_'+timestampResult2!+'_left_side'+fileExtension;
        String savedPath = '${customDir.path}/$fileName';

        // Save image
        final savedImage = await imageFile.copy(savedPath);

        setState(() {
          _savedImage = savedImage;
        });

        print("Image saved to: $savedPath");

      }

      // upload image
      if (_image2 != null) { // upload image 2

        File? _savedImage;
        File imageFile = File(_image2!.path);

        // Get app directory
        Directory appDir = await getApplicationDocumentsDirectory();

        // Create custom folder
        String folderName = "manual_in-situ/"+stationID;
        Directory customDir = Directory('${appDir.path}/$folderName');
        if (!await customDir.exists()) {
          await customDir.create(recursive: true);
        }

        // Create full image path
        //String fileName = path.basename(_image1!.path);
        String fileExtension = path.extension(_image2!.path);
        String fileName = stationID+'_'+timestampResult2!+'_right_side'+fileExtension;
        String savedPath = '${customDir.path}/$fileName';

        // Save image
        final savedImage = await imageFile.copy(savedPath);

        setState(() {
          _savedImage = savedImage;
        });

        print("Image saved to: $savedPath");

      }

      // upload image
      if (_image3 != null) { // upload image 3

        File? _savedImage;
        File imageFile = File(_image3!.path);

        // Get app directory
        Directory appDir = await getApplicationDocumentsDirectory();

        // Create custom folder
        String folderName = "manual_in-situ/"+stationID;
        Directory customDir = Directory('${appDir.path}/$folderName');
        if (!await customDir.exists()) {
          await customDir.create(recursive: true);
        }

        // Create full image path
        //String fileName = path.basename(_image1!.path);
        String fileExtension = path.extension(_image3!.path);
        String fileName = stationID+'_'+timestampResult2!+'_filling_water'+fileExtension;
        String savedPath = '${customDir.path}/$fileName';

        // Save image
        final savedImage = await imageFile.copy(savedPath);

        setState(() {
          _savedImage = savedImage;
        });

        print("Image saved to: $savedPath");

      }

      // upload image
      if (_image4 != null) { // upload image 4

        File? _savedImage;
        File imageFile = File(_image4!.path);

        // Get app directory
        Directory appDir = await getApplicationDocumentsDirectory();

        // Create custom folder
        String folderName = "manual_in-situ/"+stationID;
        Directory customDir = Directory('${appDir.path}/$folderName');
        if (!await customDir.exists()) {
          await customDir.create(recursive: true);
        }

        // Create full image path
        //String fileName = path.basename(_image1!.path);
        String fileExtension = path.extension(_image4!.path);
        String fileName = stationID+'_'+timestampResult2!+'_seawater_in_clear_glass'+fileExtension;
        String savedPath = '${customDir.path}/$fileName';

        // Save image
        final savedImage = await imageFile.copy(savedPath);

        setState(() {
          _savedImage = savedImage;
        });

        print("Image saved to: $savedPath");

      }

      // upload image
      if (_image5 != null) { // upload image 5

        File? _savedImage;
        File imageFile = File(_image5!.path);

        // Get app directory
        Directory appDir = await getApplicationDocumentsDirectory();

        // Create custom folder
        String folderName = "manual_in-situ/"+stationID;
        Directory customDir = Directory('${appDir.path}/$folderName');
        if (!await customDir.exists()) {
          await customDir.create(recursive: true);
        }

        // Create full image path
        //String fileName = path.basename(_image1!.path);
        String fileExtension = path.extension(_image5!.path);
        String fileName = stationID+'_'+timestampResult2!+'_examine_preservative'+fileExtension;
        String savedPath = '${customDir.path}/$fileName';

        // Save image
        final savedImage = await imageFile.copy(savedPath);

        setState(() {
          _savedImage = savedImage;
        });

        print("Image saved to: $savedPath");

      }

      // upload image optional 1
      if (_image6 != null) { // upload image 6

        File? _savedImage;
        File imageFile = File(_image6!.path);

        // Get app directory
        Directory appDir = await getApplicationDocumentsDirectory();

        // Create custom folder
        String folderName = "manual_in-situ/"+stationID;
        Directory customDir = Directory('${appDir.path}/$folderName');
        if (!await customDir.exists()) {
          await customDir.create(recursive: true);
        }

        // Create full image path
        //String fileName = path.basename(_image1!.path);
        String fileExtension = path.extension(_image6!.path);
        String fileName = stationID+'_'+timestampResult2!+'_optional1'+fileExtension;
        String savedPath = '${customDir.path}/$fileName';

        // Save image
        final savedImage = await imageFile.copy(savedPath);

        setState(() {
          _savedImage = savedImage;
        });

        print("Image saved to: $savedPath");

      }

      // upload image optional 2
      if (_image7 != null) { // upload image 7

        File? _savedImage;
        File imageFile = File(_image7!.path);

        // Get app directory
        Directory appDir = await getApplicationDocumentsDirectory();

        // Create custom folder
        String folderName = "manual_in-situ/"+stationID;
        Directory customDir = Directory('${appDir.path}/$folderName');
        if (!await customDir.exists()) {
          await customDir.create(recursive: true);
        }

        // Create full image path
        //String fileName = path.basename(_image1!.path);
        String fileExtension = path.extension(_image7!.path);
        String fileName = stationID+'_'+timestampResult2!+'_optional2'+fileExtension;
        String savedPath = '${customDir.path}/$fileName';

        // Save image
        final savedImage = await imageFile.copy(savedPath);

        setState(() {
          _savedImage = savedImage;
        });

        print("Image saved to: $savedPath");

      }

      // upload image optional 3
      if (_image8 != null) { // upload image 8

        File? _savedImage;
        File imageFile = File(_image8!.path);

        // Get app directory
        Directory appDir = await getApplicationDocumentsDirectory();

        // Create custom folder
        String folderName = "manual_in-situ/"+stationID;
        Directory customDir = Directory('${appDir.path}/$folderName');
        if (!await customDir.exists()) {
          await customDir.create(recursive: true);
        }

        // Create full image path
        //String fileName = path.basename(_image1!.path);
        String fileExtension = path.extension(_image8!.path);
        String fileName = stationID+'_'+timestampResult2!+'_optional3'+fileExtension;
        String savedPath = '${customDir.path}/$fileName';

        // Save image
        final savedImage = await imageFile.copy(savedPath);

        setState(() {
          _savedImage = savedImage;
        });

        print("Image saved to: $savedPath");

      }

      // upload image optional 4
      if (_image9 != null) { // upload image 9

        File? _savedImage;
        File imageFile = File(_image9!.path);

        // Get app directory
        Directory appDir = await getApplicationDocumentsDirectory();

        // Create custom folder
        String folderName = "manual_in-situ/"+stationID;
        Directory customDir = Directory('${appDir.path}/$folderName');
        if (!await customDir.exists()) {
          await customDir.create(recursive: true);
        }

        // Create full image path
        //String fileName = path.basename(_image1!.path);
        String fileExtension = path.extension(_image9!.path);
        String fileName = stationID+'_'+timestampResult2!+'_optional4'+fileExtension;
        String savedPath = '${customDir.path}/$fileName';

        // Save image
        final savedImage = await imageFile.copy(savedPath);

        setState(() {
          _savedImage = savedImage;
        });

        print("Image saved to: $savedPath");

      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Data has been saved!",
          style: TextStyle(fontWeight: FontWeight.bold,color: Colors.white),),backgroundColor: Colors.black,),
      );

      setState(() {

        firstSamplerName = '';
        secondSamplerName = '';
        selectedLocalSampler = null;

        _latitude.clear();
        _longitude.clear();
        _currentLatitude.clear();
        _currentLongitude.clear();
        _type = "";
        _barcode.clear();

        _stateName.clear();
        _latitude.clear();
        _longitude.clear();
        _stationID.clear();
        _stationLatitude.clear();
        _stationLongitude.clear();
        _selectedStationName.clear();

        selectedLocalState = null;
        _isDisplay = false;
        _isCategory = false;
        _isLocation = false;

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

        firstSamplerName = '';
        secondSamplerName = '';
        selectedLocalSampler = null;

        _latitude.clear();
        _longitude.clear();
        _currentLatitude.clear();
        _currentLongitude.clear();
        _type = "";
        _barcode.clear();

        _stateName.clear();
        _latitude.clear();
        _longitude.clear();
        _stationID.clear();
        _stationLatitude.clear();
        _stationLongitude.clear();
        _selectedStationName.clear();

        selectedLocalState = null;
        _isDisplay = false;
        _isCategory = false;
        _isLocation = false;

        _form1 = true;
        _form2 = false;
        _form3 = false;
        _form4 = false;

      });

    }

  }

}

