import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:app_mms/object-class/local-object-category.dart';
import 'package:app_mms/object-class/local-object-distinct-location.dart';
import 'package:app_mms/object-class/local-object-location.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/rendering.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server/gmail.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:path/path.dart' as path;
import 'package:dropdown_search/dropdown_search.dart';
import 'package:app_mms/object-station.dart';
import '../../db_helper.dart';
import '../../object-class/local-object-state.dart';
import 'package:image/image.dart' as img;

import '../../object-class/local-object-user.dart'; // Add image package for dimension check

class SFormTarball extends StatefulWidget {
  _SFormTarball createState() => _SFormTarball();
}

class _SFormTarball extends State<SFormTarball> {

  bool _isDisplay = false;

  final TextEditingController _firstSamplerName = TextEditingController();
  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _timeController = TextEditingController();
  TimeOfDay selectedTime = TimeOfDay.now();
  int selectedSecond = 0;

  final TextEditingController _latitude = TextEditingController();
  final TextEditingController _longitude = TextEditingController();
  final TextEditingController _currentLatitude = TextEditingController();
  final TextEditingController _currentLongitude = TextEditingController();
  late String? latitude, longitude;
  late String? _getLatitude, _getLongitude;
  late String? firstSamplerName, sampleDate, sampleTime;

  String? _selectedStateName;

  String? _selectedCategoryName;

  final TextEditingController _optional1 = TextEditingController();
  final TextEditingController _optional2 = TextEditingController();
  final TextEditingController _optional3 = TextEditingController();
  final TextEditingController _optional4 = TextEditingController();

  late String _optionalName1='',_optionalName2='',_optionalName3='',_optionalName4='';

  List<dynamic> _dropdownItemClassify = [];
  Map<String, dynamic>? _selectedClassify;
  String? _selectedClassifyID;
  String? _selectedClassifyName;
  String? _secondSamplerName;

  String? _selectedStationID;
  String? _selectedStationName;

  String? reportID;

  bool _form1 = true;
  bool _form2 = false;
  bool _form3 = false;

  final _formTarbal1 = GlobalKey<FormState>();
  final _formTarbal2 = GlobalKey<FormState>();

  Station? selectedStation;
  String? stateID,categoryID;
  bool connectionStatus = true;
  bool _isCategory = false;
  bool _isLocation = false;
  String? timestampResult1,timestampResult2;
  double _distanceDevice = 0;
  final db = DBHelper();

  @override
  void initState() {
    super.initState();
    _checkInternet();
    _loadClassify();
    _generateID();
    _getProfile();
    _loadSampler();
    _loadState();
    DBHelper.getData();

    var now = DateTime.now();
    var formatter = DateFormat('yyyy-MM-dd');
    String formattedDate = formatter.format(now);
    String formattedTime = DateFormat('HH:mm:ss').format(now);
    _dateController.text = formattedDate;

    int timestamp = DateTime.now().millisecondsSinceEpoch;
    DateTime date = DateTime.fromMillisecondsSinceEpoch(timestamp);
    String result1 = DateFormat('yyyy-MM-dd HH:mm:ss').format(date);
    String result2 = DateFormat('yyyyMMdd_HHmmss').format(date);

    setState(() {
      timestampResult1 = result1;
      timestampResult2 = result2;
    });

    //String formattedTime = now.hour.toString()+":"+now.minute.toString()+":"+now.second.toString();
    _timeController.text = formattedTime;
  }


  @override
  void dispose() {
    _timeController.dispose();
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
    final data = await DBHelper.getCategoryTarball(stateID);
    setState(() {
      category1 = data;
    });
  }

  List<localLocation> location1 = [];
  localLocation? selectedLocalLocation;

  Future<void> _loadLocation(String? stateID, String? categoryID) async {
    final data = await DBHelper.getLocation(stateID,categoryID);
    setState(() {
      _isLocation = true;
      location1 = data;
    });
  }

  Future<void> _loadClassify() async {

    String jsonString = await rootBundle.loadString('assets/tarball-classification.json');
    final List<dynamic> jsonResponse = jsonDecode(jsonString);

    setState(() {
      _dropdownItemClassify = jsonResponse;
    });
  }

  Future<void> _getProfile() async {
    final prefs = await SharedPreferences.getInstance();

    setState(() {
      _firstSamplerName.text = prefs.getString("fullName").toString();
    });

  }

  String generateRandomString(int length) {
    const chars = "ABCDEFGHIJKLMNOPQRSTUVW0123456789";
    Random random = Random();

    return String.fromCharCodes(
      Iterable.generate(
        length,
            (_) => chars.codeUnitAt(random.nextInt(chars.length)),
      ),
    );
  }

  void _generateID() {
    reportID = generateRandomString(10); // Generates a 16-character random ID
    print("Generated Random String ID: $reportID");
  }

  Future<void> _checkPermissionsAndFetchLocation(BuildContext context) async {

    if ((_latitude.text.isNotEmpty)&&(_longitude.text.isNotEmpty))  {

      var connectivityResult = await Connectivity().checkConnectivity();

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

      double result = calculateDistance(double.parse(_latitude.text),double.parse(_longitude.text),double.parse(_currentLatitude.text),double.parse(_currentLongitude.text));

      setState(() {
        _distanceDevice = result;
      });
      _showDistance(context, result.toString());

      print("Distance: ${result} km");
      print("Latitude: ${position.latitude}, Longitude: ${position.longitude}");
    }

    else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Please choose location to get latitude and longitude")),
      );
    }
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
      final XFile? photo = await _picker4.pickImage(source: source);

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
          img.drawString(originalImage!, img.arial_14, 2, 12, timestampResult1!);

          // Save string to file
          final tempDir = await getTemporaryDirectory();
          final filePath = path.join(tempDir.path, 'edited_${path.basename(photo.path)}');
          final editedFile = File(filePath)..writeAsBytesSync(img.encodeJpg(originalImage));

          setState(() {
            //_image5 = File(photo.path);
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
          img.drawString(originalImage!, img.arial_14, 2, 12, timestampResult1!);

          // Save string to file
          final tempDir = await getTemporaryDirectory();
          final filePath = path.join(tempDir.path, 'edited_${path.basename(photo.path)}');
          final editedFile = File(filePath)..writeAsBytesSync(img.encodeJpg(originalImage));

          setState(() {
            //_image5 = File(photo.path);
            _image5 = editedFile;
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
          img.drawString(originalImage!, img.arial_14, 2, 12, timestampResult1!);

          // Save string to file
          final tempDir = await getTemporaryDirectory();
          final filePath = path.join(tempDir.path, 'edited_${path.basename(photo.path)}');
          final editedFile = File(filePath)..writeAsBytesSync(img.encodeJpg(originalImage));

          setState(() {
            //_image6 = File(photo.path);
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
          img.drawString(originalImage!, img.arial_14, 2, 12, timestampResult1!);

          // Save string to file
          final tempDir = await getTemporaryDirectory();
          final filePath = path.join(tempDir.path, 'edited_${path.basename(photo.path)}');
          final editedFile = File(filePath)..writeAsBytesSync(img.encodeJpg(originalImage));

          setState(() {
            //_image6 = File(photo.path);
            _image6 = editedFile;
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

  final ImagePicker _picker7 = ImagePicker();
  File? _image7;

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
            //_image7 = File(photo.path);
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

  Future<void> _takePicture7a(ImageSource source) async {
    try {
      final XFile? photo = await _picker7.pickImage(source: source);

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
            //_image7 = File(photo.path);
            _image7 = editedFile;
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

  final ImagePicker _picker8 = ImagePicker();
  File? _image8;

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
            //_image8 = File(photo.path);
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

  Future<void> _takePicture8a(ImageSource source) async {
    try {
      final XFile? photo = await _picker8.pickImage(source: source);

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
            //_image8 = File(photo.path);
            _image8 = editedFile;
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

  final List<String> items = [
    "Apple", "Banana", "Cherry", "Date", "Elderberry",
    "Fig", "Grape", "Honeydew", "Indian Fig", "Jackfruit"
  ];

  Widget _buildForm1() {
    return Form(
      key: _formTarbal1,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('TARBALL SAMPLING',style: TextStyle(fontSize: 18,fontWeight: FontWeight.bold),),
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
          SizedBox(height: 5.0,),
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
                  validator: (value) {
                    if (value!.isEmpty) {
                      return '1st Sampler';
                    }
                  },
                  onSaved: (value) => setState(() => firstSamplerName = value!),
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
                      _secondSamplerName = selectedLocalSampler!.fullname;
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
                  readOnly: true,
                  controller: _dateController,
                  decoration: InputDecoration(
                    labelText: 'Date',
                    contentPadding: EdgeInsets.fromLTRB(10.0, 10.0, 20.0, 10.0),
                    border: OutlineInputBorder(),
                  ),
                  //onTap: () => _selectDate(context),
                  onSaved: (value) => setState(() => sampleDate = value!),
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'Date';
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
                  controller: _timeController,
                  readOnly: true,
                  decoration: InputDecoration(
                    labelText: 'Time',
                    contentPadding: EdgeInsets.fromLTRB(10.0, 10.0, 20.0, 10.0),
                    border: OutlineInputBorder(),
                  ),
                  //onTap: () => _selectTime(context),
                  onSaved: (value) => setState(() => sampleTime = value!),
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'Time';
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

                      _latitude.clear();
                      _longitude.clear();
                      _currentLatitude.clear();
                      _currentLongitude.clear();

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

                          _latitude.clear();
                          _longitude.clear();
                          _currentLatitude.clear();
                          _currentLongitude.clear();

                          _loadLocation(stateID,categoryID);
                        });
                        if (value != null) {
                          print("Selected ID: ${value.categoryID}, Name: ${value.categoryName}");
                        }
                      },
                    ),
                  ),
                ],
              ),
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

                          _currentLatitude.clear();
                          _currentLongitude.clear();

                          _selectedStationID = selectedLocalLocation!.stationID;
                          _selectedStationName = selectedLocalLocation!.locationName;
                          _latitude.text = selectedLocalLocation!.latitude;
                          _longitude.text = selectedLocalLocation!.longitude;
                        }
                      },
                    ),
                  )
                ],
              )
            ],
          ) : SizedBox(width: 0.0,),
          SizedBox(height: 10.0,),
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
                    SizedBox(height: 10.0,),
                    TextFormField(
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
                  ],
                ),
              ),
            ],
          ),
          SizedBox(
            height: 10.0,
          ),
          Text('Current Location : ',style: TextStyle(fontWeight: FontWeight.bold),),
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
                      controller: _currentLatitude,
                      decoration: InputDecoration(
                        labelText: 'Latitude',
                        hintStyle: TextStyle(fontSize: 12,color: Colors.red),
                        hintText: 'Latitude',
                        filled: true,
                        fillColor: Colors.blue[50],
                        contentPadding: EdgeInsets.fromLTRB(10.0, 10.0, 20.0, 10.0),
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value!.isEmpty) {
                          return 'Current latitude';
                        }
                      },
                      onSaved: (value) => setState(() => _getLatitude = value!),
                    ),
                    SizedBox(height: 10.0,),
                    TextFormField(
                      readOnly: true,
                      controller: _currentLongitude,
                      decoration: InputDecoration(
                        hintStyle: TextStyle(fontSize: 12,color: Colors.red),
                        labelText: 'Longitude',
                        filled: true,
                        fillColor: Colors.blue[50],
                        contentPadding: EdgeInsets.fromLTRB(10.0, 10.0, 20.0, 10.0),
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value!.isEmpty) {
                          return 'Current longitude';
                        }
                      },
                      onSaved: (value) => setState(() => _getLongitude = value!),
                    ),
                    TextButton(
                        onPressed: () => _checkPermissionsAndFetchLocation(context),
                      child: Text('--> Click to Get location'),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 5.0,),

          SizedBox(height: 5.0,),
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue
                  ),
                  onPressed: () {
                    if (_formTarbal1.currentState!.validate()) {
                      _formTarbal1.currentState!.save();
                      //print(firstSampler! + sampleDate!.toString() + sampleTime!.toString());
                      //print(latitude! + longitude!);
                      //print(_selectedState);

                      setState(() {
                        _form1 = false;
                        _form2 = true;
                        _form3 = false;
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
      key: _formTarbal2,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
        Text(':: On-Site Information',style: TextStyle(fontSize: 20,fontWeight: FontWeight.bold),),
          Divider(),
          SizedBox(height: 5.0,),
          Row(
            children: [
              Expanded(
                flex: 2,
                child: Text('Tarball Classfication'),
              ),
              Expanded(
                flex: 3,
                child: _dropdownItemClassify.isEmpty
                    ? Center(child: CircularProgressIndicator()) // Show a loader while data is loading
                    : DropdownButtonFormField<Map<String, dynamic>>(
                  value: _selectedClassify,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                  ),
                  items: _dropdownItemClassify.map((item) {
                    return DropdownMenuItem<Map<String, dynamic>>(
                      value: item,
                      child: Text(item['name']),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedClassify = value;
                      _selectedClassifyID = _selectedClassify!['id'];
                      _selectedClassifyName = _selectedClassify!['name'];
                    });
                  },
                  validator: (value) {
                    if (value == null) {
                      return 'Classification';
                    }
                    return null;
                  },
                ),
              ),
            ],
          ),
          SizedBox(height: 5,),
          Row(
            children: [
              Expanded(
                flex: 3,
                child: Text('Left Side Coastal View'),
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
          SizedBox(height: 5.0,),
          Row(
            children: [
              Expanded(
                flex: 3,
                child: Text('Right Side Coastal View'),
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
                    )
                  ],
                ),
              ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              _image2 != null
                  ? Column(
                children: [
                  SingleChildScrollView(
                    //scrollDirection: Axis.horizontal,
                    child: Container(
                      alignment: Alignment.center,
                      child: Center(
                        child: Image.file(
                          _image2!,
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
                          onPressed: _deletePicture2,
                          icon: Icon(
                            size: 40,
                            color: Colors.red,
                            Icons.delete_forever_outlined,
                          ),
                        ),
                      )
                    ],
                  )
                ],
              )
                  : Text("--No image captured yet--",style: TextStyle(fontSize: 12,color: Colors.red),),
            ],
          ),
          SizedBox(height: 5.0,),
          Row(
            children: [
              Expanded(
                flex: 3,
                child: Text('Drawing Vertical Lines'),
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
                    )
                  ],
                ),
              ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              _image3 != null
                  ? Column(
                children: [
                  SingleChildScrollView(
                    //scrollDirection: Axis.horizontal,
                    child: Container(
                      alignment: Alignment.center,
                      child: Center(
                        child: Image.file(
                          _image3!,
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
                          onPressed: _deletePicture3,
                          icon: Icon(
                            size: 40,
                            color: Colors.red,
                            Icons.delete_forever_outlined,
                          ),
                        ),
                      )
                    ],
                  )
                ],
              )
                  : Text("--No image captured yet--",style: TextStyle(fontSize: 12,color: Colors.red),),
            ],
          ),
          SizedBox(height: 5.0,),
          Row(
            children: [
              Expanded(
                flex: 3,
                child: Text('Drawing Horizontal Lines \n(Racking)'),
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
                    )
                  ],
                ),
              ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              _image4 != null
                  ? Column(
                children: [
                  SingleChildScrollView(
                    //scrollDirection: Axis.horizontal,
                    child: Container(
                      alignment: Alignment.center,
                      child: Center(
                        child: Image.file(
                          _image4!,
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
                          onPressed: _deletePicture4,
                          icon: Icon(
                            size: 40,
                            color: Colors.red,
                            Icons.delete_forever_outlined,
                          ),
                        ),
                      )
                    ],
                  )
                ],
              )
                  : Text("--No image captured yet--",style: TextStyle(fontSize: 12,color: Colors.red),),
            ],
          ),
          SizedBox(height: 5.0,),
          Row(
            children: [
              Expanded(
                flex: 3,
                child: Text('Optional photo'),
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
                    )
                  ],
                ),
              ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              _image5 != null
                  ? Column(
                children: [
                  SingleChildScrollView(
                    //scrollDirection: Axis.horizontal,
                    child: Container(
                      alignment: Alignment.center,
                      child: Center(
                        child: Image.file(
                          _image5!,
                          width: 300,
                          height: 200,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ),
                  TextFormField(
                    controller: _optional1,
                    decoration: InputDecoration(
                        labelText: 'Comments',
                        labelStyle: TextStyle(fontSize: 12)
                    ),
                    onSaved: (value) => setState(() => _optionalName1 = value!),
                  ),
                  SizedBox(height: 5.0,),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Expanded(
                        child: IconButton(
                          onPressed: _deletePicture5,
                          icon: Icon(
                            size: 40,
                            color: Colors.red,
                            Icons.delete_forever_outlined,
                          ),
                        ),
                      )
                    ],
                  )
                ],
              )
                  : Text("--No image captured yet--",style: TextStyle(fontSize: 12,color: Colors.red),),
            ],
          ),
          SizedBox(height: 5.0,),
          Row(
            children: [
              Expanded(
                flex: 3,
                child: Text(''),
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
                    )
                  ],
                ),
              ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              _image6 != null
                  ? Column(
                children: [
                  SingleChildScrollView(
                    //scrollDirection: Axis.horizontal,
                    child: Container(
                      alignment: Alignment.center,
                      child: Center(
                        child: Image.file(
                          _image6!,
                          width: 300,
                          height: 200,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ),
                  TextFormField(
                    controller: _optional2,
                    decoration: InputDecoration(
                        labelText: 'Comments',
                        labelStyle: TextStyle(fontSize: 12)
                    ),
                    onSaved: (value) => setState(() => _optionalName2 = value!),
                  ),
                  SizedBox(height: 5.0,),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Expanded(
                        child: IconButton(
                          onPressed: _deletePicture6,
                          icon: Icon(
                            size: 40,
                            color: Colors.red,
                            Icons.delete_forever_outlined,
                          ),
                        ),
                      )
                    ],
                  )
                ],
              )
                  : Text("--No image captured yet--",style: TextStyle(fontSize: 12,color: Colors.red),),
            ],
          ),
          SizedBox(height: 5.0,),
          SizedBox(height: 5.0,),
          Row(
            children: [
              Expanded(
                flex: 3,
                child: Text(''),
              ),
              Expanded(
                flex: 2,
                child: Row(
                  children: [
                    Align(
                      alignment: Alignment.centerRight,
                      child: IconButton(
                        onPressed: _takePicture7,
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
                          _takePicture7a(ImageSource.gallery);
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
              _image7 != null
                  ? Column(
                children: [
                  SingleChildScrollView(
                    //scrollDirection: Axis.horizontal,
                    child: Container(
                      alignment: Alignment.center,
                      child: Center(
                        child: Image.file(
                          _image7!,
                          width: 300,
                          height: 200,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ),
                  TextFormField(
                    controller: _optional3,
                    decoration: InputDecoration(
                        labelText: 'Comments',
                        labelStyle: TextStyle(fontSize: 12)
                    ),
                    onSaved: (value) => setState(() => _optionalName3 = value!),
                  ),
                  SizedBox(height: 5.0,),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Expanded(
                        child: IconButton(
                          onPressed: _deletePicture7,
                          icon: Icon(
                            size: 40,
                            color: Colors.red,
                            Icons.delete_forever_outlined,
                          ),
                        ),
                      )
                    ],
                  )
                ],
              )
                  : Text("--No image captured yet--",style: TextStyle(fontSize: 12,color: Colors.red),),
            ],
          ),
          SizedBox(height: 5.0,),
          Row(
            children: [
              Expanded(
                flex: 3,
                child: Text(''),
              ),
              Expanded(
                flex: 2,
                child: Row(
                  children: [
                    Align(
                      alignment: Alignment.centerRight,
                      child: IconButton(
                        onPressed: _takePicture8,
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
                          _takePicture8a(ImageSource.gallery);
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
              _image8 != null
                  ? Column(
                children: [
                  SingleChildScrollView(
                    //scrollDirection: Axis.horizontal,
                    child: Container(
                      alignment: Alignment.center,
                      child: Center(
                        child: Image.file(
                          _image8!,
                          width: 300,
                          height: 200,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ),
                  TextFormField(
                    controller: _optional4,
                    decoration: InputDecoration(
                        labelText: 'Comments',
                        labelStyle: TextStyle(fontSize: 12)
                    ),
                    onSaved: (value) => setState(() => _optionalName4 = value!),
                  ),
                  SizedBox(height: 5.0,),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Expanded(
                        child: IconButton(
                          onPressed: _deletePicture8,
                          icon: Icon(
                            size: 40,
                            color: Colors.red,
                            Icons.delete_forever_outlined,
                          ),
                        ),
                      )
                    ],
                  )
                ],
              )
                  : Text("--No image captured yet--",style: TextStyle(fontSize: 12,color: Colors.red),),
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
                      backgroundColor: Colors.grey
                  ),
                  onPressed: () {
                    setState(() {
                      _form1 = true;
                      _form2 = false;
                      _form3 = false;
                    });
                  },
                  child: Text('Back',
                    style: TextStyle(color: Colors.white,fontWeight: FontWeight.bold),),
                ),
              ),
              SizedBox(width: 5.0,),
              Expanded(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue
                  ),
                  onPressed: () {
                    if (_formTarbal2.currentState!.validate()) {
                      _formTarbal2.currentState!.save();

                      setState(() {
                        _form1 = false;
                        _form2 = false;
                        _form3 = true;
                      });
                    }

                  },
                  child: Text('Proceed',
                    style: TextStyle(color: Colors.white,fontWeight: FontWeight.bold),),
                ),
              ),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildForm3() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Center(
          child: Text(':: REPORT SUMMARY ::',style: TextStyle(fontSize: 20,fontWeight: FontWeight.bold),),
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
              child: Text(reportID!),
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
              child: Text(firstSamplerName!),
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
              child: Text(_secondSamplerName!),
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
              child: Text('State'),
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
              child: Text('Station Category'),
            ),
            Expanded(
              flex: 3,
              child: Text(_selectedCategoryName!),
            ),
          ],
        ),
        SizedBox(height: 5.0,),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 2,
              child: Text('Station ID & Name',),
            ),
            Expanded(
              flex: 3,
              child: Text(_selectedStationID! + " \n "+ _selectedStationName!),
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
              child: Text(latitude! +" - "+ longitude!),
            ),
          ],
        ),
        SizedBox(height: 5.0,),
        Row(
          children: [
            Expanded(
              flex: 2,
              child: Text('Current Location'),
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
              child: Text('Tarball Classification'),
            ),
            Expanded(
              flex: 3,
              child: Text(_selectedClassifyName!),
            ),
          ],
        ),
        SizedBox(height: 5.0,),
        Divider(),
        Text('PHOTO',style: TextStyle(fontWeight: FontWeight.bold),),
        SizedBox(height: 5.0,),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Left Side Coastal View'),
            _image1 != null
                ? Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(height: 5.0,),
                Image.file(_image1!),
              ],
            )
                : Text("--No image captured yet--",style: TextStyle(fontSize: 12,color: Colors.red),),
          ],
        ),
        SizedBox(height: 10.0,),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Right Side Coastal View'),
            _image2 != null
                ? Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(height: 5.0,),
                Image.file(_image2!), // Display captured image
              ],
            )
                : Text("--No image captured yet--",style: TextStyle(fontSize: 12,color: Colors.red),),
          ],
        ),
        SizedBox(height: 10.0,),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Drawing Vertical Lines'),
            _image3 != null
                ? Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(height: 5.0,),
                Image.file(_image3!), // Display captured image
              ],
            )
                : Text("--No image captured yet--",style: TextStyle(fontSize: 12,color: Colors.red),),
          ],
        ),
        SizedBox(height: 10.0,),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Drawing Horizontal Lines (Racking)'),
            _image4 != null
                ? Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(height: 5.0,),
                Image.file(_image4!), // Display captured image
              ],
            )
                : Text("--No image captured yet--",style: TextStyle(fontSize: 12,color: Colors.red),),
          ],
        ),
        SizedBox(height: 10.0,),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Optional photo'),
            _image5 != null
                ? Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(height: 5.0,),
                Image.file(_image5!),
                SizedBox(height: 2.0,),
                Text(_optionalName1!),// Display captured image// Display captured image
              ],
            )
                : Text("--No image captured yet--",style: TextStyle(fontSize: 12,color: Colors.red),),
          ],
        ),
        SizedBox(height: 10.0,),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            //Text('Optional photo'),
            _image6 != null
                ? Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(height: 5.0,),
                Image.file(_image6!),
                SizedBox(height: 2.0,),
                Text(_optionalName2!),// Display captured image// Display captured image
              ],
            )
                : Text("--No image captured yet--",style: TextStyle(fontSize: 12,color: Colors.red),),
          ],
        ),
        SizedBox(height: 10.0,),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            //Text('Optional photo'),
            _image7 != null
                ? Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(height: 5.0,),
                Image.file(_image7!),
                SizedBox(height: 2.0,),
                Text(_optionalName3!),// Display captured image// Display captured image
              ],
            )
                : Text("--No image captured yet--",style: TextStyle(fontSize: 12,color: Colors.red),),
          ],
        ),
        SizedBox(height: 10.0,),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            //Text('Optional photo'),
            _image8 != null
                ? Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(height: 5.0,),
                Image.file(_image8!),
                SizedBox(height: 2.0,),
                Text(_optionalName4!),// Display captured image// Display captured image
              ],
            )
                : Text("--No image captured yet--",style: TextStyle(fontSize: 12,color: Colors.red),),
          ],
        ),
        SizedBox(height: 25.0,),
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
              child: connectionStatus ? ElevatedButton(
                style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue
                ),
                onPressed: () {
                  setState(() {
                    _showStoreData(context);
                  });
                },
                child: Text('Submit to PSTW Server',style: TextStyle(fontWeight: FontWeight.bold,color: Colors.white),),
              ) : ElevatedButton(
                style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue
                ),
                onPressed: () {
                  setState(() {
                    _showStoreDataLocal(context);
                  });
                },
                child: Text('Submit to Local',style: TextStyle(fontWeight: FontWeight.bold,color: Colors.white),),
              ),
            )
          ],
        ),
        SizedBox(height: 50,),
      ],
    );
  }

  _showAlertReport(BuildContext context) {

    Widget continueButton = TextButton(
      child: Text("Continue"),
      onPressed:  () {

      },
    );

    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      title: Text("Attach Tarball File"),
      content: Text("Attach tarball report?"),
      actions: [
      ],
    );

    // show the dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  _showStoreData(BuildContext context) {

    Widget continueButton = TextButton(
      child: Text("Continue"),
      onPressed:  () {},
    );

    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      title: Text("Server PSTW"),
      content: Text("Store data to PSTW?"),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop(false); // Return false
          },
          child: Text("No"),
        ),
        TextButton(
          onPressed: () {
            Navigator.of(context).pop(false);
            _submitData();
          },
          child: Text("Yes"),
        ),
      ],
    );

    // show the dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  _showStoreDataLocal(BuildContext context) {

    Widget continueButton = TextButton(
      child: Text("Continue"),
      onPressed:  () {},
    );

    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      title: Text("Local Storage"),
      content: Text("Store data to Local Storage?"),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop(false); // Return false
          },
          child: Text("No"),
        ),
        TextButton(
          onPressed: () {
            Navigator.of(context).pop(false);
            _submitDataToLocal();
          },
          child: Text("Yes"),
        ),
      ],
    );

    // show the dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
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
    ) :
    Column(
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
      ],
    );
  }

  void _submitData() async {

    setState(() {
      _isDisplay = true;
    });

    var client = http.Client();
    var response = await
    client.post(Uri.parse("https://mmsv2.pstw.com.my/api/marine/api-post-marine.php"), body: {
      "action": "marine-new-tarball","reportID": reportID,"firstSampler": firstSamplerName,
      "secondSampler": _secondSamplerName,
      "dateSample": sampleDate!,"timeSample": sampleTime!,
      "stationID": _selectedStationID,"classifyID": _selectedClassifyID,
      "latitude": latitude,"longitude": longitude,
      "getLatitude": _getLatitude,"getLongitude": _getLongitude,
      "distance":_distanceDevice.toString(),
      "optionalName1": _optionalName1,"optionalName2": _optionalName2,
      "optionalName3": _optionalName3,"optionalName4": _optionalName4,
      "timestamp":timestampResult1!
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
                '\n2nd Sampler : ' + _secondSamplerName.toString() +
                '\nStation ID : ' + _selectedStationID.toString() +
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

      // upload image
      if (_image1 != null) { // upload image 1
        final uri = Uri.parse("https://mmsv2.pstw.com.my/upload-image.php?action=marine_tarball&id="+_selectedStationID.toString()+"&timestamp="+timestampResult2!+"&description=LEFTSIDECOASTALVIEW");
        var request = http.MultipartRequest('POST', uri);
        request.files.add(await http.MultipartFile.fromPath(
          'image',
          _image1!.path,
          filename: path.basename(_image1!.path),
        ));

        var response1 = await request.send();
      }

      if (_image2 != null) { // upload image 2
        final uri = Uri.parse("https://mmsv2.pstw.com.my/upload-image.php?action=marine_tarball&id="+_selectedStationID.toString()+"&timestamp="+timestampResult2!+"&description=RIGHTSIDECOASTALVIEW");
        var request = http.MultipartRequest('POST', uri);
        request.files.add(await http.MultipartFile.fromPath(
          'image',
          _image2!.path,
          filename: path.basename(_image2!.path),
        ));

        var response2 = await request.send();
      }

      if (_image3 != null) { // upload image 3
        final uri = Uri.parse("https://mmsv2.pstw.com.my/upload-image.php?action=marine_tarball&id="+_selectedStationID.toString()+"&timestamp="+timestampResult2!+"&description=DRAWINGVERTICALLINES");
        var request = http.MultipartRequest('POST', uri);
        request.files.add(await http.MultipartFile.fromPath(
          'image',
          _image3!.path,
          filename: path.basename(_image3!.path),
        ));

        var response3 = await request.send();
      }

      if (_image4 != null) { // upload image 4
        final uri = Uri.parse("https://mmsv2.pstw.com.my/upload-image.php?action=marine_tarball&id="+_selectedStationID.toString()+"&timestamp="+timestampResult2!+"&description=DRAWINGHORIZONTALLINES");
        var request = http.MultipartRequest('POST', uri);
        request.files.add(await http.MultipartFile.fromPath(
          'image',
          _image4!.path,
          filename: path.basename(_image4!.path),
        ));

        var response4 = await request.send();
      }

      if (_image5 != null) { // upload image 5
        final uri = Uri.parse("https://mmsv2.pstw.com.my/upload-image.php?action=marine_tarball&id="+_selectedStationID.toString()+"&timestamp="+timestampResult2!+"&description=OPTIONAL01");
        var request = http.MultipartRequest('POST', uri);
        request.files.add(await http.MultipartFile.fromPath(
          'image',
          _image5!.path,
          filename: path.basename(_image5!.path),
        ));

        var response5 = await request.send();
      }

      if (_image6 != null) { // upload image 6
        final uri = Uri.parse("https://mmsv2.pstw.com.my/upload-image.php?action=marine_tarball&id="+_selectedStationID.toString()+"&timestamp="+timestampResult2!+"&description=OPTIONAL02");
        var request = http.MultipartRequest('POST', uri);
        request.files.add(await http.MultipartFile.fromPath(
          'image',
          _image6!.path,
          filename: path.basename(_image6!.path),
        ));

        var response6 = await request.send();
      }

      if (_image7 != null) { // upload image 7
        final uri = Uri.parse("https://mmsv2.pstw.com.my/upload-image.php?action=marine_tarball&id="+_selectedStationID.toString()+"&timestamp="+timestampResult2!+"&description=OPTIONAL03");
        var request = http.MultipartRequest('POST', uri);
        request.files.add(await http.MultipartFile.fromPath(
          'image',
          _image7!.path,
          filename: path.basename(_image7!.path),
        ));

        var response7 = await request.send();
      }

      if (_image8 != null) { // upload image 8
        final uri = Uri.parse("https://mmsv2.pstw.com.my/upload-image.php?action=marine_tarball&id="+_selectedStationID.toString()+"&timestamp="+timestampResult2!+"&description=OPTIONAL04");
        var request = http.MultipartRequest('POST', uri);
        request.files.add(await http.MultipartFile.fromPath(
          'image',
          _image8!.path,
          filename: path.basename(_image8!.path),
        ));

        var response8 = await request.send();
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Data has been saved!",
          style: TextStyle(fontWeight: FontWeight.bold,color: Colors.white),),backgroundColor: Colors.black,),
      );

      setState(() {
        firstSamplerName = '';
        _secondSamplerName = '';
        selectedLocalSampler = null;
        _dateController.clear();
        _timeController.clear();
        _latitude.clear();
        _longitude.clear();
        _currentLatitude.clear();
        _currentLongitude.clear();

        selectedLocalState = null;
        _isDisplay = false;
        _isCategory = false;
        _isLocation = false;

        _form1 = true;
        _form2 = false;
        _form3 = false;
      });
    }

    else {

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Data failed to save",
          style: TextStyle(fontWeight: FontWeight.bold,color: Colors.white),),backgroundColor: Colors.red,),
      );

      setState(() {

        firstSamplerName = '';
        _secondSamplerName = '';
        selectedLocalSampler = null;
        _dateController.clear();
        _timeController.clear();
        _latitude.clear();
        _longitude.clear();
        _currentLatitude.clear();
        _currentLongitude.clear();

        selectedLocalState = null;
        _isDisplay = false;
        _isCategory = false;
        _isLocation = false;

        _form1 = true;
        _form2 = false;
        _form3 = false;
      });
    }
  }

  void _submitDataToLocal() async {

    setState(() {
      _isDisplay = true;
    });

    bool success = await db.insertDataTarball(
      tableName: 'tbl_marine_tarball',
      values: {
        'reportID': reportID!,
        'firstSampler': firstSamplerName!,
        'secondSampler': _secondSamplerName!,
        'dateSample': sampleDate!,
        'timeSample': sampleTime!,
        'stationID': _selectedStationID!,
        'classifyID': _selectedClassifyID!,
        'latitude': latitude!,
        'longitude': longitude!,
        'getLatitude': _getLatitude!,
        'getLongitude': _getLongitude!,
        'distance':_distanceDevice.toString(),
        'optionalName1': _optionalName1,
        'optionalName2': _optionalName2,
        'optionalName3': _optionalName3,
        'optionalName4': _optionalName4,
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
        String folderName = "tarball/"+_selectedStationID!;
        Directory customDir = Directory('${appDir.path}/$folderName');
        if (!await customDir.exists()) {
          await customDir.create(recursive: true);
        }

        // Create full image path
        //String fileName = path.basename(_image1!.path);
        String fileExtension = path.extension(_image1!.path);
        String fileName = _selectedStationID!+'_'+timestampResult2!+'_LEFTSIDECOASTALVIEW'+fileExtension;
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
        String folderName = "tarball/"+_selectedStationID!;
        Directory customDir = Directory('${appDir.path}/$folderName');
        if (!await customDir.exists()) {
          await customDir.create(recursive: true);
        }

        // Create full image path
        //String fileName = path.basename(_image1!.path);
        String fileExtension = path.extension(_image2!.path);
        String fileName = _selectedStationID!+'_'+timestampResult2!+'_RIGHTSIDECOASTALVIEW'+fileExtension;
        String savedPath = '${customDir.path}/$fileName';

        // Save image
        final savedImage = await imageFile.copy(savedPath);

        setState(() {
          _savedImage = savedImage;
        });

        print("Image saved to: $savedPath");

      }

      // upload image 3
      if (_image3 != null) { // upload image 3

        File? _savedImage;
        File imageFile = File(_image3!.path);

        // Get app directory
        Directory appDir = await getApplicationDocumentsDirectory();

        // Create custom folder
        String folderName = "tarball/"+_selectedStationID!;
        Directory customDir = Directory('${appDir.path}/$folderName');
        if (!await customDir.exists()) {
          await customDir.create(recursive: true);
        }

        // Create full image path
        //String fileName = path.basename(_image1!.path);
        String fileExtension = path.extension(_image3!.path);
        String fileName = _selectedStationID!+'_'+timestampResult2!+'_DRAWINGVERTICALLINES'+fileExtension;
        String savedPath = '${customDir.path}/$fileName';

        // Save image
        final savedImage = await imageFile.copy(savedPath);

        setState(() {
          _savedImage = savedImage;
        });

        print("Image saved to: $savedPath");

      }

      // upload image 4
      if (_image4 != null) { // upload image 4

        File? _savedImage;
        File imageFile = File(_image4!.path);

        // Get app directory
        Directory appDir = await getApplicationDocumentsDirectory();

        // Create custom folder
        String folderName = "tarball/"+_selectedStationID!;
        Directory customDir = Directory('${appDir.path}/$folderName');
        if (!await customDir.exists()) {
          await customDir.create(recursive: true);
        }

        // Create full image path
        //String fileName = path.basename(_image1!.path);
        String fileExtension = path.extension(_image4!.path);
        String fileName = _selectedStationID!+'_'+timestampResult2!+'_DRAWINGHORIZONTALLINES'+fileExtension;
        String savedPath = '${customDir.path}/$fileName';

        // Save image
        final savedImage = await imageFile.copy(savedPath);

        setState(() {
          _savedImage = savedImage;
        });

        print("Image saved to: $savedPath");

      }

      // upload image 5
      if (_image5 != null) { // upload image 5

        File? _savedImage;
        File imageFile = File(_image5!.path);

        // Get app directory
        Directory appDir = await getApplicationDocumentsDirectory();

        // Create custom folder
        String folderName = "tarball/"+_selectedStationID!;
        Directory customDir = Directory('${appDir.path}/$folderName');
        if (!await customDir.exists()) {
          await customDir.create(recursive: true);
        }

        // Create full image path
        //String fileName = path.basename(_image1!.path);
        String fileExtension = path.extension(_image5!.path);
        String fileName = _selectedStationID!+'_'+timestampResult2!+'_OPTIONAL01'+fileExtension;
        String savedPath = '${customDir.path}/$fileName';

        // Save image
        final savedImage = await imageFile.copy(savedPath);

        setState(() {
          _savedImage = savedImage;
        });

        print("Image saved to: $savedPath");

      }

      // upload image 6
      if (_image6 != null) { // upload image 6

        File? _savedImage;
        File imageFile = File(_image6!.path);

        // Get app directory
        Directory appDir = await getApplicationDocumentsDirectory();

        // Create custom folder
        String folderName = "tarball/"+_selectedStationID!;
        Directory customDir = Directory('${appDir.path}/$folderName');
        if (!await customDir.exists()) {
          await customDir.create(recursive: true);
        }

        // Create full image path
        //String fileName = path.basename(_image1!.path);
        String fileExtension = path.extension(_image6!.path);
        String fileName = _selectedStationID!+'_'+timestampResult2!+'_OPTIONAL02'+fileExtension;
        String savedPath = '${customDir.path}/$fileName';

        // Save image
        final savedImage = await imageFile.copy(savedPath);

        setState(() {
          _savedImage = savedImage;
        });

        print("Image saved to: $savedPath");

      }

      // upload image 7
      if (_image7 != null) { // upload image 7

        File? _savedImage;
        File imageFile = File(_image7!.path);

        // Get app directory
        Directory appDir = await getApplicationDocumentsDirectory();

        // Create custom folder
        String folderName = "tarball/"+_selectedStationID!;
        Directory customDir = Directory('${appDir.path}/$folderName');
        if (!await customDir.exists()) {
          await customDir.create(recursive: true);
        }

        // Create full image path
        //String fileName = path.basename(_image1!.path);
        String fileExtension = path.extension(_image7!.path);
        String fileName = _selectedStationID!+'_'+timestampResult2!+'_OPTIONAL03'+fileExtension;
        String savedPath = '${customDir.path}/$fileName';

        // Save image
        final savedImage = await imageFile.copy(savedPath);

        setState(() {
          _savedImage = savedImage;
        });

        print("Image saved to: $savedPath");

      }

      // upload image 8
      if (_image8 != null) { // upload image 8

        File? _savedImage;
        File imageFile = File(_image8!.path);

        // Get app directory
        Directory appDir = await getApplicationDocumentsDirectory();

        // Create custom folder
        String folderName = "tarball/"+_selectedStationID!;
        Directory customDir = Directory('${appDir.path}/$folderName');
        if (!await customDir.exists()) {
          await customDir.create(recursive: true);
        }

        // Create full image path
        //String fileName = path.basename(_image1!.path);
        String fileExtension = path.extension(_image8!.path);
        String fileName = _selectedStationID!+'_'+timestampResult2!+'_OPTIONAL04'+fileExtension;
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
        _secondSamplerName = '';
        selectedLocalSampler = null;
        _dateController.clear();
        _timeController.clear();
        _latitude.clear();
        _longitude.clear();
        _currentLatitude.clear();
        _currentLongitude.clear();

        selectedLocalState = null;
        _isDisplay = false;
        _isCategory = false;
        _isLocation = false;

        _form1 = true;
        _form2 = false;
        _form3 = false;
      });

    }

    else {

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Data failed to save",
          style: TextStyle(fontWeight: FontWeight.bold,color: Colors.white),),backgroundColor: Colors.red,),
      );

      setState(() {

        firstSamplerName = '';
        _secondSamplerName = '';
        selectedLocalSampler = null;
        _dateController.clear();
        _timeController.clear();
        _latitude.clear();
        _longitude.clear();
        _currentLatitude.clear();
        _currentLongitude.clear();

        selectedLocalState = null;
        _isDisplay = false;
        _isCategory = false;
        _isLocation = false;

        _form1 = true;
        _form2 = false;
        _form3 = false;
      });

    }

  }
}