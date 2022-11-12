import 'dart:math';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
// import 'package:googleapis/shared.dart';
import 'package:graphic/graphic.dart';
import 'package:test_location_2nd/Util/Util.dart';
import 'package:transparent_image/transparent_image.dart';
import 'package:extended_image/extended_image.dart';
import 'package:test_location_2nd/Util/StateProvider.dart';
import 'package:provider/provider.dart';
import 'dart:io';
import 'package:test_location_2nd/Util/global.dart' as global;

import 'package:test_location_2nd/Location/AddressFinder.dart';
import 'package:test_location_2nd/Location/Coordinate.dart';
class PolarTimeIndicators extends StatelessWidget {
  var photoDataForPlot;
  String? date;
  List files = [];
  Map<int, int> selectedIndex = {};
  Map<int, String?> addresses = {};
  List<Placemark?> addressOfFiles = [];
  PolarTimeIndicators(
    this.photoDataForPlot,
      this.addresses,
  )  {
  }

  void init() async {
    files = transpose(photoDataForPlot)[1];
    selectedIndex = selectIndexForLocation(files);
    List<Placemark?> addressOfFiles = await getAddressOfFiles(selectedIndex.values.toList());
    addresses = Map.fromIterable(
        List.generate(selectedIndex.keys.length, (i)=>i),
    key : (item) => selectedIndex.keys.elementAt(item),
    value : (item)=> addressOfFiles.elementAt(item)?.locality);
    print(addresses);
  }

  Map<int, int> selectIndexForLocation(files){
      Map<int, int> indexForSelectedFile = {};
      List<DateTime?> datetimes = List<DateTime?>.generate(files.length, (i)=>global.infoFromFiles[files.elementAt(i)]?.datetime);
      List<int> times = List<int>.generate(datetimes.length, (i)=>datetimes[i]!.hour);
      Set<int> setOfTimes = times.toSet();
      for(int i =0; i<setOfTimes.length; i++)
        indexForSelectedFile[setOfTimes.elementAt(i)] = (times.indexOf(setOfTimes.elementAt(i)));
    return indexForSelectedFile;
  }

  Future<List<Placemark?>> getAddressOfFiles(List<int> index) async {
    List<Placemark?> listOfAddress = [];
    for(int i=0; i<index.length; i++){
      Coordinate? coordinate = global.infoFromFiles[files[index.elementAt(i)]]!.coordinate;
      print(coordinate);
      if(coordinate==null) {
        listOfAddress.add(null);
      }
      Placemark? address = await AddressFinder.getAddressFromCoordinate(coordinate?.latitude, coordinate?.longitude);
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
                (int index) =>
                    PolarTimeIndicator(index, photoDataForPlot, addresses[index]
                    ).build(context)))
        : Text("");
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
  PolarTimeIndicator(index, photoDataForPlot, address) {
    this.photoDataForPlot = photoDataForPlot;
    this.containerSize = containerSize;
    this.index = index;
    this.numberOfImages = numberOfImages;
    xLocation = imageLocationFactor *
        cos((index) / 24 * 2 * pi - pi / 2) *
        (0.45 + 0.10 * 1);
    yLocation = imageLocationFactor *
        sin((index) / 24 * 2 * pi - pi / 2) *
        (0.45 + 0.1 * 1);
    date = date;

      this.address = address;
  }

  @override
  Widget build(BuildContext context) {
    var provider = Provider.of<DayPageStateProvider>(context, listen: true);
    return Align(
      alignment: Alignment(xLocation, yLocation),
      child: Transform.rotate(
          angle: atan2(yLocation, xLocation),
          child: SizedBox(
            child: Text(
              address==null? "$index" :"$index\n$address",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 60, color: global.kColor_backgroundText),
            ),
          )),
    );
  }
}
