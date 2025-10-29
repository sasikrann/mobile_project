import 'package:flutter/material.dart';

void main() => runApp(
  const MaterialApp(debugShowCheckedModeBanner: false, home: MyBookingsPage()),
);

class MyBookingsPage extends StatefulWidget {
  const MyBookingsPage({super.key});

  @override
  State<MyBookingsPage> createState() => _MyBookingsPageState();
}

class _MyBookingsPageState extends State<MyBookingsPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    )..forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // 📌 ตัวอย่างข้อมูล (เปลี่ยนเป็น [] เพื่อลอง no data)
    final bookings = <_Booking>[
      _Booking(
        room: 'Room 1',
        date: '10 Oct 2025',
        time: '10:00 - 12:00',
        status: BookingStatus.confirmed,
        approver: 'Sophia Bennett',
      ),
      _Booking(
        room: 'Room 2',
        date: '11 Oct 2025',
        time: '13:00 - 15:00',
        status: BookingStatus.pending,
      ),
      _Booking(
        room: 'Room 3',
        date: '14 Oct 2025',
        time: '10:00 - 12:00',
        status: BookingStatus.cancelled,
      ),
    ];

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFFFFFBF5), Color(0xFFFEF3E2), Color(0xFFFCE8CD)],
            stops: [0.0, 0.5, 1.0],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // ===== Header =====
              FadeTransition(
                opacity: _animController,
                child: SlideTransition(
                  position:
                      Tween<Offset>(
                        begin: const Offset(0, -0.2),
                        end: Offset.zero,
                      ).animate(
                        CurvedAnimation(
                          parent: _animController,
                          curve: Curves.easeOut,
                        ),
                      ),
                  child: Container(
                    margin: const EdgeInsets.all(20),
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Color(0xFFFF4444),
                          Color(0xFFD61F26),
                          Color(0xFFAA0000),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(28),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFFD61F26).withOpacity(0.3),
                          blurRadius: 24,
                          offset: const Offset(0, 8),
                          spreadRadius: -4,
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(18),
                            border: Border.all(
                              color: Colors.white.withOpacity(0.3),
                              width: 2,
                            ),
                          ),
                          child: const Icon(
                            Icons.calendar_month_rounded,
                            color: Colors.white,
                            size: 28,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'My Bookings',
                                style: TextStyle(
                                  fontSize: 26,
                                  fontWeight: FontWeight.w800,
                                  color: Colors.white,
                                  letterSpacing: -0.5,
                                  height: 1.1,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  Container(
                                    width: 4,
                                    height: 4,
                                    decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.8),
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    '${bookings.length} Reservations',
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: Colors.white.withOpacity(0.9),
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
                ),
              ),

              // ===== List =====
              Expanded(
                child: bookings.isEmpty
                    ? Center(
                        child: FadeTransition(
                          opacity: _animController,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(32),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.7),
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.05),
                                      blurRadius: 20,
                                      offset: const Offset(0, 8),
                                    ),
                                  ],
                                ),
                                child: Icon(
                                  Icons.event_busy_rounded,
                                  size: 64,
                                  color: const Color(
                                    0xFF8B6F47,
                                  ).withOpacity(0.5),
                                ),
                              ),
                              const SizedBox(height: 24),
                              const Text(
                                'No Reservations Found',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFF1A1A2E),
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Book a room to get started',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: const Color(
                                    0xFF64748B,
                                  ).withOpacity(0.7),
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                    : ListView.builder(
                        padding: EdgeInsets.fromLTRB(
                          20,
                          0,
                          20,
                          MediaQuery.of(context).padding.bottom + 60, // ✅ เพิ่มพื้นที่ล่าง
                        ),
                        physics: const BouncingScrollPhysics(),
                        itemCount: bookings.length,
                        itemBuilder: (context, index) {
                          return _BookingCard(
                            booking: bookings[index],
                            index: index,
                            controller: _animController,
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

/* ===== Models ===== */
enum BookingStatus { confirmed, pending, cancelled }

class _Booking {
  final String room;
  final String date;
  final String time;
  final BookingStatus status;
  final String? approver;
  _Booking({
    required this.room,
    required this.date,
    required this.time,
    required this.status,
    this.approver,
  });
}

/* ===== Booking Card ===== */
class _BookingCard extends StatefulWidget {
  final _Booking booking;
  final int index;
  final AnimationController controller;

  const _BookingCard({
    required this.booking,
    required this.index,
    required this.controller,
  });

  @override
  State<_BookingCard> createState() => _BookingCardState();
}

class _BookingCardState extends State<_BookingCard> {
  bool _isPressed = false;

  Color get _statusColor {
    switch (widget.booking.status) {
      case BookingStatus.confirmed:
        return const Color(0xFF10B981);
      case BookingStatus.pending:
        return const Color(0xFFF59E0B);
      case BookingStatus.cancelled:
        return const Color(0xFFEF4444);
    }
  }

  Color get _statusBgColor {
    switch (widget.booking.status) {
      case BookingStatus.confirmed:
        return const Color(0xFFD1FAE5);
      case BookingStatus.pending:
        return const Color(0xFFFEF3C7);
      case BookingStatus.cancelled:
        return const Color(0xFFFEE2E2);
    }
  }

  String get _statusText {
    switch (widget.booking.status) {
      case BookingStatus.confirmed:
        return 'Confirmed';
      case BookingStatus.pending:
        return 'Pending';
      case BookingStatus.cancelled:
        return 'Cancelled';
    }
  }

  IconData get _statusIcon {
    switch (widget.booking.status) {
      case BookingStatus.confirmed:
        return Icons.check_circle_rounded;
      case BookingStatus.pending:
        return Icons.schedule_rounded;
      case BookingStatus.cancelled:
        return Icons.cancel_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final delay = widget.index * 0.1;
    final animation = CurvedAnimation(
      parent: widget.controller,
      curve: Interval(delay, delay + 0.5, curve: Curves.easeOut),
    );

    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        return Opacity(
          opacity: animation.value,
          child: Transform.translate(
            offset: Offset(0, 30 * (1 - animation.value)),
            child: child,
          ),
        );
      },
      child: Padding(
        padding: const EdgeInsets.only(bottom: 20),
        child: GestureDetector(
          onTapDown: (_) => setState(() => _isPressed = true),
          onTapUp: (_) => setState(() => _isPressed = false),
          onTapCancel: () => setState(() => _isPressed = false),
          child: AnimatedScale(
            scale: _isPressed ? 0.97 : 1.0,
            duration: const Duration(milliseconds: 150),
            curve: Curves.easeOut,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Colors.white, Colors.white.withOpacity(0.95)],
                ),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: _statusColor.withOpacity(0.2),
                  width: 2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: _statusColor.withOpacity(_isPressed ? 0.2 : 0.15),
                    blurRadius: _isPressed ? 24 : 20,
                    offset: Offset(0, _isPressed ? 8 : 6),
                    spreadRadius: -3,
                  ),
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Stack(
                children: [
                  // Decorative gradient
                  Positioned(
                    top: 0,
                    right: 0,
                    child: Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        gradient: RadialGradient(
                          colors: [
                            _statusColor.withOpacity(0.08),
                            _statusColor.withOpacity(0.0),
                          ],
                        ),
                      ),
                    ),
                  ),

                  // Content
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Room + Status
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [
                                    Color(0xFF5D6CC4),
                                    Color(0xFF4A5AB3),
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(
                                      0xFF5D6CC4,
                                    ).withOpacity(0.3),
                                    blurRadius: 12,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: const Icon(
                                Icons.meeting_room_rounded,
                                color: Colors.white,
                                size: 22,
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'ROOM',
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w700,
                                      color: Color(0xFF8B6F47),
                                      letterSpacing: 1.2,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    widget.booking.room,
                                    style: const TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.w800,
                                      color: Color(0xFF1A1A2E),
                                      letterSpacing: -0.5,
                                      height: 1.1,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                color: _statusBgColor,
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(
                                  color: _statusColor.withOpacity(0.3),
                                  width: 2,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: _statusColor.withOpacity(0.2),
                                    blurRadius: 8,
                                    offset: const Offset(0, 3),
                                  ),
                                ],
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    _statusIcon,
                                    size: 14,
                                    color: _statusColor,
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    _statusText,
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w800,
                                      color: _statusColor,
                                      letterSpacing: 0.3,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 18),

                        // Date & Time
                        Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFFBF5),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: const Color(0xFFE5D5C3).withOpacity(0.5),
                              width: 1.5,
                            ),
                          ),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(
                                    colors: [
                                      Color(0xFFFFB547),
                                      Color(0xFFFF8A00),
                                    ],
                                  ),
                                  borderRadius: BorderRadius.circular(10),
                                  boxShadow: [
                                    BoxShadow(
                                      color: const Color(
                                        0xFFFF8A00,
                                      ).withOpacity(0.3),
                                      blurRadius: 8,
                                      offset: const Offset(0, 3),
                                    ),
                                  ],
                                ),
                                child: const Icon(
                                  Icons.calendar_today_rounded,
                                  size: 16,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  widget.booking.date,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w700,
                                    color: Color(0xFF1A1A2E),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFE0E4F7),
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(
                                    color: const Color(
                                      0xFF5D6CC4,
                                    ).withOpacity(0.3),
                                    width: 1.5,
                                  ),
                                ),
                                child: const Icon(
                                  Icons.access_time_rounded,
                                  size: 16,
                                  color: Color(0xFF5D6CC4),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Text(
                                widget.booking.time,
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFF5D6CC4),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Divider
                        Container(
                          height: 2,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Colors.transparent,
                                _statusColor.withOpacity(0.3),
                                Colors.transparent,
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Bottom section
                        if (widget.booking.status == BookingStatus.confirmed)
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: const Color(0xFFD1FAE5).withOpacity(0.4),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: const Color(0xFF10B981).withOpacity(0.2),
                                width: 1.5,
                              ),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFD1FAE5),
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(
                                      color: const Color(
                                        0xFF10B981,
                                      ).withOpacity(0.3),
                                      width: 1.5,
                                    ),
                                  ),
                                  child: const Icon(
                                    Icons.verified_rounded,
                                    size: 16,
                                    color: Color(0xFF10B981),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'APPROVED BY',
                                        style: TextStyle(
                                          fontSize: 9,
                                          fontWeight: FontWeight.w700,
                                          color: const Color(
                                            0xFF10B981,
                                          ).withOpacity(0.7),
                                          letterSpacing: 0.8,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        widget.booking.approver ?? '-',
                                        style: const TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w700,
                                          color: Color(0xFF1A1A2E),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),

                        if (widget.booking.status == BookingStatus.pending)
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFFEF4444),
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 14,
                                ),
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                shadowColor: const Color(
                                  0xFFEF4444,
                                ).withOpacity(0.3),
                              ),
                              onPressed: () {
                                // Handle cancel
                              },
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: const [
                                  Icon(Icons.cancel_rounded, size: 18),
                                  SizedBox(width: 8),
                                  Text(
                                    'Cancel Booking',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w700,
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),

                        if (widget.booking.status == BookingStatus.cancelled)
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFEE2E2).withOpacity(0.4),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: const Color(0xFFEF4444).withOpacity(0.2),
                                width: 1.5,
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.info_rounded,
                                  size: 16,
                                  color: const Color(
                                    0xFFEF4444,
                                  ).withOpacity(0.8),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'This booking has been cancelled',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                    color: const Color(
                                      0xFFEF4444,
                                    ).withOpacity(0.8),
                                  ),
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
      ),
    );
  }
}
