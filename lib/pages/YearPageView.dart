
import 'package:flutter/material.dart';
import 'YearPage.dart';

class YearPageView extends StatelessWidget {
  const YearPageView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body : PageView.builder(
          controller : PageController(initialPage : 0),
          itemCount:20,
          reverse : true,
          itemBuilder: (BuildContext context, int index){
            return YearPage(DateTime.now().year - index);
      })

    );
  }
}
