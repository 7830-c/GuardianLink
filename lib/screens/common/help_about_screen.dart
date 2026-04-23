import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/app_colors.dart';

class HelpAboutScreen extends StatelessWidget {
  const HelpAboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Help & About'),
        leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => context.pop()),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          // Hero card
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: const LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [Color(0xFF1E40AF), Color(0xFF3755C3)]),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(children: [
              Container(
                width: 72, height: 72,
                decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.15), shape: BoxShape.circle),
                child: const Icon(Icons.shield, size: 40, color: Colors.white),
              ),
              const SizedBox(height: 12),
              Text('GuardianLink', style: GoogleFonts.inter(fontSize: 24, fontWeight: FontWeight.w700, color: Colors.white)),
              Text('Safety Network v1.0.0', style: GoogleFonts.inter(fontSize: 13, color: Colors.white70)),
              const SizedBox(height: 8),
              Text('Protecting families, empowering communities', textAlign: TextAlign.center, style: GoogleFonts.inter(fontSize: 12, color: Colors.white60, height: 1.4)),
            ]),
          ),
          const SizedBox(height: 24),
          _sectionLabel('How It Works'),
          _faqItem('What is GuardianLink?', 'GuardianLink is a safety network app that connects family members, community volunteers, and first responders to ensure rapid emergency response.'),
          _faqItem('How does SOS work?', 'Press and hold the SOS button for 3 seconds. Your location is immediately shared with your guardian and nearby volunteers who can respond within minutes.'),
          _faqItem('Who are the volunteers?', 'Volunteers are community members who have passed background checks and verified their identity through our onboarding process.'),
          _faqItem('Is my location always shared?', 'Location sharing is only active when the app is open or when you enable background tracking. You can turn it off anytime.'),
          _faqItem('How do I add family members?', 'Go to Family Dashboard > Add Member. Share the invite code with your family member who can then link their account to yours.'),
          const SizedBox(height: 16),
          _sectionLabel('Contact & Support'),
          _contactTile(Icons.email_outlined, 'Email Support', 'support@guardianlink.in'),
          _contactTile(Icons.phone_outlined, 'Emergency Helpline', '1800-XXX-XXXX (Toll Free)'),
          _contactTile(Icons.chat_outlined, 'Live Chat', 'Available 9 AM – 9 PM IST'),
          const SizedBox(height: 16),
          _sectionLabel('Legal'),
          _navRow('Privacy Policy', () {}),
          _navRow('Terms of Service', () {}),
          _navRow('Data Deletion Policy', () {}),
          const SizedBox(height: 24),
          Center(child: Column(children: [
            Text('Made with ❤️ in India', style: GoogleFonts.inter(fontSize: 13, color: AppColors.onSurfaceVariant)),
            const SizedBox(height: 4),
            Text('© 2024 GuardianLink Inc. All rights reserved.', style: GoogleFonts.inter(fontSize: 11, color: AppColors.outline)),
          ])),
          const SizedBox(height: 24),
        ]),
      ),
    );
  }

  Widget _sectionLabel(String t) => Padding(
    padding: const EdgeInsets.only(bottom: 10),
    child: Text(t, style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.primary, letterSpacing: 0.5)),
  );

  Widget _faqItem(String q, String a) => Container(
    margin: const EdgeInsets.only(bottom: 8),
    decoration: BoxDecoration(color: AppColors.surfaceContainerHigh, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.outlineVariant.withValues(alpha: 0.4))),
    child: Theme(
      data: ThemeData(dividerColor: Colors.transparent),
      child: ExpansionTile(
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(12))),
        collapsedShape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(12))),
        tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
        iconColor: AppColors.primary,
        collapsedIconColor: AppColors.onSurfaceVariant,
        title: Text(q, style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w500, color: AppColors.onSurface)),
        children: [Text(a, style: GoogleFonts.inter(fontSize: 13, color: AppColors.onSurfaceVariant, height: 1.5))],
      ),
    ),
  );

  Widget _contactTile(IconData icon, String title, String subtitle) => Container(
    margin: const EdgeInsets.only(bottom: 8),
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(color: AppColors.surfaceContainerHigh, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.outlineVariant.withValues(alpha: 0.4))),
    child: Row(children: [
      Container(padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: AppColors.primaryContainer.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(10)), child: Icon(icon, size: 20, color: AppColors.primary)),
      const SizedBox(width: 12),
      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(title, style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.onSurface)),
        Text(subtitle, style: GoogleFonts.inter(fontSize: 12, color: AppColors.onSurfaceVariant)),
      ]),
    ]),
  );

  Widget _navRow(String title, VoidCallback onTap) => GestureDetector(
    onTap: onTap,
    child: Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(color: AppColors.surfaceContainerHigh, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.outlineVariant.withValues(alpha: 0.4))),
      child: Row(children: [
        Expanded(child: Text(title, style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w500, color: AppColors.onSurface))),
        const Icon(Icons.chevron_right, size: 18, color: AppColors.outline),
      ]),
    ),
  );
}
