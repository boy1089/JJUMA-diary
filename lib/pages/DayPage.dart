import 'package:flutter/material.dart';
import 'package:test_location_2nd/Util/DateHandler.dart';
import 'package:test_location_2nd/Photo/GooglePhotoDataManager.dart';
import 'package:test_location_2nd/Permissions/GoogleAccountManager.dart';
import 'package:test_location_2nd/Photo/LocalPhotoDataManager.dart';
import 'package:test_location_2nd/Sensor/SensorDataManager.dart';
import 'package:test_location_2nd/Util/StateProvider.dart';
import 'package:test_location_2nd/Util/Util.dart';
import 'package:test_location_2nd/Permissions/PermissionManager.dart';
import 'package:test_location_2nd/Api/PhotoLibraryApiClient.dart';
import 'package:test_location_2nd/PolarSensorDataPlot.dart';
import 'package:test_location_2nd/Data/DataManager.dart';
import 'package:provider/provider.dart';
import 'dart:io';
import 'dart:convert';
import 'package:csv/csv.dart';
import 'package:test_location_2nd/polarPhotoImageContainer.dart';
import 'package:test_location_2nd/PolarPhotoDataPlot.dart';
import 'package:test_location_2nd/Util/global.dart';
import 'dart:math';
import 'package:test_location_2nd/Note/NoteManager.dart';
import 'package:intl/intl.dart';

class DayPage extends StatefulWidget {
  GoogleAccountManager googleAccountManager;
  PermissionManager permissionManager;
  PhotoLibraryApiClient photoLibraryApiClient;
  DataManager dataManager;
  GooglePhotoDataManager googlePhotoDataManager;
  SensorDataManager sensorDataManager;
  LocalPhotoDataManager localPhotoDataManager;
  NoteManager noteManager;

  @override
  State<DayPage> createState() => _DayPageState();

  DayPage(
      this.googleAccountManager,
      this.permissionManager,
      this.photoLibraryApiClient,
      this.dataManager,
      this.googlePhotoDataManager,
      this.sensorDataManager,
      this.localPhotoDataManager,
      this.noteManager,
      {Key? key})
      : super(key: key);
}

class _DayPageState extends State<DayPage> {
  late GoogleAccountManager googleAccountManager;
  late PermissionManager permissionManager;
  late PhotoLibraryApiClient photoLibraryApiClient;
  late DataManager dataManager;
  late GooglePhotoDataManager googlePhotoDataManager;
  late SensorDataManager sensorDataManager;
  late LocalPhotoDataManager localPhotoDataManager;
  late NoteManager noteManager;

  List response = [];
  dynamic photoResponseModified = [];
  dynamic sensorDataModified = [];
  dynamic localPhotoDataForPlot = [[]];
  dynamic sensorDataForPlot = [[]];

  List<dynamic> googlePhotoLinks = [];
  List<dynamic> localPhotoLinks = [];
  List<DateTime> datesOfYear =
      getDaysInBetween(DateTime.parse("${startYear}0101"), DateTime.now())
          .reversed
          .toList();
  Future readData = Future.delayed(const Duration(seconds: 1));
  Future update = Future.delayed(const Duration(seconds: 1));
  List imagesForPlot = [];
  List<List<dynamic>> photoDataForPlot = [[]];
  FocusNode focusNode = FocusNode();

  final myTextController = TextEditingController();

  @override
  void initState() {
    super.initState();
    googleAccountManager = widget.googleAccountManager;
    permissionManager = widget.permissionManager;
    photoLibraryApiClient = widget.photoLibraryApiClient;
    dataManager = widget.dataManager;
    googlePhotoDataManager = widget.googlePhotoDataManager;
    sensorDataManager = widget.sensorDataManager;
    localPhotoDataManager = widget.localPhotoDataManager;
    noteManager = widget.noteManager;
    // update = updateUi();

    print("DayPage, after initState : ${photoDataForPlot}");
    readData = _fetchData();
    // imageContainers = polarPhotoImageContainers(imagesForPlot);
  }

  Future<List<dynamic>> _fetchData() async {
    await updateUi();
    return googlePhotoLinks;
  }

  bool isZoomIn = false;
  bool isZoomInImageVisible = false;
  double _angle = 0;

  double graphSize = 330;
  double topPadding = 150;

  //layout for zoomIn and zoomOut state
  late Map layout = {
    'magnification': {true: 7, false: 1},
    'graphSize': {true: graphSize * 7, false: graphSize},
    'left': {true: -graphSize * 5.5, false: (physicalWidth - graphSize) / 2},
    'top': {true: null, false: topPadding},
    'graphCenter': {
      true: Offset(0, 0),
      false: Offset(physicalWidth / 2, graphSize / 2 + topPadding)
    }
  };

  double firstContainerSize = 1000;

  @override
  Widget build(BuildContext context) {
    var provider = Provider.of<NavigationIndexProvider>(context, listen: true);
    var isZoomIn =
        Provider.of<NavigationIndexProvider>(context, listen: true).isZoomIn;

    return FutureBuilder(
        future: readData,
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          return Scaffold(
            backgroundColor: kBackGroundColor,
            body: !snapshot.hasData
                ? Center(
                    child: SizedBox(
                        width: 140,
                        height: 140,
                        child: CircularProgressIndicator(
                          strokeWidth: 10,
                        )))
                : RawGestureDetector(
                    behavior: HitTestBehavior.deferToChild,
                    gestures: {
                      AllowMultipleGestureRecognizer:
                          GestureRecognizerFactoryWithHandlers<
                                  AllowMultipleGestureRecognizer>(
                              () => AllowMultipleGestureRecognizer(),
                              (AllowMultipleGestureRecognizer instance) {
                        instance.onTapDown = (details) {
                          setState(() {
                            print(indexForZoomInImage);
                            if (!isImageClicked) indexForZoomInImage = -1;
                            isImageClicked = false;
                            if (isZoomIn) return;

                            Offset tapPosition =
                                calculateTapPositionRefCenter(details, 0);
                            double angleZoomIn =
                                calculateTapAngle(tapPosition, 0, 0);
                            // print("tap Position : ${tapPosition}");
                            // print("angle : $angleZoomIn");
                            // print("zoomIn : $isZoomIn");

                            provider.setZoomInState(true);
                            isZoomInImageVisible = true;
                            _angle = angleZoomIn;
                            provider.setZoomInRotationAngle(_angle);
                            FocusManager.instance.primaryFocus?.unfocus();
                          });
                        };
                      }),
                      AllowMultipleGestureRecognizer2:
                          GestureRecognizerFactoryWithHandlers<
                              AllowMultipleGestureRecognizer2>(
                        () => AllowMultipleGestureRecognizer2(),
                        (AllowMultipleGestureRecognizer2 instance) {
                          instance.onUpdate = (details) {
                            _angle =
                                isZoomIn ? _angle + details.delta.dy / 1000 : 0;
                            provider.setZoomInRotationAngle(_angle);
                            setState(() {});
                          };
                        },
                      )
                    },
                    child: Container(
                      width: firstContainerSize,
                      height: firstContainerSize,
                      child: Stack(
                          alignment:
                              isZoomIn ? Alignment.center : Alignment.topCenter,
                          children: [
                            AnimatedPositioned(
                              width: layout['graphSize']?[isZoomIn]?.toDouble(),
                              height:
                                  layout['graphSize']?[isZoomIn]?.toDouble(),
                              duration: Duration(milliseconds: animationTime),
                              left: layout['left']?[isZoomIn]?.toDouble(),
                              top: layout['top']?[isZoomIn]?.toDouble(),
                              curve: Curves.fastOutSlowIn,
                              child: AnimatedRotation(
                                  turns: isZoomIn ? _angle : 0,
                                  duration: Duration(
                                      milliseconds: animationTime - 100),
                                  child: Stack(
                                    children: [
                                      PolarSensorDataPlot(
                                              sensorDataForPlot[0].length == 0
                                                  ? dummyData
                                                  : sensorDataForPlot)
                                          .build(context),
                                      PolarPhotoDataPlot(photoDataForPlot)
                                          .build(context),
                                      polarPhotoImageContainers(imagesForPlot)
                                          .build(context),
                                    ],
                                  )),
                            ),
                            Positioned(
                              width: physicalWidth - 20,
                              height: !focusNode.hasFocus
                                  ? physicalHeight / 2 - 200
                                  : physicalHeight / 2 - 50,
                              left: 10,
                              bottom: 20,
                              child: Offstage(
                                offstage: isZoomIn ? true : false,
                                child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Container(
                                        height: !focusNode.hasFocus
                                            ? physicalHeight / 2 - 200
                                            : physicalHeight / 2 - 50,
                                        color: myTextController.text.isEmpty
                                        ?Colors.transparent
                                        :Colors.black12,
                                        child: EditableText(
                                          readOnly: isZoomIn ? true : false,
                                          maxLines: 15,
                                          controller: myTextController,
                                          focusNode: focusNode,
                                          style:
                                              TextStyle(color: Colors.black54),
                                          cursorColor: Colors.black12,
                                          backgroundCursorColor: Colors.black12,
                                          textAlign: TextAlign.left,
                                        ),
                                      ),
                                    ]),
                              ),
                            ),
                            Positioned(
                                top: 30,
                                child: Text(
                                  "${DateFormat('EEEE').format(DateTime.parse(provider.date))}/"
                                  "${DateFormat('MMM').format(DateTime.parse(provider.date))} "
                                  "${DateFormat('dd').format(DateTime.parse(provider.date))}/"
                                  "${DateFormat('yyyy').format(DateTime.parse(provider.date))}",
                                  style: TextStyle(fontSize: 20, color: Colors.black54),
                                )),
                          ]),
                    ),
                  ),
            floatingActionButton: FloatingActionButton(
              mini: true,
              child: Icon(focusNode.hasFocus ? Icons.arrow_right : Icons.add),
              onPressed: () {
                if (focusNode.hasFocus) {
                  dismissKeyboard();
                } else {
                  showKeyboard();
                }                ;
                setState(() {});
              },
            ),
          );
        });
  }

  //this function calculates the tap position relative to graph
  double calculateTapAngle(Offset, referencePosition, referenceAngle) {
    double dx = Offset.dx;
    double dy = Offset.dy;

    var angle =
        atan2(dy / sqrt(dx * dx + dy * dy), dx / sqrt(dx * dx + dy * dy)) /
            (2 * pi);
    return angle;
  }

  //this function calculates the tap position relative to center of the graph
  Offset calculateTapPositionRefCenter(details, reference) {
    bool isZoomIn =
        Provider.of<NavigationIndexProvider>(context, listen: false).isZoomIn;
    var dx = details.globalPosition.dx - layout['graphCenter'][isZoomIn].dx;
    var dy =
        -1 * (details.globalPosition.dy - layout['graphCenter'][isZoomIn].dy);
    return Offset(dx, dy.toDouble());
  }

  void showKeyboard() {
    focusNode.requestFocus();
    setState(() {});
  }

  void dismissKeyboard() async {
    focusNode.unfocus();
    await noteManager.writeNote(
        Provider.of<NavigationIndexProvider>(context, listen: false).date,
        myTextController.text);
  }

  @override
  void dispose() {
    focusNode.dispose();
    super.dispose();
  }

  Future updateUi() async {
    googlePhotoLinks = [];
    imagesForPlot = [];
    photoDataForPlot = [];
    localPhotoDataForPlot = [[]];
    //code to updatePhoto from google photo
    // try {
    //   var a = await updatePhoto();
    //   imagesForPlot = selectImagesForPlot(photoDataForPlot);
    // } catch (e) {
    //   print("while updating Ui, error is occrued, google photo : $e");
    // }
    try {
      var b = await updatePhotoFromLocal();
      imagesForPlot = selectImagesForPlot(localPhotoDataForPlot);
    } catch (e) {
      print("while updating Ui, error is occrued : $e");
    }

    updateSensorData();

    setState(() {});
    //convert data type..
    photoDataForPlot = List<List>.generate(
        imagesForPlot.length, (index) => imagesForPlot.elementAt(index));

    try {
      myTextController.text = await noteManager.readNote(
          Provider.of<NavigationIndexProvider>(context, listen: false).date);
    } catch (e) {
      print("while updating UI, reading note, error is occured : $e");
    }
    print("updateUi done");
  }

  List selectImagesForPlot(List input) {
    print("selectImageForPlot : ${input}");
    if (input[0] == null) {
      return imagesForPlot;
    }

    print(input);
    if (input[0].length == 0) {
      return imagesForPlot;
    }

    imagesForPlot.add(input.first);
    imagesForPlot.add(input.last);
    int j = 0;
    for (int i = 0; i < input.length; i++) {
      print("selectImagesForPlot, ${i}, ${imagesForPlot}, ${input}");
      if ((input[i][0] - imagesForPlot[j][0]).abs() >
          kMinimumTimeDifferenceBetweenImages) {
        imagesForPlot.add(input[i]);
        j += 1;
      }
    }
    print("selectImagesForPlot, $imagesForPlot}");

    return imagesForPlot;
  }

  Future updatePhoto() async {
    String date =
        Provider.of<NavigationIndexProvider>(context, listen: false).date;
    response =
        await this.googlePhotoDataManager.getPhoto(photoLibraryApiClient, date);
    print("updatePhoto");
    photoResponseModified =
        modifyListForPlot(response, executeTranspose: true, filterTime: true);

    photoDataForPlot = photoResponseModified;
    print("dataForPlot : $photoDataForPlot");
    googlePhotoLinks = transpose(photoDataForPlot).elementAt(1);
    print("googlePhotoLinks : $googlePhotoLinks");
    googlePhotoDataManager.writePhotoResponse(date, response);
    dataManager.updateSummaryOfPhotoData(date, googlePhotoLinks.length);
    return googlePhotoLinks;
  }

  Future updatePhotoFromLocal() async {
    String date =
        Provider.of<NavigationIndexProvider>(context, listen: false).date;
    List<List<dynamic>> files =
        await localPhotoDataManager.getPhotoOfDate(date);
    localPhotoDataForPlot = modifyListForPlot(files, executeTranspose: true);
    localPhotoLinks = transpose(localPhotoDataForPlot);
    dataManager.updateSummaryOfPhotoData(date, localPhotoLinks[0].length);
    // photoDataForPlot.addAll(localPhotoDataForPlot);
  }

  void openSensorData(filepath) async {
    File f = File(filepath);
    debugPrint("CSV to List");
    final input = f.openRead();
    final fields = await input
        .transform(utf8.decoder)
        .transform(const CsvToListConverter(eol: '\n'))
        .toList();
    sensorDataForPlot = modifyListForPlot(fields);
    print("sensorDataForPlot : $sensorDataForPlot");
  }

  void updateSensorData() async {
    String date =
        Provider.of<NavigationIndexProvider>(context, listen: false).date;
    var sensorData = await this.sensorDataManager.openFile(date);
    sensorDataModified = modifyListForPlot(subsampleList(sensorData, 50));
    sensorDataForPlot = sensorDataModified;
    print("sensorDataForPlot : $sensorDataForPlot");

    // sensorDataManager.writeSensorData(date, sensorDataModified);
  }
}
