import 'package:flutter/material.dart';
import 'package:test_location_2nd/Permissions/GoogleAccountManager.dart';
import '../Sensor/SensorDataReader.dart';
import '../navigation.dart';
import 'package:test_location_2nd/pages/SettingPage.dart';
import 'package:test_location_2nd/Permissions/PermissionManager.dart';
import 'package:test_location_2nd/Api/PhotoLibraryApiClient.dart';
import 'package:test_location_2nd/Util/responseParser.dart';
import 'package:test_location_2nd/Data/DataManager.dart';
import 'WeekPage.dart';
import 'MonthPage.dart';
import 'DayPage.dart';
import 'package:provider/provider.dart';
import 'package:test_location_2nd/StateProvider.dart';
import 'package:test_location_2nd/GooglePhotoDataManager.dart';
import 'package:test_location_2nd/Sensor/SensorDataManager.dart';

//TODO : put shared data in provider(date,
//TODO : make consistency on datetime handling - datetime or date?
//TODO : formatting list for chart data
//TODO : refactoring -
//TODO : refactoring - dataManager-data reader

class MainPage extends StatefulWidget {
  // SensorDataReader dataReader;
  GoogleAccountManager googleAccountManager;
  PermissionManager permissionManager;
  PhotosLibraryApiClient photoLibraryApiClient;
  DataManager dataManager;
  GooglePhotoDataManager googlePhotoDataManager;
  SensorDataManager sensorDataManager;

  MainPage(
      // this.dataReader,
      this.googleAccountManager,
      this.permissionManager,
      this.photoLibraryApiClient,
      this.dataManager,
      this.googlePhotoDataManager,
      this.sensorDataManager,
      {Key? key})
      : super(key: key);

  @override
  State<MainPage> createState() => MainPageState();
}

class MainPageState extends State<MainPage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  var response;
  // late SensorDataReader dataReader;
  late GoogleAccountManager googleAccountManager;
  late PermissionManager permissionManager;
  late PhotosLibraryApiClient photoLibraryApiClient;
  late DataManager dataManager;
  late GooglePhotoDataManager googlePhotoDataManager;
  late SensorDataManager sensorDataManager;

  int dataIndex = 0;
  List<List<String>> responseResult = [];
  Future readData = Future.delayed(const Duration(seconds: 1));

  List<Widget> _widgetOptions = [];
  int a = 0;
  late MonthPage monthPage;
  late DayPage dayPage;

  @override
  void initState() {
    readData = _fetchData();
    super.initState();
    // dataReader = widget.dataReader;
    googleAccountManager = widget.googleAccountManager;
    permissionManager = widget.permissionManager;
    photoLibraryApiClient = widget.photoLibraryApiClient;
    dataManager = widget.dataManager;
    googlePhotoDataManager = widget.googlePhotoDataManager;
    sensorDataManager = widget.sensorDataManager;

    DayPage dayPage = DayPage(
        // dataReader,
        googleAccountManager,
        permissionManager,
        photoLibraryApiClient,
        dataManager,
        googlePhotoDataManager,
        sensorDataManager);
    // WeekPage weekPage = WeekPage(dataReader, googleAccountManager,
    //     permissionManager, photoLibraryApiClient, dataManager);
    MonthPage monthPage = MonthPage(a);

    _widgetOptions = <Widget>[
      dayPage,
      // weekPage,
      monthPage,
    ];
  }

  Future<List<List<dynamic>>> _fetchData() async {
    await Future.delayed(const Duration(seconds: 2));
    // return dataReader.readFiles();
    return [[]];
  }

  @override
  Widget build(BuildContext context) {
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
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
              icon: Icon(Icons.calendar_today), label: "Day"),
          BottomNavigationBarItem(
              icon: Icon(Icons.calendar_view_month), label: "Month"),
        ],
        currentIndex: context.watch<NavigationIndexProvider>().navigationIndex,
        onTap: (index) {
          Provider.of<NavigationIndexProvider>(context, listen: false)
              .setNavigationIndex(index);

          // context.watch<NavigationIndexProvider>().setIndex(index);
        },
      ),
      body: FutureBuilder(
          future: readData,
          builder: (BuildContext context, AsyncSnapshot snapshot) {
            print(
                "value from provider : ${context.watch<NavigationIndexProvider>().navigationIndex}");
            if (snapshot.hasData == false) {
              return Center(child: CircularProgressIndicator());
            } else {
              return _widgetOptions[
                  context.watch<NavigationIndexProvider>().navigationIndex];
            }
          }),
      // floatingActionButton: FloatingActionButton(
      //   onPressed: () async {
      //     // var photoResponse = await googlePhotoManager.getPhoto(photoLibraryApiClient, "20221004");
      //     googlePhotoManager.getAndSaveAllPhoto(photoLibraryApiClient, "20220601", "20220602");
      //
      //     // print(googlePhotoManager.photoResponseAll.keys);
      //     // print(googlePhotoManager.photoResponseAll);
      //
      //   },
      // ),
    );
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
