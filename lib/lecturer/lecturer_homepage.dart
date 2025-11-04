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
  late AnimationController _staggerController;
  late AnimationController _floatingController;

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
        return Icons.check_circle_rounded;
      case 'Reserved':
        return Icons.schedule_rounded;
      case 'Disabled':
        return Icons.block_rounded;
      default:
        return Icons.meeting_room;
    }
  }

  @override
  Widget build(BuildContext context) {
    final double safe = MediaQuery.of(context).padding.bottom;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFFFFFBF5),
              Color(0xFFFFF5E6),
              Color(0xFFFFE8CC),
            ],
            stops: [0.0, 0.5, 1.0],
          ),
        ),
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Enhanced Header with glassmorphism
              FadeTransition(
                opacity: _fadeController,
                child: SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(0, -0.2),
                    end: Offset.zero,
                  ).animate(
                    CurvedAnimation(
                      parent: _fadeController,
                      curve: Curves.easeOut,
                    ),
                  ),
                  child: Container(
                    margin: const EdgeInsets.all(20.0),
                    padding: const EdgeInsets.all(20.0),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Colors.white.withValues(alpha:0.9),
                          Colors.white.withValues(alpha:0.7),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(28),
                      border: Border.all(
                        color: Colors.white.withValues(alpha:0.5),
                        width: 2,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFFDD0303).withValues(alpha:0.15),
                          blurRadius: 24,
                          offset: const Offset(0, 8),
                          spreadRadius: -4,
                        ),
                        BoxShadow(
                          color: Colors.black.withValues(alpha:0.05),
                          blurRadius: 16,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Row(
                            children: [
                              // Logo animation
                              AnimatedBuilder(
                                animation: _floatingController,
                                builder: (context, child) {
                                  return Transform.translate(
                                    offset: Offset(
                                      0,
                                      -3 * math.sin(_floatingController.value * math.pi),
                                    ),
                                    child: Container(
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(18),
                                        gradient: const LinearGradient(
                                          begin: Alignment.topLeft,
                                          end: Alignment.bottomRight,
                                          colors: [
                                            Color(0xFFDD0303),
                                            Color(0xFFFF4444),
                                          ],
                                        ),
                                        boxShadow: [
                                          BoxShadow(
                                            color: const Color(0xFFDD0303).withValues(alpha:0.35),
                                            blurRadius: 14,
                                            offset: const Offset(0, 5),
                                            spreadRadius: -2,
                                          ),
                                        ],
                                      ),
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(18),
                                        child: Container(
                                          width: 70,
                                          height: 70,
                                          padding: const EdgeInsets.all(2),
                                          child: ClipRRect(
                                            borderRadius: BorderRadius.circular(16),
                                            child: Image.asset(
                                              'assets/logo.png',
                                              fit: BoxFit.cover,
                                              cacheWidth: 140,
                                              cacheHeight: 140,
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
                                        fontSize: 28,
                                        fontWeight: FontWeight.w800,
                                        color: Color(0xFF1A1A2E),
                                        letterSpacing: -0.8,
                                        height: 1.1,
                                      ),
                                    ),
                                    SizedBox(height: 4),
                                    Row(
                                      children: [
                                        CircleAvatar(
                                          radius: 2,
                                          backgroundColor: Color(0xFFDD0303),
                                        ),
                                        SizedBox(width: 8),
                                        Text(
                                          'Manage your spaces',
                                          style: TextStyle(
                                            fontSize: 13,
                                            color: Color(0xFF64748B),
                                            fontWeight: FontWeight.w600,
                                            letterSpacing: 0.2,
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
                      ],
                    ),
                  ),
                ),
              ),

              // Room Grid
              Expanded(
                child: GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: 20,
                    crossAxisSpacing: 20,
                    childAspectRatio: 0.82,
                  ),
                  padding: EdgeInsets.fromLTRB(20, 0, 20, safe + 100),
                  itemCount: rooms.length,
                  physics: const BouncingScrollPhysics(),
                  itemBuilder: (context, index) {
                    final room = rooms[index];
                    return _AnimatedRoomCard(
                      index: index,
                      controller: _staggerController,
                      title: room['name'],
                      status: room['status'],
                      capacity: room['capacity'],
                      statusColor: getStatusColor(room['status']),
                      statusBgColor: getStatusBg(room['status']),
                      statusIcon: getStatusIcon(room['status']),
                      imageUrl: room['image'],
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

class _AnimatedRoomCard extends StatefulWidget {
  const _AnimatedRoomCard({
    required this.index,
    required this.controller,
    required this.title,
    required this.status,
    required this.capacity,
    required this.statusColor,
    required this.statusBgColor,
    required this.statusIcon,
    required this.imageUrl,
  });

  final int index;
  final AnimationController controller;
  final String title;
  final String status;
  final int capacity;
  final Color statusColor;
  final Color statusBgColor;
  final IconData statusIcon;
  final String imageUrl;

  @override
  State<_AnimatedRoomCard> createState() => _AnimatedRoomCardState();
}

class _AnimatedRoomCardState extends State<_AnimatedRoomCard> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final delay = widget.index * 0.08;
    final animation = CurvedAnimation(
      parent: widget.controller,
      curve: Interval(delay, delay + 0.4, curve: Curves.easeOut),
    );

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
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Opening ${widget.title}')),
          );
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
              border: Border.all(
                color: widget.statusColor.withValues(alpha:0.2),
                width: 2,
              ),
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
                // Image Section
                Expanded(
                  child: Stack(
                    children: [
                      // Room Image
                      Hero(
                        tag: 'room_${widget.title}',
                        child: Container(
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
                                Image.asset(
                                  widget.imageUrl,
                                  fit: BoxFit.cover,
                                  cacheWidth: 400,
                                  cacheHeight: 400,
                                  errorBuilder: (context, error, stackTrace) {
                                    return Container(
                                      color: widget.statusBgColor,
                                      child: Icon(
                                        Icons.meeting_room_rounded,
                                        size: 48,
                                        color: widget.statusColor.withValues(alpha:0.5),
                                      ),
                                    );
                                  },
                                ),
                                // Gradient overlay
                                Container(
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      begin: Alignment.topCenter,
                                      end: Alignment.bottomCenter,
                                      colors: [
                                        Colors.transparent,
                                        Colors.black.withValues(alpha:0.25),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),

                      // Status Badge
                      Positioned(
                        top: 22,
                        right: 22,
                        child: TweenAnimationBuilder<double>(
                          tween: Tween(begin: 0.0, end: 1.0),
                          duration: Duration(milliseconds: 500 + widget.index * 60),
                          curve: Curves.easeOut,
                          builder: (context, value, child) {
                            return Opacity(opacity: value, child: child);
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: widget.statusBgColor,
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                color: widget.statusColor.withValues(alpha:0.4),
                                width: 2,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: widget.statusColor.withValues(alpha:0.25),
                                  blurRadius: 10,
                                  offset: const Offset(0, 3),
                                ),
                              ],
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  widget.statusIcon,
                                  size: 14,
                                  color: widget.statusColor,
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  widget.status,
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w800,
                                    color: widget.statusColor,
                                    letterSpacing: 0.3,
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

                // Title and Action Section
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
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w800,
                                color: Color(0xFF1A1A2E),
                                letterSpacing: -0.5,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Row(
                              children: [
                                const Icon(
                                  Icons.people_alt_rounded,
                                  size: 12,
                                  color: Color(0xFF64748B),
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  'Capacity ${widget.capacity}',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                    color: const Color(0xFF64748B).withValues(alpha:0.7),
                                    letterSpacing: 0.2,
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
              ],
            ),
          ),
        ),
      ),
    );
  }
}