// ignore_for_file: use_build_context_synchronously

import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:counterstate/firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
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
  Position? position;

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
      try {
        position = await _determinePosition();
        var uuid = const Uuid();
        final String uid = uuid.v4();
        if (kDebugMode) {
          print(uid);
        }
        //upload
        final String downloadURL = await _uploadFile(uid);
        await _addItem(downloadURL, uid);
        Navigator.pop(context);
      } catch (e) {
        if (kDebugMode) {
          print(e.toString());
        }
      }
    }
  }

  Future<String> _uploadFile(String filename) async {
    if (!_initialized) {
      await initializeDefault();
    }
    final Reference ref = FirebaseStorage.instance.ref().child('$filename.jpg');
    final SettableMetadata metadata =
        SettableMetadata(contentType: 'image/jpeg', contentLanguage: 'en');
    final UploadTask uploadTask = ref.putFile(_image!, metadata);
    final String downloadURL = await (await uploadTask).ref.getDownloadURL();
    if (kDebugMode) {
      print(downloadURL);
    }
    return downloadURL;
  }

  /// Determine the current position of the device.
  ///
  /// When the location services are not enabled or permissions
  /// are denied the `Future` will return an error.
  Future<Position> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Test if location services are enabled.
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // Location services are not enabled don't continue
      // accessing the position and request users of the
      // App to enable the location services.
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        // Permissions are denied, next time you could try
        // requesting permissions again (this is also where
        // Android's shouldShowRequestPermissionRationale
        // returned true. According to Android guidelines
        // your App should show an explanatory UI now.
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      // Permissions are denied forever, handle appropriately.
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }

    // When we reach here, permissions are granted and we can
    // continue accessing the position of the device.
    return await Geolocator.getCurrentPosition();
  }

  Future<void> _addItem(String downloadURL, String title) async {
    if (!_initialized) {
      await initializeDefault();
    }
    await FirebaseFirestore.instance.collection("photos").add(<String, dynamic>{
      'downloadURL': downloadURL,
      'title': title,
      'geopoint': GeoPoint(position!.latitude, position!.longitude),
      'timestamp': DateTime.now()
    });
  }
}
