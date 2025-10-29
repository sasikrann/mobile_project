import 'package:flutter/material.dart';
import './settingpage/profile.dart';
import './settingpage/service.dart';
import './settingpage/privacy.dart';
import './settingpage/help.dart';
import '../auth/login.dart';

class StaffProfilePage extends StatefulWidget {
  const StaffProfilePage({super.key, this.bottomOverlapPadding});

  final double? bottomOverlapPadding;

  @override
  State<StaffProfilePage> createState() => _StaffProfilePageState();
}

class _StaffProfilePageState extends State<StaffProfilePage>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;



  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    )..forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final double safe = MediaQuery.of(context).padding.bottom;
    final double barH = widget.bottomOverlapPadding ?? 88;
    final double bottomPad = barH + safe + 16;

    return Scaffold(
      backgroundColor: const Color(0xFFFFF0DB),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFFFFF5E6), Color(0xFFFFE8CC), Color(0xFFFFF0DB)],
          ),
        ),
        child: SafeArea(
          bottom: false,
          child: Stack(
            children: [
              // ===== เนื้อหาหลัก =====
              SingleChildScrollView(
                padding: EdgeInsets.fromLTRB(24, 24, 24, bottomPad),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header
                    FadeTransition(
                      opacity: _controller,
                      child: SlideTransition(
                        position: Tween<Offset>(
                          begin: const Offset(0, -0.3),
                          end: Offset.zero,
                        ).animate(
                          CurvedAnimation(
                            parent: _controller,
                            curve: Curves.easeOut,
                          ),
                        ),
                        child: const Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Settings',
                              style: TextStyle(
                                fontSize: 32,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF1A1A2E),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),

                    // Profile Card (กดแล้วไป Edit Profile — เติมโค้ดเองที่นี่)
                    _buildAnimatedItem(
                      index: 0,
                      child: _ProfileCard(
                        onTap: () {
                          Navigator.push(context, MaterialPageRoute(builder: (_) => const EditProfilePage()));
                        },
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Menu Items
                    _buildAnimatedItem(
                      index: 1,
                      child: _SettingMenuItem(
                        icon: Icons.help_outline,
                        iconColor: const Color(0xFF6366F1),
                        iconBgColor: const Color(0xFFDDD6FE),
                        title: 'Help Center',
                        onTap: () {
                          Navigator.push(context, MaterialPageRoute(builder: (_) => const HelpCenterPage()));
                        },
                      ),
                    ),
                    const SizedBox(height: 12),

                    _buildAnimatedItem(
                      index: 2,
                      child: _SettingMenuItem(
                        icon: Icons.privacy_tip_outlined,
                        iconColor: const Color(0xFF10B981),
                        iconBgColor: const Color(0xFFD1FAE5),
                        title: 'Privacy Policy',
                        onTap: () {
                          Navigator.push(context, MaterialPageRoute(builder: (_) => const PrivacyPolicyPage()));
                        },
                      ),
                    ),
                    const SizedBox(height: 12),

                    _buildAnimatedItem(
                      index: 3,
                      child: _SettingMenuItem(
                        icon: Icons.description_outlined,
                        iconColor: const Color(0xFFF59E0B),
                        iconBgColor: const Color(0xFFFEF3E2),
                        title: 'Terms of Service',
                        onTap: () {
                          Navigator.push(context, MaterialPageRoute(builder: (_) => const TermsOfServicePage()));
                        },
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Logout Button
                    _buildAnimatedItem(
                      index: 4,
                      child: _LogoutButton(
                        onTap: () {
                          Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (_) => const LoginPage()),
                        );
                        }, // <<< เติม flow logout ของคุณเอง
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAnimatedItem({required int index, required Widget child}) {
    final delay = index * 0.08;
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
      child: child,
    );
  }
}

// ========================= วิดเจ็ตย่อย =========================

class _ProfileCard extends StatefulWidget {
  const _ProfileCard({this.onTap});
  final VoidCallback? onTap;

  @override
  State<_ProfileCard> createState() => _ProfileCardState();
}

class _ProfileCardState extends State<_ProfileCard> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) => setState(() => _isPressed = false),
      onTapCancel: () => setState(() => _isPressed = false),
      onTap: widget.onTap, // เว้นไว้ให้
      child: AnimatedScale(
        scale: _isPressed ? 0.97 : 1.0,
        duration: const Duration(milliseconds: 150),
        curve: Curves.easeOut,
        child: Container(
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF6366F1).withOpacity(_isPressed ? 0.3 : 0.2),
                blurRadius: _isPressed ? 20 : 16,
                offset: Offset(0, _isPressed ? 6 : 4),
              ),
            ],
          ),
          child: const Padding(
            padding: EdgeInsets.all(24.0),
            child: Row(
              children: [
                _CircleAvatarIcon(),
                SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'John Doe',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Staff',
                        style: TextStyle(fontSize: 13, color: Colors.white70),
                      ),
                    ],
                  ),
                ),
                _LightArrow(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _CircleAvatarIcon extends StatelessWidget {
  const _CircleAvatarIcon();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 64,
      height: 64,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: 3),
      ),
      child: const Icon(Icons.person, color: Colors.white, size: 32),
    );
  }
}

class _LightArrow extends StatelessWidget {
  const _LightArrow();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(10),
      ),
      child: const Icon(Icons.arrow_forward_ios, color: Colors.white, size: 16),
    );
  }
}

class _SettingMenuItem extends StatefulWidget {
  const _SettingMenuItem({
    required this.icon,
    required this.iconColor,
    required this.iconBgColor,
    required this.title,
    required this.onTap,
  });

  final IconData icon;
  final Color iconColor;
  final Color iconBgColor;
  final String title;
  final VoidCallback onTap; // เว้นไว้ให้ใส่เองตอนเรียกใช้

  @override
  State<_SettingMenuItem> createState() => _SettingMenuItemState();
}

class _SettingMenuItemState extends State<_SettingMenuItem> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) {
        setState(() => _isPressed = false);
        widget.onTap(); // จะว่างก็ได้ เพราะ call site เป็น () {}
      },
      onTapCancel: () => setState(() => _isPressed = false),
      child: AnimatedScale(
        scale: _isPressed ? 0.97 : 1.0,
        duration: const Duration(milliseconds: 150),
        curve: Curves.easeOut,
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: widget.iconColor.withOpacity(_isPressed ? 0.12 : 0.06),
                blurRadius: _isPressed ? 16 : 10,
                offset: Offset(0, _isPressed ? 6 : 3),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: widget.iconBgColor,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(widget.icon, color: widget.iconColor, size: 24),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    widget.title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1A1A2E),
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    Icons.arrow_forward_ios,
                    size: 14,
                    color: Colors.grey[700],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _LogoutButton extends StatefulWidget {
  const _LogoutButton({required this.onTap});
  final VoidCallback onTap; // เว้นไว้ให้

  @override
  State<_LogoutButton> createState() => _LogoutButtonState();
}

class _LogoutButtonState extends State<_LogoutButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) {
        setState(() => _isPressed = false);
        widget.onTap(); // จะว่างก็ได้ เพราะ call site เป็น () {}
      },
      onTapCancel: () => setState(() => _isPressed = false),
      child: AnimatedScale(
        scale: _isPressed ? 0.97 : 1.0,
        duration: const Duration(milliseconds: 150),
        curve: Curves.easeOut,
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: const Color(0xFFDD0303).withOpacity(0.3),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFDD0303).withOpacity(_isPressed ? 0.15 : 0.08),
                blurRadius: _isPressed ? 16 : 10,
                offset: Offset(0, _isPressed ? 6 : 3),
              ),
            ],
          ),
          child: const Padding(
            padding: EdgeInsets.all(20.0),
            child: Row(
              children: [
                SizedBox(
                  width: 48,
                  height: 48,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: Color(0xFFFFE5E5),
                      borderRadius: BorderRadius.all(Radius.circular(14)),
                    ),
                    child: Icon(
                      Icons.logout,
                      color: Color(0xFFDD0303),
                      size: 24,
                    ),
                  ),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: Text(
                    'Logout',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFFDD0303),
                    ),
                  ),
                ),
                SizedBox(
                  width: 32,
                  height: 32,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: Color(0xFFFFE5E5),
                      borderRadius: BorderRadius.all(Radius.circular(10)),
                    ),
                    child: Icon(
                      Icons.arrow_forward_ios,
                      size: 14,
                      color: Color(0xFFDD0303),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}