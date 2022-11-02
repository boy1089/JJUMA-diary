import 'package:glob/list_local_fs.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/material.dart';
import 'dart:io';
// import 'package:intl/intl.dart';
import 'package:glob/glob.dart';
import 'package:test_location_2nd/Util/Util.dart';
import 'package:test_location_2nd/Util/global.dart' as global;
import 'dart:collection';

class NoteManager {

  NoteManager() {
    init();
  }

  Map notes = {};
  List files = [];
  Map summaryOfNotes = {};

  void init() async {
    print("initializing noteManager..");
    files = await getAllFiles();
    summaryOfNotes = generateSummaryOfNotes(files);
    await readAllNotes();
    print("initialization done on noteManager..");
  }

  Future<String> readNote(String date) async {
    final Directory? directory = await getExternalStorageDirectory();
    final String folder = '${directory?.path}/noteData';
    final File file = File('${folder}/${date}_note.csv');
    debugPrint("reading note from local");
    String note = await file.readAsString();
    return note;
  }

  Future getAllFiles() async {
    final Directory? directory = await getExternalStorageDirectory();
    final String folder = '${directory?.path}/noteData';
    final files = Glob(folder + "/*.csv").listSync();
    return files;
  }

  Future readAllNotes() async {
    for(int i = 0; i < summaryOfNotes.length; i++){
      String date = summaryOfNotes.keys.elementAt(i);
      String note = await readNote(date);
      notes[date] = note;
    }

    // notes.entries.toList().sort(((a, b) => a.key.compareTo(b.key)));
    // var sortedKeys = notes.keys.toList()..sort();
    notes = Map.fromEntries(
        notes.entries.toList()..sort((e1, e2) => e2.key.compareTo(e1.key)));

  }

  Map generateSummaryOfNotes(files) {
    List dates = List.generate(
        files.length, (i) => files.elementAt(i).basename.substring(0, 8));
    List sizeOfFiles = List.generate(files.length,
        (i) => FileStat.statSync(files.elementAt(i).path).size.ceil());
    print("aa $dates");
    final summaryOfNotes = Map<String, int>.fromIterable(
        transpose([dates, sizeOfFiles]),
        key: (item) => item[0],
        value: (item) => item[1]);
    global.summaryOfNoteData = summaryOfNotes;
    return summaryOfNotes;
  }

  Future<void> writeNote(String date, note) async {
    final Directory? directory = await getExternalStorageDirectory();
    final String folder = '${directory?.path}/noteData';
    bool isFolderExists = await Directory(folder).exists();

    final File file = File('${folder}/${date}_note.csv');

    if (!isFolderExists) {
      Directory(folder).create(recursive: true);
    }

    debugPrint("writing note to Local..");
    await file.writeAsString(note, mode: FileMode.write);
  }
}
