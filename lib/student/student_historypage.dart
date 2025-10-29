import 'package:flutter/material.dart';

void main() => runApp(const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: MyBookingsPage(),
    ));

class MyBookingsPage extends StatelessWidget {
  const MyBookingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    // 📌 ตัวอย่างข้อมูล (เปลี่ยนเป็น [] เพื่อทดสอบ No reservations found)
    final bookings = <_Booking>[
      _Booking(
          room: 'Room 1',
          date: '10 Oct 2025',
          time: '10:00 - 12:00',
          status: BookingStatus.confirmed,
          approver: 'Sophia Bennett'),
      _Booking(
          room: 'Room 2',
          date: '11 Oct 2025',
          time: '13:00 - 15:00',
          status: BookingStatus.pending),
      _Booking(
          room: 'Room 3',
          date: '14 Oct 2025',
          time: '10:00 - 12:00',
          status: BookingStatus.cancelled),
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFF8EBDD), // พื้นหลังครีม
      appBar: AppBar(
        backgroundColor: const Color(0xFFD61F26),
        centerTitle: true,
        elevation: 0,
        title: const Text(
          'My Bookings',
          style: TextStyle(
            fontWeight: FontWeight.w800,
            fontSize: 18,
            color: Colors.white,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 440),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
            child: bookings.isEmpty
                ? const Center(
                    child: Text(
                      'No reservations found',
                      style: TextStyle(
                        color: Color(0xFF6B7280),
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  )
                : ListView.separated(
                    itemCount: bookings.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 14),
                    itemBuilder: (context, index) {
                      final b = bookings[index];
                      return _BookingCard(booking: b);
                    },
                  ),
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
class _BookingCard extends StatelessWidget {
  final _Booking booking;
  const _BookingCard({required this.booking});

  @override
  Widget build(BuildContext context) {
    final chip = _statusChip(booking.status);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: Color(0x14000000),
            blurRadius: 12,
            offset: Offset(0, 6),
          ),
        ],
      ),
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Room name + Status chip
          Row(
            children: [
              Expanded(
                child: Text(
                  booking.room,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF1A1A1A),
                  ),
                ),
              ),
              chip,
            ],
          ),
          const SizedBox(height: 8),

          // Date + Time
          Text(
            '${booking.date}, ${booking.time}',
            style: const TextStyle(
              fontSize: 13.5,
              color: Color(0xFF1A1A1A),
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 12),

          // Divider line
          const Divider(color: Color(0xFFE7E7E7), thickness: 1),
          const SizedBox(height: 8),

          // Details / Cancel button
          if (booking.status == BookingStatus.confirmed)
            Text(
              'Approved by ${booking.approver ?? '-'}',
              style: const TextStyle(
                fontSize: 12.5,
                color: Color(0xFF6B7280),
                fontWeight: FontWeight.w600,
              ),
            ),

          if (booking.status == BookingStatus.pending)
            Align(
              alignment: Alignment.centerLeft,
              child: SizedBox(
                height: 32,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFF5A3A6),
                    foregroundColor: const Color(0xFF6E1A1A),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    elevation: 0,
                  ),
                  onPressed: () {},
                  child: const Text(
                    'Cancel Booking',
                    style: TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 12.5,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  // ป้ายสถานะ
  Widget _statusChip(BookingStatus s) {
    switch (s) {
      case BookingStatus.confirmed:
        return _chip('Confirmed',
            bg: const Color(0xFFE7F7EC), fg: const Color(0xFF18A05B));
      case BookingStatus.pending:
        return _chip('Pending',
            bg: const Color(0xFFFFF4D7), fg: const Color(0xFFA37D00));
      case BookingStatus.cancelled:
        return _chip('Cancelled',
            bg: const Color(0xFFFDE6E7), fg: const Color(0xFFD33B42));
    }
  }

  Widget _chip(String text, {required Color bg, required Color fg}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: fg,
          fontSize: 12,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}
