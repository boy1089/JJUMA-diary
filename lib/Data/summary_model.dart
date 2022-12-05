// import 'package:lateDiary/Data/file_info_model.dart';
// import 'package:ml_dataframe/ml_dataframe.dart';
//
//
// enum imagesColumn {
//   date, count
// }
//
// enum locationsColumn{
//   date, location
// }
//
// class SummaryModel {
//   DataFrame? locations;
//   DataFrame? counts;
//   DataFrame? summary; //TOdo make function to update summary
//
//   // SummaryModel({required this.locations, required this.images});
//   SummaryModel({this.locations, this.counts, this.summary});
//
//   factory SummaryModel.fromFilesInfo({required FilesInfoModel filesInfoModel}) {
//     return SummaryModel(
//         locations: updateLocations(filesInfoModel),
//         counts: updateImages(filesInfoModel));
//   }
//
//   // factory SummaryModel.fromDataFrames({required locations, required counts}){
//   //   return SummaryModel(summary:)
//   // }
//
//   List<String> get dates {
//     if (counts == null ) return [];
//     return List<String>.from(counts!.header.toList().sublist(1));
//   }
//
//
//   List<int> get imagesList {
//     if (counts == null ) return [];
//     return List<int>.from(counts!.rows.elementAt(imagesColumn.count.index-1).toList().sublist(1));
//   }
//
//   List<int> get locationssList {
//     if (counts == null ) return [];
//     return List<int>.from(counts!.rows.elementAt(locationsColumn.location.index).toList().sublist(1));
//   }
//
//   static DataFrame updateImages(FilesInfoModel filesInfoModel) {
//     DataFrame counts = DataFrame([
//       ['date'],
//       ['counts']
//     ]);
//     List dates = filesInfoModel.dates;
//     Map<String, int> countsMap = {};
//
//     for (int i = 0; i < dates.length; i++) {
//       String? date = dates[i];
//       if (date == null) continue;
//       bool isContained = countsMap.containsKey(date);
//       if (isContained) {
//         countsMap[date] = countsMap[date]! + 1;
//         continue;
//       }
//       countsMap[date] = 1;
//     }
//     //convert map to dataframe
//     for (var entry in countsMap.entries) {
//       counts = counts.addSeries(Series(entry.key, [entry.value]));
//     }
//     return counts;
//   }
//
//   static DataFrame updateLocations(FilesInfoModel filesInfoModel) {
//     DataFrame locations = DataFrame([
//       ['date'],
//       ['location']
//     ]);
//     List dates = filesInfoModel.dates;
//     List distances = filesInfoModel.distances;
//     Map<String, double> locationsMap = {};
//
//     for (int i = 0; i < dates.length; i++) {
//       String date = dates.elementAt(i);
//       bool isContained = locationsMap.containsKey(date);
//       bool isNull = distances.elementAt(i) == null ? true : false;
//       if (isNull) {
//         continue;
//       }
//
//       if (isContained) {
//         locationsMap[date] = (locationsMap[date]! > distances.elementAt(i)!
//             ? locationsMap[date]
//             : distances.elementAt(i))!;
//         continue;
//       }
//       locationsMap[date] = distances.elementAt(i)!;
//     }
//
//     //convert map to dataframe
//     for (var entry in locationsMap.entries) {
//       locations = locations.addSeries(Series(entry.key, [entry.value]));
//     }
//
//     return locations;
//   }
//
//
// }
