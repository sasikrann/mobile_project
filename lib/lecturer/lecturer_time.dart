import 'dart:convert';
import 'package:flutter/material.dart';
import '../services/api_client.dart';
import 'package:flutter_application_1/lecturer/lecturer_shell.dart';

class Timeslot extends StatefulWidget {
  const Timeslot({super.key, required this.roomId, required this.roomName});

  final int roomId;
  final String roomName;

  @override
  State<Timeslot> createState() => _TimeslotState();
}

class _TimeslotState extends State<Timeslot> with TickerProviderStateMixin {
  late AnimationController _animController;
  bool _loading = true;
  String? _error;
  late final String fixedDate;
  List<_Slot> _slots = [];

  // 🔧 ตรงนี้คือจุดกำหนด "เวลาอ้างอิง"
  // --- ตอนทดสอบให้ใช้ mock 13:00 ---
  DateTime _now() {
    // return DateTime(
    //   DateTime.now().year,
    //   DateTime.now().month,
    //   DateTime.now().day,
    //   13,
    //   00,
    // );
    // ถ้าจะใช้เวลาจริงค่อยเปลี่ยนเป็น:
    return DateTime.now();
  }

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
    final now = _now(); // ✅ ใช้เวลาเดียวกับตอนเช็ก slot
    final dd = now.day.toString().padLeft(2, '0');
    final mm = now.month.toString().padLeft(2, '0');
    final yyyy = now.year.toString();
    return '$dd/$mm/$yyyy';
  }

  Future<void> _fetchRoomStatus() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final res = await ApiClient.get('/api/rooms/${widget.roomId}/status');
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        final slots = (data['slots'] ?? []) as List;

        // Map slot จาก backend -> UI
        final list = slots.map((e) {
          final code = e['time_slot'].toString();
          final status = e['status'].toString();
          return _Slot(
            label: _slotToLabel(code),
            status: _mapBackendStatus(status),
          );
        }).toList();

        // ให้ครบ 4 ช่วงเวลา
        final labels = const [
          '08:00 - 10:00',
          '10:00 - 12:00',
          '13:00 - 15:00',
          '15:00 - 17:00',
        ];
        final byLabel = {for (final s in list) s.label: s};
        final merged = labels
            .map((l) => byLabel[l] ?? _Slot(label: l, status: SlotStatus.free))
            .toList();

        // ปรับให้ช่วงเวลาที่ผ่านมาแล้วเป็น Closed
        final now = _now(); // ✅ ใช้เวลา mock เหมือนกัน
        final updated = merged.map((s) {
          if (s.status == SlotStatus.free && _isSlotPastEnd(s.label, now)) {
            return s.copyWith(status: SlotStatus.closed);
          }
          return s;
        }).toList();

        setState(() {
          _slots = updated;
          _loading = false;
        });
      } else {
        setState(() {
          _loading = false;
          _error = 'Failed to load (${res.statusCode})';
        });
      }
    } catch (e) {
      setState(() {
        _loading = false;
        _error = 'Cannot connect to server';
      });
    }
  }

  bool _isSlotPastEnd(String label, DateTime now) {
    final parts = label.split(' - ');
    if (parts.length != 2) return false;
    final end = parts[1].split(':');
    final endH = int.tryParse(end[0]) ?? 0;
    final endM = int.tryParse(end[1]) ?? 0;
    final endTime = DateTime(now.year, now.month, now.day, endH, endM);
    return now.isAfter(endTime);
  }

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
        return code;
    }
  }

  SlotStatus _mapBackendStatus(String s) {
    switch (s.toLowerCase()) {
      case 'reserved':
        return SlotStatus.reserved;
      case 'pending':
      case 'on hold':
        return SlotStatus.pending;
      case 'disabled':
      case 'closed':
        return SlotStatus.closed;
      case 'free':
      default:
        return SlotStatus.free;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFFFFBF5), Color(0xFFFEF3E2), Color(0xFFFCE8CD)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
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
                  color: Colors.white.withOpacity(0.8),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: Colors.white70, width: 2),
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
                    // Back
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
                              builder: (_) => const LecturerShell(),
                            ),
                          );
                        },
                      ),
                    ),
                    Expanded(
                      child: Text(
                        'Room • ${widget.roomName}',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Color(0xFFD61F26),
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.5,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.refresh_rounded),
                      color: const Color(0xFFD61F26),
                      onPressed: _fetchRoomStatus,
                    ),
                  ],
                ),
              ),

              // Body
              Expanded(
                child: _loading
                    ? const Center(child: CircularProgressIndicator())
                    : _error != null
                        ? Center(
                            child: Text(
                              _error!,
                              style: const TextStyle(
                                color: Colors.red,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          )
                        : SingleChildScrollView(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 20),
                            child: Container(
                              padding: const EdgeInsets.all(28),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(28),
                                border: Border.all(
                                  color: const Color(0xFFD61F26)
                                      .withOpacity(0.2),
                                  width: 2,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(0xFFD61F26)
                                        .withOpacity(0.15),
                                    blurRadius: 28,
                                    offset: const Offset(0, 10),
                                    spreadRadius: -4,
                                  ),
                                ],
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Room Name
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
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 28),

                                  // Date
                                  const Text(
                                    "Date",
                                    style: TextStyle(
                                      fontWeight: FontWeight.w700,
                                      fontSize: 15,
                                      color: Color(0xFF1A1A2E),
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

                                  const Text(
                                    "Available Time Slots",
                                    style: TextStyle(
                                      fontWeight: FontWeight.w700,
                                      fontSize: 15,
                                      color: Color(0xFF1A1A2E),
                                    ),
                                  ),
                                  const SizedBox(height: 10),

                                  ..._slots.map(
                                    (s) => Padding(
                                      padding:
                                          const EdgeInsets.only(bottom: 12),
                                      child: Container(
                                        padding: const EdgeInsets.all(16),
                                        decoration: BoxDecoration(
                                          color: _statusBg(s.status),
                                          borderRadius:
                                              BorderRadius.circular(16),
                                          border: Border.all(
                                            color: _statusColor(s.status),
                                            width: 2,
                                          ),
                                        ),
                                        child: Row(
                                          children: [
                                            Icon(
                                              Icons.access_time_rounded,
                                              size: 20,
                                              color: _statusColor(s.status),
                                            ),
                                            const SizedBox(width: 14),
                                            Expanded(
                                              child: Text(
                                                s.label,
                                                style: const TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.w700,
                                                  color: Color(0xFF1A1A2E),
                                                ),
                                              ),
                                            ),
                                            _badge(s.status),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
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

  Color _statusColor(SlotStatus s) {
    switch (s) {
      case SlotStatus.free:
        return const Color(0xFF16A34A);
      case SlotStatus.pending:
        return const Color(0xFF7C3AED);
      case SlotStatus.reserved:
        return const Color(0xFFF59E0B);
      case SlotStatus.closed:
        return const Color(0xFF9CA3AF);
    }
  }

  Color _statusBg(SlotStatus s) {
    switch (s) {
      case SlotStatus.free:
        return const Color(0xFFD1FAE5);
      case SlotStatus.pending:
        return const Color(0xFFEDE9FE);
      case SlotStatus.reserved:
        return const Color(0xFFFEF3C7);
      case SlotStatus.closed:
        return const Color(0xFFF3F4F6);
    }
  }

  Widget _badge(SlotStatus s) {
    String text;
    Color color;
    switch (s) {
      case SlotStatus.free:
        text = "Free";
        color = const Color(0xFF16A34A);
        break;
      case SlotStatus.pending:
        text = "Pending";
        color = const Color(0xFF7C3AED);
        break;
      case SlotStatus.reserved:
        text = "Reserved";
        color = const Color(0xFFF59E0B);
        break;
      case SlotStatus.closed:
        text = "Closed";
        color = const Color(0xFF9CA3AF);
        break;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withOpacity(0.4), width: 2),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w800,
          color: color,
        ),
      ),
    );
  }
}

enum SlotStatus { free, pending, reserved, closed }

class _Slot {
  final String label;
  final SlotStatus status;
  const _Slot({required this.label, required this.status});

  _Slot copyWith({String? label, SlotStatus? status}) =>
      _Slot(label: label ?? this.label, status: status ?? this.status);
}

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
      ),
      child: const Icon(
        Icons.calendar_today_rounded,
        size: 20,
        color: Colors.white,
      ),
    );
  }
}