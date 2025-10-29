import 'package:flutter/material.dart';
import 'student_shell.dart';

/// ===============================
/// BookRoomPage (date is String)
/// ===============================
class MyBookingsPage extends StatefulWidget {
  const MyBookingsPage({super.key});

  @override
  State<MyBookingsPage> createState() => _MyBookingsPageState();
}

class _MyBookingsPageState extends State<MyBookingsPage>
    with TickerProviderStateMixin {
  String? selectedTime; // label "HH:MM - HH:MM"
  String fixedDate = "30/10/2025"; // 🔒 ใช้ String ล็อกวัน
  final TextEditingController purposeController = TextEditingController();
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
    purposeController.dispose();
    super.dispose();
  }

  // ====== Timeslots with status ======
  // สถานะ:
  // - free: กดเลือกได้ (เดิม)
  // - reserved: มีคนอื่นจองและ "อนุมัติแล้ว" (เหลือง)
  // - pendingOther: คนอื่นจอง "รออนุมัติ" (Pending สีเหลือง)
  // - pendingMe: เราจองแล้ว "รออนุมัติ" (Pending สีม่วง/คราม แยกจากคนอื่น)
  final List<_Slot> _slots = <_Slot>[
    _Slot(start: '08:00', end: '10:00', status: SlotStatus.reserved),
    _Slot(start: '10:00', end: '12:00', status: SlotStatus.pendingOther),
    _Slot(start: '13:00', end: '15:00', status: SlotStatus.free),
    _Slot(start: '15:00', end: '17:00', status: SlotStatus.free),
  ];

  // helper: ค้นหาจาก label
  int _indexOfLabel(String label) => _slots.indexWhere((s) => s.label == label);

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
              // ===== Header =====
              FadeTransition(
                opacity: _animController,
                child: Container(
                  margin: const EdgeInsets.all(20),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 16,
                  ),
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
                          icon: const Icon(
                            Icons.arrow_back_ios_new_rounded,
                            size: 18,
                          ),
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
                              Icon(
                                Icons.meeting_room_rounded,
                                color: Color(0xFFD61F26),
                                size: 32,
                              ),
                              SizedBox(width: 10),
                              Text(
                                "Room 3",
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
                              children: const [
                                _CalIcon(),
                                SizedBox(width: 14),
                                Expanded(
                                  child: Text(
                                    "30/10/2025",
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w700,
                                      color: Color(0xFF1A1A2E),
                                    ),
                                  ),
                                ),
                                Icon(
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

                          ..._slots.map((slot) {
                            final isSelected = selectedTime == slot.label;
                            final palette = _paletteFor(
                              slot.status,
                              isSelected,
                            );

                            return Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: InkWell(
                                onTap: (slot.status == SlotStatus.free)
                                    ? () => setState(
                                        () => selectedTime = slot.label,
                                      )
                                    : null, // ❌ ช่องที่ไม่ว่างกดไม่ได้
                                borderRadius: BorderRadius.circular(16),
                                child: Container(
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: palette.tileBg,
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(
                                      color: palette.border,
                                      width: 2,
                                    ),
                                    boxShadow: isSelected
                                        ? [
                                            BoxShadow(
                                              color: palette.primary
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
                                          color: palette.iconBg,
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                          border: Border.all(
                                            color: palette.iconBorder,
                                            width: 1.5,
                                          ),
                                        ),
                                        child: Icon(
                                          Icons.access_time_rounded,
                                          size: 20,
                                          color: palette.iconFg,
                                        ),
                                      ),
                                      const SizedBox(width: 14),
                                      Expanded(
                                        child: Text(
                                          slot.label,
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w700,
                                            color: palette.text,
                                          ),
                                        ),
                                      ),

                                      // Badge ขวาแสดงสถานะ
                                      _StatusBadge(
                                        status: slot.status,
                                        isSelected: isSelected,
                                      ),

                                      if (isSelected)
                                        const Padding(
                                          padding: EdgeInsets.only(left: 10),
                                          child: Icon(
                                            Icons.check_circle_rounded,
                                            color: Color(0xFFD61F26),
                                            size: 22,
                                          ),
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
                              hintText: 'Enter the purpose of your booking...',
                              hintStyle: TextStyle(
                                color: const Color(0xFF8B6F47).withOpacity(0.5),
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
                                borderRadius: BorderRadius.all(
                                  Radius.circular(16),
                                ),
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
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 16,
                                    ),
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
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 16,
                                    ),
                                    elevation: 0,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    shadowColor: const Color(
                                      0xFFD61F26,
                                    ).withOpacity(0.3),
                                  ),
                                  onPressed: selectedTime == null
                                      ? null
                                      : () {
                                          // อัปเดตสถานะ slot ที่เราเลือกให้เป็น PendingMe
                                          final i = _indexOfLabel(
                                            selectedTime!,
                                          );
                                          if (i != -1) {
                                            setState(() {
                                              _slots[i] = _slots[i].copyWith(
                                                status: SlotStatus.pendingMe,
                                              );
                                            });
                                          }

                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (_) =>
                                                  ConfirmBookingPage(
                                                    date: fixedDate,
                                                    time: selectedTime!,
                                                    purpose:
                                                        purposeController
                                                            .text
                                                            .isEmpty
                                                        ? '-'
                                                        : purposeController
                                                              .text,
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
                                      Icon(
                                        Icons.arrow_forward_rounded,
                                        size: 20,
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
            colors: [Color(0xFFFFFBF5), Color(0xFFFEF3E2), Color(0xFFFCE8CD)],
            stops: [0.0, 0.5, 1.0],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Header
              Container(
                margin: const EdgeInsets.all(20),
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 16,
                ),
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
                        icon: const Icon(
                          Icons.arrow_back_ios_new_rounded,
                          size: 18,
                        ),
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
                                  color: const Color(
                                    0xFF10B981,
                                  ).withOpacity(0.3),
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
                                padding: const EdgeInsets.symmetric(
                                  vertical: 18,
                                ),
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(18),
                                ),
                                shadowColor: const Color(
                                  0xFF10B981,
                                ).withOpacity(0.3),
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
        border: Border.all(color: const Color(0xFFE5D5C3), width: 2),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: iconBg,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: iconColor.withOpacity(0.3), width: 1.5),
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

/* ===== UI helpers & models for slot ===== */

class _CalIcon extends StatelessWidget {
  const _CalIcon();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFFFB547), Color(0xFFFF8A00)],
        ),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFFF8A00).withOpacity(0.3),
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
    );
  }
}

enum SlotStatus { free, reserved, pendingOther, pendingMe }

class _Slot {
  final String start;
  final String end;
  final SlotStatus status;

  const _Slot({required this.start, required this.end, required this.status});

  String get label => '$start - $end';

  _Slot copyWith({String? start, String? end, SlotStatus? status}) => _Slot(
    start: start ?? this.start,
    end: end ?? this.end,
    status: status ?? this.status,
  );
}

/// สี/สไตล์ตามสถานะ (และกรณีถูกเลือก)
class _TilePalette {
  final Color tileBg;
  final Color border;
  final Color text;
  final Color iconBg;
  final Color iconBorder;
  final Color iconFg;
  final Color primary;

  const _TilePalette({
    required this.tileBg,
    required this.border,
    required this.text,
    required this.iconBg,
    required this.iconBorder,
    required this.iconFg,
    required this.primary,
  });
}

_TilePalette _paletteFor(SlotStatus s, bool isSelected) {
  switch (s) {
    case SlotStatus.free:
      return _TilePalette(
        tileBg: isSelected ? const Color(0xFFFEE2E2) : const Color(0xFFFFFBF5),
        border: isSelected ? const Color(0xFFD61F26) : const Color(0xFFE5D5C3),
        text: isSelected ? const Color(0xFFD61F26) : const Color(0xFF1A1A2E),
        iconBg: isSelected ? const Color(0xFFD61F26) : const Color(0xFFE0E4F7),
        iconBorder: isSelected
            ? const Color(0xFFD61F26)
            : const Color(0xFF5D6CC4).withOpacity(0.3),
        iconFg: isSelected ? Colors.white : const Color(0xFF5D6CC4),
        primary: const Color(0xFFD61F26),
      );
    case SlotStatus.reserved: // อนุมัติแล้ว (คนอื่น)
      return const _TilePalette(
        tileBg: Color(0xFFFEF3C7),
        border: Color(0xFFF59E0B),
        text: Color(0xFF92400E),
        iconBg: Color(0xFFFFE8A3),
        iconBorder: Color(0xFFF59E0B),
        iconFg: Color(0xFFF59E0B),
        primary: Color(0xFFF59E0B),
      );
    case SlotStatus.pendingOther:
      return const _TilePalette(
        tileBg: Color(0xFFE0F2FE), // พื้นหลังน้ำเงินอ่อน
        border: Color(0xFF0284C7), // เส้นขอบน้ำเงินกลาง
        text: Color(0xFF075985), // ตัวหนังสือน้ำเงินเข้ม
        iconBg: Color(0xFFBAE6FD), // พื้นหลังไอคอนน้ำเงินจาง
        iconBorder: Color(0xFF0284C7), // ขอบไอคอนน้ำเงิน
        iconFg: Color(0xFF0284C7), // ไอคอนน้ำเงิน
        primary: Color(0xFF0284C7), // สีหลักของสถานะ
      );

    case SlotStatus.pendingMe: // รออนุมัติ (เรา) = สีคนละโทน (ม่วง/คราม)
      return const _TilePalette(
        tileBg: Color(0xFFEDE9FE),
        border: Color(0xFF7C3AED),
        text: Color(0xFF5B21B6),
        iconBg: Color(0xFFDDD6FE),
        iconBorder: Color(0xFF7C3AED),
        iconFg: Color(0xFF7C3AED),
        primary: Color(0xFF7C3AED),
      );
  }
}

/// ป้ายสถานะด้านขวา
class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.status, required this.isSelected});
  final SlotStatus status;
  final bool isSelected;

  @override
  Widget build(BuildContext context) {
    late String text;
    late Color fg, bg, bd;

    switch (status) {
      case SlotStatus.free:
        text = isSelected ? 'Selected' : 'Free';
        fg = isSelected ? const Color(0xFFD61F26) : const Color(0xFF16A34A);
        bg = isSelected ? const Color(0xFFFEE2E2) : const Color(0xFFD1FAE5);
        bd = isSelected ? const Color(0xFFD61F26) : const Color(0xFF16A34A);
        break;
      case SlotStatus.reserved:
        text = 'Reserved';
        fg = const Color(0xFFF59E0B);
        bg = const Color(0xFFFEF3C7);
        bd = const Color(0xFFF59E0B);
        break;
      case SlotStatus.pendingOther:
        text = 'Pending';
        fg = const Color(0xFF0284C7);
        bg = const Color(0xFFE0F2FE);
        bd = const Color(0xFF0284C7);
        break;

      case SlotStatus.pendingMe:
        text = 'Pending (You)';
        fg = const Color(0xFF7C3AED);
        bg = const Color(0xFFEDE9FE);
        bd = const Color(0xFF7C3AED);
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: bd.withOpacity(0.4), width: 2),
        boxShadow: [
          BoxShadow(
            color: bd.withOpacity(0.18),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w800,
          color: fg,
          letterSpacing: 0.2,
        ),
      ),
    );
  }
}