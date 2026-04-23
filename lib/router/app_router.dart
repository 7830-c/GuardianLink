import 'package:go_router/go_router.dart';
import '../screens/splash_screen.dart';
import '../screens/error_screen.dart';
import '../screens/role_selection_screen.dart';
import '../screens/child/child_login_screen.dart';
import '../screens/child/child_registration_screen.dart';
import '../screens/child/child_home_screen.dart';
import '../screens/child/sos_alert_progress_screen.dart';
import '../screens/family/family_login_screen.dart';
import '../screens/family/family_registration_screen.dart';
import '../screens/family/family_dashboard_screen.dart';
import '../screens/family/family_tracking_screen.dart';
import '../screens/family/family_settings_screen.dart';
import '../screens/family/family_profile_screen.dart';
import '../screens/family/family_profile_management_screen.dart';
import '../screens/family/alert_history_screen.dart';
import '../screens/family/emergency_alert_view_screen.dart';
import '../screens/volunteer/volunteer_login_screen.dart';
import '../screens/volunteer/volunteer_registration_screen.dart';
import '../screens/volunteer/active_alerts_screen.dart';
import '../screens/volunteer/incident_response_detail_screen.dart';
import '../screens/volunteer/response_confirmed_screen.dart';
import '../screens/volunteer/response_history_screen.dart';
import '../screens/volunteer/volunteer_profile_screen.dart';
import '../screens/volunteer/volunteer_settings_screen.dart';
import '../screens/volunteer/incident_acknowledged_screen.dart';
import '../screens/police/police_login_screen.dart';
import '../screens/police/police_registration_screen.dart';
import '../screens/police/police_command_center_screen.dart';
import '../screens/police/incident_command_view_screen.dart';
import '../screens/police/police_settings_screen.dart';
import '../screens/police/police_incident_archive_screen.dart';
import '../screens/police/officer_profile_screen.dart';
import '../screens/common/live_tracking_screen.dart';
import '../screens/common/incident_history_screen.dart';
import '../screens/common/profile_management_screen.dart';
import '../screens/common/app_settings_screen.dart';
import '../screens/common/help_about_screen.dart';

class AppRouter {
  static final GoRouter router = GoRouter(
    initialLocation: '/splash',
    errorBuilder: (context, state) => const ErrorScreen(),
    routes: [
      GoRoute(path: '/splash', builder: (c, s) => const SplashScreen()),
      GoRoute(path: '/error', builder: (c, s) => const ErrorScreen()),
      GoRoute(path: '/role-selection', builder: (c, s) => const RoleSelectionScreen()),

      // Child Routes
      GoRoute(path: '/child/login', builder: (c, s) => const ChildLoginScreen()),
      GoRoute(path: '/child/register', builder: (c, s) => const ChildRegistrationScreen()),
      GoRoute(path: '/child/home', builder: (c, s) => const ChildHomeScreen()),
      GoRoute(path: '/child/sos-progress', builder: (c, s) => const SosAlertProgressScreen()),

      // Family Routes
      GoRoute(path: '/family/login', builder: (c, s) => const FamilyLoginScreen()),
      GoRoute(path: '/family/register', builder: (c, s) => const FamilyRegistrationScreen()),
      GoRoute(path: '/family/dashboard', builder: (c, s) => const FamilyDashboardScreen()),
      GoRoute(path: '/family/tracking', builder: (c, s) => const FamilyTrackingScreen()),
      GoRoute(path: '/family/settings', builder: (c, s) => const FamilySettingsScreen()),
      GoRoute(path: '/family/profile', builder: (c, s) => const FamilyProfileScreen()),
      GoRoute(path: '/family/profile-management', builder: (c, s) => const FamilyProfileManagementScreen()),
      GoRoute(path: '/family/alert-history', builder: (c, s) => const AlertHistoryScreen()),
      GoRoute(path: '/family/emergency-alert', builder: (c, s) => const EmergencyAlertViewScreen()),

      // Volunteer Routes
      GoRoute(path: '/volunteer/login', builder: (c, s) => const VolunteerLoginScreen()),
      GoRoute(path: '/volunteer/register', builder: (c, s) => const VolunteerRegistrationScreen()),
      GoRoute(path: '/volunteer/active-alerts', builder: (c, s) => const ActiveAlertsScreen()),
      GoRoute(path: '/volunteer/incident-detail', builder: (c, s) => const IncidentResponseDetailScreen()),
      GoRoute(path: '/volunteer/response-confirmed', builder: (c, s) => const ResponseConfirmedScreen()),
      GoRoute(path: '/volunteer/response-history', builder: (c, s) => const ResponseHistoryScreen()),
      GoRoute(path: '/volunteer/profile', builder: (c, s) => const VolunteerProfileScreen()),
      GoRoute(path: '/volunteer/settings', builder: (c, s) => const VolunteerSettingsScreen()),
      GoRoute(path: '/volunteer/incident-acknowledged', builder: (c, s) => const IncidentAcknowledgedScreen()),

      // Police Routes
      GoRoute(path: '/police/login', builder: (c, s) => const PoliceLoginScreen()),
      GoRoute(path: '/police/register', builder: (c, s) => const PoliceRegistrationScreen()),
      GoRoute(path: '/police/command-center', builder: (c, s) => const PoliceCommandCenterScreen()),
      GoRoute(path: '/police/incident-command-view', builder: (c, s) => const IncidentCommandViewScreen()),
      GoRoute(path: '/police/settings', builder: (c, s) => const PoliceSettingsScreen()),
      GoRoute(path: '/police/archive', builder: (c, s) => const PoliceIncidentArchiveScreen()),
      GoRoute(path: '/police/profile', builder: (c, s) => const OfficerProfileScreen()),

      // Common Routes
      GoRoute(path: '/live-tracking', builder: (c, s) => const LiveTrackingScreen()),
      GoRoute(path: '/incident-history', builder: (c, s) => const IncidentHistoryScreen()),
      GoRoute(path: '/profile', builder: (c, s) => const ProfileManagementScreen()),
      GoRoute(path: '/settings', builder: (c, s) => const AppSettingsScreen()),
      GoRoute(path: '/help', builder: (c, s) => const HelpAboutScreen()),
    ],
  );
}
