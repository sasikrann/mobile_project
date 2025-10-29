import 'package:flutter/material.dart';
import 'student_shell.dart'; 

class BookRoomPage extends StatefulWidget {
  const BookRoomPage({super.key});

  @override
  State<BookRoomPage> createState() => _BookRoomPageState();
}

class _BookRoomPageState extends State<BookRoomPage> {
  String? selectedTime;
  final TextEditingController purposeController = TextEditingController();

  final List<Map<String, String>> timeSlots = [
    {'start': '08:00', 'end': '10:00'},
    {'start': '10:00', 'end': '12:00'},
    {'start': '13:00', 'end': '15:00'},
    {'start': '15:00', 'end': '17:00'},
  ];

  @override
  Widget build(BuildContext context) {
    final today = DateTime.now();
    final formattedDate =
        "${today.day.toString().padLeft(2, '0')}/${today.month.toString().padLeft(2, '0')}/${today.year}";

    return Scaffold(
      backgroundColor: const Color(0xFFFEF3E2), // ✅ พื้นหลังครีม
      appBar: AppBar(
        backgroundColor: const Color(0xFFFEF3E2), // ✅ bar ครีม
        centerTitle: true, // ✅ ชื่ออยู่ตรงกลาง
        elevation: 0,
        title: const Text(
          'Book a Room',
          style: TextStyle(
            color: Color(0xFFD61F26), // ✅ สีแดง
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black), // ✅ สีดำ
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const StudentShell()),
            );
          },
        ),
      ),
      body: Center(
        child: Container(
          width: 320,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Room 1",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 12),
              const Text("Date", style: TextStyle(fontWeight: FontWeight.w500)),
              const SizedBox(height: 6),
              TextField(
                readOnly: true,
                decoration: InputDecoration(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  filled: true,
                  fillColor: const Color(0xFFF4F4F4),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide.none,
                  ),
                  suffixIcon: const Icon(Icons.calendar_today, size: 20),
                  hintText: formattedDate,
                ),
              ),
              const SizedBox(height: 16),
              const Text("Time", style: TextStyle(fontWeight: FontWeight.w500)),
              Column(
                children: timeSlots.map((slot) {
                  String label = "${slot['start']} - ${slot['end']}";
                  return RadioListTile<String>(
                    title: Text(label),
                    value: label,
                    groupValue: selectedTime,
                    activeColor: const Color(0xFFD61F26),
                    onChanged: (value) {
                      setState(() => selectedTime = value);
                    },
                  );
                }).toList(),
              ),
              const SizedBox(height: 12),
              const Text("Purpose of booking", style: TextStyle(fontWeight: FontWeight.w500)),
              const SizedBox(height: 6),
              TextField(
                controller: purposeController,
                decoration: InputDecoration(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  filled: true,
                  fillColor: const Color(0xFFF4F4F4),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFD61F26),
                      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    onPressed: selectedTime == null
                        ? null
                        : () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => ConfirmBookingPage(
                                  date: formattedDate,
                                  time: selectedTime!,
                                  purpose: purposeController.text.isEmpty
                                      ? '-'
                                      : purposeController.text,
                                ),
                              ),
                            );
                          },
                    child: const Text("Confirm",
                        style: TextStyle(color: Colors.white, fontSize: 16)),
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFD9D9D9),
                      padding: const EdgeInsets.symmetric(horizontal: 35, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    onPressed: () {
                      // ✅ กลับไปหน้า homepage
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (_) => const StudentShell()),
                      );
                    },
                    child: const Text(
                      "Cancel",
                      style: TextStyle(color: Colors.black, fontSize: 16),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

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
      backgroundColor: const Color(0xFFFEF3E2), // ✅ พื้นหลังครีม
      appBar: AppBar(
        backgroundColor: const Color(0xFFFEF3E2),
        centerTitle: true,
        elevation: 0,
        title: const Text(
          'Book a Room',
          style: TextStyle(
            color: Color(0xFFD61F26), // ✅ สีแดง
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Center(
        child: Container(
          width: 320,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.check_circle, color: Color(0xFF3BAF5D), size: 80),
              const SizedBox(height: 12),
              const Text(
                "Confirm Booking",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              buildInfoRow("Date", date),
              buildInfoRow("Time", time),
              buildInfoRow("Purpose of booking", purpose),
              const SizedBox(height: 30),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFD61F26),
                  padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25),
                  ),
                ),
                onPressed: () {
                  // ✅ กลับไปหน้า homepage เมื่อจองเสร็จ
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (_) => const StudentShell(initialIndex: 1)),
                  );
                },
                child: const Text(
                  "Go to My Booking",
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text("$label: ",
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
          Text(value, style: const TextStyle(fontSize: 16)),
        ],
      ),
    );
  }
}
