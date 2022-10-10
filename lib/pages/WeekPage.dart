import 'package:flutter/material.dart';
import 'package:matrix2d/matrix2d.dart';
import 'package:test_location_2nd/Permissions/GoogleAccountManager.dart';
import 'package:test_location_2nd/Util/Util.dart';
import '../Sensor/SensorDataReader.dart';
import '../navigation.dart';
import 'package:test_location_2nd/pages/SettingPage.dart';
import 'package:test_location_2nd/Permissions/PermissionManager.dart';
import 'package:test_location_2nd/Api/PhotoLibraryApiClient.dart';
import 'package:test_location_2nd/Util/responseParser.dart';
import 'package:test_location_2nd/PolarSensorDataPlot.dart';
import 'package:test_location_2nd/PolarPhotoDataPlot.dart';
import 'package:test_location_2nd/Data/DataManager.dart';
import 'package:graphic/graphic.dart';
import 'package:flutter/material.dart';

class WeekPage extends StatefulWidget {
  // const WeekPage({Key? key}) : super(key: key);
  SensorDataReader dataReader;
  GoogleAccountManager googleAccountManager;
  PermissionManager permissionManager;
  PhotosLibraryApiClient photoLibraryApiClient;
  DataManager dataManager;

  // @override
  State<WeekPage> createState() => _WeekPageState();

  WeekPage(this.dataReader, this.googleAccountManager, this.permissionManager,
      this.photoLibraryApiClient, this.dataManager,
      {Key? key})
      : super(key: key);
}

class _WeekPageState extends State<WeekPage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  var response;
  late SensorDataReader dataReader;
  late GoogleAccountManager googleAccountManager;
  late PermissionManager permissionManager;
  late PhotosLibraryApiClient photoLibraryApiClient;
  late DataManager dataManager;
  int dataIndex = 0;
  List<List<String>> responseResult = [];
  var dataTime = [DateTime.now(), DateTime.now()];
  List<dynamic> data2 = [0.0, 0.0];
  var dataTime2 = ["2022-08-01", "2022-08-02", "2022-08-03"];
  @override
  void initState() {
    super.initState();
    dataReader = widget.dataReader;
    googleAccountManager = widget.googleAccountManager;
    permissionManager = widget.permissionManager;
    photoLibraryApiClient = widget.photoLibraryApiClient;
    dataManager = widget.dataManager;

    // var data = await dataManager.getProcessedSensorFile();
    // print("processed data : ${slice(data, [0, data.shape[0]], [0, 1]).sublist(1).flatten}");
    // var dataConverted = slice(data, [0, data.shape[0]], [0, 1]).sublist(1).flatten;
    // var dataConverted2 = slice(data, [0, data.shape[0]], [1, 2]).sublist(1).flatten;
    //
    // dataTime = List.generate(data.shape[0]-1, (index) => DateTime.parse(dataConverted[index]));
    // data2 = dataConverted2;
  }

  @override
  Widget build(BuildContext context) {
    dataTime = [DateTime.parse("2021-08-01"), DateTime.parse("2021-08-02"), DateTime.parse("2021-08-03")];

    data2 = [1, 2, 3];
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: Colors.white,
      body: SizedBox(
          height: physicalHeight,
          width: physicalWidth,
          child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                SizedBox(
                  width: physicalWidth,
                  height: physicalHeight / 2,
                  child: Stack(children: [
                    Positioned(
                      left: physicalWidth / 2 - defaultPolarPlotSize / 2,
                      top: physicalHeight / 4 - defaultPolarPlotSize / 2,
                      child: Container(
                          margin: const EdgeInsets.only(top: 10),
                          width: defaultPolarPlotSize,
                          height: defaultPolarPlotSize,
                          child: Chart(
                            data: [dataTime2, data2],
                            variables: {
                              '0': Variable(
                                accessor: (List datum) => datum[0].toString(),
                                scale:
                                    // TimeScale(min: dataTime[0], max: dataTime.last)
                                   OrdinalScale(),
                              ),
                              'dummy': Variable(
                                accessor: (List datum) => datum[1] as num,
                              ),
                            },
                            elements: [
                              PointElement(
                                size: SizeAttr(
                                    variable: 'dummy', values: [6, 7]),
                                // shape : ShapeAttr(value : []),
                                color: ColorAttr(
                                  variable: 'dummy',
                                  values: colorsHotCold,
                                  // updaters: {
                                  //   'choose': {true: (_) => Colors.red}
                                  // },
                                ),
                              ),
                            ],
                          )),
                    ),

                    // Positioned(
                    //     left: physicalWidth / 2 - secondPolarPlotSize / 2,
                    //     top: physicalHeight / 4 - secondPolarPlotSize / 2,
                    //     child: Container(
                    //       margin: const EdgeInsets.only(top: 10),
                    //       width: secondPolarPlotSize,
                    //       height: secondPolarPlotSize,
                    //       child: PolarPhotoDataPlot(dummyPhotoData)
                    //           .build(context),
                    //     )),
                  ]),
                ),
              ])),
      floatingActionButton: FloatingActionButton(
        onPressed: (() async {
          var data = await dataManager.getProcessedSensorFile();
          print("processed data : ${slice(data, [0, data.shape[0]], [0, 1]).sublist(1).flatten}");
          var dataConverted = slice(data, [0, data.shape[0]], [0, 1]).sublist(1).flatten;
          var dataConverted2 = slice(data, [0, data.shape[0]], [1, 2]).sublist(1).flatten;

          dataTime = List.generate(data.shape[0]-1, (index) => DateTime.parse(dataConverted[index]));
          data2 = dataConverted2;
          print("datetime : $dataTime");
          print("data2 : $data2");
          setState((){});
          // print(dataReader.dailyDataAll[0]);
        }),
      ),
    );
  }
}
