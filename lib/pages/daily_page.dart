import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:graphic/graphic.dart';
import 'package:intl/intl.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:test_location_2nd/Permissions/GoogleAccountManager.dart';
import '../Data/DataReader.dart';
import '../navigation.dart';
import 'package:test_location_2nd/pages/SettingPage.dart';
import 'package:test_location_2nd/Permissions/PermissionManager.dart';
import 'package:test_location_2nd/Api/PhotoLibraryApiClient.dart';
import 'package:test_location_2nd/Util/responseParser.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:test_location_2nd/Util/Util.dart';

//TODO : put scrol wheel to select the date.
//TODO : get images from google album

class TestPolarPage extends StatefulWidget {
  DataReader dataReader;

  var googleAccountManager;
  var permissionManager;
  var photoLibraryApiClient;

  TestPolarPage(
      DataReader dataReader,
      GoogleAccountManager googleAccountManager,
      PermissionManager permissionManager,
      photoLibraryClient,
      {Key? key})
      : this.dataReader = dataReader,
        this.googleAccountManager = googleAccountManager,
        this.permissionManager = permissionManager,
        this.photoLibraryApiClient = photoLibraryClient,
        super(key: key);

  @override
  State<TestPolarPage> createState() => _TestPolarPageState(
      dataReader: this.dataReader,
      googleAccountManager: this.googleAccountManager,
      permissionManager: this.permissionManager,
      photoLibraryApiClient: this.photoLibraryApiClient);
}

class _TestPolarPageState extends State<TestPolarPage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  DataReader dataReader;
  GoogleAccountManager googleAccountManager;
  PermissionManager permissionManager;
  PhotosLibraryApiClient photoLibraryApiClient;
  var response;
  _TestPolarPageState(
      {required dataReader,
      required googleAccountManager,
      required permissionManager,
      required photoLibraryApiClient})
      : this.dataReader = dataReader,
        this.googleAccountManager = googleAccountManager,
        this.permissionManager = permissionManager,
        this.photoLibraryApiClient = photoLibraryApiClient;

  int dataIndex = 0;
  List<List<String>> responseResult = [];
  Future readData = Future.delayed(Duration(seconds: 1));

  Future<List<List<List<dynamic>>>> _fetchData() async {
    await Future.delayed(Duration(seconds: 5));
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
        appBar: AppBar(
          title: Center(
            child: Text(
              "         Auto Diary",
              style: TextStyle(color: Colors.black54),
            ),
          ),
          backgroundColor: Colors.white,
          actions: [
            Padding(
                padding: EdgeInsets.only(right: 20.0),
                child: GestureDetector(
                    onTap: () {},
                    child:
                        Icon(Icons.settings_outlined, color: Colors.black54)))
          ],
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
                } else if (snapshot.data.toString() == '[[[Data]]]') {
                  return Center(
                      child: Text('no permission is allowed. \n'
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
                          child: Stack(children: [
                            // Positioned(
                            //   top: 10,
                            //     left : -50,
                            //     child: Container(
                            //   margin: const EdgeInsets.only(top: 10),
                            //   width: 400,
                            //   height: 300,
                            //   child: Chart(
                            //       data: widget.dataReader.dataAll[dataIndex],
                            //       variables: {
                            //         '0': Variable(
                            //           accessor: (List datum) => datum[0] as num,
                            //           scale: LinearScale(
                            //               min: 0, max: 24, tickCount: 5),
                            //         ),
                            //         '1': Variable(
                            //           accessor: (List datum) => datum[1] as num,
                            //         ),
                            //         '2': Variable(
                            //           accessor: (List datum) => datum[2] as num,
                            //         ),
                            //         '3': Variable(
                            //           accessor: (List datum) => datum[3] as num,
                            //         ),
                            //         '4': Variable(
                            //           accessor: (List datum) => datum[4] as num,
                            //         ),
                            //       },
                            //     axes: [
                            //       Defaults.circularAxis
                            //         ..labelMapper = (_, index, total) {
                            //           if (index == total - 1) {
                            //             return null;
                            //           }
                            //           return LabelStyle(
                            //               style: Defaults.textStyle);
                            //         }
                            //         ..label = null,
                            //       // Defaults.radialAxis
                            //       //   ..labelMapper = (_, index, total) {
                            //       //     if (index == total - 1) {
                            //       //       return null;
                            //       //     }
                            //       //     return LabelStyle(
                            //       //         style: Defaults.textStyle);
                            //       //   }
                            //       //   ..label = null,
                            //     ],
                            //       elements: [
                            //         PointElement(
                            //           size: SizeAttr(
                            //               variable: '3', values: [1, 2]),
                            //           color: ColorAttr(
                            //             variable: '3',
                            //             values: Defaults.colors20,
                            //             updaters: {
                            //               'choose': {true: (_) => Colors.red}
                            //             },
                            //           ),
                            //         ),
                            //       ],    coord: PolarCoord(),),
                            // )),
                            Positioned(
                              top: 60,
                              child: Container(
                                margin: const EdgeInsets.only(top: 10),
                                width: 300,
                                height: 200,
                                child: Chart(
                                  data: widget.dataReader.dataAll[dataIndex],
                                  variables: {
                                    '0': Variable(
                                      accessor: (List datum) => datum[0] as num,
                                      scale: LinearScale(
                                          min: 0, max: 24, tickCount: 5),
                                    ),

                                    '3': Variable(
                                      accessor: (List datum) => datum[3] as num,
                                    ),
                                    '1': Variable(
                                      accessor: (List datum) => datum[1] as num,
                                    ),
                                    '2': Variable(
                                      accessor: (List datum) => datum[2] as num,
                                    ),
                                    '4': Variable(
                                      accessor: (List datum) => datum[4] as num,
                                    ),
                                  },
                                  elements: [
                                    PointElement(
                                      size: SizeAttr(
                                          variable: '1', values: [1, 2]),
                                      color: ColorAttr(
                                        variable: '1',
                                        values: Defaults.colors20,
                                        updaters: {
                                          'choose': {true: (_) => Colors.red}
                                        },
                                      ),
                                    ),
                                    // PointElement(
                                    //   size: SizeAttr(variable: '4', values: [1, 3]),
                                    //   color: ColorAttr(
                                    //     variable: '1',
                                    //     values: Defaults.colors10,
                                    //     updaters: {
                                    //       'choose': {true: (_) => Colors.red}
                                    //     },
                                    //   ),
                                    //
                                    // )
                                  ],
                                  axes: [
                                    // Defaults.circularAxis
                                    //   ..labelMapper = (_, index, total) {
                                    //     if (index == total - 1) {
                                    //       return null;
                                    //     }
                                    //     return LabelStyle(
                                    //         style: Defaults.textStyle);
                                    //   }
                                    //   ..label = null,
                                    // Defaults.radialAxis
                                    //   ..labelMapper = (_, index, total) {
                                    //     if (index == total - 1) {
                                    //       return null;
                                    //     }
                                    //     return LabelStyle(
                                    //         style: Defaults.textStyle);
                                    //   }
                                    //   ..label = null,
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
                          ]),
                        ),
                        Center(
                          child: SizedBox(
                              width: 300,
                              height: 100,
                              // child : Text('aaa'),

                              //reference : https://www.youtube.com/watch?v=wnTYKJEJ7f4&t=167s
                              child: ListWheelScrollView.useDelegate(
                                  magnification: 1,
                                  squeeze: 1.8,
                                  physics: FixedExtentScrollPhysics(),
                                  diameterRatio: 0.7,
                                  onSelectedItemChanged: (index) =>
                                      setState(() {
                                        dataIndex = index;
                                        updatePhoto();
                                      }),
                                  itemExtent: 80,
                                  childDelegate: ListWheelChildBuilderDelegate(
                                      builder: (context, index) => Center(
                                              child:
                                            // color : Colors.blue,
                                             Text(
                                                '${dataReader.dates[index]}',
                                                style: TextStyle(fontSize: 20, color: Colors.black54)),
                                          ),
                                      childCount: dataReader.dataAll.length)
                                  // childCount: 20,
                                  )),
                        ),
                        Center(
                            child: SizedBox(
                                width: 500,
                                height: 200,
                                child: responseResult.isEmpty
                                    ? Text('no links')
                                    : ListView.builder(
                                        scrollDirection: Axis.horizontal,
                                        itemBuilder:
                                            (BuildContext context, int index) {
                                          return Image.network(
                                              responseResult[0][index]);
                                        },
                                        itemCount: responseResult[0].length,
                                      )
                                // Image.network(responseResult[0][0],
                                ))
                      ],
                      // )
                    ),
                  ),
                  floatingActionButton: FloatingActionButton(
                    onPressed: (() async {
                      print(permissionManager);
                      String date = dataReader.dates[dataIndex];
                      print(date.substring(4, 6));
                      var response =
                          await photoLibraryApiClient.getPhotosOfDate(
                              date.substring(0, 4),
                              date.substring(4, 6),
                              date.substring(6, 8));
                      responseResult = parseResponse(response);
                      photoLibraryApiClient.writeCache3(
                          responseResult[0], 'links');
                      photoLibraryApiClient.writeCache3(
                          responseResult[1], 'filename');
                      setState(() {});
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

  void updatePhoto() async {
    String date = dataReader.dates[dataIndex];
    // if(response
    print(date.substring(4, 6));
    response = await photoLibraryApiClient.getPhotosOfDate(
        date.substring(0, 4), date.substring(4, 6), date.substring(6, 8));
    responseResult = parseResponse(response);
    photoLibraryApiClient.writeCache3(responseResult[0], 'links');
    photoLibraryApiClient.writeCache3(responseResult[1], 'filename');
    setState(() {});
    print("googleAccount manager : ${googleAccountManager.currentUser}");
    // print(widget.dataReader.dataAll.last);
    // print(widget.dataReader.dates);
    // print(widget.dataReader.dataAll.last.last);
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
