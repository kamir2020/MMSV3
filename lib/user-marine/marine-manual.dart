import 'package:app_mms/user-marine/manual/form-image-request.dart';
import 'package:app_mms/user-marine/manual/form-info-centre.dart';
import 'package:flutter/material.dart';
import 'package:app_mms/user-marine/manual/form-in-situ-sampling.dart';
import 'manual/form-data-log.dart';
import 'manual/form-pre-sampling.dart';
import 'manual/form-report.dart';
import 'manual/form-tarball.dart';

class UserMarineManual extends StatefulWidget {
  _UserMarineManual createState() => _UserMarineManual();
}

class _UserMarineManual extends State<UserMarineManual> {

  bool isDisplay = true;
  bool formInfoCentre = false;
  bool formPreSampling = false;
  bool formSample = false;
  bool formReport = false;
  bool menuNPE1 = false;
  bool menuNPE2 = false;
  bool formTarball = false;
  bool menuLog = false;
  bool menuImageRequest = false;

  late Widget _containerMarine = _listMenu();

  @override
  void initState() {
    super.initState();
  }

  Widget _listMenu() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Icon(Icons.arrow_circle_right_outlined,color: Colors.green,),
            ),
            SizedBox(width: 10,),
            Expanded(
              flex: 15,
              child: Text('Info centre',
                style: TextStyle(fontSize: 15,fontWeight: FontWeight.bold),),
            ),
          ],
        ),
        SizedBox(height: 10,),
        Container(
          alignment: Alignment.centerLeft,
          width: MediaQuery.of(context).size.width,
          height: 80,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10.0),
            color: Colors.transparent,
          ),
          child: ListView(
            scrollDirection: Axis.vertical,
            children: [
              TextButton(
                onPressed: () {
                  setState(() {
                    isDisplay = false;
                    formInfoCentre = true;

                    _containerMarine = SFormInfoCentre();
                  });
                },
                child: Text('Info Centre Document'),
              ),
              /*
              TextButton(
                onPressed: () {

                },
                child: Text('Standard form'),
              ),
              TextButton(
                onPressed: () {

                },
                child: Text('Standard operating procedure (SOP)'),
              ),
              TextButton(
                onPressed: () {

                },
                child: Text('Equipment manual and reference'),
              ),
              TextButton(
                onPressed: () {

                },
                child: Text('List of manual marine station'),
              ),*/
            ],
          ),
        ),
        SizedBox(height: 10,),
        Divider(),

        Row(
          children: [
            Expanded(
              child: Icon(Icons.arrow_circle_right_outlined,color: Colors.green,),
            ),
            SizedBox(width: 10,),
            Expanded(
              flex: 15,
              child: Text('Pre-sampling',
                style: TextStyle(fontSize: 15,fontWeight: FontWeight.bold),),
            ),
          ],
        ),
        SizedBox(height: 10,),
        Container(
          width: MediaQuery.of(context).size.width,
          height: 80,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10.0),
            color: Colors.transparent,
          ),
          child: ListView(
            children: [
              TextButton(
                onPressed: () {
                  setState(() {
                    isDisplay = false;
                    formPreSampling = true;

                    _containerMarine = SFormPreSampling();
                  });
                },
                child: Text('Pre-Sampling Form'),
              ),
              /*
              TextButton(
                onPressed: () {
                },
                child: Text('Equipment Maintenance Form (F-MM01)'),
              ),
              TextButton(
                onPressed: () {
                },
                child: Text('Sonde Calibration Form (F-MM02)'),
              ),
              TextButton(
                onPressed: () {
                },
                child: Text('Pre-Departure Checklist & Safety Checklist Form'),
              ),*/
            ],
          ),
        ),
        SizedBox(height: 10,),
        Divider(),

        Row(
          children: [
            Expanded(
              child: Icon(Icons.arrow_circle_right_outlined,color: Colors.green,),
            ),
            SizedBox(width: 10,),
            Expanded(
              flex: 15,
              child: Text('In Situ Sampling',
                style: TextStyle(fontSize: 15,fontWeight: FontWeight.bold),),
            ),
          ],
        ),
        SizedBox(height: 10,),
        Container(
          width: MediaQuery.of(context).size.width,
          height: 80,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10.0),
            color: Colors.transparent,
          ),
          child: ListView(
            children: [
              TextButton(
                onPressed: () {
                  setState(() {
                    isDisplay = false;
                    formSample = true;

                    _containerMarine = SFormInSituSample();
                  });
                },
                child: Text('Process of sampling'),
              ),
            ],
          ),
        ),
        SizedBox(height: 10,),
        Divider(),

        SizedBox(height: 10,),
        Row(
          children: [
            Expanded(
              child: Icon(Icons.arrow_circle_right_outlined,color: Colors.green,),
            ),
            SizedBox(width: 10,),
            Expanded(
              flex: 15,
              child: Text('Tarball Sampling',
                style: TextStyle(fontSize: 15,fontWeight: FontWeight.bold),),
            ),
          ],
        ),
        SizedBox(height: 10,),
        Container(
          width: MediaQuery.of(context).size.width,
          height: 80,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10.0),
            color: Colors.transparent,
          ),
          child: ListView(
            children: [
              TextButton(
                onPressed: () {
                  setState(() {
                    isDisplay = false;
                    formTarball = true;

                    _containerMarine = SFormTarball();
                  });
                },
                child: Text('Process of sampling'),
              )
            ],
          ),
        ),
        SizedBox(height: 10,),
        Divider(),

        SizedBox(height: 10,),
        Row(
          children: [
            Expanded(
              child: Icon(Icons.arrow_circle_right_outlined,color: Colors.green,),
            ),
            SizedBox(width: 10,),
            Expanded(
              flex: 15,
              child: Text('Report',
                style: TextStyle(fontSize: 15,fontWeight: FontWeight.bold),),
            ),
          ],
        ),
        Container(
          width: MediaQuery.of(context).size.width,
          height: 80,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10.0),
            color: Colors.transparent,
          ),
          child: ListView(
            children: [
              TextButton(
                onPressed: () {
                  setState(() {
                    isDisplay = false;
                    formReport = true;

                    _containerMarine = SFormReport();
                  });
                },
                child: Text('Process of reporting'),
              ),
              /*
              TextButton(
                onPressed: () {
                },
                child: Text('Sonde Calibration Form (F-MM02)'),
              ),
              TextButton(
                onPressed: () {
                },
                child: Text('Pre-Departure Checklist & Safety Checklist Form'),
              ),
              TextButton(
                onPressed: () {
                },
                child: Text('Notification Pollution Event 1/NPE 1 (F-MM06)'),
              ),
              TextButton(
                onPressed: () {
                },
                child: Text('Tarball Sampling Report (F-MM09))'),
              ),*/
            ],
          ),
        ),
        SizedBox(height: 10,),
        Divider(),

        SizedBox(height: 10,),
        Row(
          children: [
            Expanded(
              child: Icon(Icons.arrow_circle_right_outlined,color: Colors.green,),
            ),
            SizedBox(width: 10,),
            Expanded(
              flex: 15,
              child: Text('Data Status Log',
                style: TextStyle(fontSize: 15,fontWeight: FontWeight.bold),),
            ),
          ],
        ),
        SizedBox(height: 10,),
        Container(
          width: MediaQuery.of(context).size.width,
          height: 80,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10.0),
            color: Colors.transparent,
          ),
          child: ListView(
            children: [
              TextButton(
                onPressed: () {
                  setState(() {
                    isDisplay = false;
                    menuLog = true;

                    _containerMarine = SFormDataLog();

                  });
                },
                child: Text('Process of status log'),
              ),
            ],
          ),
        ),
        SizedBox(height: 10,),
        Divider(),

        SizedBox(height: 10,),
        Row(
          children: [
            Expanded(
              child: Icon(Icons.arrow_circle_right_outlined,color: Colors.green,),
            ),
            SizedBox(width: 10,),
            Expanded(
              flex: 15,
              child: Text('Image Request',
                style: TextStyle(fontSize: 15,fontWeight: FontWeight.bold),),
            ),
          ],
        ),
        Container(
          width: MediaQuery.of(context).size.width,
          height: 80,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10.0),
            color: Colors.transparent,
          ),
          child: ListView(
            children: [
              TextButton(
                onPressed: () {
                  setState(() {
                    isDisplay = false;
                    menuImageRequest = true;

                    _containerMarine = SFormImageRequest();
                  });
                },
                child: Text('Process of image request'),
              ),
            ],
          ),
        ),
        SizedBox(height: 10,),
        Divider(),

      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(

        child: Padding(
          padding: EdgeInsets.all(10.0),
          child: Column(
            children: [
              if (isDisplay == true) ... [
                _containerMarine,
              ]
              else if (formInfoCentre == true) ... [
                _containerMarine,
              ]
              else if (formPreSampling == true) ... [
                  _containerMarine,
                ]
                else if (formReport == true) ... [
                    _containerMarine,
                  ]
                  else if (formSample == true) ... [
                      _containerMarine,
                    ]
                    else if (formTarball == true) ... [
                        _containerMarine,
                      ]
                      else if (menuLog == true) ... [
                          _containerMarine,
                        ]
                        else if (menuImageRequest == true) ... [
                            _containerMarine,
                          ]
            ],
          ),
        ),
      ),
      floatingActionButton: isDisplay ? SizedBox() :
      FloatingActionButton(
        backgroundColor: Colors.white,
        tooltip: 'Marine-Sampling',
        onPressed: (){
          setState(() {
            isDisplay = true;
            _containerMarine = _listMenu();
          });
        },
        child: const Icon(Icons.arrow_back, color: Colors.black, size: 28),
      ),
    );
  }

}
