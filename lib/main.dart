import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:googleapis/shared.dart';
import 'package:test_location_2nd/NoteData.dart';

import 'package:test_location_2nd/SensorLogger.dart';
import 'package:test_location_2nd/NoteLogger.dart';
import 'package:test_location_2nd/DataAnalyzer.dart';
import 'package:test_location_2nd/DataReader.dart';

import 'package:test_location_2nd/daily_page.dart';
import 'package:test_location_2nd/PhotoLibraryApiClient.dart';
import 'package:test_location_2nd/GoogleAccountManager.dart';

import 'SettingPage.dart';
import 'navigation.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  var text = "logging";
  final sensorLogger = SensorLogger();
  final noteLogger = NoteLogger();
  final dataAnalyzer = DataAnalyzer();
  final myTextController = TextEditingController();
  final dataReader = DataReader();
  final googleAccountManager = GoogleAccountManager();

  Future readData = Future.delayed(Duration(seconds : 1));



  Future<List<List<List<dynamic>>>> _fetchData() async{
    await Future.delayed(Duration(seconds : 10));
    return [[['Data']]];
  }

  @override
  void initState(){
    readData = _fetchData();
    super.initState();
      }

  void saveNote() {
    noteLogger.writeCache2(NoteData(DateTime.now(), myTextController.text));
    text = "${DateTime.now()} : note saved!";
    myTextController.clear();
    setState(() {});
  }

  // @override
  // Widget build(BuildContext context){
  //   return MaterialApp(
  //     home :  AndroidSettingsScreen(),
  //     );
  //
  // }


  void onSelected(BuildContext context, int item){
    print(item);
    switch (item){
      case 0 :
        // Navigator.of(context).push(
        //   MaterialPageRoute(builder: (context) => AndroidSettingsScreen()),
        // );
        Navigation.navigateTo(context: context, screen: AndroidSettingsScreen(), style: NavigationRouteStyle.material);
       break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar : AppBar(
          title : Text("test application"),
          actions : [
            PopupMenuButton<int> (
              onSelected: (item) => onSelected(context, item),
              itemBuilder: (context) => [
                PopupMenuItem(
                  value : 0,
                  child : Text("Settings"),
                )
              ],
            )
          ]
        ),
        body: FutureBuilder(
            future: readData,
            builder: (BuildContext context, AsyncSnapshot snapshot) {
              print("snapshot : ${snapshot.data}");

              if (snapshot.hasData == false) {
                return Scaffold(

                  backgroundColor: Colors.white,
                  body: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircularProgressIndicator(
                          backgroundColor: Colors.blue,
                          color : Colors.orange,
                          strokeWidth: 4.0,
                        ),

                      ],
                    ),
                  ),
                );
              } else if (snapshot.hasError) {
                return Text('error');
              } else {
                print("snap shot data : ${snapshot.data}");
                print("snap shot data : ${snapshot.data.isEmpty}");
                if (snapshot.data.isEmpty) {
                  // sensorLogger.forceWrite();
                  return Center(child: Text('no data found'));
                }
                return TestPolarPage(dataReader);
              }
            }),
      ),
    );
  }
}
