import 'package:flutter/material.dart';
import 'sample/form-air-collection-sample.dart';
import 'sample/form-air-data-log.dart';
import 'sample/form-air-install-sample.dart';

class UserAirSample extends StatefulWidget {
  _UserAirSample createState() => _UserAirSample();
}

class _UserAirSample extends State<UserAirSample> {

  bool isDisplay = true;
  bool formAirInstallSample = false;
  bool formAirCollectionSample = false;
  bool formAirDataLog = false;
  bool menuNPE1 = false;
  bool menuNPE2 = false;
  bool menuLog = false;
  bool menuImageRequest = false;

  late Widget _containerAir = _listMenu();

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
              child: Text('AIR: Sampling',
                style: TextStyle(fontSize: 15,fontWeight: FontWeight.bold),),
            ),
          ],
        ),
        SizedBox(height: 10,),
        Row(
          children: [
            Expanded(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  alignment: Alignment.centerLeft, // align text to the left
                  padding: EdgeInsets.symmetric(horizontal: 20), // optional padding
                ),
                onPressed: () {
                  setState(() {
                    isDisplay = false;
                    formAirInstallSample = true;

                    _containerAir = SFormAirInstallSample();
                  });
                },
                child: Text('Installation'),
              ),
            )
          ],
        ),
        Row(
          children: [
            Expanded(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  alignment: Alignment.centerLeft, // align text to the left
                  padding: EdgeInsets.symmetric(horizontal: 20), // optional padding
                ),
                onPressed: () {
                  setState(() {
                    isDisplay = false;
                    formAirCollectionSample = true;

                    _containerAir = SFormAirCollectionSample();
                  });
                },
                child: Text('Data collection'),
              ),
            )
          ],
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
              child: Text('AIR: Report',
                style: TextStyle(fontSize: 15,fontWeight: FontWeight.bold),),
            ),
          ],
        ),
        SizedBox(height: 10.0,),
        Row(
          children: [
            Expanded(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  alignment: Alignment.centerLeft, // align text to the left
                  padding: EdgeInsets.symmetric(horizontal: 20), // optional padding
                ),
                onPressed: () {

                },
                child: Text('NPE-1'),
              ),
            )
          ],
        ),
        Row(
          children: [
            Expanded(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  alignment: Alignment.centerLeft, // align text to the left
                  padding: EdgeInsets.symmetric(horizontal: 20), // optional padding
                ),
                onPressed: () {

                },
                child: Text('NPE-2'),
              ),
            )
          ],
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
              child: Text('AIR: Data Log',
                style: TextStyle(fontSize: 15,fontWeight: FontWeight.bold),),
            ),
          ],
        ),
        SizedBox(height: 10,),
        Row(
          children: [
            Expanded(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  alignment: Alignment.centerLeft, // align text to the left
                  padding: EdgeInsets.symmetric(horizontal: 20), // optional padding
                ),
                onPressed: () {
                  setState(() {
                    isDisplay = false;
                    formAirDataLog = true;

                    _containerAir = SFormAirDataLog();
                  });
                },
                child: Text('Data Log Report'),
              ),
            )
          ],
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
              child: Text('AIR: Image Request',
                style: TextStyle(fontSize: 15,fontWeight: FontWeight.bold),),
            ),
          ],
        ),
        SizedBox(height: 10,),
        Row(
          children: [
            Expanded(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  alignment: Alignment.centerLeft, // align text to the left
                  padding: EdgeInsets.symmetric(horizontal: 20), // optional padding
                ),
                onPressed: () {

                },
                child: Text('Upload image request'),
              ),
            )
          ],
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
                _containerAir,
              ]
              else if (formAirInstallSample == true) ... [
                _containerAir,
              ]
              else if (formAirCollectionSample == true) ... [
                _containerAir,
              ]
              else if (formAirDataLog == true) ... [
                _containerAir,
              ]
            ],
          ),
        ),
      ),
      floatingActionButton: isDisplay ? SizedBox() :
      FloatingActionButton(
        backgroundColor: Colors.white,
        tooltip: 'Air-Sampling',
        onPressed: (){
          setState(() {
            isDisplay = true;
            _containerAir = _listMenu();
          });
        },
        child: const Icon(Icons.arrow_back, color: Colors.black, size: 28),
      ),
    );
  }

}

