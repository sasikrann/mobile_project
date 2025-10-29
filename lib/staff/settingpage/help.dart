import 'package:flutter/material.dart';

class HelpCenterPage extends StatefulWidget {
  const HelpCenterPage({
    super.key,
    this.backgroundColor = const Color(0xFFFFF0DB),
    this.accentColor = const Color(0xFFDD0303),
  });

  final Color backgroundColor;
  final Color accentColor;

  @override
  State<HelpCenterPage> createState() => _HelpCenterPageState();
}

class _HelpCenterPageState extends State<HelpCenterPage> {
  final List<FaqSection> _sections = [
    FaqSection(
      title: 'General Information',
      icon: Icons.info_outline,
      color: const Color(0xFF4A90E2),
      faqs: const [
        Faq(
          q: 'What are the time slot statuses?',
          a: 'Each room slot has one of: FREE, PENDING, RESERVED, DISABLED.',
        ),
        Faq(
          q: "What are today's time slots?",
          a: 'There are four slots per day: 08–10, 10–12, 13–15, and 15–17.',
        ),
        Faq(
          q: 'When is a slot not bookable anymore?',
          a: "If current time is later than a slot’s start, that slot is not available for booking today.",
        ),
        Faq(
          q: 'What happens at the start of the next day?',
          a: 'All rooms must be either FREE or DISABLED for the new day.',
        ),
      ],
    ),
    FaqSection(
      title: 'For Students',
      icon: Icons.school_outlined,
      color: const Color(0xFF9C27B0),
      faqs: const [
        Faq(
          q: 'What can a student do?',
          a: 'Register/login, browse room list, request a booking for today by choosing date and time slot, and check request status.',
        ),
        Faq(
          q: 'How many bookings can I make per day?',
          a: 'A student can book only a single slot in one day.',
        ),
        Faq(
          q: 'What happens after I request a booking?',
          a: 'The slot becomes PENDING. No other booking is allowed for that slot until it is approved or rejected by an Approver.',
        ),
        Faq(
          q: 'How do I check my booking status?',
          a: 'Open your "My Requests/History" page to see PENDING/RESERVED/REJECTED. If rejected, the slot returns to FREE.',
        ),
        Faq(
          q: 'Can I request for a future day?',
          a: 'Requests are for today only as per policy. If future-day booking is needed, contact staff/approver for exceptions.',
        ),
      ],
    ),
    FaqSection(
      title: 'For Staff',
      icon: Icons.admin_panel_settings_outlined,
      color: const Color(0xFFFF9800),
      faqs: const [
        Faq(
          q: 'What can staff do?',
          a: "Login, browse room list, add/edit/disable rooms, view dashboard with counts for FREE/PENDING/RESERVED/DISABLED, and review lecturers’ histories.",
        ),
        Faq(
          q: 'When may I disable a room/slot?',
          a: 'Staff can disable rooms (or slots) only when the status is FREE. Do not disable PENDING/RESERVED slots.',
        ),
        Faq(
          q: 'How does the dashboard help?',
          a: "Dashboard summarizes today’s FREE, PENDING, RESERVED, and DISABLED slots and highlights demand patterns.",
        ),
        Faq(
          q: 'Editing rooms safely',
          a: 'Edit room details (name/equipment) any time, but avoid changing availability for slots that are PENDING/RESERVED.',
        ),
      ],
    ),
    FaqSection(
      title: 'For Approvers',
      icon: Icons.verified_user_outlined,
      color: const Color(0xFF4CAF50),
      faqs: const [
        Faq(
          q: 'What can an approver do?',
          a: 'Login, browse rooms, see booking requests, approve or disapprove requests, view own history/log.',
        ),
        Faq(
          q: 'What happens when I approve a request?',
          a: "The slot’s status changes from PENDING to RESERVED.",
        ),
        Faq(
          q: 'What happens when I reject a request?',
          a: 'The slot returns to FREE and becomes available for others.',
        ),
        Faq(
          q: 'How should I handle conflicts?',
          a: "Always verify the student’s single-slot-per-day rule and room readiness. Use dashboard/room list to double-check statuses before finalizing.",
        ),
      ],
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: widget.backgroundColor,
      appBar: AppBar(
        elevation: 0,
        centerTitle: true,
        backgroundColor: widget.backgroundColor,
        title: const Text(
          'Help Center',
          style: TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 22,
          ),
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFFFF5E6), Color(0xFFFFE8CC), Color(0xFFFFF0DB)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          bottom: false,
          child: ListView.builder(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
            itemCount: _sections.length,
            itemBuilder: (context, index) => _SectionCard(
              section: _sections[index],
              accentColor: widget.accentColor,
            ),
          ),
        ),
      ),
    );
  }
}

class FaqSection {
  final String title;
  final IconData icon;
  final Color color;
  final List<Faq> faqs;

  const FaqSection({
    required this.title,
    required this.icon,
    required this.color,
    required this.faqs,
  });
}

class Faq {
  final String q;
  final String a;
  const Faq({required this.q, required this.a});
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({
    required this.section,
    required this.accentColor,
  });

  final FaqSection section;
  final Color accentColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: section.color.withOpacity(0.15),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  section.color.withOpacity(0.1),
                  section.color.withOpacity(0.05),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: section.color.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(
                    section.icon,
                    color: section.color,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    section.title,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: section.color,
                    ),
                  ),
                ),
              ],
            ),
          ),
          // FAQ List
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            padding: const EdgeInsets.all(16),
            itemCount: section.faqs.length,
            separatorBuilder: (_, __) => const Divider(height: 24),
            itemBuilder: (context, index) => _FaqItem(
              faq: section.faqs[index],
              color: section.color,
            ),
          ),
        ],
      ),
    );
  }
}

class _FaqItem extends StatefulWidget {
  const _FaqItem({
    required this.faq,
    required this.color,
  });

  final Faq faq;
  final Color color;

  @override
  State<_FaqItem> createState() => _FaqItemState();
}

class _FaqItemState extends State<_FaqItem> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => setState(() => _isExpanded = !_isExpanded),
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    widget.faq.q,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1A1A2E),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                AnimatedRotation(
                  turns: _isExpanded ? 0.5 : 0,
                  duration: const Duration(milliseconds: 200),
                  child: Icon(
                    Icons.keyboard_arrow_down,
                    color: widget.color,
                  ),
                ),
              ],
            ),
            AnimatedCrossFade(
              firstChild: const SizedBox.shrink(),
              secondChild: Padding(
                padding: const EdgeInsets.only(top: 12, right: 24),
                child: Text(
                  widget.faq.a,
                  style: const TextStyle(
                    fontSize: 14,
                    height: 1.6,
                    color: Colors.black87,
                  ),
                ),
              ),
              crossFadeState:
                  _isExpanded ? CrossFadeState.showSecond : CrossFadeState.showFirst,
              duration: const Duration(milliseconds: 200),
            ),
          ],
        ),
      ),
    );
  }
}