import 'dart:convert';
import 'package:flutter/material.dart';

import '../services/api_client.dart';

/* ===== Models ===== */
enum BookingStatus { confirmed, pending, cancelled, rejected }

class _Booking {
  final int id;              // booking_id จาก DB
  final String room;         // rooms.name
  final String date;         // dd/MM/yyyy (format แล้ว)
  final String time;         // HH:MM - HH:MM (format แล้ว)
  final BookingStatus status;
  final String? approver;    // ชื่อคนอนุมัติ (nullable)
  final String? rejectReason;
  final String? bookingReason; // เหตุผลที่ student กรอกตอนจอง

  const _Booking({
    required this.id,
    required this.room,
    required this.date,
    required this.time,
    required this.status,
    this.approver,
    this.rejectReason,
    this.bookingReason,
  });

  _Booking copyWith({
    int? id,
    String? room,
    String? date,
    String? time,
    BookingStatus? status,
    String? approver,
    String? rejectReason,
    String? bookingReason,
  }) {
    return _Booking(
      id: id ?? this.id,
      room: room ?? this.room,
      date: date ?? this.date,
      time: time ?? this.time,
      status: status ?? this.status,
      approver: approver ?? this.approver,
      rejectReason: rejectReason ?? this.rejectReason,
      bookingReason: bookingReason ?? this.bookingReason,
    );
  }
}

/* ===== Page ===== */
class MyBookingsPage extends StatefulWidget {
  const MyBookingsPage({super.key});

  @override
  State<MyBookingsPage> createState() => _MyBookingsPageState();
}

class _MyBookingsPageState extends State<MyBookingsPage>
    with SingleTickerProviderStateMixin {

  late AnimationController _animController;

  final List<_Booking> _bookings = <_Booking>[];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    )..forward();

    _loadBookings();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  /* ===== Helpers: mapping/format ===== */
  // DB: 'Pending' | 'Approved' | 'Rejected' | 'Cancelled'
  BookingStatus _mapStatus(String s) {
    switch (s.toLowerCase()) {
      case 'approved':
        return BookingStatus.confirmed;
      case 'pending':
        return BookingStatus.pending;
      case 'cancelled':
        return BookingStatus.cancelled;
      case 'rejected':
        return BookingStatus.rejected;
      default:
        return BookingStatus.pending;
    }
  }

  String _formatDate(String ymd) {
    // รับ 'yyyy-mm-dd'
    final parts = ymd.split('-');
    if (parts.length != 3) return ymd;
    final yyyy = parts[0];
    final mm = parts[1].padLeft(2, '0');
    final dd = parts[2].padLeft(2, '0');
    return '$dd/$mm/$yyyy';
  }

  String _formatTimeSlot(String slot) {
    // '8-10' -> '08:00 - 10:00'
    final p = slot.split('-');
    if (p.length != 2) return slot;
    final s = p[0].padLeft(2, '0');
    final e = p[1].padLeft(2, '0');
    return '$s:00 - $e:00';
  }

  void _toast(String msg, {Color? bg}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: bg ?? Colors.grey.shade900,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  /* ===== API calls ===== */
  Future<void> _loadBookings() async {
    try {
      final res = await ApiClient.get('/api/me/bookings');

      if (!mounted) return;

      if (res.statusCode == 200) {
        final jsonBody = json.decode(res.body) as Map<String, dynamic>;
        final rows = (jsonBody['bookings'] ?? []) as List<dynamic>;

        _bookings
          ..clear()
          ..addAll(rows.map((row) {
            final statusStr = (row['status'] ?? '').toString();

            final rawReason = row['reason'];
            final bookingReason = rawReason == null
                ? null
                : rawReason.toString().trim().isEmpty
                    ? null
                    : rawReason.toString().trim();

            return _Booking(
              id: row['booking_id'] as int,
              room: (row['room_name'] ?? '-').toString(),
              date: _formatDate((row['booking_date'] ?? '').toString()),
              time: _formatTimeSlot((row['time_slot'] ?? '').toString()),
              status: _mapStatus(statusStr),
              approver: (row['approver_name'] as String?)?.trim().isEmpty == true
                  ? null
                  : row['approver_name'],
              rejectReason: (row['reject_reason'] as String?),
              bookingReason: bookingReason,
            );
          }));

        setState(() => _loading = false);
      } else {
        setState(() => _loading = false);
        _toast('Load bookings failed (${res.statusCode})');
      }
    } catch (_) {
      if (!mounted) return;
      setState(() => _loading = false);
      _toast('Cannot connect to server');
    }
  }

  Future<void> _requestCancel(int index) async {
    final booking = _bookings[index];

    // แสดง bottom sheet เดิม
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return _CancelSheet(
          room: booking.room,
          date: booking.date,
          time: booking.time,
          onConfirm: () async {
            Navigator.pop(ctx);
            await _doCancel(index);
          },
        );
      },
    );
  }

  Future<void> _doCancel(int index) async {
    final booking = _bookings[index];

    try {
      final res = await ApiClient.post('/api/bookings/${booking.id}/cancel');

      if (res.statusCode == 200) {
        // อัปเดต card เป็น cancelled ทันที
        setState(() {
          _bookings[index] = _bookings[index].copyWith(status: BookingStatus.cancelled);
        });
        _toast(
          'Booking for ${booking.room} has been cancelled.',
          bg: const Color(0xFFEF4444),
        );
      } else {
        final body = json.decode(res.body);
        _toast(body['message']?.toString() ?? 'Cancel failed (${res.statusCode})');
      }
    } catch (e) {
      _toast('Cancel failed: $e');
    }
  }

  /* ===== UI (เดิม) ===== */
  static Widget _rowInfo(IconData icon, String label, String value) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: const Color(0xFFE0E4F7),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, size: 16, color: const Color(0xFF5D6CC4)),
        ),
        const SizedBox(width: 10),
        Text(
          '$label: ',
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: Color(0xFF8B6F47),
          ),
        ),
        Expanded(
          child: Text(
            value,
            textAlign: TextAlign.end,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: Color(0xFF1A1A2E),
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
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
              FadeTransition(
                opacity: _animController,
                child: SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(0, -0.2),
                    end: Offset.zero,
                  ).animate(
                    CurvedAnimation(
                      parent: _animController,
                      curve: Curves.easeOut,
                    ),
                  ),
                  child: _Header(total: _bookings.length),
                ),
              ),

              Expanded(
                child: _loading
                    ? const Center(child: CircularProgressIndicator())
                    : _bookings.isEmpty
                        ? _EmptyState(anim: _animController)
                        : ListView.builder(
                            padding: EdgeInsets.fromLTRB(
                              20,
                              0,
                              20,
                              MediaQuery.of(context).padding.bottom + 60,
                            ),
                            physics: const BouncingScrollPhysics(),
                            itemCount: _bookings.length,
                            itemBuilder: (context, index) {
                              final b = _bookings[index];
                              return _BookingCard(
                                booking: b,
                                index: index,
                                controller: _animController,
                                onRequestCancel: b.status == BookingStatus.pending
                                    ? () => _requestCancel(index)
                                    : null,
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

/* ===== UI widgets (ย่อย) ===== */
class _Header extends StatelessWidget {
  const _Header({required this.total});
  final int total;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFFF4444), Color(0xFFD61F26), Color(0xFFAA0000)],
        ),
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFD61F26).withValues(alpha: 0.3),
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
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.3),
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
                        color: Colors.white.withValues(alpha: 0.8),
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '$total Reservations',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.white.withValues(alpha: 0.9),
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
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.anim});
  final AnimationController anim;
  @override
  Widget build(BuildContext context) {
    return Center(
      child: FadeTransition(
        opacity: anim,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.7),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Icon(
                Icons.event_busy_rounded,
                size: 64,
                color: const Color(0xFF8B6F47).withValues(alpha: 0.5),
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
                color: const Color(0xFF64748B).withValues(alpha: 0.7),
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CancelSheet extends StatelessWidget {
  const _CancelSheet({
    required this.room,
    required this.date,
    required this.time,
    required this.onConfirm,
  });

  final String room;
  final String date;
  final String time;
  final VoidCallback onConfirm;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      child: Container(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 48,
              height: 5,
              decoration: BoxDecoration(
                color: Colors.black12,
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFFFF6B6B), Color(0xFFD61F26)],
                    ),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFFD61F26).withValues(alpha: 0.25),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      )
                    ],
                  ),
                  child: const Icon(
                    Icons.warning_rounded,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Text(
                    'Cancel this booking?',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF1A1A2E),
                      letterSpacing: -0.3,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFFFFFBF5),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: const Color(0xFFE5D5C3).withValues(alpha: 0.6),
                  width: 1.5,
                ),
              ),
              child: Column(
                children: [
                  _MyBookingsPageState._rowInfo(
                    Icons.meeting_room_rounded,
                    'Room',
                    room,
                  ),
                  const SizedBox(height: 8),
                  _MyBookingsPageState._rowInfo(
                    Icons.calendar_today_rounded,
                    'Date',
                    date,
                  ),
                  const SizedBox(height: 8),
                  _MyBookingsPageState._rowInfo(
                    Icons.access_time_rounded,
                    'Time',
                    time,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),

            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      side: const BorderSide(
                        color: Color(0xFFE5D5C3),
                        width: 2,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      foregroundColor: const Color(0xFF1A1A2E),
                      backgroundColor: const Color(0xFFFFFBF5),
                    ),
                    onPressed: () => Navigator.pop(context),
                    child: const Text(
                      'Keep booking',
                      style: TextStyle(fontWeight: FontWeight.w700),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFEF4444),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      shadowColor:
                          const Color(0xFFEF4444).withValues(alpha: 0.3),
                    ),
                    onPressed: onConfirm,
                    child: const Text(
                      'Yes, cancel',
                      style: TextStyle(fontWeight: FontWeight.w800),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}

/* ===== การ์ด (คง UI เดิม) ===== */
class _BookingCard extends StatefulWidget {
  final _Booking booking;
  final int index;
  final AnimationController controller;
  final VoidCallback? onRequestCancel;

  const _BookingCard({
    required this.booking,
    required this.index,
    required this.controller,
    required this.onRequestCancel,
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
        return const Color(0xFF7C3AED);
      case BookingStatus.cancelled:
        return const Color(0xFFEF4444);
      case BookingStatus.rejected:
        return const Color(0xFFF59E0B);
    }
  }

  Color get _statusBgColor {
    switch (widget.booking.status) {
      case BookingStatus.confirmed:
        return const Color(0xFFD1FAE5);
      case BookingStatus.pending:
        return const Color(0xFFEDE9FE);
      case BookingStatus.cancelled:
        return const Color(0xFFFEE2E2);
      case BookingStatus.rejected:
        return const Color(0xFFFEF3C7);
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
      case BookingStatus.rejected:
        return 'Rejected';
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
      case BookingStatus.rejected:
        return Icons.info_rounded;
    }
  }

  Widget _bookingReasonBox(BookingStatus status, String? reason) {
    if (reason == null || reason.isEmpty) return const SizedBox.shrink();

    // สีแยกตามสถานะ
    final bool isPending = status == BookingStatus.pending;
    final Color base = isPending
        ? const Color(0xFF7C3AED) // pending = ม่วง
        : const Color(0xFF10B981); // confirmed = เขียว

    final Color bg = isPending
        ? const Color(0xFFEDE9FE)
        : const Color(0xFFD1FAE5);

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: bg.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: base.withValues(alpha: 0.3),
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
              color: Colors.white.withValues(alpha: 0.7),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: base.withValues(alpha: 0.18),
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
                    color: const Color(0xFF8B6F47).withValues(alpha: 0.85),
                  ),
                ),
                Expanded(
                  child: Text(
                    reason,
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1A1A2E),
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
                  colors: [Colors.white, Colors.white.withValues(alpha: 0.95)],
                ),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: _statusColor.withValues(alpha: 0.2),
                  width: 2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: _statusColor
                        .withValues(alpha: _isPressed ? 0.2 : 0.15),
                    blurRadius: _isPressed ? 24 : 20,
                    offset: Offset(0, _isPressed ? 8 : 6),
                    spreadRadius: -3,
                  ),
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Stack(
                children: [
                  Positioned(
                    top: 0,
                    right: 0,
                    child: Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        gradient: RadialGradient(
                          colors: [
                            _statusColor.withValues(alpha: 0.08),
                            _statusColor.withValues(alpha: 0.0),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            _leadingRoomIcon(),
                            const SizedBox(width: 14),
                            Expanded(child: _roomTitle(widget.booking.room)),
                            _statusChip(
                              _statusText,
                              _statusBgColor,
                              _statusColor,
                              _statusIcon,
                            ),
                          ],
                        ),
                        const SizedBox(height: 18),
                        _dateTimePanel(
                          widget.booking.date,
                          widget.booking.time,
                        ),
                        const SizedBox(height: 16),
                        _dividerGlow(_statusColor),
                        const SizedBox(height: 16),

                        // 🔹 1) การ์ด Booking Reason สำหรับ pending + confirmed
                        if ((widget.booking.status == BookingStatus.confirmed ||
                            widget.booking.status == BookingStatus.pending) &&
                            widget.booking.bookingReason != null &&
                            widget.booking.bookingReason!.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 10),
                            child: _bookingReasonBox(
                              widget.booking.status,
                              widget.booking.bookingReason,
                            ),
                          ),

                        // 🔹 2) ถ้า approved ก็ยังโชว์ APPROVED BY เหมือนเดิม
                        if (widget.booking.status == BookingStatus.confirmed)
                          _approvedBox(widget.booking.approver),

                        // 🔹 3) ถ้า pending ก็ยังมีปุ่ม Cancel ได้เหมือนเดิม
                        if (widget.booking.status == BookingStatus.pending &&
                            widget.onRequestCancel != null)
                          _cancelButton(widget.onRequestCancel!),

                        // 🔹 4) ถ้า cancelled หรือ rejected ใช้การ์ดเดิมสำหรับ reject reason / cancelled
                        if (widget.booking.status == BookingStatus.cancelled ||
                            widget.booking.status == BookingStatus.rejected)
                          _rejectedBox(
                            widget.booking.status,
                            widget.booking.rejectReason,
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

  Widget _leadingRoomIcon() => Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF5D6CC4), Color(0xFF4A5AB3)],
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF5D6CC4).withValues(alpha: 0.3),
              blurRadius: 12,
              offset: const Offset(0, 4),
            )
          ],
        ),
        child: const Icon(
          Icons.meeting_room_rounded,
          color: Colors.white,
          size: 22,
        ),
      );

  Widget _roomTitle(String room) => Column(
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
            room,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: Color(0xFF1A1A2E),
              letterSpacing: -0.5,
              height: 1.1,
            ),
          ),
        ],
      );

  Widget _statusChip(
    String text,
    Color bg,
    Color fg,
    IconData icon,
  ) =>
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: fg.withValues(alpha: 0.3), width: 2),
          boxShadow: [
            BoxShadow(
              color: fg.withValues(alpha: 0.2),
              blurRadius: 8,
              offset: const Offset(0, 3),
            )
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 14, color: fg),
            const SizedBox(width: 6),
            Text(
              text,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w800,
                color: fg,
                letterSpacing: 0.3,
              ),
            ),
          ],
        ),
      );

  Widget _dateTimePanel(String date, String time) => Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: const Color(0xFFFFFBF5),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: const Color(0xFFE5D5C3).withValues(alpha: 0.5),
            width: 1.5,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFFFB547), Color(0xFFFF8A00)],
                ),
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFFF8A00).withValues(alpha: 0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  )
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
                date,
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
                  color: const Color(0xFF5D6CC4).withValues(alpha: 0.3),
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
              time,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: Color(0xFF5D6CC4),
              ),
            ),
          ],
        ),
      );

  Widget _dividerGlow(Color c) => Container(
        height: 2,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Colors.transparent,
              c.withValues(alpha: 0.3),
              Colors.transparent
            ],
          ),
        ),
      );

  Widget _approvedBox(String? approver) => Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: const Color(0xFFD1FAE5).withValues(alpha: 0.4),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: const Color(0xFF10B981).withValues(alpha: 0.2),
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
                  color: const Color(0xFF10B981).withValues(alpha: 0.3),
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
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'APPROVED BY',
                    style: TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF10B981).withValues(alpha: 0.7),
                      letterSpacing: 0.8,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    approver ?? '-',
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
      );

  Widget _cancelButton(VoidCallback onTap) => SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFEF4444),
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 14),
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
            shadowColor: const Color(0xFFEF4444).withValues(alpha: 0.3),
          ),
          onPressed: onTap,
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
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
      );

  Widget _rejectedBox(BookingStatus status, String? reason) {
    final isRejected = status == BookingStatus.rejected;
    final title = isRejected ? 'Booking Rejected' : 'Booking Cancelled';
    final base =
        isRejected ? const Color(0xFFF59E0B) : const Color(0xFFEF4444);

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: (isRejected
                ? const Color(0xFFFEF3C7)
                : const Color(0xFFFEE2E2))
            .withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: base.withValues(alpha: 0.2),
          width: 1.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.info_rounded,
                size: 16,
                color: base.withValues(alpha: 0.8),
              ),
              const SizedBox(width: 8),
              Text(
                title,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  color: base.withValues(alpha: 0.8),
                  letterSpacing: 0.3,
                ),
              ),
            ],
          ),
          if (reason != null && reason.isNotEmpty) ...[
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.6),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: base.withValues(alpha: 0.15),
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
                      color:
                          const Color(0xFF8B6F47).withValues(alpha: 0.8),
                    ),
                  ),
                  Expanded(
                    child: Text(
                      reason,
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF1A1A2E),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}