import 'package:flutter/material.dart';
import 'student_bar.dart';
import 'student_homepage.dart';
// import 'student_historypage.dart';
import '../student/student_profile.dart'; 
import '../student/student_historypage.dart';

class StudentShell extends StatelessWidget {
  final int initialIndex; // ✅ เพิ่ม
  const StudentShell({super.key, this.initialIndex = 0});

  @override
  Widget build(BuildContext context) {
    return StudentBar(
      home: const StudentHomePage(),
      history: const MyBookingsPage(),
      profile: const StudentProfilePage(),
      initialIndex: initialIndex, // ✅ ส่งค่า index
    );
  }
}