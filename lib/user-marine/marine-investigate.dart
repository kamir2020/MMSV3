import 'package:flutter/material.dart';
import 'investigate/form-investigate.dart';

class MarineInvestigate extends StatefulWidget {
  _MarineInvestigate createState() => _MarineInvestigate();
}

class _MarineInvestigate extends State<MarineInvestigate> {

  bool isDisplay = true;
  bool formSample = false;
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
              child: Text('Investigative Study Sampling',
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

                    _containerMarine = SFormInvestigate();
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
                  isDisplay = false;
                  formSample = true;

                  _containerMarine = SFormInvestigate();
                },
                child: Text('Investigative Study Sampling Records'),
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

                },
                child: Text('Extract Image Investigative Study Sampling'),
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
              else if (formSample == true) ... [
                _containerMarine,
              ]
              else if (formTarball == true) ... [
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

