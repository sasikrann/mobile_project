import 'package:flutter/material.dart';
import 'student_shell.dart';

/// ===============================
/// BookRoomPage (date is String)
/// ===============================
class BookRoomPage extends StatefulWidget {
  const BookRoomPage({super.key});

  @override
  State<BookRoomPage> createState() => _BookRoomPageState();
}

class _BookRoomPageState extends State<BookRoomPage>
    with TickerProviderStateMixin {
  String? selectedTime;
  // 🔒 ใช้ String ธรรมดา (แก้เป็นค่าที่คุณต้องการได้เลย)
  String fixedDate = "29/10/2025";
  final TextEditingController purposeController = TextEditingController();
  late AnimationController _animController;

  final List<Map<String, String>> timeSlots = const [
    {'start': '08:00', 'end': '10:00'},
    {'start': '10:00', 'end': '12:00'},
    {'start': '13:00', 'end': '15:00'},
    {'start': '15:00', 'end': '17:00'},
  ];

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
    purposeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFFFFFBF5),
              Color(0xFFFEF3E2),
              Color(0xFFFCE8CD),
            ],
            stops: [0.0, 0.5, 1.0],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // ===== Header =====
              FadeTransition(
                opacity: _animController,
                child: Container(
                  margin: const EdgeInsets.all(20),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.white.withOpacity(0.9),
                        Colors.white.withOpacity(0.7),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.5),
                      width: 2,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFFD61F26).withOpacity(0.15),
                        blurRadius: 20,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: const Color(0xFFFEF3E2),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: const Color(0xFFD61F26).withOpacity(0.2),
                            width: 2,
                          ),
                        ),
                        child: IconButton(
                          icon: const Icon(Icons.arrow_back_ios_new_rounded,
                              size: 18),
                          color: const Color(0xFFD61F26),
                          padding: EdgeInsets.zero,
                          onPressed: () {
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const StudentShell(),
                              ),
                            );
                          },
                        ),
                      ),
                      const Expanded(
                        child: Text(
                          'Book a Room',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Color(0xFFD61F26),
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                            letterSpacing: -0.5,
                          ),
                        ),
                      ),
                      const SizedBox(width: 44),
                    ],
                  ),
                ),
              ),

              // ===== Main =====
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  physics: const BouncingScrollPhysics(),
                  child: FadeTransition(
                    opacity: _animController,
                    child: Container(
                      padding: const EdgeInsets.all(28),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(28),
                        border: Border.all(
                          color: const Color(0xFFD61F26).withOpacity(0.2),
                          width: 2,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFFD61F26).withOpacity(0.15),
                            blurRadius: 28,
                            offset: const Offset(0, 10),
                            spreadRadius: -4,
                          ),
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 16,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Title
                          const Row(
                            children: [
                              Icon(Icons.meeting_room_rounded,
                                  color: Color(0xFFD61F26), size: 32),
                              SizedBox(width: 10),
                              Text(
                                "Room 1",
                                style: TextStyle(
                                  fontSize: 26,
                                  fontWeight: FontWeight.w800,
                                  color: Color(0xFF1A1A2E),
                                  letterSpacing: -0.5,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 28),

                          // Date (String, not selectable)
                          const Text(
                            "Date",
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 15,
                              color: Color(0xFF1A1A2E),
                              letterSpacing: 0.3,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFFFBF5),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: const Color(0xFFE5D5C3),
                                width: 2,
                              ),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    gradient: const LinearGradient(
                                      colors: [
                                        Color(0xFFFFB547),
                                        Color(0xFFFF8A00),
                                      ],
                                    ),
                                    borderRadius: BorderRadius.circular(12),
                                    boxShadow: [
                                      BoxShadow(
                                        color: const Color(0xFFFF8A00)
                                            .withOpacity(0.3),
                                        blurRadius: 8,
                                        offset: const Offset(0, 3),
                                      ),
                                    ],
                                  ),
                                  child: const Icon(
                                    Icons.calendar_today_rounded,
                                    size: 20,
                                    color: Colors.white,
                                  ),
                                ),
                                const SizedBox(width: 14),
                                Expanded(
                                  child: Text(
                                    fixedDate,
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w700,
                                      color: Color(0xFF1A1A2E),
                                    ),
                                  ),
                                ),
                                const Icon(
                                  Icons.lock_rounded,
                                  size: 18,
                                  color: Color(0xFF8B6F47),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 24),

                          // Time Slot
                          const Text(
                            "Available Time Slots",
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 15,
                              color: Color(0xFF1A1A2E),
                              letterSpacing: 0.3,
                            ),
                          ),
                          const SizedBox(height: 10),
                          ...timeSlots.map((slot) {
                            final label =
                                "${slot['start']} - ${slot['end']}";
                            final isSelected = selectedTime == label;
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: InkWell(
                                onTap: () => setState(() => selectedTime = label),
                                borderRadius: BorderRadius.circular(16),
                                child: Container(
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: isSelected
                                        ? const Color(0xFFFEE2E2)
                                        : const Color(0xFFFFFBF5),
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(
                                      color: isSelected
                                          ? const Color(0xFFD61F26)
                                          : const Color(0xFFE5D5C3),
                                      width: 2,
                                    ),
                                    boxShadow: isSelected
                                        ? [
                                            BoxShadow(
                                              color: const Color(0xFFD61F26)
                                                  .withOpacity(0.2),
                                              blurRadius: 12,
                                              offset: const Offset(0, 4),
                                            ),
                                          ]
                                        : [],
                                  ),
                                  child: Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(10),
                                        decoration: BoxDecoration(
                                          color: isSelected
                                              ? const Color(0xFFD61F26)
                                              : const Color(0xFFE0E4F7),
                                          borderRadius:
                                              BorderRadius.circular(12),
                                        ),
                                        child: Icon(
                                          Icons.access_time_rounded,
                                          size: 20,
                                          color: isSelected
                                              ? Colors.white
                                              : const Color(0xFF5D6CC4),
                                        ),
                                      ),
                                      const SizedBox(width: 14),
                                      Expanded(
                                        child: Text(
                                          label,
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w700,
                                            color: isSelected
                                                ? const Color(0xFFD61F26)
                                                : const Color(0xFF1A1A2E),
                                          ),
                                        ),
                                      ),
                                      if (isSelected)
                                        const Icon(
                                          Icons.check_circle_rounded,
                                          color: Color(0xFFD61F26),
                                          size: 24,
                                        ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                          const SizedBox(height: 24),

                          // Purpose
                          const Text(
                            "Purpose of Booking (Optional)",
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 15,
                              color: Color(0xFF1A1A2E),
                              letterSpacing: 0.3,
                            ),
                          ),
                          const SizedBox(height: 10),
                          TextField(
                            controller: purposeController,
                            maxLines: 3,
                            decoration: InputDecoration(
                              hintText:
                                  'Enter the purpose of your booking...',
                              hintStyle: TextStyle(
                                color:
                                    const Color(0xFF8B6F47).withOpacity(0.5),
                              ),
                              filled: true,
                              fillColor: const Color(0xFFFFFBF5),
                              contentPadding: const EdgeInsets.all(16),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16),
                                borderSide: const BorderSide(
                                  color: Color(0xFFE5D5C3),
                                  width: 2,
                                ),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16),
                                borderSide: const BorderSide(
                                  color: Color(0xFFE5D5C3),
                                  width: 2,
                                ),
                              ),
                              focusedBorder: const OutlineInputBorder(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(16)),
                                borderSide: BorderSide(
                                  color: Color(0xFFD61F26),
                                  width: 2,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 32),

                          // Buttons
                          Row(
                            children: [
                              Expanded(
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFFF5F5F5),
                                    foregroundColor: const Color(0xFF1A1A2E),
                                    padding:
                                        const EdgeInsets.symmetric(vertical: 16),
                                    elevation: 0,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(16),
                                      side: const BorderSide(
                                        color: Color(0xFFE5D5C3),
                                        width: 2,
                                      ),
                                    ),
                                  ),
                                  onPressed: () {
                                    Navigator.pushReplacement(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => const StudentShell(),
                                      ),
                                    );
                                  },
                                  child: const Text(
                                    "Cancel",
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: selectedTime == null
                                        ? const Color(0xFFE5D5C3)
                                        : const Color(0xFFD61F26),
                                    foregroundColor: Colors.white,
                                    padding:
                                        const EdgeInsets.symmetric(vertical: 16),
                                    elevation: 0,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    shadowColor: const Color(0xFFD61F26)
                                        .withOpacity(0.3),
                                  ),
                                  onPressed: selectedTime == null
                                      ? null
                                      : () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (_) => ConfirmBookingPage(
                                                date: fixedDate,
                                                time: selectedTime!,
                                                purpose:
                                                    purposeController
                                                            .text.isEmpty
                                                        ? '-'
                                                        : purposeController.text,
                                              ),
                                            ),
                                          );
                                        },
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: const [
                                      Text(
                                        "Confirm",
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                      SizedBox(width: 8),
                                      Icon(Icons.arrow_forward_rounded, size: 20),
                                    ],
                                  ),
                                ),
                              ),
                            ],
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

/// =======================================
/// ConfirmBookingPage (styled, full UI)
/// =======================================
class ConfirmBookingPage extends StatelessWidget {
  final String date;
  final String time;
  final String purpose;

  const ConfirmBookingPage({
    super.key,
    required this.date,
    required this.time,
    required this.purpose,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFFFFFBF5),
              Color(0xFFFEF3E2),
              Color(0xFFFCE8CD),
            ],
            stops: [0.0, 0.5, 1.0],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Header
              Container(
                margin: const EdgeInsets.all(20),
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.white.withOpacity(0.9),
                      Colors.white.withOpacity(0.7),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.5),
                    width: 2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF10B981).withOpacity(0.15),
                      blurRadius: 20,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: const Color(0xFFFEF3E2),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: const Color(0xFF10B981).withOpacity(0.2),
                          width: 2,
                        ),
                      ),
                      child: IconButton(
                        icon: const Icon(Icons.arrow_back_ios_new_rounded,
                            size: 18),
                        color: const Color(0xFF10B981),
                        padding: EdgeInsets.zero,
                        onPressed: () => Navigator.pop(context),
                      ),
                    ),
                    const Expanded(
                      child: Text(
                        'Confirm Booking',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Color(0xFF10B981),
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.5,
                        ),
                      ),
                    ),
                    const SizedBox(width: 44),
                  ],
                ),
              ),

              // Content
              Expanded(
                child: Center(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Container(
                      padding: const EdgeInsets.all(32),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(28),
                        border: Border.all(
                          color: const Color(0xFF10B981).withOpacity(0.2),
                          width: 2,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF10B981).withOpacity(0.15),
                            blurRadius: 28,
                            offset: const Offset(0, 10),
                            spreadRadius: -4,
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Success Icon
                          Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: const Color(0xFFD1FAE5),
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0xFF10B981).withOpacity(0.3),
                                  blurRadius: 20,
                                  offset: const Offset(0, 6),
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.check_circle_rounded,
                              color: Color(0xFF10B981),
                              size: 80,
                            ),
                          ),
                          const SizedBox(height: 24),
                          const Text(
                            "Booking Confirmed!",
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF1A1A2E),
                              letterSpacing: -0.5,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            "Your room has been reserved",
                            style: TextStyle(
                              fontSize: 14,
                              color: const Color(0xFF64748B).withOpacity(0.7),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 32),

                          // Details
                          _buildDetailCard(
                            icon: Icons.calendar_today_rounded,
                            iconColor: const Color(0xFFFF8A00),
                            iconBg: const Color(0xFFFEF3C7),
                            label: "Date",
                            value: date,
                          ),
                          const SizedBox(height: 14),
                          _buildDetailCard(
                            icon: Icons.access_time_rounded,
                            iconColor: const Color(0xFF6366F1),
                            iconBg: const Color(0xFFDDD6FE),
                            label: "Time",
                            value: time,
                          ),
                          const SizedBox(height: 14),
                          _buildDetailCard(
                            icon: Icons.edit_note_rounded,
                            iconColor: const Color(0xFFD61F26),
                            iconBg: const Color(0xFFFEE2E2),
                            label: "Purpose",
                            value: purpose,
                          ),
                          const SizedBox(height: 36),

                          // Button
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF10B981),
                                foregroundColor: Colors.white,
                                padding:
                                    const EdgeInsets.symmetric(vertical: 18),
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(18),
                                ),
                                shadowColor: const Color(0xFF10B981)
                                    .withOpacity(0.3),
                              ),
                              onPressed: () {
                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) =>
                                        const StudentShell(initialIndex: 1),
                                  ),
                                );
                              },
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: const [
                                  Icon(Icons.calendar_month_rounded, size: 22),
                                  SizedBox(width: 10),
                                  Text(
                                    "Go to My Bookings",
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ],
                              ),
                            ),
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

  // ===== Helper: detail card =====
  Widget _buildDetailCard({
    required IconData icon,
    required Color iconColor,
    required Color iconBg,
    required String label,
    required String value,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFBF5),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFFE5D5C3),
          width: 2,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: iconBg,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: iconColor.withOpacity(0.3),
                width: 1.5,
              ),
            ),
            child: Icon(icon, color: iconColor, size: 20),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF8B6F47),
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 15,
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
  }
}