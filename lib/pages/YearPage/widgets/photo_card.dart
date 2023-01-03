import 'dart:async';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:jjuma.d/Data/data_manager_interface.dart';
import 'package:jjuma.d/Data/info_from_file.dart';
import 'package:jjuma.d/Util/Util.dart';
import 'dart:io';
import 'package:extended_image/extended_image.dart';
import 'package:photo_manager/photo_manager.dart';

import '../../../Util/DateHandler.dart';
import 'package:jjuma.d/Util/global.dart' as global;
import 'package:clickable_list_wheel_view/clickable_list_wheel_widget.dart';

import '../../event.dart';

class PhotoCard extends StatefulWidget {
  Event event;
  bool isMagnified = false;
  double height = 200;
  int scrollIndex = 0;
  bool isTickEnabled = false;
  String tag;
  String? filenameOfFavoriteImage;
  PhotoCard({
    super.key,
    this.isMagnified = false,
    this.height = 200,
    this.scrollIndex = 0,
    this.isTickEnabled = false,
    required this.tag,
    required this.event,
    this.filenameOfFavoriteImage,
  });
  @override
  State<PhotoCard> createState() => _PhotoCardState();
}

class _PhotoCardState extends State<PhotoCard> {
  String defaultText = "Write your note here!";
  int scrollIndex = 0;
  FocusNode focusNode = FocusNode();
  DateTime dateTime = DateTime.now();
  TextEditingController controller = TextEditingController();
  FixedExtentScrollController scrollController1 = FixedExtentScrollController();
  FixedExtentScrollController scrollController2 = FixedExtentScrollController();

  String? filenameOfFavoriteImage;
  int? indexOfFavoriteImage;

  late List<dynamic> listOfImages;
  late List<dynamic> listOfImages_sub;

  @override
  void initState() {
    super.initState();
    dateTime = widget.event.images.entries.elementAt(0).value.datetime!;
    var dataManager = DataManagerInterface(global.kOs);
    print("numberOfImages : ${widget.event.images.length}");

    if (dataManager.noteForChart2[dateTime.year.toString()]
            ?[formatDate(dateTime)] !=
        null) {
      controller.text = dataManager.noteForChart2[dateTime.year.toString()]
              ?[formatDate(dateTime)] ??
          "";
    }

    controller.text = defaultText;
    if (dataManager.filenameOfFavoriteImages[dateTime.year.toString()]
            ?[formatDate(dateTime)] !=
        null)
      filenameOfFavoriteImage =
          dataManager.filenameOfFavoriteImages[dateTime.year.toString()]
              ?[formatDate(dateTime)];

    final keyList =
        List.generate(widget.event.images.length, (index) => GlobalKey());

    filenameOfFavoriteImage = widget.filenameOfFavoriteImage;
    print(
        "index : ${widget.event.images.keys.toList().indexOf(filenameOfFavoriteImage)}");
    indexOfFavoriteImage =
        widget.event.images.keys.toList().indexOf(filenameOfFavoriteImage);

    if (indexOfFavoriteImage != -1) {
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        await Future.delayed(const Duration(milliseconds: 2000));
        Scrollable.ensureVisible(
          keyList[indexOfFavoriteImage!].currentContext!,
          duration: const Duration(milliseconds: 300),
          curve: Curves.bounceInOut,
        );
      });
    }
    if (filenameOfFavoriteImage != null) {
      scrollController1 =
          FixedExtentScrollController(initialItem: indexOfFavoriteImage!);
      scrollController2 =
          FixedExtentScrollController(initialItem: indexOfFavoriteImage!);
    }

    updateListOfImages();
  }

  void updateListOfImages() {
    listOfImages = [];
    listOfImages_sub = [];
    List<MapEntry<dynamic, InfoFromFile>> entries =
        widget.event.images.entries.toList();

    switch (global.kOs) {
      case ("android"):
        {
          for (int i = 0; i < entries.length; i++) {
            var image = ExtendedImage.file(
              File(entries.elementAt(i).key),
              cacheRawData: true,
              compressionRatio: 0.1,
              fit: BoxFit.cover,
              clearMemoryCacheWhenDispose: true,
            );
            listOfImages.add(
              image
            );
            listOfImages_sub.add(image);
          }
        }
        break;

      case ("ios"):
        {
          for (int i = 0; i < entries.length; i++) {
            var image = AssetEntityImage(
              entries.elementAt(i).key,
              isOriginal: false,
              fit: BoxFit.cover,
            );
            listOfImages.add(
              image
            );
            listOfImages_sub.add(image);
          }
        }
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    dateTime = widget.event.images.entries.first.value.datetime!;
    return Hero(
      tag: widget.tag,
      child: Scaffold(
        resizeToAvoidBottomInset: true,
        body: SafeArea(
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.max,
              children: [
                mainPhotoListView(),
                if (widget.isMagnified) subPhotoListView(),
                if (widget.isMagnified) dateText(),
                if (widget.isMagnified) noteView()
              ],
            ),
          ),
        ),
      ),
    );
  }

  mainPhotoListView() {
    return SizedBox(
        height: physicalWidth,
        width: physicalWidth,
        child: RotatedBox(
          quarterTurns: -1,
          child: Stack(children: [
            ClickableListWheelScrollView(
              itemCount: widget.event.images.length,
              itemHeight: physicalWidth,
              scrollController: scrollController1,
              onItemTapCallback: (index) {
                setState(() {
                  if (filenameOfFavoriteImage == null) {
                    filenameOfFavoriteImage =
                        widget.event.images.keys.elementAt(index);
                    indexOfFavoriteImage = index;
                    return;
                  }
                  indexOfFavoriteImage = null;
                  filenameOfFavoriteImage = null;
                });
              },
              child: ListWheelScrollView(
                  onSelectedItemChanged: (index) {
                    if (scrollIndex == index) return;
                    scrollController2.animateToItem(index,
                        duration: const Duration(milliseconds: 500),
                        curve: Curves.easeIn);
                    scrollIndex = index;
                    setState(() {});
                  },
                  controller: scrollController1,
                  physics: const PageScrollPhysics(),
                  scrollBehavior: const MaterialScrollBehavior(),
                  diameterRatio: 200,
                  itemExtent: physicalWidth,
                  renderChildrenOutsideViewport: true,
                  clipBehavior: Clip.none,
                  children: List.generate(
                      widget.event.images.entries.length,
                      (index) => Center(
                            child: RotatedBox(
                                quarterTurns: 1,
                                child: Stack(children: [
                                  SizedBox(
                                      height: physicalWidth,
                                      width: physicalWidth,
                                      child: listOfImages.elementAt(index)
                                      // ExtendedImage.file(
                                      //   File(widget.event.images.entries
                                      //       .elementAt(index)
                                      //       .key),
                                      //   cacheRawData: true,
                                      //   compressionRatio: 0.1,
                                      //   fit: BoxFit.cover,
                                      //   clearMemoryCacheWhenDispose: true,
                                      // ),
                                      ),
                                  Positioned(
                                      right: 10.0,
                                      bottom: 10.0,
                                      child: indexOfFavoriteImage == index
                                          ? const Icon(
                                              Icons.favorite,
                                              size: 32.0,
                                              color: Colors.red,
                                            )
                                          : const Icon(
                                              Icons.favorite_outline_outlined,
                                              size: 32.0,
                                              color: Colors.red)),
                                  Positioned(
                                    left: 10.0,
                                    top: 10.0,
                                    child: Text(
                                      DateFormat('Hm').format(widget
                                              .event.images.entries
                                              .elementAt(index)
                                              .value
                                              .datetime ??
                                          DateTime.now()),
                                      style: const TextStyle(fontSize: 16.0),
                                    ),
                                  ),
                                ])),
                          ))),
            ),
          ]),
        ));
  }

  subPhotoListView() {
    return Container(
      height: 50,
      width: physicalWidth,
      margin: const EdgeInsets.only(top: 8.0),
      child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: RotatedBox(
            quarterTurns: -1,
            child: ListWheelScrollView(
                // useMagnifier: true,
                // magnification: 2,
                controller: scrollController2,
                onSelectedItemChanged: (index) {
                  if (scrollIndex == index) return;
                  scrollIndex = index;
                  setState(() {});
                  scrollController1.jumpToItem(index);
                },
                diameterRatio: 200,
                itemExtent: 40,
                children: List.generate(
                    widget.event.images.entries.length,
                    (index) => Center(
                          child: RotatedBox(
                              quarterTurns: 1,
                              child:
                              listOfImages_sub.elementAt(index)
                          ),
                        ))),
          )),
    );
  }

  dateText() {
    return Container(
        width: physicalWidth,
        height: 20,
        margin: const EdgeInsets.symmetric(vertical: 8.0),
        child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Row(
              children: [
                DateText(dateTime: dateTime),
              ],
            )));
  }

  noteView() {
    return SizedBox(
      height: 100,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0),
        child: EditableText(
            maxLines: 5,
            controller: controller,
            focusNode: focusNode,
            onChanged: (a) {
              print(controller.text);
            },
            style: const TextStyle(
              // color: Colors.black,
              fontSize: 20.0,
            ),
            // onChanged: (value){controller.text = value;},
            cursorColor: Colors.white,
            backgroundCursorColor: Colors.grey),
      ),
    );
  }

  @override
  void dispose() async {
    super.dispose();
    DataManagerInterface dataManager = DataManagerInterface(global.kOs);

    dataManager.setFilenameOfFavoriteImage(dateTime, filenameOfFavoriteImage);
    if (controller.text != defaultText) {
      dataManager.setNote(dateTime, controller.text);
    }
  }
}

class DateText extends StatelessWidget {
  DateTime dateTime;
  DateText({super.key, required this.dateTime});

  factory DateText.fromString({required date}) {
    return DateText(dateTime: formatDateString(date));
  }
  @override
  Widget build(BuildContext context) {
    return Text(
      "${DateFormat('EEEE').format(dateTime)}/"
      "${DateFormat('MMM').format(dateTime)} "
      "${DateFormat('dd').format(dateTime)}/"
      "${DateFormat('yyyy').format(dateTime)} ",
      // "${DateFormat('h a').format(dateTime)}",
      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
    );
  }
}
