import 'package:flutter/material.dart';
import 'student_bar.dart';
import 'student_homepage.dart';
// import 'student_historypage.dart';
import '../student/student_profile.dart'; 

class StudentShell extends StatelessWidget {
  const StudentShell({super.key});

  @override
  Widget build(BuildContext context) {
    return const StudentBar(
      home: StudentHomePage(),
      history: StudentHomePage(),
      profile: StudentProfilePage(),
    );
  }
}
