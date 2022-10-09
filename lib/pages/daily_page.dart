import 'package:flutter/material.dart';
import 'package:graphic/graphic.dart';
import 'package:test_location_2nd/Permissions/GoogleAccountManager.dart';
import '../Data/DataReader.dart';
import '../navigation.dart';
import 'package:test_location_2nd/pages/SettingPage.dart';
import 'package:test_location_2nd/Permissions/PermissionManager.dart';
import 'package:test_location_2nd/Api/PhotoLibraryApiClient.dart';
import 'package:test_location_2nd/Util/responseParser.dart';

//TODO : put scroll wheel to select the date.
//TODO : get images from google album

class TestPolarPage extends StatefulWidget {
  DataReader dataReader;

  GoogleAccountManager googleAccountManager;
  PermissionManager permissionManager;
  PhotosLibraryApiClient photoLibraryApiClient;

  TestPolarPage(this.dataReader, this.googleAccountManager,
      this.permissionManager, this.photoLibraryApiClient,
      {Key? key})
      : super(key: key);

  @override
  State<TestPolarPage> createState() => _TestPolarPageState();
}

class _TestPolarPageState extends State<TestPolarPage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  // DataReader dataReader = dataReader;
  var response;
  late DataReader dataReader;
  late GoogleAccountManager googleAccountManager;
  late PermissionManager permissionManager;
  late PhotosLibraryApiClient photoLibraryApiClient;

  int dataIndex = 0;
  List<List<String>> responseResult = [];
  Future readData = Future.delayed(const Duration(seconds: 1));

  @override
  void initState() {
    readData = _fetchData();
    super.initState();
    dataReader = widget.dataReader;
    googleAccountManager = widget.googleAccountManager;
    permissionManager = widget.permissionManager;
    photoLibraryApiClient = widget.photoLibraryApiClient;
  }

  Future<List<List<List<dynamic>>>> _fetchData() async {
    await Future.delayed(const Duration(seconds: 5));
    return dataReader.readFiles();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Center(
            child: Text(
              "         Auto Diary",
              style: TextStyle(color: Colors.black54),
            ),
          ),
          backgroundColor: Colors.white,
          actions: [
            Padding(
                padding: const EdgeInsets.only(right: 20.0),
                child: GestureDetector(
                    onTap: () {},
                    child: const Icon(Icons.settings_outlined,
                        color: Colors.black54)))
          ],
        ),
        body: FutureBuilder(
            future: readData,
            builder: (BuildContext context, AsyncSnapshot snapshot) {
              debugPrint("snapshot : ${snapshot.data}");

              if (snapshot.hasData == false) {
                return Scaffold(
                  backgroundColor: Colors.white,
                  body: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
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
                return const Text('error');
              } else {
                debugPrint("snap shot data : ${snapshot.data}");
                debugPrint("snap shot data : ${snapshot.data.isEmpty}");
                if (snapshot.data.isEmpty) {
                  // sensorLogger.forceWrite();
                  return const Center(child: Text('no data found'));
                } else if (snapshot.data.toString() == '[[[Data]]]') {
                  return const Center(
                      child: Text('no permission is allowed. \n'
                          'please restart the application and allow the permissions. '));
                }
                return Scaffold(
                  key: _scaffoldKey,
                  backgroundColor: Colors.white,
                  body: SizedBox(
                    height: 800,
                    width: 500,
                    child: Column(
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
                                  axes: const [
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
                                  physics: const FixedExtentScrollPhysics(),
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
                                                Text(dataReader.dates[index],
                                                    style: const TextStyle(
                                                        fontSize: 20,
                                                        color: Colors.black54)),
                                          ),
                                      childCount: dataReader.dataAll.length)
                                  )),
                        ),
                        Center(
                            child: SizedBox(
                                width: 500,
                                height: 200,
                                child: responseResult.isEmpty
                                    ? const Text('no links')
                                    : ListView.builder(
                                        scrollDirection: Axis.horizontal,
                                        itemBuilder:
                                            (BuildContext context, int index) {
                                          return Image.network(
                                              responseResult[0][index]);
                                        },
                                        itemCount: responseResult[0].length,
                                      )
                                ))
                      ],
                    ),
                  ),
                  floatingActionButton: FloatingActionButton(
                    onPressed: (() async {
                      debugPrint(permissionManager.toString());
                      String date = dataReader.dates[dataIndex];
                      debugPrint(date.substring(4, 6));
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
                      debugPrint(
                          "googleAccount manager : ${googleAccountManager.currentUser}");
                    }),
                  ),
                );
              }
            }));
  }

  void updatePhoto() async {
    String date = dataReader.dates[dataIndex];
    // if(response
    debugPrint(date.substring(4, 6));
    response = await photoLibraryApiClient.getPhotosOfDate(
        date.substring(0, 4), date.substring(4, 6), date.substring(6, 8));
    responseResult = parseResponse(response);
    photoLibraryApiClient.writeCache3(responseResult[0], 'links');
    photoLibraryApiClient.writeCache3(responseResult[1], 'filename');
    setState(() {});
    debugPrint("googleAccount manager : ${googleAccountManager.currentUser}");
  }

  void onSelected(BuildContext context, int item) {
    debugPrint(item.toString());
    switch (item) {
      case 0:
        Navigation.navigateTo(
            context: context,
            screen:
                AndroidSettingsScreen(googleAccountManager, permissionManager),
            style: NavigationRouteStyle.material);
        break;
    }
  }
}
