import 'package:flutter/material.dart';

class MarineContinuos extends StatefulWidget {
  _MarineContinuos createState() => _MarineContinuos();
}

class _MarineContinuos extends State<MarineContinuos> {

  bool isDisplay = true;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text('In progress...'),
      ),
    );
  }

}


