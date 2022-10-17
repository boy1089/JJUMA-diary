import 'dart:convert';

List<String> splitResponse(response) {
  List<String> responseToString =
      json.decode(response)['mediaItems'].toString().split(',');
  return responseToString;
}

List<List<String>> parseResponse(response) {
  List<String> responseToString =
      json.decode(response)['mediaItems'].toString().split(',');
  List<String> links = [];
  List<String> filenames = [];
  List<String> datetimes = [];
  for (int i = 0; i < responseToString.length; i++) {
    if (responseToString[i].contains("https://lh3.googleusercontent.com/")) {
      links.add(responseToString[i].substring(10));
    }
    if (responseToString[i].contains("filename")) {
      filenames.add(responseToString[i].substring(11).split('}').first);
      String filename = responseToString[i].substring(11).split('}').first;
      filenames.add(filename);

      try {
        datetimes.add(filename.substring(0, 15));
      } catch(e){
        datetimes.add(filename);
      }


    }
  }
  List<List<String>> result = [datetimes, links, filenames];
  return result;
}

