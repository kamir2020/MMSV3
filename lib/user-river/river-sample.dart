import 'package:app_mms/user-marine/manual/form-tarball.dart';
import 'package:flutter/material.dart';
import 'package:app_mms/user-river/sample/form-river-sample.dart';


class UserRiverSample extends StatefulWidget {
  _UserRiverSample createState() => _UserRiverSample();
}

class _UserRiverSample extends State<UserRiverSample> {

  bool isDisplay = true;
  bool formSample = false;
  bool menuNPE1 = false;
  bool menuNPE2 = false;
  bool formTriennial = false;
  bool menuLog = false;
  bool menuImageRequest = false;

  late Widget _containerRiver = _listMenu();

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
              child: Text('RIVER: Sampling',
                style: TextStyle(fontSize: 15,fontWeight: FontWeight.bold),),
            ),
          ],
        ),
        SizedBox(height: 10,),
        Container(
          width: MediaQuery.of(context).size.width,
          height: 60,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10.0),
            color: Colors.transparent,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 170,
                height: 50,
                child: ElevatedButton(
                  onPressed: () {
                    setState(() {
                      isDisplay = false;
                      formSample = true;

                      _containerRiver = SFormRiverSample();
                    });
                  },
                  child: Text('Sampling Data'),
                ),
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
              child: Text('RIVER: Report',
                style: TextStyle(fontSize: 15,fontWeight: FontWeight.bold),),
            ),
          ],
        ),
        Container(
          width: MediaQuery.of(context).size.width,
          height: 60,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10.0),
            color: Colors.transparent,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Container(
                width: 170,
                height: 50,
                child: ElevatedButton(
                  onPressed: () {

                  },
                  child: Text('NPE-1'),
                ),
              ),
              SizedBox(width: 20,),
              Container(
                width: 170,
                height: 50,
                child: ElevatedButton(
                  onPressed: () {

                  },
                  child: Text('NPE-2'),
                ),
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
              child: Text('RIVER: Triennial',
                style: TextStyle(fontSize: 15,fontWeight: FontWeight.bold),),
            ),
          ],
        ),
        SizedBox(height: 10,),
        Container(
          width: MediaQuery.of(context).size.width,
          height: 60,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10.0),
            color: Colors.transparent,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 170,
                height: 50,
                child: ElevatedButton(
                  onPressed: () {
                    setState(() {
                      isDisplay = false;
                      formTriennial = true;

                      _containerRiver = SFormTarball();
                    });
                  },
                  child: Text('Report Data'),
                ),
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
              child: Text('RIVER: Data Log',
                style: TextStyle(fontSize: 15,fontWeight: FontWeight.bold),),
            ),
          ],
        ),
        SizedBox(height: 10,),
        Container(
          width: MediaQuery.of(context).size.width,
          height: 60,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10.0),
            color: Colors.transparent,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 170,
                height: 50,
                child: ElevatedButton(
                  onPressed: () {

                  },
                  child: Text('Data Log Report'),
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 10,),

        /*
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
              child: Text('RIVER: Image Request',
                style: TextStyle(fontSize: 15,fontWeight: FontWeight.bold),),
            ),
          ],
        ),
        SizedBox(height: 10,),
        Container(
          width: MediaQuery.of(context).size.width,
          height: 60,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10.0),
            color: Colors.transparent,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 170,
                height: 50,
                child: ElevatedButton(
                  onPressed: () {

                  },
                  child: Text('Upload image request'),
                ),
              ),
            ],
          ),
        ),*/
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
                _containerRiver,
              ]
              else if (formSample == true) ... [
                _containerRiver,
              ]
              else if (formTriennial == true) ... [
                  _containerRiver,
                ]
            ],
          ),
        ),
      ),
      floatingActionButton: isDisplay ? SizedBox() :
      FloatingActionButton(
        backgroundColor: Colors.white,
        tooltip: 'River-Sampling',
        onPressed: (){
          setState(() {
            isDisplay = true;
            _containerRiver = _listMenu();
          });
        },
        child: const Icon(Icons.arrow_back, color: Colors.black, size: 28),
      ),
    );
  }

}

