import 'package:flutter/material.dart';
import 'package:test_location_2nd/Photo/PhotoDataManager.dart';
import 'package:test_location_2nd/Sensor/SensorDataManager.dart';
import 'package:test_location_2nd/StateProvider/StateProvider.dart';
import 'package:test_location_2nd/Util/Util.dart';
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

import 'package:test_location_2nd/Location/AddressFinder.dart';
import 'package:test_location_2nd/Location/Coordinate.dart';
import 'package:geocoding/geocoding.dart';
import 'package:test_location_2nd/CustomWidget/ZoomableWidgets.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:flutter_keyboard_size/flutter_keyboard_size.dart';

import 'package:test_location_2nd/StateProvider/DayPageStateProvider.dart';
import 'package:test_location_2nd/StateProvider/NavigationIndexStateProvider.dart';

class DayPage extends StatefulWidget {
  DataManager dataManager;
  SensorDataManager sensorDataManager;
  PhotoDataManager localPhotoDataManager;
  NoteManager noteManager;

  @override
  State<DayPage> createState() => _DayPageState();

  DayPage(this.dataManager, this.sensorDataManager, this.localPhotoDataManager,
      this.noteManager,
      {Key? key})
      : super(key: key);
}

class _DayPageState extends State<DayPage> {
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
  Map<int, String?> addresses = {};

  FocusNode focusNode = FocusNode();
  final myTextController = TextEditingController();
  var dayPageStateProvider;
  List files = [];

  @override
  void initState() {
    super.initState();
    dataManager = widget.dataManager;
    sensorDataManager = widget.sensorDataManager;
    localPhotoDataManager = widget.localPhotoDataManager;
    noteManager = widget.noteManager;
    print("DayPage, after initState : ${photoDataForPlot}");
    readData = _fetchData();
    dayPageStateProvider =
        Provider.of<DayPageStateProvider>(context, listen: false);
    date = Provider.of<NavigationIndexProvider>(context, listen: false).date;
  }

  Future<List<dynamic>> _fetchData() async {
    date = Provider.of<NavigationIndexProvider>(context, listen: false).date;
    await updateDataForUi();
    // provider = Provider.of<UiStateProvider>(context, listen: false);
    dayPageStateProvider.setZoomInState(false);
    print("fetchData done, $photoDataForPlot");
    await Future.delayed(Duration(seconds: 1));
    return photoDataForPlot;
  }

  bool isZoomInImageVisible = false;
  double _angle = 0;

  late double graphSize = physicalWidth - global.kMarginForDayPage * 2;

  //layout for zoomIn and zoomOut state
  late Map layout_dayPage = {
    'graphSize': {
      true: graphSize * global.kMagnificationOnDayPage,
      false: graphSize
    },
    // 'left': {true: -graphSize * 5.5, false: (physicalWidth - graphSize) / 2},
    'left': {
      true:
          -graphSize * (global.kMagnificationOnDayPage / 2) * (1 + (1 - 0.43)),
      false: global.kMarginForDayPage
    },
    'top': {
      true: null,
      false: (physicalHeight -
                  global.kBottomNavigationBarHeight -
                  global.kHeightOfArbitraryWidgetOnBottom) *
              (global.kYPositionRatioOfGraph) -
          graphSize / 2
    },
    'graphCenter': {
      true: null,
      false: Offset(
          physicalWidth / 2,
          (physicalHeight -
                  global.kBottomNavigationBarHeight -
                  global.kHeightOfArbitraryWidgetOnBottom) *
              (global.kYPositionRatioOfGraph))
    },

    'textHeight': {
      true: physicalHeight -
          graphSize -
          (physicalHeight -
                  global.kBottomNavigationBarHeight -
                  global.kHeightOfArbitraryWidgetOnBottom) *
              (global.kYPositionRatioOfGraph) -
          global.kImageSize,
      false: physicalHeight -
          graphSize -
          ((physicalHeight -
                      global.kBottomNavigationBarHeight -
                      global.kHeightOfArbitraryWidgetOnBottom) *
                  (global.kYPositionRatioOfGraph) -
              graphSize / 2) -
          global.kImageSize * 2 / 3
    }
  };
  double firstContainerSize = 1000;

  void showKeyboard() {
    focusNode.requestFocus();
    setState(() {});
  }

  void dismissKeyboard() async {
    focusNode.unfocus();
    await noteManager.writeNote(date, myTextController.text);
  }

  @override
  Widget build(BuildContext context) {
    print("building DayPage..");

    return Consumer<DayPageStateProvider>(
        builder: (context, product, child) =>
        FutureBuilder(
        future: readData,
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          print("snapshot : ${snapshot.data}. ${snapshot.hasData}");
          return Scaffold(
            backgroundColor: global.kBackGroundColor,
            body: (!snapshot.hasData)
                ? Center(
                    child: SizedBox(
                        width: global.kSizeOfProgressIndicator,
                        height: global.kSizeOfProgressIndicator,
                        child: CircularProgressIndicator(
                          strokeWidth: global.kStrokeWidthOfProgressIndicator,
                        )))
                : RawGestureDetector(
                    behavior: HitTestBehavior.deferToChild,
                    gestures: {
                      AllowMultipleGestureRecognizer:
                          GestureRecognizerFactoryWithHandlers<
                                  AllowMultipleGestureRecognizer>(
                              () => AllowMultipleGestureRecognizer(),
                              (AllowMultipleGestureRecognizer instance) {
                        instance.onTapUp = (details) {
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
                          if (product.isZoomIn) return;
                          // setState(() {});
                          Offset tapPosition = calculateTapPositionRefCenter(
                              details, 0, layout_dayPage);
                          double angleZoomIn =
                              calculateTapAngle(tapPosition, 0, 0);

                          if (details.globalPosition.dy >
                              physicalHeight -
                                  layout_dayPage['textHeight'][false] -
                                  60) return;
                          //if editing text, doesn't zoom in.
                          if (focusNode.hasFocus) {
                            print("has focus? ${focusNode.hasFocus}");
                            dismissKeyboard();
                            setState(() {});
                            return;
                          }
                          setState(() {
                            product.setZoomInState(true);
                            isZoomInImageVisible = true;
                            product.setZoomInRotationAngle(_angle);
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
                            if (!product.isZoomIn) return;
                            product.setZoomInRotationAngle(
                                product.isZoomIn ? product.zoomInAngle + details.delta.dy / 1000 : 0);
                          };
                        },
                      )
                    },
                    child: Stack(
                        alignment:
                            product.isZoomIn ? Alignment.center : Alignment.topCenter,
                        children: [
                          ZoomableWidgets(
                                  widgets: [
                                PolarTimeIndicators(photoForPlot, addresses)
                                    .build(context),
                                PolarSensorDataPlot(
                                        (sensorDataForPlot[0].length == 0) |
                                                (sensorDataForPlot.length == 0)
                                            ? global.dummyData1
                                            : sensorDataForPlot)
                                    .build(context),
                                PolarPhotoDataPlot(photoDataForPlot)
                                    .build(context),
                                polarPhotoImageContainers(photoForPlot)
                                    .build(context),
                              ],
                                  layout: layout_dayPage,
                                  isZoomIn: product.isZoomIn,
                                  provider: product)
                              .build(context),
                          KeyboardVisibilityBuilder(
                              builder: (context, isKeyboardVisible) {
                            print("isKeyboardVisible : $isKeyboardVisible");
                            print(MediaQuery.of(context).viewInsets.top - 100);
                            return Positioned(
                              width: physicalWidth,
                              height: isKeyboardVisible
                                  ? physicalHeight - 200 - 200
                                  : layout_dayPage['textHeight'][false],
                              bottom: global.kMarginOfBottomOnDayPage,
                              child: Container(
                                margin: EdgeInsets.all(10),
                                // height: !focusNode.hasFocus
                                //     ? physicalHeight / 2 - 200
                                //     : physicalHeight / 2 - 200,
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
                            );
                          }),
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
        }));
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

    addresses = await updateAddress();

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

  Future<Map<int, String?>> updateAddress() async {
    Map<int, int> selectedIndex = {};
    Map<int, String?> addresses = {};
    List<Placemark?> addressOfFiles = [];
    files = transpose(photoForPlot)[1];
    selectedIndex = selectIndexForLocation(files);
    addressOfFiles = await getAddressOfFiles(selectedIndex.values.toList());
    addresses = Map<int, String?>.fromIterable(
        List.generate(selectedIndex.keys.length, (i) => i),
        key: (item) => selectedIndex.keys.elementAt(item),
        // value: (item) => "${addressOfFiles
        //     .elementAt(item)
        //     ?.locality}, ${addressOfFiles.elementAt(item)?.thoroughfare}" );
        value: (item) => "${addressOfFiles.elementAt(item)?.locality}");

    print(addressOfFiles.elementAt(0));
    return addresses;
  }

  Map<int, int> selectIndexForLocation(files) {
    Map<int, int> indexForSelectedFile = {};
    List<DateTime?> datetimes = List<DateTime?>.generate(files.length,
        (i) => global.infoFromFiles[files.elementAt(i)]?.datetime);
    List<int> times =
        List<int>.generate(datetimes.length, (i) => datetimes[i]!.hour);
    Set<int> setOfTimes = times.toSet();
    for (int i = 0; i < setOfTimes.length; i++)
      indexForSelectedFile[setOfTimes.elementAt(i)] =
          (times.indexOf(setOfTimes.elementAt(i)));
    return indexForSelectedFile;
  }

  Future<List<Placemark?>> getAddressOfFiles(List<int> index) async {
    List<Placemark?> listOfAddress = [];
    for (int i = 0; i < index.length; i++) {
      Coordinate? coordinate =
          global.infoFromFiles[files[index.elementAt(i)]]!.coordinate;
      print(coordinate);
      if (coordinate == null) {
        listOfAddress.add(null);
      }
      Placemark? address = await AddressFinder.getAddressFromCoordinate(
          coordinate?.latitude, coordinate?.longitude);
      listOfAddress.add(address);
    }
    return listOfAddress;
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
