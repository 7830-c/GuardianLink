import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_colors.dart';

class RoleSelectionScreen extends StatefulWidget {
  const RoleSelectionScreen({super.key});

  @override
  State<RoleSelectionScreen> createState() => _RoleSelectionScreenState();
}

class _RoleSelectionScreenState extends State<RoleSelectionScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 800));
    _fadeAnim = CurvedAnimation(parent: _controller, curve: Curves.easeOut);
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF0D1B3E), AppColors.background],
          ),
        ),
        child: SafeArea(
          child: FadeTransition(
            opacity: _fadeAnim,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 40),
                  // Header
                  Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFF1E40AF), Color(0xFF3755C3)],
                          ),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(Icons.shield, size: 22, color: Colors.white),
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('GuardianLink',
                              style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.onSurface)),
                          Text('Safety Network',
                              style: GoogleFonts.inter(fontSize: 11, color: AppColors.onSurfaceVariant, letterSpacing: 1.5)),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 48),
                  Text(
                    'Welcome.\nSelect your role.',
                    style: GoogleFonts.inter(fontSize: 32, fontWeight: FontWeight.w700, color: AppColors.onSurface, height: 1.2),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Choose how you\'ll be using the app today.',
                    style: GoogleFonts.inter(fontSize: 14, color: AppColors.onSurfaceVariant),
                  ),
                  const SizedBox(height: 40),
                  // Role Cards
                  _RoleCard(
                    icon: Icons.family_restroom,
                    title: 'Family / Guardian',
                    subtitle: 'Monitor your loved ones and manage family safety',
                    color: AppColors.primary,
                    containerColor: AppColors.primaryContainer,
                    onTap: () => context.go('/family/login'),
                  ),
                  const SizedBox(height: 16),
                  _RoleCard(
                    icon: Icons.child_care,
                    title: 'Child / Member',
                    subtitle: 'Stay connected and trigger SOS alerts when needed',
                    color: AppColors.tertiary,
                    containerColor: AppColors.tertiaryContainer,
                    onTap: () => context.go('/child/login'),
                  ),
                  const SizedBox(height: 16),
                  _RoleCard(
                    icon: Icons.volunteer_activism,
                    title: 'Volunteer Responder',
                    subtitle: 'Respond to emergency alerts in your community',
                    color: AppColors.secondary,
                    containerColor: AppColors.secondaryContainer,
                    onTap: () => context.go('/volunteer/login'),
                  ),
                  const SizedBox(height: 16),
                  _RoleCard(
                    icon: Icons.local_police,
                    title: 'Law Enforcement',
                    subtitle: 'Police and emergency command center access',
                    color: AppColors.primary,
                    containerColor: AppColors.primaryContainer,
                    onTap: () => context.go('/police/login'),
                  ),
                  const Spacer(),
                  Center(
                    child: Text(
                      'GuardianLink v1.0 • Sentinel Safety System',
                      style: GoogleFonts.inter(fontSize: 11, color: AppColors.outline),
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _RoleCard extends StatefulWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final Color containerColor;
  final VoidCallback onTap;

  const _RoleCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.containerColor,
    required this.onTap,
  });

  @override
  State<_RoleCard> createState() => _RoleCardState();
}

class _RoleCardState extends State<_RoleCard> with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 100));
    _scale = Tween<double>(begin: 1, end: 0.97).animate(_ctrl);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _scale,
      child: GestureDetector(
        onTapDown: (_) => _ctrl.forward(),
        onTapUp: (_) { _ctrl.reverse(); widget.onTap(); },
        onTapCancel: () => _ctrl.reverse(),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppColors.surfaceContainerHigh,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: widget.color.withValues(alpha: 0.3)),
          ),
          child: Row(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: widget.containerColor.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(widget.icon, size: 28, color: widget.color),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(widget.title,
                        style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.onSurface)),
                    const SizedBox(height: 4),
                    Text(widget.subtitle,
                        style: GoogleFonts.inter(fontSize: 12, color: AppColors.onSurfaceVariant, height: 1.4)),
                  ],
                ),
              ),
              Icon(Icons.arrow_forward_ios, size: 16, color: widget.color),
            ],
          ),
        ),
      ),
    );
  }
}
