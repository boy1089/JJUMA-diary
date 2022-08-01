import 'package:flutter/material.dart';
import 'package:test_location_2nd/ImageReader.dart';

import 'dart:math';
import 'dart:async';

class CalendarPage extends StatefulWidget {
  const CalendarPage({Key? key}) : super(key: key);

  @override
  State<CalendarPage> createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> {
  var imageReader;

  _CalendarPageState() {
    init();
  }

  void initState() {
    super.initState();
  }

  void init() async {
    imageReader = ImageReader('all');
    debugPrint("CalendarPage, init, ${imageReader.datesRange}");
    // setState(() {});
  }

  Future<ImageReader> _getImageReader() {
    return Future<ImageReader>.delayed(Duration(seconds: 5), () => imageReader);
  }

  Widget Button(String text, String numberOfFiles, bool isThereData) {
    var date = 'null';
    date = text.substring(4, 8);

    var color = '2F1BDB';
    return Container(
        // flex: 2,
        width: 50,
        height: 50,
        decoration: BoxDecoration(
          color: Color.fromARGB(
              min(255, int.parse(numberOfFiles) * 3), 200, 100, 100),
          shape: BoxShape.rectangle,
          borderRadius: BorderRadius.all(Radius.circular(10.0)),
        ),
        child: FlatButton(
            padding: EdgeInsets.all(5),
            height: 20,
            child: Text("$date, $numberOfFiles", style: TextStyle(fontSize: 8)),
            onPressed: () {
              debugPrint("buttonPressed");
              Navigator.pushNamed(
                context,
                '/day',
                arguments: {
                  'date': text,
                },
              );
            }));
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        home: Scaffold(
      body: //Text('aaa'),
          FutureBuilder<ImageReader>(
              future: _getImageReader(),
              builder:
                  (BuildContext context, AsyncSnapshot<ImageReader> snapshot) {
                int i_image = 0;
                // debugPrint("$i_image");
                var data = snapshot.data;
                // debugPrint("${data?.dates}");
                // debugPrint("${imageReader.datesRange[0]}");
                return SafeArea(
                    minimum: EdgeInsets.all(30),
                    child: GridView.builder(
                        physics: AlwaysScrollableScrollPhysics(),
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 7,
                          crossAxisSpacing: 10,
                          mainAxisSpacing: 10,
                        ),
                        itemCount: imageReader.datesRange.length,
                        // itemCount: 20,
                        itemBuilder: (context, index) {
                          // debugPrint("build gridview, $index");
                          // debugPrint(
                          //     "build gridview, datesRange ${data?.datesRange[index]}");
                          // debugPrint(
                          //     "build gridview, dates ${data?.dates[i_image]}");
                          // debugPrint("build gridview, i_image $i_image}");
                          bool isThereData = imageReader.datesRange[index] ==
                              imageReader.dates[i_image];
                          var button = Button(
                              imageReader.datesRange[index],
                              imageReader.datesRange[index] ==
                                      imageReader.dates[i_image]
                                  ? imageReader.numberOfFiles[i_image]
                                  : "0",
                              isThereData);
                          if (data?.datesRange[index] == data?.dates[i_image]) {
                            i_image += 1;
                          }
                          return button;
                        }));
              }),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // print("${imageReader.filesAll}");
          print("${imageReader.dates}");
          setState(() {});
        },
      ),
    ));
  }
}
