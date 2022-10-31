import 'package:path_provider/path_provider.dart';
import 'package:flutter/material.dart';
import 'dart:io';
import 'package:intl/intl.dart';


class NoteManager {



    Future<String> readNote(String date) async {
      final Directory? directory = await getExternalStorageDirectory();
      final String folder = '${directory?.path}/noteData';
      final File file = File(
          '${folder}/${date}_note.csv');
      debugPrint("reading note from local");
      String note = await file.readAsString();
      return note;
  }

  Future<void> writeNote(String date, note) async {
    final Directory? directory = await getExternalStorageDirectory();
    final String folder = '${directory?.path}/noteData';
    bool isFolderExists = await Directory(folder).exists();

    final File file = File(
        '${folder}/${date}_note.csv');

    if (!isFolderExists) {
      Directory(folder).create(recursive: true);
    }

    debugPrint("writing note to Local..");
      await file.writeAsString(
        note,
          mode: FileMode.write);
    }
  }
