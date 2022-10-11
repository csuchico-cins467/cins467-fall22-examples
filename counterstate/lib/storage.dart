// ignore_for_file: use_build_context_synchronously

import 'dart:io';

import 'package:counterstate/firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';

class SecondScreen extends StatefulWidget {
  const SecondScreen({super.key, required this.title});

  final String title;

  @override
  State<SecondScreen> createState() => _SecondScreenState();
}

class _SecondScreenState extends State<SecondScreen> {
  File? _image;
  bool _initialized = false;
  FirebaseApp? app;

  Future<void> initializeDefault() async {
    app = await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform);
    _initialized = true;
    if (kDebugMode) {
      print("Initialized the default app $app");
    }
  }

  void _getImage() async {
    final ImagePicker _picker = ImagePicker();
    // Pick an image
    final XFile? pickedImage =
        await _picker.pickImage(source: ImageSource.camera);
    setState(() {
      if (pickedImage != null) {
        _image = File(pickedImage.path);
      } else {
        if (kDebugMode) {
          print("No image selected.");
        }
      }
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    initializeDefault();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.title)),
      body: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        _image == null
            ? const Text("No image selected.")
            : Image.file(_image!, width: 300),
        ElevatedButton(
            onPressed: () {
              if (kDebugMode) {
                print("upload");
              }
              _upload();
            },
            child: const Text(
              "Submit",
              style: TextStyle(fontSize: 20),
            ))
      ]),
      floatingActionButton: FloatingActionButton(
        onPressed: _getImage,
        tooltip: "Add a photo",
        child: const Icon(Icons.add_a_photo),
      ),
    );
  }

  void _upload() async {
    if (!_initialized) {
      await initializeDefault();
    }
    if (_image != null) {
      var uuid = const Uuid();
      final String uid = uuid.v4();
      if (kDebugMode) {
        print(uid);
      }
      //upload
      Navigator.pop(context);
    }
  }
}
