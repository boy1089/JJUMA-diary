import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:graphic/graphic.dart';
import 'package:intl/intl.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:test_location_2nd/GoogleAccountManager.dart';
import '../DataReader.dart';
import 'navigation.dart';
import 'package:test_location_2nd/SettingPage.dart';
import 'package:test_location_2nd/PermissionManager.dart';

//TODO : put scrol wheel to select the date.
//TODO : get images from google album

class TestPolarPage extends StatefulWidget {
  DataReader dataReader;

  var googleAccountManager;
  var permissionManager;

  TestPolarPage(
      DataReader dataReader,
      GoogleAccountManager googleAccountManager,
      PermissionManager permissionManager,
      {Key? key})
      : this.dataReader = dataReader,
        this.googleAccountManager = googleAccountManager,
        this.permissionManager = permissionManager,
        super(key: key);

  @override
  State<TestPolarPage> createState() => _TestPolarPageState(
      dataReader: this.dataReader,
      googleAccountManager: this.googleAccountManager,
      permissionManager: this.permissionManager);
}

class _TestPolarPageState extends State<TestPolarPage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  DataReader dataReader;
  GoogleAccountManager googleAccountManager;
  PermissionManager permissionManager;
  _TestPolarPageState(
      {required dataReader,
      required googleAccountManager,
      required permissionManager})
      : this.dataReader = dataReader,
        this.googleAccountManager = googleAccountManager,
        this.permissionManager = permissionManager;

  int dataIndex = 0;

  Future readData = Future.delayed(Duration(seconds: 1));

  Future<List<List<List<dynamic>>>> _fetchData() async {
    await Future.delayed(Duration(seconds: 10));
    return dataReader.readFiles();
    // return [
    //   [
    //     ['Data']
    //   ]
    // ];
  }

  @override
  void initState() {
    readData = _fetchData();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: Text("test application"), actions: [
          PopupMenuButton<int>(
            onSelected: (item) => onSelected(context, item),
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 0,
                child: Text("Settings"),
              )
            ],
          )
        ]),
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
                          color: Colors.orange,
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
                } else if (snapshot.data.toString() =='[[[Data]]]'){
                  return Center(child: Text('no permission is allowed. \n'
                  'please restart the application and allow the permissions. '));
                }
                return Scaffold(
                  key: _scaffoldKey,

                  backgroundColor: Colors.white,
                  body: Container(
                    height: 800,
                    width: 500,
                    child: Column(
                      // mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.center,

                      children: <Widget>[
                        SizedBox(
                          width: 300,
                          height: 300,
                          child: Container(
                            margin: const EdgeInsets.only(top: 10),
                            width: 400,
                            height: 300,
                            child: Chart(
                              data: widget.dataReader.dataAll[dataIndex],
                              variables: {
                                '0': Variable(
                                  accessor: (List datum) => datum[0] as num,
                                  scale: LinearScale(
                                      min: 0, max: 24, tickCount: 5),
                                ),
                                '1': Variable(
                                  accessor: (List datum) => datum[1] as num,
                                ),
                                '2': Variable(
                                  accessor: (List datum) => datum[2] as num,
                                ),
                                '3': Variable(
                                  accessor: (List datum) => datum[3] as num,
                                ),
                                '4': Variable(
                                  accessor: (List datum) => datum[4] as num,
                                ),
                              },
                              elements: [
                                PointElement(
                                  size: SizeAttr(variable: '3', values: [1, 2]),
                                  color: ColorAttr(
                                    variable: '3',
                                    values: Defaults.colors20,
                                    updaters: {
                                      'choose': {true: (_) => Colors.red}
                                    },
                                  ),
                                  // shape: ShapeAttr(variable: '3', values: [
                                  //   CircleShape(hollow: true),
                                  //   SquareShape(hollow: true),
                                  // ]),
                                )
                              ],
                              axes: [
                                Defaults.circularAxis
                                  ..labelMapper = (_, index, total) {
                                    if (index == total - 1) {
                                      return null;
                                    }
                                    return LabelStyle(
                                        style: Defaults.textStyle);
                                  }
                                  ..label = null,
                                Defaults.radialAxis
                                  ..labelMapper = (_, index, total) {
                                    if (index == total - 1) {
                                      return null;
                                    }
                                    return LabelStyle(
                                        style: Defaults.textStyle);
                                  }
                                  ..label = null,
                              ],
                              coord: PolarCoord(),
                              selections: {
                                'choose': PointSelection(toggle: true)
                              },
                              tooltip: TooltipGuide(
                                anchor: (_) => Offset.zero,
                                align: Alignment.bottomRight,
                                multiTuples: true,
                              ),
                            ),
                          ),
                        ),
                        Center(
                          child: SizedBox(
                            width: 300,
                            height: 100,
                            // child : Text('aaa'),

                            //reference : https://www.youtube.com/watch?v=wnTYKJEJ7f4&t=167s
                            child: ListWheelScrollView.useDelegate(
                                magnification: 1,
                                physics: FixedExtentScrollPhysics(),
                                diameterRatio: 0.2,
                                onSelectedItemChanged: (index) => setState(() {
                                      dataIndex = index;
                                    }),
                                itemExtent: 80,
                                childDelegate: ListWheelChildBuilderDelegate(
                                    builder: (context, index) => Container(
                                          child: Center(
                                              child: Text(
                                                  '${dataReader.dates[index]}')),
                                        ),
                                    childCount: dataReader.dataAll.length
                                    // childCount: 20,
                                    )),
                          ),
                        )
                      ],
                      // )
                    ),
                  ),
                  floatingActionButton: FloatingActionButton(
                    onPressed: (() {
                      print(permissionManager);
                      print(
                          "googleAccount manager : ${googleAccountManager.currentUser}");
                      // print(widget.dataReader.dataAll.last);
                      // print(widget.dataReader.dates);
                      // print(widget.dataReader.dataAll.last.last);
                    }),
                  ),
                );
              }
            }));
  }

  void onSelected(BuildContext context, int item) {
    print(item);
    switch (item) {
      case 0:
        // Navigator.of(context).push(
        //   MaterialPageRoute(builder: (context) => AndroidSettingsScreen()),
        // );
        Navigation.navigateTo(
            context: context,
            screen:
                AndroidSettingsScreen(googleAccountManager, permissionManager),
            style: NavigationRouteStyle.material);
        break;
    }
  }
}
