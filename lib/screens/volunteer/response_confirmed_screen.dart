import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/app_colors.dart';
import '../../widgets/guardian_button.dart';

class ResponseConfirmedScreen extends StatefulWidget {
  const ResponseConfirmedScreen({super.key});
  @override
  State<ResponseConfirmedScreen> createState() => _ResponseConfirmedScreenState();
}

class _ResponseConfirmedScreenState extends State<ResponseConfirmedScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _scale;
  late Animation<double> _fade;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 700));
    _scale = Tween<double>(begin: 0.4, end: 1.0).animate(CurvedAnimation(parent: _ctrl, curve: Curves.elasticOut));
    _fade = CurvedAnimation(parent: _ctrl, curve: Curves.easeIn);
    _ctrl.forward();
  }

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: FadeTransition(
            opacity: _fade,
            child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
              ScaleTransition(
                scale: _scale,
                child: Container(
                  width: 140, height: 140,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: const LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [Color(0xFF15803D), Color(0xFF16A34A)]),
                    boxShadow: [BoxShadow(color: Colors.green.withValues(alpha: 0.5), blurRadius: 30, spreadRadius: 8)],
                  ),
                  child: const Icon(Icons.check_rounded, size: 72, color: Colors.white),
                ),
              ),
              const SizedBox(height: 32),
              Text('Incident Resolved!', style: GoogleFonts.inter(fontSize: 28, fontWeight: FontWeight.w700, color: AppColors.onSurface)),
              const SizedBox(height: 8),
              Text('Thank you for keeping the community safe.', textAlign: TextAlign.center, style: GoogleFonts.inter(fontSize: 14, color: AppColors.onSurfaceVariant, height: 1.5)),
              const SizedBox(height: 40),
              // Summary card
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(color: AppColors.surfaceContainerHigh, borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.green.withValues(alpha: 0.3))),
                child: const Column(children: [
                  _SummaryRow(icon: Icons.timer_outlined, label: 'Response Time', value: '8 min 34 sec', color: AppColors.primary),
                  Divider(color: AppColors.outlineVariant, height: 24),
                  _SummaryRow(icon: Icons.location_on_outlined, label: 'Incident Location', value: 'Connaught Place', color: AppColors.tertiary),
                  Divider(color: AppColors.outlineVariant, height: 24),
                  _SummaryRow(icon: Icons.person_outline, label: 'Person Assisted', value: 'Arjun Sharma', color: AppColors.onSurface),
                  Divider(color: AppColors.outlineVariant, height: 24),
                  _SummaryRow(icon: Icons.star_outline, label: 'Impact Points Earned', value: '+50 pts', color: Colors.amber),
                ]),
              ),
              const SizedBox(height: 24),
              // Rating prompt
              Text('Rate your experience', style: GoogleFonts.inter(fontSize: 14, color: AppColors.onSurfaceVariant)),
              const SizedBox(height: 12),
              Row(mainAxisAlignment: MainAxisAlignment.center, children: List.generate(5, (i) => GestureDetector(
                onTap: () {},
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: Icon(i < 4 ? Icons.star : Icons.star_border, color: Colors.amber, size: 32),
                ),
              ))),
              const SizedBox(height: 40),
              GuardianButton(label: 'Back to Dashboard', icon: Icons.home_outlined, onPressed: () => context.go('/volunteer/active-alerts')),
              const SizedBox(height: 12),
              GuardianButton(label: 'View Response History', outlined: true, onPressed: () => context.go('/volunteer/response-history')),
            ]),
          ),
        ),
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  final IconData icon;
  final String label, value;
  final Color color;
  const _SummaryRow({required this.icon, required this.label, required this.value, required this.color});
  @override
  Widget build(BuildContext context) => Row(children: [
    Icon(icon, size: 18, color: AppColors.onSurfaceVariant),
    const SizedBox(width: 10),
    Expanded(child: Text(label, style: GoogleFonts.inter(fontSize: 13, color: AppColors.onSurfaceVariant))),
    Text(value, style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w700, color: color)),
  ]);
}
