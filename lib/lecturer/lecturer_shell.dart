import 'package:flutter/material.dart';
import 'lecturer_bar.dart';
import 'lecturer_homepage.dart';
import '../staff/staff_dashboard.dart';
import '../lecturer/lecturer_request.dart';
import '../lecturer/lecturer_history.dart';
import '../lecturer/lecturer_profile.dart';

class LecturerShell extends StatelessWidget {
  const LecturerShell({super.key});

  @override
  Widget build(BuildContext context) {
    return const LecturerBar(
      home: LecturerHomePage(),
      dashboard: StaffDashboardPage(),
      notification: BookingApp(),
      history: LecturerHistoryBookingPage(),
      profile: LecturerProfilePage(),
    );
  }
}
