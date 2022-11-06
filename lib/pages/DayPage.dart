import 'package:flutter/material.dart';
import 'package:test_location_2nd/Util/DateHandler.dart';
import 'package:test_location_2nd/Photo/LocalPhotoDataManager.dart';
import 'package:test_location_2nd/Sensor/SensorDataManager.dart';
import 'package:test_location_2nd/Util/StateProvider.dart';
import 'package:test_location_2nd/Util/Util.dart';
import 'package:test_location_2nd/Permissions/PermissionManager.dart';
import 'package:test_location_2nd/PolarSensorDataPlot.dart';
import 'package:test_location_2nd/Data/DataManager.dart';
import 'package:provider/provider.dart';
import 'dart:io';
import 'dart:convert';
import 'package:csv/csv.dart';
import 'package:test_location_2nd/polarPhotoImageContainer.dart';
import 'package:test_location_2nd/PolarPhotoDataPlot.dart';
import 'package:test_location_2nd/Util/global.dart' as global;
import 'dart:math';
import 'package:test_location_2nd/Note/NoteManager.dart';
import 'package:intl/intl.dart';
import 'package:test_location_2nd/PolarTimeIndicators.dart';

class DayPage extends StatefulWidget {
  PermissionManager permissionManager;
  DataManager dataManager;
  SensorDataManager sensorDataManager;
  LocalPhotoDataManager localPhotoDataManager;
  NoteManager noteManager;

  @override
  State<DayPage> createState() => _DayPageState();

  DayPage(this.permissionManager, this.dataManager, this.sensorDataManager,
      this.localPhotoDataManager, this.noteManager,
      {Key? key})
      : super(key: key);
}

class _DayPageState extends State<DayPage> {
  late PermissionManager permissionManager;
  late DataManager dataManager;
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
  List<DateTime> datesOfYear = getDaysInBetween(
          DateTime.parse("${global.startYear}0101"), DateTime.now())
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
    permissionManager = widget.permissionManager;
    dataManager = widget.dataManager;
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
    var provider =
    Provider.of<NavigationIndexProvider>(context, listen: false);

    provider.setZoomInState(false);
    return googlePhotoLinks;
  }

  bool isZoomIn = false;
  bool isZoomInImageVisible = false;
  double _angle = 0;

  double graphSize = 330;
  double topPadding = 100;

  //layout for zoomIn and zoomOut state
  late Map layout_dayPage = {
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
            backgroundColor: global.kBackGroundColor,
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
                          print(global.indexForZoomInImage);
                          if (!global.isImageClicked)
                            global.indexForZoomInImage = -1;
                          global.isImageClicked = false;
                          if (isZoomIn) return;

                          Offset tapPosition =
                              calculateTapPositionRefCenter(details, 0, layout_dayPage);
                          double angleZoomIn =
                              calculateTapAngle(tapPosition, 0, 0);

                          if (tapPosition.dy < -200) return;
                          //if editing text, doesn't zoom in.
                          if (focusNode.hasFocus) {
                            print("has focus? ${focusNode.hasFocus}");
                            dismissKeyboard();
                            setState(() {});
                            return;
                          }
                          setState(() {
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
                    child: SizedBox(
                      width: firstContainerSize,
                      height: firstContainerSize,
                      child: Stack(
                          alignment:
                              isZoomIn ? Alignment.center : Alignment.topCenter,
                          children: [
                            AnimatedPositioned(
                              width: layout_dayPage['graphSize']?[isZoomIn]?.toDouble(),
                              height:
                                  layout_dayPage['graphSize']?[isZoomIn]?.toDouble(),
                              duration:
                                  Duration(milliseconds: global.animationTime),
                              left: layout_dayPage['left']?[isZoomIn]?.toDouble(),
                              top: layout_dayPage['top']?[isZoomIn]?.toDouble(),
                              curve: Curves.fastOutSlowIn,
                              child: AnimatedRotation(
                                  turns: isZoomIn ? _angle : 0,
                                  duration: Duration(
                                      milliseconds: global.animationTime - 100),
                                  child: Stack(
                                    children: [
                                      PolarTimeIndicators().build(context),
                                      PolarSensorDataPlot((sensorDataForPlot[0]
                                                          .length ==
                                                      0) |
                                                  (sensorDataForPlot.length ==
                                                      0)
                                              ? global.dummyData1
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
                              width: physicalWidth,
                              height: !focusNode.hasFocus
                                  ? physicalHeight / 2 - 120
                                  : physicalHeight / 2 - 50,
                              bottom: 20,
                              child: Container(
                                margin: EdgeInsets.all(10),
                                height: !focusNode.hasFocus
                                    ? physicalHeight / 2 - 200
                                    : physicalHeight / 2 - 50,
                                color: focusNode.hasFocus
                                    ? global.kColor_containerFocused
                                    : global.kColor_container,
                                child: EditableText(
                                  // readOnly: isZoomIn ? true : false,
                                  maxLines: 15,
                                  controller: myTextController,
                                  onSelectionChanged: (a, b) {
                                    if (!focusNode.hasFocus) setState(() {});
                                  },

                                  onEditingComplete: () {
                                    print("editing completed");
                                    dismissKeyboard();
                                  },

                                  focusNode: focusNode,
                                  style:
                                      TextStyle(color: global.kColor_diaryText),
                                  cursorColor: Colors.black12,
                                  backgroundCursorColor: Colors.black12,
                                  textAlign: TextAlign.left,
                                ),
                              ),
                            ),
                            Positioned(
                                top: 30,
                                child: Text(
                                  "${DateFormat('EEEE').format(DateTime.parse(provider.date))}/"
                                  "${DateFormat('MMM').format(DateTime.parse(provider.date))} "
                                  "${DateFormat('dd').format(DateTime.parse(provider.date))}/"
                                  "${DateFormat('yyyy').format(DateTime.parse(provider.date))}",
                                  style: TextStyle(
                                      fontSize: 20,
                                      color: global.kColor_backgroundText),
                                )),
                          ]),
                    ),
                  ),
            floatingActionButton: FloatingActionButton(
              mini: true,
              backgroundColor: global.kMainColor_warm,
              child: focusNode.hasFocus ? Text("save") : Icon(Icons.add),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(15.0)),
              ),
              onPressed: () {
                if (focusNode.hasFocus) {
                  dismissKeyboard();
                } else {
                  showKeyboard();
                }
                ;
                setState(() {});
              },
            ),
          );
        });
  }

  //this function calculates the tap position relative to graph



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
    print("dispose..");
    noteManager.writeNote(
        Provider.of<NavigationIndexProvider>(context, listen: false).date,
        myTextController.text);
    focusNode.dispose();
    super.dispose();
  }

  Future updateUi() async {
    googlePhotoLinks = [];
    imagesForPlot = [];
    photoDataForPlot = [];
    localPhotoDataForPlot = [[]];

    try {
      var b = await updatePhotoFromLocal();
      imagesForPlot = selectImagesForPlot(localPhotoDataForPlot);
    } catch (e) {
      print("while updating Ui, error is occrued : $e");
    }

    await updateSensorData();

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
          global.kMinimumTimeDifferenceBetweenImages) {
        imagesForPlot.add(input[i]);
        j += 1;
      }
    }
    print("selectImagesForPlot, $imagesForPlot}");

    return imagesForPlot;
  }

  Future updatePhotoFromLocal() async {
    String date =
        Provider.of<NavigationIndexProvider>(context, listen: false).date;
    List<List<dynamic>> files =
        await localPhotoDataManager.getPhotoOfDate(date);
    localPhotoDataForPlot = modifyListForPlot(files, executeTranspose: true);
    localPhotoLinks = transpose(localPhotoDataForPlot);
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

  Future<void> updateSensorData() async {
    String date =
        Provider.of<NavigationIndexProvider>(context, listen: false).date;
    var sensorData = await this.sensorDataManager.openFile(date);
    try {
      sensorDataModified = modifyListForPlot(subsampleList(sensorData, 10));
    } catch (e) {
      sensorDataModified = [[]];
      print("error during updating sensorData : $e");
    }
    sensorDataForPlot = sensorDataModified;
    print("sensorDataForPlot : $sensorDataForPlot");
  }
}
