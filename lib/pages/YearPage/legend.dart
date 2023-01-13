import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:jjuma.d/Util/Util.dart';
import 'package:provider/provider.dart';
import '../../StateProvider/year_page_state_provider.dart';

class LegendOfYearChart extends StatelessWidget {
  late YearPageStateProvider provider;
  LegendOfYearChart({Key? key}) : super(key: key);

  Map<String, Color> items = {
    "Most frequent": colorList2.elementAt(0),
    "< 5km": colorList2.elementAt(1),
    "< 20km": colorList2.elementAt(2),
    "< 100km": colorList2.elementAt(3),
    "< 500km": colorList2.elementAt(4),
    'more' : colorList2.elementAt(5),
  };

  @override
  Widget build(BuildContext context) {
    return Consumer<YearPageStateProvider>(
      builder: (context, product, child) =>
          // Row(
          // children: List.generate(
          //     items.length,
          //     (i) => legendItem(product, items.values.elementAt(i),
          //         items.keys.elementAt(i), context))),
      SizedBox(
        width : physicalWidth,
        height : 30,
        child: ListView(
          scrollDirection: Axis.horizontal,
          children: List.generate(items.length, (i)=> legendItem(product, items.values.elementAt(i),
                items.keys.elementAt(i), context))),
      ),
    );
  }

  Widget legendItem(product, Color color, String text, context) {
    bool enabled = product.enabledLocations[text];
    Color textColor = enabled ? Colors.white : Colors.grey;
    color = enabled ? color : color.withAlpha(100);

    return TextButton(
      style: TextButton.styleFrom(
        padding: const EdgeInsets.all(0),
      ),

      child: Row(children: [
        Container(
          color: color,
          width: 20,
          height: 20,
          margin: const EdgeInsets.all(2),
        ),
        Text(
          text,
          style: TextStyle(color: textColor),
        )
      ]),
      onPressed: () {
        if (product.isUpdating) {
          SnackBar snackBar = const SnackBar(
            content: Text('Sorry, JJUMA diary is working on the previous action!'),
          );
          ScaffoldMessenger.of(context).showSnackBar(snackBar);
          return;
        }
        product.setEnabledLocation(text);
      },
    );
  }

}
