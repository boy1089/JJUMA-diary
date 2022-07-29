import 'package:flutter/material.dart';
import 'package:location/location.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
// import 'package:image/image.dart' as Image;
import 'package:flutter/foundation.dart';
import 'package:record/record.dart';
import 'package:flutter_sensors/flutter_sensors.dart';
import 'package:graphic/graphic.dart';
import 'dart:async';
import 'package:df/df.dart';

import 'package:flutter_file_manager/flutter_file_manager.dart';
import 'package:test_location_2nd/SensorLogger.dart';
import 'package:test_location_2nd/DataReader.dart';
import 'package:test_location_2nd/ImageReader.dart';
import 'package:test_location_2nd/Util.dart';
import 'package:test_location_2nd/LoadingPage.dart';

//TODO : finalize calendar view, photo view
//TODO : make application working. - try future builder
//TODO :

//TODO : manage audio files.

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  MyApp({Key? key}) : super(key: key);

  final myHomePage = MyHomePage();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        // initialRoute: '/loading',
        initialRoute: '/home',

        routes: {
          '/home': (context) => MyHomePage(),
          // '/loading': (context) => SplashScreen(myHomePage: myHomePage),
          // '/loading' : (context) => SplashScreen(),
        },
        onGenerateRoute: (routeSettings) {
          // if (routeSettings.name == '/loading') {
          //   final args = routeSettings.arguments;
          //   return MaterialPageRoute(builder: (context) {
          //     return SplashScreen(myHomePage: myHomePage);
          //     // return SplashScreen();
          //   });
          // }
          if (routeSettings.name == '/home') {
            final args = routeSettings.arguments;
            return MaterialPageRoute(builder: (context) {
              return myHomePage;
              // return SplashScreen();
            });
          }
        },
        title: 'Flutter Demo',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: myHomePage);
  }
}

class MyHomePage extends StatefulWidget {
  var sensorLogger;
  var dataReader;
  var imageReader;
  var title;
  bool isInitializationDone = false;

  MyHomePage({Key? key}) : super(key: key) {
    title = 'test';
    sensorLogger = SensorLogger();
    dataReader = DataReader('20220606');
    imageReader = ImageReader('20220606');
  }

  @override
  State<MyHomePage> createState() =>
      _MyHomePageState(dataReader, imageReader, sensorLogger);
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;
  final heatmapChannel = StreamController<Selected?>.broadcast();
  var dataReader;
  var imageReader;
  var sensorLogger;

  _MyHomePageState(dataReader, imageReader, sensorLogger) {
    this.dataReader = dataReader;
    this.imageReader = imageReader;
    this.sensorLogger = sensorLogger;
  }

  void _incrementCounter() {
    setState(() {
      // dataReader.readData('20220721');
      // print(dataReader.heatmapData2);
      sensorLogger.writeCache();
      sensorLogger.writeAudio();

      // print("findTimestamp : ${dataReader.findIndicesOf('21')}");
    });
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, fo
    // print("building widget : $heatmapData2");
    List<List<num>> heatmapData3 = [];
    print("building widget, ${dataReader.heatmapData2}");
    setState(() {
      heatmapData3 = dataReader.heatmapData2;
    });
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Row(
        children: [
          SizedBox(width: 10),
          Column(
            children: <Widget>[
              Container(
                // margin: const EdgeInsets.only(top: 10),
                width: 50,
                height: 1 * 700,
                child: heatmapData3.isEmpty
                    ? Text("processing files, ${heatmapData3}")
                    : Chart(
                        padding: (_) => EdgeInsets.zero,
                        data: heatmapData3,
                        // data: heatmapData,

                        variables: {
                          'name': Variable(
                            accessor: (List datum) => datum[0].toString(),
                          ),
                          'day': Variable(
                            accessor: (List datum) => datum[1].toString(),
                          ),
                          'sales': Variable(
                            accessor: (List datum) => datum[2] as num,
                          ),
                        },
                        elements: [
                          PolygonElement(
                            color: ColorAttr(
                              variable: 'sales',
                              values: [
                                const Color(0xffbae7af),
                                const Color(0xff1890af),
                                const Color(0xffc5553d)
                              ],
                              updaters: {
                                'tap': {false: (color) => color.withAlpha(70)}
                              },
                            ),
                            selectionChannel: heatmapChannel,
                          )
                        ],
                        selections: {'tap': PointSelection()},
                      ),
              ),
            ],
          ),

          Stack(children: [
            SizedBox(height: 700, width: 300),
            ...List.generate(kTimeStamps.length, (index1) {
              return Positioned(
                top: (index1 * 29).toDouble(),
                left: 0,
                right: 0,
                bottom: 0,
                child: Container(
                  width: 300,
                  height: 29,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    children: imageReader.filesSortByHour == []
                        ? [Text('processing')]
                        : List.generate(
                            imageReader.filesSortByHour[index1].length,
                            (index) {
                            return Image.file(
                              imageReader.filesSortByHour[index1][index],
                              height: 50,
                              width: 40,
                            );
                          }),
                  ),
                ),
              );
            })
          ]),
          // Column(
          //     children: List.generate(kTimeStamps.length, (index1){
          //       // debugPrint(imageReader.filesSortByHour[0]);
          //   return Container(
          //     width: 350,
          //     height: 29,
          //     child: ListView(
          //       scrollDirection: Axis.horizontal,
          //       children: imageReader.filesSortByHour == []
          //         ? [Text('processing')]
          //         :List.generate(imageReader.filesSortByHour[index1].length, (index) {
          //         return Image.file(
          //           imageReader.filesSortByHour[index1][index],
          //           height: 29,
          //           width: 29,
          //         );
          //       }),
          //     ),
          //   );
          // }))
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
