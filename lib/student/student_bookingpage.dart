import 'package:flutter/material.dart';
import 'dart:convert';

import '../services/api_client.dart';
import 'student_shell.dart';

/// ===============================
/// BookRoomPage (date is String)
/// ===============================
class MyBookingsPage extends StatefulWidget {
  const MyBookingsPage({
    super.key,
    required this.roomId,
    required this.roomName,
  });

  final int roomId;
  final String roomName;

  @override
  State<MyBookingsPage> createState() => _MyBookingsPageState();
}

class _MyBookingsPageState extends State<MyBookingsPage>
    with TickerProviderStateMixin {
  String? selectedTime; // label "HH:MM - HH:MM"
  late final String fixedDate; //
  final TextEditingController purposeController = TextEditingController();
  late AnimationController _animController;

  bool _loading = true;
  String? _loadError;

  // สถานะจาก backend จะแปลงมาเป็น list นี้เพื่อคุม UI
  List<_Slot> _slots = <_Slot>[];

  @override
  void initState() {
    super.initState();
    fixedDate = _formatToday();
    _animController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    )..forward();

    _fetchRoomStatus();
  }

  String _formatToday() {
    final now = DateTime.now(); // เวลา local
    final dd = now.day.toString().padLeft(2, '0');
    final mm = now.month.toString().padLeft(2, '0');
    final yyyy = now.year.toString();
    return '$dd/$mm/$yyyy';
  }

  @override
  void dispose() {
    _animController.dispose();
    purposeController.dispose();
    super.dispose();
  }

  /// ===== API: GET /api/rooms/:id/status =====
  Future<void> _fetchRoomStatus() async {
    setState(() {
      _loading = true;
      _loadError = null;
    });

    try {
      final res = await ApiClient.get('/api/rooms/${widget.roomId}/status');

      if (res.statusCode == 200) {
        final data = json.decode(res.body);
        final List<dynamic> slotsJson = (data['slots'] ?? []) as List<dynamic>;

        // backend ส่ง time_slot เป็น: 8-10 / 10-12 / 13-15 / 15-17
        // status เป็น: Free / Reserved / Waiting / MyPending
        final mapped = slotsJson.map<_Slot>((s) {
          final ts = (s['time_slot'] ?? '').toString();
          final st = (s['status'] ?? '').toString();
          return _Slot(
            start: _slotToLabel(ts).split(' - ')[0],
            end: _slotToLabel(ts).split(' - ')[1],
            status: _mapBackendStatus(st),
          );
        }).toList();

        // ให้แน่ใจว่ามีครบ 4 ช่องเสมอ (ถ้า backend ส่งไม่ครบ)
        final labels = const [
          '08:00 - 10:00',
          '10:00 - 12:00',
          '13:00 - 15:00',
          '15:00 - 17:00'
        ];
        final Map<String, _Slot> byLabel = {
          for (final s in mapped) s.label: s
        };
        final complete = labels.map((label) {
          return byLabel[label] ??
              _slotFromLabel(label, SlotStatus.free); // ช่องที่ไม่มา = Free
        }).toList();

        final adjusted = complete.map((s) {
          if (s.status == SlotStatus.free && _isSlotPastEnd(s.end)) {
            return s.copyWith(status: SlotStatus.closed);
          }
          return s;
        }).toList();

        setState(() {
          _slots = adjusted;  // ⬅️ ใช้ adjusted แทน
          _loading = false;
        });
      } else {
        setState(() {
          _loading = false;
          _loadError = 'Failed to load status (${res.statusCode})';
        });
      }
    } catch (e) {
      setState(() {
        _loading = false;
        _loadError = 'Cannot connect to server';
      });
    }
  }

  /// ===== API: POST /api/bookings =====
  Future<bool> _createBooking() async {
    if (selectedTime == null) return false;

    final slotCode = _labelToSlot(selectedTime!); // "8-10" | "10-12" ...
    final body = {
      'room_id': widget.roomId,
      'time_slot': slotCode,
      'reason': purposeController.text.isEmpty ? null : purposeController.text,
    };

    try {
      final res = await ApiClient.post('/api/bookings', body: body);

      if (res.statusCode == 201) {
        return true;
      } else {
        final msg = _safeMsg(res.body) ?? 'Booking failed (${res.statusCode})';
        _toast(msg);
        return false;
      }
    } catch (e) {
      _toast('Cannot connect to server');
      return false;
    }
  }

  String? _safeMsg(String raw) {
    try {
      final m = json.decode(raw);
      return m['message']?.toString();
    } catch (_) {
      return null;
    }
  }

  // helper: ค้นหาจาก label
  int _indexOfLabel(String label) =>
      _slots.indexWhere((s) => s.label == label);

  // ====== Mapping helpers ======
  // UI label  -> backend code
  String _labelToSlot(String label) {
    switch (label) {
      case '08:00 - 10:00':
        return '8-10';
      case '10:00 - 12:00':
        return '10-12';
      case '13:00 - 15:00':
        return '13-15';
      case '15:00 - 17:00':
        return '15-17';
      default:
        return '8-10';
    }
  }

  // backend code -> UI label
  String _slotToLabel(String code) {
    switch (code) {
      case '8-10':
        return '08:00 - 10:00';
      case '10-12':
        return '10:00 - 12:00';
      case '13-15':
        return '13:00 - 15:00';
      case '15-17':
        return '15:00 - 17:00';
      default:
        return '08:00 - 10:00';
    }
  }

  // backend status -> UI SlotStatus
  SlotStatus _mapBackendStatus(String s) {
    switch (s) {
      case 'Reserved':
        return SlotStatus.reserved;
      case 'On Hold':
        return SlotStatus.pendingOther;
      case 'Pending':
        return SlotStatus.pendingMe;
      case 'Free':
      default:
        return SlotStatus.free;
    }
  }

  _Slot _slotFromLabel(String label, SlotStatus status) {
    final parts = label.split(' - ');
    return _Slot(start: parts[0], end: parts[1], status: status);
  }

  void _toast(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: Colors.grey.shade800,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  bool _isSlotPastEnd(String endHHmm) {
    // endHHmm รูปแบบ "HH:MM"
    final now = DateTime.now(); // local
    // final now = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day, 10, 00);
    final endParts = endHHmm.split(':');
    if (endParts.length != 2) return false;
    final endH = int.tryParse(endParts[0]) ?? 0;
    final endM = int.tryParse(endParts[1]) ?? 0;

    final endToday = DateTime(now.year, now.month, now.day, endH, endM);
    // บล็อกเมื่อเวลาปัจจุบัน ">= เวลาสิ้นสุด"
    return !now.isBefore(endToday);
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
                        Colors.white.withValues(alpha:0.9),
                        Colors.white.withValues(alpha:0.7),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                      color: Colors.white.withValues(alpha:0.5),
                      width: 2,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFFD61F26).withValues(alpha:0.15),
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
                            color: const Color(0xFFD61F26).withValues(alpha:0.2),
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
                      Expanded(
                        child: Text(
                          'Book a Room • ${widget.roomName}',
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: Color(0xFFD61F26),
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                            letterSpacing: -0.5,
                          ),
                        ),
                      ),
                      // refresh button
                      IconButton(
                        icon: const Icon(Icons.refresh_rounded),
                        color: const Color(0xFFD61F26),
                        onPressed: _fetchRoomStatus,
                        tooltip: 'Refresh slots',
                      ),
                    ],
                  ),
                ),
              ),

              // ===== Main =====
              Expanded(
                child: _loading
                    ? const Center(child: CircularProgressIndicator())
                    : _loadError != null
                        ? Center(
                            child: Text(
                              _loadError!,
                              style: const TextStyle(
                                  color: Colors.red, fontWeight: FontWeight.w600),
                            ),
                          )
                        : SingleChildScrollView(
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
                                    color: const Color(0xFFD61F26).withValues(alpha:0.2),
                                    width: 2,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: const Color(0xFFD61F26).withValues(alpha:0.15),
                                      blurRadius: 28,
                                      offset: const Offset(0, 10),
                                      spreadRadius: -4,
                                    ),
                                    BoxShadow(
                                      color: Colors.black.withValues(alpha:0.05),
                                      blurRadius: 16,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // Title
                                    Row(
                                      children: [
                                        const Icon(
                                          Icons.meeting_room_rounded,
                                          color: Color(0xFFD61F26),
                                          size: 32,
                                        ),
                                        const SizedBox(width: 10),
                                        Text(
                                          widget.roomName,
                                          style: const TextStyle(
                                            fontSize: 26,
                                            fontWeight: FontWeight.w800,
                                            color: Color(0xFF1A1A2E),
                                            letterSpacing: -0.5,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 28),

                                    // Date (String, not selectable) — คง UI เดิม
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
                                          const _CalIcon(),
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
                                              ? () => setState(() => selectedTime = slot.label)
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
                                                        color: palette.primary.withValues(alpha:0.2),
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
                                                    borderRadius: BorderRadius.circular(12),
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
                                    }),

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
                                          color: const Color(0xFF8B6F47).withValues(alpha:0.5),
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
                                              shadowColor: const Color(0xFFD61F26).withValues(alpha:0.3),
                                            ),
                                            onPressed: selectedTime == null
                                                ? null
                                                : () async {
                                                  final i = _indexOfLabel(selectedTime!);
                                                  if (i == -1) return;
                                                  final chosen = _slots[i];

                                                  if (chosen.status != SlotStatus.free || _isSlotPastEnd(chosen.end)) {
                                                    _toast('This time slot is already closed.');
                                                    // sync UI เผื่อกรณีเวลาล่วงเลยระหว่างหน้าเปิดอยู่
                                                    if (chosen.status == SlotStatus.free && _isSlotPastEnd(chosen.end)) {
                                                      setState(() {
                                                        _slots[i] = _slots[i].copyWith(status: SlotStatus.closed);
                                                      });
                                                    }
                                                    return;
                                                  }
                                                  // ยิงจองจริง
                                                  final ok = await _createBooking();
                                                  if (!ok) return;

                                                  setState(() {
                                                    _slots[i] = _slots[i].copyWith(status: SlotStatus.pendingMe);
                                                  });

                                                  if (!mounted) return;
                                                  Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                      builder: (_) => ConfirmBookingPage(
                                                        date: fixedDate,
                                                        time: selectedTime!,
                                                        purpose: purposeController.text.isEmpty ? '-' : purposeController.text,
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
                      Colors.white.withValues(alpha:0.9),
                      Colors.white.withValues(alpha:0.7),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: Colors.white.withValues(alpha:0.5),
                    width: 2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF10B981).withValues(alpha:0.15),
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
                          color: const Color(0xFF10B981).withValues(alpha:0.2),
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
                          color: const Color(0xFF10B981).withValues(alpha:0.2),
                          width: 2,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF10B981).withValues(alpha:0.15),
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
                                  color: const Color(0xFF10B981).withValues(alpha:0.3),
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
                              color: const Color(0xFF64748B).withValues(alpha:0.7),
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
                                padding: const EdgeInsets.symmetric(vertical: 18),
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(18),
                                ),
                                shadowColor:
                                    const Color(0xFF10B981).withValues(alpha:0.3),
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
              border: Border.all(color: iconColor.withValues(alpha:0.3), width: 1.5),
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
            color: const Color(0xFFFF8A00).withValues(alpha:0.3),
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

enum SlotStatus { free, reserved, pendingOther, pendingMe, closed }

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
        iconBorder:
            isSelected ? const Color(0xFFD61F26) : const Color(0xFF5D6CC4).withValues(alpha:0.3),
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
        tileBg: Color(0xFFE0F2FE), // น้ำเงินอ่อน
        border: Color(0xFF0284C7),
        text: Color(0xFF075985),
        iconBg: Color(0xFFBAE6FD),
        iconBorder: Color(0xFF0284C7),
        iconFg: Color(0xFF0284C7),
        primary: Color(0xFF0284C7),
      );
    case SlotStatus.pendingMe: // เราจองรออนุมัติ
      return const _TilePalette(
        tileBg: Color(0xFFEDE9FE),
        border: Color(0xFF7C3AED),
        text: Color(0xFF5B21B6),
        iconBg: Color(0xFFDDD6FE),
        iconBorder: Color(0xFF7C3AED),
        iconFg: Color(0xFF7C3AED),
        primary: Color(0xFF7C3AED),
      );
    case SlotStatus.closed:     // ⬅️ ใหม่: เทาๆ
      return const _TilePalette(
        tileBg: Color(0xFFF3F4F6),
        border: Color(0xFFD1D5DB),
        text: Color(0xFF6B7280),
        iconBg: Color(0xFFE5E7EB),
        iconBorder: Color(0xFFD1D5DB),
        iconFg: Color(0xFF9CA3AF),
        primary: Color(0xFF9CA3AF),
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
        text = 'On Hold';
        fg = const Color(0xFF0284C7);
        bg = const Color(0xFFE0F2FE);
        bd = const Color(0xFF0284C7);
        break;
      case SlotStatus.pendingMe:
        text = 'Pending';
        fg = const Color(0xFF7C3AED);
        bg = const Color(0xFFEDE9FE);
        bd = const Color(0xFF7C3AED);
        break;
      case SlotStatus.closed: // ⬅️ ใหม่
        text = 'Closed';
        fg = const Color(0xFF6B7280);
        bg = const Color(0xFFF3F4F6);
        bd = const Color(0xFFD1D5DB);
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: bd.withValues(alpha:0.4), width: 2),
        boxShadow: [
          BoxShadow(
            color: bd.withValues(alpha:0.18),
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