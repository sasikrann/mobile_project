// staff_homepage.dart
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../services/auth_storage.dart';
import '../../services/api_client.dart';
import '../../services/upload_service.dart';
import 'package:http/http.dart' as http;
import 'dart:async';

class StaffHomePage extends StatefulWidget {
  const StaffHomePage({super.key});

  @override
  State<StaffHomePage> createState() => _StaffHomePageState();
}

class _StaffHomePageState extends State<StaffHomePage>
    with SingleTickerProviderStateMixin {
  List<dynamic> rooms = [];
  List<dynamic> filteredRooms = [];
  bool loading = true;
  String searchQuery = '';
  String filter = 'all'; // all, available, disabled

  late AnimationController _animController;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    fetchRooms();
    _startAutoRefresh(); // auto refresh every 1 minute for badges
  }

  void _startAutoRefresh() {
    Future.delayed(Duration.zero, () async {
      while (mounted) {
        await Future.delayed(const Duration(minutes: 1));
        await fetchRooms();
      }
    });
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  // ---------------- Fetch Rooms ---------------- //
  Future<void> fetchRooms() async {
    setState(() => loading = true);
    try {
      final res = await ApiClient.get('/api/rooms');
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        setState(() {
          rooms = data['rooms'] ?? [];
          _applyFilters();
          _animController.forward(from: 0);
        });
      } else {
        _showSnack('Failed to load rooms (${res.statusCode})');
      }
    } catch (e) {
      _showSnack('Error: $e');
    } finally {
      setState(() => loading = false);
    }
  }

  // ---------------- Search + Filter ---------------- //
  void _applyFilters() {
    List<dynamic> temp = rooms;

    if (searchQuery.isNotEmpty) {
      temp = temp
          .where(
            (r) =>
                (r['name'] ?? '').toString().toLowerCase().contains(
                  searchQuery.toLowerCase(),
                ) ||
                (r['description'] ?? '').toString().toLowerCase().contains(
                  searchQuery.toLowerCase(),
                ),
          )
          .toList();
    }

    if (filter == 'available') {
      temp = temp
          .where(
            (r) => (r['status'] ?? '').toString().toLowerCase() != 'disabled',
          )
          .toList();
    } else if (filter == 'disabled') {
      temp = temp
          .where(
            (r) => (r['status'] ?? '').toString().toLowerCase() == 'disabled',
          )
          .toList();
    }

    setState(() => filteredRooms = temp);
  }

  bool _isEditable(Map r) {
    final s = (r['status'] ?? '').toString().toLowerCase();
    return !(s == 'reserved' || s == 'pending');
  }

  // ---------------- Toggle ---------------- //
  Future<void> _toggleStatus(int id, bool enable) async {
    try {
      final headers = await AuthStorage.authHeaders();
      final res = await http.patch(
        Uri.parse('${Config.apiBase}/api/rooms/$id/status'),
        headers: headers,
        body: jsonEncode({'status': enable ? 'available' : 'disabled'}),
      );

      if (res.statusCode == 200) {
        // ✅ Update UI immediately
        setState(() {
          rooms = rooms.map((room) {
            if (room['id'] == id) {
              room['status'] = enable ? 'available' : 'disabled';
            }
            return room;
          }).toList();
          _applyFilters();
        });
        _showSnack('Room status updated');
      } else {
        final body = jsonDecode(res.body);
        _showSnack(body['message'] ?? 'Toggle failed');
      }
    } catch (e) {
      _showSnack('Error: $e');
    }
  }

  // ---------------- Add/Edit Dialog ---------------- //
  Future<void> _openDialog({Map? room}) async {
    final editable = room == null ? true : _isEditable(room);
    final nameCtrl = TextEditingController(text: room?['name'] ?? '');
    final descCtrl = TextEditingController(text: room?['description'] ?? '');
    final capCtrl = TextEditingController(
      text: room?['capacity']?.toString() ?? '',
    );
    File? imageFile;
    final picker = ImagePicker();

    await showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx2, setState2) {
            Widget imgPreview() {
              if (imageFile != null) {
                return Image.file(
                  imageFile!,
                  width: 220,
                  height: 140,
                  fit: BoxFit.cover,
                );
              } else if ((room?['image'] ?? '').toString().isNotEmpty) {
                return Image.network(
                  '${Config.apiBase}${room!['image']}',
                  width: 220,
                  height: 140,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) =>
                      const Icon(Icons.broken_image, size: 60),
                );
              } else {
                return Container(
                  width: 220,
                  height: 140,
                  color: Colors.grey[300],
                  child: const Icon(Icons.image, size: 60),
                );
              }
            }

            return AlertDialog(
              title: Text(room == null ? 'Add New Room' : 'Edit Room'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    imgPreview(),
                    const SizedBox(height: 8),
                    ElevatedButton.icon(
                      onPressed: editable
                          ? () async {
                              final picked = await picker.pickImage(
                                source: ImageSource.gallery,
                                imageQuality: 80,
                              );
                              if (picked != null) {
                                setState2(() => imageFile = File(picked.path));
                              }
                            }
                          : null,
                      icon: const Icon(Icons.photo),
                      label: const Text('Pick image'),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: nameCtrl,
                      decoration: const InputDecoration(labelText: 'Name'),
                    ),
                    TextField(
                      controller: descCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Description',
                      ),
                    ),
                    TextField(
                      controller: capCtrl,
                      decoration: const InputDecoration(labelText: 'Capacity'),
                      keyboardType: TextInputType.number,
                    ),
                    if (!editable)
                      Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: Text(
                          'Cannot edit — room is Pending or Reserved',
                          style: TextStyle(
                            color: Colors.red[700],
                            fontSize: 13,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    final name = nameCtrl.text.trim();
                    final cap = int.tryParse(capCtrl.text.trim()) ?? 4;
                    if (name.isEmpty) {
                      _showSnack('Name required');
                      return;
                    }

                    if (room == null) {
                      final res = await UploadService.createRoom(
                        name: name,
                        description: descCtrl.text.trim(),
                        capacity: cap,
                        imageFile: imageFile,
                      );
                      if (res['statusCode'] == 201) {
                        Navigator.pop(ctx);
                        await fetchRooms();
                        _showSnack('Room created');
                      } else {
                        _showSnack('Create failed: ${res['body']}');
                      }
                    } else {
                      if (!editable) {
                        _showSnack('Room is Reserved/Pending');
                        return;
                      }
                      final res = await UploadService.updateRoom(
                        roomId: room['id'],
                        name: name,
                        description: descCtrl.text.trim(),
                        capacity: cap,
                        imageFile: imageFile,
                      );
                      if (res['statusCode'] == 200) {
                        Navigator.pop(ctx);
                        await fetchRooms();
                        _showSnack('Room updated');
                      } else {
                        _showSnack('Update failed: ${res['body']}');
                      }
                    }
                  },
                  child: Text(room == null ? 'Create' : 'Save'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  // ---------------- Room Card ---------------- //
  Widget _roomCard(Map r, int index) {
    final img = r['image'];
    final rawStatus = (r['status'] ?? 'unknown').toString().toLowerCase();
    final editable = _isEditable(r);
    final isDisabled = rawStatus == 'disabled';
    DateTime now = DateTime.now();
    bool isAfterFive = now.hour >= 17; // After 5 PM
    // bool canToggle = editable && !isAfterFive;
    bool canToggle = editable;

    // Dynamic badge — auto reflect time slot + DB status
    String badgeLabel;
    Color badgeColor;

    if (rawStatus == 'reserved' || rawStatus == 'approved') {
      badgeLabel = 'RESERVED / PENDING';
      badgeColor = Colors.red;
    } else if (isDisabled) {
      badgeLabel = 'DISABLED';
      badgeColor = Colors.grey;
    } else {
      badgeLabel = 'FREE';
      badgeColor = Colors.green;
    }

    return FadeTransition(
      opacity: CurvedAnimation(
        parent: _animController,
        curve: Interval((index / filteredRooms.length).clamp(0.0, 1.0), 1.0),
      ),
      child: Card(
        color: const Color(0xFFFEF3E2),
        elevation: 3,
        margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Stack(
          children: [
            // Image
            ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(12),
              ),
              child: (img != null && img.toString().isNotEmpty)
                  ? Image.network(
                      '${Config.apiBase}${img}',
                      height: 150,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    )
                  : Container(
                      height: 150,
                      color: Colors.grey[200],
                      alignment: Alignment.center,
                      child: const Icon(
                        Icons.image,
                        size: 56,
                        color: Colors.grey,
                      ),
                    ),
            ),
            // Badge
            Positioned(
              top: 10,
              right: 10,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: badgeColor,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  badgeLabel,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
            ),
            // Info
            Padding(
              padding: const EdgeInsets.only(
                top: 155.0,
                left: 12,
                right: 12,
                bottom: 10,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    r['name'] ?? '-',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    r['description'] ?? '-',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Seat: ${r['capacity'] ?? '-'}',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      Row(
                        children: [
                          // Apply dimming to switch when locked
                          Opacity(
                            opacity: canToggle ? 1.0 : 0.5,
                            child: Switch(
                              value: !isDisabled,
                              activeColor: Colors.green,
                              onChanged: canToggle
                                  ? (v) => _toggleStatus(r['id'], v)
                                  : (v) {
                                      // Optional: show snack bar if staff tries after 5 PM
                                      if (isAfterFive) {
                                        ScaffoldMessenger.of(
                                          context,
                                        ).showSnackBar(
                                          const SnackBar(
                                            content: Text(
                                              'Room control is locked after 17:00. Please manage tomorrow.',
                                              style: TextStyle(
                                                color: Colors.white,
                                              ),
                                            ),
                                            backgroundColor: Colors.redAccent,
                                          ),
                                        );
                                      }
                                    },
                            ),
                          ),
                          IconButton(
                            icon: const Icon(
                              Icons.edit,
                              color: Color(0xFFDD0303),
                              shadows: [
                                Shadow(
                                  color: Colors
                                      .black38, // Shadow color and opacity
                                  offset: const Offset(
                                    3,
                                    3,
                                  ), // Shadow offset (x, y)
                                  blurRadius: 5.0, // Shadow blur radius
                                ),
                              ],
                            ),
                            onPressed: () => _openDialog(room: r),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ---------------- Snack Helper ---------------- //
  void _showSnack(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  // ---------------- Build ---------------- //
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFEF3E2),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(12, 30, 12, 6),
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: 'Search rooms...',
                      prefixIcon: const Icon(Icons.search),
                      filled: true,
                      fillColor: const Color.fromARGB(255, 255, 255, 255),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    onChanged: (v) {
                      setState(() => searchQuery = v);
                      _applyFilters();
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _filterRadio('all', 'All'),
                      _filterRadio('available', 'Available'),
                      _filterRadio('disabled', 'Disabled'),
                    ],
                  ),
                ),
                FloatingActionButton(
                  onPressed: _openDialog,
                  backgroundColor: const Color(0xFFDD0303),
                  child: const Icon(Icons.add, color: Colors.white),
                ),

                Expanded(
                  child: RefreshIndicator(
                    onRefresh: fetchRooms,
                    child: filteredRooms.isEmpty
                        ? const Center(child: Text('No rooms found'))
                        : ListView.builder(
                            padding: const EdgeInsets.only(bottom: 80),
                            itemCount: filteredRooms.length,
                            itemBuilder: (context, i) =>
                                _roomCard(filteredRooms[i], i),
                          ),
                  ),
                ),
              ],
            ),
    );
  }

  Widget _filterRadio(String value, String label) {
    return Row(
      children: [
        Radio<String>(
          activeColor: const Color(0xFFDD0303),
          value: value,
          groupValue: filter,
          onChanged: (v) {
            setState(() => filter = v!);
            _applyFilters();
          },
        ),
        Text(label),
      ],
    );
  }
}
