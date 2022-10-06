import 'package:flutter/material.dart';
import 'package:nav_stack/components/drawer.dart';
import 'package:nav_stack/first.dart';

class SecondRoute extends StatelessWidget {
  const SecondRoute({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Second Route'),
      ),
      drawer: getDrawer(context),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            if (Navigator.canPop(context)) {
              // Navigate back to first route when tapped.
              Navigator.pop(context);
            } else {
              Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (context) => const FirstRoute()),
                  (route) => false);
            }
          },
          child: const Text('Go back!'),
        ),
      ),
    );
  }
}
