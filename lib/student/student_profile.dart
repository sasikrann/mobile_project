import 'package:flutter/material.dart';

class StudentProfilePage extends StatelessWidget {
  const StudentProfilePage ({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Color(0xFFFEF3E2),
      body: SafeArea(
        child: Center(
          child: Text(
            'Hello World',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Color(0xFFDD0303),
            ),
          ),
        ),
      ),
    );
 }
}