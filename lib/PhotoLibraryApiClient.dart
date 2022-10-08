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
import 'package:test_location_2nd/GoogleAccountManager.dart';

class PhotosLibraryApiClient {
  // final Future<Map<String, String>> _authHeaders;
  GoogleAccountManager googleAccountManager;

  PhotosLibraryApiClient(this.googleAccountManager);


  Future<String> testPhoto() async {
    // Get the filename of the image
    var request = {};
    request['pageSize'] = 100;
    // request['pageToken'] = "1";
    var request_json = json.encode(request);

    final response = await http.post(
      Uri.parse("https://photoslibrary.googleapis.com/v1/mediaItems:search"),
      body : request_json,
      headers: await googleAccountManager.currentUser!.authHeaders,
    );

    List<String> responseToString = json.decode(response.body)['mediaItems'].toString().split(',');
    List<String> links = [];
    for(int i = 0; i< responseToString.length; i++){
      if( responseToString[i].contains("https://lh3.googleusercontent.com/")){
        links.add(responseToString[i].substring(10));
        // print(responseToString[i].substring(10));
      }
    }

    return response.body;
  }

  static void printError(final Response response) {
    if (response.statusCode != 200) {
      print(response.reasonPhrase);
      print(response.body);
    }
  }
}
