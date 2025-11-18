import 'package:flutter/material.dart';
import 'dart:convert';
import '../services/api_client.dart';

class StaffHistoryBookingPage extends StatefulWidget {
  const StaffHistoryBookingPage({
    super.key,
    this.bottomOverlapPadding,
  });

  final double? bottomOverlapPadding;

  @override
  State<StaffHistoryBookingPage> createState() => _StaffHistoryBookingPageState();
}

class _StaffHistoryBookingPageState extends State<StaffHistoryBookingPage>
    with SingleTickerProviderStateMixin {

  late AnimationController _controller;

  List<BookingData> bookings = []; // สร้าง list สำหรับเก็บข้อมูลประวัติการจองที่โหลดมาจาก API
  Future<void> loadBookings() async {
  final res = await ApiClient.get('/api/staff/bookings/history');

  if (res.statusCode == 200) {
    final data = json.decode(res.body);

    print(data); // 

    final List<dynamic> list = data['history'] ?? data['bookings'] ?? [];

    setState(() {

  bookings = list.map((b) {
    return BookingData(
      roomNumber: b['room_name'] ?? '',
      date: b['booking_date'] ?? '',
      time: convertSlot(b['time_slot']),
      bookedBy: b['student_name'] ?? '',

      approvedBy: b['status'] == 'Approved' ? (b['lecturer_name'] ?? '') : '',
      rejectedBy: b['status'] == 'Rejected' ? (b['lecturer_name'] ?? '') : '',
      rejectReason: (b['reject_reason'] ?? b['rejectReason'] ?? '').toString(),



      status: parseStatus(b['status'] ?? ''),

      roomStatus: b['room_status'] ?? '',   
    );
  }).toList();
});


     
  }
}




 @override
void initState() {
  super.initState();
  _controller = AnimationController(
    duration: const Duration(milliseconds: 1200),
    vsync: this,
  )..forward();

  loadBookings();  
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
              // Enhanced Header with decorative elements
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
                          Colors.white.withValues(alpha:0.9),
                          Colors.white.withValues(alpha:0.7),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(28),
                      border: Border.all(
                        color: const Color(0xFFE5D5C3).withValues(alpha:0.5),
                        width: 1.5,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFFD4A574).withValues(alpha:0.15),
                          blurRadius: 24,
                          offset: const Offset(0, 8),
                          spreadRadius: -4,
                        ),
                        BoxShadow(
                          color: Colors.white.withValues(alpha:0.8),
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
                                color: const Color(0xFFFF8A00).withValues(alpha:0.3),
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
                    return _buildBookingCard(bookings[index], index);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBookingCard(BookingData booking, int index) {
    final delay = index * 0.1;
    final animation = CurvedAnimation(
      parent: _controller,
      curve: Interval(
        delay,
        delay + 0.5,
        curve: Curves.easeOutCubic,
      ),
    );

    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, 40 * (1 - animation.value)),
          child: Opacity(
            opacity: animation.value,
            child: child,
          ),
        );
      },
      child: _BookingCard(booking: booking),
    );
  }
}

class _BookingCard extends StatefulWidget {
  const _BookingCard({required this.booking});

  final BookingData booking;

  @override
  State<_BookingCard> createState() => _BookingCardState();
}

class _BookingCardState extends State<_BookingCard> with SingleTickerProviderStateMixin {


  bool _isPressed = false;
  late AnimationController _hoverController;

  @override
  void initState() {
    super.initState();
    _hoverController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _hoverController.dispose();
    super.dispose();
  }


  bool get _isRoomClosed {
  final rs = widget.booking.roomStatus.toLowerCase();
  return rs == 'disabled' || rs == 'closed';
}

  Color get _statusColor {
      // ถ้าห้องปิด → แดง, ถ้าห้องเปิด → เขียว
      return _isRoomClosed
          ? const Color(0xFFE74C3C)
          : const Color(0xFF0FA968);
    }

    Color get _statusBgColor {
      return _isRoomClosed
          ? const Color(0xFFFFE8E8)
          : const Color(0xFFD4F4E6);
    }

    String get _statusText {
      return _isRoomClosed ? 'Room Closed' : 'Room Open';
    }

    IconData get _statusIcon {
      return _isRoomClosed
          ? Icons.block_rounded
          : Icons.check_circle_rounded;
    }


  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20.0),
      child: GestureDetector(
        onTapDown: (_) {
          setState(() => _isPressed = true);
          _hoverController.forward();
        },
        onTapUp: (_) {
          setState(() => _isPressed = false);
          _hoverController.reverse();
        },
        onTapCancel: () {
          setState(() => _isPressed = false);
          _hoverController.reverse();
        },
        child: AnimatedScale(
          scale: _isPressed ? 0.96 : 1.0,
          duration: const Duration(milliseconds: 150),
          curve: Curves.easeOut,
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.white,
                  Colors.white.withValues(alpha:0.95),
                ],
              ),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: _statusColor.withValues(alpha:0.2),
                width: 2,
              ),
              boxShadow: [
                BoxShadow(
                  color: _statusColor.withValues(alpha:_isPressed ? 0.2 : 0.12),
                  blurRadius: _isPressed ? 24 : 20,
                  offset: Offset(0, _isPressed ? 10 : 8),
                  spreadRadius: -3,
                ),
                BoxShadow(
                  color: Colors.black.withValues(alpha:0.05),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(24),
              child: Stack(
                children: [
                  // Decorative gradient overlay
                  Positioned(
                    top: 0,
                    right: 0,
                    child: Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        gradient: RadialGradient(
                          colors: [
                            _statusColor.withValues(alpha:0.08),
                            _statusColor.withValues(alpha:0.0),
                          ],
                        ),
                      ),
                    ),
                  ),
                  
                  // Main content
                  Padding(
                    padding: const EdgeInsets.all(22.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Room Number & Status Badge
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                        colors: [
                                          const Color(0xFF5D6CC4),
                                          const Color(0xFF4A5AB3),
                                        ],
                                      ),
                                      borderRadius: BorderRadius.circular(16),
                                      boxShadow: [
                                        BoxShadow(
                                          color: const Color(0xFF5D6CC4).withValues(alpha:0.3),
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
                                            fontSize: 11,
                                            fontWeight: FontWeight.w700,
                                            color: Color(0xFF8B6F47),
                                            letterSpacing: 1.2,
                                          ),
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          widget.booking.roomNumber,
                                          style: const TextStyle(
                                            fontSize: 26,
                                            fontWeight: FontWeight.w800,
                                            color: Color(0xFF2D1810),
                                            letterSpacing: -0.5,
                                            height: 1.1,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 12),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                              decoration: BoxDecoration(
                                color: _statusBgColor,
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(
                                  color: _statusColor.withValues(alpha:0.3),
                                  width: 2,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: _statusColor.withValues(alpha:0.2),
                                    blurRadius: 10,
                                    offset: const Offset(0, 3),
                                  ),
                                ],
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    _statusIcon,
                                    size: 16,
                                    color: _statusColor,
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    _statusText,
                                    style: TextStyle(
                                      fontSize: 12,
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
                        const SizedBox(height: 20),
                        
                        // Date & Time Container
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFFBF5),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: const Color(0xFFE5D5C3).withValues(alpha:0.5),
                              width: 1.5,
                            ),
                          ),
                          child: Column(
                            children: [
                              // Date
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(10),
                                    decoration: BoxDecoration(
                                      gradient: const LinearGradient(
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                        colors: [
                                          Color(0xFFFFB547),
                                          Color(0xFFFF8A00),
                                        ],
                                      ),
                                      borderRadius: BorderRadius.circular(12),
                                      boxShadow: [
                                        BoxShadow(
                                          color: const Color(0xFFFF8A00).withValues(alpha:0.3),
                                          blurRadius: 8,
                                          offset: const Offset(0, 3),
                                        ),
                                      ],
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
                                      widget.booking.date,
                                      style: const TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w700,
                                        color: Color(0xFF2D1810),
                                        letterSpacing: -0.2,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              if (widget.booking.time.isNotEmpty) ...[
                                const SizedBox(height: 12),
                                Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(10),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFE0E4F7),
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(
                                          color: const Color(0xFF5D6CC4).withValues(alpha:0.3),
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
                                        widget.booking.time,
                                        style: const TextStyle(
                                          fontSize: 15,
                                          color: Color(0xFF5D6CC4),
                                          fontWeight: FontWeight.w700,
                                          letterSpacing: -0.2,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                              const SizedBox(height: 12),
                              // Booked by
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(10),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFE0E4F7),
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                        color: const Color(0xFF5D6CC4).withValues(alpha:0.3),
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
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'BOOKED BY',
                                          style: TextStyle(
                                            fontSize: 10,
                                            color: const Color(0xFF5D6CC4).withValues(alpha:0.7),
                                            fontWeight: FontWeight.w700,
                                            letterSpacing: 0.8,
                                          ),
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          widget.booking.bookedBy,
                                          style: const TextStyle(
                                            fontSize: 15,
                                            fontWeight: FontWeight.w700,
                                            color: Color(0xFF2D1810),
                                            letterSpacing: -0.2,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),
                        
                        // Elegant Divider
                        Row(
                          children: [
                            Expanded(
                              child: Container(
                                height: 2,
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      Colors.transparent,
                                      _statusColor.withValues(alpha:0.3),
                                      Colors.transparent,
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 12),
                              child: Container(
                                width: 6,
                                height: 6,
                                decoration: BoxDecoration(
                                  color: _statusColor.withValues(alpha:0.5),
                                  shape: BoxShape.circle,
                                ),
                              ),
                            ),
                            Expanded(
                              child: Container(
                                height: 2,
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      Colors.transparent,
                                      _statusColor.withValues(alpha:0.3),
                                      Colors.transparent,
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        
                        // People Info
                        Column(
                          children: [
                            // Approved
if (widget.booking.status == BookingStatus.approved) ...[
  _buildPersonInfo(
    icon: Icons.verified_rounded,
    label: 'Approved by',
    name: widget.booking.approvedBy,
    bgColor: const Color(0xFFD4F4E6),
    iconColor: const Color(0xFF0FA968),
  ),
]

// Rejected
else if (widget.booking.status == BookingStatus.rejected) ...[
  _buildPersonInfo(
    icon: Icons.cancel_rounded,
    label: 'Rejected by',
    name: widget.booking.rejectedBy,
    bgColor: const Color(0xFFFFE5E5),
    iconColor: const Color(0xFFD9534F),
  ),
  if (widget.booking.rejectReason.isNotEmpty)
    Padding(
      padding: const EdgeInsets.only(top: 10),
      child: Text(
        'Reason: ${widget.booking.rejectReason}',
        style: const TextStyle(
          color: Color(0xFFD9534F),
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
      ),
    ),
]

// ✨ Cancelled → ใช้ข้อความ fix ไม่ใช้ rejectReason
else if (widget.booking.status == BookingStatus.cancelled) ...[
  _buildPersonInfo(
    icon: Icons.person_off_rounded,
    label: 'Cancelled by',
    name: widget.booking.bookedBy,
    bgColor: const Color(0xFFF0F0F0),
    iconColor: const Color.fromARGB(255, 206, 64, 64),
  ),
  Padding(
    padding: const EdgeInsets.only(top: 10),
    child: Text(
      'Reason: Cancelled by Student',
      style: TextStyle(
        color: const Color.fromARGB(255, 217, 83, 79),
        fontSize: 14,
        fontWeight: FontWeight.w600,
      ),
    ),
  ),
]




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
      ),
    );
  }

  Widget _buildPersonInfo({
    required IconData icon,
    required String label,
    required String name,
    required Color bgColor,
    required Color iconColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: bgColor.withValues(alpha:0.4),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: iconColor.withValues(alpha:0.2),
          width: 1.5,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: iconColor.withValues(alpha:0.3),
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: iconColor.withValues(alpha:0.2),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Icon(
              icon,
              size: 20,
              color: iconColor,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label.toUpperCase(),
                  style: TextStyle(
                    fontSize: 10,
                    color: iconColor.withValues(alpha:0.7),
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.8,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  name,
                  style: const TextStyle(
                    fontSize: 15,
                    color: Color(0xFF2D1810),
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.2,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

enum BookingStatus {
  approved,
  pending,
  rejected,
  cancelled,
  disabled,
}

class BookingData {
  final String roomNumber;
  final String date;
  final String time;
  final String bookedBy;

  
  final String approvedBy;

  final String rejectedBy;
  final String rejectReason;


  final BookingStatus status;   // สถานะการจอง
  final String roomStatus;      // สถานะห้อง


  BookingData({
    required this.roomNumber,
    required this.date,
    required this.time,
    required this.bookedBy,
    required this.approvedBy,
    required this.rejectedBy,
    required this.rejectReason,
    required this.status,
    required this.roomStatus,
  });
}

BookingStatus parseStatus(String s) {
  final v = s.toLowerCase();

  if (v == 'approved') return BookingStatus.approved;
  if (v == 'pending') return BookingStatus.pending;
  if (v == 'rejected') return BookingStatus.rejected;
  if (v == 'cancelled') return BookingStatus.cancelled;


  // ถ้า backend ส่งสถานะห้องเข้ามา เช่น open/closed/disabled
  if (v == 'open' || v == 'available') return BookingStatus.pending; 
  if (v == 'closed' || v == 'disabled') return BookingStatus.disabled;

  return BookingStatus.pending; // fallback
}


String convertSlot(String slot) {
  switch (slot) {
    case '8-10':
      return '08:00 - 10:00';
    case '10-12':
      return '10:00 - 12:00';
    case '13-15':
      return '13:00 - 15:00';
    case '15-17':
      return '15:00 - 17:00';
    default:
      return '';
  }
}