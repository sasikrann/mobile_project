import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

enum _FilterMode { all, open, closed }

class Room {
  int id;
  String name;
  String description;
  bool isReserved; // students/others reserved -> true
  bool isOpen; // staff open/close control
  File? imageFile;

  Room({
    required this.id,
    required this.name,
    required this.description,
    required this.isReserved,
    required this.isOpen,
    this.imageFile,
  });

  Room copyWith({
    int? id,
    String? name,
    String? description,
    bool? isReserved,
    bool? isOpen,
    File? imageFile,
  }) {
    return Room(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      isReserved: isReserved ?? this.isReserved,
      isOpen: isOpen ?? this.isOpen,
      imageFile: imageFile ?? this.imageFile,
    );
  }
}

class StaffHomePage extends StatefulWidget {
  const StaffHomePage({super.key});

  @override
  State<StaffHomePage> createState() => _StaffHomePage();
}

class _StaffHomePage extends State<StaffHomePage> {
  final ImagePicker _picker = ImagePicker();

  final List<Room> _rooms = [
    Room(id: 1, name: 'Room 1', description: '8', isReserved: false, isOpen: true),
    Room(id: 2, name: 'Room 2', description: '12', isReserved: true, isOpen: true),
    Room(id: 3, name: 'Room 3', description: '8', isReserved: false, isOpen: false),
    Room(id: 4, name: 'Room 4', description: '6', isReserved: true, isOpen: true),
    Room(id: 5, name: 'Room 5', description: '12', isReserved: false, isOpen: true),
    Room(id: 6, name: 'Room 6', description: '10', isReserved: false, isOpen: false),
  ];

  int _nextId = 100;
  String _searchQuery = '';
  _FilterMode _filterMode = _FilterMode.all;

  List<Room> get _filteredRooms {
    final q = _searchQuery.trim().toLowerCase();
    return _rooms.where((r) {
      // filter by search
      if (q.isNotEmpty && !r.name.toLowerCase().contains(q)) return false;

      // filter by open/closed radio
      if (_filterMode == _FilterMode.open && !r.isOpen) return false;
      if (_filterMode == _FilterMode.closed && r.isOpen) return false;

      return true;
    }).toList();
  }

  // --- Add/Edit dialog ---
  Future<void> _showAddEditDialog({Room? existing}) async {
    final isEdit = existing != null;
    final nameCtrl = TextEditingController(text: existing?.name ?? '');
    final descCtrl = TextEditingController(text: existing?.description ?? '');
    File? pickedImage = existing?.imageFile;

    await showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(builder: (ctx, setDialogState) {
        Future<void> pickImage() async {
          try {
            final xfile = await _picker.pickImage(source: ImageSource.gallery);
            if (xfile != null) {
              setDialogState(() => pickedImage = File(xfile.path));
            }
          } catch (e) {
            debugPrint('Image pick error: $e');
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Error picking image')));
          }
        }

        return AlertDialog(
          title: Text(isEdit ? 'Edit Room' : 'Add Room'),
          content: SingleChildScrollView(
            child: Column(
              children: [
                GestureDetector(
                  onTap: pickImage,
                  child: Container(
                    width: double.infinity,
                    height: 150,
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    child: pickedImage != null
                        ? ClipRRect(borderRadius: BorderRadius.circular(12), child: Image.file(pickedImage!, fit: BoxFit.cover))
                        : const Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.image, size: 36, color: Colors.grey),
                                SizedBox(height: 8),
                                Text('Tap to pick image'),
                              ],
                            ),
                          ),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: nameCtrl,
                  decoration: const InputDecoration(labelText: 'Room name', border: OutlineInputBorder()),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: descCtrl,
                  decoration: const InputDecoration(labelText: 'Description', border: OutlineInputBorder()),
                  maxLines: 3,
                ),
                const SizedBox(height: 8),
                
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
            ElevatedButton(
              onPressed: () {
                final name = nameCtrl.text.trim();
                final desc = descCtrl.text.trim();
                if (name.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Room name is required')));
                  return;
                }

                setState(() {
                  if (isEdit) {
                    final idx = _rooms.indexWhere((r) => r.id == existing.id);
                    if (idx != -1) {
                      // Only name/description/image editable here; not open/reserved
                      _rooms[idx] = _rooms[idx].copyWith(name: name, description: desc, imageFile: pickedImage);
                    }
                  } else {
                    _rooms.add(Room(id: _nextId++, name: name, description: desc, isReserved: false, isOpen: true, imageFile: pickedImage));
                  }
                });

                Navigator.pop(ctx);
              },
              child: Text(isEdit ? 'Save' : 'Add'),
            ),
          ],
        );
      }),
    );
  }

  void _toggleOpen(Room room) {
   
    setState(() {
      final idx = _rooms.indexWhere((r) => r.id == room.id);
      if (idx != -1) _rooms[idx] = _rooms[idx].copyWith(isOpen: !room.isOpen);
    });
  }

  @override
  Widget build(BuildContext context) {
    final rooms = _filteredRooms;

    return Scaffold(
      backgroundColor: const Color(0xFFFEF3E2),
     

      // Add bottom padding so FAB sits above custom nav bar if embedded
      body: SafeArea(
        
        child: Padding(
          padding: EdgeInsets.only(bottom: MediaQuery.of(context).padding.bottom + 88),
          child: Column(
            children: [
              // Search + filters
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Column(
                  children: [
  
                    TextField(
                        decoration: InputDecoration(
                          hintText: 'Search room by name',
                          prefixIcon: const Icon(Icons.search),
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
                        ),
                        onChanged: (v) => setState(() => _searchQuery = v),
                      ),
              
                    const SizedBox(height: 12),
                    // Radio filters group
 
                       Row(mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _buildFilterRadio('All', _FilterMode.all),
                          _buildFilterRadio('Open', _FilterMode.open),
                          _buildFilterRadio('Closed', _FilterMode.closed),
                        ],
                      ),
      
                  ],
                ),
              ),

              // List of rooms (single column)
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: rooms.isEmpty
                      ? const Center(child: Text('No rooms found'))
                      : ListView.builder(         
                          padding: const EdgeInsets.only(top: 16, bottom: 12),
                          itemCount: rooms.length,
                          itemBuilder: (context, idx) {
                            final r = rooms[idx];
                            return _RoomCard(
                              room: r,
                              onEdit: r.isReserved ? null : () => _showAddEditDialog(existing: r),
                              onToggleOpen: () => _toggleOpen(r),
                            );
                          },
                        ),
                ),
              ),

              FloatingActionButton(onPressed: () => _showAddEditDialog(),
              backgroundColor: const Color(0xFFDD0303),
              
              child: const Icon(Icons.add, color: Colors.white,),
              )
            ],
          ),
        ),
      ),

    );
  }

  Widget _buildFilterRadio(String label, _FilterMode mode) {
    return Row(
      children: [
        Radio<_FilterMode>(
          value: mode,
          groupValue: _filterMode,
          onChanged: (v) => setState(() => _filterMode = v!),
          activeColor: const Color(0xFFDD0303),
        ),
        Text(label),
      ],
    );
  }
}

// ---------------- Room Card Widget ----------------
class _RoomCard extends StatelessWidget {
  final Room room;
  final VoidCallback? onEdit; // nullable: if null -> disabled
  final VoidCallback onToggleOpen;

  const _RoomCard({
    required this.room,
    required this.onEdit,
    required this.onToggleOpen,
  });

  @override
  Widget build(BuildContext context) {
    final isReserved = room.isReserved;
    final isOpen = room.isOpen;
    final color = isReserved ? Colors.orange : Colors.green;
    final label = isReserved ? 'Reserved' : 'Free';
    final icon = isReserved ? Icons.event_busy : Icons.event_available;

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // image + badge
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(14)),
              child: Stack(
                children: [
                  room.imageFile != null
                      ? Image.file(room.imageFile!, width: double.infinity, height: 160, fit: BoxFit.cover)
                      : Container(height: 160, color: Colors.grey[200], alignment: Alignment.center, child: const Icon(Icons.meeting_room_rounded, size: 56, color: Colors.grey)),
                  Positioned(
                    right: 12,
                    top: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(color: color.withOpacity(0.95), borderRadius: BorderRadius.circular(12)),
                      child: Row(
                        children: [
                          Icon(icon, color: Colors.white, size: 14),
                          const SizedBox(width: 6),
                          Text(label, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // details
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 12, 14, 8),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(room.name, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 6),
                Text('Capacity: ' + room.description, style: const TextStyle(fontSize: 13, color: Colors.black87)),
              ]),
            ),

            // actions row: edit + open/close switch
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Edit button (disabled when reserved)
                  TextButton.icon(
                    onPressed: onEdit,
                    style: ButtonStyle( backgroundColor: isReserved ==true ? WidgetStatePropertyAll<Color>(const Color.fromARGB(255, 220, 220, 220)) : WidgetStatePropertyAll<Color>(Color(0xFFDD0303)) ),
                    icon: Icon(Icons.edit, color: isReserved == true ? Colors.grey : Colors.white),
                    label: Text('Edit', style: TextStyle(color: isReserved == true ? Colors.grey : Colors.white)),
                  ),

                  // Open/Close switch (disabled when reserved)
                  Row(
                    children: [
                      Text(isOpen ? 'Open' : 'Closed', style: TextStyle(fontWeight: FontWeight.bold)),
                      const SizedBox(width: 8),
                      // If reserved -> disable switch
                      AbsorbPointer(
                        absorbing: isReserved,
                        child: Opacity(
                          opacity: isReserved ? 0.6 : 1.0,
                          child: Switch(
                            value: isOpen,
                            onChanged: (_) => onToggleOpen(),
                            activeColor: isOpen ? Colors.green : Color(0xFFDD0303),
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
    );
  }
}