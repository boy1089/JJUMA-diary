import 'package:flutter/material.dart';
import 'package:test_location_2nd/Photo/PhotoDataManager.dart';
import 'package:test_location_2nd/Sensor/SensorDataManager.dart';
import 'package:test_location_2nd/Util/StateProvider.dart';
import 'package:test_location_2nd/Util/Util.dart';
import 'package:test_location_2nd/Permissions/PermissionManager.dart';
import 'package:test_location_2nd/PolarSensorDataPlot.dart';
import 'package:test_location_2nd/Data/DataManager.dart';
import 'package:provider/provider.dart';
import 'package:test_location_2nd/polarPhotoImageContainer.dart';
import 'package:test_location_2nd/PolarPhotoDataPlot.dart';
import 'package:test_location_2nd/Util/global.dart' as global;
import 'package:test_location_2nd/Note/NoteManager.dart';
import 'package:intl/intl.dart';
import 'package:test_location_2nd/PolarTimeIndicators.dart';
import 'package:test_location_2nd/Util/DateHandler.dart';

class DayPage extends StatefulWidget {
  PermissionManager permissionManager;
  DataManager dataManager;
  SensorDataManager sensorDataManager;
  PhotoDataManager localPhotoDataManager;
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
  late PhotoDataManager localPhotoDataManager;
  late NoteManager noteManager;

  String date = formatDate(DateTime.now());
  Future readData = Future.delayed(const Duration(seconds: 1));
  List photoForPlot = [];
  dynamic photoData = [[]];
  dynamic sensorDataForPlot = [[]];
  List<List<dynamic>> photoDataForPlot = [[]];
  List<List<dynamic>> dummy = [[]];

  FocusNode focusNode = FocusNode();
  final myTextController = TextEditingController();
  var uiStateProvider;

  @override
  void initState() {
    super.initState();
    permissionManager = widget.permissionManager;
    dataManager = widget.dataManager;
    sensorDataManager = widget.sensorDataManager;
    localPhotoDataManager = widget.localPhotoDataManager;
    noteManager = widget.noteManager;
    print("DayPage, after initState : ${photoDataForPlot}");
    readData = _fetchData();
    uiStateProvider = Provider.of<UiStateProvider>(context, listen: false);
    date = Provider.of<NavigationIndexProvider>(context, listen: false).date;
  }

  Future<List<dynamic>> _fetchData() async {
    date = Provider.of<NavigationIndexProvider>(context, listen: false).date;
    await updateDataForUi();
    // provider = Provider.of<UiStateProvider>(context, listen: false);
    uiStateProvider.setZoomInState(false);
    print("fetchData done, $photoDataForPlot");
    await Future.delayed(Duration(seconds: 1));
    return photoDataForPlot;
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
    bool isZoomIn =
        Provider.of<UiStateProvider>(context, listen: true).isZoomIn;
    print("building DayPage..");
    return FutureBuilder(
        future: readData,
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          print("snapshot : ${snapshot.data}. ${snapshot.hasData}");
          return Scaffold(
            backgroundColor: global.kBackGroundColor,
            body: (!snapshot.hasData)
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
                          //action expected
                          //1. if not zoom in
                          //1-1. if image is clicked, then zoom in that location (angle)
                          //1-2. if note is clicked. focus on the editable text
                          //1-3 if image is clicked, when note is focused, dismiss the focus

                          //2. if zoom in
                          //2-1 if image is clicked enlarge the image
                          //2-2 if image is not clicked, dismiss the enlarged image
                          //2-3 if text is clicked, focus on the editable text
                          //2-4 if text is not clicked when note is focused, dismiss the focus

                          if (!global.isImageClicked)
                            global.indexForZoomInImage = -1;
                          global.isImageClicked = false;
                          setState(() {});
                          if (isZoomIn) return;
                          // setState(() {});
                          Offset tapPosition = calculateTapPositionRefCenter(
                              details, 0, layout_dayPage);
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
                            uiStateProvider.setZoomInState(true);
                            isZoomInImageVisible = true;
                            _angle = angleZoomIn;
                            uiStateProvider.setZoomInRotationAngle(_angle);
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
                            uiStateProvider.setZoomInRotationAngle(_angle);
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
                              width: layout_dayPage['graphSize']?[isZoomIn]
                                  ?.toDouble(),
                              height: layout_dayPage['graphSize']?[isZoomIn]
                                  ?.toDouble(),
                              duration:
                                  Duration(milliseconds: global.animationTime),
                              left:
                                  layout_dayPage['left']?[isZoomIn]?.toDouble(),
                              top: layout_dayPage['top']?[isZoomIn]?.toDouble(),
                              // curve: Curves.fastOutSlowIn,
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
                                      polarPhotoImageContainers(photoForPlot)
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
                                  "${DateFormat('EEEE').format(DateTime.parse(date))}/"
                                  "${DateFormat('MMM').format(DateTime.parse(date))} "
                                  "${DateFormat('dd').format(DateTime.parse(date))}/"
                                  "${DateFormat('yyyy').format(DateTime.parse(date))}",
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

  void showKeyboard() {
    focusNode.requestFocus();
    setState(() {});
  }

  void dismissKeyboard() async {
    focusNode.unfocus();
    await noteManager.writeNote(date, myTextController.text);
  }

  @override
  void dispose() {
    print("dispose..");
    noteManager.writeNote(date, myTextController.text);
    focusNode.dispose();
    super.dispose();
  }

  Future<void> updateDataForUi() async {
    photoForPlot = [];
    photoDataForPlot = [];
    photoData = [[]];

    try {
      photoData = await updatePhotoData();
      photoForPlot = selectPhotoForPlot(photoData);
    } catch (e) {
      print("while updating Ui, error is occrued : $e");
    }
    // //convert data type..
    photoDataForPlot = List<List>.generate(
        photoForPlot.length, (index) => photoForPlot.elementAt(index));

    await updateSensorData();

    try {
      myTextController.text = await noteManager.readNote(date);
    } catch (e) {
      print("while updating UI, reading note, error is occured : $e");
    }
    print("updateUi done");
  }

  Future updatePhotoData() async {
    print("dayPage, updatePhotoFromLocal, date : $date");
    List<List<dynamic>> data = await localPhotoDataManager.getPhotoOfDate(date);
    print("dayPage, updatePhotoFromLocal, files : $data");
    photoData = modifyListForPlot(data, executeTranspose: true);
    return photoData;
  }

  List selectPhotoForPlot(List input) {
    print("DayPage selectImageForPlot : ${input}");
    if (input[0] == null) return photoForPlot;
    if (input[0].length == 0) return photoForPlot;

    photoForPlot.add([input.first[0], input.first[1], input.first[2], true]);

    int j = 0;
    for (int i = 1; i < input.length - 2; i++) {
      if ((input[i][0] - photoForPlot[j][0]).abs() >
          global.kMinimumTimeDifferenceBetweenImages) {
        photoForPlot.add([input[i][0], input[i][1], input[i][2], true]);
        j = i;
      } else {
        photoForPlot.add([input[i][0], input[i][1], input[i][2], false]);
      }
    }

    photoForPlot.add([input.last[0], input.last[1], input.last[2], true]);
    print("selectImagesForPlot done, $photoDataForPlot");
    return photoForPlot;
  }

  Future<void> updateSensorData() async {
    var sensorData = await this.sensorDataManager.openFile(date);
    try {
      sensorDataForPlot = modifyListForPlot(subsampleList(sensorData, 10));
    } catch (e) {
      sensorDataForPlot = [[]];
      print("error during updating sensorData : $e");
    }
    print("sensorDataForPlot : $sensorDataForPlot");
  }
}
