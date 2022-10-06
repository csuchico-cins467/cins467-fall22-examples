import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:nav_stack/first.dart';
import 'package:nav_stack/second.dart';

Widget getDrawer(context) {
  return Drawer(
    child: ListView(
      padding: EdgeInsets.zero,
      children: <Widget>[
        const DrawerHeader(
          decoration: BoxDecoration(
            color: Colors.blue,
          ),
          child: Text(
            'Drawer Header',
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
            ),
          ),
        ),
        ListTile(
          title: const Text('Page 1'),
          onTap: () {
            if (kDebugMode) {
              print("Page 1");
            }
            Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (context) => const FirstRoute()),
                (route) => false);
          },
        ),
        ListTile(
          title: const Text('Page 2'),
          onTap: () {
            if (kDebugMode) {
              print("Page 2");
            }
            Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (context) => const SecondRoute()),
                (route) => false);
          },
        ),
      ],
    ),
  );
}
