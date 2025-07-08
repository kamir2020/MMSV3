import 'package:flutter/material.dart';

class UserMain extends StatefulWidget {
  _UserMain createState() => _UserMain();
}

class _UserMain extends State<UserMain> {
  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.center,
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.height,
      padding: EdgeInsets.all(10.0),
      child: Column(
        children: [
          Text('Integrated Environmental Solution',
            style: TextStyle(fontSize: 19,fontWeight: FontWeight.bold),),
          SizedBox(height: 10.0,),
          Text('Water and Air Monitoring System',style: TextStyle(fontSize: 16),),
          Divider(thickness: 1,color: Colors.black,),
          SizedBox(height: 10,),
          Container(
            alignment: Alignment.center,
            width: MediaQuery.of(context).size.width,
            height: 150,
            decoration: BoxDecoration(
                color: Colors.blue[100],
                borderRadius: BorderRadius.circular(10.0)
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircleAvatar(
                        backgroundColor: Colors.white,
                        radius: 40,
                        child: Image.asset("images/marine-1.png",width: 100,height: 100,),
                      ),
                      SizedBox(height: 10,),
                      Center(
                        child: Text('Marine',
                          style: TextStyle(fontSize: 15,fontWeight: FontWeight.bold),),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircleAvatar(
                        backgroundColor: Colors.white,
                        radius: 40,
                        child: Image.asset("images/river-1.png",width: 100,height: 100,),
                      ),
                      SizedBox(height: 10,),
                      Center(
                        child: Text('River',
                          style: TextStyle(fontSize: 15,fontWeight: FontWeight.bold),),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircleAvatar(
                        backgroundColor: Colors.white,
                        radius: 40,
                        child: Image.asset("images/air-1.png",width: 100,height: 100,),
                      ),
                      SizedBox(height: 10,),
                      Center(
                        child: Text('Air',
                          style: TextStyle(fontSize: 15,fontWeight: FontWeight.bold),),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

}