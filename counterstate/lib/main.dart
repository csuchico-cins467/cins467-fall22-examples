import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:counterstate/storage.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';

void main() {
  if (kIsWeb) {
    runApp(const MyApp(
      title: "Web",
    ));
  } else if (Platform.isAndroid) {
    runApp(const MyApp(title: "Android"));
  } else if (Platform.isIOS) {
    runApp(const MyApp(
      title: "iOS",
    ));
  }
}

class MyApp extends StatelessWidget {
  final String title;
  const MyApp({Key? key, required this.title}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.purple,
      ),
      home: MyHomePage(
        title: 'Flutter Demo $title',
        storage: CounterStorage(),
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title, required this.storage})
      : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;
  final CounterStorage storage;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  late Future<int> _counter;
  late Future<Position> _position;
  File? _image;

  void _incrementCounter() async {
    int counter = await widget.storage.readCounter();
    counter += 1;
    await widget.storage.writeCounter(counter);
    setState(() {
      _counter = widget.storage.readCounter();
    });
  }

  void _decrementCounter() async {
    int counter = await widget.storage.readCounter();
    counter -= 1;
    await widget.storage.writeCounter(counter);
    setState(() {
      _counter = widget.storage.readCounter();
    });
  }

  // void getCounter() async {
  //   _counter = await _prefs.then((SharedPreferences prefs) {
  //     return prefs.getInt('counter') ?? 0;
  //   });
  //   setState(() {});
  // }

  @override
  void initState() {
    super.initState();
    _counter = widget.storage.readCounter();
    _position = _determinePosition();
    const LocationSettings locationSettings =
        LocationSettings(accuracy: LocationAccuracy.high, distanceFilter: 100);
    Geolocator.getPositionStream(locationSettings: locationSettings)
        .listen((Position? position) {
      if (kDebugMode) {
        print(position == null
            ? 'Unknown Location'
            : "${position.latitude.toString()}, ${position.longitude.toString()}");
      }
    });
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

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      appBar: AppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
      ),
      body: Center(
        // Center is a layout widget. It takes a single child and positions it
        // in the middle of the parent.
        child: Column(
          // Column is also a layout widget. It takes a list of children and
          // arranges them vertically. By default, it sizes itself to fit its
          // children horizontally, and tries to be as tall as its parent.
          //
          // Invoke "debug painting" (press "p" in the console, choose the
          // "Toggle Debug Paint" action from the Flutter Inspector in Android
          // Studio, or the "Toggle Debug Paint" command in Visual Studio Code)
          // to see the wireframe for each widget.
          //
          // Column has various properties to control how it sizes itself and
          // how it positions its children. Here we use mainAxisAlignment to
          // center the children vertically; the main axis here is the vertical
          // axis because Columns are vertical (the cross axis would be
          // horizontal).
          mainAxisAlignment: MainAxisAlignment.center,
          children: getBody(),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _getImage,
        tooltip: 'Add an Image',
        child: const Icon(Icons.add_a_photo),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }

  List<Widget> getBody() {
    return <Widget>[
      Container(
        margin: const EdgeInsets.all(10.0),
        width: 200,
        height: 200,
        color: Colors.white,
        child: _image == null
            ? const Placeholder(
                child: Image(
                    image: NetworkImage(
                        'https://t3.ftcdn.net/jpg/02/48/42/64/360_F_248426448_NVKLywWqArG2ADUxDq6QprtIzsF82dMF.jpg')))
            : Image.file(_image!),
      ),
      FutureBuilder(
          future: _position,
          builder: ((BuildContext context, AsyncSnapshot<Position> snapshot) {
            switch (snapshot.connectionState) {
              case ConnectionState.waiting:
                return const CircularProgressIndicator();
              default:
                if (snapshot.hasError) {
                  return Text("Error: ${snapshot.error}");
                }
                return Text(
                    '${snapshot.data!.latitude}, ${snapshot.data!.longitude}, ${snapshot.data!.accuracy}');
            }
          })),
      const Text(
        'You have pushed the button this many times:',
      ),
      widget.storage.isInitialized
          ? StreamBuilder(
              stream:
                  FirebaseFirestore.instance.collection("example").snapshots(),
              builder: (BuildContext context,
                  AsyncSnapshot<QuerySnapshot> snapshot) {
                if (snapshot.hasError) {
                  return Text('Error: ${snapshot.error.toString()}');
                } else {
                  if (!snapshot.hasData)
                    return const CircularProgressIndicator();
                  print(snapshot.data);
                  return Text(
                    snapshot.data!.docs[0]['count'].toString(),
                    style: Theme.of(context).textTheme.headline4,
                  );
                }
              })
          : Container(),
      Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ElevatedButton(child: Icon(Icons.add), onPressed: _incrementCounter),
          FutureBuilder<int>(
              future: _counter,
              builder: (BuildContext context, AsyncSnapshot<int> snapshot) {
                switch (snapshot.connectionState) {
                  case ConnectionState.waiting:
                    return const CircularProgressIndicator();
                  default:
                    if (snapshot.hasError) {
                      return Text('Error: ${snapshot.error}');
                    } else {
                      return Text(
                        '${snapshot.data}',
                        style: Theme.of(context).textTheme.headline4,
                      );
                      // Text(
                      //   'Button tapped ${snapshot.data} time${snapshot.data == 1 ? '' : 's'}.\n\n'
                      //   'This should persist across restarts.',
                      // );
                    }
                }
              }),
          ElevatedButton(
              child: Icon(Icons.remove), onPressed: _decrementCounter),
        ],
      ),
    ];
  }
}
