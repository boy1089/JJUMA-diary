import 'dart:math';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:lateDiary/Data/file_info_model.dart';
import 'package:lateDiary/Util/Util.dart';
import 'package:provider/provider.dart';
import 'package:lateDiary/Location/AddressFinder.dart';
import 'package:lateDiary/Location/Coordinate.dart';
import 'package:lateDiary/StateProvider/DayPageStateProvider.dart';
import 'package:lateDiary/Data/DataManagerInterface.dart';
import 'package:lateDiary/Util/global.dart' as global;

class PolarTimeIndicators extends StatelessWidget {
  var photoDataForPlot;
  String? date;
  List files = [];
  Map<int, int> selectedIndex = {};
  Map<int, String?> addresses = {};
  List<Placemark?> addressOfFiles = [];
  DataManagerInterface dataManager = DataManagerInterface(global.kOs);
  PolarTimeIndicators(this.photoDataForPlot, this.addresses, {super.key});

  void init() async {
    files = transpose(photoDataForPlot)[1];
    selectedIndex = selectIndexForLocation(files);
    List<Placemark?> addressOfFiles =
        await getAddressOfFiles(selectedIndex.values.toList());
    addresses = {
      for (var item in List.generate(selectedIndex.keys.length, (i) => i))
        selectedIndex.keys.elementAt(item):
            addressOfFiles.elementAt(item)?.locality
    };
  }

  Map<int, int> selectIndexForLocation(files) {
    Map<int, int> indexForSelectedFile = {};
    List<DateTime?> datetimes = List<DateTime?>.generate(
        files.length,
        // (i) => dataManager.infoFromFiles[files.elementAt(i)]?.datetime);
        (i) => dataManager.filesInfo.data[files.elementAt(i)]?.data
            .elementAt(columns.datetime.index));

    List<int> times =
        List<int>.generate(datetimes.length, (i) => datetimes[i]!.hour);
    Set<int> setOfTimes = times.toSet();
    for (int i = 0; i < setOfTimes.length; i++) {
      indexForSelectedFile[setOfTimes.elementAt(i)] =
          (times.indexOf(setOfTimes.elementAt(i)));
    }
    return indexForSelectedFile;
  }

  Future<List<Placemark?>> getAddressOfFiles(List<int> index) async {
    List<Placemark?> listOfAddress = [];
    for (int i = 0; i < index.length; i++) {
      Coordinate? coordinate =
          dataManager.infoFromFiles[files[index.elementAt(i)]]!.coordinate;
      if (coordinate == null) {
        listOfAddress.add(null);
      }
      Placemark? address = await AddressFinder.getAddressFromCoordinate(
          coordinate?.latitude, coordinate?.longitude);
      listOfAddress.add(address);
    }
    return listOfAddress;
  }

  @override
  Widget build(BuildContext context) {
    return Provider.of<DayPageStateProvider>(context, listen: true).isZoomIn
        ? Stack(
            children: List<Widget>.generate(
                24,
                (int index) => PolarTimeIndicator(
                        index, photoDataForPlot, addresses[index])
                    .build(context)))
        : const Text("");
    // return Stack(
    // children: List<Widget>.generate(
    //     24, (int index) => PolarTimeIndicator(index).build(context)));
  }
}

class PolarTimeIndicator {
  var photoDataForPlot;
  double imageLocationFactor = 1.4;
  double imageSize = 90;
  double defaultImageSize = 100;
  double zoomInImageSize = 300;
  double xLocation = 0;
  double yLocation = 0;
  double containerSize = kSecondPolarPlotSize;
  int index = -1;
  int numberOfImages = 0;

  String? fileForLocation;
  String? date;
  var address;
  PolarTimeIndicator(this.index, this.photoDataForPlot, this.address) {
    containerSize = containerSize;
    numberOfImages = numberOfImages;
    xLocation = imageLocationFactor *
        cos((index) / 24 * 2 * pi - pi / 2) *
        (0.45 + 0.10 * 1);
    yLocation = imageLocationFactor *
        sin((index) / 24 * 2 * pi - pi / 2) *
        (0.45 + 0.1 * 1);
    date = date;
  }

  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment(xLocation, yLocation),
      child: Transform.rotate(
          angle: atan2(yLocation, xLocation),
          child: SizedBox(
            child: Text(
                [null, "null"].contains(address)
                    ? "$index"
                    : "$index\n$address",
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headline2),
          )),
    );
  }
}
