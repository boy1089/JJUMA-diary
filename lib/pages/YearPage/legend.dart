import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../StateProvider/year_page_state_provider.dart';

class LegendOfYearChart extends StatelessWidget {
  late YearPageStateProvider provider;
  LegendOfYearChart({Key? key}) : super(key: key);

  Map<String, Color> items = {
    "Most frequent": Colors.blue,
    "< 1km": Colors.green,
    "< 5km": Colors.yellow,
    "< 20km": Colors.red,
    ">100km": Colors.purple
  };

  Widget legendItem(product, Color color, String text) {
    bool enabled = product.enabledLocations[text];
    print(enabled);
    Color textColor = enabled? Colors.white : Colors.grey;
    color = enabled? color:color.withAlpha(100);

    return TextButton(
      style: TextButton.styleFrom(
        padding: const EdgeInsets.all(0),
      ),
      onPressed: () {
        product.setEnabledLocation(text);
      },
      child: Row(children: [
        Container(
          color: color,
          width: 20,
          height: 20,
          margin: const EdgeInsets.all(2),
        ),
        Text(
          text,
          style:  TextStyle(color: textColor),
        )
      ]),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<YearPageStateProvider>(
      builder: (context, product, child) => Row(
          children: List.generate(
              items.length,
              (i) => legendItem(product, items.values.elementAt(i),
                  items.keys.elementAt(i)))),
    );
  }
}
