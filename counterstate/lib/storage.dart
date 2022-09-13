import 'dart:io';
import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';

class CounterStorage {
  const CounterStorage();

  Future<String> get _localPath async {
    Directory directory = await getApplicationDocumentsDirectory();
    return directory.path;
  }

  Future<File> get _localFile async {
    String path = await _localPath;
    return File('$path/counter.txt');
  }

  Future<bool> writeCounter(int counter) async {
    try {
      File file = await _localFile;
      String jsonString = '{"counter":$counter}';
      await file.writeAsString(jsonString);
      return true;
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
    }
    return false;
  }

  Future<int> readCounter() async {
    try {
      File file = await _localFile;
      String contents = await file.readAsString();
      var countData = jsonDecode(contents);
      return countData["counter"];
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
      bool writeSuccess = await writeCounter(0);
      if (writeSuccess) {
        return 0;
      }
    }
    return -1;
  }
}
