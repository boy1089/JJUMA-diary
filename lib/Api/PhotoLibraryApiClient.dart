/*
 * Copyright 2019 Google LLC
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     https://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as path;
import 'package:test_location_2nd/Permissions/GoogleAccountManager.dart';
import '../Util/responseParser.dart';
import 'package:intl/intl.dart';
import 'dart:io';
import 'package:test_location_2nd/Util/responseParser.dart';
import 'package:path_provider/path_provider.dart';

class PhotosLibraryApiClient {
  // final Future<Map<String, String>> _authHeaders;
  GoogleAccountManager googleAccountManager;

  PhotosLibraryApiClient(this.googleAccountManager);

  Future<String> getPhotosOfDate(String year, String month, String day) async {


    var request = {};
    request['pageSize'] = 100;
    request['filters'] = {"dateFilter" : {'dates':{'year' : year, 'month' : month, 'day' : day}}};

    var request_json = json.encode(request);

    final response = await http.post(
      Uri.parse("https://photoslibrary.googleapis.com/v1/mediaItems:search"),
      body: request_json,
      headers: await googleAccountManager.currentUser!.authHeaders,
    );

    print("page token : ${jsonDecode(response.body)['nextPageToken']}");
    request_json = json.encode(request);

    var nextPageToken;
    request['nextPageToken'] = nextPageToken;
    nextPageToken = jsonDecode(response.body)['nextPageToken'];
    // var response2 = await http.post(
    //   Uri.parse("https://photoslibrary.googleapis.com/v1/mediaItems:search"),
    //   body: request_json,
    //   headers: await googleAccountManager.currentUser!.authHeaders,
    // );
    //
    // nextPageToken = jsonDecode(response2.body)['nextPageToken'];
    // print("page token : ${jsonDecode(response2.body)['nextPageToken']}");
    // request['pageToken'] = nextPageToken;

    // responseList.add(response2);
    // if(jsonDecode(response.body)['nextPageToken'] != null)

    return response.body;
  }



  void writeCache3(List<String> listString, String name) async {
    final Directory? directory = await getExternalStorageDirectory();
    final String folder = '${directory?.path}';
    bool isFolderExists = await Directory(folder).exists();

    final File file = File(
        '${folder}/${DateFormat('yyyyMMdd').format(DateTime.now())}_${name}.csv');

    if (!isFolderExists) {
      Directory(folder).create(recursive: true);
    }
    file.writeAsString("writing..", mode : FileMode.write);
    print("lenght : ${listString.length}");
    for(int i = 0; i < listString.length; i++){
      print(listString[i]);
      await file.writeAsString("${listString[i].toString()}\n", mode: FileMode.append);
    }

  }

  static void printError(final Response response) {
    if (response.statusCode != 200) {
      print(response.reasonPhrase);
      print(response.body);
    }
  }
}
