// staff_dashboard.dart
import 'dart:convert';
import 'package:flutter/material.dart';
import '../../services/auth_storage.dart';
import '../services/api_client.dart';

class StaffDashboardPage extends StatefulWidget {
  const StaffDashboardPage({super.key});

  @override
  State<StaffDashboardPage> createState() => _StaffDashboardPageState();
}

class _StaffDashboardPageState extends State<StaffDashboardPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  // Dynamic counts
  int totalFree = 0;
  int totalPending = 0;
  int totalReserved = 0;
  int totalClosedRooms = 0;
  int totalRooms = 0;

  bool loading = true;
  String? token;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    )..forward();
    _initDashboard();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _initDashboard() async {
    final savedToken = await AuthStorage.getToken();
    if (savedToken == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Session expired. Please log in again.')),
        );
        Navigator.pushReplacementNamed(context, '/login');
      }
      return;
    }
    token = savedToken;
    await _loadDashboardData();
  }

  Future<void> _loadDashboardData() async {
    setState(() => loading = true);

    try {
      // ===== 1️⃣ ดึงรายการห้องทั้งหมด =====
      final roomsRes = await ApiClient.get('/api/rooms');
      if (roomsRes.statusCode != 200) {
        throw Exception('Failed to fetch rooms (${roomsRes.statusCode})');
      }

      final rooms = (jsonDecode(roomsRes.body)['rooms'] as List<dynamic>);
      totalRooms = rooms.length;

      // ===== 2️⃣ แยกห้องที่ปิดออก =====
      final closedRooms = rooms.where((r) {
        final status = (r['status'] ?? '').toString().toLowerCase();
        return status == 'closed';
      }).toList();

      totalClosedRooms = closedRooms.length;
      final openRooms = rooms.where((r) => !closedRooms.contains(r)).toList();

      // 1 ห้องมี 4 slot
      final totalPossibleSlots = openRooms.length * 4;
      int reserved = 0;
      int pending = 0;

      // ===== 3️⃣ ดึงสถานะห้องที่เปิดอยู่ (parallel fetch) =====
      final futures = openRooms.map((room) async {
        final id = room['id'];
        try {
          final res = await ApiClient.get('/api/rooms/$id/status');

          if (res.statusCode == 200) {
            final body = jsonDecode(res.body) as Map<String, dynamic>;
            final slots = (body['slots'] as List<dynamic>?) ?? [];

            for (final s in slots) {
              final st = (s['status'] ?? '').toString().toLowerCase().trim();
              if (st == 'reserved') {
                reserved++;
              } else if (st == 'pending' || st == 'on hold' || st == 'onhold') {
                pending++;
              }
            }
          }
        } catch (e) {
          // network error → skip this room
          debugPrint('⚠️ Failed to fetch status for room $id: $e');
        }
      }).toList();

      // รอทุก future ให้เสร็จ
      await Future.wait(futures).timeout(const Duration(seconds: 10), onTimeout: () {
        debugPrint('⏰ Timeout while fetching room statuses');
        return futures.map((_) => null).toList();
      });

      // ===== 4️⃣ คำนวณสรุป =====
      int free = totalPossibleSlots - reserved - pending;
      if (free < 0) free = 0;

      // ===== 5️⃣ อัปเดต state =====
      if (!mounted) return;
      setState(() {
        totalReserved = reserved;
        totalPending = pending;
        totalFree = free;
        loading = false;
      });
    } on ApiUnauthorized {
      if (!mounted) return;
      setState(() => loading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Session expired. Please log in again.')),
      );
      // TODO: redirect ไปหน้า login
    } catch (e, st) {
      debugPrint('❌ Dashboard load error: $e\n$st');
      if (!mounted) return;
      setState(() => loading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading dashboard: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final double safe = MediaQuery.of(context).padding.bottom;
    const double barH = 88;
    final double bottomPad = 24 + barH + safe;

    return Scaffold(
      body: Stack(
        children: [
          // Background gradient (same as your layout)
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFFFFF5E6),
                  Color(0xFFFFE8CC),
                  Color(0xFFFFF0DB),
                ],
              ),
            ),
          ),

          // Decorative circles (unchanged)
          Positioned(
            top: -100,
            right: -100,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    const Color(0xFFDD0303).withValues(alpha:0.08),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            bottom: -50,
            left: -50,
            child: Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    const Color(0xFFE67E22).withValues(alpha:0.06),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),

          // Main content
          SafeArea(
            child: loading
                ? const Center(child: CircularProgressIndicator())
                : RefreshIndicator(
                    onRefresh: _loadDashboardData,
                    child: SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: EdgeInsets.fromLTRB(24, 24, 24, bottomPad),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Header card (unchanged)
                          FadeTransition(
                            opacity: _controller,
                            child: SlideTransition(
                              position: Tween<Offset>(
                                begin: const Offset(0, -0.3),
                                end: Offset.zero,
                              ).animate(CurvedAnimation(
                                parent: _controller,
                                curve: Curves.easeOut,
                              )),
                              child: Container(
                                padding: const EdgeInsets.all(20),
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha:0.6),
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                    color: Colors.white.withValues(alpha:0.8),
                                    width: 2,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: const Color(0xFFDD0303)
                                          .withValues(alpha:0.08),
                                      blurRadius: 20,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(12),
                                      decoration: BoxDecoration(
                                        gradient: const LinearGradient(
                                          colors: [
                                            Color(0xFFDD0303),
                                            Color(0xFFFF4444),
                                          ],
                                        ),
                                        borderRadius:
                                            BorderRadius.circular(14),
                                        boxShadow: [
                                          BoxShadow(
                                            color: const Color(0xFFDD0303)
                                                .withValues(alpha:0.3),
                                            blurRadius: 8,
                                            offset: const Offset(0, 4),
                                          ),
                                        ],
                                      ),
                                      child: const Icon(
                                        Icons.dashboard_rounded,
                                        color: Colors.white,
                                        size: 28,
                                      ),
                                    ),
                                    const SizedBox(width: 16),
                                    const Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'Today',
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: Color(0xFF8B6F47),
                                              fontWeight: FontWeight.w600,
                                              letterSpacing: 1.2,
                                            ),
                                          ),
                                          SizedBox(height: 2),
                                          Text(
                                            'Dashboard',
                                            style: TextStyle(
                                              fontSize: 28,
                                              fontWeight: FontWeight.bold,
                                              color: Color(0xFF2D1810),
                                              letterSpacing: -0.5,
                                              height: 1.0,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 32),

                          // Stats grid (dynamic counts)
                          GridView.count(
                            crossAxisCount: 2,
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            mainAxisSpacing: 16,
                            crossAxisSpacing: 16,
                            childAspectRatio: 1.0,
                            children: [
                              _buildStatusCard(
                                index: 0,
                                icon: Icons.event_available_rounded,
                                iconColor: const Color(0xFF0FA968),
                                iconBgColor: const Color(0xFFD4F4E6),
                                count: '$totalFree',
                                label: 'Free Slots',
                              ),
                              _buildStatusCard(
                                index: 1,
                                icon: Icons.access_time_rounded,
                                iconColor: const Color(0xFF5D6CC4),
                                iconBgColor: const Color(0xFFE0E4F7),
                                count: '$totalPending',
                                label: 'Pending Slots',
                              ),
                              _buildStatusCard(
                                index: 2,
                                icon: Icons.bookmark_rounded,
                                iconColor: const Color(0xFFE67E22),
                                iconBgColor: const Color(0xFFFDEDD7),
                                count: '$totalReserved',
                                label: 'Reserved Slots',
                              ),
                              _buildStatusCard(
                                index: 3,
                                icon: Icons.block_rounded,
                                iconColor: const Color(0xFFDD0303),
                                iconBgColor: const Color(0xFFFFE8E8),
                                count: '$totalClosedRooms',
                                label: 'Disabled Room',
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),

                          // All Rooms card (shows totalRooms)
                          _buildAllRoomsCard(index: 4, totalRooms: totalRooms),
                        ],
                      ),
                    ),
                  ),
          ),

          // Bottom overlay (fixed two-color gradient)
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              height: barH + safe,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Color(0xFFFFF0DB), Color(0xFFFFE8CC)],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusCard({
    required int index,
    required IconData icon,
    required Color iconColor,
    required Color iconBgColor,
    required String count,
    required String label,
  }) {
    final delay = index * 0.1;
    final animation = CurvedAnimation(
      parent: _controller,
      curve: Interval(delay, delay + 0.4, curve: Curves.easeOutCubic),
    );

    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, 30 * (1 - animation.value)),
          child: Opacity(opacity: animation.value, child: child),
        );
      },
      child: _StatCard(
        icon: icon,
        iconColor: iconColor,
        iconBgColor: iconBgColor,
        count: count,
        label: label,
      ),
    );
  }

  Widget _buildAllRoomsCard({required int index, required int totalRooms}) {
    final delay = index * 0.1;
    final animation = CurvedAnimation(
      parent: _controller,
      curve: Interval(delay, delay + 0.4, curve: Curves.easeOutCubic),
    );

    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, 30 * (1 - animation.value)),
          child: Opacity(opacity: animation.value, child: child),
        );
      },
      child: _AllRoomsCard(totalRooms: totalRooms),
    );
  }
}

//--------------------- Stat Card ----------------------//
class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.icon,
    required this.iconColor,
    required this.iconBgColor,
    required this.count,
    required this.label,
  });

  final IconData icon;
  final Color iconColor;
  final Color iconBgColor;
  final String count;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: iconColor.withValues(alpha:0.15), width: 2),
        boxShadow: [
          BoxShadow(
            color: iconColor.withValues(alpha:0.12),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
          BoxShadow(
            color: Colors.black.withValues(alpha:0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: iconBgColor,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: iconColor.withValues(alpha:0.2), width: 2),
              ),
              child: Icon(icon, color: iconColor, size: 28),
            ),
            const Spacer(),
            Text(
              count,
              style: TextStyle(
                fontSize: 36,
                fontWeight: FontWeight.bold,
                color: iconColor,
                height: 1.0,
                letterSpacing: -1,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 13,
                color: Color(0xFF8B6F47),
                fontWeight: FontWeight.w600,
                letterSpacing: 0.2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

//--------------------- All Rooms Card ----------------------//
class _AllRoomsCard extends StatelessWidget {
  const _AllRoomsCard({required this.totalRooms});
  final int totalRooms;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFDD0303), Color(0xFFB00202)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withValues(alpha:0.2), width: 2),
      ),
      child: Padding(
        padding: const EdgeInsets.all(28.0),
        child: Row(
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha:0.25),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: Colors.white.withValues(alpha:0.4),
                  width: 2,
                ),
              ),
              child: const Icon(Icons.meeting_room_rounded,
                  color: Colors.white, size: 32),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '$totalRooms',
                    style: const TextStyle(
                      fontSize: 42,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      height: 1.0,
                      letterSpacing: -1,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'All Rooms',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.5,
                    ),
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
