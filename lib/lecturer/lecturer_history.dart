import 'package:flutter/material.dart';

class LecturerHistoryBookingPage extends StatefulWidget {
  const LecturerHistoryBookingPage({
    super.key,
    this.bottomOverlapPadding,
  });

  final double? bottomOverlapPadding;

  @override
  State<LecturerHistoryBookingPage> createState() =>
      _LecturerHistoryBookingPageState();
}

class _LecturerHistoryBookingPageState
    extends State<LecturerHistoryBookingPage> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  final List<BookingData> bookings = [
    BookingData(
      roomNumber: '3',
      date: '15 March 2024',
      time: '13:00 AM - 15:00',
      bookedBy: 'Noah Parker',
      status: BookingStatus.approved,
    ),
    BookingData(
      roomNumber: '6',
      date: '15 March 2024',
      time: '10:00 AM - 12:00',
      bookedBy: 'Olivia Harper',
      status: BookingStatus.approved,
    ),
    BookingData(
      roomNumber: '1',
      date: '15 March 2024',
      time: '8:00 PM - 10:00',
      bookedBy: 'Ethan Carter',
      status: BookingStatus.pending,
    ),
    BookingData(
      roomNumber: '4',
      date: '15 March 2024',
      time: '',
      bookedBy: 'Isabella Hayes',
      status: BookingStatus.disabled,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    )..forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final double safe = MediaQuery.of(context).padding.bottom;
    final double barH = widget.bottomOverlapPadding ?? 88;
    final double bottomPad = barH + safe + 16;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFFFFF8F0),
              Color(0xFFFEF3E2),
              Color(0xFFFCE8CD),
            ],
            stops: [0.0, 0.5, 1.0],
          ),
        ),
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header (ใช้สีเดิม)
              FadeTransition(
                opacity: _controller,
                child: SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(0, -0.3),
                    end: Offset.zero,
                  ).animate(CurvedAnimation(
                    parent: _controller,
                    curve: Curves.easeOutCubic,
                  )),
                  child: Container(
                    margin: const EdgeInsets.all(20.0),
                    padding: const EdgeInsets.all(24.0),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Colors.white.withOpacity(0.9),
                          Colors.white.withOpacity(0.7),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(28),
                      border: Border.all(
                        color: const Color(0xFFE5D5C3).withOpacity(0.5),
                        width: 1.5,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFFD4A574).withOpacity(0.15),
                          blurRadius: 24,
                          offset: const Offset(0, 8),
                          spreadRadius: -4,
                        ),
                        BoxShadow(
                          color: Colors.white.withOpacity(0.8),
                          blurRadius: 16,
                          offset: const Offset(-4, -4),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                Color(0xFFFFB547),
                                Color(0xFFFF8A00),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(18),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFFFF8A00).withOpacity(0.3),
                                blurRadius: 12,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.history_rounded,
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
                                'Booking History',
                                style: TextStyle(
                                  fontSize: 28,
                                  fontWeight: FontWeight.w800,
                                  color: Color(0xFF2D1810),
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
                                    decoration: const BoxDecoration(
                                      color: Color(0xFFFF8A00),
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    '${bookings.length} Total Bookings',
                                    style: const TextStyle(
                                      fontSize: 13,
                                      color: Color(0xFF8B6F47),
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

              // Booking List
              Expanded(
                child: ListView.builder(
                  padding: EdgeInsets.fromLTRB(20, 0, 20, bottomPad),
                  itemCount: bookings.length,
                  itemBuilder: (context, index) {
                    return _BookingCard(booking: bookings[index]);
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

class _BookingCard extends StatelessWidget {
  const _BookingCard({required this.booking});
  final BookingData booking;

  Color get _statusColor {
    switch (booking.status) {
      case BookingStatus.approved:
        return const Color(0xFF0FA968);
      case BookingStatus.pending:
        return const Color(0xFFE67E22);
      case BookingStatus.disabled:
        return const Color(0xFFE74C3C);
    }
  }

  Color get _statusBgColor {
    switch (booking.status) {
      case BookingStatus.approved:
        return const Color(0xFFD4F4E6);
      case BookingStatus.pending:
        return const Color(0xFFFDEDD7);
      case BookingStatus.disabled:
        return const Color(0xFFFFE8E8);
    }
  }

  String get _statusText {
    switch (booking.status) {
      case BookingStatus.approved:
        return 'Approved';
      case BookingStatus.pending:
        return 'Pending';
      case BookingStatus.disabled:
        return 'Room Closed';
    }
  }

  IconData get _statusIcon {
    switch (booking.status) {
      case BookingStatus.approved:
        return Icons.check_circle_rounded;
      case BookingStatus.pending:
        return Icons.schedule_rounded;
      case BookingStatus.disabled:
        return Icons.block_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20.0),
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
              color: _statusColor.withOpacity(0.12),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(22.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Room number + Status
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFF5D6CC4), Color(0xFF4A5AB3)],
                          ),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: const Icon(
                          Icons.meeting_room_rounded,
                          color: Colors.white,
                          size: 22,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Text(
                        'Room ${booking.roomNumber}',
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF2D1810),
                        ),
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: _statusBgColor,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: _statusColor.withOpacity(0.3),
                        width: 2,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(_statusIcon, size: 16, color: _statusColor),
                        const SizedBox(width: 6),
                        Text(
                          _statusText,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w800,
                            color: _statusColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // Date + Time
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFFBF5),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: const Color(0xFFE5D5C3).withOpacity(0.5),
                    width: 1.5,
                  ),
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFFFFB547), Color(0xFFFF8A00)],
                            ),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.calendar_today_rounded,
                            size: 18,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            booking.date,
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF2D1810),
                            ),
                          ),
                        ),
                      ],
                    ),
                    if (booking.time.isNotEmpty) ...[
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: const Color(0xFFE0E4F7),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: const Color(0xFF5D6CC4).withOpacity(0.3),
                                width: 1.5,
                              ),
                            ),
                            child: const Icon(
                              Icons.access_time_rounded,
                              size: 18,
                              color: Color(0xFF5D6CC4),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              booking.time,
                              style: const TextStyle(
                                fontSize: 15,
                                color: Color(0xFF5D6CC4),
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: const Color(0xFFE0E4F7),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: const Color(0xFF5D6CC4).withOpacity(0.3),
                              width: 1.5,
                            ),
                          ),
                          child: const Icon(
                            Icons.person_rounded,
                            size: 18,
                            color: Color(0xFF5D6CC4),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Booked by ${booking.bookedBy}',
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF2D1810),
                            ),
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
    );
  }
}

enum BookingStatus { approved, pending, disabled }

class BookingData {
  final String roomNumber;
  final String date;
  final String time;
  final String bookedBy;
  final BookingStatus status;

  BookingData({
    required this.roomNumber,
    required this.date,
    required this.time,
    required this.bookedBy,
    required this.status,
  });
}
