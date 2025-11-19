import 'dart:convert';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_application_1/lecturer/lecturer_time.dart';

import '../services/api_client.dart';

class LecturerHomePage extends StatefulWidget {
  const LecturerHomePage({super.key});

  @override
  State<LecturerHomePage> createState() => _LecturerHomePageState();
}

class _LecturerHomePageState extends State<LecturerHomePage>
    with TickerProviderStateMixin {

  late AnimationController _fadeController;
  late AnimationController _staggerController;
  late AnimationController _floatingController;

  List<dynamic> _rooms = [];
  bool _loading = true;

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

    _fetchRooms();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _staggerController.dispose();
    _floatingController.dispose();
    super.dispose();
  }

  // ====== API: GET /api/rooms ======
  Future<void> _fetchRooms() async {
    try {
      final res = await ApiClient.get('/api/rooms');

      if (!mounted) return;

      if (res.statusCode == 200) {
        final data = json.decode(res.body);
        setState(() {
          _rooms = (data['rooms'] ?? []) as List<dynamic>;
          _loading = false;
        });
      } else {
        setState(() => _loading = false);
        _toast('Fetch rooms failed (${res.statusCode})');
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _loading = false);
      _toast('Cannot connect to server');
    }
  }

  // ====== BOOK BEHAVIOR ======
  void _openOrBlock({
    required int roomId,
    required String roomName,
    required String statusLabel, // "Free" | "Reserved" | "Disabled"
  }) {
    if (statusLabel == 'Free') {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => Timeslot(
            roomId: roomId,
            roomName: roomName,
          ),
        ),
      );
    } else if (statusLabel == 'Reserved') {
      _toast("This room is fully booked for the remaining time today.");
    } else {
      _toast("This room is not available now.");
    }
  }

  void _toast(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: Colors.grey.shade800,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  String statusLabelFromApi(String? api) {
    switch ((api ?? '').toLowerCase()) {
      case 'reserved':
        return 'Reserved';
      case 'disabled':
        return 'Disabled';
      case 'free':
      default:
        return 'Free';
    }
  }

  Color statusColor(String label) {
    switch (label) {
      case 'Reserved':  return const Color(0xFFF59E0B); // เหลือง
      case 'Disabled':  return const Color(0xFFEF4444); // แดง
      case 'Free':
      default:          return const Color(0xFF10B981); // เขียว
    }
  }

  Color statusBg(String label) {
    switch (label) {
      case 'Reserved':  return const Color(0xFFFEF3C7); // เหลืองอ่อน
      case 'Disabled':  return const Color(0xFFFEE2E2); // แดงอ่อน
      case 'Free':
      default:          return const Color(0xFFD1FAE5); // เขียวอ่อน
    }
  }

  IconData statusIcon(String label) {
    switch (label) {
      case 'Reserved':  return Icons.event_busy_rounded;
      case 'Disabled':  return Icons.block_rounded;
      case 'Free':
      default:          return Icons.check_circle_rounded;
    }
  }

  // ====== IMAGE WIDGET (BLOB base64 or asset fallback) ======
  Widget _roomImage({
    required dynamic imageField, // base64 string or null
    required String assetFallback,
    required Color tintColor,
    required Color bgColor,
  }) {
    if (imageField is String && imageField.isNotEmpty) {
      return Image.network(
        '${Config.apiBase}$imageField',
        fit: BoxFit.cover,
        cacheWidth: 400,
        cacheHeight: 400,
        errorBuilder: (_, __, ___) => _assetFallback(bgColor, tintColor),
      );
    }
    // asset fallback
    return Image.asset(
      assetFallback,
      fit: BoxFit.cover,
      cacheWidth: 400,
      cacheHeight: 400,
      errorBuilder: (_, _, _) => _assetFallback(bgColor, tintColor),
    );
  }

  Widget _assetFallback(Color bg, Color tint) {
    return Container(
      color: bg,
      alignment: Alignment.center,
      child: Icon(Icons.meeting_room_rounded, size: 48, color: tint.withValues(alpha:0.5)),
    );
  }

  // สุ่ม asset ตาม index (กันรูปซ้ำเดิมพัง UI)
  String _assetForIndex(int i) {
    const assets = [
      'assets/Room1.png',
      'assets/Room2.jpg',
      'assets/Room3.png',
      'assets/Room4.jpg',
      'assets/Room5.png',
      'assets/Room6.png',
    ];
    return assets[i % assets.length];
  }

  @override
  Widget build(BuildContext context) {
    final double safe = MediaQuery.of(context).padding.bottom;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft, end: Alignment.bottomRight,
            colors: [Color(0xFFFFFBF5), Color(0xFFFFF5E6), Color(0xFFFFE8CC)],
            stops: [0.0, 0.5, 1.0],
          ),
        ),
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ===== Header =====
              FadeTransition(
                opacity: _fadeController,
                child: SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(0, -0.2), end: Offset.zero,
                  ).animate(CurvedAnimation(parent: _fadeController, curve: Curves.easeOut)),
                  child: Container(
                    margin: const EdgeInsets.all(20.0),
                    padding: const EdgeInsets.all(20.0),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft, end: Alignment.bottomRight,
                        colors: [Colors.white.withValues(alpha:0.9), Colors.white.withValues(alpha:0.7)],
                      ),
                      borderRadius: BorderRadius.circular(28),
                      border: Border.all(color: Colors.white.withValues(alpha:0.5), width: 2),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFFDD0303).withValues(alpha:0.15),
                          blurRadius: 24, offset: const Offset(0, 8), spreadRadius: -4,
                        ),
                        BoxShadow(
                          color: Colors.black.withValues(alpha:0.05),
                          blurRadius: 16, offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        AnimatedBuilder(
                          animation: _floatingController,
                          builder: (context, child) {
                            return Transform.translate(
                              offset: Offset(0, -3 * math.sin(_floatingController.value * math.pi)),
                              child: Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(18),
                                  gradient: const LinearGradient(
                                    begin: Alignment.topLeft, end: Alignment.bottomRight,
                                    colors: [Color(0xFFDD0303), Color(0xFFFF4444)],
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: const Color(0xFFDD0303).withValues(alpha:0.35),
                                      blurRadius: 14, offset: const Offset(0, 5), spreadRadius: -2,
                                    ),
                                  ],
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(18),
                                  child: Container(
                                    width: 70, height: 70, padding: const EdgeInsets.all(2),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(16),
                                      child: Image.asset(
                                        'assets/logo.png', fit: BoxFit.cover,
                                        cacheWidth: 140, cacheHeight: 140,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                        const SizedBox(width: 16),
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'All Rooms',
                                style: TextStyle(
                                  fontSize: 28, fontWeight: FontWeight.w800,
                                  color: Color(0xFF1A1A2E), letterSpacing: -0.8, height: 1.1,
                                ),
                              ),
                              SizedBox(height: 4),
                              Row(
                                children: [
                                  CircleAvatar(radius: 2, backgroundColor: Color(0xFFDD0303)),
                                  SizedBox(width: 8),
                                  Text(
                                    'Manage your spaces',
                                    style: TextStyle(
                                      fontSize: 13, color: Color(0xFF64748B),
                                      fontWeight: FontWeight.w600, letterSpacing: 0.2,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // ===== Grid รายการห้อง =====
              Expanded(
                child: _loading
                    ? const Center(child: CircularProgressIndicator())
                    : _rooms.isEmpty
                        ? const Center(child: Text('No rooms available'))
                        : GridView.builder(
                            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2, mainAxisSpacing: 20, crossAxisSpacing: 20,
                              childAspectRatio: 0.82,
                            ),
                            padding: EdgeInsets.fromLTRB(20, 0, 20, safe + 100),
                            itemCount: _rooms.length,
                            physics: const BouncingScrollPhysics(),
                            itemBuilder: (context, index) {
                              final room = _rooms[index];
                              final int roomId = room['id'] as int;
                              final String roomName = (room['name'] ?? 'Room').toString();
                              final String apiStatus = (room['status'] ?? 'disabled').toString();
                              final String label = statusLabelFromApi(apiStatus);
                              final int capacity = (room['capacity'] ?? 0) as int;
                              final dynamic imageField = room['image']; // base64 or null

                              final Color sc = statusColor(label);
                              final Color sbg = statusBg(label);
                              final IconData sicon = statusIcon(label);

                              return _AnimatedLecturerCardForStudent(
                                index: index,
                                controller: _staggerController,
                                title: roomName,
                                statusLabel: label,
                                capacity: capacity,
                                statusColor: sc,
                                statusBgColor: sbg,
                                statusIcon: sicon,
                                // ถ้ามี base64 ใช้, ถ้าไม่มีใช้ asset เดิมตาม index
                                imageBuilder: () => _roomImage(
                                  imageField: imageField,
                                  assetFallback: _assetForIndex(index),
                                  tintColor: sc,
                                  bgColor: sbg,
                                ),
                                onOpen: () => _openOrBlock(
                                  roomId: roomId,
                                  roomName: roomName,
                                  statusLabel: label,
                                ),
                              );
                            },
                          ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// การ์ดแบบ Lecturer + พฤติกรรมกด (ไปจอง/แจ้งเตือน)
class _AnimatedLecturerCardForStudent extends StatefulWidget {
  const _AnimatedLecturerCardForStudent({
    required this.index,
    required this.controller,
    required this.title,
    required this.statusLabel,
    required this.capacity,
    required this.statusColor,
    required this.statusBgColor,
    required this.statusIcon,
    required this.imageBuilder, // () => Widget
    required this.onOpen,
  });

  final int index;
  final AnimationController controller;
  final String title;
  final String statusLabel;
  final int capacity;
  final Color statusColor;
  final Color statusBgColor;
  final IconData statusIcon;
  final Widget Function() imageBuilder;
  final VoidCallback onOpen;

  @override
  State<_AnimatedLecturerCardForStudent> createState() =>
      _AnimatedLecturerCardForStudentState();
}

class _AnimatedLecturerCardForStudentState
    extends State<_AnimatedLecturerCardForStudent> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final delay = widget.index * 0.08;
    final animation = CurvedAnimation(
      parent: widget.controller,
      curve: Interval(delay, delay + 0.4, curve: Curves.easeOut),
    );

    final bool isAvailable = widget.statusLabel == 'Free';

    final Color btnStart = isAvailable ? const Color(0xFFFF4444) : const Color(0xFF9CA3AF);
    final Color btnEnd   = isAvailable ? const Color(0xFFDD0303) : const Color(0xFF6B7280);
    final List<BoxShadow> btnShadow = isAvailable
        ? [BoxShadow(color: const Color(0xFFDD0303).withValues(alpha:0.30), blurRadius: 10, offset: const Offset(0, 4))]
        : [BoxShadow(color: Colors.black.withValues(alpha:0.15), blurRadius: 8, offset: const Offset(0, 3))];

    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        return Opacity(
          opacity: animation.value,
          child: Transform.translate(
            offset: Offset(0, 20 * (1 - animation.value)),
            child: child,
          ),
        );
      },
      child: GestureDetector(
        onTapDown: (_) => setState(() => _isPressed = true),
        onTapUp: (_) {
          setState(() => _isPressed = false);
          widget.onOpen();
        },
        onTapCancel: () => setState(() => _isPressed = false),
        child: AnimatedScale(
          scale: _isPressed ? 0.95 : 1.0,
          duration: const Duration(milliseconds: 100),
          curve: Curves.easeOut,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(28),
              border: Border.all(color: widget.statusColor.withValues(alpha:0.2), width: 2),
              boxShadow: [
                BoxShadow(
                  color: widget.statusColor.withValues(alpha:_isPressed ? 0.25 : 0.18),
                  blurRadius: _isPressed ? 28 : 24,
                  offset: Offset(0, _isPressed ? 10 : 8),
                  spreadRadius: -3,
                ),
                BoxShadow(
                  color: Colors.black.withValues(alpha:0.04),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // รูป + badge สถานะ
                Expanded(
                  child: Stack(
                    children: [
                      Container(
                        margin: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha:0.12),
                              blurRadius: 10,
                              offset: const Offset(0, 5),
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(20),
                          child: Stack(
                            fit: StackFit.expand,
                            children: [
                              // รูปจาก base64 หรือ asset
                              widget.imageBuilder(),
                              Container(
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment.topCenter, end: Alignment.bottomCenter,
                                    colors: [Colors.transparent, Colors.black.withValues(alpha:0.25)],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Positioned(
                        top: 22,
                        right: 22,
                        child: TweenAnimationBuilder<double>(
                          tween: Tween(begin: 0, end: 1),
                          duration: Duration(milliseconds: 500 + widget.index * 60),
                          curve: Curves.easeOut,
                          builder: (_, value, child) => Opacity(opacity: value, child: child),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            decoration: BoxDecoration(
                              color: widget.statusBgColor,
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(color: widget.statusColor.withValues(alpha:0.4), width: 2),
                              boxShadow: [
                                BoxShadow(color: widget.statusColor.withValues(alpha:0.25), blurRadius: 10, offset: const Offset(0, 3)),
                              ],
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(widget.statusIcon, size: 14, color: widget.statusColor),
                                const SizedBox(width: 6),
                                Text(
                                  widget.statusLabel,
                                  style: TextStyle(
                                    fontSize: 11, fontWeight: FontWeight.w800,
                                    color: widget.statusColor, letterSpacing: 0.3,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // ชื่อห้อง + ความจุ + ปุ่ม
                Padding(
                  padding: const EdgeInsets.fromLTRB(18, 0, 18, 18),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.title,
                              maxLines: 1, overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 20, fontWeight: FontWeight.w800,
                                color: Color(0xFF1A1A2E), letterSpacing: -0.5,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Row(
                              children: const [
                                Icon(Icons.people_alt_rounded, size: 12, color: Color(0xFF64748B)),
                                SizedBox(width: 4),
                              ],
                            ),
                            Text(
                              'Capacity ${widget.capacity}',
                              style: TextStyle(
                                fontSize: 11, fontWeight: FontWeight.w600,
                                color: const Color(0xFF64748B).withValues(alpha:0.7),
                                letterSpacing: 0.2,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      GestureDetector(
                        onTap: widget.onOpen,
                        child: Container(
                          width: 44, height: 44,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topLeft, end: Alignment.bottomRight,
                              colors: [btnStart, btnEnd],
                            ),
                            borderRadius: BorderRadius.circular(14),
                            boxShadow: btnShadow,
                          ),
                          alignment: Alignment.center,
                          child: const Icon(Icons.arrow_forward_ios_rounded, size: 16, color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}