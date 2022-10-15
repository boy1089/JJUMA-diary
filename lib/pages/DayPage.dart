import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:matrix2d/matrix2d.dart';
import 'package:test_location_2nd/DateHandler.dart';
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

class DayPage extends StatefulWidget {
  // const WeekPage({Key? key}) : super(key: key);
  SensorDataReader dataReader;
  GoogleAccountManager googleAccountManager;
  PermissionManager permissionManager;
  PhotosLibraryApiClient photoLibraryApiClient;
  DataManager dataManager;

  // @override
  State<DayPage> createState() => _DayPageState();

  DayPage(this.dataReader, this.googleAccountManager, this.permissionManager,
      this.photoLibraryApiClient, this.dataManager,
      {Key? key})
      : super(key: key);
}

class _DayPageState extends State<DayPage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  var response;
  late SensorDataReader dataReader;
  late GoogleAccountManager googleAccountManager;
  late PermissionManager permissionManager;
  late PhotosLibraryApiClient photoLibraryApiClient;
  late DataManager dataManager;
  int dataIndex = 0;
  int indexOfDate2 = 0;
  List<List<String>> photoResponse = [];
  dynamic photoResponseModified = [];
  dynamic c = [];
  dynamic d;
  List<DateTime> datesOfYear =
      getDaysInBetween(DateTime.parse("20220101"), DateTime.now())
          .reversed
          .toList();

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

  List<List<dynamic>> dummyData = [
    [0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0],
    [0.0, 1.5, 0.0, 0.0, 0.0, 0.0, 0.0],
    [2.0, 1.5, 0.0, 0.0, 0.0, 0.0, 0.0],
    [4.0, 1.5, 0.0, 0.0, 0.0, 0.0, 0.0],
    [6.0, 1.5, 0.0, 0.0, 0.0, 0.0, 0.0],
    [8.0, 1.5, 0.0, 0.0, 0.0, 0.0, 0.0],
    [10.0, 1.5, 0.0, 0.0, 0.0, 0.0, 0.0],
    [12.0, 1.5, 0.0, 0.0, 0.0, 0.0, 0.0],
    [14.0, 1.5, 0.0, 0.0, 0.0, 0.0, 0.0],
    [16.0, 1.5, 0.0, 0.0, 0.0, 0.0, 0.0],
    [18.0, 1.5, 0.0, 0.0, 0.0, 0.0, 0.0],
  ];

  @override
  Widget build(BuildContext context) {
    print(c.runtimeType);
    // dataTime = [DateTime.parse("2021-08-01"), DateTime.parse("2021-08-02"), DateTime.parse("2021-08-03")];
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: Colors.white,
      body: Column(
        children: [
          SizedBox(
              height: physicalHeight / 2,
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
                          left: physicalWidth / 2 - kDefaultPolarPlotSize / 2,
                          top: physicalHeight / 4 - kDefaultPolarPlotSize / 2,
                          child: Container(
                            margin: const EdgeInsets.only(top: 10),
                            width: kDefaultPolarPlotSize,
                            height: kDefaultPolarPlotSize,
                            child: PolarSensorDataPlot(dataIndex == -1
                                    ? dummyData
                                    : dataReader.dailyDataAll[dataIndex])
                                .build(context),
                          ),
                        ),
                        Positioned(
                            left: physicalWidth / 2 - kDefaultPolarPlotSize / 2,
                            top: physicalHeight / 4 - kDefaultPolarPlotSize / 2,
                            child: Container(
                                margin: const EdgeInsets.only(top: 10),
                                width: kDefaultPolarPlotSize,
                                height: kDefaultPolarPlotSize,
                                child: Chart(
                                  data: photoResponseModified.length == 0?
                                  dummyData:
                                      c,
                                  // [photoResponseModified[0], photoResponseModified[2]],
                                  // photoResponseModified,
                                  // data : dummyData,

                                  elements: [
                                    PointElement(
                                      size: SizeAttr(variable: 'dummy', values: [7, 8]),
                                      // shape : ShapeAttr(value : []),
                                    ),
                                  ],
                                  variables: {
                                    '0': Variable(
                                      accessor: (List datum) => datum[0] as num,
                                      scale: LinearScale(
                                          min: 0, max: 24, tickCount: 5),
                                    ),
                                    'dummy': Variable(
                                      accessor: (List datum) => datum[1] as num,
                                    ),
                                  },
                                  coord: PolarCoord(),
                                )))
                      ]),
                    ),
                  ])),
          Center(
            child: SizedBox(
                width: physicalWidth,
                height: 50,
                //reference : https://www.youtube.com/watch?v=wnTYKJEJ7f4&t=167s
                child: ListWheelScrollView.useDelegate(
                    magnification: 1,
                    squeeze: 1.8,
                    physics: const FixedExtentScrollPhysics(),
                    diameterRatio: 0.7,
                    onSelectedItemChanged: (index) => setState(() {
                          String currentDateString =
                              DateFormat("yyyyMMdd").format(datesOfYear[index]);
                          indexOfDate2 = index;
                          int indexOfDate =
                              dataReader.dates.indexOf(currentDateString);
                          dataIndex = indexOfDate;
                          updatePhoto();
                        }),
                    itemExtent: 80,
                    childDelegate: ListWheelChildBuilderDelegate(
                        builder: (context, index) => Center(
                              child: Text(
                                  DateFormat("yyyyMMdd")
                                      .format(datesOfYear[index]),
                                  // Text(dataReader.dates[index],
                                  style: const TextStyle(
                                      fontSize: 20, color: Colors.black54)),
                            ),
                        childCount: datesOfYear.length))),
          ),
          Center(
              child: SizedBox(
                  width: physicalWidth,
                  height: physicalHeight / 4,
                  child: photoResponse.isEmpty
                      ? const Text('no links')
                      : ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemBuilder: (BuildContext context, int index) {
                            return Image.network(photoResponse[1][index]);
                          },
                          itemCount: photoResponse[1].length,
                        )))
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: (() async {
          // print(dataReader.dailyDataAll[0].transpose[0]);

          updatePhoto();
          // print(dataManager.datesOfYear);
          // print(dataReader.dates);
          // print(dataReader.dailyDataAll[0]);
          // print(dataReader.dailyDataAll[0]);
        }),
      ),
    );
  }

  void updatePhoto() async {
    String date = DateFormat("yyyyMMdd").format(datesOfYear[indexOfDate2]);
    // debugPrint(date.substring(4, 6));
    response = await photoLibraryApiClient.getPhotosOfDate(
        date.substring(0, 4), date.substring(4, 6), date.substring(6, 8));
    photoResponse = parseResponse(response);
    photoResponseModified = modifyPhotoResponseForPlot(photoResponse);
    // photoLibraryApiClient.writeCache3(photoResponse[0], 'time');
    // photoLibraryApiClient.writeCache3(photoResponse[1], 'link');
    // photoLibraryApiClient.writeCache3(photoResponse[2], 'filename');
    c = [photoResponseModified[0], photoResponseModified[2]];
    // print("photoResponseModified : $photoResponseModified");
    // c = transposeList([photoResponseModified[0], photoResponseModified[2]]);
    // c = transposeList(c);
    c = transpose(c);
    d = c;
    print("c : ${c}");

    setState(() {});
  }
}
