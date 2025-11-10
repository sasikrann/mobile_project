import 'package:flutter/material.dart';
import 'package:flutter_application_1/lecturer/lecturer_dashboard.dart';
import 'lecturer_bar.dart';
import 'lecturer_homepage.dart';
import '../lecturer/lecturer_request.dart';
import '../lecturer/lecturer_history.dart';
import '../lecturer/lecturer_profile.dart';

class LecturerShell extends StatelessWidget {
  const LecturerShell({super.key});

  @override
  Widget build(BuildContext context) {
    return const LecturerBar(
      home: LecturerHomePage(),
      dashboard: lecturerDashboardPage(),
      notification: BookingApp(),
      history: LecturerHistoryBookingPage(),
      profile: LecturerProfilePage(),
    );
  }
}
