import 'package:flutter/material.dart';

class PrivacyPolicyPage extends StatelessWidget {
  const PrivacyPolicyPage({
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
          'Privacy Policy',
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
              // Hero Header Card
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      accentColor.withOpacity(0.1),
                      accentColor.withOpacity(0.05),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: accentColor.withOpacity(0.15),
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
                      child: Icon(
                        Icons.privacy_tip_outlined,
                        size: 40,
                        color: accentColor,
                      ),
                    ),
                    const SizedBox(width: 20),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Your Privacy Matters',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF1A1A2E),
                            ),
                          ),
                          SizedBox(height: 6),
                          Text(
                            'We protect your data with care',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.black87,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Main Content Card
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.08),
                      blurRadius: 24,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    _Section(
                      icon: Icons.info_outline,
                      color: const Color(0xFF4A90E2),
                      title: 'Introduction',
                      children: const [
                        _P(
                          "This Privacy Policy explains how we collect, use, disclose, and safeguard your information when you use our room reservation application. By using the Service, you agree to the collection and use of information in accordance with this Policy.",
                        ),
                      ],
                    ),
                    _Divider(),
                    _Section(
                      icon: Icons.folder_outlined,
                      color: const Color(0xFF9C27B0),
                      title: 'Information We Collect',
                      children: const [
                        _H2('1) Information you provide'),
                        _UL([
                          "Account details: first name, last name, username, email, phone number.",
                          "Profile content: optional information you add to your profile.",
                          "Support messages and feedback you submit to us.",
                        ]),
                        _H2('2) Information collected automatically'),
                        _UL([
                          "Usage data: app screens and actions (e.g., view rooms, submit requests).",
                          "Device data: device model, OS version, app version, approximate time zone.",
                          "Log data and diagnostic events to improve stability and performance.",
                        ]),
                        _H2('3) Information from others'),
                        _UL([
                          "If your organization provides staff/approver accounts, we may receive basic account metadata from them.",
                        ]),
                      ],
                    ),
                    _Divider(),
                    _Section(
                      icon: Icons.settings_outlined,
                      color: const Color(0xFFFF9800),
                      title: 'How We Use Your Information',
                      children: const [
                        _UL([
                          "Provide and operate the room reservation features (browse, request, approve).",
                          "Maintain account authentication and user sessions.",
                          "Prevent duplicate bookings and enforce per-day booking limits.",
                          "Monitor performance, troubleshoot, and improve the Service.",
                          "Communicate updates, security alerts, and support responses.",
                          "Comply with legal obligations and enforce our Terms.",
                        ]),
                      ],
                    ),
                    _Divider(),
                    _Section(
                      icon: Icons.gavel_outlined,
                      color: const Color(0xFF4CAF50),
                      title: 'Legal Bases',
                      children: const [
                        _UL([
                          "Performance of a contract (to deliver the Service you requested).",
                          "Legitimate interests (to keep the Service secure and reliable).",
                          "Consent (where required; you can withdraw at any time).",
                          "Compliance with a legal obligation.",
                        ]),
                      ],
                    ),
                    _Divider(),
                    _Section(
                      icon: Icons.share_outlined,
                      color: const Color(0xFFE91E63),
                      title: 'Sharing of Information',
                      children: const [
                        _UL([
                          "With your organization's administrators (for staff/approver accounts).",
                          "Service providers that host, store, or process data on our behalf.",
                          "When required by law, regulation, or legal process.",
                          "In connection with a merger, acquisition, or asset transfer (with notice).",
                          "With your consent or at your direction.",
                        ]),
                      ],
                    ),
                    _Divider(),
                    _Section(
                      icon: Icons.access_time_outlined,
                      color: const Color(0xFF00BCD4),
                      title: 'Data Retention',
                      children: const [
                        _P(
                          "We retain personal information for as long as necessary to provide the Service, resolve disputes, enforce agreements, and comply with legal requirements. Retention periods may vary by data type and organizational policy.",
                        ),
                      ],
                    ),
                    _Divider(),
                    _Section(
                      icon: Icons.security_outlined,
                      color: const Color(0xFFDD0303),
                      title: 'Security',
                      children: const [
                        _P(
                          "We use administrative, technical, and physical safeguards designed to protect your information. However, no method of transmission or storage is 100% secure, and we cannot guarantee absolute security.",
                        ),
                      ],
                    ),
                    _Divider(),
                    _Section(
                      icon: Icons.how_to_reg_outlined,
                      color: const Color(0xFF673AB7),
                      title: 'Your Rights & Choices',
                      children: const [
                        _UL([
                          "Access, correct, or delete certain account information.",
                          "Object to or restrict certain processing, where applicable.",
                          "Export your data where technically feasible.",
                          "Manage communications and notifications from the app.",
                        ]),
                        SizedBox(height: 8),
                        _P(
                          "To exercise rights, use in-app settings or contact us using the details below. We may need to verify your identity before fulfilling your request.",
                        ),
                      ],
                    ),
                    _Divider(),
                    _Section(
                      icon: Icons.child_care_outlined,
                      color: const Color(0xFFFF5722),
                      title: 'Childrens Privacy',
                      children: const [
                        _P(
                          "The Service is not directed to children under the age required by local law. We do not knowingly collect personal information from children. If you believe a child has provided us information, please contact us to request deletion.",
                        ),
                      ],
                    ),
                    _Divider(),
                    _Section(
                      icon: Icons.public_outlined,
                      color: const Color(0xFF009688),
                      title: 'International Transfers',
                      children: const [
                        _P(
                          "Your information may be processed and stored in countries other than your own. We take steps to ensure appropriate safeguards are in place for such transfers in accordance with applicable laws.",
                        ),
                      ],
                    ),
                    _Divider(),
                    _Section(
                      icon: Icons.cookie_outlined,
                      color: const Color(0xFF795548),
                      title: 'Cookies & Similar Technologies',
                      children: const [
                        _P(
                          "If the Service uses cookies or local storage, these are used to remember your session, preferences, and to measure performance. You can manage these via your device or browser settings, though some features may not function properly.",
                        ),
                      ],
                    ),
                    _Divider(),
                    _Section(
                      icon: Icons.update_outlined,
                      color: const Color(0xFF607D8B),
                      title: 'Changes to This Policy',
                      children: const [
                        _P(
                          "We may update this Policy from time to time. The updated version will be indicated by a revised Last updated date. Your continued use of the Service after changes constitutes acceptance of the updated Policy.",
                        ),
                      ],
                    ),
                    _Divider(),
                    _Section(
                      icon: Icons.contact_support_outlined,
                      color: const Color(0xFF3F51B5),
                      title: 'Contact Us',
                      children: const [
                        _P(
                          "If you have questions about this Policy or our data practices, please contact: support@example.com. For organizational accounts, you may also contact your administrator.",
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    const _Caption('Last updated: October 21, 2025'),
                    const SizedBox(height: 24),
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
                  color: color.withOpacity(0.12),
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
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      height: 1,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.transparent,
            Colors.black.withOpacity(0.08),
            Colors.transparent,
          ],
        ),
      ),
    );
  }
}

class _H2 extends StatelessWidget {
  const _H2(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 12, bottom: 8),
      child: Text(
        text,
        style: const TextStyle(
          fontWeight: FontWeight.w700,
          fontSize: 15,
          color: Color(0xFF1A1A2E),
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
                      color: const Color(0xFF1A1A2E).withOpacity(0.6),
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
        color: Colors.black.withOpacity(0.03),
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