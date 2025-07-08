import 'package:flutter/material.dart';

class MyHeaderDrawer extends StatefulWidget {
  _MyHeaderDrawer createState() => _MyHeaderDrawer();
}

class _MyHeaderDrawer extends State<MyHeaderDrawer> {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.blue,
      width: double.infinity,
      height: 200,
      padding: EdgeInsets.only(top: 20.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            margin: EdgeInsets.only(bottom: 10),
            height: 70,
            decoration: BoxDecoration(
                shape: BoxShape.circle,
                image: DecorationImage(
                  image: AssetImage('images/icon1.png'),
                )
            ),
          ),
          Text('MMS Application',style: TextStyle(fontSize: 18,fontWeight: FontWeight.bold,color: Colors.white),),
          Text('ScienoTw@gmail.com',style: TextStyle(fontSize: 16,fontWeight: FontWeight.bold,color: Colors.white),)
        ],
      ),
    );
  }

}