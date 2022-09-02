import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:graphic/graphic.dart';
import 'dart:async';

import 'package:test_location_2nd/DataReader.dart';
import 'package:test_location_2nd/ImageReader.dart';
import 'package:test_location_2nd/Util.dart';

import 'package:intl/intl.dart';

class DayPage extends StatefulWidget {
  var title;
  bool isInitializationDone = false;


  DayPage({Key? key}) : super(key: key) {
    debugPrint("daypage constructed");
    title = 'test';
    // return _dayPageInstance;
  }
  // final _dayPageInstance = DayPage._internal();
  // factory DayPage() =>_instance;

  // DayPage._internal();


  @override
  State<DayPage> createState() => _DayPageState();
}

class _DayPageState extends State<DayPage> with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  int _counter = 0;
  final heatmapChannel = StreamController<Selected?>.broadcast();
  var dataReader;
  var imageReader;

  String _selectedIndex = "20220605";

  _DayPageState() {
    debugPrint("dayPage constructed");
    this.dataReader = DataReader(_selectedIndex);
    this.imageReader = ImageReader(_selectedIndex);
  }
  @override
  void dispose() {
    debugPrint("dayPage destructed");
    super.dispose();
  }

  void _incrementCounter() {
    setState(() {});
  }

  Future<List<List<num>>> _getHeatmapData2() {
    debugPrint("daypage, _getHeatmapData is ongoing");
    return Future<List<List<num>>>.delayed(
        Duration(seconds: 10), () => dataReader.heatmapData2);
  }

  void _moveToSelectedDate(date) {
    setState(() {
      _selectedIndex = date;
      dataReader.readData(_selectedIndex);
      imageReader.updateState(_selectedIndex);
    });
  }

  @override
  Widget build(BuildContext context) {
    final arguments = (ModalRoute.of(context)?.settings.arguments) as Map;
    var date = arguments.toString().split(' ')[1].substring(0, 8);
    _selectedIndex = date;
    _moveToSelectedDate(date);

    return new WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        appBar: AppBar(
            title: Text(widget.title),
            leading : IconButton(
                icon: new Icon(Icons.ac_unit),
                onPressed:(){
                  // Navigator.of(context).pop();
                  Navigator.pushNamed(context, '/calendar',
                  );
                }
            )
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
                                      const Color(0xffc5553d),
                                      const Color(0xff00503d)
                                    ],
                                    updaters: {
                                      'tap': {
                                        false: (color) => color.withAlpha(70)
                                      },
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
              ...List.generate(kTimeStamps2hour.length.toInt(), (index1) {
                debugPrint("stack, ${imageReader.filesSortBy2Hour}");
                debugPrint("stack, ${imageReader.filesSortBy2Hour}");

                return Positioned(
                  top: (index1 * 58).toDouble(),
                  left: 0,
                  right: 0,
                  // bottom: (index1 * 58 + 100).toDouble(),
                  child: Container(
                    width: 300,
                    height: 100,
                    child: ListView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      scrollDirection: Axis.horizontal,
                      children: imageReader.filesSortBy2Hour.isEmpty
                          ? [Text('processing')]
                          : List.generate(
                          imageReader.filesSortBy2Hour[index1].length,
                              (index) {
                            return Image.file(
                              imageReader.filesSortBy2Hour[index1][index],
                              height: 100,
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

        bottomNavigationBar: Row(
          children: [
            Material(
              color: const Color(0xffff8989),
              child: InkWell(
                onTap: () {
                  var parsedDate = DateTime.parse(_selectedIndex);
                  _moveToSelectedDate(DateFormat('yyyyMMdd')
                      .format(parsedDate.subtract(Duration(days: 1))));
                },
                child: const SizedBox(
                  height: kToolbarHeight,
                  width: 200,
                  child: Center(
                    child: Text(
                      'previous',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            Expanded(
              child: Material(
                color: const Color(0xffff8906),
                child: InkWell(
                  onTap: () {
                    var parsedDate = DateTime.parse(_selectedIndex);
                    _moveToSelectedDate(DateFormat('yyyyMMdd')
                        .format(parsedDate.add(Duration(days: 1))));
                  },
                  child: const SizedBox(
                    height: kToolbarHeight,
                    width: double.infinity,
                    child: Center(
                      child: Text(
                        "next",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),

        floatingActionButton: FloatingActionButton(
          onPressed: _incrementCounter,
          tooltip: 'Increment',
          child: const Icon(Icons.add),
        ), // This trailing comma makes auto-formatting nicer for build methods.
      ),
    );
  }

  void _onTap() {
    var parsedDate = DateTime.parse(_selectedIndex);
    setState(() {});
  }
}
