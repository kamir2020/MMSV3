import 'dart:io';
import 'dart:math';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image/image.dart' as img;
import 'package:image_picker/image_picker.dart';
import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../db_helper.dart';
import '../../object-class/local-object-location.dart';
import '../../object-class/local-object-state.dart';
import '../../object-state.dart';
import '../../object-station.dart';

class SFormAirInstallSample extends StatefulWidget {
  _SFormAirInstallSample createState() => _SFormAirInstallSample();
}

class _SFormAirInstallSample extends State<SFormAirInstallSample> {

  bool _isDisplay = false;
  bool _isLocation = false;

  TextEditingController _clientID = TextEditingController();
  TextEditingController _region = TextEditingController();
  TextEditingController _temp = TextEditingController();
  TextEditingController _pm10 = TextEditingController();
  TextEditingController _pm2 = TextEditingController();
  TextEditingController _remark = TextEditingController();
  final TextEditingController _sampleDate = TextEditingController();

  late String? clientID,region,temp,pm10,pm2,remark;
  late String _weather = '';

  Station? selectedStation;
  States? selectedState;

  String? stateID;
  String? sampleDate;
  String? _selectedStationID;

  late String? timestampResult1,timestampResult2;

  bool connectionStatus = true;
  final _formAirInstall = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _checkInternet();
    _getProfile();
    _loadState();

    var now = DateTime.now();
    var formatter = DateFormat('yyyy-MM-dd');
    String formattedTime = DateFormat('HH:mm:ss').format(now);
    String formattedDate = formatter.format(now);

    int timestamp = DateTime.now().millisecondsSinceEpoch;
    DateTime date = DateTime.fromMillisecondsSinceEpoch(timestamp);
    String result1 = DateFormat('yyyy-MM-dd HH:mm:ss').format(date);
    String result2 = DateFormat('yyyyMMdd_HHmmss').format(date);

    _sampleDate.text = formattedDate;

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

  Future<void> _getProfile() async {
    final prefs = await SharedPreferences.getInstance();

    setState(() {
      _clientID.text = prefs.getString("fullName").toString();
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

  List<localLocation> location1 = [];
  localLocation? selectedLocalLocation;

  Future<void> _loadLocation(String? stateID) async {
    final data = await DBHelper.getLocationAir(stateID);
    setState(() {
      _isLocation = true;
      location1 = data;
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
          img.drawString(originalImage!, img.arial_14, 2, 12, timestampResult1!);

          // Save string to file
          final tempDir = await getTemporaryDirectory();
          final filePath = path.join(tempDir.path, 'edited_${path.basename(photo.path)}');
          final editedFile = File(filePath)..writeAsBytesSync(img.encodeJpg(originalImage));

          setState(() {
            //_image1 = File(photo.path);
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
          img.drawString(originalImage!, img.arial_14, 2, 12, timestampResult1!);

          // Save string to file
          final tempDir = await getTemporaryDirectory();
          final filePath = path.join(tempDir.path, 'edited_${path.basename(photo.path)}');
          final editedFile = File(filePath)..writeAsBytesSync(img.encodeJpg(originalImage));

          setState(() {
            //_image1 = File(photo.path);
            _image1 = editedFile;
          });
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Please select a landscape (horizontal) image.")),
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
          img.drawString(originalImage!, img.arial_14, 2, 12, timestampResult1!);

          // Save string to file
          final tempDir = await getTemporaryDirectory();
          final filePath = path.join(tempDir.path, 'edited_${path.basename(photo.path)}');
          final editedFile = File(filePath)..writeAsBytesSync(img.encodeJpg(originalImage));

          setState(() {
            //_image2 = File(photo.path);
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
          img.drawString(originalImage!, img.arial_14, 2, 12, timestampResult1!);

          // Save string to file
          final tempDir = await getTemporaryDirectory();
          final filePath = path.join(tempDir.path, 'edited_${path.basename(photo.path)}');
          final editedFile = File(filePath)..writeAsBytesSync(img.encodeJpg(originalImage));

          setState(() {
            //_image2 = File(photo.path);
            _image2 = editedFile;
          });
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Please select a landscape (horizontal) image.")),
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
          img.drawString(originalImage!, img.arial_14, 2, 12, timestampResult1!);

          // Save string to file
          final tempDir = await getTemporaryDirectory();
          final filePath = path.join(tempDir.path, 'edited_${path.basename(photo.path)}');
          final editedFile = File(filePath)..writeAsBytesSync(img.encodeJpg(originalImage));

          setState(() {
            //_image3 = File(photo.path);
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
          img.drawString(originalImage!, img.arial_14, 2, 12, timestampResult1!);

          // Save string to file
          final tempDir = await getTemporaryDirectory();
          final filePath = path.join(tempDir.path, 'edited_${path.basename(photo.path)}');
          final editedFile = File(filePath)..writeAsBytesSync(img.encodeJpg(originalImage));

          setState(() {
            //_image3 = File(photo.path);
            _image3 = editedFile;
          });
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Please select a landscape (horizontal) image.")),
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
          img.drawString(originalImage!, img.arial_14, 2, 12, timestampResult1!);

          // Save string to file
          final tempDir = await getTemporaryDirectory();
          final filePath = path.join(tempDir.path, 'edited_${path.basename(photo.path)}');
          final editedFile = File(filePath)..writeAsBytesSync(img.encodeJpg(originalImage));

          setState(() {
            //_image4 = File(photo.path);
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

  Future<void> _takePicture4a(ImageSource source) async {
    try {
      final XFile? photo = await _picker1.pickImage(source: source);

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
            //_image4 = File(photo.path);
            _image4 = editedFile;
          });
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Please select a landscape (horizontal) image.")),
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

  Widget _viewAirInstall() {
    return Form(
      key: _formAirInstall,
      child: Column(
        children: [
          Center(
            child: Text(':: INSTALLATION STEPS ::',
              style: TextStyle(fontWeight: FontWeight.bold,fontSize: 16),),
          ),
          Divider(),
          SizedBox(height: 15.0,),
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
                      _isLocation = true;
                      selectedLocalState = value;
                      stateID = selectedLocalState!.stateID;
                      _loadLocation(stateID);
                    });
                    if (value != null) {
                      print("Selected ID: ${value.stateID}, Name: ${value.stateName}");
                    }
                  },
                ),
              ),
            ],
          ),SizedBox(height: 10.0,),
          _isLocation ? Column(
            children: [
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
                    labelText: "Select location",
                    border: OutlineInputBorder(),
                  ),
                ),

                onChanged: (localLocation? value) {
                  setState(() {
                    selectedLocalLocation = value;
                    _selectedStationID = selectedLocalLocation!.stationID;
                  });
                  if (value != null) {
                    print("Station: ${value.stationID} - Name: ${value.locationName}");
                  }
                },
              ),
            ],
          ):SizedBox(height: 0.0,),
          SizedBox(height: 10.0,),
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: _region,
                  decoration: InputDecoration(
                    labelText: 'Region',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(5.0)),
                    ),
                  ),
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'Region';
                    }
                  },
                  onSaved: (value) => setState(() => region = value!),
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
                  controller: _sampleDate,
                  decoration: InputDecoration(
                    labelText: 'Sampling Date',
                    contentPadding: EdgeInsets.fromLTRB(10.0, 10.0, 20.0, 10.0),
                    border: OutlineInputBorder(),
                  ),
                  //onTap: () => _selectDate(context),
                  onSaved: (value) => setState(() => sampleDate = value!),
                ),
              ),
            ],
          ),
          SizedBox(height: 5.0,),
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
          SizedBox(height: 5.0,),
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
          SizedBox(height: 5.0,),
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: _pm10,
                  decoration: InputDecoration(
                    labelText: 'PM10 Filter Id',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(5.0)),
                    ),
                  ),
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'PM10 Filter Id';
                    }
                  },
                  onSaved: (value) => setState(() => pm10 = value!),
                ),
              ),
            ],
          ),
          SizedBox(height: 5.0,),
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: _pm2,
                  decoration: InputDecoration(
                    labelText: 'PM2.5 Filter Id',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(5.0)),
                    ),
                  ),
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'PM2.5 Filter Id';
                    }
                  },
                  onSaved: (value) => setState(() => pm2 = value!),
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
          SizedBox(height: 5.0,),
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
          SizedBox(height: 5.0,),

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
          SizedBox(height: 5.0,),

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
          SizedBox(height: 5.0,),

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
          SizedBox(height: 5.0,),

          Center(
            child: _isDisplay ? CircularProgressIndicator() :
            Container(
              width: MediaQuery.of(context).size.width,
              child: connectionStatus ?
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                ),
                onPressed: () {
                  if (_formAirInstall.currentState!.validate()) {
                    _formAirInstall.currentState!.save();
                    _sendData();
                  }
                },
                child: Text('Submit to Server PSTW',style: TextStyle(color: Colors.white,fontWeight: FontWeight.bold),),
              ) : ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                ),
                onPressed: () {
                  if (_formAirInstall.currentState!.validate()) {
                    _formAirInstall.currentState!.save();
                    _sendDataLocalServer();
                  }
                },
                child: Text('Submit to Local Server',style: TextStyle(color: Colors.white,fontWeight: FontWeight.bold),),
              ),
            ),
          ),
          SizedBox(height: 20.0,),
        ],
      ),
    );
  }

  void _sendData() async {

    String randomId = generateRandomId(10); // Length 10

    setState(() {
      _isDisplay = true;
    });

    var client = http.Client();
    var response = await
    client.post(Uri.parse("https://mmsv2.pstw.com.my/api/air/api-post-air.php"), body: {
      "action": "air-install","refID": randomId,"clientID": clientID!,"stationID": _selectedStationID!,
      "region": region!,"sampleDate":sampleDate!,"weather":_weather,"temp":temp!,
      "pm10":pm10!,"pm2":pm2,"remark":remark!,"timestamp":timestampResult1!
    });
    var data = json.decode(response.body);
    //print(data);

    if (data['statusCode']==404) {

      // upload picture
      if (_image1 != null) { // upload image 1
        final uri = Uri.parse("https://mmsv2.pstw.com.my/upload-image.php?action=air_install&stationID="+_selectedStationID!+"&refID="+randomId+"&timestamp="+timestampResult2!+'&description=INSTALLATION_LEFT');
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
        final uri = Uri.parse("https://mmsv2.pstw.com.my/upload-image.php?action=air_install&stationID="+_selectedStationID!+"&refID="+randomId+"&timestamp="+timestampResult2!+'&description=INSTALLATION_RIGHT');
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
        final uri = Uri.parse("https://mmsv2.pstw.com.my/upload-image.php?action=air_install&stationID="+_selectedStationID!+"&refID="+randomId+"&timestamp="+timestampResult2!+'&description=INSTALLATION_FRONT');
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
        final uri = Uri.parse("https://mmsv2.pstw.com.my/upload-image.php?action=air_install&stationID="+_selectedStationID!+"&refID="+randomId+"&timestamp="+timestampResult2!+'&description=INSTALLATION_BACK');
        var request = http.MultipartRequest('POST', uri);
        request.files.add(await http.MultipartFile.fromPath(
          'image',
          _image4!.path,
          filename: path.basename(_image4!.path),
        ));

        var response1 = await request.send();
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Data has been saved!",
          style: TextStyle(fontWeight: FontWeight.bold,color: Colors.white),),backgroundColor: Colors.black,),
      );

      setState(() {
        _isLocation = false;

        _region.clear();
        _weather = "";
        _temp.clear();
        _pm10.clear();
        _pm2.clear();
        _remark.clear();
        _image1 = null;
        _image2 = null;
        _image3 = null;
        _image4 = null;

        _isDisplay = false;
      });

    }

    else {

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Data failed to save",
          style: TextStyle(fontWeight: FontWeight.bold,color: Colors.white),),backgroundColor: Colors.red,),
      );

      setState(() {
        _isLocation = false;

        _region.clear();
        _weather = "";
        _temp.clear();
        _pm10.clear();
        _pm2.clear();
        _remark.clear();
        _image1 = null;
        _image2 = null;
        _image3 = null;
        _image4 = null;

        _isDisplay = false;
      });

    }

  }

  void _sendDataLocalServer() async {

    String randomId = generateRandomId(10); // Length 10
    print(randomId);
    setState(() {
      _isDisplay = true;
    });

    final db = DBHelper();

    bool success = await db.insertDataAir(
      tableName: 'tbl_air_install',
      values: {
        'refID': randomId,
        'clientID': clientID!,
        'stationID': _selectedStationID!,
        'region': region!,
        'sampleDate': sampleDate!,
        'weather': _weather,
        'temp': temp!,
        'pm10': pm10!,
        'pm2': pm2!,
        'remark': remark!,
        'statusID': 'L1',
        'timestamp': timestampResult1!,
      },
    );

    if (success == true) {  // success submission

      // upload image
      if (_image1 != null) { // upload image 1

        File? _savedImage;
        File imageFile = File(_image1!.path);

        // Get app directory
        Directory appDir = await getApplicationDocumentsDirectory();

        // Create custom folder
        String folderName = "air/install/"+_selectedStationID!;
        Directory customDir = Directory('${appDir.path}/$folderName');
        if (!await customDir.exists()) {
          await customDir.create(recursive: true);
        }

        // Create full image path
        String fileExtension = path.extension(_image1!.path);
        String fileName = _selectedStationID!+'_'+randomId+'_'+timestampResult2!+'_INSTALLATION_LEFT'+fileExtension;
        String savedPath = '${customDir.path}/$fileName';

        // Save image
        final savedImage = await imageFile.copy(savedPath);

        setState(() {
          _savedImage = savedImage;
        });

        print("Image saved to: $savedPath");

      }

      // upload image 2
      if (_image2 != null) { // upload image 2

        File? _savedImage;
        File imageFile = File(_image2!.path);

        // Get app directory
        Directory appDir = await getApplicationDocumentsDirectory();

        // Create custom folder
        String folderName = "air/install/"+_selectedStationID!;
        Directory customDir = Directory('${appDir.path}/$folderName');
        if (!await customDir.exists()) {
          await customDir.create(recursive: true);
        }

        // Create full image path
        // Create full image path
        String fileExtension = path.extension(_image2!.path);
        String fileName = _selectedStationID!+'_'+randomId+'_'+timestampResult2!+'_INSTALLATION_RIGHT'+fileExtension;
        String savedPath = '${customDir.path}/$fileName';

        // Save image
        final savedImage = await imageFile.copy(savedPath);

        setState(() {
          _savedImage = savedImage;
        });

        print("Image saved to: $savedPath");

      }

      // upload image 3
      if (_image3 != null) { // upload image 2

        File? _savedImage;
        File imageFile = File(_image3!.path);

        // Get app directory
        Directory appDir = await getApplicationDocumentsDirectory();

        // Create custom folder
        String folderName = "air/install/"+_selectedStationID!;
        Directory customDir = Directory('${appDir.path}/$folderName');
        if (!await customDir.exists()) {
          await customDir.create(recursive: true);
        }

        // Create full image path
        String fileExtension = path.extension(_image3!.path);
        String fileName = _selectedStationID!+'_'+randomId+'_'+timestampResult2!+'_INSTALLATION_FRONT'+fileExtension;
        String savedPath = '${customDir.path}/$fileName';

        // Save image
        final savedImage = await imageFile.copy(savedPath);

        setState(() {
          _savedImage = savedImage;
        });

        print("Image saved to: $savedPath");

      }

      // upload image 4
      if (_image4 != null) { // upload image 2

        File? _savedImage;
        File imageFile = File(_image4!.path);

        // Get app directory
        Directory appDir = await getApplicationDocumentsDirectory();

        // Create custom folder
        String folderName = "air/install/"+_selectedStationID!;
        Directory customDir = Directory('${appDir.path}/$folderName');
        if (!await customDir.exists()) {
          await customDir.create(recursive: true);
        }

        // Create full image path
        String fileExtension = path.extension(_image4!.path);
        String fileName = _selectedStationID!+'_'+randomId+'_'+timestampResult2!+'_INSTALLATION_BACK'+fileExtension;
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
        _isLocation = false;

        _region.clear();
        _weather = "";
        _temp.clear();
        _pm10.clear();
        _pm2.clear();
        _remark.clear();
        _image1 = null;
        _image2 = null;
        _image3 = null;
        _image4 = null;

        _isDisplay = false;
      });

    }

    else {

    }


  }

  String generateRandomId(int length) {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    Random rnd = Random();
    return String.fromCharCodes(Iterable.generate(
        length, (_) => chars.codeUnitAt(rnd.nextInt(chars.length))));
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(5.0),
      child: _viewAirInstall(),
    );
  }

}