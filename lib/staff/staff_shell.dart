import 'package:flutter/material.dart';
import 'staff_bar.dart';
import 'staff_homepage.dart';
import 'staff_dashboard.dart';
import 'staff_historybooking.dart';
import 'staff_profile.dart'; 

class StaffShell extends StatelessWidget {
  const StaffShell({super.key});

  @override
  Widget build(BuildContext context) {
    return const StaffBar(
      home: StaffHomePage(),
      chack: StaffDashboardPage(),
      hit: StaffHistoryBookingPage(),
      pf: StaffProfilePage(),
    );
  }
}