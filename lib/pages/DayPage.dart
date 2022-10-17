import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:test_location_2nd/DateHandler.dart';
import 'package:test_location_2nd/GooglePhotoManager.dart';
import 'package:test_location_2nd/Permissions/GoogleAccountManager.dart';
import 'package:test_location_2nd/StateProvider.dart';
import 'package:test_location_2nd/Util/Util.dart';
import '../Sensor/SensorDataReader.dart';
import 'package:test_location_2nd/Permissions/PermissionManager.dart';
import 'package:test_location_2nd/Api/PhotoLibraryApiClient.dart';
import 'package:test_location_2nd/Util/responseParser.dart';
import 'package:test_location_2nd/PolarSensorDataPlot.dart';
import 'package:test_location_2nd/Data/DataManager.dart';
import 'package:graphic/graphic.dart';
import 'package:provider/provider.dart';
import 'dart:io';
import 'dart:convert';
import 'package:csv/csv.dart';

import 'package:path_provider/path_provider.dart';

//TODO : put global variables to StateProvider - date/month/year, setting, current page

class DayPage extends StatefulWidget {
  SensorDataReader dataReader;
  GoogleAccountManager googleAccountManager;
  PermissionManager permissionManager;
  PhotosLibraryApiClient photoLibraryApiClient;
  DataManager dataManager;
  GooglePhotoManager googlePhotoManager;

  @override
  State<DayPage> createState() => _DayPageState();

  DayPage(this.dataReader, this.googleAccountManager, this.permissionManager,
      this.photoLibraryApiClient, this.dataManager, this.googlePhotoManager,
      {Key? key})
      : super(key: key);


}

class _DayPageState extends State<DayPage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  late SensorDataReader dataReader;
  late GoogleAccountManager googleAccountManager;
  late PermissionManager permissionManager;
  late PhotosLibraryApiClient photoLibraryApiClient;
  late DataManager dataManager;
  late GooglePhotoManager googlePhotoManager;

  List response = [];
  int dataIndexInDataReader = 0;
  int indexOfDate2 = 0;
  dynamic photoResponseModified = [];
  dynamic dataForPlot = [];
  dynamic d;
  List<dynamic> googlePhotoLinks = [];
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
    googlePhotoManager = widget.googlePhotoManager;

    updateUi();
  }

  var path =
      "https://lh3.googleusercontent.com/lr/AGiIYOVR_tHXYSoT-mraJx-N7emFAOmwsV10I3xpvkvt9L-eGyoiBRYbsoet65k6ONqTtaGSgTkysOh3wRC_IeOEEB1-yesECjGtpwuDmnZSEML4e3C08B640docvD8UxgH6P8RO-klXvSfIOOr54WGrdruw2QfET404Hm8z89H-T8Sd83n30W-Nrc0LFuSzwwz0IPQ6Cncx8aGGriBsrC9tcDeZ7NLzb_R8T92tR8WMzmYrXBfd748vohg6lD_0vihssmyAerrMgpnO406B_jsDdHggluLeIvxDrMaGNvBLCaWRBDIrHvD_IusKdULmxgGIIWxYe2hrgzhT2WzV0qrYbfNuDYvJgR-9NbOPbd-5NyxCT9uQRzbUvlHyZW-r87Vu8qUuV9i3uj7RwqTkFLsBrns-LkxjtQ58VCjid95iMP9MPQQiZzSvEK0SY2-vqNVksiWRLdgZGzxiskWiqkXenz63LqBKKlN3gxO0aSSU88-j5Ol9sjds_MEzIF3FjKQ3ZcmCW2jYfBUNeYXaDVzbMLivcift79CIehK8quaI8Wp3BhYPpbvRVpRCYM8qazYb-Jgjm4mOsI4uqdBnrPMeF14eLnaoh2ebvJXJCVT2YAVjIiWL6PYOCslCLVfMD2CmbSLzjbLevZlVKp5n_-DNe4uN0_or5yRWvyaUdkBXqhCGlOQN3CtQVQ7cOPuHrJkA4pNTvP-aNycKtUUPGd_lfbQP78bs_UWsfFFF_a57gIoyGfnsYAtI0x9ilO9w_1hvz9r1WktaNYzJV43dSSzN3StZ_ftpkqK-XNvBT_fP5HE9vrYIRp7tMTNVzBfb-yyeLIkirNRfbFJ70tOHiX3TI0cgaslGNVhQiGy_34URsaXPNRnYa2gzVU2zIhYD4betspl8xYJ9mkVGX_Ds57DSF5AFYMnmk_llErRaAK4LVnj0WHUmxXZhc9ZoaX1g8UTM7yPHl824zoMMVNCnZXkXDZpCsan2GNc-W4dWEpJDdsKc8SxWKAl-Rpbhz7rf1p7n8pRlI5TxKKxAe0SLUopO1Fjq1fCEmg6hVgBZVwzmMK8T-Yw3a80Q-VQdmAUCPg";
  @override
  Widget build(BuildContext context) {
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
                            child: PolarSensorDataPlot(dataIndexInDataReader ==
                                        -1
                                    ? dummyData
                                    : dataReader
                                        .dailyDataAll[dataIndexInDataReader])
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
                                  data: dataForPlot[0].length == 0
                                      ? dummyData
                                      : dataForPlot.sublist(0),
                                  elements: [
                                    PointElement(
                                      size: SizeAttr(
                                          variable: 'dummy', values: [7, 8]),
                                    ),
                                  ],
                                  variables: {
                                    'time': Variable(
                                      accessor: (List datum) => datum[0] as num,
                                      scale: LinearScale(
                                          min: 0, max: 24, tickCount: 5),
                                    ),
                                    'dummy': Variable(
                                      accessor: (List datum) => datum[2] as num,
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
                    controller: FixedExtentScrollController(
                        initialItem: datesOfYear.indexOf(DateTime.parse(
                            Provider.of<NavigationIndexProvider>(context,
                                    listen: false)
                                .date))),
                    magnification: 1,
                    squeeze: 1.8,
                    physics: const FixedExtentScrollPhysics(),
                    diameterRatio: 0.7,
                    onSelectedItemChanged: (index) => setState(() {
                          String currentDateString =
                              DateFormat("yyyyMMdd").format(datesOfYear[index]);
                          indexOfDate2 = index;
                          dataIndexInDataReader =
                              dataReader.dates.indexOf(currentDateString);
                          context
                              .read<NavigationIndexProvider>()
                              .setDate(datesOfYear[index]);

                          // var date2 = DateTime.parse(
                          //     Provider.of<NavigationIndexProvider>(context,
                          //             listen: false)
                          //         .date);
                          updateUi();
                          // openFile(
                          //     "/storage/emulated/0/Android/data/com.example.test_location_2nd/files/googlePhotoData/${formatDate(date2)}_googlePhoto.csv");
                        }),
                    itemExtent: 80,
                    restorationId: "aa",
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
                  child: googlePhotoLinks.isEmpty
                      ? const Text('no links')
                      : ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemBuilder: (BuildContext context, int index) {
                            print(googlePhotoLinks[index]);
                            return Image.network(googlePhotoLinks[index]);
                            // return Image.network(path);
                          },
                          itemCount: googlePhotoLinks.length,
                        )))
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: (() async {
          setState(() {});
          updatePhoto();

        }),
      ),
    );
  }

  void updateUi() async {
    var date2 = DateTime.parse(
        Provider.of<NavigationIndexProvider>(context, listen: false).date);
    bool isFileExists = await File(
            "/storage/emulated/0/Android/data/com.example.test_location_2nd/files/googlePhotoData/${formatDate(date2)}_googlePhoto.csv")
        .exists();

    print("isFileExists $isFileExists");

    setState(() {
      if (isFileExists) {
        print("opening file");
        openFile(
            "/storage/emulated/0/Android/data/com.example.test_location_2nd/files/googlePhotoData/${formatDate(date2)}_googlePhoto.csv");
      } else {
        updatePhoto();
      }
    });
  }

  void openFile(filepath) async {
    File f = File(filepath);
    debugPrint("CSV to List");
    final input = f.openRead();
    final fields = await input
        .transform(utf8.decoder)
        .transform(const CsvToListConverter(eol: '\n'))
        .toList();
    // c = modifyPhotoDataForPlot(transpose(fields.sublist(1)));
    dataForPlot = modifyListForPlot(fields, filterTime: true);
    print("c, testing modifyListforPlot : ${dataForPlot.length}");

    googlePhotoLinks = transpose(dataForPlot).elementAt(1);

    setState(() {});
    // return fields;
  }

  void updatePhoto() async {
    String date =
        Provider.of<NavigationIndexProvider>(context, listen: false).date;
    response = await this.googlePhotoManager.getPhoto(photoLibraryApiClient, date);
    photoResponseModified =
        modifyListForPlot(response, executeTranspose: true);

    dataForPlot = photoResponseModified;
    print("dataForPlot : $dataForPlot");
    googlePhotoLinks = transpose(dataForPlot).elementAt(1);
    googlePhotoManager.writePhotoResponse(date, response);
    setState(() {});
  }

}
