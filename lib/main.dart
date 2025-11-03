import 'package:flutter/material.dart';
import 'auth/login.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(MaterialApp(
    home: const LoginPage(),
    debugShowCheckedModeBanner: false,
  ));
}
