import 'package:flutter/material.dart';

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
        scaffoldBackgroundColor: const Color(0xFFFBF0E6),
        useMaterial3: true,
      ),
      home: const BookingRequestsPage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

enum BookingStatus { pending, approved, rejected }

class Booking {
  final int room;
  final DateTime date;
  final TimeOfDay start;
  final TimeOfDay end;
  final String bookedBy;
  BookingStatus status;

  Booking({
    required this.room,
    required this.date,
    required this.start,
    required this.end,
    required this.bookedBy,
    this.status = BookingStatus.pending,
  });
}

class BookingRequestsPage extends StatefulWidget {
  const BookingRequestsPage({super.key});

  @override
  State<BookingRequestsPage> createState() => _BookingRequestsPageState();
}

class _BookingRequestsPageState extends State<BookingRequestsPage> {
  int _selectedIndex = 2;
  int _totalBookings = 1;

  Booking booking = Booking(
    room: 1,
    date: DateTime(2024, 3, 15),
    start: const TimeOfDay(hour: 8, minute: 0),
    end: const TimeOfDay(hour: 10, minute: 0),
    bookedBy: 'Ethan Carter',
    status: BookingStatus.pending,
  );

  void _approve() {
    setState(() {
      booking.status = BookingStatus.approved;
      _totalBookings = 0;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Booking approved')),
    );
  }

  void _reject() {
    setState(() {
      booking.status = BookingStatus.rejected;
      _totalBookings = 0;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Booking rejected')),
    );
  }

  void _onNavTap(int idx) {
    setState(() {
      _selectedIndex = idx;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Tapped navigation item $idx')),
    );
  }

  // ฟังก์ชันฟอร์แมตวันที่แบบ manual (แทน DateFormat)
  String _formatDate(DateTime date) {
    const months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }

  Widget _buildTopHeader() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(0, 3)),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFFFFE7D9),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.schedule, color: Color(0xFFB75F00)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Booking Request',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 6),
                Text(
                  '$_totalBookings Total Bookings',
                  style: TextStyle(
                    color: Colors.black.withOpacity(0.6),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          const Icon(Icons.chevron_right, color: Colors.black26),
        ],
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
        bg = const Color(0xFFFFF3E0);
        text = const Color(0xFFB26A00);
        label = 'Pending';
        icon = Icons.hourglass_top;
        break;
      case BookingStatus.approved:
        bg = const Color(0xFFE8F6E8);
        text = const Color(0xFF0B7A3E);
        label = 'Approved';
        icon = Icons.check_circle_outline;
        break;
      case BookingStatus.rejected:
        bg = const Color(0xFFFCEAEA);
        text = const Color(0xFFB71C1C);
        label = 'Rejected';
        icon = Icons.cancel_outlined;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: text),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(color: text, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }

  Widget _bookingCard(Booking b) {
    final dateStr = _formatDate(b.date);
    final timeStr = '${b.start.format(context)} - ${b.end.format(context)}';

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFFDF6F0),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFDCEEDD)),
      ),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: const Color(0xFFEDEFFE),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.meeting_room, color: Color(0xFF1E2A78)),
                    const SizedBox(height: 4),
                    Text(
                      '${b.room}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      dateStr,
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(Icons.access_time_outlined, size: 18),
                        const SizedBox(width: 8),
                        Text(
                          timeStr,
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF0ECFD),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        children: [
                          const CircleAvatar(
                            radius: 16,
                            backgroundColor: Color(0xFFE8E8FF),
                            child: Icon(Icons.person, color: Color(0xFF5850A6)),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              'Booked by\n${b.bookedBy}',
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              _statusChip(b.status),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              ElevatedButton.icon(
                onPressed: b.status == BookingStatus.pending ? _approve : null,
                icon: const Icon(Icons.check),
                label: const Text('Approve'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF23B85B),
                  disabledBackgroundColor: const Color(0xFFBDE9C9),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 12,
                  ),
                ),
              ),
              ElevatedButton.icon(
                onPressed: b.status == BookingStatus.pending ? _reject : null,
                icon: const Icon(Icons.close),
                label: const Text('Reject'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFF5C5C),
                  disabledBackgroundColor: const Color(0xFFF6C6C6),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 12,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNav() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      color: Colors.transparent,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(30),
        child: BottomNavigationBar(
          currentIndex: _selectedIndex,
          onTap: _onNavTap,
          type: BottomNavigationBarType.fixed,
          backgroundColor: const Color(0xFFDA0E0E),
          selectedItemColor: Colors.white,
          unselectedItemColor: Colors.white70,
          showSelectedLabels: false,
          showUnselectedLabels: false,
          items: [
            const BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
            const BottomNavigationBarItem(icon: Icon(Icons.grid_view), label: 'Grid'),
            BottomNavigationBarItem(
              icon: Stack(
                clipBehavior: Clip.none,
                children: [
                  const Padding(
                    padding: EdgeInsets.only(bottom: 2),
                    child: Icon(Icons.notifications),
                  ),
                  if (_totalBookings > 0)
                    Positioned(
                      right: -6,
                      top: -6,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                        child: Text(
                          '$_totalBookings',
                          style: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: Colors.red,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
              label: 'Notifications',
            ),
            const BottomNavigationBarItem(icon: Icon(Icons.schedule), label: 'Clock'),
            const BottomNavigationBarItem(icon: Icon(Icons.settings), label: 'Settings'),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Container(
              height: 8,
              decoration: const BoxDecoration(
                border: Border(
                  bottom: BorderSide(color: Color(0xFF6F2AA3), width: 3),
                ),
              ),
            ),
            const SizedBox(height: 8),
            _buildTopHeader(),
            const SizedBox(height: 6),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.only(bottom: 18),
                children: [
                  const SizedBox(height: 6),
                  _bookingCard(booking),
                  if (booking.status != BookingStatus.pending && _totalBookings == 0)
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: const [
                          BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(0, 3)),
                        ],
                      ),
                      child: const Center(
                        child: Text(
                          'No pending bookings',
                          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }
}