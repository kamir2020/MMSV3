import 'package:flutter/material.dart';

class SFormInfoCentre extends StatefulWidget {
  _SFormInfoCentre createState() => _SFormInfoCentre();
}

class _SFormInfoCentre extends State<SFormInfoCentre> {

  late String _formType = '';
  late String _title = 'Form';

  bool _form1 = false;
  bool _form2 = false;
  bool _form3 = false;
  bool _form4 = false;
  bool _form5 = false;

  // for Sample & Standard - Letter, for SOP - Procedure
  // for Equipment manual & reference - Manual & Reference
  // for List of Manual Marine Station - Station List
  @override
  void initState() {
    super.initState();
  }

  Widget _buildForm1() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              flex: 2,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Deputy of Environment (DOE) letter of sampling'),
                  Text('(Update: 2024 Oct 12)',style: TextStyle(color: Colors.red),)
                ],
              ),
            ),
            Expanded(
              flex: 2,
              child: Row(
                children: [
                  ElevatedButton(
                    onPressed: () {

                    },
                    child: Text('View'),
                  ),
                  SizedBox(width: 5.0,),
                  ElevatedButton(
                    onPressed: () {

                    },
                    child: Text('Download'),
                  ),
                ],
              ),
            )
          ],
        ),

        SizedBox(height: 10.0,),
        Row(
          children: [
            Expanded(
              flex: 2,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Pakar Scieno TW (PSTW) letter of sampling'),
                  Text('(Update: 2024 Oct 12)',style: TextStyle(color: Colors.red),)
                ],
              ),
            ),
            Expanded(
              flex: 2,
              child: Row(
                children: [
                  ElevatedButton(
                    onPressed: () {

                    },
                    child: Text('View'),
                  ),
                  SizedBox(width: 5.0,),
                  ElevatedButton(
                    onPressed: () {

                    },
                    child: Text('Download'),
                  ),
                ],
              ),
            )
          ],
        ),

        SizedBox(height: 10.0,),
        Row(
          children: [
            Expanded(
              flex: 2,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Additional letter'),
                  Text('(Update: 2024 Oct 12)',style: TextStyle(color: Colors.red),)
                ],
              ),
            ),
            Expanded(
              flex: 2,
              child: Row(
                children: [
                  ElevatedButton(
                    onPressed: () {

                    },
                    child: Text('View'),
                  ),
                  SizedBox(width: 5.0,),
                  ElevatedButton(
                    onPressed: () {

                    },
                    child: Text('Download'),
                  ),
                ],
              ),
            )
          ],
        ),

        SizedBox(height: 10.0,),
        Row(
          children: [
            Expanded(
              flex: 2,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Additional letter'),
                  Text('(Update: 2024 Oct 12)',style: TextStyle(color: Colors.red),)
                ],
              ),
            ),
            Expanded(
              flex: 2,
              child: Row(
                children: [
                  ElevatedButton(
                    onPressed: () {

                    },
                    child: Text('View'),
                  ),
                  SizedBox(width: 5.0,),
                  ElevatedButton(
                    onPressed: () {

                    },
                    child: Text('Download'),
                  ),
                ],
              ),
            )
          ],
        ),
      ],
    );
  }

  Widget _buildForm2() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              flex: 2,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('F-MM01 Equipment Maintenance and Repair Form'),
                  Text('(Update: 2024 Oct 12)',style: TextStyle(color: Colors.red),)
                ],
              ),
            ),
            Expanded(
              flex: 2,
              child: Row(
                children: [
                  ElevatedButton(
                    onPressed: () {

                    },
                    child: Text('View'),
                  ),
                  SizedBox(width: 5.0,),
                  ElevatedButton(
                    onPressed: () {

                    },
                    child: Text('Download'),
                  ),
                ],
              ),
            )
          ],
        ),

        SizedBox(height: 10.0,),
        Row(
          children: [
            Expanded(
              flex: 2,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('F-MM02 Sonde Calibration Form'),
                  Text('(Update: 2024 Oct 12)',style: TextStyle(color: Colors.red),)
                ],
              ),
            ),
            Expanded(
              flex: 2,
              child: Row(
                children: [
                  ElevatedButton(
                    onPressed: () {

                    },
                    child: Text('View'),
                  ),
                  SizedBox(width: 5.0,),
                  ElevatedButton(
                    onPressed: () {

                    },
                    child: Text('Download'),
                  ),
                ],
              ),
            )
          ],
        ),

        SizedBox(height: 10.0,),
        Row(
          children: [
            Expanded(
              flex: 2,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('F-MM03 Pre-Departure and Safety Checklist Form'),
                  Text('(Update: 2024 Oct 12)',style: TextStyle(color: Colors.red),)
                ],
              ),
            ),
            Expanded(
              flex: 2,
              child: Row(
                children: [
                  ElevatedButton(
                    onPressed: () {

                    },
                    child: Text('View'),
                  ),
                  SizedBox(width: 5.0,),
                  ElevatedButton(
                    onPressed: () {

                    },
                    child: Text('Download'),
                  ),
                ],
              ),
            )
          ],
        ),

        SizedBox(height: 10.0,),
        Row(
          children: [
            Expanded(
              flex: 2,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('F-MM04 Sampling Sheet Form'),
                  Text('(Update: 2024 Oct 12)',style: TextStyle(color: Colors.red),)
                ],
              ),
            ),
            Expanded(
              flex: 2,
              child: Row(
                children: [
                  ElevatedButton(
                    onPressed: () {

                    },
                    child: Text('View'),
                  ),
                  SizedBox(width: 5.0,),
                  ElevatedButton(
                    onPressed: () {

                    },
                    child: Text('Download'),
                  ),
                ],
              ),
            )
          ],
        ),

        SizedBox(height: 10.0,),
        Row(
          children: [
            Expanded(
              flex: 2,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('F-MM05 Chain of Custody Form'),
                  Text('(Update: 2024 Oct 12)',style: TextStyle(color: Colors.red),)
                ],
              ),
            ),
            Expanded(
              flex: 2,
              child: Row(
                children: [
                  ElevatedButton(
                    onPressed: () {

                    },
                    child: Text('View'),
                  ),
                  SizedBox(width: 5.0,),
                  ElevatedButton(
                    onPressed: () {

                    },
                    child: Text('Download'),
                  ),
                ],
              ),
            )
          ],
        ),

        SizedBox(height: 10.0,),
        Row(
          children: [
            Expanded(
              flex: 2,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('F-MM06 Notification Pollution Event 1 (NPE 1)'),
                  Text('(Update: 2024 Oct 12)',style: TextStyle(color: Colors.red),)
                ],
              ),
            ),
            Expanded(
              flex: 2,
              child: Row(
                children: [
                  ElevatedButton(
                    onPressed: () {

                    },
                    child: Text('View'),
                  ),
                  SizedBox(width: 5.0,),
                  ElevatedButton(
                    onPressed: () {

                    },
                    child: Text('Download'),
                  ),
                ],
              ),
            )
          ],
        ),

        SizedBox(height: 10.0,),
        Row(
          children: [
            Expanded(
              flex: 2,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('F-MM07 Notification of Non-Conforming Form'),
                  Text('(Update: 2024 Oct 12)',style: TextStyle(color: Colors.red),)
                ],
              ),
            ),
            Expanded(
              flex: 2,
              child: Row(
                children: [
                  ElevatedButton(
                    onPressed: () {

                    },
                    child: Text('View'),
                  ),
                  SizedBox(width: 5.0,),
                  ElevatedButton(
                    onPressed: () {

                    },
                    child: Text('Download'),
                  ),
                ],
              ),
            )
          ],
        ),

        SizedBox(height: 10.0,),
        Row(
          children: [
            Expanded(
              flex: 2,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('F-MM08 Contingency Action Log Form'),
                  Text('(Update: 2024 Oct 12)',style: TextStyle(color: Colors.red),)
                ],
              ),
            ),
            Expanded(
              flex: 2,
              child: Row(
                children: [
                  ElevatedButton(
                    onPressed: () {

                    },
                    child: Text('View'),
                  ),
                  SizedBox(width: 5.0,),
                  ElevatedButton(
                    onPressed: () {

                    },
                    child: Text('Download'),
                  ),
                ],
              ),
            )
          ],
        ),

        SizedBox(height: 10.0,),
        Row(
          children: [
            Expanded(
              flex: 2,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('F-MM09 Tarball Sampling Form'),
                  Text('(Update: 2024 Oct 12)',style: TextStyle(color: Colors.red),)
                ],
              ),
            ),
            Expanded(
              flex: 2,
              child: Row(
                children: [
                  ElevatedButton(
                    onPressed: () {

                    },
                    child: Text('View'),
                  ),
                  SizedBox(width: 5.0,),
                  ElevatedButton(
                    onPressed: () {

                    },
                    child: Text('Download'),
                  ),
                ],
              ),
            )
          ],
        ),

        SizedBox(height: 10.0,),
        Row(
          children: [
            Expanded(
              flex: 2,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Additional Form'),
                  Text('(Update: 2024 Oct 12)',style: TextStyle(color: Colors.red),)
                ],
              ),
            ),
            Expanded(
              flex: 2,
              child: Row(
                children: [
                  ElevatedButton(
                    onPressed: () {

                    },
                    child: Text('View'),
                  ),
                  SizedBox(width: 5.0,),
                  ElevatedButton(
                    onPressed: () {

                    },
                    child: Text('Download'),
                  ),
                ],
              ),
            )
          ],
        ),
      ],
    );
  }

  Widget _buildForm3() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              flex: 2,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Standard Operation Procedure (SOP) Marine Manual Straits of Johor (SOJ)'),
                  Text('(Update: 2024 Oct 12)',style: TextStyle(color: Colors.red),)
                ],
              ),
            ),
            Expanded(
              flex: 2,
              child: Row(
                children: [
                  ElevatedButton(
                    onPressed: () {

                    },
                    child: Text('View'),
                  ),
                  SizedBox(width: 5.0,),
                  ElevatedButton(
                    onPressed: () {

                    },
                    child: Text('Download'),
                  ),
                ],
              ),
            )
          ],
        ),

        SizedBox(height: 10.0,),
        Row(
          children: [
            Expanded(
              flex: 2,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Standard Operation Procedure (SOP) Marine Manual Investigative Study (IS)'),
                  Text('(Update: 2024 Oct 12)',style: TextStyle(color: Colors.red),)
                ],
              ),
            ),
            Expanded(
              flex: 2,
              child: Row(
                children: [
                  ElevatedButton(
                    onPressed: () {

                    },
                    child: Text('View'),
                  ),
                  SizedBox(width: 5.0,),
                  ElevatedButton(
                    onPressed: () {

                    },
                    child: Text('Download'),
                  ),
                ],
              ),
            )
          ],
        ),

        SizedBox(height: 10.0,),
        Row(
          children: [
            Expanded(
              flex: 2,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Additional Standard Operation Procedure (SOP)'),
                  Text('(Update: 2024 Oct 12)',style: TextStyle(color: Colors.red),)
                ],
              ),
            ),
            Expanded(
              flex: 2,
              child: Row(
                children: [
                  ElevatedButton(
                    onPressed: () {

                    },
                    child: Text('View'),
                  ),
                  SizedBox(width: 5.0,),
                  ElevatedButton(
                    onPressed: () {

                    },
                    child: Text('Download'),
                  ),
                ],
              ),
            )
          ],
        ),
      ],
    );
  }

  Widget _buildForm4() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              flex: 2,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('YSI EXO 2 Multiparameter Sonde User Manual'),
                  Text('(Update: 2024 Oct 12)',style: TextStyle(color: Colors.red),)
                ],
              ),
            ),
            Expanded(
              flex: 2,
              child: Row(
                children: [
                  ElevatedButton(
                    onPressed: () {

                    },
                    child: Text('View'),
                  ),
                  SizedBox(width: 5.0,),
                  ElevatedButton(
                    onPressed: () {

                    },
                    child: Text('Download'),
                  ),
                ],
              ),
            )
          ],
        ),

        SizedBox(height: 10.0,),
        Row(
          children: [
            Expanded(
              flex: 2,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Van Dorn Sampler User Manual'),
                  Text('(Update: 2024 Oct 12)',style: TextStyle(color: Colors.red),)
                ],
              ),
            ),
            Expanded(
              flex: 2,
              child: Row(
                children: [
                  ElevatedButton(
                    onPressed: () {

                    },
                    child: Text('View'),
                  ),
                  SizedBox(width: 5.0,),
                  ElevatedButton(
                    onPressed: () {

                    },
                    child: Text('Download'),
                  ),
                ],
              ),
            )
          ],
        ),

        SizedBox(height: 10.0,),
        Row(
          children: [
            Expanded(
              flex: 2,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Additional Equipment User Manual'),
                  Text('(Update: 2024 Oct 12)',style: TextStyle(color: Colors.red),)
                ],
              ),
            ),
            Expanded(
              flex: 2,
              child: Row(
                children: [
                  ElevatedButton(
                    onPressed: () {

                    },
                    child: Text('View'),
                  ),
                  SizedBox(width: 5.0,),
                  ElevatedButton(
                    onPressed: () {

                    },
                    child: Text('Download'),
                  ),
                ],
              ),
            )
          ],
        ),
      ],
    );
  }

  Widget _buildForm5() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              flex: 2,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Marine Manual Station'),
                  Text('(Update: 2024 Oct 12)',style: TextStyle(color: Colors.red),)
                ],
              ),
            ),
            Expanded(
              flex: 2,
              child: Row(
                children: [
                  ElevatedButton(
                    onPressed: () {

                    },
                    child: Text('View'),
                  ),
                  SizedBox(width: 5.0,),
                  ElevatedButton(
                    onPressed: () {

                    },
                    child: Text('Download'),
                  ),
                ],
              ),
            )
          ],
        ),

        SizedBox(height: 10.0,),
        Row(
          children: [
            Expanded(
              flex: 2,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Tarball Station'),
                  Text('(Update: 2024 Oct 12)',style: TextStyle(color: Colors.red),)
                ],
              ),
            ),
            Expanded(
              flex: 2,
              child: Row(
                children: [
                  ElevatedButton(
                    onPressed: () {

                    },
                    child: Text('View'),
                  ),
                  SizedBox(width: 5.0,),
                  ElevatedButton(
                    onPressed: () {

                    },
                    child: Text('Download'),
                  ),
                ],
              ),
            )
          ],
        ),

        SizedBox(height: 10.0,),
        Row(
          children: [
            Expanded(
              flex: 2,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Investigative Station'),
                  Text('(Update: 2024 Oct 12)',style: TextStyle(color: Colors.red),)
                ],
              ),
            ),
            Expanded(
              flex: 2,
              child: Row(
                children: [
                  ElevatedButton(
                    onPressed: () {

                    },
                    child: Text('View'),
                  ),
                  SizedBox(width: 5.0,),
                  ElevatedButton(
                    onPressed: () {

                    },
                    child: Text('Download'),
                  ),
                ],
              ),
            )
          ],
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('INFO CENTRE',
          style: TextStyle(fontSize: 20,fontWeight: FontWeight.bold),),
        SizedBox(height: 10.0,),

        Text(_title),
        SizedBox(height: 5.0,),
        DropdownButtonFormField(
          decoration: InputDecoration(
            contentPadding: EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10.0),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(15.0)),
          ),
          value: _formType.isNotEmpty ? _formType : null,
          items: <String>['Sampling Document', 'Standard Forms', 'Standard Operating Procedure (SOP)', 'Equipment Manual & Reference', 'List of Manual Marine Station']
              .map<DropdownMenuItem<String>>((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(value),
            );
          }).toList(),
          onChanged: (value) {
            setState(() {
              _formType = value.toString();

              if (_formType=='Sampling Document') {
                _form1 = true;
                _form2 = false;
                _form3 = false;
                _form4 = false;
                _form5 = false;
              }
              else if (_formType=='Standard Forms') {
                _form1 = false;
                _form2 = true;
                _form3 = false;
                _form4 = false;
                _form5 = false;
              }
              else if (_formType=='Standard Operating Procedure (SOP)') {
                _form1 = false;
                _form2 = false;
                _form3 = true;
                _form4 = false;
                _form5 = false;
              }
              else if (_formType=='Equipment Manual & Reference') {
                _form1 = false;
                _form2 = false;
                _form3 = false;
                _form4 = true;
                _form5 = false;
              }
              else if (_formType=='List of Manual Marine Station') {
                _form1 = false;
                _form2 = false;
                _form3 = false;
                _form4 = false;
                _form5 = true;
              }
            });
          },
          validator: (value) =>
          value!.isEmpty ? 'Form type is required' : null,
        ),
        SizedBox(height: 20.0,),
        Text('Seaching Result...',
          style: TextStyle(fontSize: 18,fontWeight: FontWeight.bold),),

        Column(
          children: [
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
            else if (_form5 == true) ... [
              _buildForm5(),
            ]
          ],
        ),
      ],
    );
  }

}