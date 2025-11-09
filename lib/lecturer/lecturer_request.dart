import 'dart:convert';
import 'package:flutter/material.dart';

// ✅ ปรับ path ให้ตรงโปรเจกต์ของคุณเอง
import '../services/api_client.dart';

void main() {
  runApp(const BookingApp());
}

class BookingApp extends StatelessWidget {
  const BookingApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Booking Request UI',
      theme: ThemeData(
        primarySwatch: Colors.red,
        scaffoldBackgroundColor: const Color(0xFFFFFBF5),
        useMaterial3: true,
        fontFamily: 'SF Pro Display',
      ),
      home: const BookingRequestsPage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

enum BookingStatus { pending, approved, rejected }

class Booking {
  final int id; // booking_id จาก DB
  final String room; // ✅ เก็บชื่อห้องเป็น String แล้ว
  final DateTime date;
  final TimeOfDay start;
  final TimeOfDay end;
  final String bookedBy;
  BookingStatus status;
  String? rejectReason;

  Booking({
    required this.id,
    required this.room,
    required this.date,
    required this.start,
    required this.end,
    required this.bookedBy,
    this.status = BookingStatus.pending,
    this.rejectReason,
  });

  // ✅ แปลง JSON จากหลังบ้าน -> Booking
  factory Booking.fromJson(Map<String, dynamic> json) {
    // id / booking_id
    final idRaw = json['booking_id'] ?? json['id'] ?? 0;
    final int id = idRaw is int ? idRaw : int.tryParse(idRaw.toString()) ?? 0;

    // ✅ ดึงชื่อห้อง: รองรับหลาย key จากหลังบ้าน
    final String room =
        (json['room_name'] ??
                json['room_number'] ??
                json['room'] ??
                json['roomNo'] ??
                json['name'] ??
                '')
            .toString();

    // booking_date (คาดว่าเป็น "2025-11-08" หรือ ISO String)
    final String dateStr =
        (json['booking_date'] ?? json['date'] ?? '') as String;
    DateTime date;
    try {
      date = DateTime.parse(dateStr);
    } catch (_) {
      date = DateTime.now();
    }

    // time_slot: "08:00-10:00" หรือ "08:00 - 10:00"
    final String slot = (json['time_slot'] ?? json['time'] ?? '') as String;
    String startStr = '00:00';
    String endStr = '00:00';
    if (slot.contains('-')) {
      final parts = slot.split('-');
      if (parts.length >= 2) {
        startStr = parts[0].trim();
        endStr = parts[1].trim();
      }
    }

    TimeOfDay parseTime(String t) {
      final p = t.split(':');
      if (p.length >= 2) {
        final h = int.tryParse(p[0]) ?? 0;
        final m = int.tryParse(p[1]) ?? 0;
        return TimeOfDay(hour: h, minute: m);
      }
      return const TimeOfDay(hour: 0, minute: 0);
    }

    final start = parseTime(startStr);
    final end = parseTime(endStr);

    // bookedBy
    final bookedBy =
        (json['booked_by'] ??
                json['student_name'] ??
                json['lecturer_name'] ??
                '')
            as String;

    // status
    final statusRaw = (json['status'] ?? 'pending').toString().toLowerCase();
    BookingStatus status;
    if (statusRaw == 'approved' || statusRaw == 'confirm') {
      status = BookingStatus.approved;
    } else if (statusRaw == 'rejected') {
      status = BookingStatus.rejected;
    } else {
      status = BookingStatus.pending;
    }

    return Booking(
      id: id,
      room: room,
      date: date,
      start: start,
      end: end,
      bookedBy: bookedBy,
      status: status,
      rejectReason: json['reject_reason'] as String?,
    );
  }
}

class BookingRequestsPage extends StatefulWidget {
  const BookingRequestsPage({super.key});

  @override
  State<BookingRequestsPage> createState() => _BookingRequestsPageState();
}

class _BookingRequestsPageState extends State<BookingRequestsPage>
    with SingleTickerProviderStateMixin {
  int _totalBookings = 0;
  late AnimationController _animController;

  // 🔁 ใช้ list จากหลังบ้าน แทนตัวอย่างเดียว
  List<Booking> bookings = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..forward();

    fetchRequests();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  // ========== CALL API ==========

  Future<void> fetchRequests() async {
    try {
      final res = await ApiClient.get('/api/lecturer/requests');
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        final List list = data['requests'] ?? [];
        final newBookings = list
            .map((e) => Booking.fromJson(e as Map<String, dynamic>))
            .toList();

        setState(() {
          bookings = newBookings;
          _totalBookings = bookings.length;
          _loading = false;
        });

        _animController.forward(from: 0); // รีรันอนิเมชั่น
      } else {
        setState(() => _loading = false);
      }
    } catch (_) {
      setState(() => _loading = false);
    }
  }

  Future<void> approveBooking(Booking b) async {
    try {
      await ApiClient.post(
        '/api/lecturer/approve',
        body: {'booking_id': b.id, 'decision': 'Approved'},
      );
      _showTopNotification(
        'Booking approved successfully!',
        const Color(0xFF10B981),
        Icons.check_circle_rounded,
      );
      await fetchRequests();
    } catch (_) {
      _showTopNotification(
        'Failed to approve booking',
        const Color(0xFFEF4444),
        Icons.error_outline_rounded,
      );
    }
  }

  Future<void> rejectBooking(Booking b, String reason) async {
    try {
      await ApiClient.post(
        '/api/lecturer/approve',
        body: {'booking_id': b.id, 'decision': 'Rejected', 'reason': reason},
      );
      _showTopNotification(
        'Booking rejected',
        const Color(0xFFEF4444),
        Icons.cancel_rounded,
      );
      await fetchRequests();
    } catch (_) {
      _showTopNotification(
        'Failed to reject booking',
        const Color(0xFFEF4444),
        Icons.error_outline_rounded,
      );
    }
  }

  // ========== UI เดิม (ปรับให้ใช้ bookings) ==========

  void _showRejectDialog(Booking booking) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => RejectReasonSheet(
        onReject: (reason) async {
          Navigator.pop(context);
          await rejectBooking(booking, reason);
        },
      ),
    );
  }

  void _showTopNotification(String message, Color color, IconData icon) {
    final overlay = Overlay.of(context);

    late OverlayEntry entry;
    entry = OverlayEntry(
      builder: (context) => Positioned(
        top: MediaQuery.of(context).padding.top + 16,
        left: 16,
        right: 16,
        child: Material(
          color: Colors.transparent,
          child: TweenAnimationBuilder<double>(
            tween: Tween(begin: -100, end: 0),
            duration: const Duration(milliseconds: 400),
            curve: Curves.easeOut,
            builder: (context, value, child) {
              return Transform.translate(
                offset: Offset(0, value),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: color.withValues(alpha: 0.4),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Icon(icon, color: Colors.white, size: 24),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          message,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
            onEnd: () => Future.delayed(
              const Duration(seconds: 2),
              () => entry.remove(),
            ),
          ),
        ),
      ),
    );
    overlay.insert(entry);
  }

  String _formatDate(DateTime date) {
    const months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }

  Widget _buildTopHeader() {
    return FadeTransition(
      opacity: _animController,
      child: SlideTransition(
        position: Tween<Offset>(begin: const Offset(0, -0.2), end: Offset.zero)
            .animate(
              CurvedAnimation(parent: _animController, curve: Curves.easeOut),
            ),
        child: Container(
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
                  Icons.schedule_rounded,
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
                      'Booking Requests',
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
                          '$_totalBookings ${_totalBookings == 1 ? 'Request' : 'Requests'} Pending',
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
        ),
      ),
    );
  }

  Widget _statusChip(BookingStatus status) {
    Color bg;
    Color text;
    String label;
    IconData icon;

    switch (status) {
      case BookingStatus.pending:
        bg = const Color(0xFFEDE9FE);
        text = const Color(0xFF7C3AED);
        label = 'Pending';
        icon = Icons.schedule_rounded;
        break;
      case BookingStatus.approved:
        bg = const Color(0xFFD1FAE5);
        text = const Color(0xFF10B981);
        label = 'Approved';
        icon = Icons.check_circle_rounded;
        break;
      case BookingStatus.rejected:
        bg = const Color(0xFFFEE2E2);
        text = const Color(0xFFEF4444);
        label = 'Rejected';
        icon = Icons.cancel_rounded;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: text.withValues(alpha: 0.3), width: 2),
        boxShadow: [
          BoxShadow(
            color: text.withValues(alpha: 0.2),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: text),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w800,
              color: text,
              letterSpacing: 0.3,
            ),
          ),
        ],
      ),
    );
  }

  Widget _bookingCard(Booking b) {
    final dateStr = _formatDate(b.date);
    final timeStr = '${b.start.format(context)} - ${b.end.format(context)}';
    final animation = CurvedAnimation(
      parent: _animController,
      curve: const Interval(0.2, 0.7, curve: Curves.easeOut),
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
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Colors.white, Colors.white.withValues(alpha: 0.95)],
          ),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: b.status == BookingStatus.pending
                ? const Color(0xFF7C3AED).withValues(alpha: 0.2)
                : b.status == BookingStatus.approved
                ? const Color(0xFF10B981).withValues(alpha: 0.2)
                : const Color(0xFFEF4444).withValues(alpha: 0.2),
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 20,
              offset: const Offset(0, 8),
              spreadRadius: -3,
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
                      (b.status == BookingStatus.pending
                              ? const Color(0xFF7C3AED)
                              : b.status == BookingStatus.approved
                              ? const Color(0xFF10B981)
                              : const Color(0xFFEF4444))
                          .withValues(alpha: 0.08),
                      Colors.transparent,
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
                  // Room + Status
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFF5D6CC4), Color(0xFF4A5AB3)],
                          ),
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(
                                0xFF5D6CC4,
                              ).withValues(alpha: 0.3),
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
                              b.room,
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
                      _statusChip(b.status),
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
                                color: const Color(
                                  0xFFFF8A00,
                                ).withValues(alpha: 0.3),
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
                            dateStr,
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
                              ).withValues(alpha: 0.3),
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
                          timeStr,
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

                  // Booked by
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          const Color(0xFF5D6CC4).withValues(alpha: 0.08),
                          const Color(0xFF4A5AB3).withValues(alpha: 0.05),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: const Color(0xFF5D6CC4).withValues(alpha: 0.2),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFF5D6CC4), Color(0xFF4A5AB3)],
                            ),
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: const Color(
                                  0xFF5D6CC4,
                                ).withValues(alpha: 0.3),
                                blurRadius: 8,
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.person_rounded,
                            color: Colors.white,
                            size: 20,
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
                                  fontSize: 9,
                                  fontWeight: FontWeight.w700,
                                  color: const Color(
                                    0xFF8B6F47,
                                  ).withValues(alpha: 0.7),
                                  letterSpacing: 0.8,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                b.bookedBy,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 15,
                                  letterSpacing: -0.3,
                                  color: Color(0xFF1A1A2E),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  if (b.status == BookingStatus.pending) ...[
                    const SizedBox(height: 16),
                    Container(
                      height: 2,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.transparent,
                            const Color(0xFF7C3AED).withValues(alpha: 0.3),
                            Colors.transparent,
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () => approveBooking(b),
                            icon: const Icon(Icons.check_rounded, size: 20),
                            label: const Text('Approve'),
                            style:
                                ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF10B981),
                                  foregroundColor: Colors.white,
                                  elevation: 0,
                                  shadowColor: const Color(
                                    0xFF10B981,
                                  ).withValues(alpha: 0.3),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 14,
                                  ),
                                ).copyWith(
                                  elevation: WidgetStateProperty.resolveWith((
                                    states,
                                  ) {
                                    if (states.contains(WidgetState.pressed)) {
                                      return 0;
                                    }
                                    return 4;
                                  }),
                                ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () => _showRejectDialog(b),
                            icon: const Icon(Icons.close_rounded, size: 20),
                            label: const Text('Reject'),
                            style:
                                ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFFEF4444),
                                  foregroundColor: Colors.white,
                                  elevation: 0,
                                  shadowColor: const Color(
                                    0xFFEF4444,
                                  ).withValues(alpha: 0.3),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 14,
                                  ),
                                ).copyWith(
                                  elevation: WidgetStateProperty.resolveWith((
                                    states,
                                  ) {
                                    if (states.contains(WidgetState.pressed)) {
                                      return 0;
                                    }
                                    return 4;
                                  }),
                                ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final allPending = bookings
        .where((b) => b.status == BookingStatus.pending)
        .toList();

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
              _buildTopHeader(),
              Expanded(
                child: _loading
                    ? const Center(child: CircularProgressIndicator())
                    : allPending.isNotEmpty
                    ? ListView(
                        padding: const EdgeInsets.only(bottom: 18),
                        children: [
                          const SizedBox(height: 8),
                          for (final b in allPending) _bookingCard(b),
                        ],
                      )
                    : Center(
                        child: FadeTransition(
                          opacity: _animController,
                          child: Container(
                            margin: const EdgeInsets.symmetric(horizontal: 24),
                            padding: const EdgeInsets.all(32),
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [Color(0xFFFFFFFF), Color(0xFFFFFBF8)],
                              ),
                              borderRadius: BorderRadius.circular(24),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.06),
                                  blurRadius: 20,
                                  offset: const Offset(0, 8),
                                ),
                              ],
                            ),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(20),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFFFFBF5),
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: const Color(
                                        0xFFE5D5C3,
                                      ).withValues(alpha: 0.5),
                                      width: 2,
                                    ),
                                  ),
                                  child: Icon(
                                    Icons.check_circle_rounded,
                                    size: 56,
                                    color: const Color(
                                      0xFF8B6F47,
                                    ).withValues(alpha: 0.5),
                                  ),
                                ),
                                const SizedBox(height: 20),
                                const Text(
                                  'All caught up!',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w800,
                                    fontSize: 22,
                                    letterSpacing: -0.5,
                                    color: Color(0xFF1A1A2E),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                const Text(
                                  'No pending bookings at the moment',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 14,
                                    color: Color(0xFF8B6F47),
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Reject Reason Bottom Sheet (เหมือนเดิม)
class RejectReasonSheet extends StatefulWidget {
  final Function(String) onReject;

  const RejectReasonSheet({super.key, required this.onReject});

  @override
  State<RejectReasonSheet> createState() => _RejectReasonSheetState();
}

class _RejectReasonSheetState extends State<RejectReasonSheet>
    with SingleTickerProviderStateMixin {
  final TextEditingController _reasonController = TextEditingController();
  String? _selectedReason;
  late AnimationController _animController;

  final List<String> _predefinedReasons = [
    'Room maintenance required',
    'Double booking conflict',
    'Equipment unavailable',
    'Insufficient notice',
    'Other',
  ];

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    )..forward();
  }

  @override
  void dispose() {
    _reasonController.dispose();
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SlideTransition(
      position: Tween<Offset>(begin: const Offset(0, 1), end: Offset.zero)
          .animate(
            CurvedAnimation(parent: _animController, curve: Curves.easeOut),
          ),
      child: Container(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom + 60,
        ),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.only(bottom: 40),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Handle bar
              Container(
                margin: const EdgeInsets.only(top: 12),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: const Color(0xFFE5D5C3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),

              Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFEE2E2),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: const Color(
                                0xFFEF4444,
                              ).withValues(alpha: 0.3),
                              width: 2,
                            ),
                          ),
                          child: const Icon(
                            Icons.cancel_rounded,
                            color: Color(0xFFEF4444),
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 14),
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Reject Booking',
                                style: TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.w800,
                                  color: Color(0xFF1A1A2E),
                                  letterSpacing: -0.5,
                                ),
                              ),
                              SizedBox(height: 2),
                              Text(
                                'Please provide a reason',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Color(0xFF8B6F47),
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Predefined reasons
                    const Text(
                      'Select a reason',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF1A1A2E),
                        letterSpacing: 0.2,
                      ),
                    ),
                    const SizedBox(height: 12),
                    ...List.generate(_predefinedReasons.length, (index) {
                      final reason = _predefinedReasons[index];
                      final isSelected = _selectedReason == reason;
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: InkWell(
                          onTap: () {
                            setState(() {
                              _selectedReason = reason;
                              if (reason != 'Other') {
                                _reasonController.text = reason;
                              } else {
                                _reasonController.clear();
                              }
                            });
                          },
                          borderRadius: BorderRadius.circular(14),
                          child: Container(
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? const Color(0xFFFEE2E2)
                                  : const Color(0xFFFFFBF5),
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                color: isSelected
                                    ? const Color(0xFFEF4444)
                                    : const Color(0xFFE5D5C3),
                                width: 2,
                              ),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  isSelected
                                      ? Icons.radio_button_checked_rounded
                                      : Icons.radio_button_off_rounded,
                                  color: isSelected
                                      ? const Color(0xFFEF4444)
                                      : const Color(0xFF8B6F47),
                                  size: 20,
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    reason,
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      color: isSelected
                                          ? const Color(0xFFEF4444)
                                          : const Color(0xFF1A1A2E),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    }),

                    if (_selectedReason == 'Other') ...[
                      const SizedBox(height: 16),
                      const Text(
                        'Additional details',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF1A1A2E),
                          letterSpacing: 0.2,
                        ),
                      ),
                      const SizedBox(height: 10),
                      TextField(
                        controller: _reasonController,
                        maxLines: 3,
                        autofocus: true,
                        onChanged: (value) => setState(() {}),
                        decoration: InputDecoration(
                          hintText: 'Enter rejection reason...',
                          hintStyle: TextStyle(
                            color: const Color(
                              0xFF8B6F47,
                            ).withValues(alpha: 0.5),
                          ),
                          filled: true,
                          fillColor: const Color(0xFFFFFBF5),
                          contentPadding: const EdgeInsets.all(14),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: const BorderSide(
                              color: Color(0xFFE5D5C3),
                              width: 2,
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: const BorderSide(
                              color: Color(0xFFE5D5C3),
                              width: 2,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: const BorderSide(
                              color: Color(0xFFEF4444),
                              width: 2,
                            ),
                          ),
                        ),
                      ),
                    ],

                    const SizedBox(height: 24),

                    // Action buttons
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFF5F5F5),
                              foregroundColor: const Color(0xFF1A1A2E),
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                                side: const BorderSide(
                                  color: Color(0xFFE5D5C3),
                                  width: 2,
                                ),
                              ),
                            ),
                            onPressed: () => Navigator.pop(context),
                            child: const Text(
                              'Cancel',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor:
                                  _selectedReason == null ||
                                      (_selectedReason == 'Other' &&
                                          _reasonController.text.trim().isEmpty)
                                  ? const Color(0xFFE5D5C3)
                                  : const Color(0xFFEF4444),
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                            onPressed:
                                _selectedReason == null ||
                                    (_selectedReason == 'Other' &&
                                        _reasonController.text.trim().isEmpty)
                                ? null
                                : () {
                                    widget.onReject(
                                      _reasonController.text.trim(),
                                    );
                                  },
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: const [
                                Icon(Icons.cancel_rounded, size: 20),
                                SizedBox(width: 8),
                                Text(
                                  'Reject',
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
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
