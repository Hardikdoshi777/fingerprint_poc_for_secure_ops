import 'package:fingerprint_poc/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class HomeScreen extends StatelessWidget {
  final secureStorage = FlutterSecureStorage();

  HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Home")),
      body: Center(
        child: ElevatedButton(
          onPressed: () async {
            await secureStorage.delete(key: 'token');
            Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => MyApp()));
          },
          child: const Text("Logout"),
        ),
      ),
    );
  }
}