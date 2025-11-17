import 'dart:convert';
import 'package:flutter/material.dart';

// 🔁 ปรับ path ให้ตรงกับโปรเจกต์ของคุณเอง
import '../services/api_client.dart';

class LecturerHistoryBookingPage extends StatefulWidget {
  const LecturerHistoryBookingPage({super.key, this.bottomOverlapPadding});

  final double? bottomOverlapPadding;

  @override
  State<LecturerHistoryBookingPage> createState() =>
      _LecturerHistoryBookingPageState();
}

class _LecturerHistoryBookingPageState extends State<LecturerHistoryBookingPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  // ✅ ใช้ข้อมูลจากหลังบ้านแทน mock
  List<BookingData> bookings = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    )..forward();

    // 🔁 ดึง history จาก API
    fetchHistory();
  }

  Future<void> fetchHistory() async {
    try {
      final res = await ApiClient.get('/api/lecturer/history');

      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);

        // สมมติหลังบ้านส่งแบบ:
        // { "history": [ { ... }, { ... } ] }
        final List list = data['history'] ?? [];

        setState(() {
          bookings = list
              .map((e) => BookingData.fromJson(e as Map<String, dynamic>))
              .toList();
          _loading = false;
        });
      } else {
        // error code อื่น ๆ
        setState(() {
          _loading = false;
        });
      }
    } catch (e) {
      // debug print ไว้เวลา test
      // print('fetchHistory error: $e');
      setState(() {
        _loading = false;
      });
    }
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
            colors: [Color(0xFFFFF8F0), Color(0xFFFEF3E2), Color(0xFFFCE8CD)],
            stops: [0.0, 0.5, 1.0],
          ),
        ),
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header เดิม (ไม่ยุ่ง UI)
              FadeTransition(
                opacity: _controller,
                child: SlideTransition(
                  position:
                      Tween<Offset>(
                        begin: const Offset(0, -0.3),
                        end: Offset.zero,
                      ).animate(
                        CurvedAnimation(
                          parent: _controller,
                          curve: Curves.easeOutCubic,
                        ),
                      ),
                  child: Container(
                    margin: const EdgeInsets.all(20.0),
                    padding: const EdgeInsets.all(24.0),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Colors.white.withValues(alpha: 0.9),
                          Colors.white.withValues(alpha: 0.7),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(28),
                      border: Border.all(
                        color: const Color(0xFFE5D5C3).withValues(alpha: 0.5),
                        width: 1.5,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(
                            0xFFD4A574,
                          ).withValues(alpha: 0.15),
                          blurRadius: 24,
                          offset: const Offset(0, 8),
                          spreadRadius: -4,
                        ),
                        BoxShadow(
                          color: Colors.white.withValues(alpha: 0.8),
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
                              colors: [Color(0xFFFFB547), Color(0xFFFF8A00)],
                            ),
                            borderRadius: BorderRadius.circular(18),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(
                                  0xFFFF8A00,
                                ).withValues(alpha: 0.3),
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
                child: _loading
                    ? const Center(child: CircularProgressIndicator())
                    : bookings.isEmpty
                    ? Center(
                        child: Text(
                          'No booking history',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.brown.shade600,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      )
                    : ListView.builder(
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
        return 'Rejected';
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
            colors: [Colors.white, Colors.white.withValues(alpha: 0.95)],
          ),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: _statusColor.withValues(alpha: 0.2),
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: _statusColor.withValues(alpha: 0.12),
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
                        booking.roomNumber,
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF2D1810),
                        ),
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: _statusBgColor,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: _statusColor.withValues(alpha: 0.3),
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

              // Date + Time + Booked by
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFFBF5),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: const Color(0xFFE5D5C3).withValues(alpha: 0.5),
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
                                color: const Color(
                                  0xFF5D6CC4,
                                ).withValues(alpha: 0.3),
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
                              color: const Color(
                                0xFF5D6CC4,
                              ).withValues(alpha: 0.3),
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

              if (booking.bookingReason != null &&
                  booking.bookingReason!.isNotEmpty) ...[
                const SizedBox(height: 12),
                _bookingReasonBox(),
              ],
            ],
          ),
        ),
      ),
    );
  }

    Widget _bookingReasonBox() {
    if (booking.bookingReason == null || booking.bookingReason!.isEmpty) {
      return const SizedBox.shrink();
    }

    // ใช้สีตามสถานะให้ฟีลคล้าย student
    final isPending = booking.status == BookingStatus.pending;
    final isApproved = booking.status == BookingStatus.approved;

    final Color base = isPending
        ? const Color(0xFFE67E22) // pending -> ส้ม (ตาม status เดิม)
        : isApproved
            ? const Color(0xFF0FA968) // approved -> เขียว
            : const Color(0xFF8B6F47); // disabled/อื่น ๆ -> น้ำตาลกลาง ๆ

    final Color bg = isPending
        ? const Color(0xFFFDEDD7)
        : isApproved
            ? const Color(0xFFD4F4E6)
            : const Color(0xFFFFF3E0);

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: bg.withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: base.withValues(alpha: 0.35),
          width: 1.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.chat_bubble_rounded,
                size: 16,
                color: base.withValues(alpha: 0.9),
              ),
              const SizedBox(width: 8),
              Text(
                'Booking Reason',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  color: base.withValues(alpha: 0.9),
                  letterSpacing: 0.3,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.85),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: base.withValues(alpha: 0.2),
                width: 1,
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Reason: ',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF8B6F47).withValues(alpha: 0.9),
                  ),
                ),
                Expanded(
                  child: Text(
                    booking.bookingReason!,
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF2D1810),
                    ),
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

enum BookingStatus { approved, pending, disabled }

class BookingData {
  final String roomNumber;
  final String date;
  final String time;
  final String bookedBy;
  final BookingStatus status;
  final String? bookingReason;

  BookingData({
    required this.roomNumber,
    required this.date,
    required this.time,
    required this.bookedBy,
    required this.status,
    this.bookingReason,
  });

  factory BookingData.fromJson(Map<String, dynamic> json) {
    String fmt(dynamic raw) {
      final s = (raw ?? '').toString();
      if (!s.contains('-')) return s;
      pad(x) => x.contains(':') ? x : '${x.padLeft(2, '0')}:00';
      final p = s.split('-');
      return '${pad(p[0].trim())} - ${pad(p[1].trim())}';
    }

    // 👇 ดึงเหตุผลจาก backend (ถ้า key ชื่ออื่น แก้ตรงนี้เอา)
    final rawReason = json['reason'];
    final String? bookingReason = (() {
      if (rawReason == null) return null;
      final t = rawReason.toString().trim();
      return t.isEmpty ? null : t;
    })();

    return BookingData(
      roomNumber: (json['room_name'] ?? json['room'] ?? '').toString(),
      date: (json['booking_date'] ?? json['date'] ?? '') as String,
      time: fmt(json['time_slot'] ?? json['time']),
      bookedBy:
          (json['booked_by'] ??
                  json['lecturer_name'] ??
                  json['student_name'] ??
                  '') as String,
      status: _parseStatus(json['status']),
      bookingReason: bookingReason,
    );
  }

  static BookingStatus _parseStatus(dynamic raw) {
    final s = (raw ?? '').toString().toLowerCase();

    if (s == 'approved' || s == 'confirm' || s == 'confirmed') {
      return BookingStatus.approved;
    }
    if (s == 'pending' || s == 'waiting') {
      return BookingStatus.pending;
    }
    return BookingStatus.disabled;
  }
}