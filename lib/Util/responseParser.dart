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
  for (int i = 0; i < responseToString.length; i++) {
    if (responseToString[i].contains("https://lh3.googleusercontent.com/")) {
      links.add(responseToString[i].substring(10));
    }
    if (responseToString[i].contains("filename")) {
      filenames.add(responseToString[i].substring(11).split('}').first);
      print(responseToString[i].length);
      filenames.add(responseToString[i].substring(11).split('}').first);
    }
  }
  List<List<String>> result = [links, filenames];
  return result;
}
