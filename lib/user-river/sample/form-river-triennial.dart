import 'package:flutter/material.dart';

class SFormRiverSample extends StatefulWidget {
  _SFormRiverSample createState() => _SFormRiverSample();
}

class _SFormRiverSample extends State<SFormRiverSample> {

  late String _type = '',_state = '',_category = '';
  late String _weather = '',_tide = '',_condition = '',_tarball = '';

  bool _form1 = true;
  bool _form2 = false;
  bool _form3 = false;
  bool _form4 = false;

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
            child: Text('Information Details',style: TextStyle(fontSize: 20,fontWeight: FontWeight.bold),),
          ),
        ),
        SizedBox(height: 5.0,),
        Row(
          children: [
            Expanded(
              flex: 2,
              child: Text('Name'),
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
              child: Text('2nd Sampler'),
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
              child: Text('Type'),
            ),
            Expanded(
              flex: 3,
              child: DropdownButtonFormField(
                decoration: InputDecoration(
                  contentPadding: EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10.0),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(15.0)),
                ),
                value: _type.isNotEmpty ? _type : null,
                items: <String>['Schedule', 'Triennial']
                    .map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _type = value.toString();
                  });
                },
                validator: (value) =>
                value!.isEmpty ? 'type is required' : null,
              ),
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
              child: DropdownButtonFormField(
                decoration: InputDecoration(
                  contentPadding: EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10.0),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(15.0)),
                ),
                value: _state.isNotEmpty ? _state : null,
                items: <String>['Kuala Lumpur', 'Pahang']
                    .map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _state = value.toString();
                  });
                },
                validator: (value) =>
                value!.isEmpty ? 'state is required' : null,
              ),
            ),
          ],
        ),
        SizedBox(height: 5.0,),
        Row(
          children: [
            Expanded(
              flex: 2,
              child: Text('Basin'),
            ),
            Expanded(
              flex: 3,
              child: DropdownButtonFormField(
                decoration: InputDecoration(
                  contentPadding: EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10.0),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(15.0)),
                ),
                value: _category.isNotEmpty ? _category : null,
                items: <String>['Estuary', 'Island']
                    .map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _category = value.toString();
                  });
                },
                validator: (value) =>
                value!.isEmpty ? 'category is required' : null,
              ),
            ),
          ],
        ),
        SizedBox(
          height: 5,
        ),
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
                  filled: true,
                  fillColor: Colors.yellow[100],
                  contentPadding: EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10.0),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(15.0)),
                ),
              ),
            ),
          ],
        ),
        SizedBox(
          height: 5,
        ),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 2,
              child: Text('Location'),
            ),
            Expanded(
              flex: 3,
              child: Column(
                children: [
                  TextFormField(
                    decoration: InputDecoration(
                      hintText: 'Latitude',
                      contentPadding: EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10.0),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(15.0)),
                    ),
                  ),
                  SizedBox(height: 5.0,),
                  TextFormField(
                    decoration: InputDecoration(
                      hintText: 'Longitude',
                      contentPadding: EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10.0),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(15.0)),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        SizedBox(
          height: 5.0,
        ),
        SizedBox(
          height: 5,
        ),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 2,
              child: Text('Current location'),
            ),
            Expanded(
              flex: 3,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextFormField(
                    decoration: InputDecoration(
                      hintText: 'Latitude',
                      filled: true,
                      fillColor: Colors.yellow[100],
                      contentPadding: EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10.0),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(15.0)),
                    ),
                  ),
                  SizedBox(height: 5.0,),
                  TextFormField(
                    decoration: InputDecoration(
                      hintText: 'Longitude',
                      filled: true,
                      fillColor: Colors.yellow[100],
                      contentPadding: EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10.0),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(15.0)),
                    ),
                  ),
                  TextButton(
                    onPressed: () {

                    },
                    child: Text('Get location'),
                  ),
                ],
              ),
            ),
          ],
        ),
        SizedBox(height: 5.0,),
        SizedBox(height: 5.0,),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 2,
              child: Text('Barcode'),
            ),
            Expanded(
                flex: 3,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextFormField(
                      decoration: InputDecoration(
                        contentPadding: EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10.0),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(15.0)),
                      ),
                    ),
                    TextButton(
                      onPressed: () {

                      },
                      child: Text('Scan barcode'),
                    ),
                  ],
                )
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
                        _form4 = false;
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
              child: Text('Weather'),
            ),
            Expanded(
              flex: 3,
              child: DropdownButtonFormField(
                decoration: InputDecoration(
                  contentPadding: EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10.0),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(15.0)),
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
                validator: (value) =>
                value!.isEmpty ? 'state is required' : null,
              ),
            ),
          ],
        ),
        SizedBox(height: 5,),
        Row(
          children: [
            Expanded(
              child: ElevatedButton(
                onPressed: () {

                },
                child: Text('Take a photo'),
              ),
            ),
          ],
        ),
        SizedBox(height: 5,),
        Row(
          children: [
            Expanded(
              flex: 2,
              child: Text('Event remarks'),
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
              child: Text('Lab remarks'),
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
                        _form4 = false;
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

  Widget _buildForm3() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: 5.0,),
        Container(
          width: MediaQuery.of(context).size.width,
          height: 30,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: Colors.grey[200],
          ),
          child: Text('Station Info',style: TextStyle(fontWeight: FontWeight.bold,fontSize: 18),),
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
              child: DropdownButtonFormField(
                decoration: InputDecoration(
                  contentPadding: EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10.0),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(5.0)),
                ),
                value: _type.isNotEmpty ? _type : null,
                items: <String>['Schedule', 'Triennial']
                    .map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _type = value.toString();
                  });
                },
                validator: (value) =>
                value!.isEmpty ? 'type is required' : null,
              ),
            ),
          ],
        ),
        SizedBox(height: 5.0,),
        Row(
          children: [
            Expanded(
              flex: 2,
              child: Text('Latitude/Longitude'),
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
        SizedBox(height: 10.0,),
        Container(
          height: 50,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15.0),
            color: Colors.yellow,
          ),
          child: Center(
            child: Text('Data capture',style: TextStyle(fontSize: 20,fontWeight: FontWeight.bold),),
          ),
        ),
        SizedBox(height: 5.0,),
        Row(
          children: [
            Expanded(
              child: TextButton(
                onPressed: () {

                },
                child: Text('COMMUNICATE VIA SERIAL',textAlign: TextAlign.center,),
              ),
            ),
            SizedBox(width: 10.0,),
            Expanded(
              child: TextButton(
                onPressed: () {

                },
                child: Text('COMMUNICATE VIA BLUETOOTH',textAlign: TextAlign.center,),
              ),
            ),
          ],
        ),
        SizedBox(height: 5.0,),
        Row(
          children: [
            Expanded(
              child: ElevatedButton(
                onPressed: () {

                },
                child: Text('Start Reading'),
              ),
            ),
          ],
        ),
        SizedBox(height: 5.0,),
        Row(
          children: [
            Expanded(
              flex: 2,
              child: Text('Sonde ID'),
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
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: Colors.grey[200],
          ),
          child: Text('Parameters',style: TextStyle(fontWeight: FontWeight.bold,fontSize: 18),),
        ),
        SizedBox(height: 5.0,),
        Row(
          children: [
            Expanded(
              flex: 2,
              child: Text('Oxygen concentration'),
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
              child: Text('Oxygen saturation'),
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
              child: Text('pH'),
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
              child: Text('Salinity'),
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
              child: Text('Temperature'),
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
              child: Text('Turbidity'),
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
              child: Text('Conductivity'),
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
              child: Text('Total Dissolve Solid'),
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
              child: Text('Total Suspended Solid'),
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
              child: Text('Battery status'),
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
                        _form3 = false;
                        _form4 = true;
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

  Widget _buildForm4() {
    return Column(
      children: [
        Container(
          height: 50,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15.0),
            color: Colors.yellow,
          ),
          child: Center(
            child: Text('Report summary',style: TextStyle(fontSize: 20,fontWeight: FontWeight.bold),),
          ),
        ),
        SizedBox(height: 5.0,),
        Row(
          children: [
            Expanded(
              flex: 2,
              child: Text('Report'),
            ),
            Expanded(
              flex: 3,
              child: Text('343242332222'),
            ),
          ],
        ),
        SizedBox(height: 5.0,),
        Row(
          children: [
            Expanded(
              flex: 2,
              child: Text('Sampler Name'),
            ),
            Expanded(
              flex: 3,
              child: Text('Ahmad Sazali'),
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
              child: Text('Kamal Yahya'),
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
              child: Text(''),
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
              child: Text(''),
            ),
          ],
        ),
        SizedBox(height: 5.0,),
        Row(
          children: [
            Expanded(
              flex: 2,
              child: Text('Samppling type'),
            ),
            Expanded(
              flex: 3,
              child: Text(''),
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
              child: Text(''),
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
              child: Text(''),
            ),
          ],
        ),
        SizedBox(height: 5.0,),
        Row(
          children: [
            Expanded(
              flex: 2,
              child: Text('Category'),
            ),
            Expanded(
              flex: 3,
              child: Text(''),
            ),
          ],
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
              child: Text(''),
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
              child: Text(''),
            ),
          ],
        ),
        SizedBox(height: 5.0,),
        Row(
          children: [
            Expanded(
              flex: 2,
              child: Text('Current location'),
            ),
            Expanded(
              flex: 3,
              child: Text(''),
            ),
          ],
        ),
        SizedBox(height: 5.0,),
        Row(
          children: [
            Expanded(
              flex: 2,
              child: Text('Barcode'),
            ),
            Expanded(
              flex: 3,
              child: Text(''),
            ),
          ],
        ),
        SizedBox(height: 5.0,),
        Container(
          width: MediaQuery.of(context).size.width,
          height: 30,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: Colors.grey[200],
          ),
          child: Text('Parameters',style: TextStyle(fontWeight: FontWeight.bold,fontSize: 18),),
        ),
        SizedBox(height: 5.0,),
        Row(
          children: [
            Expanded(
              flex: 2,
              child: Text('Oxygen concentration'),
            ),
            Expanded(
              flex: 3,
              child: Text(''),
            ),
          ],
        ),
        SizedBox(height: 5.0,),
        Row(
          children: [
            Expanded(
              flex: 2,
              child: Text('Oxygen saturation'),
            ),
            Expanded(
              flex: 3,
              child: Text(''),
            ),
          ],
        ),
        SizedBox(height: 5.0,),
        Row(
          children: [
            Expanded(
              flex: 2,
              child: Text('pH'),
            ),
            Expanded(
              flex: 3,
              child: Text(''),
            ),
          ],
        ),
        SizedBox(height: 5.0,),
        Row(
          children: [
            Expanded(
              flex: 2,
              child: Text('Salinity'),
            ),
            Expanded(
              flex: 3,
              child: Text(''),
            ),
          ],
        ),
        SizedBox(height: 5.0,),
        Row(
          children: [
            Expanded(
              flex: 2,
              child: Text('Temparature'),
            ),
            Expanded(
              flex: 3,
              child: Text(''),
            ),
          ],
        ),
        SizedBox(height: 5.0,),
        Row(
          children: [
            Expanded(
              flex: 2,
              child: Text('Tubidity'),
            ),
            Expanded(
              flex: 3,
              child: Text(''),
            ),
          ],
        ),
        SizedBox(height: 5.0,),
        Row(
          children: [
            Expanded(
              flex: 2,
              child: Text('EC'),
            ),
            Expanded(
              flex: 3,
              child: Text(''),
            ),
          ],
        ),
        SizedBox(height: 5.0,),
        Row(
          children: [
            Expanded(
              flex: 2,
              child: Text('Battery status'),
            ),
            Expanded(
              flex: 3,
              child: Text(''),
            ),
          ],
        ),
        SizedBox(height: 5.0,),
        Row(
          children: [
            Expanded(
              flex: 2,
              child: Text('TDS'),
            ),
            Expanded(
              flex: 3,
              child: Text(''),
            ),
          ],
        ),
        SizedBox(height: 5.0,),
        Row(
          children: [
            Expanded(
              flex: 2,
              child: Text('TSS'),
            ),
            Expanded(
              flex: 3,
              child: Text(''),
            ),
          ],
        ),
        SizedBox(height: 5.0,),
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _form1 = false;
                  _form2 = false;
                  _form3 = false;
                  _form4 = false;
                });
              },
              child: Text('Cancel'),
            ),
            SizedBox(width: 5.0,),
            ElevatedButton(
              onPressed: () {
                setState(() {

                });
              },
              child: Text('Submit'),
            ),
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
        Text('River: Triennial Sampling',style: TextStyle(fontSize: 18,fontWeight: FontWeight.bold),),
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
          else if (_form4 == true) ... [
              _buildForm4(),
            ]
      ],
    );
  }

}