import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'student_bookingpage.dart';

class StudentHomePage extends StatefulWidget {
  const StudentHomePage({super.key});

  @override
  State<StudentHomePage> createState() => _StudentHomePageState();
}

class _StudentHomePageState extends State<StudentHomePage>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _staggerController;
  late AnimationController _floatingController;
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    )..forward();

    _staggerController = AnimationController(
      duration: const Duration(milliseconds: 900),
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
    _staggerController.dispose();
    _floatingController.dispose();
    super.dispose();
  }

  // เมื่อกดปุ่ม BOOK
  void _tryBooking(String title, String status) {
    if (status == 'Free') {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const BookingPage(),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text("Can’t booking this room ❌"),
          backgroundColor: Colors.grey.shade700,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  final List<Map<String, dynamic>> rooms = [
    {'name': 'Room 1', 'status': 'Reserved', 'image': 'assets/Room1.png', 'capacity': 8},
    {'name': 'Room 2', 'status': 'Disabled', 'image': 'assets/Room2.jpg', 'capacity': 12},
    {'name': 'Room 3', 'status': 'Free', 'image': 'assets/Room3.png', 'capacity': 8},
    {'name': 'Room 4', 'status': 'Disabled', 'image': 'assets/Room4.jpg', 'capacity': 6},
    {'name': 'Room 5', 'status': 'Free', 'image': 'assets/Room5.png', 'capacity': 12},
    {'name': 'Room 6', 'status': 'Reserved', 'image': 'assets/Room6.png', 'capacity': 10},
  ];

  // สีและไอคอนสถานะ
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

  // Navigation bar
  void _onTabTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });

    if (index == 1) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Go to Booking History 📜')),
      );
    } else if (index == 2) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Go to Settings ⚙️')),
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
                            0,
                            -3 * math.sin(_floatingController.value * math.pi),
                          ),
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
                        fontSize: 24,
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
                  final isAvailable = status == 'Free';

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
                        // รูปห้อง
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

                        // ชื่อห้อง + ความจุ + ปุ่ม BOOK
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
                              const SizedBox(height: 6),
                              Align(
                                alignment: Alignment.centerRight,
                                child: ElevatedButton(
                                  onPressed: () =>
                                      _tryBooking(room['name'], status),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: isAvailable
                                        ? const Color(0xFFDD0303)
                                        : Colors.grey.shade400,
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 14,
                                      vertical: 6,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                  child: isAvailable
                                      ? const Text(
                                          'BOOK',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 12,
                                          ),
                                        )
                                      : const Icon(
                                          Icons.arrow_forward_ios_rounded,
                                          color: Colors.white,
                                          size: 14,
                                        ),
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

            // 🔹 Bottom Navigation Bar
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
                  _buildNavIcon(Icons.receipt_long_rounded, 1),
                  _buildNavIcon(Icons.settings, 2),
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
      child: Icon(
        icon,
        size: 30,
        color: isSelected ? Colors.white : Colors.grey.shade300,
      ),
    );
  }
}

