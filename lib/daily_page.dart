
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:graphic/graphic.dart';
import 'package:intl/intl.dart';
import '../DataReader.dart';

final _monthDayFormat = DateFormat('MM-dd');

//TODO : put scrol wheel to select the date.
//TODO : get images from google album
class TestPolarPage extends StatelessWidget {
  DataReader dataReader;
  TestPolarPage(DataReader dataReader, {Key? key})
      : this.dataReader = dataReader,
        super(key: key);

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: const Text('Line and Area Element'),
      ),
      backgroundColor: Colors.white,
      body: Container(
        height : 400,
        width : 500,

        child : Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,

          children: <Widget>[
            SizedBox(
              child: FutureBuilder(
                  future : dataReader.readFiles(),
                  builder : (BuildContext context, AsyncSnapshot snapshot){
                    if (snapshot.hasData == false){
                      return CircularProgressIndicator();
                    }
                    else if (snapshot.hasError){
                      return Text('error');
                    }
                    else {
                      return Container(
                        margin: const EdgeInsets.only(top: 10),
                        width: 400,
                        height: 300,
                        child: Chart(
                          data: dataReader.dataAll[1],
                          variables: {
                            '0': Variable(
                              accessor: (List datum) => datum[0] as num,
                              scale: LinearScale(min: 0, max: 24, tickCount: 5),

                            ),
                            '1': Variable(
                              accessor: (List datum) => datum[1] as num,

                            ),
                            '2': Variable(
                              accessor: (List datum) => datum[2] as num,
                            ),
                            '3': Variable(
                              accessor: (List datum) => datum[3] as num,
                            ),

                            '4': Variable(
                              accessor: (List datum) => datum[4] as num,
                            ),
                          },
                          elements: [
                            PointElement(
                              size: SizeAttr(variable: '3', values: [1, 2]),
                              color: ColorAttr(
                                variable: '3',
                                values: Defaults.colors20,
                                updaters: {
                                  'choose': {true: (_) => Colors.red}
                                },
                              ),
                              // shape: ShapeAttr(variable: '3', values: [
                              //   CircleShape(hollow: true),
                              //   SquareShape(hollow: true),
                              // ]),
                            )
                          ],
                          axes: [
                            Defaults.circularAxis
                              ..labelMapper = (_, index, total) {
                                if (index == total - 1) {
                                  return null;
                                }
                                return LabelStyle(style: Defaults.textStyle);
                              }
                              ..label = null,
                            Defaults.radialAxis
                              ..labelMapper = (_, index, total) {
                                if (index == total - 1) {
                                  return null;
                                }
                                return LabelStyle(style: Defaults.textStyle);
                              }
                              ..label = null,
                          ],
                          coord: PolarCoord(),
                          selections: {'choose': PointSelection(toggle: true)},
                          tooltip: TooltipGuide(
                            anchor: (_) => Offset.zero,
                            align: Alignment.bottomRight,
                            multiTuples: true,
                          ),

                        ),
                      );
                    }


                  }
              ),
            ),

          ],
          // )
        ),

      ),
      floatingActionButton: FloatingActionButton(
        onPressed : ((){
          print(dataReader.dataAll[0].first);
          print(dataReader.dataAll[0].last);
        }),
      ),
    );
  }
}

