import 'package:flutter/material.dart';

class TermsOfServicePage extends StatelessWidget {
  const TermsOfServicePage({
    super.key,
    this.backgroundColor = const Color(0xFFFFF0DB),
    this.accentColor = const Color(0xFFDD0303),
  });

  final Color backgroundColor;
  final Color accentColor;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        elevation: 0,
        centerTitle: true,
        backgroundColor: backgroundColor,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Terms of Service',
          style: TextStyle(fontWeight: FontWeight.w700, fontSize: 22),
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
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              // Hero header
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      accentColor.withValues(alpha:0.10),
                      accentColor.withValues(alpha:0.05),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: accentColor.withValues(alpha:0.15),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Icon(Icons.article_outlined, size: 40, color: accentColor),
                    ),
                    const SizedBox(width: 20),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Terms that keep things fair',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF1A1A2E),
                            ),
                          ),
                          SizedBox(height: 6),
                          Text(
                            'Please read these terms carefully',
                            style: TextStyle(fontSize: 14, color: Colors.black87),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Content card
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha:0.08),
                      blurRadius: 24,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: const Column(
                  children: [
                    _Section(
                      icon: Icons.info_outline,
                      color: Color(0xFF4A90E2),
                      title: '1. Introduction',
                      children: [
                        _P(
                          'These Terms of Service ("Terms") govern your use of the room reservation application and related services ("Service"). By accessing or using the Service, you agree to be bound by these Terms.',
                        ),
                      ],
                    ),
                    _Divider(),
                    _Section(
                      icon: Icons.rule_folder_outlined,
                      color: Color(0xFF9C27B0),
                      title: '2. Acceptance of Terms',
                      children: [
                        _P(
                          'If you do not agree to these Terms, do not use the Service. If you are using the Service on behalf of an organization, you represent that you have the authority to bind that organization to these Terms.',
                        ),
                      ],
                    ),
                    _Divider(),
                    _Section(
                      icon: Icons.person_outline,
                      color: Color(0xFFFF9800),
                      title: '3. User Accounts',
                      children: [
                        _UL([
                          'You must provide accurate and current account information.',
                          'You are responsible for maintaining the confidentiality of your credentials and all activities under your account.',
                          'Notify us immediately of any unauthorized use or security incident.',
                        ]),
                      ],
                    ),
                    _Divider(),
                    _Section(
                      icon: Icons.event_available_outlined,
                      color: Color(0xFF4CAF50),
                      title: '4. Booking Rules',
                      children: [
                        _UL([
                          'Bookings are for the current day only unless otherwise stated.',
                          'If current time is past a slot start, that slot cannot be booked for today.',
                          'Each student may book only one slot per day.',
                          'Slots have statuses: FREE, PENDING, RESERVED, DISABLED.',
                          'Staff may disable rooms/slots only when status is FREE.',
                          'Approvers (lecturers) review and approve or reject booking requests.',
                        ]),
                      ],
                    ),
                    _Divider(),
                    _Section(
                      icon: Icons.block_outlined,
                      color: Color(0xFFE91E63),
                      title: '5. Prohibited Activities',
                      children: [
                        _UL([
                          'Bypass or interfere with booking limits or slot states.',
                          'Submit false information or impersonate others.',
                          'Attempt to access accounts, data, or systems without authorization.',
                          'Introduce malware or perform actions that degrade Service performance.',
                        ]),
                      ],
                    ),
                    _Divider(),
                    _Section(
                      icon: Icons.verified_user_outlined,
                      color: Color(0xFF00BCD4),
                      title: '6. Approvals & Responsibilities',
                      children: [
                        _P(
                          'Approvers are solely responsible for verifying eligibility and resource readiness before approving. Staff manage room details and availability; they do not approve bookings.',
                        ),
                      ],
                    ),
                    _Divider(),
                    _Section(
                      icon: Icons.privacy_tip_outlined,
                      color: Color(0xFFDD0303),
                      title: '7. Data & Privacy',
                      children: [
                        _P(
                          'Your use of the Service is also governed by our Privacy Policy, which explains how we collect and process personal data.',
                        ),
                      ],
                    ),
                    _Divider(),
                    _Section(
                      icon: Icons.copyright_outlined,
                      color: Color(0xFF673AB7),
                      title: '8. Intellectual Property',
                      children: [
                        _P(
                          'The Service and its original content, features, and functionality are owned by the operator or its licensors and are protected by applicable laws.',
                        ),
                      ],
                    ),
                    _Divider(),
                    _Section(
                      icon: Icons.report_problem_outlined,
                      color: Color(0xFF795548),
                      title: '9. Disclaimers',
                      children: [
                        _P(
                          'The Service is provided on an "AS IS" and "AS AVAILABLE" basis. We disclaim all warranties of any kind to the fullest extent permitted by law.',
                        ),
                      ],
                    ),
                    _Divider(),
                    _Section(
                      icon: Icons.scale_outlined,
                      color: Color(0xFF3F51B5),
                      title: '10. Limitation of Liability',
                      children: [
                        _P(
                          'To the maximum extent permitted by law, we shall not be liable for any indirect, incidental, special, consequential, or punitive damages arising from or related to your use of the Service.',
                        ),
                      ],
                    ),
                    _Divider(),
                    _Section(
                      icon: Icons.handshake_outlined,
                      color: Color(0xFF607D8B),
                      title: '11. Indemnification',
                      children: [
                        _P(
                          'You agree to indemnify and hold harmless the operator from any claims, liabilities, damages, and expenses arising from your use of the Service or violation of these Terms.',
                        ),
                      ],
                    ),
                    _Divider(),
                    _Section(
                      icon: Icons.cancel_presentation_outlined,
                      color: Color(0xFF9E9E9E),
                      title: '12. Termination',
                      children: [
                        _P(
                          'We may suspend or terminate access to the Service at any time for violations of these Terms or for operational, security, or legal reasons.',
                        ),
                      ],
                    ),
                    _Divider(),
                    _Section(
                      icon: Icons.update_outlined,
                      color: Color(0xFF009688),
                      title: '13. Changes to These Terms',
                      children: [
                        _P(
                          'We may modify these Terms from time to time. The updated version will be indicated by a revised "Last updated" date. Continued use of the Service constitutes acceptance of the revised Terms.',
                        ),
                      ],
                    ),
                    _Divider(),
                    _Section(
                      icon: Icons.contact_support_outlined,
                      color: Color(0xFF9C27B0),
                      title: '14. Contact',
                      children: [
                        _P(
                          'Questions about these Terms can be sent to: support@example.com. Organizational users may also contact their administrator.',
                        ),
                      ],
                    ),
                    SizedBox(height: 24),
                    _Caption('Last updated: October 21, 2025'),
                    SizedBox(height: 24),
                  ],
                ),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}

/// ---- Small text/section helpers (same style as Privacy Policy) ----
class _Section extends StatelessWidget {
  const _Section({
    required this.icon,
    required this.color,
    required this.title,
    required this.children,
  });

  final IconData icon;
  final Color color;
  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: color.withValues(alpha:0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 24),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 18,
                    color: color,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...children,
        ],
      ),
    );
  }
}

class _Divider extends StatelessWidget {
  const _Divider();
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      height: 1,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.transparent,
            Colors.black.withValues(alpha:0.08),
            Colors.transparent,
          ],
        ),
      ),
    );
  }
}

class _P extends StatelessWidget {
  const _P(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        height: 1.6,
        fontSize: 14,
        color: Colors.black87,
      ),
    );
  }
}

class _UL extends StatelessWidget {
  const _UL(this.items);
  final List<String> items;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: items
          .map(
            (t) => Padding(
              padding: const EdgeInsets.only(top: 8, left: 4),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    margin: const EdgeInsets.only(top: 8),
                    width: 6,
                    height: 6,
                    decoration: BoxDecoration(
                      color: const Color(0xFF1A1A2E).withValues(alpha:0.6),
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      t,
                      style: const TextStyle(
                        height: 1.6,
                        fontSize: 14,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          )
          .toList(),
    );
  }
}

class _Caption extends StatelessWidget {
  const _Caption(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha:0.03),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.update, size: 14, color: Colors.black54),
          const SizedBox(width: 6),
          Text(
            text,
            style: const TextStyle(
              fontSize: 12,
              color: Colors.black54,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}