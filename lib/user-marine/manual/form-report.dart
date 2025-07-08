import 'package:flutter/material.dart';
import 'package:toggle_switch/toggle_switch.dart';

class SFormReport extends StatefulWidget {
  _SFormReport createState() => _SFormReport();
}

class _SFormReport extends State<SFormReport> {

  late String _formType = '';
  bool _isReportForm  = true;
  bool _isNewReport = false;

  bool _isFirstPageBuild1 = false;
  bool _isFirstPageBuild2 = false;
  bool _isFirstPageBuild3 = false;


  late String _special_1 = 'μ';

  final List<Map<String, dynamic>> items = [
    {'index': 1, 'value': 'Equipment Maintenance Report (F-MM01)'},
    {'index': 2, 'value': 'Sonde Calibration Form (F-MM02)'},
    {'index': 3, 'value': 'Pre-Departure & Safety Checklist Report (F-MM03)'},
    {'index': 4, 'value': 'Notification Pollution Event 1 (F-MM06)'},
    {'index': 5, 'value': 'Equipment Maintenance & Repair (F-MM01)'},

  ];
  int? selectedIndex;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: _isReportForm ? Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('REPORT',
            style: TextStyle(fontSize: 20,fontWeight: FontWeight.bold),),
          SizedBox(height: 10.0,),

          Text('Type of Report'),
          SizedBox(height: 5.0,),
          DropdownButtonFormField(
            decoration: InputDecoration(
              contentPadding: EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10.0),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(15.0)),
            ),
            value: selectedIndex,
            items: items.map((item) {
              return DropdownMenuItem<int>(
                value: item['index'], // Use the index as the value
                child: Text(item['value'],style: TextStyle(fontSize: 12),), // Display the value as text
              );
            }).toList(),
            onChanged: (int? newIndex) {
              setState(() {
                selectedIndex = newIndex;
              });
            },

          ),
          SizedBox(height: 20.0,),
          Container(
            height: 40,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _isReportForm = false;
                      _isNewReport = true;

                      if (selectedIndex==4) {
                        _isFirstPageBuild1 = true;
                      }
                    });
                  },
                  child: Text('Create Report'),
                ),
                SizedBox(width: 10.0,),
                ElevatedButton(
                  onPressed: () {

                  },
                  child: Text('Rejected Report'),
                ),
                SizedBox(width: 10.0,),
                ElevatedButton(
                  onPressed: () {

                  },
                  child: Text('Completed Report'),
                ),
              ],
            ),
          ),
        ],
      ) : SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if ((selectedIndex == 4)&&(_isNewReport == true)) ... [
              _buildNewForm1(),
            ]
            else if ((selectedIndex == 2)&&(_isNewReport == true))  ... [
              _buildNewForm2(),
            ]
            else if ((selectedIndex == 3)&&(_isNewReport == true))  ... [
              _buildNewForm3(),
            ]
          ],
        ),
      ),
    );
  }

  Widget _buildNewForm1() {
    return Form(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Notification Pollution Event 1/NPE 1 (F-MM06)',style: TextStyle(fontSize: 15,fontWeight: FontWeight.bold),),
          SizedBox(height: 15.0,),
          _isFirstPageBuild1 ? Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text('State'),
                  ),
                  Expanded(
                    flex: 2,
                    child: DropdownButtonFormField(
                      decoration: InputDecoration(
                        contentPadding: EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10.0),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(15.0)),
                      ),
                      value: _formType.isNotEmpty ? _formType : null,
                      items: <String>['ABC',]
                          .map<DropdownMenuItem<String>>((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _formType = value.toString();
                        });
                      },
                      validator: (value) =>
                      value!.isEmpty ? 'Form type is required' : null,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 5.0,),
              Row(
                children: [
                  Expanded(
                    child: Text('Station ID & Name'),
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
                    child: Text('Location'),
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
                    child: Text('Date'),
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
                    child: Text('Time'),
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
              Divider(),
              Row(
                children: [
                  Expanded(
                    child: Container(
                      height: 50,
                      width: MediaQuery.of(context).size.width,
                      child: ElevatedButton(
                        onPressed: () {

                        },
                        child: Text('Communicate via Serial Cable',textAlign: TextAlign.center,),
                      ),
                    ),
                  ),
                  SizedBox(width: 10.0,),
                  Expanded(
                    child: Container(
                      height: 50,
                      width: MediaQuery.of(context).size.width,
                      child: ElevatedButton(
                        onPressed: () {

                        },
                        child: Text('Communicate via Bluetooth',textAlign: TextAlign.center,),
                      ),
                    ),
                  ),
                ],
              ),

              SizedBox(height: 5.0,),
              Row(
                children: [
                  Expanded(
                    flex: 3,
                    child: Text('Oxygen Concentration'),
                  ),
                  Expanded(
                    flex: 2,
                    child: Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            decoration: InputDecoration(
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10.0)),
                            ),
                          ),
                        ),
                        SizedBox(width: 10.0,),
                        Expanded(
                          child: Text('(mg/L)'),
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
                    child: Text('Oxygen Saturation'),
                  ),
                  Expanded(
                    flex: 2,
                    child: Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            decoration: InputDecoration(
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10.0)),
                            ),
                          ),
                        ),
                        SizedBox(width: 10.0,),
                        Expanded(
                          child: Text('(% sat)'),
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
                    child: Text('pH'),
                  ),
                  Expanded(
                    flex: 2,
                    child: Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            decoration: InputDecoration(
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10.0)),
                            ),
                          ),
                        ),
                        SizedBox(width: 10.0,),
                        Expanded(
                          child: Text(''),
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
                    child: Text('Sanality'),
                  ),
                  Expanded(
                    flex: 2,
                    child: Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            decoration: InputDecoration(
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10.0)),
                            ),
                          ),
                        ),
                        SizedBox(width: 10.0,),
                        Expanded(
                          child: Text('(g/L (ppt))'),
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
                    child: Text('Electrical Conductivity'),
                  ),
                  Expanded(
                    flex: 2,
                    child: Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            decoration: InputDecoration(
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10.0)),
                            ),
                          ),
                        ),
                        SizedBox(width: 10.0,),
                        Expanded(
                          child: Text('('+_special_1+'s/cm)'),
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
                    child: Text('Temperature'),
                  ),
                  Expanded(
                    flex: 2,
                    child: Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            decoration: InputDecoration(
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10.0)),
                            ),
                          ),
                        ),
                        SizedBox(width: 10.0,),
                        Expanded(
                          child: RichText(
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
                    child: Text('TDS'),
                  ),
                  Expanded(
                    flex: 2,
                    child: Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            decoration: InputDecoration(
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10.0)),
                            ),
                          ),
                        ),
                        SizedBox(width: 10.0,),
                        Expanded(
                          child: Text('(mg/L)'),
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
                    child: Text('Turbidity'),
                  ),
                  Expanded(
                    flex: 2,
                    child: Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            decoration: InputDecoration(
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10.0)),
                            ),
                          ),
                        ),
                        SizedBox(width: 10.0,),
                        Expanded(
                          child: Text('(NTU)'),
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
                    child: Text('TSS'),
                  ),
                  Expanded(
                    flex: 2,
                    child: Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            decoration: InputDecoration(
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10.0)),
                            ),
                          ),
                        ),
                        SizedBox(width: 10.0,),
                        Expanded(
                          child: Text('(mg/L)'),
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
                    child: Text('Battery status'),
                  ),
                  Expanded(
                    flex: 2,
                    child: Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            decoration: InputDecoration(
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10.0)),
                            ),
                          ),
                        ),
                        SizedBox(width: 10.0,),
                        Expanded(
                          child: Text('(V)'),
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
                        setState(() {
                          setState(() {
                            _isReportForm = false;
                            _isFirstPageBuild1 = false;
                          });
                        });
                      },
                      child: Text('Next'),
                    ),
                  )
                ],
              ),
            ],
          ) : Column(
            crossAxisAlignment: CrossAxisAlignment.start,
           children: [
             Text('Field observation',style: TextStyle(fontWeight: FontWeight.bold,fontSize: 15),),

             SizedBox(height: 10.0,),
             Row(
               children: [
                 Expanded(
                   flex: 1,
                   child: Text('Oil slick on the water surface/Oil spill'),
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
                           print('switched to: $index');
                         },
                       ),
                     ],
                   ),
                 ),
               ],
             ),

             SizedBox(height: 10.0,),
             Row(
               children: [
                 Expanded(
                   flex: 1,
                   child: Text('Discoloration of the sea water'),
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
                           print('switched to: $index');
                         },
                       ),
                     ],
                   ),
                 ),
               ],
             ),

             SizedBox(height: 10.0,),
             Row(
               children: [
                 Expanded(
                   flex: 1,
                   child: Text('Formation of foam on the surface'),
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
                           print('switched to: $index');
                         },
                       ),
                     ],
                   ),
                 ),
               ],
             ),

             SizedBox(height: 10.0,),
             Row(
               children: [
                 Expanded(
                   flex: 1,
                   child: Text('Coral bleaching or dead corals'),
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
                           print('switched to: $index');
                         },
                       ),
                     ],
                   ),
                 ),
               ],
             ),

             SizedBox(height: 10.0,),
             Row(
               children: [
                 Expanded(
                   flex: 1,
                   child: Text('Observation of the tar balls'),
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
                           print('switched to: $index');
                         },
                       ),
                     ],
                   ),
                 ),
               ],
             ),

             SizedBox(height: 10.0,),
             Row(
               children: [
                 Expanded(
                   flex: 1,
                   child: Text('Excessive debris'),
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
                           print('switched to: $index');
                         },
                       ),
                     ],
                   ),
                 ),
               ],
             ),

             SizedBox(height: 10.0,),
             Row(
               children: [
                 Expanded(
                   flex: 1,
                   child: Text('Red tides or algae blooms'),
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
                           print('switched to: $index');
                         },
                       ),
                     ],
                   ),
                 ),
               ],
             ),

             SizedBox(height: 10.0,),
             Row(
               children: [
                 Expanded(
                   flex: 1,
                   child: Text('Slit plume'),
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
                           print('switched to: $index');
                         },
                       ),
                     ],
                   ),
                 ),
               ],
             ),

             SizedBox(height: 10.0,),
             Row(
               children: [
                 Expanded(
                   flex: 1,
                   child: Text('Foul smell'),
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
                           print('switched to: $index');
                         },
                       ),
                     ],
                   ),
                 ),
               ],
             ),

             SizedBox(height: 10.0,),
             Row(
               children: [
                 Expanded(
                   flex: 1,
                   child: Text('Others'),
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
                   hintStyle: TextStyle(fontSize: 12),
                   hintText: 'Remarks'
               ),
             ),

             SizedBox(height: 10.0,),
             Row(
               children: [
                 Expanded(
                   flex: 1,
                   child: Text('Possible source'),
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
                  hintStyle: TextStyle(fontSize: 12),
                  hintText: 'Remarks'
               ),
             ),

             SizedBox(height: 10.0,),
             Text('Photo Attachment'),
             Row(
               children: [
                 Expanded(
                   child: Text('Picture:',
                     style: TextStyle(fontWeight: FontWeight.bold,),),
                 ),
                 Expanded(
                   flex: 2,
                   child: ElevatedButton(
                     onPressed: () {

                     },
                     child: Text('Upload multiple pictures'),
                   ),
                 ),
               ],
             ),

             SizedBox(
               height: 15.0,
             ),

             Divider(),
             Text('REPORTED BY:',style: TextStyle(fontWeight: FontWeight.bold,color: Colors.green),),
             Row(
               children: [
                 Expanded(
                   child: Text('Name:',
                     style: TextStyle(fontWeight: FontWeight.bold,),),
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
                   child: Text('Signature:',
                     style: TextStyle(fontWeight: FontWeight.bold,),),
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
                   child: Text('Date:',
                     style: TextStyle(fontWeight: FontWeight.bold,),),
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

             SizedBox(height: 10.0,),
             Text('VERIFIED BY:',style: TextStyle(fontWeight: FontWeight.bold,color: Colors.red),),
             Row(
               children: [
                 Expanded(
                   child: Text('Name:',
                     style: TextStyle(fontWeight: FontWeight.bold,),),
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
                   child: Text('Signature:',
                     style: TextStyle(fontWeight: FontWeight.bold,),),
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
                   child: Text('Date:',
                     style: TextStyle(fontWeight: FontWeight.bold,),),
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
             Divider(),

             SizedBox(height: 10,),
             Row(
               children: [
                 Expanded(
                   child: ElevatedButton(
                     onPressed: () {
                      setState(() {
                        _isFirstPageBuild1 = false;
                        _isReportForm = true;
                      });
                     },
                     child: Text('Cancel'),
                   ),
                 ),
                 SizedBox(width: 10.0,),
                 Expanded(
                   child: ElevatedButton(
                     onPressed: () {
                       setState(() {
                         setState(() {

                         });
                       });
                     },
                     child: Text('Submit'),
                   ),
                 )
               ],
             ),
           ],
          )
        ],
      ),
    );
  }

  Widget _buildNewForm2() {
    return Form(
      child: Text('AAAA'),
    );
  }

  Widget _buildNewForm3() {
    return Form(
      child: Column(
        children: [
          Text(' Pre-Departure Checklist & Safety Checklist Form(F-MM03)',style: TextStyle(fontSize: 20,fontWeight: FontWeight.bold),),
          SizedBox(height: 15.0,),
          Row(
            children: [
              Expanded(
                flex: 1,
                child: Text('MMWQM Standard Operation Procedure (SOP)'),
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
                hintText: 'Remarks'
            ),
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
                hintText: 'Remarks'
            ),
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
                hintText: 'Remarks'
            ),
          ),

          SizedBox(height: 15.0,),
          Row(
            children: [
              Expanded(
                flex: 1,
                child: Text('Varn Dorn Sampler with Rope and Messenger'),
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
                hintText: 'Remarks'
            ),
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
                hintText: 'Remarks'
            ),
          ),

          SizedBox(height: 15.0,),
          Row(
            children: [
              Expanded(
                flex: 1,
                child: Text('Smart pre-installed with application (apps for manual sampling - MMS)'),
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
                hintText: 'Remarks'
            ),
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
                hintText: 'Remarks'
            ),
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
                hintText: 'Remarks'
            ),
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
                hintText: 'Remarks'
            ),
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
                hintText: 'Remarks'
            ),
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
                hintText: 'Remarks'
            ),
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
                hintText: 'Remarks'
            ),
          ),

          SizedBox(height: 15.0,),
          Row(
            children: [
              Expanded(
                flex: 1,
                child: Text('Sampling Shoes'),
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
                hintText: 'Remarks'
            ),
          ),

          SizedBox(height: 15.0,),
          Row(
            children: [
              Expanded(
                flex: 1,
                child: Text('Sufficient set of cooler box and sampling bottles'),
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
                hintText: 'Remarks'
            ),
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
                hintText: 'Remarks'
            ),
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
                hintText: 'Remarks'
            ),
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
                hintText: 'Remarks'
            ),
          ),

          SizedBox(height: 15.0,),
          Row(
            children: [
              Expanded(
                flex: 1,
                child: Text('Maker pen, pen and brown tapes'),
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
                hintText: 'Remarks'
            ),
          ),

          SizedBox(height: 15.0,),
          Row(
            children: [
              Expanded(
                flex: 1,
                child: Text('Zipper Bags'),
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
                hintText: 'Remarks'
            ),
          ),

          SizedBox(height: 15.0,),
          Row(
            children: [
              Expanded(
                flex: 1,
                child: Text('Aluminium Foil'),
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
                hintText: 'Remarks'
            ),
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
}