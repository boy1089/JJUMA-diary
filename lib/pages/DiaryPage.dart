import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:test_location_2nd/Util/StateProvider.dart';
import 'package:test_location_2nd/Util/Util.dart';
import 'package:test_location_2nd/Util/DateHandler.dart';
import 'package:test_location_2nd/Util/global.dart' as global;
import 'package:test_location_2nd/Data/DataManager.dart';
import 'package:intl/intl.dart';
import 'package:badges/badges.dart';

class DiaryPage extends StatefulWidget {

  DataManager dataManager;

  @override
  State<DiaryPage> createState() => _DiaryPageState();

  DiaryPage(this.dataManager, {Key? key}) : super(key: key);
}


class _DiaryPageState extends State<DiaryPage> {
  late DataManager dataManager;

  @override
  void initState() {
    this.dataManager = widget.dataManager;
  }

  @override
  Widget build(BuildContext buildContext) {
    return Scaffold(
      body: Center(child:Text('aaa'),
    ));
  }
}


