import 'package:flutter/material.dart';

class AirSampling extends StatefulWidget {
  _AirSampling createState() => _AirSampling();
}

class _AirSampling extends State<AirSampling> {

  late String _tide = '',_condition = '',_tarball = '';

  bool _form1 = true;
  bool _form2 = false;
  bool _form3 = false;

  @override
  void initState() {
    super.initState();
  }

  Widget _buildForm1() {
    return Column(
      children: [
        Container(
          height: 50,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15.0),
            color: Colors.yellow,
          ),
          child: Center(
            child: Text('Manual Info',style: TextStyle(fontSize: 20,fontWeight: FontWeight.bold),),
          ),
        ),
        SizedBox(height: 5.0,),
        Row(
          children: [
            Expanded(
              flex: 2,
              child: Text('Station ID'),
            ),
            Expanded(
              flex: 3,
              child: TextFormField(
                decoration: InputDecoration(
                  contentPadding: EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10.0),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(15.0)),
                ),
              ),
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
              child: TextFormField(
                decoration: InputDecoration(
                  contentPadding: EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10.0),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(15.0)),
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 5.0,),
        Container(
          width: MediaQuery.of(context).size.width,
          height: 30,
          alignment: Alignment.centerLeft,
          decoration: BoxDecoration(
            color: Colors.grey[200],
          ),
          child: Text('Installation',style: TextStyle(fontWeight: FontWeight.bold,fontSize: 18),),
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
              child: TextFormField(
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.yellow[100],
                  contentPadding: EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10.0),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(15.0)),
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 5,),
        Row(
          children: [
            Expanded(
              flex: 2,
              child: Text('Time'),
            ),
            Expanded(
              flex: 3,
              child: TextFormField(
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.yellow[100],
                  contentPadding: EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10.0),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(15.0)),
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 5,),
        Row(
          children: [
            Expanded(
              flex: 2,
              child: Text('Weather'),
            ),
            Expanded(
              flex: 3,
              child: TextFormField(
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.yellow[100],
                  contentPadding: EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10.0),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(15.0)),
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 5,),
        Row(
          children: [
            Expanded(
              flex: 2,
              child: Text('Temparature'),
            ),
            Expanded(
              flex: 3,
              child: TextFormField(
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.yellow[100],
                  contentPadding: EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10.0),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(15.0)),
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 5.0,),
        SizedBox(height: 5.0,),
        Container(
          width: MediaQuery.of(context).size.width,
          height: 30,
          alignment: Alignment.centerLeft,
          decoration: BoxDecoration(
            color: Colors.grey[200],
          ),
          child: Text('Collection',style: TextStyle(fontWeight: FontWeight.bold,fontSize: 18),),
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
              child: TextFormField(
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.yellow[100],
                  contentPadding: EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10.0),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(15.0)),
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 5,),
        Row(
          children: [
            Expanded(
              flex: 2,
              child: Text('Time'),
            ),
            Expanded(
              flex: 3,
              child: TextFormField(
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.yellow[100],
                  contentPadding: EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10.0),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(15.0)),
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 5,),
        Row(
          children: [
            Expanded(
              flex: 2,
              child: Text('Weather'),
            ),
            Expanded(
              flex: 3,
              child: TextFormField(
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.yellow[100],
                  contentPadding: EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10.0),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(15.0)),
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 5,),
        Row(
          children: [
            Expanded(
              flex: 2,
              child: Text('Temparature'),
            ),
            Expanded(
              flex: 3,
              child: TextFormField(
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.yellow[100],
                  contentPadding: EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10.0),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(15.0)),
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 5.0,),
        Row(
          children: [
            Expanded(
              flex: 2,
              child: Text(''),
            ),
            Expanded(
              flex: 3,
              child: Row(
                children: [
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _form1 = false;
                        _form2 = true;
                        _form3 = false;
                      });
                    },
                    child: Text('Proceed'),
                  ),
                ],
              ),
            ),
          ],
        )
      ],
    );
  }

  Widget _buildForm2() {
    return Column(
      children: [
        Container(
          width: MediaQuery.of(context).size.width,
          height: 30,
          alignment: Alignment.centerLeft,
          decoration: BoxDecoration(
            color: Colors.grey[200],
          ),
          child: Text('Parameter : PM10',style: TextStyle(fontWeight: FontWeight.bold,fontSize: 18),),
        ),
        SizedBox(height: 5.0,),
        Row(
          children: [
            Expanded(
              flex: 2,
              child: Text('Filter ID'),
            ),
            Expanded(
              flex: 3,
              child: TextFormField(
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.yellow[100],
                  contentPadding: EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10.0),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(15.0)),
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 5,),
        Row(
          children: [
            Expanded(
              flex: 2,
              child: Text('Actual Flow Rate'),
            ),
            Expanded(
              flex: 3,
              child: TextFormField(
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.yellow[100],
                  contentPadding: EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10.0),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(15.0)),
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 5,),
        Row(
          children: [
            Expanded(
              flex: 2,
              child: Text('Total Time'),
            ),
            Expanded(
              flex: 3,
              child: TextFormField(
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.yellow[100],
                  contentPadding: EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10.0),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(15.0)),
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 5,),
        Row(
          children: [
            Expanded(
              flex: 2,
              child: Text('Ambient Temperature'),
            ),
            Expanded(
              flex: 3,
              child: TextFormField(
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.yellow[100],
                  contentPadding: EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10.0),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(15.0)),
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 5,),
        Row(
          children: [
            Expanded(
              flex: 2,
              child: Text('Pressure, Pa (Hg)'),
            ),
            Expanded(
              flex: 3,
              child: TextFormField(
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.yellow[100],
                  contentPadding: EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10.0),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(15.0)),
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 5,),
        Row(
          children: [
            Expanded(
              flex: 2,
              child: Text('Flowrate'),
            ),
            Expanded(
              flex: 3,
              child: TextFormField(
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.yellow[100],
                  contentPadding: EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10.0),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(15.0)),
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 5,),
        Row(
          children: [
            Expanded(
              flex: 2,
              child: Text('Total Air Sampled'),
            ),
            Expanded(
              flex: 3,
              child: TextFormField(
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.yellow[100],
                  contentPadding: EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10.0),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(15.0)),
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 5.0,),
        Container(
          width: MediaQuery.of(context).size.width,
          height: 30,
          alignment: Alignment.centerLeft,
          decoration: BoxDecoration(
            color: Colors.grey[200],
          ),
          child: Text('Parameter : PM2.5',style: TextStyle(fontWeight: FontWeight.bold,fontSize: 18),),
        ),
        SizedBox(height: 5.0,),
        Row(
          children: [
            Expanded(
              flex: 2,
              child: Text('Filter ID'),
            ),
            Expanded(
              flex: 3,
              child: TextFormField(
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.yellow[100],
                  contentPadding: EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10.0),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(15.0)),
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 5,),
        Row(
          children: [
            Expanded(
              flex: 2,
              child: Text('Actual Flow Rate'),
            ),
            Expanded(
              flex: 3,
              child: TextFormField(
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.yellow[100],
                  contentPadding: EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10.0),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(15.0)),
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 5,),
        Row(
          children: [
            Expanded(
              flex: 2,
              child: Text('Total Time'),
            ),
            Expanded(
              flex: 3,
              child: TextFormField(
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.yellow[100],
                  contentPadding: EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10.0),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(15.0)),
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 5,),
        Row(
          children: [
            Expanded(
              flex: 2,
              child: Text('Ambient Temperature'),
            ),
            Expanded(
              flex: 3,
              child: TextFormField(
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.yellow[100],
                  contentPadding: EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10.0),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(15.0)),
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 5,),
        Row(
          children: [
            Expanded(
              flex: 2,
              child: Text('Pressure, Pa (Hg)'),
            ),
            Expanded(
              flex: 3,
              child: TextFormField(
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.yellow[100],
                  contentPadding: EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10.0),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(15.0)),
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 5,),
        Row(
          children: [
            Expanded(
              flex: 2,
              child: Text('Flowrate'),
            ),
            Expanded(
              flex: 3,
              child: TextFormField(
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.yellow[100],
                  contentPadding: EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10.0),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(15.0)),
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 5,),
        Row(
          children: [
            Expanded(
              flex: 2,
              child: Text('Total Air Sampled'),
            ),
            Expanded(
              flex: 3,
              child: TextFormField(
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.yellow[100],
                  contentPadding: EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10.0),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(15.0)),
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 5.0,),
        Row(
          children: [
            Expanded(
              flex: 2,
              child: Text(''),
            ),
            Expanded(
              flex: 3,
              child: Row(
                children: [
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _form1 = false;
                        _form2 = false;
                        _form3 = true;
                      });
                    },
                    child: Text('Proceed'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildForm3() {
    return Column(
      children: [

      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Air Sampling'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(10.0),
          child: Form(
            child: Column(
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
              ],
            ),
          ),
        ),
      ),
    );
  }

}