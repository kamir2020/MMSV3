import 'dart:io';
import 'package:app_mms/object-class/object-local-air-install.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image/image.dart' as img;
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../../db_helper.dart';
import '../../object-station-air-install.dart';
import '../../object-station-air.dart';
import 'package:path/path.dart' as path;

class SFormAirCollectionSample extends StatefulWidget {
  _SFormAirCollectionSample createState() => _SFormAirCollectionSample();
}

class _SFormAirCollectionSample extends State<SFormAirCollectionSample> {

  bool _isDisplay = false;
  bool isViewList = true;
  late String _type = '';

  TextEditingController _clientID = TextEditingController();
  TextEditingController _temp = TextEditingController();
  TextEditingController _flowRate1 = TextEditingController();
  TextEditingController _flowRateResult1 = TextEditingController();
  TextEditingController _totalTime1 = TextEditingController();
  TextEditingController _totalTimeResult1 = TextEditingController();
  TextEditingController _pressure1 = TextEditingController();
  TextEditingController _pressureResult1 = TextEditingController();
  TextEditingController _vstd1 = TextEditingController();

  TextEditingController _flowRate2 = TextEditingController();
  TextEditingController _flowRateResult2 = TextEditingController();
  TextEditingController _totalTime2 = TextEditingController();
  TextEditingController _totalTimeResult2 = TextEditingController();
  TextEditingController _pressure2 = TextEditingController();
  TextEditingController _pressureResult2 = TextEditingController();
  TextEditingController _vstd2 = TextEditingController();

  TextEditingController _remark = TextEditingController();

  late String? clientID,region,temp,flowRate1,flowRateResult1,totalTime1,totalTimeResult1;
  late String? pressure1,pressureResult1,remark;
  late String? flowRate2,flowRateResult2;
  late String? totalTime2,totalTimeResult2, pressure2,pressureResult2;
  late String? vstd1,vstd2;
  late String _weather = '';

  late String? _selectedCurrentTemp;
  String? _selectedID;
  String? _selectedRefID;
  String? _selectedStationID;
  StationAirInstall? selectedStation;

  final _formAirCollection = GlobalKey<FormState>();

  late String? timestampResult1,timestampResult2;
  bool connectionStatus = true;

  @override
  void initState() {
    super.initState();
    _checkInternet();
    _getProfile();

    var now = DateTime.now();
    var formatter = DateFormat('yyyy-MM-dd');
    String formattedDate = formatter.format(now);
    String formattedTime = DateFormat('HH:mm:ss').format(now);

    int timestamp = DateTime.now().millisecondsSinceEpoch;
    DateTime date = DateTime.fromMillisecondsSinceEpoch(timestamp);
    String result1 = DateFormat('yyyy-MM-dd HH:mm:ss').format(date);
    String result2 = DateFormat('yyyyMMdd_HHmmss').format(date);

    setState(() {
      timestampResult1 = result1;
      timestampResult2 = result2;
    });

  }

  Future<void> _checkInternet() async {
    var connectivityResult = await Connectivity().checkConnectivity();

    if (connectivityResult == ConnectivityResult.none) {
      setState(() {
        connectionStatus = false;
        _loadLocalAirInstall();
      });
      return;
    }

    // Check actual internet access
    try {
      final result = await http.get(Uri.parse('https://google.com')).timeout(Duration(seconds: 5));
      if (result.statusCode == 200) {
        setState(() {
          connectionStatus = true;
          fetchItems();
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

  Future<void> _getProfile() async {
    final prefs = await SharedPreferences.getInstance();

    setState(() {
      _clientID.text = prefs.getString("fullName").toString();
    });

  }

  Future<List<StationAirInstall>> fetchItems() async {
    final response = await http.get(Uri.parse("https://mmsv2.pstw.com.my/api/air/api-get-air.php?action=air-collection"));
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      print(data);

      if (data['status']=='success') {

        final List jsonList = data['data'];
        return jsonList.map((json) => StationAirInstall.fromJson(json)).toList();
      }
      else {
        return [];
      }
    } else {
      throw Exception('Failed to load items');
    }
  }

  List<localAirInstall> airInstall = [];
  localAirInstall? selectedLocalAirInstall;
  String? _selectedLocalAirRefID;

  Future<void> _loadLocalAirInstall() async {
    final data = await DBHelper.getInstallAir();
    setState(() {
      airInstall = data;
    });
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
          img.drawString(
              originalImage!, img.arial_14, 2, 12, timestampResult1!);

          // Save string to file
          final tempDir = await getTemporaryDirectory();
          final filePath = path.join(
              tempDir.path, 'edited_${path.basename(photo.path)}');
          final editedFile = File(filePath)
            ..writeAsBytesSync(img.encodeJpg(originalImage));

          setState(() {
            //_image1 = File(photo.path);
            _image1 = editedFile;
          });
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

        final bytes = await photo.readAsBytes();
        final decodedImage = img.decodeImage(bytes);

        // drawing text
        img.Image? originalImage = img.decodeImage(bytes);

        if (decodedImage != null && decodedImage.width > decodedImage.height) {
          // save string
          img.drawString(
              originalImage!, img.arial_14, 2, 12, timestampResult1!);

          // Save string to file
          final tempDir = await getTemporaryDirectory();
          final filePath = path.join(
              tempDir.path, 'edited_${path.basename(photo.path)}');
          final editedFile = File(filePath)
            ..writeAsBytesSync(img.encodeJpg(originalImage));

          setState(() {
            //_image1 = File(photo.path);
            _image1 = editedFile;
          });
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

  final ImagePicker _picker2 = ImagePicker();
  File? _image2;

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
          img.drawString(
              originalImage!, img.arial_14, 2, 12, timestampResult1!);

          // Save string to file
          final tempDir = await getTemporaryDirectory();
          final filePath = path.join(
              tempDir.path, 'edited_${path.basename(photo.path)}');
          final editedFile = File(filePath)
            ..writeAsBytesSync(img.encodeJpg(originalImage));

          setState(() {
            //_image2 = File(photo.path);
            _image2 = editedFile;
          });
        }
      }
    } catch (e) {
      print("Error while capturing image: $e");
    }
  }

  Future<void> _takePicture2a(ImageSource source) async {
    try {
      final XFile? photo = await _picker2.pickImage(source: source);

      if (photo != null) {

        final bytes = await photo.readAsBytes();
        final decodedImage = img.decodeImage(bytes);

        // drawing text
        img.Image? originalImage = img.decodeImage(bytes);

        if (decodedImage != null && decodedImage.width > decodedImage.height) {
          // save string
          img.drawString(
              originalImage!, img.arial_14, 2, 12, timestampResult1!);

          // Save string to file
          final tempDir = await getTemporaryDirectory();
          final filePath = path.join(
              tempDir.path, 'edited_${path.basename(photo.path)}');
          final editedFile = File(filePath)
            ..writeAsBytesSync(img.encodeJpg(originalImage));

          setState(() {
            //_image2 = File(photo.path);
            _image2 = editedFile;
          });
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

  final ImagePicker _picker3 = ImagePicker();
  File? _image3;

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
          img.drawString(
              originalImage!, img.arial_14, 2, 12, timestampResult1!);

          // Save string to file
          final tempDir = await getTemporaryDirectory();
          final filePath = path.join(
              tempDir.path, 'edited_${path.basename(photo.path)}');
          final editedFile = File(filePath)
            ..writeAsBytesSync(img.encodeJpg(originalImage));

          setState(() {
            //_image3 = File(photo.path);
            _image3 = editedFile;
          });
        }
      }
    } catch (e) {
      print("Error while capturing image: $e");
    }
  }

  Future<void> _takePicture3a(ImageSource source) async {
    try {
      final XFile? photo = await _picker3.pickImage(source: source);

      if (photo != null) {

        final bytes = await photo.readAsBytes();
        final decodedImage = img.decodeImage(bytes);

        // drawing text
        img.Image? originalImage = img.decodeImage(bytes);

        if (decodedImage != null && decodedImage.width > decodedImage.height) {
          // save string
          img.drawString(
              originalImage!, img.arial_14, 2, 12, timestampResult1!);

          // Save string to file
          final tempDir = await getTemporaryDirectory();
          final filePath = path.join(
              tempDir.path, 'edited_${path.basename(photo.path)}');
          final editedFile = File(filePath)
            ..writeAsBytesSync(img.encodeJpg(originalImage));

          setState(() {
            //_image3 = File(photo.path);
            _image3 = editedFile;
          });
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

  final ImagePicker _picker4 = ImagePicker();
  File? _image4;

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
          img.drawString(
              originalImage!, img.arial_14, 2, 12, timestampResult1!);

          // Save string to file
          final tempDir = await getTemporaryDirectory();
          final filePath = path.join(
              tempDir.path, 'edited_${path.basename(photo.path)}');
          final editedFile = File(filePath)
            ..writeAsBytesSync(img.encodeJpg(originalImage));

          setState(() {
            //_image4 = File(photo.path);
            _image4 = editedFile;
          });
        }
      }
    } catch (e) {
      print("Error while capturing image: $e");
    }
  }

  Future<void> _takePicture4a(ImageSource source) async {
    try {
      final XFile? photo = await _picker4.pickImage(source: source);

      if (photo != null) {

        final bytes = await photo.readAsBytes();
        final decodedImage = img.decodeImage(bytes);

        // drawing text
        img.Image? originalImage = img.decodeImage(bytes);

        if (decodedImage != null && decodedImage.width > decodedImage.height) {
          // save string
          img.drawString(
              originalImage!, img.arial_14, 2, 12, timestampResult1!);

          // Save string to file
          final tempDir = await getTemporaryDirectory();
          final filePath = path.join(
              tempDir.path, 'edited_${path.basename(photo.path)}');
          final editedFile = File(filePath)
            ..writeAsBytesSync(img.encodeJpg(originalImage));

          setState(() {
            //_image4 = File(photo.path);
            _image4 = editedFile;
          });
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

  final ImagePicker _picker5 = ImagePicker();
  File? _image5;

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
          img.drawString(
              originalImage!, img.arial_14, 2, 12, timestampResult1!);

          // Save string to file
          final tempDir = await getTemporaryDirectory();
          final filePath = path.join(
              tempDir.path, 'edited_${path.basename(photo.path)}');
          final editedFile = File(filePath)
            ..writeAsBytesSync(img.encodeJpg(originalImage));

          setState(() {
            //_image5 = File(photo.path);
            _image5 = editedFile;
          });
        }
      }
    } catch (e) {
      print("Error while capturing image: $e");
    }
  }

  Future<void> _takePicture5a(ImageSource source) async {
    try {
      final XFile? photo = await _picker5.pickImage(source: source);

      if (photo != null) {

        final bytes = await photo.readAsBytes();
        final decodedImage = img.decodeImage(bytes);

        // drawing text
        img.Image? originalImage = img.decodeImage(bytes);

        if (decodedImage != null && decodedImage.width > decodedImage.height) {
          // save string
          img.drawString(
              originalImage!, img.arial_14, 2, 12, timestampResult1!);

          // Save string to file
          final tempDir = await getTemporaryDirectory();
          final filePath = path.join(
              tempDir.path, 'edited_${path.basename(photo.path)}');
          final editedFile = File(filePath)
            ..writeAsBytesSync(img.encodeJpg(originalImage));

          setState(() {
            //_image5 = File(photo.path);
            _image5 = editedFile;
          });
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

  final ImagePicker _picker6 = ImagePicker();
  File? _image6;

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
          img.drawString(
              originalImage!, img.arial_14, 2, 12, timestampResult1!);

          // Save string to file
          final tempDir = await getTemporaryDirectory();
          final filePath = path.join(
              tempDir.path, 'edited_${path.basename(photo.path)}');
          final editedFile = File(filePath)
            ..writeAsBytesSync(img.encodeJpg(originalImage));

          setState(() {
            //_image6 = File(photo.path);
            _image6 = editedFile;
          });
        }
      }
    } catch (e) {
      print("Error while capturing image: $e");
    }
  }

  Future<void> _takePicture6a(ImageSource source) async {
    try {
      final XFile? photo = await _picker6.pickImage(source: source);

      if (photo != null) {

        final bytes = await photo.readAsBytes();
        final decodedImage = img.decodeImage(bytes);

        // drawing text
        img.Image? originalImage = img.decodeImage(bytes);

        if (decodedImage != null && decodedImage.width > decodedImage.height) {
          // save string
          img.drawString(
              originalImage!, img.arial_14, 2, 12, timestampResult1!);

          // Save string to file
          final tempDir = await getTemporaryDirectory();
          final filePath = path.join(
              tempDir.path, 'edited_${path.basename(photo.path)}');
          final editedFile = File(filePath)
            ..writeAsBytesSync(img.encodeJpg(originalImage));

          setState(() {
            //_image6 = File(photo.path);
            _image6 = editedFile;
          });
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

  Widget _viewAirInstall() {
    return Form(
      key: _formAirCollection,
      child: Column(
        children: [
          Center(
            child: Text('Data collection:',
              style: TextStyle(fontWeight: FontWeight.bold,fontSize: 16),),
          ),
          SizedBox(height: 10.0,),
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  readOnly: true,
                  controller: _clientID,
                  decoration: InputDecoration(
                    labelText: 'Client ID',
                    contentPadding: EdgeInsets.fromLTRB(10.0, 10.0, 20.0, 10.0),
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'Client ID';
                    }
                  },
                  onSaved: (value) => setState(() => clientID = value!),
                ),
              ),
            ],
          ),
          SizedBox(height: 10.0,),

          connectionStatus ? Row(
            children: [
              Expanded(
                child: DropdownSearch<StationAirInstall>(
                  asyncItems: (filter) => fetchItems(),
                  itemAsString: (StationAirInstall p) => "${p.id} - ${p.stationID} - ${p.locationName} - ${p.timestamp}", // show product_name only
                  popupProps: PopupProps.menu(
                    showSearchBox: true,
                    emptyBuilder: (context, searchEntry) => Center(
                      child: Text("No records found"),
                    ),
                  ),
                  dropdownDecoratorProps: DropDownDecoratorProps(
                    baseStyle: TextStyle(fontSize: 12),
                    dropdownSearchDecoration: InputDecoration(
                      labelText: "Choose station",
                      border: OutlineInputBorder(),
                    ),
                  ),
                  onChanged: (StationAirInstall? value) {
                    setState(() {
                      selectedStation = value;
                      _selectedID = selectedStation!.refID;
                      _selectedStationID = selectedStation!.stationID;
                      _selectedCurrentTemp = selectedStation!.temp;
                      print(_selectedStationID);
                    });
                    //print("Selected: ${value?.stationID}, ID: ${value?.stateName}");
                    //print(_selectedStationID);
                  },
                ),
              )
            ],
          ) :
              Row(
                children: [
                  Expanded(
                    child: DropdownSearch<localAirInstall>(
                      items: airInstall,
                      selectedItem: selectedLocalAirInstall,
                      itemAsString: (localAirInstall p) => "${p.id} - ${p.stationID} - ${p.locationName} - ${p.timestamp}", // optional
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
                      onChanged: (localAirInstall? value) {
                        setState(() {
                          selectedLocalAirInstall = value;
                          _selectedLocalAirRefID = selectedLocalAirInstall!.refID;
                          _selectedStationID = selectedLocalAirInstall!.stationID;
                          _selectedCurrentTemp = selectedLocalAirInstall!.temp;
                        });
                        if (value != null) {
                          print(_selectedLocalAirRefID);
                          print("Station: ${value.stationID} - Name: ${value.refID}");
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
                child: DropdownButtonFormField(
                  decoration: InputDecoration(
                    labelText: 'Weather',
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
                  validator: (value) => value == null ? 'Weather' : null,
                  onSaved: (value) => setState(() => _weather = value!),
                ),
              ),
            ],
          ),
          SizedBox(height: 10.0,),
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: _temp,
                  decoration: InputDecoration(
                    labelText: 'Temperature',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(5.0)),
                    ),
                  ),
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'Temperature';
                    }
                  },
                  onSaved: (value) => setState(() => temp = value!),
                ),
              ),
            ],
          ),
          SizedBox(height: 10.0,),
          Row(
            children: [
              Expanded(
                flex: 2,
                child: TextFormField(
                  controller: _flowRate1,
                  decoration: InputDecoration(
                    labelText: 'PM10 actual flow rate',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(5.0)),
                    ),
                  ),
                  onChanged: (value) {
                    double result = double.parse(value) * 0.0283;
                    print("Value changed: " + result.toString());
                    setState(() {
                      _flowRateResult1.text = result.toStringAsFixed(4);
                    });
                  },
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'Flow rate';
                    }
                  },
                  onSaved: (value) => setState(() => flowRate1 = value!),
                ),
              ),
              SizedBox(width: 10.0,),
              Expanded(
                flex: 2,
                child: TextFormField(
                  readOnly: true,
                  controller: _flowRateResult1,
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.blueGrey[100],
                    labelText: 'Result',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(5.0)),
                    ),
                  ),
                  onSaved: (value) => setState(() => flowRateResult1 = value!),
                ),
              ),
            ],
          ),
          SizedBox(height: 10.0,),
          Row(
            children: [
              Expanded(
                flex: 2,
                child: TextFormField(
                  controller: _totalTime1,
                  decoration: InputDecoration(
                    labelText: 'PM10 Total Time',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(5.0)),
                    ),
                  ),
                  onChanged: (value) {
                    double result = double.parse(value) * 60;
                    print("Value changed: " + result.toString());
                    setState(() {
                      _totalTimeResult1.text = result.toStringAsFixed(2);
                    });
                  },
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'Total time';
                    }
                  },
                  onSaved: (value) => setState(() => totalTime1 = value!),
                ),
              ),
              SizedBox(width: 5.0,),
              Expanded(
                flex: 2,
                child: TextFormField(
                  readOnly: true,
                  controller: _totalTimeResult1,
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.blueGrey[100],
                    labelText: 'Result',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(5.0)),
                    ),
                  ),
                  onSaved: (value) => setState(() => totalTimeResult1 = value!),
                ),
              ),
            ],
          ),
          SizedBox(height: 10.0,),
          Row(
            children: [
              Expanded(
                flex: 2,
                child: TextFormField(
                  controller: _pressure1,
                  decoration: InputDecoration(
                    labelText: 'PM10 Pressure',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(5.0)),
                    ),
                  ),
                  onChanged: (value) {
                    double result = double.parse(value) * 0.0295;
                    print("Value changed: " + result.toString());
                    setState(() {
                      _pressureResult1.text = result.toStringAsFixed(2);
                      double resultTemp = (double.parse(_selectedCurrentTemp!) + double.parse(_temp.text))/2;

                      if ((_flowRate1.text.isNotEmpty)&&(_pressure1.text.isNotEmpty)) {

                        double column1 = 760 * (273 + resultTemp);
                        double column2 = (double.parse(_flowRate1.text) * double.parse(_pressureResult1.text) * 298);

                        // 228380
                        // 369222.00
                        double std1 = column2 / column1;
                        double vstd1 = std1 * double.parse(_totalTimeResult1.text);
                        _vstd1.text = vstd1.toStringAsFixed(3);
                      }
                      else {
                        double std1 = 0.00;
                        _vstd1.text = std1.toStringAsFixed(3);
                      }

                    });
                  },
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'Pressure';
                    }
                  },
                  onSaved: (value) => setState(() => pressure1 = value!),
                ),
              ),
              SizedBox(width: 5.0,),
              Expanded(
                flex: 2,
                child: TextFormField(
                  readOnly: true,
                  controller: _pressureResult1,
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.blueGrey[100],
                    labelText: 'Result',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(5.0)),
                    ),
                  ),
                  onSaved: (value) => setState(() => pressureResult1 = value!),
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
                  controller: _vstd1,
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.yellow,
                    labelText: 'VSTD PM10',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(5.0)),
                    ),
                  ),
                  onSaved: (value) => setState(() => vstd1 = value!),
                ),
              ),
            ],
          ),
          SizedBox(height: 10.0,),
          Row(
            children: [
              Expanded(
                flex: 2,
                child: TextFormField(
                  controller: _flowRate2,
                  decoration: InputDecoration(
                    labelText: 'PM2.5 actual flow rate',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(5.0)),
                    ),
                  ),
                  onChanged: (value) {
                    double result = double.parse(value) * 0.0283;
                    print("Value changed: " + result.toString());
                    setState(() {
                      _flowRateResult2.text = result.toStringAsFixed(4);
                    });
                  },
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'Flow rate';
                    }
                  },
                  onSaved: (value) => setState(() => flowRate2 = value!),
                ),
              ),
              SizedBox(width: 5.0,),
              Expanded(
                flex: 2,
                child: TextFormField(
                  readOnly: true,
                  controller: _flowRateResult2,
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.blueGrey[100],
                    labelText: 'Result',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(5.0)),
                    ),
                  ),

                  onSaved: (value) => setState(() => flowRateResult2 = value!),
                ),
              ),
            ],
          ),
          SizedBox(height: 10,),
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: _totalTime2,
                  decoration: InputDecoration(
                    labelText: 'PM2.5 Total Time',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(5.0)),
                    ),
                  ),
                  onChanged: (value) {
                    double result = double.parse(value) * 60;
                    print("Value changed: " + result.toString());
                    setState(() {
                      _totalTimeResult2.text = result.toStringAsFixed(2);
                    });
                  },
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'Total time';
                    }
                  },
                  onSaved: (value) => setState(() => totalTime2 = value!),
                ),
              ),
              SizedBox(width: 5.0,),
              Expanded(
                child: TextFormField(
                  readOnly: true,
                  controller: _totalTimeResult2,
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.blueGrey[100],
                    labelText: 'Result',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(5.0)),
                    ),
                  ),
                  onSaved: (value) => setState(() => totalTimeResult2 = value!),
                ),
              ),
            ],
          ),
          SizedBox(height: 10.0,),
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: _pressure2,
                  decoration: InputDecoration(
                    labelText: 'PM2.5 Pressure',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(5.0)),
                    ),
                  ),
                  onChanged: (value) {
                    double result = double.parse(value) * 0.0295;
                    print("Value changed: " + result.toString());
                    setState(() {
                      _pressureResult2.text = result.toStringAsFixed(2);
                      double resultTemp = (double.parse(_selectedCurrentTemp!) + double.parse(_temp.text))/2;

                      if ((_flowRate2.text.isNotEmpty)&&(_pressure2.text.isNotEmpty)) {

                        double column1 = 760 * (273 + resultTemp);
                        double column2 = (double.parse(_flowRate2.text) * double.parse(_pressureResult2.text) * 298);

                        // 228380
                        // 369222.00
                        double std1 = column2 / column1;
                        double vstd1 = std1 * double.parse(_totalTimeResult2.text);
                        _vstd2.text = vstd1.toStringAsFixed(3);
                      }
                      else {
                        double std1 = 0.00;
                        _vstd2.text = std1.toStringAsFixed(3);
                      }

                    });
                  },
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'Pressure';
                    }
                  },
                  onSaved: (value) => setState(() => pressure2 = value!),
                ),
              ),
              SizedBox(width: 5.0,),
              Expanded(
                child: TextFormField(
                  controller: _pressureResult2,
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.blueGrey[100],
                    labelText: 'Result',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(5.0)),
                    ),
                  ),
                  onSaved: (value) => setState(() => pressureResult2 = value!),
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
                  controller: _vstd2,
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.yellow,
                    labelText: 'VSTD PM10',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(5.0)),
                    ),
                  ),
                  onSaved: (value) => setState(() => vstd2 = value!),
                ),
              ),
            ],
          ),
          SizedBox(height: 5.0,),
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: _remark,
                  decoration: InputDecoration(
                    labelText: '* Remark',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(5.0)),
                    ),
                  ),
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'Remarks';
                    }
                  },
                  onSaved: (value) => setState(() => remark = value!),
                ),
              ),
            ],
          ),
          SizedBox(height: 10.0,),
          Row(
            children: [
              Expanded(
                flex: 3,
                child: Text('Take a Photo (Left)'),
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
                    ),
                  ],
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

          SizedBox(height: 10.0,),
          Row(
            children: [
              Expanded(
                flex: 3,
                child: Text('Take a Photo (Right)'),
              ),
              Expanded(
                flex: 2,
                child: Row(
                  children: [
                    Align(
                      alignment: Alignment.centerRight,
                      child: IconButton(
                        onPressed: _takePicture2,
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
                          _takePicture2a(ImageSource.gallery);
                        },
                        icon: Icon(
                          size: 30,
                          Icons.collections,
                        ),
                      ),
                    ),
                  ],
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

          SizedBox(height: 10.0,),
          Row(
            children: [
              Expanded(
                flex: 3,
                child: Text('Take a Photo (Top)'),
              ),
              Expanded(
                flex: 2,
                child: Row(
                  children: [
                    Align(
                      alignment: Alignment.centerRight,
                      child: IconButton(
                        onPressed: _takePicture3,
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
                          _takePicture3a(ImageSource.gallery);
                        },
                        icon: Icon(
                          size: 30,
                          Icons.collections,
                        ),
                      ),
                    ),
                  ],
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

          SizedBox(height: 10.0,),
          Row(
            children: [
              Expanded(
                flex: 3,
                child: Text('Take a Photo (Bottom)'),
              ),
              Expanded(
                flex: 2,
                child: Row(
                  children: [
                    Align(
                      alignment: Alignment.centerRight,
                      child: IconButton(
                        onPressed: _takePicture4,
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
                          _takePicture4a(ImageSource.gallery);
                        },
                        icon: Icon(
                          size: 30,
                          Icons.collections,
                        ),
                      ),
                    ),
                  ],
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

          SizedBox(height: 10.0,),
          Row(
            children: [
              Expanded(
                flex: 3,
                child: Text('Take a Photo (Front)'),
              ),
              Expanded(
                flex: 2,
                child: Row(
                  children: [
                    Align(
                      alignment: Alignment.centerRight,
                      child: IconButton(
                        onPressed: _takePicture5,
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
                          _takePicture5a(ImageSource.gallery);
                        },
                        icon: Icon(
                          size: 30,
                          Icons.collections,
                        ),
                      ),
                    ),
                  ],
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

          SizedBox(height: 10.0,),
          Row(
            children: [
              Expanded(
                flex: 3,
                child: Text('Take a Photo (Back)'),
              ),
              Expanded(
                flex: 2,
                child: Row(
                  children: [
                    Align(
                      alignment: Alignment.centerRight,
                      child: IconButton(
                        onPressed: _takePicture6,
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
                          _takePicture6a(ImageSource.gallery);
                        },
                        icon: Icon(
                          size: 30,
                          Icons.collections,
                        ),
                      ),
                    ),
                  ],
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

          Center(
            child: _isDisplay ? CircularProgressIndicator() :
            Container(
              width: MediaQuery.of(context).size.width,
              child: connectionStatus ? ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                ),
                onPressed: () {
                  if (_formAirCollection.currentState!.validate()) {
                    _formAirCollection.currentState!.save();
                    _sendDataServer();
                  }
                },
                child: Text('Submit to Server (PSTW)',style: TextStyle(color: Colors.white,fontWeight: FontWeight.bold),),
              ) :
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                ),
                onPressed: () {
                  if (_formAirCollection.currentState!.validate()) {
                    _formAirCollection.currentState!.save();
                    _sendDataLocalStorage();
                  }
                },
                child: Text('Submit to Local Storage',style: TextStyle(color: Colors.white,fontWeight: FontWeight.bold),),
              ),
            ),
          ),
          SizedBox(height: 20.0,),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(5.0),
      child: _viewAirInstall(),
    );
  }

  void _sendDataServer() async {

    setState(() {
      _isDisplay = true;
    });

    var client = http.Client();
    var response = await
    client.post(Uri.parse("https://mmsv2.pstw.com.my/api/air/api-post-air.php"), body: {
      "action": "air-collection","refID": _selectedID!,"clientID": clientID!,"stationID": _selectedStationID!,
      "weather":_weather,"temp":temp,
      "actual1": flowRate1!,"actualResult1":flowRateResult1!,
      "time1":totalTime1!, "timeResult1":totalTimeResult1!,
      "pressure1":pressure1!, "pressureResult1":pressureResult1!,
      "vstd1":vstd1!,
      "actual2": flowRate2!,"actualResult2":flowRateResult2!,
      "time2":totalTime2!, "timeResult2":totalTimeResult2!,
      "pressure2":pressure2!, "pressureResult2":pressureResult2!,
      "vstd2":vstd2!,
      "remark":remark!,
      "timestamp":timestampResult1!
    });
    var data = json.decode(response.body);

    if (data['statusCode']==404) {

      // upload picture
      if (_image1 != null) { // upload image 1
        final uri = Uri.parse("https://mmsv2.pstw.com.my/upload-image.php?action=air_collection&id="+_selectedID!+'&stationID='+_selectedStationID!+'&timestamp='+timestampResult2!+'&description=Data_Collection_Left');
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
        final uri = Uri.parse("https://mmsv2.pstw.com.my/upload-image.php?action=air_collection&id="+_selectedID!+'&stationID='+_selectedStationID!+'&timestamp='+timestampResult2!+'&description=Data_Collection_Right');
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
        final uri = Uri.parse("https://mmsv2.pstw.com.my/upload-image.php?action=air_collection&id="+_selectedID!+'&stationID='+_selectedStationID!+'&timestamp='+timestampResult2!+'&description=Data_Collection_Top');
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
        final uri = Uri.parse("https://mmsv2.pstw.com.my/upload-image.php?action=air_collection&id="+_selectedID!+'&stationID='+_selectedStationID!+'&timestamp='+timestampResult2!+'&description=Data_Collection_Bottom');
        var request = http.MultipartRequest('POST', uri);
        request.files.add(await http.MultipartFile.fromPath(
          'image',
          _image4!.path,
          filename: path.basename(_image4!.path),
        ));

        var response1 = await request.send();
      }

      // upload picture
      if (_image5 != null) { // upload image 5
        final uri = Uri.parse("https://mmsv2.pstw.com.my/upload-image.php?action=air_collection&id="+_selectedID!+'&stationID='+_selectedStationID!+'&timestamp='+timestampResult2!+'&description=Data_Collection_Front');
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
        final uri = Uri.parse("https://mmsv2.pstw.com.my/upload-image.php?action=air_collection&id="+_selectedID!+'&stationID='+_selectedStationID!+'&timestamp='+timestampResult2!+'&description=Data_Collection_Back');
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
        fetchItems();
        _weather = "";
        _temp.clear();

        _flowRate1.clear();
        _flowRateResult1.clear();
        _totalTime1.clear();
        _totalTimeResult1.clear();
        _pressure1.clear();
        _pressureResult1.clear();
        _vstd1.clear();

        _flowRate2.clear();
        _flowRateResult2.clear();
        _totalTime2.clear();
        _totalTimeResult2.clear();
        _pressure2.clear();
        _pressureResult2.clear();
        _vstd2.clear();

        _image1 = null;
        _image2 = null;
        _image3 = null;
        _image4 = null;
        _image5 = null;
        _image6 = null;
        _remark.clear();

        _isDisplay = false;
      });

    }

    else {

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Data failed to save",
          style: TextStyle(fontWeight: FontWeight.bold,color: Colors.white),),backgroundColor: Colors.red,),
      );

      setState(() {
        fetchItems();
        _weather = "";
        _temp.clear();

        _flowRate1.clear();
        _flowRateResult1.clear();
        _totalTime1.clear();
        _totalTimeResult1.clear();
        _pressure1.clear();
        _pressureResult1.clear();
        _vstd1.clear();

        _flowRate2.clear();
        _flowRateResult2.clear();
        _totalTime2.clear();
        _totalTimeResult2.clear();
        _pressure2.clear();
        _pressureResult2.clear();
        _vstd2.clear();

        _image1 = null;
        _image2 = null;
        _image3 = null;
        _image4 = null;
        _image5 = null;
        _image6 = null;
        _remark.clear();

        _isDisplay = false;
      });
    }

  }

  void _sendDataLocalStorage() async {

    final db = DBHelper();

    setState(() {
      _isDisplay = true;
    });

    bool success = await db.insertDataAir(
      tableName: 'tbl_air_collection',
      values: {
        'refID': _selectedLocalAirRefID!,
        'clientID': clientID!,
        'stationID': _selectedStationID!,
        'weather': _weather,
        'temp': temp,
        'actual1': flowRate1!,
        'actualResult1': flowRateResult1!,
        'time1': totalTime1!,
        'timeResult1': totalTimeResult1!,
        'pressure1': pressure1!,
        'pressureResult1': pressureResult1!,
        'vstd1': vstd1!,
        'actual2': flowRate2!,
        'actualResult2': flowRateResult2!,
        'time2': totalTime2!,
        'timeResult2': totalTimeResult2!,
        'pressure2': pressure2!,
        'pressureResult2': pressureResult2!,
        'vstd2': vstd2!,
        'remark':remark!,
        'timestamp': timestampResult1!,
      },
    );


    if (success == true) {

      String statusID = 'L3';

      // update tbl_air_install
      if (((int.parse(totalTime1!) > 18)&&(int.parse(totalTime1!) < 24))||((int.parse(totalTime2!) > 18)&&(int.parse(totalTime2!) < 24))) {
        statusID = 'L2';
      }
      else if (((int.parse(flowRate1!) > 40)&&(int.parse(flowRate1!) < 60))||((int.parse(flowRate2!) > 40)&&(int.parse(flowRate2!) < 60))) {
        statusID = 'L2';
      }

      await db.updateDataCollection(_selectedLocalAirRefID!, statusID);

      // upload image
      if (_image1 != null) { // upload image 1

        File? _savedImage;
        File imageFile = File(_image1!.path);

        // Get app directory
        Directory appDir = await getApplicationDocumentsDirectory();

        // Create custom folder
        String folderName = "air/collection/"+_selectedStationID!;
        Directory customDir = Directory('${appDir.path}/$folderName');
        if (!await customDir.exists()) {
          await customDir.create(recursive: true);
        }

        // Create full image path
        String fileExtension = path.extension(_image1!.path);
        String fileName = _selectedLocalAirRefID!+'_'+_selectedStationID!+'_'+timestampResult2!+'_Data_Collection_Left'+fileExtension;
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
        String folderName = "air/collection/"+_selectedStationID!;
        Directory customDir = Directory('${appDir.path}/$folderName');
        if (!await customDir.exists()) {
          await customDir.create(recursive: true);
        }

        // Create full image path
        String fileExtension = path.extension(_image2!.path);
        String fileName = _selectedLocalAirRefID!+'_'+_selectedStationID!+'_'+timestampResult2!+'_Data_Collection_Right'+fileExtension;
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
        String folderName = "air/collection/"+_selectedStationID!;
        Directory customDir = Directory('${appDir.path}/$folderName');
        if (!await customDir.exists()) {
          await customDir.create(recursive: true);
        }

        // Create full image path
        String fileExtension = path.extension(_image3!.path);
        String fileName = _selectedLocalAirRefID!+'_'+_selectedStationID!+'_'+timestampResult2!+'_Data_Collection_Top'+fileExtension;
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
        String folderName = "air/collection/"+_selectedStationID!;
        Directory customDir = Directory('${appDir.path}/$folderName');
        if (!await customDir.exists()) {
          await customDir.create(recursive: true);
        }

        // Create full image path
        String fileExtension = path.extension(_image4!.path);
        String fileName = _selectedLocalAirRefID!+'_'+_selectedStationID!+'_'+timestampResult2!+'_Data_Collection_Bottom'+fileExtension;
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
        String folderName = "air/collection/"+_selectedStationID!;
        Directory customDir = Directory('${appDir.path}/$folderName');
        if (!await customDir.exists()) {
          await customDir.create(recursive: true);
        }

        // Create full image path
        String fileExtension = path.extension(_image5!.path);
        String fileName = _selectedLocalAirRefID!+'_'+_selectedStationID!+'_'+timestampResult2!+'_Data_Collection_Front'+fileExtension;
        String savedPath = '${customDir.path}/$fileName';

        // Save image
        final savedImage = await imageFile.copy(savedPath);

        setState(() {
          _savedImage = savedImage;
        });

        print("Image saved to: $savedPath");

      }

      // upload image
      if (_image6 != null) { // upload image 6

        File? _savedImage;
        File imageFile = File(_image6!.path);

        // Get app directory
        Directory appDir = await getApplicationDocumentsDirectory();

        // Create custom folder
        String folderName = "air/collection/"+_selectedStationID!;
        Directory customDir = Directory('${appDir.path}/$folderName');
        if (!await customDir.exists()) {
          await customDir.create(recursive: true);
        }

        // Create full image path
        String fileExtension = path.extension(_image6!.path);
        String fileName = _selectedLocalAirRefID!+'_'+_selectedStationID!+'_'+timestampResult2!+'_Data_Collection_Back'+fileExtension;
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
        _loadLocalAirInstall();
        selectedLocalAirInstall = null;
        _weather = "";
        _temp.clear();

        _flowRate1.clear();
        _flowRateResult1.clear();
        _totalTime1.clear();
        _totalTimeResult1.clear();
        _pressure1.clear();
        _pressureResult1.clear();
        _vstd1.clear();

        _flowRate2.clear();
        _flowRateResult2.clear();
        _totalTime2.clear();
        _totalTimeResult2.clear();
        _pressure2.clear();
        _pressureResult2.clear();
        _vstd2.clear();

        _image1 = null;
        _image2 = null;
        _image3 = null;
        _image4 = null;
        _image5 = null;
        _image6 = null;
        _remark.clear();

        _isDisplay = false;
      });

    }


  }

}