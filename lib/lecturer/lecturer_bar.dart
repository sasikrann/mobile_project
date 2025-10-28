import 'package:flutter/material.dart';

class LecturerBar extends StatefulWidget {
  const LecturerBar({
    super.key,
    required this.home,
    required this.dashboard,
    required this.notification,
    required this.history,
    required this.profile,
    this.backgroundColor = Colors.transparent,
  });

  final Widget home;
  final Widget dashboard;
  final Widget notification;
  final Widget history;
  final Widget profile;
  final Color backgroundColor;

  @override
  State<LecturerBar> createState() => _LecturerBarState();
}

class _LecturerBarState extends State<LecturerBar> {
  int _currentIndex = 0;
  late final PageController _pc = PageController(initialPage: 0);

  List<Widget> get _pages => [
        widget.home,
        widget.dashboard,
        widget.notification,
        widget.history,
        widget.profile,
      ];

  @override
  void dispose() {
    _pc.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: widget.backgroundColor,
      extendBody: true,
      body: Stack(
        children: [
          // 🔹 PageView
          AnimatedBuilder(
            animation: _pc,
            builder: (_, __) {
              final page = _pc.hasClients
                  ? _pc.page ?? _currentIndex.toDouble()
                  : _currentIndex.toDouble();

              return PageView.builder(
                controller: _pc,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _pages.length,
                itemBuilder: (context, index) {
                  final delta = (index - page);
                  final t = (1 - delta.abs()).clamp(0.0, 1.0);
                  final dx = 40.0 * -delta;
                  final scale = 0.96 + 0.04 * t;
                  final opacity = 0.65 + 0.35 * t;

                  return Transform.translate(
                    offset: Offset(dx, 0),
                    child: Transform.scale(
                      scale: scale,
                      alignment: delta >= 0
                          ? Alignment.centerLeft
                          : Alignment.centerRight,
                      child: Opacity(opacity: opacity, child: _pages[index]),
                    ),
                  );
                },
              );
            },
          ),

          // 🔹 Capsule bar ด้านล่าง
          Positioned(
            left: 0,
            right: 0,
            bottom: MediaQuery.of(context).padding.bottom + 16,
            child: Center(
              child: _CapsuleIconBar(
                currentIndex: _currentIndex,
                onTap: (i) {
                  if (i == _currentIndex) return;
                  setState(() => _currentIndex = i);
                  _pc.animateToPage(
                    i,
                    duration: const Duration(milliseconds: 420),
                    curve: Curves.easeOutCubic,
                  );
                },
                items: const [
                  Icons.home_rounded,
                  Icons.dashboard_rounded,
                  Icons.notifications_rounded,
                  Icons.access_time_rounded,
                  Icons.person_rounded,
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CapsuleIconBar extends StatelessWidget {
  const _CapsuleIconBar({
    required this.items,
    required this.currentIndex,
    required this.onTap,
  });

  final List<IconData> items;
  final int currentIndex;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    const double itemWidth = 56;
    const double itemHeight = 48;
    const double gap = 8;
    final double totalWidth =
        (items.length * itemWidth) + ((items.length - 1) * gap);

    return Container(
      padding: const EdgeInsets.all(6),
      margin: const EdgeInsets.symmetric(horizontal: 24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFDD0303), Color(0xFFB80202)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            blurRadius: 24,
            offset: const Offset(0, 8),
            color: const Color(0xFFDD0303).withOpacity(0.35),
          ),
          BoxShadow(
            blurRadius: 8,
            offset: const Offset(0, 2),
            color: Colors.black.withOpacity(0.15),
          ),
        ],
        border: Border.all(
          color: const Color(0xFFFF4444).withOpacity(0.3),
          width: 1.5,
        ),
      ),
      child: SafeArea(
        top: false,
        bottom: false,
        child: Center(
          child: SizedBox(
            width: totalWidth,
            height: itemHeight,
            child: Stack(
              children: [
                AnimatedPositioned(
                  duration: const Duration(milliseconds: 280),
                  curve: Curves.easeInOutCubic,
                  left: currentIndex * (itemWidth + gap),
                  top: 0,
                  width: itemWidth,
                  height: itemHeight,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(22),
                    ),
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: List.generate(items.length, (i) {
                    final active = i == currentIndex;
                    return SizedBox(
                      width: itemWidth,
                      height: itemHeight,
                      child: _IconPillButton(
                        icon: items[i],
                        active: active,
                        onTap: () => onTap(i),
                      ),
                    );
                  }),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _IconPillButton extends StatelessWidget {
  const _IconPillButton({
    required this.icon,
    required this.active,
    required this.onTap,
  });

  final IconData icon;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Center(
        child: AnimatedScale(
          duration: const Duration(milliseconds: 200),
          scale: active ? 1.1 : 0.95,
          curve: Curves.easeOutCubic,
          child: Icon(
            icon,
            size: 24,
            color:
                active ? const Color(0xFFDD0303) : Colors.white.withOpacity(0.7),
          ),
        ),
      ),
    );
  }
}
