import 'package:test_location_2nd/main.dart';
import 'package:flutter/material.dart';
import 'package:test_location_2nd/SensorLogger.dart';
import 'package:test_location_2nd/DataReader.dart';
import 'package:test_location_2nd/ImageReader.dart';

class SplashScreen extends StatefulWidget {
  var myHomePage;
  SplashScreen({required myHomePage}) {
    this.myHomePage = myHomePage;
    print('splashScreen, contructor');
    print('splashScreen, contructor ${myHomePage.title}');
  }

  void aaaa() {
    print('ccc');
  }

  @override
  _SplashScreenState createState() {
    return _SplashScreenState(myHomePage);
  }
}

class _SplashScreenState extends State<SplashScreen> {
  var _myHomePage;
  _SplashScreenState(myHomePage) {
    _myHomePage = myHomePage;
  }

  @override
  void initState() {
    super.initState();
    _init();
  }

  void _init() async {
    print('aaa');
    //오래걸리는 작업 수행

    _myHomePage.sensorLogger = SensorLogger();
    debugPrint("LoadingPage, sensor logger loading");
    _myHomePage.dataReader = DataReader('20220606');
    debugPrint("LoadingPage, DataReader loading");
    _myHomePage.imageReader = ImageReader('20220606');
    debugPrint("LoadingPage, imageReader loading");
    Navigator.push(
        context, MaterialPageRoute(builder: (context) => MyHomePage()));
    // print('cccc');
    // Future.delayed(const Duration(milliseconds: 15000), () {
    //   print('Hello, world');
    //   Navigator.push(
    //       context, MaterialPageRoute(builder: (context) => MyHomePage()));
    // });

    print('ddd');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            CircularProgressIndicator(
                backgroundColor: Colors.white, strokeWidth: 6),
            SizedBox(height: 20),
            Text('Now loading...',
                style: TextStyle(
                    fontSize: 40,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                    shadows: <Shadow>[
                      Shadow(offset: Offset(4, 4), color: Colors.white10)
                    ],
                    decorationStyle: TextDecorationStyle.solid))
          ],
        ),
      ),
    );
  }
}
