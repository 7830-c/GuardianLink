import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../theme/app_colors.dart';

class SosAlertProgressScreen extends StatefulWidget {
  const SosAlertProgressScreen({super.key});
  @override
  State<SosAlertProgressScreen> createState() => _SosAlertProgressScreenState();
}

class _SosAlertProgressScreenState extends State<SosAlertProgressScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _pulse;
  int _step = 0;
  final List<String> _steps = [
    'Capturing location...',
    'Contacting guardians...',
    'Alerting nearby volunteers...',
    'Alert dispatched successfully!',
  ];

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 900))..repeat(reverse: true);
    _pulse = Tween<double>(begin: 0.9, end: 1.1).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut));
    _runSteps();
  }

  void _runSteps() async {
    for (int i = 0; i < _steps.length; i++) {
      await Future.delayed(const Duration(milliseconds: 1200));
      if (mounted) setState(() => _step = i);
    }
  }

  Future<void> _clearEmergencyAlert() async {
    final user = FirebaseAuth.instance.currentUser;
    try {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(child: CircularProgressIndicator(color: Colors.white)),
      );

      var collection = FirebaseFirestore.instance.collection('alerts');
      var snapshot = await collection.where('status', isEqualTo: 'urgent').get();

      for (var doc in snapshot.docs) {
        await doc.reference.delete();
      }

      if (user != null) {
        await FirebaseFirestore.instance.collection('users').doc(user.uid).update({
          'isEmergency': false,
        });
      }

      if (!mounted) return;
      Navigator.pop(context); 
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('All emergency alerts cleared!'), backgroundColor: Colors.green),
      );
      context.go('/loved-one/home');
    } catch (e) {
      if (mounted) Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to clear: $e'), backgroundColor: Colors.red),
      );
    }
  }

  @override
  void dispose() { 
    _ctrl.dispose(); 
    super.dispose(); 
  }

  @override
  Widget build(BuildContext context) {
    final done = _step >= _steps.length - 1;
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // FIXED AnimatedBuilder HERE
              AnimatedBuilder(
                animation: _pulse,
                builder: (BuildContext context, Widget? child) {
                  return Transform.scale(
                    scale: done ? 1.0 : _pulse.value,
                    child: Container(
                      width: 160, height: 160,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: RadialGradient(colors: done
                            ? [const Color(0xFF16A34A), const Color(0xFF15803D)]
                            : [AppColors.sosRed, const Color(0xFF9B1C1C)]),
                        boxShadow: [BoxShadow(
                          color: (done ? Colors.green : AppColors.sosRed).withOpacity(0.5),
                          blurRadius: 30, spreadRadius: 8,
                        )],
                      ),
                      child: Icon(done ? Icons.check_circle : Icons.sos,
                          color: Colors.white, size: 72),
                    ),
                  );
                },
              ),
              const SizedBox(height: 40),
              Text(
                done ? 'Help is on the way!' : 'Sending SOS Alert',
                style: GoogleFonts.inter(fontSize: 24, fontWeight: FontWeight.w700, color: AppColors.onSurface),
              ),
              const SizedBox(height: 32),
              ...List.generate(_steps.length, (i) => _StepRow(
                label: _steps[i],
                status: i < _step ? 'done' : i == _step ? 'active' : 'pending',
              )),
              const SizedBox(height: 40),
              if (done) ...[
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceContainerHigh,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.outlineVariant.withOpacity(0.5)),
                  ),
                  child: const Column(children: [
                    _InfoRow(icon: Icons.people, label: '3 Volunteers Notified'),
                    SizedBox(height: 8),
                    _InfoRow(icon: Icons.family_restroom, label: 'Guardian Notified'),
                    SizedBox(height: 8),
                    _InfoRow(icon: Icons.location_on, label: 'Location Shared: Connaught Place'),
                  ]),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => context.go('/loved-one/home'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryContainer,
                      foregroundColor: AppColors.onPrimaryContainer,
                      minimumSize: const Size(double.infinity, 52),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    child: Text('Go to Home', style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
                  ),
                ),
              ],
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: _clearEmergencyAlert,
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: done ? Colors.green : AppColors.secondary),
                    foregroundColor: done ? Colors.green : AppColors.secondary,
                    minimumSize: const Size(double.infinity, 52),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  child: Text(done ? 'Clear Alert' : 'Cancel Alert', style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StepRow extends StatelessWidget {
  final String label;
  final String status;
  const _StepRow({required this.label, required this.status});
  @override
  Widget build(BuildContext context) {
    Color c = status == 'done' ? Colors.green : status == 'active' ? AppColors.primary : AppColors.outline;
    IconData ic = status == 'done' ? Icons.check_circle : status == 'active' ? Icons.radio_button_checked : Icons.radio_button_unchecked;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(children: [
        Icon(ic, color: c, size: 20),
        const SizedBox(width: 12),
        Text(label, style: GoogleFonts.inter(fontSize: 14, color: c)),
      ]),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  const _InfoRow({required this.icon, required this.label});
  @override
  Widget build(BuildContext context) => Row(children: [
    Icon(icon, size: 16, color: AppColors.onSurfaceVariant),
    const SizedBox(width: 8),
    Text(label, style: GoogleFonts.inter(fontSize: 13, color: AppColors.onSurface)),
  ]);
}