import 'package:flutter/material.dart';
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

//TODO : put scroll wheel to select the date.
//TODO : get images from google album



class TestPolarPage extends StatefulWidget {

  SensorDataReader dataReader;

  GoogleAccountManager googleAccountManager;
  PermissionManager permissionManager;
  PhotosLibraryApiClient photoLibraryApiClient;
  DataManager dataManager;

  TestPolarPage(this.dataReader, this.googleAccountManager,
      this.permissionManager, this.photoLibraryApiClient, this.dataManager,
      {Key? key})
      : super(key: key);

  @override
  State<TestPolarPage> createState() => _TestPolarPageState();
}

class _TestPolarPageState extends State<TestPolarPage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  // DataReader dataReader = dataReader;
  var response;
  late SensorDataReader dataReader;
  late GoogleAccountManager googleAccountManager;
  late PermissionManager permissionManager;
  late PhotosLibraryApiClient photoLibraryApiClient;
  late DataManager dataManager;

  int dataIndex = 0;
  List<List<String>> responseResult = [];
  Future readData = Future.delayed(const Duration(seconds: 1));
  int _selectedIndex = 0;
  @override
  void initState() {
    readData = _fetchData();
    super.initState();
    dataReader = widget.dataReader;
    googleAccountManager = widget.googleAccountManager;
    permissionManager = widget.permissionManager;
    photoLibraryApiClient = widget.photoLibraryApiClient;
    dataManager = widget.dataManager;
  }

  Future<List<List<dynamic>>> _fetchData() async {
    await Future.delayed(const Duration(seconds: 5));
    return dataReader.readFiles();
  }

  List<Widget> _widgetOptions = <Widget>[];


  @override
  Widget build(BuildContext context) {

    final deviceWidth = MediaQuery.of(context).size.width;
    final deviceHeight = MediaQuery.of(context).size.height;

    return Scaffold(
        appBar: AppBar(
          title: const Center(
            child: Text(
              "         Auto Diary",
              style: TextStyle(color: Colors.black54),
            ),
          ),
          backgroundColor: Colors.white,
          actions: [
            Padding(
                padding: const EdgeInsets.only(right: 20.0),
                child: GestureDetector(
                    onTap: () {},
                    child: const Icon(Icons.settings_outlined,
                        color: Colors.black54)))
          ],
        ),
        bottomNavigationBar: BottomNavigationBar(
          items : const <BottomNavigationBarItem>[
            BottomNavigationBarItem(icon: Icon(Icons.calendar_today),
            label : "Day"),
            BottomNavigationBarItem(icon: Icon(Icons.calendar_view_week),
                label : "Week"),
            BottomNavigationBarItem(icon: Icon(Icons.calendar_view_month),
                label : "Month"),
          ],
          currentIndex : _selectedIndex,
          onTap: _onBottomNavigationBarTapped,

        ),
        body: FutureBuilder(
            future: readData,
            builder: (BuildContext context, AsyncSnapshot snapshot) {
              debugPrint("snapshot : ${snapshot.data}");

              if (snapshot.hasData == false) {
                return Scaffold(
                  backgroundColor: Colors.white,
                  body: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        CircularProgressIndicator(
                          backgroundColor: Colors.blue,
                          color: Colors.orange,
                          strokeWidth: 4.0,
                        ),
                      ],
                    ),
                  ),
                );
              } else if (snapshot.hasError) {
                return const Text('error');
              } else {
                debugPrint("snap shot data : ${snapshot.data}");
                debugPrint("snap shot data : ${snapshot.data.isEmpty}");
                if (snapshot.data.isEmpty) {
                  // sensorLogger.forceWrite();
                  return const Center(child: Text('no data found'));
                } else if (snapshot.data.toString() == '[[[Data]]]') {
                  return const Center(
                      child: Text('no permission is allowed. \n'
                          'please restart the application and allow the permissions. '));
                }
                return Scaffold(
                  key: _scaffoldKey,
                  backgroundColor: Colors.white,
                  body: SizedBox(
                    height: deviceHeight,
                    width: deviceWidth,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        SizedBox(
                          width: deviceWidth,
                          height: deviceHeight/2,
                          child: Stack(children: [
                            Positioned(
                              left : deviceWidth/2-defaultPolarPlotSize/2,
                              top : deviceHeight/4 - defaultPolarPlotSize/2,
                              child: Container(
                                margin: const EdgeInsets.only(top: 10),
                                width: defaultPolarPlotSize,
                                height: defaultPolarPlotSize,
                                child: PolarSensorDataPlot(
                                        widget.dataReader.dailyDataAll[dataIndex])
                                    .build(context),
                              ),
                            ),
                            Positioned(
                                left : deviceWidth/2 - secondPolarPlotSize/2,
                                top : deviceHeight/4 - secondPolarPlotSize/2,
                                child: Container(
                                  margin: const EdgeInsets.only(top: 10),
                                  width: secondPolarPlotSize,
                                  height: secondPolarPlotSize,
                                  child: PolarPhotoDataPlot(dummyPhotoData)
                                      .build(context),
                                )),
                          ]),
                        ),
                        Center(
                          child: SizedBox(
                              width: deviceWidth,
                              height: 50,
                              //reference : https://www.youtube.com/watch?v=wnTYKJEJ7f4&t=167s
                              child: ListWheelScrollView.useDelegate(
                                  magnification: 1,
                                  squeeze: 1.8,
                                  physics: const FixedExtentScrollPhysics(),
                                  diameterRatio: 0.7,
                                  onSelectedItemChanged: (index) =>
                                      setState(() {
                                        dataIndex = index;
                                        updatePhoto();
                                      }),
                                  itemExtent: 80,
                                  childDelegate: ListWheelChildBuilderDelegate(
                                      builder: (context, index) => Center(
                                            child:
                                                // color : Colors.blue,
                                                Text(dataReader.dates[index],
                                                    style: const TextStyle(
                                                        fontSize: 20,
                                                        color: Colors.black54)),
                                          ),
                                      childCount: dataReader.dailyDataAll.length))),
                        ),
                        Center(
                            child: SizedBox(
                                width: deviceWidth,
                                height: 200,
                                child: responseResult.isEmpty
                                    ? const Text('no links')
                                    : ListView.builder(
                                        scrollDirection: Axis.horizontal,
                                        itemBuilder:
                                            (BuildContext context, int index) {
                                          return Image.network(
                                              responseResult[0][index]);
                                        },
                                        itemCount: responseResult[0].length,
                                      )))
                      ],
                    ),
                  ),
                  floatingActionButton: FloatingActionButton(
                    onPressed: (() async {
                      print(dataReader.dailyDataAll[0]);
                      // dataManager.processAllSensorFiles();
                      // setState(() {});
                    }

                        ),
                  ),
                );
              }
            }));
  }
  void _onBottomNavigationBarTapped(int index){
    setState((){
      _selectedIndex = index;
    });
  }

  void updatePhoto() async {
    String date = dataReader.dates[dataIndex];
    // if(response
    debugPrint(date.substring(4, 6));
    response = await photoLibraryApiClient.getPhotosOfDate(
        date.substring(0, 4), date.substring(4, 6), date.substring(6, 8));
    responseResult = parseResponse(response);
    photoLibraryApiClient.writeCache3(responseResult[0], 'links');
    photoLibraryApiClient.writeCache3(responseResult[1], 'filename');
    setState(() {});
    debugPrint("googleAccount manager : ${googleAccountManager.currentUser}");
  }

  void onSelected(BuildContext context, int item) {
    debugPrint(item.toString());
    switch (item) {
      case 0:
        Navigation.navigateTo(
            context: context,
            screen:
                AndroidSettingsScreen(googleAccountManager, permissionManager),
            style: NavigationRouteStyle.material);
        break;
    }
  }
}
