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

import 'package:http/http.dart' as http;
// import 'package:path/path.dart' as path;
import 'package:test_location_2nd/Permissions/GoogleAccountManager.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/foundation.dart';
import 'package:test_location_2nd/global.dart' as global;

class PhotoLibraryApiClient {
  GoogleAccountManager googleAccountManager;
  PhotoLibraryApiClient(this.googleAccountManager);

  Future<String> getPhotosOfDate(String year, String month, String day) async {
    var request = {};
    request['pageSize'] = 100;
    request['filters'] = {
      "dateFilter": {
        'dates': {'year': year, 'month': month, 'day': day}
      }
    };

    var requestJson = json.encode(request);

    final response = await http.post(
      Uri.parse("https://photoslibrary.googleapis.com/v1/mediaItems:search"),
      body: requestJson,
      // headers: await googleAccountManager.currentUser!.authHeaders,
      headers: await global.currentUser!.authHeaders,

    );

    debugPrint("page token : ${jsonDecode(response.body)['nextPageToken']}");
    requestJson = json.encode(request);

    var nextPageToken;
    request['nextPageToken'] = nextPageToken;
    nextPageToken = jsonDecode(response.body)['nextPageToken'];

    return response.body;
  }

  void writeCache3(List<String> listString, String name) async {
    final Directory? directory = await getExternalStorageDirectory();
    final String folder = '${directory?.path}';
    bool isFolderExists = await Directory(folder).exists();

    final File file = File(
        '$folder/${DateFormat('yyyyMMdd').format(DateTime.now())}_$name.csv');

    if (!isFolderExists) {
      Directory(folder).create(recursive: true);
    }

    file.writeAsString("writing..", mode: FileMode.write);
    debugPrint("length : ${listString.length}");
    for (int i = 0; i < listString.length; i++) {
      debugPrint(listString[i]);
      await file.writeAsString("${listString[i].toString()}\n",
          mode: FileMode.append);
    }
  }

}
