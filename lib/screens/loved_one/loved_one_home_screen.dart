import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/app_colors.dart';

class LovedOneHomeScreen extends StatefulWidget {
  const LovedOneHomeScreen({super.key});
  @override
  State<LovedOneHomeScreen> createState() => _LovedOneHomeScreenState();
}

class _LovedOneHomeScreenState extends State<LovedOneHomeScreen>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnim;
  late AnimationController _holdController;
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(vsync: this, duration: const Duration(milliseconds: 1500))..repeat(reverse: true);
    _pulseAnim = Tween<double>(begin: 0.95, end: 1.05).animate(CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut));
    
    _holdController = AnimationController(vsync: this, duration: const Duration(seconds: 3));
    _holdController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _holdController.reset();
        _showSOSDialog(context);
      }
    });
  }

  @override
  void dispose() { 
    _pulseController.dispose(); 
    _holdController.dispose();
    super.dispose(); 
  }

  void _onHoldStart() {
    _holdController.forward();
  }

  void _onHoldEnd() {
    if (_holdController.status != AnimationStatus.completed) {
      _holdController.reverse();
    }
  }

  void _onTap() {
    // Show a small hint that they need to hold the button
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Press and hold for 3 seconds to send SOS', style: GoogleFonts.inter()),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(children: [
              const CircleAvatar(radius: 20, backgroundColor: AppColors.surfaceContainerHigh, child: Icon(Icons.person, color: AppColors.onSurface, size: 22)),
              const SizedBox(width: 12),
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('Hello, Arjun 👋', style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.onSurface)),
                Text('You are safe & connected', style: GoogleFonts.inter(fontSize: 12, color: AppColors.tertiary)),
              ]),
              const Spacer(),
              Stack(children: [
                IconButton(icon: const Icon(Icons.notifications_outlined, color: AppColors.onSurface), onPressed: () {}),
                Positioned(top: 8, right: 8, child: Container(width: 8, height: 8, decoration: const BoxDecoration(color: AppColors.secondary, shape: BoxShape.circle))),
              ]),
            ]),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(color: AppColors.surfaceContainerHigh, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppColors.tertiary.withAlpha(77))),
                  child: Row(children: [
                    Container(width: 10, height: 10, decoration: const BoxDecoration(color: AppColors.tertiary, shape: BoxShape.circle)),
                    const SizedBox(width: 10),
                    Text('Location Sharing: Active', style: GoogleFonts.inter(fontSize: 13, color: AppColors.tertiary, fontWeight: FontWeight.w500)),
                    const Spacer(),
                    Text('Guardian Linked ✓', style: GoogleFonts.inter(fontSize: 12, color: AppColors.onSurfaceVariant)),
                  ]),
                ),
                const SizedBox(height: 32),
                GestureDetector(
                  onTap: _onTap, // Handle accidental taps
                  onLongPressStart: (_) => _onHoldStart(),
                  onLongPressEnd: (_) => _onHoldEnd(),
                  child: Stack(alignment: Alignment.center, children: [
                    // Outer pulse/rings
                    AnimatedBuilder(
                      animation: _pulseAnim,
                      builder: (_, __) => Stack(alignment: Alignment.center, children: [
                        ...List.generate(3, (i) => Container(
                          width: 200.0 + (i * 30), height: 200.0 + (i * 30),
                          decoration: BoxDecoration(shape: BoxShape.circle, color: AppColors.sosRed.withAlpha((10 * (3 - i)).toInt())),
                        )),
                      ]),
                    ),
                    // Hold progress indicator
                    AnimatedBuilder(
                      animation: _holdController,
                      builder: (_, __) => SizedBox(
                        width: 210, height: 210,
                        child: CircularProgressIndicator(
                          value: _holdController.value,
                          strokeWidth: 8,
                          color: Colors.white,
                          backgroundColor: Colors.transparent,
                        ),
                      ),
                    ),
                    // Main SOS Button
                    AnimatedBuilder(
                      animation: _pulseAnim,
                      builder: (_, __) => Transform.scale(
                        scale: _pulseAnim.value,
                        child: Container(
                          width: 180, height: 180,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: const RadialGradient(colors: [Color(0xFFDC2626), Color(0xFF9B1C1C)]),
                            boxShadow: [BoxShadow(color: AppColors.sosRed.withAlpha(128), blurRadius: 30, spreadRadius: 5)],
                          ),
                          child: Center(
                            child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                              Text('SOS', style: GoogleFonts.inter(fontSize: 36, fontWeight: FontWeight.w900, color: Colors.white, letterSpacing: 1.5)),
                              Text('Hold 3s', style: GoogleFonts.inter(fontSize: 12, color: Colors.white70, fontWeight: FontWeight.w500)),
                            ]),
                          ),
                        ),
                      ),
                    ),
                  ]),
                ),
                const SizedBox(height: 8),
                Text('Hold for 3 seconds to send emergency alert', textAlign: TextAlign.center, style: GoogleFonts.inter(fontSize: 11, color: AppColors.outline)),
                const SizedBox(height: 32),
                Row(children: [
                  Expanded(child: _QuickAction(icon: Icons.location_on_outlined, label: 'Share Location', color: AppColors.primary, onTap: () => context.push('/live-tracking'))),
                  const SizedBox(width: 12),
                  Expanded(child: _QuickAction(icon: Icons.phone, label: 'Call Guardian', color: AppColors.tertiary, onTap: () {})),
                  const SizedBox(width: 12),
                  Expanded(child: _QuickAction(icon: Icons.history, label: 'Alert History', color: AppColors.onSurfaceVariant, onTap: () => context.push('/family/alert-history'))),
                ]),
                const SizedBox(height: 24),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(color: AppColors.surfaceContainer, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppColors.outlineVariant.withAlpha(128))),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text('Your Guardians', style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.onSurface)),
                    const SizedBox(height: 12),
                    const _GuardianRow(name: 'Priya Sharma', relation: 'Mother', isOnline: true),
                    const SizedBox(height: 8),
                    const _GuardianRow(name: 'Raj Sharma', relation: 'Father', isOnline: false),
                  ]),
                ),
                const SizedBox(height: 24),
              ]),
            ),
          ),
        ]),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (i) {
          setState(() => _selectedIndex = i);
          if (i == 1) context.push('/live-tracking');
          if (i == 2) context.push('/profile');
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home_outlined), activeIcon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.location_on_outlined), activeIcon: Icon(Icons.location_on), label: 'Location'),
          BottomNavigationBarItem(icon: Icon(Icons.person_outline), activeIcon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }

  void _showSOSDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.surfaceContainerHigh,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(children: [
          const Icon(Icons.warning_amber_rounded, color: AppColors.secondary, size: 24),
          const SizedBox(width: 8),
          Text('Send SOS Alert?', style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.onSurface)),
        ]),
        content: Text('This will immediately alert your guardian and nearby volunteers with your current location.', style: GoogleFonts.inter(fontSize: 13, color: AppColors.onSurfaceVariant, height: 1.5)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text('Cancel', style: GoogleFonts.inter(color: AppColors.onSurfaceVariant))),
          ElevatedButton(
            onPressed: () { Navigator.pop(context); context.go('/loved-one/sos-progress'); },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.sosRed, foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
            child: Text('Send SOS', style: GoogleFonts.inter(fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }
}

class _QuickAction extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;
  const _QuickAction({required this.icon, required this.label, required this.color, required this.onTap});
  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Container(
      padding: const EdgeInsets.symmetric(vertical: 14),
      decoration: BoxDecoration(color: AppColors.surfaceContainerHigh, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.outlineVariant.withAlpha(128))),
      child: Column(children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(height: 6),
        Text(label, textAlign: TextAlign.center, style: GoogleFonts.inter(fontSize: 10, color: AppColors.onSurfaceVariant)),
      ]),
    ),
  );
}

class _GuardianRow extends StatelessWidget {
  final String name, relation;
  final bool isOnline;
  const _GuardianRow({required this.name, required this.relation, required this.isOnline});
  @override
  Widget build(BuildContext context) => Row(children: [
    Stack(children: [
      CircleAvatar(radius: 18, backgroundColor: AppColors.surfaceContainerHighest, child: Text(name[0], style: GoogleFonts.inter(fontWeight: FontWeight.w700, color: AppColors.primary))),
      if (isOnline) Positioned(bottom: 0, right: 0, child: Container(width: 10, height: 10, decoration: BoxDecoration(color: AppColors.tertiary, shape: BoxShape.circle, border: Border.all(color: AppColors.surfaceContainer, width: 1.5)))),
    ]),
    const SizedBox(width: 12),
    Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(name, style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.onSurface)),
      Text(relation, style: GoogleFonts.inter(fontSize: 11, color: AppColors.onSurfaceVariant)),
    ]),
    const Spacer(),
    Text(isOnline ? 'Online' : 'Offline', style: GoogleFonts.inter(fontSize: 11, color: isOnline ? AppColors.tertiary : AppColors.outline)),
  ]);
}
