import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:numberpicker/numberpicker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:toggle_switch/toggle_switch.dart';
import 'package:http/http.dart' as http;

class SFormPreSampling extends StatefulWidget {
  _SFormPreSampling createState() => _SFormPreSampling();
}

class _SFormPreSampling extends State<SFormPreSampling> {

  bool _isLoading = false;

  final TextEditingController _startController = TextEditingController();
  final TextEditingController _lastController = TextEditingController();

  final TextEditingController _lastReplaceDate1 = TextEditingController();
  final TextEditingController _newReplaceDate1 = TextEditingController();

  final TextEditingController _lastReplaceDate2 = TextEditingController();
  final TextEditingController _newReplaceDate2 = TextEditingController();

  final TextEditingController _lastReplaceDate3 = TextEditingController();
  final TextEditingController _newReplaceDate3 = TextEditingController();

  final TextEditingController _lastReplaceDate4 = TextEditingController();
  final TextEditingController _newReplaceDate4 = TextEditingController();

  final TextEditingController _conductedDate = TextEditingController();
  final TextEditingController _verifiedDate = TextEditingController();

  late String? lastReplaceDate1, newReplaceDate1;
  late String? lastReplaceDate2, newReplaceDate2;
  late String? lastReplaceDate3, newReplaceDate3;
  late String? lastReplaceDate4, newReplaceDate4;

  late String? conductedDate, verifiedDate;
  late String? verifiedName, verifiedDesignation;

  final TextEditingController _timeController1 = TextEditingController();
  TimeOfDay selectedTime1 = TimeOfDay.now();
  int selectedSecond1 = 0;

  final TextEditingController _timeController2 = TextEditingController();
  TimeOfDay selectedTime2 = TimeOfDay.now();
  int selectedSecond2 = 0;

  late String? startDate, endDate, sampleTime1, sampleTime2;
  late String? locationName, observationName1, observationName2, observationName3;
  late String? serialNumber1, newserialNumber1;
  late String? serialNumber2, newserialNumber2;
  late String? serialNumber3, newserialNumber3;
  late String? serialNumber4, newserialNumber4;
  late String? serialNumber5, newserialNumber5;
  late String? serialNumber6, newserialNumber6;

  late int bullet1=1, bullet2=1;
  late int bullet3=1, bullet4=1;
  late int bullet5=1, bullet6=1, bullet7=1, bullet8=1, bullet9=1, bullet10=1, bullet11=1, bullet12=1;
  late int bullet13=1, bullet14=1, bullet15=1, bullet16=1;

  final TextEditingController _conductName = TextEditingController();
  final TextEditingController _designation = TextEditingController();
  late String? conductName,designationName;

  final _formPreSample1 = GlobalKey<FormState>();

  late String _formType = '';
  bool _isSamplingForm  = true;
  bool _isForm1 = false;
  bool _isForm2 = false;
  bool _isForm3 = false;

  late String _special_1 = 'μ';
  late String? _userID;

  final List<Map<String, dynamic>> items = [
    {'index': 0, 'value': 'Equipment Maintenance & Repair (F-MM01)'},
    {'index': 1, 'value': 'Sonde Calibration Form (F-MM02)'},
    {'index': 2, 'value': 'Pre-Departure Checklist & Safety Checklist Form (F-MM03)'},
  ];
  int? selectedIndex;

  Future<void> _selectDateStart(BuildContext context) async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(), // Default date
      firstDate: DateTime(2000),  // Earliest date
      lastDate: DateTime(2100),  // Latest date
    );

    if (pickedDate != null) {
      setState(() {
        _startController.text = "${pickedDate.toLocal()}".split(' ')[0];
      });
    }
  }

  Future<void> _selectDateLast(BuildContext context) async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(), // Default date
      firstDate: DateTime(2000),  // Earliest date
      lastDate: DateTime(2100),  // Latest date
    );

    if (pickedDate != null) {
      setState(() {
        _lastController.text = "${pickedDate.toLocal()}".split(' ')[0];
      });
    }
  }

  Future<void> _selectDateReplacement1(BuildContext context) async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(), // Default date
      firstDate: DateTime(2000),  // Earliest date
      lastDate: DateTime(2100),  // Latest date
    );

    if (pickedDate != null) {
      setState(() {
        _lastReplaceDate1.text = "${pickedDate.toLocal()}".split(' ')[0];
      });
    }
  }

  Future<void> _selectDateNewReplacement1(BuildContext context) async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(), // Default date
      firstDate: DateTime(2000),  // Earliest date
      lastDate: DateTime(2100),  // Latest date
    );

    if (pickedDate != null) {
      setState(() {
        _newReplaceDate1.text = "${pickedDate.toLocal()}".split(' ')[0];
      });
    }
  }

  Future<void> _selectDateReplacement2(BuildContext context) async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(), // Default date
      firstDate: DateTime(2000),  // Earliest date
      lastDate: DateTime(2100),  // Latest date
    );

    if (pickedDate != null) {
      setState(() {
        _lastReplaceDate2.text = "${pickedDate.toLocal()}".split(' ')[0];
      });
    }
  }

  Future<void> _selectDateNewReplacement2(BuildContext context) async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(), // Default date
      firstDate: DateTime(2000),  // Earliest date
      lastDate: DateTime(2100),  // Latest date
    );

    if (pickedDate != null) {
      setState(() {
        _newReplaceDate2.text = "${pickedDate.toLocal()}".split(' ')[0];
      });
    }
  }

  Future<void> _selectDateReplacement3(BuildContext context) async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(), // Default date
      firstDate: DateTime(2000),  // Earliest date
      lastDate: DateTime(2100),  // Latest date
    );

    if (pickedDate != null) {
      setState(() {
        _lastReplaceDate3.text = "${pickedDate.toLocal()}".split(' ')[0];
      });
    }
  }

  Future<void> _selectDateNewReplacement3(BuildContext context) async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(), // Default date
      firstDate: DateTime(2000),  // Earliest date
      lastDate: DateTime(2100),  // Latest date
    );

    if (pickedDate != null) {
      setState(() {
        _newReplaceDate3.text = "${pickedDate.toLocal()}".split(' ')[0];
      });
    }
  }

  Future<void> _selectDateReplacement4(BuildContext context) async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(), // Default date
      firstDate: DateTime(2000),  // Earliest date
      lastDate: DateTime(2100),  // Latest date
    );

    if (pickedDate != null) {
      setState(() {
        _lastReplaceDate4.text = "${pickedDate.toLocal()}".split(' ')[0];
      });
    }
  }

  Future<void> _selectDateNewReplacement4(BuildContext context) async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(), // Default date
      firstDate: DateTime(2000),  // Earliest date
      lastDate: DateTime(2100),  // Latest date
    );

    if (pickedDate != null) {
      setState(() {
        _newReplaceDate4.text = "${pickedDate.toLocal()}".split(' ')[0];
      });
    }
  }

  Future<void> _selectDateConducted(BuildContext context) async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(), // Default date
      firstDate: DateTime(2000),  // Earliest date
      lastDate: DateTime(2100),  // Latest date
    );

    if (pickedDate != null) {
      setState(() {
        _conductedDate.text = "${pickedDate.toLocal()}".split(' ')[0];
      });
    }
  }

  Future<void> _selectDateVerified(BuildContext context) async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(), // Default date
      firstDate: DateTime(2000),  // Earliest date
      lastDate: DateTime(2100),  // Latest date
    );

    if (pickedDate != null) {
      setState(() {
        _verifiedDate.text = "${pickedDate.toLocal()}".split(' ')[0];
      });
    }
  }

  Future<void> _selectTime1(BuildContext context) async {
    TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: selectedTime1, // Default time
    );

    if (pickedTime != null) {
      setState(() {
        selectedTime1 = pickedTime;
      });
      await _selectSeconds1(context);
    }
  }

  Future<void> _selectSeconds1(BuildContext context) async {
    int? pickedSecond = await showDialog<int>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Select Seconds"),
          content: SizedBox(
            height: 150,
            child: Column(
              children: [
                Text("Choose seconds (0-59):"),
                DropdownButton<int>(
                  value: selectedSecond1,
                  items: List.generate(60, (index) {
                    return DropdownMenuItem<int>(
                      value: index,
                      child: Text(index.toString().padLeft(2, '0')),
                    );
                  }),
                  onChanged: (value) {
                    Navigator.of(context).pop(value); // Close dialog and return value
                  },
                ),
              ],
            ),
          ),
        );
      },
    );

    if (pickedSecond != null) {
      setState(() {
        selectedSecond1 = pickedSecond;
        _timeController1.text =
        "${selectedTime1.hour.toString().padLeft(2, '0')}:${selectedTime1.minute.toString().padLeft(2, '0')}:${selectedSecond1.toString().padLeft(2, '0')}";
      });
    }
  }

  Future<void> _selectTime2(BuildContext context) async {
    TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: selectedTime2, // Default time
    );

    if (pickedTime != null) {
      setState(() {
        selectedTime2 = pickedTime;
      });
      await _selectSeconds2(context);
    }
  }

  Future<void> _selectSeconds2(BuildContext context) async {
    int? pickedSecond = await showDialog<int>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Select Seconds"),
          content: SizedBox(
            height: 150,
            child: Column(
              children: [
                Text("Choose seconds (0-59):"),
                DropdownButton<int>(
                  value: selectedSecond2,
                  items: List.generate(60, (index) {
                    return DropdownMenuItem<int>(
                      value: index,
                      child: Text(index.toString().padLeft(2, '0')),
                    );
                  }),
                  onChanged: (value) {
                    Navigator.of(context).pop(value); // Close dialog and return value
                  },
                ),
              ],
            ),
          ),
        );
      },
    );

    if (pickedSecond != null) {
      setState(() {
        selectedSecond2 = pickedSecond;
        _timeController2.text =
        "${selectedTime2.hour.toString().padLeft(2, '0')}:${selectedTime2.minute.toString().padLeft(2, '0')}:${selectedSecond2.toString().padLeft(2, '0')}";
      });
    }
  }

  void _getProfile() async {
    final prefs = await SharedPreferences.getInstance();

    String url = "https://mmsv2.pstw.com.my/api/api-get.php?action=getProfile&userID="+prefs.getString("auth_id").toString();
    final response = await http.get(Uri.parse(url));
    var responseData = json.decode(response.body);

    setState(() {
      _userID = prefs.getString("auth_id").toString();
      _conductName.text = responseData['fullname'].toString();
      _designation.text = responseData['levelName'].toString();
    });

  }

  List<dynamic> _itemData = [];
  //bool _isLoadingData = true;
  bool _isLoadingData = false;

  @override
  void initState() {
    super.initState();
    _getProfile();
    //fetchUserData();
  }

  Future<void> fetchUserData() async {
    final url = Uri.parse('https://mmsv2.pstw.com.my/api/marine/api-get-marine.php?action=marine-sampling');

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        setState(() {
          _itemData = json.decode(response.body);
          _isLoadingData = false;
        });
      } else {
        throw Exception('Failed to load data');
      }
    } catch (e) {
      print('Error fetching data: $e');
      setState(() {
        _isLoadingData = false;
      });
    }
  }

  // form for maintenance
  Widget _buildForm1() {
    return Form(
      key: _formPreSample1,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Equipment Maintenance Form (F-MM01)',style: TextStyle(fontSize: 20,fontWeight: FontWeight.bold),),
          SizedBox(height: 15.0,),
          Row(
            children: [
              Expanded(
                flex: 3,
                child: Text('Maintenance Date'),
              ),
              Expanded(
                flex: 2,
                child: TextFormField(
                  controller: _startController,
                  readOnly: true, // Prevent manual input
                  decoration: InputDecoration(
                    contentPadding: EdgeInsets.fromLTRB(10.0, 10.0, 20.0, 10.0),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10.0)),
                  ),
                  onTap: () => _selectDateStart(context),
                  onSaved: (value) => setState(() => startDate = value!),
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'Start Date';
                    }
                  },
                ),
              ),
            ],
          ),
          SizedBox(height: 5.0,),
          Row(
            children: [
              Expanded(
                flex: 3,
                child: Text('Last Maintenance Date'),
              ),
              Expanded(
                flex: 2,
                child: TextFormField(
                  controller: _lastController,
                  readOnly: true, // Prevent manual input
                  decoration: InputDecoration(
                    contentPadding: EdgeInsets.fromLTRB(10.0, 10.0, 20.0, 10.0),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10.0)),
                  ),
                  onTap: () => _selectDateLast(context),
                  onSaved: (value) => setState(() => endDate = value!),
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'Last Date';
                    }
                  },
                ),
              ),
            ],
          ),
          SizedBox(height: 5.0,),
          Row(
            children: [
              Expanded(
                flex: 3,
                child: Text('Start Time'),
              ),
              Expanded(
                flex: 2,
                child: TextFormField(
                  controller: _timeController1,
                  readOnly: true,
                  decoration: InputDecoration(
                    contentPadding: EdgeInsets.fromLTRB(10.0, 10.0, 20.0, 10.0),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10.0)),
                  ),
                  onTap: () => _selectTime1(context),
                  onSaved: (value) => setState(() => sampleTime1 = value!),
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'Start Time';
                    }
                  },
                ),
              ),
            ],
          ),
          SizedBox(height: 5.0,),
          Row(
            children: [
              Expanded(
                flex: 3,
                child: Text('End Time'),
              ),
              Expanded(
                flex: 2,
                child: TextFormField(
                  controller: _timeController2,
                  readOnly: true,
                  decoration: InputDecoration(
                    contentPadding: EdgeInsets.fromLTRB(10.0, 10.0, 20.0, 10.0),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10.0)),
                  ),
                  onTap: () => _selectTime2(context),
                  onSaved: (value) => setState(() => sampleTime2 = value!),
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'End Time';
                    }
                  },
                ),
              ),
            ],
          ),
          SizedBox(height: 5.0,),
          Row(
            children: [
              Expanded(
                flex: 3,
                child: Text('Location'),
              ),
              Expanded(
                flex: 2,
                child: TextFormField(
                  decoration: InputDecoration(
                    contentPadding: EdgeInsets.fromLTRB(10.0, 10.0, 20.0, 10.0),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10.0)),
                  ),
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'Location';
                    }
                  },
                  onSaved: (value) => setState(() => locationName = value!),
                ),
              ),
            ],
          ),
          SizedBox(height: 5.0,),
          Row(
            children: [
              Expanded(
                flex: 3,
                child: Text('Schedule Maintenance'),
              ),
              Expanded(
                flex: 2,
                child: Row(
                  children: [
                    ToggleSwitch(
                      initialLabelIndex: 1,
                      totalSwitches: 2,
                      labels: [
                        'Yes',
                        'No',
                      ],
                      onToggle: (index) {
                        bullet1 = index!;
                        print('switched to: $index' + bullet1.toString());
                      },
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
                flex: 3,
                child: Text('Sonde/Sensor/Tip/Part Replacement'),
              ),
              Expanded(
                flex: 2,
                child: Row(
                  children: [
                    ToggleSwitch(
                      initialLabelIndex: 1,
                      totalSwitches: 2,
                      labels: [
                        'Yes',
                        'No',
                      ],
                      onToggle: (index) {
                        bullet2 = index!;
                        print('switched to: $index');
                      },
                    )
                  ],
                ),
              ),
            ],
          ),

          Divider(),
          Text('PART 1: YSI EXO 2 Multiparameter Sonde & EXO Sensor',
            style: TextStyle(fontWeight: FontWeight.bold,fontSize: 18),),
          SizedBox(height: 5.0,),
          Divider(),
          Text('YSI EXO 2 Multiparameter Sonde',
            style: TextStyle(fontWeight: FontWeight.bold),),
          SizedBox(height: 10.0,),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('1) Upper body of instrument'),
              Text('2) Side body of instrument'),
              Text('3) Bottom body of instrument'),
              Text('4) Sonde guard and calibration cup'),
            ],
          ),
          Row(
            children: [
              Expanded(
                flex: 1,
                child: Text('Inspect',
                  style: TextStyle(fontWeight: FontWeight.bold),textAlign: TextAlign.center,),
              ),
              Expanded(
                flex: 1,
                child: Text('Clean',
                  style: TextStyle(fontWeight: FontWeight.bold),textAlign: TextAlign.center,),
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ToggleSwitch(
                initialLabelIndex: 1,
                totalSwitches: 2,
                labels: [
                  'Yes',
                  'No',
                ],
                onToggle: (index) {
                  bullet3 = index!;
                  print('switched to: $index');
                },
              ),
              ToggleSwitch(
                initialLabelIndex: 1,
                totalSwitches: 2,
                labels: [
                  'Yes',
                  'No',
                ],
                onToggle: (index) {
                  bullet4 = index!;
                  print('switched to: $index');
                },
              ),
            ],
          ),
          SizedBox(height: 10.0,),
          Row(
            children: [
              Expanded(
                child: Text('Observation:',
                  style: TextStyle(fontWeight: FontWeight.bold),),
              ),
              Expanded(
                flex: 2,
                child: TextFormField(
                  decoration: InputDecoration(
                    contentPadding: EdgeInsets.fromLTRB(10.0, 10.0, 20.0, 10.0),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10.0)),
                  ),
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'Observation';
                    }
                  },
                  onSaved: (value) => setState(() => observationName1 = value!),
                ),
              ),
            ],
          ),
          Divider(),
          Text('EXO Sensor',
            style: TextStyle(fontWeight: FontWeight.bold),),
          SizedBox(height: 10.0,),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('1)	Sensor body'),
              Text('2)	Lenses'),
              Text('3)	Pin connector'),
              Text('4)	Retaining Nut Kit'),
            ],
          ),
          SizedBox(height: 5.0,),
          Row(
            children: [
              Expanded(
                child: Text('Sensor',
                  style: TextStyle(fontWeight: FontWeight.bold),),
              ),
              Expanded(
                child: Text('Inspect',
                  style: TextStyle(fontWeight: FontWeight.bold),),
              ),
              Expanded(
                child: Text('Clean',
                  style: TextStyle(fontWeight: FontWeight.bold),),
              ),
            ],
          ),

          Row(
            children: [
              Expanded(
                child: Text('pH'),
              ),
              Expanded(
                child: Row(
                  children: [
                    SizedBox(
                      width:100,
                      child: ToggleSwitch(
                        initialLabelIndex: 1,
                        totalSwitches: 2,
                        labels: [
                          'Yes',
                          'No',
                        ],
                        onToggle: (index) {
                          bullet5 = index!;
                          print('switched to: $index');
                        },
                      ),
                    )
                  ],
                ),
              ),
              Expanded(
                child: Row(
                  children: [
                    SizedBox(
                      width:100,
                      child: ToggleSwitch(
                        initialLabelIndex: 1,
                        totalSwitches: 2,
                        labels: [
                          'Yes',
                          'No',
                        ],
                        onToggle: (index) {
                          bullet6 = index!;
                          print('switched to: $index');
                        },
                      ),
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
                child: Text('Conductivity'),
              ),
              Expanded(
                child: Row(
                  children: [
                    SizedBox(
                      width:100,
                      child: ToggleSwitch(
                        initialLabelIndex: 1,
                        totalSwitches: 2,
                        labels: [
                          'Yes',
                          'No',
                        ],
                        onToggle: (index) {
                          bullet7 = index!;
                          print('switched to: $index');
                        },
                      ),
                    )
                  ],
                ),
              ),
              Expanded(
                child: Row(
                  children: [
                    SizedBox(
                      width:100,
                      child: ToggleSwitch(
                        initialLabelIndex: 1,
                        totalSwitches: 2,
                        labels: [
                          'Yes',
                          'No',
                        ],
                        onToggle: (index) {
                          bullet8 = index!;
                          print('switched to: $index');
                        },
                      ),
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
                child: Text('Turbidity'),
              ),
              Expanded(
                child: Row(
                  children: [
                    SizedBox(
                      width:100,
                      child: ToggleSwitch(
                        initialLabelIndex: 1,
                        totalSwitches: 2,
                        labels: [
                          'Yes',
                          'No',
                        ],
                        onToggle: (index) {
                          bullet9 = index!;
                          print('switched to: $index');
                        },
                      ),
                    )
                  ],
                ),
              ),
              Expanded(
                child: Row(
                  children: [
                    SizedBox(
                      width:100,
                      child: ToggleSwitch(
                        initialLabelIndex: 1,
                        totalSwitches: 2,
                        labels: [
                          'Yes',
                          'No',
                        ],
                        onToggle: (index) {
                          bullet10 = index!;
                          print('switched to: $index');
                        },
                      ),
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
                child: Text('Dissolved Oxygen'),
              ),
              Expanded(
                child: Row(
                  children: [
                    SizedBox(
                      width:100,
                      child: ToggleSwitch(
                        initialLabelIndex: 1,
                        totalSwitches: 2,
                        labels: [
                          'Yes',
                          'No',
                        ],
                        onToggle: (index) {
                          bullet11 = index!;
                          print('switched to: $index');
                        },
                      ),
                    )
                  ],
                ),
              ),
              Expanded(
                child: Row(
                  children: [
                    SizedBox(
                      width:100,
                      child: ToggleSwitch(
                        initialLabelIndex: 1,
                        totalSwitches: 2,
                        labels: [
                          'Yes',
                          'No',
                        ],
                        onToggle: (index) {
                          bullet12 = index!;
                          print('switched to: $index');
                        },
                      ),
                    )
                  ],
                ),
              ),
            ],
          ),

          SizedBox(height: 10.0,),
          Row(
            children: [
              Expanded(
                child: Text('Observation:',
                  style: TextStyle(fontWeight: FontWeight.bold),),
              ),
              Expanded(
                flex: 2,
                child: TextFormField(
                  decoration: InputDecoration(
                    contentPadding: EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10.0),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10.0)),
                  ),
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'Observation';
                    }
                  },
                  onSaved: (value) => setState(() => observationName2 = value!),
                ),
              ),
            ],
          ),

          Divider(),
          Text('Sonde/Sensor/Tip Replacement',
            style: TextStyle(fontWeight: FontWeight.bold),),
          SizedBox(height: 10.0,),
          Text('1. YSI EXO 2 Multiparameter Sonde',
            style: TextStyle(fontWeight: FontWeight.bold),),
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  decoration: InputDecoration(
                    hintStyle: TextStyle(fontSize: 10),
                    hintText: 'Current Serial Number',
                    contentPadding: EdgeInsets.fromLTRB(10.0, 10.0, 20.0, 10.0),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10.0)),
                  ),
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'Serial number';
                    }
                  },
                  onSaved: (value) => setState(() => serialNumber1 = value!),
                ),
              ),
            ],
          ),

          SizedBox(height: 5.0,),
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  decoration: InputDecoration(
                    hintStyle: TextStyle(fontSize: 10),
                    hintText: 'New Serial Number',
                    contentPadding: EdgeInsets.fromLTRB(10.0, 10.0, 20.0, 10.0),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10.0)),
                  ),
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'New serial number';
                    }
                  },
                  onSaved: (value) => setState(() => newserialNumber1 = value!),
                ),
              ),
            ],
          ),

          SizedBox(height: 5.0,),
          Text('2. pH',
            style: TextStyle(fontWeight: FontWeight.bold),),
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  decoration: InputDecoration(
                    hintStyle: TextStyle(fontSize: 10),
                    hintText: 'Current Serial Number',
                    contentPadding: EdgeInsets.fromLTRB(10.0, 10.0, 20.0, 10.0),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10.0)),
                  ),
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'Serial number';
                    }
                  },
                  onSaved: (value) => setState(() => serialNumber2 = value!),
                ),
              ),
            ],
          ),
          SizedBox(height: 5.0,),
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  decoration: InputDecoration(
                    hintStyle: TextStyle(fontSize: 10),
                    hintText: 'New Serial Number',
                    contentPadding: EdgeInsets.fromLTRB(10.0, 10.0, 20.0, 10.0),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10.0)),
                  ),
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'New serial number';
                    }
                  },
                  onSaved: (value) => setState(() => newserialNumber2 = value!),
                ),
              ),
            ],
          ),

          SizedBox(height: 5.0,),
          Text('3. Conductivity',
            style: TextStyle(fontWeight: FontWeight.bold),),
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  decoration: InputDecoration(
                    hintStyle: TextStyle(fontSize: 10),
                    hintText: 'Current Serial Number',
                    contentPadding: EdgeInsets.fromLTRB(10.0, 10.0, 20.0, 10.0),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10.0)),
                  ),
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'Serial number';
                    }
                  },
                  onSaved: (value) => setState(() => serialNumber3 = value!),
                ),
              ),
            ],
          ),
          SizedBox(height: 5.0,),
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  decoration: InputDecoration(
                    hintStyle: TextStyle(fontSize: 10),
                    hintText: 'New Serial Number',
                    contentPadding: EdgeInsets.fromLTRB(10.0, 10.0, 20.0, 10.0),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10.0)),
                  ),
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'New serial number';
                    }
                  },
                  onSaved: (value) => setState(() => newserialNumber3 = value!),
                ),
              ),
            ],
          ),

          SizedBox(height: 5.0,),
          Text('4. Turbidity',
            style: TextStyle(fontWeight: FontWeight.bold),),
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  decoration: InputDecoration(
                    hintStyle: TextStyle(fontSize: 10),
                    hintText: 'Current Serial Number',
                    contentPadding: EdgeInsets.fromLTRB(10.0, 10.0, 20.0, 10.0),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10.0)),
                  ),
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'Serial number';
                    }
                  },
                  onSaved: (value) => setState(() => serialNumber4 = value!),
                ),
              ),
            ],
          ),
          SizedBox(height: 5.0,),
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  decoration: InputDecoration(
                    hintStyle: TextStyle(fontSize: 10),
                    hintText: 'New Serial Number',
                    contentPadding: EdgeInsets.fromLTRB(10.0, 10.0, 20.0, 10.0),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10.0)),
                  ),
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'New serial number';
                    }
                  },
                  onSaved: (value) => setState(() => newserialNumber4 = value!),
                ),
              ),
            ],
          ),

          SizedBox(height: 5.0,),
          Text('5. Dissolved Oxygen',
            style: TextStyle(fontWeight: FontWeight.bold),),
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  decoration: InputDecoration(
                    hintStyle: TextStyle(fontSize: 10),
                    hintText: 'Current Serial Number',
                    contentPadding: EdgeInsets.fromLTRB(10.0, 10.0, 20.0, 10.0),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10.0)),
                  ),
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'Serial number';
                    }
                  },
                  onSaved: (value) => setState(() => serialNumber5 = value!),
                ),
              ),
            ],
          ),
          SizedBox(height: 5.0,),
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  decoration: InputDecoration(
                    hintStyle: TextStyle(fontSize: 10),
                    hintText: 'New Serial Number',
                    contentPadding: EdgeInsets.fromLTRB(10.0, 10.0, 20.0, 10.0),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10.0)),
                  ),
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'New serial number';
                    }
                  },
                  onSaved: (value) => setState(() => newserialNumber5 = value!),
                ),
              ),
            ],
          ),

          Divider(),
          Text('PART 2: Van Dorn Sampler',
            style: TextStyle(fontWeight: FontWeight.bold,fontSize: 18),),
          SizedBox(height: 10.0,),
          Text('Schedule Maintenance – Inspection & Cleaning',
            style: TextStyle(fontWeight: FontWeight.bold,),),
          SizedBox(height: 5.0,),
          Row(
            children: [
              Expanded(
                flex: 2,
                child: Text(''),
              ),
              Expanded(
                child: Row(
                  children: [
                    SizedBox(
                      width:80,
                      child: Text('Inspect',
                        style: TextStyle(fontWeight: FontWeight.bold),),
                    )
                  ],
                ),
              ),
              Expanded(
                child: Row(
                  children: [
                    SizedBox(
                      width: 80,
                      child: Text('Clean',
                        style: TextStyle(fontWeight: FontWeight.bold),),
                    ),
                  ],
                ),
              ),
            ],
          ),

          Row(
            children: [
              Expanded(
                flex: 2,
                child: Text('Inside body, outside body & outlet valves cleaning'),
              ),
              Expanded(
                child: Row(
                  children: [
                    SizedBox(
                      width:80,
                      child: ToggleSwitch(
                        initialLabelIndex: 1,
                        totalSwitches: 2,
                        labels: [
                          'Y',
                          'N',
                        ],
                        onToggle: (index) {
                          bullet13 = index!;
                          print('switched to: $index');
                        },
                      ),
                    )
                  ],
                ),
              ),
              Expanded(
                child: Row(
                  children: [
                    SizedBox(
                      width:80,
                      child: ToggleSwitch(
                        initialLabelIndex: 1,
                        totalSwitches: 2,
                        labels: [
                          'Y',
                          'N',
                        ],
                        onToggle: (index) {
                          bullet14 = index!;
                          print('switched to: $index');
                        },
                      ),
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
                child: Text('Check cable assembly & tubing assembly'),
              ),
              Expanded(
                child: Row(
                  children: [
                    SizedBox(
                      width:80,
                      child: ToggleSwitch(
                        initialLabelIndex: 1,
                        totalSwitches: 2,
                        labels: [
                          'Y',
                          'N',
                        ],
                        onToggle: (index) {
                          bullet15 = index!;
                          print('switched to: $index');
                        },
                      ),
                    )
                  ],
                ),
              ),
              Expanded(
                child: Row(
                  children: [

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
                child: Text('Check messenger and rope'),
              ),
              Expanded(
                child: Row(
                  children: [
                    SizedBox(
                      width:80,
                      child: ToggleSwitch(
                        initialLabelIndex: 1,
                        totalSwitches: 2,
                        labels: [
                          'Y',
                          'N',
                        ],
                        onToggle: (index) {
                          bullet16 = index!;
                          print('switched to: $index');
                        },
                      ),
                    )
                  ],
                ),
              ),
              Expanded(
                child: Row(
                  children: [

                  ],
                ),
              ),
            ],
          ),

          SizedBox(height: 5.0,),
          Row(
            children: [
              Expanded(
                child: Text('Observation:',
                  style: TextStyle(fontWeight: FontWeight.bold),),
              ),
              Expanded(
                flex: 2,
                child: TextFormField(
                  decoration: InputDecoration(
                    contentPadding: EdgeInsets.fromLTRB(10.0, 10.0, 20.0, 10.0),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10.0)),
                  ),
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'Observation';
                    }
                  },
                  onSaved: (value) => setState(() => observationName3 = value!),
                ),
              ),
            ],
          ),
          Divider(),
          Text('Van Dorn Sampler Part Replacement',
            style: TextStyle(fontWeight: FontWeight.bold,),),
          SizedBox(height: 5.0,),
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  decoration: InputDecoration(
                    hintStyle: TextStyle(fontSize: 10),
                    hintText: 'Current Serial Number',
                    contentPadding: EdgeInsets.fromLTRB(10.0, 10.0, 20.0, 10.0),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10.0)),
                  ),
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'Serial number';
                    }
                  },
                  onSaved: (value) => setState(() => serialNumber6 = value!),
                ),
              ),
            ],
          ),
          SizedBox(height: 5.0,),
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  decoration: InputDecoration(
                    hintStyle: TextStyle(fontSize: 10),
                    hintText: 'New Serial Number',
                    contentPadding: EdgeInsets.fromLTRB(10.0, 10.0, 20.0, 10.0),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10.0)),
                  ),
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'New serial number';
                    }
                  },
                  onSaved: (value) => setState(() => newserialNumber6 = value!),
                ),
              ),
            ],
          ),
          SizedBox(height: 5.0,),

          Row(
            children: [
              Expanded(
                flex: 2,
                child: Text('Part',
                  style: TextStyle(fontWeight: FontWeight.bold),),
              ),
            ],
          ),
          SizedBox(height: 5.0,),
          Row(
            mainAxisSize: MainAxisSize.max,
            children: [
              Expanded(
                flex: 2,
                child: Text('End seals with air / drain valve'),
              ),
              Expanded(
                flex: 3,
                child: Column(
                  children: [
                    TextFormField(
                      controller: _lastReplaceDate1,
                      readOnly: true, // Prevent manual input
                      decoration: InputDecoration(
                        hintText: 'Last replacement date',
                        hintStyle: TextStyle(fontSize: 10),
                        contentPadding: EdgeInsets.fromLTRB(10.0, 10.0, 20.0, 10.0),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10.0)),
                      ),
                      onTap: () => _selectDateReplacement1(context),
                      onSaved: (value) => setState(() => lastReplaceDate1 = value!),
                      validator: (value) {
                        if (value!.isEmpty) {
                          return 'Last replacement date';
                        }
                      },
                    ),
                    SizedBox(height: 5.0,),
                    TextFormField(
                      controller: _newReplaceDate1,
                      readOnly: true, // Prevent manual input
                      decoration: InputDecoration(
                        hintText: 'New replacement date',
                        hintStyle: TextStyle(fontSize: 10,color: Colors.blueGrey),
                        contentPadding: EdgeInsets.fromLTRB(10.0, 10.0, 20.0, 10.0),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10.0)),
                      ),
                      onTap: () => _selectDateNewReplacement1(context),
                      onSaved: (value) => setState(() => newReplaceDate1 = value!),
                      validator: (value) {
                        if (value!.isEmpty) {
                          return 'New replacement date';
                        }
                      },
                    )
                  ],
                ),
              ),
            ],
          ),
          Divider(),

          SizedBox(height: 5.0,),
          Row(
            children: [
              Expanded(
                flex: 2,
                child: Text('Tubing Assembly'),
              ),
              Expanded(
                flex: 3,
                child: Column(
                  children: [
                    TextFormField(
                      controller: _lastReplaceDate2,
                      readOnly: true, // Prevent manual input
                      decoration: InputDecoration(
                        hintText: 'Last replacement date',
                        hintStyle: TextStyle(fontSize: 10),
                        contentPadding: EdgeInsets.fromLTRB(10.0, 10.0, 20.0, 10.0),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10.0)),
                      ),
                      onTap: () => _selectDateReplacement2(context),
                      onSaved: (value) => setState(() => lastReplaceDate2 = value!),
                      validator: (value) {
                        if (value!.isEmpty) {
                          return 'Last replacement date';
                        }
                      },
                    ),
                    SizedBox(height: 5.0,),
                    TextFormField(
                      controller: _newReplaceDate2,
                      readOnly: true, // Prevent manual input
                      decoration: InputDecoration(
                        hintText: 'New replacement date',
                        hintStyle: TextStyle(fontSize: 10),
                        contentPadding: EdgeInsets.fromLTRB(10.0, 10.0, 20.0, 10.0),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10.0)),
                      ),
                      onTap: () => _selectDateNewReplacement2(context),
                      onSaved: (value) => setState(() => newReplaceDate2 = value!),
                      validator: (value) {
                        if (value!.isEmpty) {
                          return 'New replacement date';
                        }
                      },
                    )
                  ],
                ),
              ),
            ],
          ),
          Divider(),

          SizedBox(height: 5.0,),
          Row(
            children: [
              Expanded(
                flex: 2,
                child: Text('Cable Assembly'),
              ),
              Expanded(
                flex: 3,
                child: Column(
                  children: [
                    TextFormField(
                      controller: _lastReplaceDate3,
                      readOnly: true, // Prevent manual input
                      decoration: InputDecoration(
                        hintText: 'Last replacement date',
                        hintStyle: TextStyle(fontSize: 10),
                        contentPadding: EdgeInsets.fromLTRB(10.0, 10.0, 20.0, 10.0),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10.0)),
                      ),
                      onTap: () => _selectDateReplacement3(context),
                      onSaved: (value) => setState(() => lastReplaceDate3 = value!),
                      validator: (value) {
                        if (value!.isEmpty) {
                          return 'Last replacement date';
                        }
                      },
                    ),
                    SizedBox(height: 5.0,),
                    TextFormField(
                      controller: _newReplaceDate3,
                      readOnly: true, // Prevent manual input
                      decoration: InputDecoration(
                        hintText: 'New replacement date',
                        hintStyle: TextStyle(fontSize: 10),
                        contentPadding: EdgeInsets.fromLTRB(10.0, 10.0, 20.0, 10.0),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10.0)),
                      ),
                      onTap: () => _selectDateNewReplacement3(context),
                      onSaved: (value) => setState(() => newReplaceDate3 = value!),
                      validator: (value) {
                        if (value!.isEmpty) {
                          return 'New replacement date';
                        }
                      },
                    )
                  ],
                ),
              ),
            ],
          ),
          Divider(),

          SizedBox(height: 5.0,),
          Row(
            children: [
              Expanded(
                flex: 2,
                child: Text('Main Tube\nTransparent'),
              ),
              Expanded(
                flex: 3,
                child: Column(
                  children: [
                    TextFormField(
                      controller: _lastReplaceDate4,
                      readOnly: true, // Prevent manual input
                      decoration: InputDecoration(
                        hintText: 'Last replacement date',
                        hintStyle: TextStyle(fontSize: 10),
                        contentPadding: EdgeInsets.fromLTRB(10.0, 10.0, 20.0, 10.0),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10.0)),
                      ),
                      onTap: () => _selectDateReplacement4(context),
                      onSaved: (value) => setState(() => lastReplaceDate4 = value!),
                      validator: (value) {
                        if (value!.isEmpty) {
                          return 'Last replacement date';
                        }
                      },
                    ),
                    SizedBox(height: 5.0,),
                    TextFormField(
                      controller: _newReplaceDate4,
                      readOnly: true, // Prevent manual input
                      decoration: InputDecoration(
                        hintText: 'New replacement date',
                        hintStyle: TextStyle(fontSize: 10),
                        contentPadding: EdgeInsets.fromLTRB(10.0, 10.0, 20.0, 10.0),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10.0)),
                      ),
                      onTap: () => _selectDateNewReplacement4(context),
                      onSaved: (value) => setState(() => newReplaceDate4 = value!),
                      validator: (value) {
                        if (value!.isEmpty) {
                          return 'New replacement date';
                        }
                      },
                    )
                  ],
                ),
              ),
            ],
          ),

          Divider(),
          Row(
            children: [
              Expanded(
                child: Text('Conducted by:',
                  style: TextStyle(fontWeight: FontWeight.bold),),
              ),
              Expanded(
                flex: 2,
                child: TextFormField(
                  readOnly: true,
                  controller: _conductName,
                  style: TextStyle(fontSize: 13),
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.grey[200],
                    contentPadding: EdgeInsets.fromLTRB(10.0, 10.0, 20.0, 10.0),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10.0)),
                  ),
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'Conducted By';
                    }
                  },
                  onSaved: (value) => setState(() => conductName = value!),
                ),
              ),
            ],
          ),
          SizedBox(height: 5.0,),
          Row(
            children: [
              Expanded(
                child: Text('Signature:',
                  style: TextStyle(fontWeight: FontWeight.bold),),
              ),
              Expanded(
                flex: 2,
                child: TextFormField(
                  decoration: InputDecoration(
                    contentPadding: EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10.0),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10.0)),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 5.0,),
          Row(
            children: [
              Expanded(
                child: Text('Designation:',
                  style: TextStyle(fontWeight: FontWeight.bold),),
              ),
              Expanded(
                flex: 2,
                child: TextFormField(
                  style: TextStyle(fontSize: 13),
                  readOnly: true,
                  controller: _designation,
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.grey[200],
                    contentPadding: EdgeInsets.fromLTRB(10.0, 10.0, 20.0, 10.0),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10.0)),
                  ),
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'Designation';
                    }
                  },
                  onSaved: (value) => setState(() => designationName = value!),
                ),
              ),
            ],
          ),
          SizedBox(height: 5.0,),
          Row(
            children: [
              Expanded(
                child: Text('Date:',
                  style: TextStyle(fontWeight: FontWeight.bold),),
              ),
              Expanded(
                flex: 2,
                child: TextFormField(
                  controller: _conductedDate,
                  readOnly: true, // Prevent manual input
                  decoration: InputDecoration(
                    contentPadding: EdgeInsets.fromLTRB(10.0, 10.0, 20.0, 10.0),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10.0)),
                  ),
                  onTap: () => _selectDateConducted(context),
                  onSaved: (value) => setState(() => conductedDate = value!),
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'Conducted Date';
                    }
                  },
                ),
              ),
            ],
          ),

          Divider(),
          Row(
            children: [
              Expanded(
                child: Text('Verified by:',
                  style: TextStyle(fontWeight: FontWeight.bold,color: Colors.green),),
              ),
              Expanded(
                flex: 2,
                child: TextFormField(
                  decoration: InputDecoration(
                    contentPadding: EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10.0),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10.0)),
                  ),
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'Verified By';
                    }
                  },
                  onSaved: (value) => setState(() => verifiedName = value!),
                ),
              ),
            ],
          ),
          SizedBox(height: 5.0,),
          Row(
            children: [
              Expanded(
                child: Text('Signature:',
                  style: TextStyle(fontWeight: FontWeight.bold,color: Colors.green),),
              ),
              Expanded(
                flex: 2,
                child: TextFormField(
                  decoration: InputDecoration(
                    contentPadding: EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10.0),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10.0)),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 5.0,),
          Row(
            children: [
              Expanded(
                child: Text('Designation:',
                  style: TextStyle(fontWeight: FontWeight.bold,color: Colors.green),),
              ),
              Expanded(
                flex: 2,
                child: TextFormField(
                  decoration: InputDecoration(
                    contentPadding: EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10.0),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10.0)),
                  ),
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'Designation';
                    }
                  },
                  onSaved: (value) => setState(() => verifiedDesignation = value!),
                ),
              ),
            ],
          ),
          SizedBox(height: 5.0,),
          Row(
            children: [
              Expanded(
                child: Text('Date:',
                  style: TextStyle(fontWeight: FontWeight.bold,color: Colors.green),),
              ),
              Expanded(
                flex: 2,
                child: TextFormField(
                  controller: _verifiedDate,
                  readOnly: true, // Prevent manual input
                  decoration: InputDecoration(
                    contentPadding: EdgeInsets.fromLTRB(10.0, 10.0, 20.0, 10.0),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10.0)),
                  ),
                  onTap: () => _selectDateVerified(context),
                  onSaved: (value) => setState(() => verifiedDate = value!),
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'Verified Date';
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
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey
                  ),
                  onPressed: () {

                  },
                  child: Text('Cancel',
                    style: TextStyle(fontWeight: FontWeight.bold,color: Colors.white),),
                ),
              ),
              SizedBox(width: 10.0,),
              Expanded(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue
                  ),
                  onPressed: () {
                    if (_formPreSample1.currentState!.validate()) {
                      _formPreSample1.currentState!.save();
                      _submitForm1();
                    }
                  },
                  child: Text('Submit',
                    style: TextStyle(fontWeight: FontWeight.bold,color: Colors.white),),
                ),
              )
            ],
          ),
        ],
      ),
    );
  }

  final _formPreSample2 = GlobalKey<FormState>();

  final TextEditingController _sondeStartDate = TextEditingController();
  final TextEditingController _sondeEndDate = TextEditingController();

  final TextEditingController _sondeConductedDate = TextEditingController();
  final TextEditingController _sondeVerifiedDate = TextEditingController();

  final TextEditingController _sondeStartTime = TextEditingController();
  final TextEditingController _sondeEndTime = TextEditingController();

  late String? sondeConductedDate,sondeVerifiedDate;
  late String? sondeStartDate,sondeEndDate;
  late String? sondeStartTime,sondeEndTime;
  late String? sondeSerialNumber,firmWareVersion,korVersion,sondeLocation;
  late String? ph7_reading,ph7_before,ph7_after;
  late String? ph10_reading,ph10_before,ph10_after;
  late String? sp_before,sp_after;
  late String? ntu_before,ntu_after;
  late String? dis_before,dis_after;
  late String? sondeObservation;
  late String? sondeVerifiedName,sondeVerifiedDesignation;
  int _hour = 0, _minute = 0, _second = 0;

  void _showSondeStartTime() {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Container(
          padding: EdgeInsets.all(16.0),
          height: 300,
          child: Column(
            children: [
              Text("Select Time", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  // Hour picker
                  Column(
                    children: [
                      Text("Hour"),
                      NumberPicker(
                        minValue: 0,
                        maxValue: 23,
                        value: _hour,
                        onChanged: (value) => setState(() => _hour = value),
                      ),
                    ],
                  ),
                  // Minute picker
                  Column(
                    children: [
                      Text("Minute"),
                      NumberPicker(
                        minValue: 0,
                        maxValue: 59,
                        value: _minute,
                        onChanged: (value) => setState(() => _minute = value),
                      ),
                    ],
                  ),
                  // Second picker
                  Column(
                    children: [
                      Text("Second"),
                      NumberPicker(
                        minValue: 0,
                        maxValue: 59,
                        value: _second,
                        onChanged: (value) => setState(() => _second = value),
                      ),
                    ],
                  ),
                ],
              ),
              ElevatedButton(
                onPressed: () {
                  _sondeStartTime.text = '${_hour.toString().padLeft(2, '0')}:${_minute.toString().padLeft(2, '0')}:${_second.toString().padLeft(2, '0')}';
                  Navigator.pop(context);
                },
                child: Text("Select Time"),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showSondeEndTime() {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Container(
          padding: EdgeInsets.all(16.0),
          height: 300,
          child: Column(
            children: [
              Text("Select Time", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  // Hour picker
                  Column(
                    children: [
                      Text("Hour"),
                      NumberPicker(
                        minValue: 0,
                        maxValue: 23,
                        value: _hour,
                        onChanged: (value) => setState(() => _hour = value),
                      ),
                    ],
                  ),
                  // Minute picker
                  Column(
                    children: [
                      Text("Minute"),
                      NumberPicker(
                        minValue: 0,
                        maxValue: 59,
                        value: _minute,
                        onChanged: (value) => setState(() => _minute = value),
                      ),
                    ],
                  ),
                  // Second picker
                  Column(
                    children: [
                      Text("Second"),
                      NumberPicker(
                        minValue: 0,
                        maxValue: 59,
                        value: _second,
                        onChanged: (value) => setState(() => _second = value),
                      ),
                    ],
                  ),
                ],
              ),
              ElevatedButton(
                onPressed: () {
                  _sondeEndTime.text = '${_hour.toString().padLeft(2, '0')}:${_minute.toString().padLeft(2, '0')}:${_second.toString().padLeft(2, '0')}';
                  Navigator.pop(context);
                },
                child: Text("Select Time"),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _selectSondeStartDate(BuildContext context) async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(), // Default date
      firstDate: DateTime(2000),  // Earliest date
      lastDate: DateTime(2100),  // Latest date
    );

    if (pickedDate != null) {
      setState(() {
        _sondeStartDate.text = "${pickedDate.toLocal()}".split(' ')[0];
      });
    }
  }

  Future<void> _selectSondeEndDate(BuildContext context) async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(), // Default date
      firstDate: DateTime(2000),  // Earliest date
      lastDate: DateTime(2100),  // Latest date
    );

    if (pickedDate != null) {
      setState(() {
        _sondeEndDate.text = "${pickedDate.toLocal()}".split(' ')[0];
      });
    }
  }

  Future<void> _selectSondeConductedDate(BuildContext context) async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(), // Default date
      firstDate: DateTime(2000),  // Earliest date
      lastDate: DateTime(2100),  // Latest date
    );

    if (pickedDate != null) {
      setState(() {
        _sondeConductedDate.text = "${pickedDate.toLocal()}".split(' ')[0];
      });
    }
  }

  Future<void> _selectSondeVerifiedDate(BuildContext context) async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(), // Default date
      firstDate: DateTime(2000),  // Earliest date
      lastDate: DateTime(2100),  // Latest date
    );

    if (pickedDate != null) {
      setState(() {
        _sondeVerifiedDate.text = "${pickedDate.toLocal()}".split(' ')[0];
      });
    }
  }

  // form for sonde
  Widget _buildForm2() {
    return Form(
      key: _formPreSample2,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Sonde Calibration Form (F-MM02) ',style: TextStyle(fontSize: 20,fontWeight: FontWeight.bold),),
          SizedBox(height: 15.0,),
          Row(
            children: [
              Expanded(
                child: Text('Sonde Serial Number'),
              ),
              Expanded(
                flex: 2,
                child: TextFormField(
                  decoration: InputDecoration(
                    contentPadding: EdgeInsets.fromLTRB(10.0, 10.0, 20.0, 10.0),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10.0)),
                  ),
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'Serial number';
                    }
                  },
                  onSaved: (value) => setState(() => sondeSerialNumber = value!),
                ),
              ),
            ],
          ),
          SizedBox(height: 5.0,),
          Row(
            children: [
              Expanded(
                child: Text('Firmware Ver.'),
              ),
              Expanded(
                flex: 2,
                child: TextFormField(
                  decoration: InputDecoration(
                    contentPadding: EdgeInsets.fromLTRB(10.0, 10.0, 20.0, 10.0),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10.0)),
                  ),
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'Firmware version';
                    }
                  },
                  onSaved: (value) => setState(() => firmWareVersion = value!),
                ),
              ),
            ],
          ),
          SizedBox(height: 5.0,),
          Row(
            children: [
              Expanded(
                child: Text('Kor Ver.'),
              ),
              Expanded(
                flex: 2,
                child: TextFormField(
                  decoration: InputDecoration(
                    contentPadding: EdgeInsets.fromLTRB(10.0, 10.0, 20.0, 10.0),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10.0)),
                  ),
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'Kor version';
                    }
                  },
                  onSaved: (value) => setState(() => korVersion = value!),
                ),
              ),
            ],
          ),
          SizedBox(height: 5.0,),
          Row(
            children: [
              Expanded(
                child: Text('Start Date'),
              ),
              Expanded(
                flex: 2,
                child: TextFormField(
                  controller: _sondeStartDate,
                  readOnly: true, // Prevent manual input
                  decoration: InputDecoration(
                    contentPadding: EdgeInsets.fromLTRB(10.0, 10.0, 20.0, 10.0),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10.0)),
                  ),
                  onTap: () => _selectSondeStartDate(context),
                  onSaved: (value) => setState(() => sondeStartDate = value!),
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'Start Date';
                    }
                  },
                ),
              ),
            ],
          ),
          SizedBox(height: 5.0,),
          Row(
            children: [
              Expanded(
                child: Text('Start Time'),
              ),
              Expanded(
                flex: 2,
                child: TextFormField(
                  controller: _sondeStartTime,
                  readOnly: true,
                  decoration: InputDecoration(
                    contentPadding: EdgeInsets.fromLTRB(10.0, 10.0, 20.0, 10.0),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10.0)),
                  ),
                  onTap: _showSondeStartTime,
                  onSaved: (value) => setState(() => sondeStartTime = value!),
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'Start time';
                    }
                  },
                ),
              ),
            ],
          ),
          SizedBox(height: 5.0,),
          Row(
            children: [
              Expanded(
                child: Text('End Date'),
              ),
              Expanded(
                flex: 2,
                child: TextFormField(
                  controller: _sondeEndDate,
                  readOnly: true, // Prevent manual input
                  decoration: InputDecoration(
                    contentPadding: EdgeInsets.fromLTRB(10.0, 10.0, 20.0, 10.0),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10.0)),
                  ),
                  onTap: () => _selectSondeEndDate(context),
                  onSaved: (value) => setState(() => sondeEndDate = value!),
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'End Date';
                    }
                  },
                ),
              ),
            ],
          ),
          SizedBox(height: 5.0,),
          Row(
            children: [
              Expanded(
                child: Text('End Time'),
              ),
              Expanded(
                flex: 2,
                child: TextFormField(
                  controller: _sondeEndTime,
                  readOnly: true, // Prevent manual input
                  decoration: InputDecoration(
                    contentPadding: EdgeInsets.fromLTRB(10.0, 10.0, 20.0, 10.0),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10.0)),
                  ),
                  onTap: _showSondeEndTime,
                  onSaved: (value) => setState(() => sondeEndTime = value!),
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'End time';
                    }
                  },
                ),
              ),
            ],
          ),
          SizedBox(height: 5.0,),
          Row(
            children: [
              Expanded(
                child: Text('Location'),
              ),
              Expanded(
                flex: 2,
                child: TextFormField(
                  decoration: InputDecoration(
                    contentPadding: EdgeInsets.fromLTRB(10.0, 10.0, 20.0, 10.0),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10.0)),
                  ),
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'Location';
                    }
                  },
                  onSaved: (value) => setState(() => sondeLocation = value!),
                ),
              ),
            ],
          ),
          Divider(),
          Row(
            children: [
              Expanded(
                flex: 1,
                child: Text(''),
              ),
              Expanded(
                flex: 3,
                child: Row(
                  children: [
                    SizedBox(
                        width: 80,
                        height: 50,
                        child: Text('MV Reading',style: TextStyle(fontSize: 10),textAlign: TextAlign.center,),),
                    SizedBox(width: 5.0,),
                    SizedBox(
                      width: 80,
                      height: 50,
                      child: Text('Before Calibration',style: TextStyle(fontSize: 10),textAlign: TextAlign.center,),
                    ),
                    SizedBox(width: 5.0,),
                    SizedBox(
                      width: 80,
                      height: 50,
                      child: Text('After Calibration',style: TextStyle(fontSize: 10),textAlign: TextAlign.center,),
                    )
                  ],
                ),
              )
            ],
          ),

          Row(
            children: [
              Expanded(
                flex: 1,
                child: Text('pH 7'),
              ),
              Expanded(
                flex: 3,
                child: Row(
                  children: [
                    SizedBox(
                      width: 80,
                      height: 50,
                      child: TextFormField(
                        keyboardType: TextInputType.numberWithOptions(decimal: true),
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*$')), // Allows digits and one dot
                        ],
                        decoration: InputDecoration(
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10.0)),
                        ),
                        validator: (value) {
                          if (value!.isEmpty) {
                            return 'MV Reading';
                          }
                        },
                        onSaved: (value) => setState(() => ph7_reading = value!),
                      ),
                    ),
                    SizedBox(width: 5.0,),
                    SizedBox(
                      width: 80,
                      height: 50,
                      child: TextFormField(
                        keyboardType: TextInputType.numberWithOptions(decimal: true),
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*$')), // Allows digits and one dot
                        ],
                        decoration: InputDecoration(
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10.0)),
                        ),
                        validator: (value) {
                          if (value!.isEmpty) {
                            return 'Before calibration';
                          }
                        },
                        onSaved: (value) => setState(() => ph7_before = value!),
                      ),
                    ),
                    SizedBox(width: 5.0,),
                    SizedBox(
                      width: 80,
                      height: 50,
                      child: TextFormField(
                        keyboardType: TextInputType.numberWithOptions(decimal: true),
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*$')), // Allows digits and one dot
                        ],
                        decoration: InputDecoration(
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10.0)),
                        ),
                        validator: (value) {
                          if (value!.isEmpty) {
                            return 'After calibration';
                          }
                        },
                        onSaved: (value) => setState(() => ph7_after = value!),
                      ),
                    )
                  ],
                ),
              )
            ],
          ),
          SizedBox(height: 5.0,),
          Row(
            children: [
              Expanded(
                flex: 1,
                child: Text('pH 10'),
              ),
              Expanded(
                flex: 3,
                child: Row(
                  children: [
                    SizedBox(
                      width: 80,
                      height: 50,
                      child: TextFormField(
                        keyboardType: TextInputType.numberWithOptions(decimal: true),
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*$')), // Allows digits and one dot
                        ],
                        decoration: InputDecoration(
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10.0)),
                        ),
                        validator: (value) {
                          if (value!.isEmpty) {
                            return 'Reading';
                          }
                        },
                        onSaved: (value) => setState(() => ph10_reading = value!),
                      ),
                    ),
                    SizedBox(width: 5.0,),
                    SizedBox(
                      width: 80,
                      height: 50,
                      child: TextFormField(
                        keyboardType: TextInputType.numberWithOptions(decimal: true),
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*$')), // Allows digits and one dot
                        ],
                        decoration: InputDecoration(
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10.0)),
                        ),
                        validator: (value) {
                          if (value!.isEmpty) {
                            return 'Before';
                          }
                        },
                        onSaved: (value) => setState(() => ph10_before = value!),
                      ),
                    ),
                    SizedBox(width: 5.0,),
                    SizedBox(
                      width: 80,
                      height: 50,
                      child: TextFormField(
                        keyboardType: TextInputType.numberWithOptions(decimal: true),
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*$')), // Allows digits and one dot
                        ],
                        decoration: InputDecoration(
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10.0)),
                        ),
                        validator: (value) {
                          if (value!.isEmpty) {
                            return 'After';
                          }
                        },
                        onSaved: (value) => setState(() => ph10_after = value!),
                      ),
                    )
                  ],
                ),
              )
            ],
          ),
          SizedBox(height: 5.0,),

          Row(
            children: [
              Expanded(
                flex: 1,
                child: Text('SP Conductivity\n(' + _special_1 + 'S/cm)'),
              ),
              Expanded(
                flex: 3,
                child: Row(
                  children: [
                    SizedBox(
                      width: 80,
                      height: 50,
                      child: Text(''),
                    ),
                    SizedBox(width: 5.0,),
                    SizedBox(
                      width: 80,
                      height: 50,
                      child: TextFormField(
                        keyboardType: TextInputType.numberWithOptions(decimal: true),
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*$')), // Allows digits and one dot
                        ],
                        decoration: InputDecoration(
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10.0)),
                        ),
                        validator: (value) {
                          if (value!.isEmpty) {
                            return 'Before';
                          }
                        },
                        onSaved: (value) => setState(() => sp_before = value!),
                      ),
                    ),
                    SizedBox(width: 5.0,),
                    SizedBox(
                      width: 80,
                      height: 50,
                      child: TextFormField(
                        keyboardType: TextInputType.numberWithOptions(decimal: true),
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*$')), // Allows digits and one dot
                        ],
                        decoration: InputDecoration(
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10.0)),
                        ),
                        validator: (value) {
                          if (value!.isEmpty) {
                            return 'After';
                          }
                        },
                        onSaved: (value) => setState(() => sp_after = value!),
                      ),
                    )
                  ],
                ),
              )
            ],
          ),
          SizedBox(height: 5.0,),
          Row(
            children: [
              Expanded(
                flex: 1,
                child: Text('Turbidity (NTU)'),
              ),
              Expanded(
                flex: 3,
                child: Row(
                  children: [
                    SizedBox(
                      width: 80,
                      height: 50,
                      child: Text(''),
                    ),
                    SizedBox(width: 5.0,),
                    SizedBox(
                      width: 80,
                      height: 50,
                      child: TextFormField(
                        keyboardType: TextInputType.numberWithOptions(decimal: true),
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*$')), // Allows digits and one dot
                        ],
                        decoration: InputDecoration(
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10.0)),
                        ),
                        validator: (value) {
                          if (value!.isEmpty) {
                            return 'Before';
                          }
                        },
                        onSaved: (value) => setState(() => ntu_before = value!),
                      ),
                    ),
                    SizedBox(width: 5.0,),
                    SizedBox(
                      width: 80,
                      height: 50,
                      child: TextFormField(
                        keyboardType: TextInputType.numberWithOptions(decimal: true),
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*$')), // Allows digits and one dot
                        ],
                        decoration: InputDecoration(
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10.0)),
                        ),
                        validator: (value) {
                          if (value!.isEmpty) {
                            return 'After';
                          }
                        },
                        onSaved: (value) => setState(() => ntu_after = value!),
                      ),
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
                flex: 1,
                child: Text('Dissolved Oxygen (%)'),
              ),
              Expanded(
                flex: 3,
                child: Row(
                  children: [
                    SizedBox(
                      width: 80,
                      height: 50,
                      child: Text(''),
                    ),
                    SizedBox(width: 5.0,),
                    SizedBox(
                      width: 80,
                      height: 50,
                      child: TextFormField(
                        keyboardType: TextInputType.numberWithOptions(decimal: true),
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*$')), // Allows digits and one dot
                        ],
                        decoration: InputDecoration(
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10.0)),
                        ),
                        validator: (value) {
                          if (value!.isEmpty) {
                            return 'Before';
                          }
                        },
                        onSaved: (value) => setState(() => dis_before = value!),
                      ),
                    ),
                    SizedBox(width: 5.0,),
                    SizedBox(
                      width: 80,
                      height: 50,
                      child: TextFormField(
                        keyboardType: TextInputType.numberWithOptions(decimal: true),
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*$')), // Allows digits and one dot
                        ],
                        decoration: InputDecoration(
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10.0)),
                        ),
                        validator: (value) {
                          if (value!.isEmpty) {
                            return 'After';
                          }
                        },
                        onSaved: (value) => setState(() => dis_after = value!),
                      ),
                    )
                  ],
                ),
              ),
            ],
          ),
          Divider(),
          Row(
            children: [
              Expanded(
                child: Text('Conducted by:',
                  style: TextStyle(fontWeight: FontWeight.bold),),
              ),
              Expanded(
                flex: 2,
                child: TextFormField(
                  readOnly: true,
                  controller: _conductName,
                  style: TextStyle(fontSize: 13),
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.grey[200],
                    contentPadding: EdgeInsets.fromLTRB(10.0, 10.0, 20.0, 10.0),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10.0)),
                  ),
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'Conducted By';
                    }
                  },
                  onSaved: (value) => setState(() => conductName = value!),
                ),
              ),
            ],
          ),
          SizedBox(height: 5.0,),
          Row(
            children: [
              Expanded(
                child: Text('Signature:',
                  style: TextStyle(fontWeight: FontWeight.bold),),
              ),
              Expanded(
                flex: 2,
                child: TextFormField(
                  decoration: InputDecoration(
                    contentPadding: EdgeInsets.fromLTRB(10.0, 10.0, 20.0, 10.0),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10.0)),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 5.0,),
          Row(
            children: [
              Expanded(
                child: Text('Designation:',
                  style: TextStyle(fontWeight: FontWeight.bold),),
              ),
              Expanded(
                flex: 2,
                child: TextFormField(
                  style: TextStyle(fontSize: 13),
                  readOnly: true,
                  controller: _designation,
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.grey[200],
                    contentPadding: EdgeInsets.fromLTRB(10.0, 10.0, 20.0, 10.0),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10.0)),
                  ),
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'Designation';
                    }
                  },
                  onSaved: (value) => setState(() => designationName = value!),
                ),
              ),
            ],
          ),
          SizedBox(height: 5.0,),
          Row(
            children: [
              Expanded(
                child: Text('Date:',
                  style: TextStyle(fontWeight: FontWeight.bold),),
              ),
              Expanded(
                flex: 2,
                child: TextFormField(
                  controller: _sondeConductedDate,
                  readOnly: true, // Prevent manual input
                  decoration: InputDecoration(
                    contentPadding: EdgeInsets.fromLTRB(10.0, 10.0, 20.0, 10.0),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10.0)),
                  ),
                  onTap: () => _selectSondeConductedDate(context),
                  onSaved: (value) => setState(() => sondeConductedDate = value!),
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'Date';
                    }
                  },
                ),
              ),
            ],
          ),
          SizedBox(height: 5.0,),
          Row(
            children: [
              Expanded(
                child: Text('Observation:',
                  style: TextStyle(fontWeight: FontWeight.bold),),
              ),
              Expanded(
                flex: 2,
                child: TextFormField(
                  decoration: InputDecoration(
                    contentPadding: EdgeInsets.fromLTRB(10.0, 10.0, 20.0, 10.0),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10.0)),
                  ),
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'Observation';
                    }
                  },
                  onSaved: (value) => setState(() => sondeObservation = value!),
                ),
              ),
            ],
          ),

          Divider(),
          Row(
            children: [
              Expanded(
                child: Text('Verified by:',
                  style: TextStyle(fontWeight: FontWeight.bold,color: Colors.green),),
              ),
              Expanded(
                flex: 2,
                child: TextFormField(
                  decoration: InputDecoration(
                    contentPadding: EdgeInsets.fromLTRB(10.0, 10.0, 20.0, 10.0),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10.0)),
                  ),
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'Verified name';
                    }
                  },
                  onSaved: (value) => setState(() => sondeVerifiedName = value!),
                ),
              ),
            ],
          ),
          SizedBox(height: 5.0,),
          Row(
            children: [
              Expanded(
                child: Text('Signature:',
                  style: TextStyle(fontWeight: FontWeight.bold,color: Colors.green),),
              ),
              Expanded(
                flex: 2,
                child: TextFormField(
                  decoration: InputDecoration(
                    contentPadding: EdgeInsets.fromLTRB(10.0, 10.0, 20.0, 10.0),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10.0)),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 5.0,),
          Row(
            children: [
              Expanded(
                child: Text('Designation:',
                  style: TextStyle(fontWeight: FontWeight.bold,color: Colors.green),),
              ),
              Expanded(
                flex: 2,
                child: TextFormField(
                  decoration: InputDecoration(
                    contentPadding: EdgeInsets.fromLTRB(10.0, 10.0, 20.0, 10.0),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10.0)),
                  ),
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'Designation name';
                    }
                  },
                  onSaved: (value) => setState(() => sondeVerifiedDesignation = value!),
                ),
              ),
            ],
          ),
          SizedBox(height: 5.0,),
          Row(
            children: [
              Expanded(
                child: Text('Date:',
                  style: TextStyle(fontWeight: FontWeight.bold,color: Colors.green),),
              ),
              Expanded(
                flex: 2,
                child: TextFormField(
                  controller: _sondeVerifiedDate,
                  readOnly: true, // Prevent manual input
                  decoration: InputDecoration(
                    contentPadding: EdgeInsets.fromLTRB(10.0, 10.0, 20.0, 10.0),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10.0)),
                  ),
                  onTap: () => _selectSondeVerifiedDate(context),
                  onSaved: (value) => setState(() => sondeVerifiedDate = value!),
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
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey
                  ),
                  onPressed: () {

                  },
                  child: Text('Cancel'),
                ),
              ),
              SizedBox(width: 10.0,),
              Expanded(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue
                  ),
                  onPressed: () {
                    if (_formPreSample2.currentState!.validate()) {
                      _formPreSample2.currentState!.save();
                      _submitForm2();
                    }
                  },
                  child: Text('Submit'),
                ),
              )
            ],
          ),
        ],
      ),
    );
  }

  final _formPreSample3 = GlobalKey<FormState>();
  late int bullet17=1,bullet18=1,bullet19=1,bullet20=1,bullet21=1;
  late int bullet22=1,bullet23=1,bullet24=1,bullet25=1,bullet26=1;
  late int bullet27=1,bullet28=1,bullet29=1,bullet30=1,bullet31=1;
  late int bullet32=1,bullet33=1,bullet34=1,bullet35=1,bullet36=1;
  late int bullet37=1,bullet38=1,bullet39=1,bullet40=1,bullet41=1;

  late String? remarks17,remarks18,remarks19,remarks20,remarks21;
  late String? remarks22,remarks23,remarks24,remarks25,remarks26;
  late String? remarks27,remarks28,remarks29,remarks30,remarks31;
  late String? remarks32,remarks33,remarks34,remarks35,remarks36;
  late String? remarks37,remarks38,remarks39,remarks40,remarks41;

  late int bullet42=1,bullet43=1,bullet44=1,bullet45=1;

  late String? remarks42,remarks43,remarks44,remarks45;

  late int bullet46=1,bullet47=1,bullet48=1,bullet49=1;

  late String? remarks46,remarks47,remarks48,remarks49;
  late String? verifiedName1, designationName1;

  final TextEditingController _inspectedDate = TextEditingController();
  final TextEditingController _verifiedDate1 = TextEditingController();
  late String? inspectedDate, verifiedDate1;

  Future<void> _selectInspectedDate(BuildContext context) async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(), // Default date
      firstDate: DateTime(2000),  // Earliest date
      lastDate: DateTime(2100),  // Latest date
    );

    if (pickedDate != null) {
      setState(() {
        _inspectedDate.text = "${pickedDate.toLocal()}".split(' ')[0];
      });
    }
  }

  Future<void> _selectVerifiedDate1(BuildContext context) async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(), // Default date
      firstDate: DateTime(2000),  // Earliest date
      lastDate: DateTime(2100),  // Latest date
    );

    if (pickedDate != null) {
      setState(() {
        _verifiedDate1.text = "${pickedDate.toLocal()}".split(' ')[0];
      });
    }
  }

  Widget _buildForm3() {
    return Form(
      key: _formPreSample3,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Pre-Departure Checklist & Safety Checklist Form (F-MM03)',style: TextStyle(fontSize: 20,fontWeight: FontWeight.bold),),
          SizedBox(height: 15.0,),
          Text('INTERNAL - IN-SITU SAMPLING',style: TextStyle(fontWeight: FontWeight.bold),),
          SizedBox(height: 15.0,),
          Row(
            children: [
              Expanded(
                flex: 1,
                child: Text('Marine manual Standard Operation Procedure (SOP)'),
              ),
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    ToggleSwitch(
                      initialLabelIndex: 1,
                      totalSwitches: 2,
                      labels: [
                        'Yes',
                        'No',
                      ],
                      onToggle: (index) {
                        bullet17 = index!;
                        print(bullet17);
                        print('switched to: $index');
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
          TextFormField(
            decoration: InputDecoration(
                hintStyle: TextStyle(fontSize: 10),
              hintText: 'Remarks'
            ),
              validator: (value) {
                if (value!.isEmpty) {
                  return 'Remarks';
                }
              },
              onSaved: (value) => setState(() => remarks17 = value!)
          ),

          SizedBox(height: 15.0,),
          Row(
            children: [
              Expanded(
                flex: 1,
                child: Text('Back-up Sampling Sheet and Chain of Custody form'),
              ),
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    ToggleSwitch(
                      initialLabelIndex: 1,
                      totalSwitches: 2,
                      labels: [
                        'Yes',
                        'No',
                      ],
                      onToggle: (index) {
                        bullet18 = index!;
                        print('switched to: $index');
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
          TextFormField(
            decoration: InputDecoration(
                hintStyle: TextStyle(fontSize: 10),
                hintText: 'Remarks'
            ),
              validator: (value) {
                if (value!.isEmpty) {
                  return 'Remarks';
                }
              },
              onSaved: (value) => setState(() => remarks18 = value!)
          ),

          SizedBox(height: 15.0,),
          Row(
            children: [
              Expanded(
                flex: 1,
                child: Text('Calibration worksheet'),
              ),
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    ToggleSwitch(
                      initialLabelIndex: 1,
                      totalSwitches: 2,
                      labels: [
                        'Yes',
                        'No',
                      ],
                      onToggle: (index) {
                        bullet19 = index!;
                        print('switched to: $index');
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
          TextFormField(
            decoration: InputDecoration(
                hintStyle: TextStyle(fontSize: 10),
                hintText: 'Remarks'
            ),
              validator: (value) {
                if (value!.isEmpty) {
                  return 'Remarks';
                }
              },
              onSaved: (value) => setState(() => remarks19 = value!)
          ),

          SizedBox(height: 15.0,),
          Row(
            children: [
              Expanded(
                flex: 1,
                child: Text('YSI EXO2 Sonde Include Sensor (pH/Turbidity/Conductivity/Dissolved Oxygen)'),
              ),
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    ToggleSwitch(
                      initialLabelIndex: 1,
                      totalSwitches: 2,
                      labels: [
                        'Yes',
                        'No',
                      ],
                      onToggle: (index) {
                        bullet20 = index!;
                        print('switched to: $index');
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
          TextFormField(
            decoration: InputDecoration(
                hintStyle: TextStyle(fontSize: 10),
                hintText: 'Remarks'
            ),
              validator: (value) {
                if (value!.isEmpty) {
                  return 'Remarks';
                }
              },
              onSaved: (value) => setState(() => remarks20 = value!)
          ),

          SizedBox(height: 15.0,),
          Row(
            children: [
              Expanded(
                flex: 1,
                child: Text('Spare set sensor (pH/Turbidity/Conductivity/Dissolved Oxygen)'),
              ),
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    ToggleSwitch(
                      initialLabelIndex: 1,
                      totalSwitches: 2,
                      labels: [
                        'Yes',
                        'No',
                      ],
                      onToggle: (index) {
                        bullet21 = index!;
                        print('switched to: $index');
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
          TextFormField(
            decoration: InputDecoration(
                hintStyle: TextStyle(fontSize: 10),
                hintText: 'Remarks'
            ),
              validator: (value) {
                if (value!.isEmpty) {
                  return 'Remarks';
                }
              },
              onSaved: (value) => setState(() => remarks21 = value!)
          ),

          SizedBox(height: 15.0,),
          Row(
            children: [
              Expanded(
                flex: 1,
                child: Text('YSI serial cable'),
              ),
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    ToggleSwitch(
                      initialLabelIndex: 1,
                      totalSwitches: 2,
                      labels: [
                        'Yes',
                        'No',
                      ],
                      onToggle: (index) {
                        bullet22 = index!;
                        print('switched to: $index');
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
          TextFormField(
            decoration: InputDecoration(
                hintStyle: TextStyle(fontSize: 10),
                hintText: 'Remarks'
            ),
              validator: (value) {
                if (value!.isEmpty) {
                  return 'Remarks';
                }
              },
              onSaved: (value) => setState(() => remarks22 = value!)
          ),

          SizedBox(height: 15.0,),
          Row(
            children: [
              Expanded(
                flex: 1,
                child: Text('Van Dorn Sampler (with rope & messenger)'),
              ),
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    ToggleSwitch(
                      initialLabelIndex: 1,
                      totalSwitches: 2,
                      labels: [
                        'Yes',
                        'No',
                      ],
                      onToggle: (index) {
                        bullet23 = index!;
                        print('switched to: $index');
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
          TextFormField(
            decoration: InputDecoration(
                hintStyle: TextStyle(fontSize: 10),
                hintText: 'Remarks'
            ),
              validator: (value) {
                if (value!.isEmpty) {
                  return 'Remarks';
                }
              },
              onSaved: (value) => setState(() => remarks23 = value!)
          ),

          SizedBox(height: 15.0,),
          Row(
            children: [
              Expanded(
                flex: 1,
                child: Text('Laptop'),
              ),
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    ToggleSwitch(
                      initialLabelIndex: 1,
                      totalSwitches: 2,
                      labels: [
                        'Yes',
                        'No',
                      ],
                      onToggle: (index) {
                        bullet24 = index!;
                        print('switched to: $index');
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
          TextFormField(
            decoration: InputDecoration(
                hintStyle: TextStyle(fontSize: 10),
                hintText: 'Remarks'
            ),
              validator: (value) {
                if (value!.isEmpty) {
                  return 'Remarks';
                }
              },
              onSaved: (value) => setState(() => remarks24 = value!)
          ),

          SizedBox(height: 15.0,),
          Row(
            children: [
              Expanded(
                flex: 1,
                child: Text('Smartphone pre-installed with application (apps for manual sampling - MMS)'),
              ),
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    ToggleSwitch(
                      initialLabelIndex: 1,
                      totalSwitches: 2,
                      labels: [
                        'Yes',
                        'No',
                      ],
                      onToggle: (index) {
                        bullet25 = index!;
                        print('switched to: $index');
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
          TextFormField(
            decoration: InputDecoration(
                hintStyle: TextStyle(fontSize: 10),
                hintText: 'Remarks'
            ),
              validator: (value) {
                if (value!.isEmpty) {
                  return 'Remarks';
                }
              },
              onSaved: (value) => setState(() => remarks25 = value!)
          ),

          SizedBox(height: 15.0,),
          Row(
            children: [
              Expanded(
                flex: 1,
                child: Text('GPS Navigation'),
              ),
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    ToggleSwitch(
                      initialLabelIndex: 1,
                      totalSwitches: 2,
                      labels: [
                        'Yes',
                        'No',
                      ],
                      onToggle: (index) {
                        bullet26 = index!;
                        print('switched to: $index');
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
          TextFormField(
            decoration: InputDecoration(
                hintStyle: TextStyle(fontSize: 10),
                hintText: 'Remarks'
            ),
              validator: (value) {
                if (value!.isEmpty) {
                  return 'Remarks';
                }
              },
              onSaved: (value) => setState(() => remarks26 = value!)
          ),

          SizedBox(height: 15.0,),
          Row(
            children: [
              Expanded(
                flex: 1,
                child: Text('Calibration standards (pH/Turbidity/Conductivity)'),
              ),
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    ToggleSwitch(
                      initialLabelIndex: 1,
                      totalSwitches: 2,
                      labels: [
                        'Yes',
                        'No',
                      ],
                      onToggle: (index) {
                        bullet27 = index!;
                        print('switched to: $index');
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
          TextFormField(
            decoration: InputDecoration(
                hintStyle: TextStyle(fontSize: 10),
                hintText: 'Remarks'
            ),
              validator: (value) {
                if (value!.isEmpty) {
                  return 'Remarks';
                }
              },
              onSaved: (value) => setState(() => remarks27 = value!)
          ),

          SizedBox(height: 15.0,),
          Row(
            children: [
              Expanded(
                flex: 1,
                child: Text('Distilled water (D.I)'),
              ),
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    ToggleSwitch(
                      initialLabelIndex: 1,
                      totalSwitches: 2,
                      labels: [
                        'Yes',
                        'No',
                      ],
                      onToggle: (index) {
                        bullet28 = index!;
                        print('switched to: $index');
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
          TextFormField(
            decoration: InputDecoration(
                hintStyle: TextStyle(fontSize: 10),
                hintText: 'Remarks'
            ),
              validator: (value) {
                if (value!.isEmpty) {
                  return 'Remarks';
                }
              },
              onSaved: (value) => setState(() => remarks28 = value!)
          ),

          SizedBox(height: 15.0,),
          Row(
            children: [
              Expanded(
                flex: 1,
                child: Text('Universal pH Indicator paper'),
              ),
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    ToggleSwitch(
                      initialLabelIndex: 1,
                      totalSwitches: 2,
                      labels: [
                        'Yes',
                        'No',
                      ],
                      onToggle: (index) {
                        bullet29 = index!;
                        print('switched to: $index');
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
          TextFormField(
            decoration: InputDecoration(
                hintStyle: TextStyle(fontSize: 10),
                hintText: 'Remarks'
            ),
              validator: (value) {
                if (value!.isEmpty) {
                  return 'Remarks';
                }
              },
              onSaved: (value) => setState(() => remarks29 = value!)
          ),

          SizedBox(height: 15.0,),
          Row(
            children: [
              Expanded(
                flex: 1,
                child: Text('Personal Floating Devices (PFD)'),
              ),
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    ToggleSwitch(
                      initialLabelIndex: 1,
                      totalSwitches: 2,
                      labels: [
                        'Yes',
                        'No',
                      ],
                      onToggle: (index) {
                        bullet30 = index!;
                        print('switched to: $index');
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
          TextFormField(
            decoration: InputDecoration(
                hintStyle: TextStyle(fontSize: 10),
                hintText: 'Remarks'
            ),
              validator: (value) {
                if (value!.isEmpty) {
                  return 'Remarks';
                }
              },
              onSaved: (value) => setState(() => remarks30 = value!)
          ),

          SizedBox(height: 15.0,),
          Row(
            children: [
              Expanded(
                flex: 1,
                child: Text('First aid kits'),
              ),
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    ToggleSwitch(
                      initialLabelIndex: 1,
                      totalSwitches: 2,
                      labels: [
                        'Yes',
                        'No',
                      ],
                      onToggle: (index) {
                        bullet31 = index!;
                        print('switched to: $index');
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
          TextFormField(
            decoration: InputDecoration(
                hintStyle: TextStyle(fontSize: 10),
                hintText: 'Remarks'
            ),
              validator: (value) {
                if (value!.isEmpty) {
                  return 'Remarks';
                }
              },
              onSaved: (value) => setState(() => remarks31 = value!)
          ),

          SizedBox(height: 15.0,),
          Row(
            children: [
              Expanded(
                flex: 1,
                child: Text('Disposable gloves'),
              ),
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    ToggleSwitch(
                      initialLabelIndex: 1,
                      totalSwitches: 2,
                      labels: [
                        'Yes',
                        'No',
                      ],
                      onToggle: (index) {
                        bullet32 = index!;
                        print('switched to: $index');
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
          TextFormField(
            decoration: InputDecoration(
                hintStyle: TextStyle(fontSize: 10),
                hintText: 'Remarks'
            ),
              validator: (value) {
                if (value!.isEmpty) {
                  return 'Remarks';
                }
              },
              onSaved: (value) => setState(() => remarks32 = value!)
          ),

          SizedBox(height: 15.0,),
          Row(
            children: [
              Expanded(
                flex: 1,
                child: Text('Black plastic bags'),
              ),
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    ToggleSwitch(
                      initialLabelIndex: 1,
                      totalSwitches: 2,
                      labels: [
                        'Yes',
                        'No',
                      ],
                      onToggle: (index) {
                        bullet33 = index!;
                        print('switched to: $index');
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
          TextFormField(
            decoration: InputDecoration(
                hintStyle: TextStyle(fontSize: 10),
                hintText: 'Remarks'
            ),
              validator: (value) {
                if (value!.isEmpty) {
                  return 'Remarks';
                }
              },
              onSaved: (value) => setState(() => remarks33 = value!)
          ),

          SizedBox(height: 15.0,),
          Row(
            children: [
              Expanded(
                flex: 1,
                child: Text('Marker pen, pen, clear tapes, brown tapes & scissors'),
              ),
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    ToggleSwitch(
                      initialLabelIndex: 1,
                      totalSwitches: 2,
                      labels: [
                        'Yes',
                        'No',
                      ],
                      onToggle: (index) {
                        bullet34 = index!;
                        print('switched to: $index');
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
          TextFormField(
            decoration: InputDecoration(
                hintStyle: TextStyle(fontSize: 10),
                hintText: 'Remarks'
            ),
              validator: (value) {
                if (value!.isEmpty) {
                  return 'Remarks';
                }
              },
              onSaved: (value) => setState(() => remarks34 = value!)
          ),

          SizedBox(height: 15.0,),
          Row(
            children: [
              Expanded(
                flex: 1,
                child: Text('Energizer battery'),
              ),
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    ToggleSwitch(
                      initialLabelIndex: 1,
                      totalSwitches: 2,
                      labels: [
                        'Yes',
                        'No',
                      ],
                      onToggle: (index) {
                        bullet35 = index!;
                        print('switched to: $index');
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
          TextFormField(
            decoration: InputDecoration(
                hintStyle: TextStyle(fontSize: 10),
                hintText: 'Remarks'
            ),
              validator: (value) {
                if (value!.isEmpty) {
                  return 'Remarks';
                }
              },
              onSaved: (value) => setState(() => remarks35 = value!)
          ),

          SizedBox(height: 15.0,),
          Row(
            children: [
              Expanded(
                flex: 1,
                child: Text('EXO battery opener and EXO magnet'),
              ),
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    ToggleSwitch(
                      initialLabelIndex: 1,
                      totalSwitches: 2,
                      labels: [
                        'Yes',
                        'No',
                      ],
                      onToggle: (index) {
                        bullet36 = index!;
                        print('switched to: $index');
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
          TextFormField(
            decoration: InputDecoration(
                hintStyle: TextStyle(fontSize: 10),
                hintText: 'Remarks'
            ),
              validator: (value) {
                if (value!.isEmpty) {
                  return 'Remarks';
                }
              },
              onSaved: (value) => setState(() => remarks36 = value!)
          ),

          SizedBox(height: 15.0,),
          Row(
            children: [
              Expanded(
                flex: 1,
                child: Text('Laminated white paper'),
              ),
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    ToggleSwitch(
                      initialLabelIndex: 1,
                      totalSwitches: 2,
                      labels: [
                        'Yes',
                        'No',
                      ],
                      onToggle: (index) {
                        bullet37 = index!;
                        print('switched to: $index');
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
          TextFormField(
            decoration: InputDecoration(
                hintStyle: TextStyle(fontSize: 10),
                hintText: 'Remarks'
            ),
              validator: (value) {
                if (value!.isEmpty) {
                  return 'Remarks';
                }
              },
              onSaved: (value) => setState(() => remarks37 = value!)
          ),

          SizedBox(height: 15.0,),
          Row(
            children: [
              Expanded(
                flex: 1,
                child: Text('Clear glass bottle (blue cap)'),
              ),
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    ToggleSwitch(
                      initialLabelIndex: 1,
                      totalSwitches: 2,
                      labels: [
                        'Yes',
                        'No',
                      ],
                      onToggle: (index) {
                        bullet38 = index!;
                        print('switched to: $index');
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
          TextFormField(
            decoration: InputDecoration(
                hintStyle: TextStyle(fontSize: 10),
                hintText: 'Remarks'
            ),
              validator: (value) {
                if (value!.isEmpty) {
                  return 'Remarks';
                }
              },
              onSaved: (value) => setState(() => remarks38 = value!)
          ),

          SizedBox(height: 15.0,),
          Row(
            children: [
              Expanded(
                flex: 1,
                child: Text('Proper sampling attires & shoes'),
              ),
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    ToggleSwitch(
                      initialLabelIndex: 1,
                      totalSwitches: 2,
                      labels: [
                        'Yes',
                        'No',
                      ],
                      onToggle: (index) {
                        bullet39 = index!;
                        print('switched to: $index');
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
          TextFormField(
            decoration: InputDecoration(
                hintStyle: TextStyle(fontSize: 10),
                hintText: 'Remarks'
            ),
              validator: (value) {
                if (value!.isEmpty) {
                  return 'Remarks';
                }
              },
              onSaved: (value) => setState(() => remarks39 = value!)
          ),

          SizedBox(height: 15.0,),
          Row(
            children: [
              Expanded(
                flex: 1,
                child: Text('Raincoat / Poncho'),
              ),
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    ToggleSwitch(
                      initialLabelIndex: 1,
                      totalSwitches: 2,
                      labels: [
                        'Yes',
                        'No',
                      ],
                      onToggle: (index) {
                        bullet40 = index!;
                        print('switched to: $index');
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
          TextFormField(
            decoration: InputDecoration(
                hintStyle: TextStyle(fontSize: 10),
                hintText: 'Remarks'
            ),
              validator: (value) {
                if (value!.isEmpty) {
                  return 'Remarks';
                }
              },
              onSaved: (value) => setState(() => remarks40 = value!)
          ),

          SizedBox(height: 15.0,),
          Row(
            children: [
              Expanded(
                flex: 1,
                child: Text('Ice packets'),
              ),
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    ToggleSwitch(
                      initialLabelIndex: 1,
                      totalSwitches: 2,
                      labels: [
                        'Yes',
                        'No',
                      ],
                      onToggle: (index) {
                        bullet41 = index!;
                        print('switched to: $index');
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
          TextFormField(
            decoration: InputDecoration(
                hintStyle: TextStyle(fontSize: 10),
                hintText: 'Remarks'
            ),
              validator: (value) {
                if (value!.isEmpty) {
                  return 'Remarks';
                }
              },
              onSaved: (value) => setState(() => remarks41 = value!)
          ),

          SizedBox(height: 15.0,),
          Text('INTERNAL - TARBALL SAMPLING',style: TextStyle(fontWeight: FontWeight.bold),),
          SizedBox(height: 15.0,),
          Row(
            children: [
              Expanded(
                flex: 1,
                child: Text('Measuring tape (100 meter)'),
              ),
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    ToggleSwitch(
                      initialLabelIndex: 1,
                      totalSwitches: 2,
                      labels: [
                        'Yes',
                        'No',
                      ],
                      onToggle: (index) {
                        bullet42 = index!;
                        print('switched to: $index');
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
          TextFormField(
            decoration: InputDecoration(
                hintStyle: TextStyle(fontSize: 10),
                hintText: 'Remarks'
            ),
              validator: (value) {
                if (value!.isEmpty) {
                  return 'Remarks';
                }
              },
              onSaved: (value) => setState(() => remarks42 = value!)
          ),

          SizedBox(height: 15.0,),
          Row(
            children: [
              Expanded(
                flex: 1,
                child: Text('Steel raking'),
              ),
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    ToggleSwitch(
                      initialLabelIndex: 1,
                      totalSwitches: 2,
                      labels: [
                        'Yes',
                        'No',
                      ],
                      onToggle: (index) {
                        bullet43 = index!;
                        print('switched to: $index');
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
          TextFormField(
            decoration: InputDecoration(
                hintStyle: TextStyle(fontSize: 10),
                hintText: 'Remarks'
            ),
              validator: (value) {
                if (value!.isEmpty) {
                  return 'Remarks';
                }
              },
              onSaved: (value) => setState(() => remarks43 = value!)
          ),

          SizedBox(height: 15.0,),
          Row(
            children: [
              Expanded(
                flex: 1,
                child: Text('Aluminum foil'),
              ),
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    ToggleSwitch(
                      initialLabelIndex: 1,
                      totalSwitches: 2,
                      labels: [
                        'Yes',
                        'No',
                      ],
                      onToggle: (index) {
                        bullet44 = index!;
                        print('switched to: $index');
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
          TextFormField(
            decoration: InputDecoration(
                hintStyle: TextStyle(fontSize: 10),
                hintText: 'Remarks'
            ),
              validator: (value) {
                if (value!.isEmpty) {
                  return 'Remarks';
                }
              },
              onSaved: (value) => setState(() => remarks44 = value!)
          ),

          SizedBox(height: 15.0,),
          Row(
            children: [
              Expanded(
                flex: 1,
                child: Text('Zipper bags'),
              ),
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    ToggleSwitch(
                      initialLabelIndex: 1,
                      totalSwitches: 2,
                      labels: [
                        'Yes',
                        'No',
                      ],
                      onToggle: (index) {
                        bullet45 = index!;
                        print('switched to: $index');
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
          TextFormField(
            decoration: InputDecoration(
                hintStyle: TextStyle(fontSize: 10),
                hintText: 'Remarks'
            ),
              validator: (value) {
                if (value!.isEmpty) {
                  return 'Remarks';
                }
              },
              onSaved: (value) => setState(() => remarks45 = value!)
          ),

          SizedBox(height: 15.0,),
          Text('EXTERNAL - LABORATORY',style: TextStyle(fontWeight: FontWeight.bold),),
          SizedBox(height: 15.0,),
          Row(
            children: [
              Expanded(
                flex: 1,
                child: Text('Sufficient sets of cooler box and sampling bottles with label'),
              ),
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    ToggleSwitch(
                      initialLabelIndex: 1,
                      totalSwitches: 2,
                      labels: [
                        'Yes',
                        'No',
                      ],
                      onToggle: (index) {
                        bullet46 = index!;
                        print('switched to: $index');
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
          TextFormField(
            decoration: InputDecoration(
                hintStyle: TextStyle(fontSize: 10),
                hintText: 'Remarks'
            ),
              validator: (value) {
                if (value!.isEmpty) {
                  return 'Remarks';
                }
              },
              onSaved: (value) => setState(() => remarks46 = value!)
          ),

          SizedBox(height: 15.0,),
          Row(
            children: [
              Expanded(
                flex: 1,
                child: Text('Field duplicate sampling bottles (if any)'),
              ),
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    ToggleSwitch(
                      initialLabelIndex: 1,
                      totalSwitches: 2,
                      labels: [
                        'Yes',
                        'No',
                      ],
                      onToggle: (index) {
                        bullet47 = index!;
                        print('switched to: $index');
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
          TextFormField(
            decoration: InputDecoration(
                hintStyle: TextStyle(fontSize: 10),
                hintText: 'Remarks'
            ),
              validator: (value) {
                if (value!.isEmpty) {
                  return 'Remarks';
                }
              },
              onSaved: (value) => setState(() => remarks47 = value!)
          ),

          SizedBox(height: 15.0,),
          Row(
            children: [
              Expanded(
                flex: 1,
                child: Text('Blank samples sampling bottles (if any)'),
              ),
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    ToggleSwitch(
                      initialLabelIndex: 1,
                      totalSwitches: 2,
                      labels: [
                        'Yes',
                        'No',
                      ],
                      onToggle: (index) {
                        bullet48 = index!;
                        print('switched to: $index');
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
          TextFormField(
            decoration: InputDecoration(
                hintStyle: TextStyle(fontSize: 10),
                hintText: 'Remarks'
            ),
              validator: (value) {
                if (value!.isEmpty) {
                  return 'Remarks';
                }
              },
              onSaved: (value) => setState(() => remarks48 = value!)
          ),

          SizedBox(height: 15.0,),
          Row(
            children: [
              Expanded(
                flex: 1,
                child: Text('Preservatives (acid & alkaline)'),
              ),
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    ToggleSwitch(
                      initialLabelIndex: 1,
                      totalSwitches: 2,
                      labels: [
                        'Yes',
                        'No',
                      ],
                      onToggle: (index) {
                        bullet49 = index!;
                        print('switched to: $index');
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
          TextFormField(
            decoration: InputDecoration(
                hintStyle: TextStyle(fontSize: 10),
                hintText: 'Remarks'
            ),
              validator: (value) {
                if (value!.isEmpty) {
                  return 'Remarks';
                }
              },
              onSaved: (value) => setState(() => remarks49 = value!)
          ),

          Divider(),
          Text('Inspected By:',style: TextStyle(fontSize: 15,fontWeight: FontWeight.bold,color: Colors.green),),
          TextFormField(
            readOnly: true,
            controller: _conductName,
            style: TextStyle(fontSize: 12),
            decoration: InputDecoration(
                filled: true,
                fillColor: Colors.grey[200],
                hintStyle: TextStyle(fontSize: 12),
                hintText: 'Name'
            ),
            validator: (value) {
              if (value!.isEmpty) {
                return 'Inspected By';
              }
            },
            onSaved: (value) => setState(() => conductName = value!),
          ),
          TextFormField(
            decoration: InputDecoration(
                hintStyle: TextStyle(fontSize: 10),
                hintText: 'Signature'
            ),
          ),
          TextFormField(
            readOnly: true,
            controller: _designation,
            style: TextStyle(fontSize: 12),
            decoration: InputDecoration(
                filled: true,
                fillColor: Colors.grey[200],
                hintStyle: TextStyle(fontSize: 12),
                hintText: 'Designation'
            ),
            validator: (value) {
              if (value!.isEmpty) {
                return 'Designation';
              }
            },
            onSaved: (value) => setState(() => designationName = value!),
          ),
          TextFormField(
            controller: _inspectedDate,
            readOnly: true,
            decoration: InputDecoration(
                hintStyle: TextStyle(fontSize: 10),
                hintText: 'Date'
            ),
            onTap: () => _selectInspectedDate(context),
            onSaved: (value) => setState(() => inspectedDate = value!),
            validator: (value) {
              if (value!.isEmpty) {
                return 'Date';
              }
            },
          ),
          SizedBox(height: 15,),

          Divider(),
          Text('Verified By:',style: TextStyle(fontSize: 15,fontWeight: FontWeight.bold,color: Colors.red),),
          TextFormField(
            decoration: InputDecoration(
                hintStyle: TextStyle(fontSize: 10),
                hintText: 'Name'
            ),
            validator: (value) {
              if (value!.isEmpty) {
                return 'Verified name';
              }
            },
            onSaved: (value) => setState(() => verifiedName1 = value!),
          ),
          TextFormField(
            decoration: InputDecoration(
                hintStyle: TextStyle(fontSize: 10),
                hintText: 'Signature'
            ),
          ),
          TextFormField(
            decoration: InputDecoration(
                hintStyle: TextStyle(fontSize: 10),
                hintText: 'Designation'
            ),
            validator: (value) {
              if (value!.isEmpty) {
                return 'Designation';
              }
            },
            onSaved: (value) => setState(() => designationName1 = value!),
          ),
          TextFormField(
            controller: _verifiedDate1,
            readOnly: true,
            decoration: InputDecoration(
                hintStyle: TextStyle(fontSize: 10),
                hintText: 'Date'
            ),
            onTap: () => _selectVerifiedDate1(context),
            onSaved: (value) => setState(() => verifiedDate1 = value!),
            validator: (value) {
              if (value!.isEmpty) {
                return 'Date';
              }
            },
          ),
          SizedBox(height: 15,),
          Divider(),
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: () {

                  },
                  child: Text('Cancel'),
                ),
              ),
              SizedBox(width: 10.0,),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    if (_formPreSample3.currentState!.validate()) {
                      _formPreSample3.currentState!.save();
                      _submitForm3();
                    }
                   },
                  child: Text('Submit'),
                ),
              )
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: _isSamplingForm ? Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          _isLoading ? Container(
            alignment: Alignment.center,
            width: MediaQuery.of(context).size.width,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                CircularProgressIndicator(),
                Text('Data transferred in progress....wait'),
              ],
            ),
          ):
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Text('PRE-SAMPLING FORM',
                  style: TextStyle(fontSize: 20,fontWeight: FontWeight.bold),),
              ),
              SizedBox(height: 10.0,),
              Center(
                child: Text('Form'),
              ),
              SizedBox(height: 5.0,),
              DropdownButtonFormField(
                decoration: InputDecoration(
                  contentPadding: EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10.0),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(15.0)),
                ),
                //value: _formType.isNotEmpty ? _formType : null,
                items: items.map((item) {
                  return DropdownMenuItem<int>(
                    value: item['index'], // Use the index as the value
                    child: Text(item['value'],style: TextStyle(fontSize: 11),), // Display the value as text
                  );
                }).toList(),
                value: selectedIndex,
                onChanged: (int? newIndex) {
                  setState(() {
                    selectedIndex = newIndex;
                    //_formType = newIndex.toString();
                  });
                },

              ),
              SizedBox(height: 20.0,),
              Row(
                children: [
                  Expanded(
                    flex: 3,
                    child: Text('List...',
                      style: TextStyle(fontSize: 18,fontWeight: FontWeight.bold),),
                  ),
                  Expanded(
                    child: Align(
                      alignment: Alignment.center,
                      child: IconButton(
                        onPressed: () {
                          setState(() {
                            if (selectedIndex==0) {
                              _isForm1 = true;
                              _isForm2 = false;
                              _isForm3 = false;
                            }
                            else if (selectedIndex==1) {
                              _isForm1 = false;
                              _isForm2 = true;
                              _isForm3 = false;
                            }
                            else if (selectedIndex==2) {
                              _isForm1 = false;
                              _isForm2 = false;
                              _isForm3 = true;
                            }

                            _isSamplingForm = false;
                          });
                        },
                        icon: Icon(
                          Icons.add,color: Colors.red,
                        ),
                      ),
                    ),
                  )
                ],
              ),
              /*
              Container(
                height: MediaQuery.of(context).size.height,
                child: _isLoadingData ? Center(child: CircularProgressIndicator())
                : _itemData.isEmpty
                    ? Center(child: Text('No data found'))
                    : ListView.builder(
                  itemCount: _itemData.length,
                  itemBuilder: (context, index) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(_itemData[index]['id'].toString()),
                      ],
                    );
                  },
                ),
              ),*/
            ],
          )
        ],
      ) : SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (_isForm1 == true) ... [
              _buildForm1(),
            ]
            else if (_isForm2 == true)  ... [
              _buildForm2(),
            ]
            else if (_isForm3 == true)  ... [
                _buildForm3(),
            ]
          ],
        ),
      ),
    );
  }

  void _submitForm1() async {

    setState(() {
      _isSamplingForm = true;
      _isLoading = true;
    });

    var client = http.Client();
    var response = await
    client.post(Uri.parse("https://my-developments.com/mms/api/marine/api-post-marine.php"), body: {
      "action": "marine-sampling-mm01","userID":_userID!,
      "startDate": startDate.toString(),"endDate": endDate.toString(),
      "startTime": sampleTime1.toString(),"endTime":sampleTime2.toString(),
      "location": locationName!,
      "ans1": bullet1.toString(),"ans2": bullet2.toString(),"ans3": bullet3.toString(),"ans4": bullet4.toString(),
      "observation1": observationName1!,
      "ans5": bullet5.toString(),"ans6": bullet6.toString(),"ans7": bullet7.toString(),"ans8": bullet8.toString(),
      "ans9": bullet9.toString(),"ans10": bullet10.toString(),"ans11": bullet11.toString(),"ans12": bullet12.toString(),
      "observation2": observationName2!,
      "serial1": serialNumber1!,"serial2": newserialNumber1!,
      "serial3": serialNumber2!,"serial4": newserialNumber2!,
      "serial5": serialNumber3!,"serial6": newserialNumber3!,
      "serial7": serialNumber4!,"serial8": newserialNumber4!,
      "serial9": serialNumber5!,"serial10": newserialNumber5!,
      "ans13": bullet13.toString(),"ans14": bullet14.toString(),"ans15": bullet15.toString(),"ans16": bullet16.toString(),
      "observation3": observationName3!,
      "serial11": serialNumber6!,"serial12": newserialNumber6!,
      "lastDate1": lastReplaceDate1.toString()!,"newDate1": newReplaceDate1.toString()!,
      "lastDate2": lastReplaceDate2.toString()!,"newDate2": newReplaceDate2.toString()!,
      "lastDate3": lastReplaceDate3.toString()!,"newDate3": newReplaceDate3.toString()!,
      "lastDate4": lastReplaceDate4.toString()!,"newDate4": newReplaceDate4.toString()!,
      "conductedDate": conductedDate.toString(),"verifiedName": verifiedName!,
      "verifiedDesignation": verifiedDesignation!,"verifiedDate": verifiedDate.toString()
    });
    var data = json.decode(response.body);
    print(data);

    if (data['statusCode']==404) {
      setState(() {
        _isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Data has been saved!",
          style: TextStyle(fontWeight: FontWeight.bold,color: Colors.white),),backgroundColor: Colors.black,),
      );
    }

    else {
      setState(() {
        _isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Data failed to save",
          style: TextStyle(fontWeight: FontWeight.bold,color: Colors.white),),backgroundColor: Colors.red,),
      );
    }

  }

  void _submitForm2() async {

    setState(() {
      _isSamplingForm = true;
      _isLoading = true;
    });

    var client = http.Client();
    var response = await
    client.post(Uri.parse("https://my-developments.com/mms/api/marine/api-post-marine.php"), body: {
      "action": "marine-sampling-mm02","userID":_userID!,
      "serialNumber": sondeSerialNumber!,"version": firmWareVersion!,
      "startDate": sondeStartDate.toString(),"endDate":sondeEndDate.toString(),
      "startTime": sondeStartTime.toString(),"endTime": sondeEndTime.toString(),
      "location": sondeLocation!,
      "ph7_reading": ph7_reading!,"ph7_before": ph7_before!, "ph7_after": ph7_after!,
      "ph10_reading": ph10_reading!,"ph10_before": ph10_before!, "ph10_after": ph10_after!,
      "sp_before": sp_before!,"sp_after": sp_after!,
      "ntu_before": ntu_before!,"ntu_after": ntu_after!,
      "dis_before": dis_before!,"dis_after": dis_after!,
      "conductedDate": sondeConductedDate.toString(),"observation": sondeObservation!,
      "verifiedName": sondeVerifiedName!,"verifiedDesignation": sondeVerifiedDesignation!,
      "verifiedDate": sondeVerifiedDate.toString()
    });
    var data = json.decode(response.body);

    if (data['statusCode']==404) {
      setState(() {
        _isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Data has been saved!",
          style: TextStyle(fontWeight: FontWeight.bold,color: Colors.white),),backgroundColor: Colors.black,),
      );
    }

    else {
      setState(() {
        _isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Data failed to save",
          style: TextStyle(fontWeight: FontWeight.bold,color: Colors.white),),backgroundColor: Colors.red,),
      );
    }

  }

  void _submitForm3() async {

    setState(() {
      _isSamplingForm = true;
      _isLoading = true;
    });

    var client = http.Client();
    var response = await
    client.post(Uri.parse("https://mmsv2.pstw.com.my/api/marine/api-post-marine.php"), body: {
      "action": "marine-sampling-mm03","userID":_userID!,
      "ans17": bullet17.toString(),"remarks17": remarks17!,
      "ans18": bullet18.toString(),"remarks18": remarks18!,
      "ans19": bullet19.toString(),"remarks19": remarks19!,
      "ans20": bullet20.toString(),"remarks20": remarks20!,
      "ans21": bullet21.toString(),"remarks21": remarks21!,
      "ans22": bullet22.toString(),"remarks22": remarks22!,
      "ans23": bullet23.toString(),"remarks23": remarks23!,
      "ans24": bullet24.toString(),"remarks24": remarks24!,
      "ans25": bullet25.toString(),"remarks25": remarks25!,
      "ans26": bullet26.toString(),"remarks26": remarks26!,
      "ans27": bullet27.toString(),"remarks27": remarks27!,
      "ans28": bullet28.toString(),"remarks28": remarks28!,
      "ans29": bullet29.toString(),"remarks29": remarks29!,
      "ans30": bullet30.toString(),"remarks30": remarks30!,
      "ans31": bullet31.toString(),"remarks31": remarks31!,
      "ans32": bullet32.toString(),"remarks32": remarks32!,
      "ans33": bullet33.toString(),"remarks33": remarks33!,
      "ans34": bullet34.toString(),"remarks34": remarks34!,
      "ans35": bullet35.toString(),"remarks35": remarks35!,
      "ans36": bullet36.toString(),"remarks36": remarks36!,
      "ans37": bullet37.toString(),"remarks37": remarks37!,
      "ans38": bullet38.toString(),"remarks38": remarks38!,
      "ans39": bullet39.toString(),"remarks39": remarks39!,
      "ans40": bullet40.toString(),"remarks40": remarks40!,
      "ans41": bullet41.toString(),"remarks41": remarks41!,
      "ans42": bullet42.toString(),"remarks42": remarks42!,
      "ans43": bullet43.toString(),"remarks43": remarks43!,
      "ans44": bullet44.toString(),"remarks44": remarks44!,
      "ans45": bullet45.toString(),"remarks45": remarks45!,
      "ans46": bullet46.toString(),"remarks46": remarks46!,
      "ans47": bullet47.toString(),"remarks47": remarks47!,
      "ans48": bullet48.toString(),"remarks48": remarks48!,
      "ans49": bullet49.toString(),"remarks49": remarks49!,
      "inspectedDate": inspectedDate.toString(),
      "verifiedName1": verifiedName1!,
      "designationName1": designationName1!,
      "verifiedDate1": verifiedDate1.toString()
    });
    var data = json.decode(response.body);
    print(data);

    if (data['statusCode']==404) {
      setState(() {
        _isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Data has been saved!",
          style: TextStyle(fontWeight: FontWeight.bold,color: Colors.white),),backgroundColor: Colors.black,),
      );
    }

    else {
      setState(() {
        _isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Data failed to save",
          style: TextStyle(fontWeight: FontWeight.bold,color: Colors.white),),backgroundColor: Colors.red,),
      );
    }

  }

}