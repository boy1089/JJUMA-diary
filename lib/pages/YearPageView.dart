
import 'package:flutter/material.dart';
import 'package:test_location_2nd/Util/StateProvider.dart';
import 'YearPage.dart';
import 'package:provider/provider.dart';

class YearPageView extends StatelessWidget {
  YearPageView({Key? key}) : super(key: key){
  }


  int year = DateTime.now().year;



  @override
  Widget build(BuildContext context) {

    return Scaffold(
      body : PageView.builder(
          controller : PageController(initialPage : 0),
          itemCount:20,
          reverse : true,
          itemBuilder: (BuildContext context, int index){
            year = DateTime.now().year - index;
            Provider.of<YearPageStateProvider>(context, listen: false).setYear(year);
            return YearPage();
      })

    );
  }
}
