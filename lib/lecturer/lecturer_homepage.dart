import 'package:flutter/material.dart';
import 'dart:math' as math;

class LecturerHomePage extends StatefulWidget {
  const LecturerHomePage({super.key});

  @override
  State<LecturerHomePage> createState() => _LecturerHomePageState();
}

class _LecturerHomePageState extends State<LecturerHomePage>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _floatingController;
  int _selectedIndex = 1; // ค่าเริ่มต้นที่ Grid (All Rooms)

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    )..forward();

    _floatingController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _floatingController.dispose();
    super.dispose();
  }

  final List<Map<String, dynamic>> rooms = [
    {'name': 'Room 1', 'status': 'Reserved', 'image': 'assets/Room1.png', 'capacity': 8},
    {'name': 'Room 2', 'status': 'Disabled', 'image': 'assets/Room2.jpg', 'capacity': 12},
    {'name': 'Room 3', 'status': 'Free', 'image': 'assets/Room3.png', 'capacity': 8},
    {'name': 'Room 4', 'status': 'Disabled', 'image': 'assets/Room4.jpg', 'capacity': 6},
    {'name': 'Room 5', 'status': 'Free', 'image': 'assets/Room5.png', 'capacity': 12},
    {'name': 'Room 6', 'status': 'Reserved', 'image': 'assets/Room6.png', 'capacity': 10},
  ];

  Color getStatusColor(String status) {
    switch (status) {
      case 'Free':
        return const Color(0xFF10B981);
      case 'Reserved':
        return const Color(0xFFF59E0B);
      case 'Disabled':
        return const Color(0xFFEF4444);
      default:
        return Colors.grey;
    }
  }

  Color getStatusBg(String status) {
    switch (status) {
      case 'Free':
        return const Color(0xFFD1FAE5);
      case 'Reserved':
        return const Color(0xFFFEF3C7);
      case 'Disabled':
        return const Color(0xFFFEE2E2);
      default:
        return Colors.grey.shade200;
    }
  }

  IconData getStatusIcon(String status) {
    switch (status) {
      case 'Free':
        return Icons.check_circle;
      case 'Reserved':
        return Icons.schedule_rounded;
      case 'Disabled':
        return Icons.block_rounded;
      default:
        return Icons.meeting_room;
    }
  }

  void _onTabTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });

    if (index == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Go to Home 🏠')), //ไปหน้าhome
      );
    } else if (index == 1) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Viewing All Rooms 🏢')),//ไปหน้าall room
      );
    } else if (index == 2) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Go to Notifications 🔔')), //ไปหน้าNotifications
      );
    } else if (index == 3) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Go to Schedule ⏰')),//ไปหน้าSchedule
      );
    } else if (index == 4) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Go to Settings ⚙️')),//ไปหน้าSetting
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final double safe = MediaQuery.of(context).padding.bottom;

    return Scaffold(
      backgroundColor: const Color(0xFFFEF3E2),
      body: SafeArea(
        child: Column(
          children: [
            // 🔹 Header
            FadeTransition(
              opacity: _fadeController,
              child: Container(
                margin: const EdgeInsets.all(16),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.9),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 16,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    AnimatedBuilder(
                      animation: _floatingController,
                      builder: (context, child) {
                        return Transform.translate(
                          offset: Offset(
                              0, -3 * math.sin(_floatingController.value * math.pi)),
                          child: Container(
                            width: 55,
                            height: 55,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              color: const Color(0xFFDD0303),
                            ),
                            child: Image.asset('assets/logo.png',
                                fit: BoxFit.contain),
                          ),
                        );
                      },
                    ),
                    const SizedBox(width: 12),
                    const Text(
                      'All Rooms',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF1A1A2E),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // 🔹 Room Grid
            Expanded(
              child: GridView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 20,
                  crossAxisSpacing: 20,
                  childAspectRatio: 0.9,
                ),
                itemCount: rooms.length,
                itemBuilder: (context, index) {
                  final room = rooms[index];
                  final status = room['status'];

                  return Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: getStatusColor(status).withOpacity(0.25),
                        width: 1.5,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: getStatusColor(status).withOpacity(0.15),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Stack(
                            children: [
                              ClipRRect(
                                borderRadius: const BorderRadius.vertical(
                                  top: Radius.circular(20),
                                ),
                                child: Image.asset(
                                  room['image'],
                                  fit: BoxFit.cover,
                                  width: double.infinity,
                                ),
                              ),
                              Positioned(
                                top: 10,
                                right: 10,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: getStatusBg(status),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: getStatusColor(status)
                                          .withOpacity(0.4),
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(
                                        getStatusIcon(status),
                                        color: getStatusColor(status),
                                        size: 14,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        status,
                                        style: TextStyle(
                                          color: getStatusColor(status),
                                          fontWeight: FontWeight.bold,
                                          fontSize: 11,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        // 🔸 ชื่อห้อง + ความจุ (ไม่มีปุ่ม BOOK)
                        Padding(
                          padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                room['name'],
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              Text(
                                'Capacity : ${room['capacity']}',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey.shade600,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),

            // 🔹 Bottom Navigation (5 Tabs)
            Container(
              height: 70 + safe,
              padding: EdgeInsets.only(bottom: safe),
              decoration: const BoxDecoration(
                color: Color(0xFFDD0303),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(24),
                  topRight: Radius.circular(24),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildNavIcon(Icons.home, 0),
                  _buildNavIcon(Icons.grid_view_rounded, 1),
                  _buildNavIcon(Icons.notifications_rounded, 2),
                  _buildNavIcon(Icons.access_time_rounded, 3),
                  _buildNavIcon(Icons.settings, 4),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavIcon(IconData icon, int index) {
    bool isSelected = _selectedIndex == index;
    return GestureDetector(
      onTap: () => _onTabTapped(index),
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(
          icon,
          size: 26,
          color: isSelected ? const Color(0xFFDD0303) : Colors.grey.shade300,
        ),
      ),
    );
  }
}
//
