import 'package:flutter/material.dart';
// import 'package:image/image.dart' as Image;
import 'package:flutter/foundation.dart';
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
      // home: myHomePage
    );
  }
}

class MyHomePage extends StatefulWidget {
  var title;
  bool isInitializationDone = false;

  MyHomePage({Key? key}) : super(key: key) {
    title = 'test';
  }

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;
  final heatmapChannel = StreamController<Selected?>.broadcast();
  var dataReader;
  var imageReader;
  var sensorLogger;

  _MyHomePageState() {
    this.dataReader = DataReader('20220606');
    this.imageReader = ImageReader('20220606');
    this.sensorLogger = SensorLogger();
  }

  void _incrementCounter() {
    setState(() {
      // sensorLogger.writeCache();
      // sensorLogger.writeAudio();
    });
  }

  //
  Future<List<List<num>>> _getHeatmapData2() {
    return Future<List<List<num>>>.delayed(
        Duration(seconds: 1), () => dataReader.heatmapData2);
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Row(
        children: [
          SizedBox(width: 10),
          Column(
            children: <Widget>[
              FutureBuilder<List<List<num>>>(
                  future: _getHeatmapData2(),
                  builder: (BuildContext context,
                      AsyncSnapshot<List<List<num>>> snapshot) {
                    Widget children;
                    var data = snapshot.data ??
                        [
                          [0, 0, 0],
                          [1, 0, 0],
                          [0, 1, 1],
                          [1, 1, 1]
                        ];
                    if (snapshot.hasData) {
                      if (data.isEmpty) {
                        children = Text("data is empty");
                      } else {
                        // children = Text("AAAAA");
                        debugPrint(
                            "future builder, snapshot, ${snapshot.data}");
                        children = Container(
                          width: 50,
                          height: 1 * 700,
                          child: Chart(
                            padding: (_) => EdgeInsets.zero,
                            data: data,
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
                                    'tap': {
                                      false: (color) => color.withAlpha(70)
                                    }
                                  },
                                ),
                                selectionChannel: heatmapChannel,
                              )
                            ],
                            selections: {'tap': PointSelection()},
                          ),
                        );
                      }
                    } else if (snapshot.hasError) {
                      children = Text("error");
                    } else {
                      children = Text("waiting");
                    }
                    return children;
                  })

              //
            ],
          ),
          Stack(children: [
            SizedBox(height: 700, width: 300),
            ...List.generate((kTimeStamps.length / 2).toInt(), (index1) {
              return Positioned(
                top: (index1 * 58).toDouble(),
                left: 0,
                right: 0,
                bottom: 0,
                child: Container(
                  width: 300,
                  height: 29,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    children: imageReader.filesSortBy2Hour.isEmpty
                        ? [Text('processing')]
                        : List.generate(
                            imageReader.filesSortBy2Hour[index1].length,
                            (index) {
                            return Image.file(
                              imageReader.filesSortBy2Hour[index1][index],
                              height: 50,
                              width: 40,
                            );
                          }),
                  ),
                ),
              );
            })
          ]),
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
