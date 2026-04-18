import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../core/constants/enums.dart';
import '../core/utils/logger.dart';
import '../shared/models/supplier_model.dart';
import '../shared/providers/providers.dart';
import '../features/auth/presentation/providers/auth_provider.dart';
import 'routes.dart';

// Import screens (placeholders - will be created)
import '../features/auth/presentation/screens/splash_screen.dart';
import '../features/auth/presentation/screens/login_screen.dart';
import '../features/auth/presentation/screens/signup_screen.dart';
import '../features/auth/presentation/screens/otp_screen.dart';
import '../features/auth/presentation/screens/complete_profile_screen.dart';
import '../features/auth/presentation/screens/request_account_screen.dart';
import '../features/admin/presentation/screens/admin_dashboard_screen.dart';
import '../features/admin/presentation/screens/admin_users_screen.dart';
import '../features/admin/presentation/screens/create_organizer_screen.dart';
import '../features/admin/presentation/screens/create_supplier_screen.dart';
import '../features/admin/presentation/screens/admin_account_requests_screen.dart';
import '../features/admin/presentation/screens/admin_orders_screen.dart';
import '../features/admin/presentation/screens/admin_bookings_screen.dart';
import '../features/admin/presentation/screens/admin_events_screen.dart';
import '../features/admin/presentation/screens/admin_edit_event_screen.dart';
import '../features/admin/presentation/screens/admin_job_applications_screen.dart';
import '../features/admin/presentation/screens/admin_jobs_screen.dart';
import '../features/owner/presentation/screens/owner_dashboard_screen.dart';
import '../features/organizer/presentation/screens/organizer_dashboard_screen.dart';
import '../features/organizer/presentation/screens/create_exhibition_screen.dart';
import '../features/organizer/presentation/screens/manage_booths_screen.dart';
import '../features/organizer/presentation/screens/create_booth_screen.dart';
import '../features/organizer/presentation/screens/edit_booth_screen.dart';
import '../features/organizer/presentation/screens/organizer_suppliers_screen.dart';
import '../features/organizer/presentation/screens/book_supplier_screen.dart';
import '../features/supplier/presentation/screens/supplier_dashboard_screen.dart';
import '../features/supplier/presentation/screens/business_settings_screen.dart';
import '../features/home/presentation/screens/home_screen.dart';
import '../features/events/presentation/screens/events_screen.dart';
import '../features/events/presentation/screens/event_detail_screen.dart';
import '../features/booths/presentation/screens/booths_screen.dart';
import '../features/bookings/presentation/screens/my_bookings_screen.dart';
import '../features/chat/presentation/screens/chats_screen.dart';
import '../features/chat/presentation/screens/chat_screen.dart';
import '../features/profile/presentation/screens/profile_screen.dart';
import '../features/profile/presentation/screens/edit_profile_screen.dart';
import '../features/interested/presentation/screens/interested_events_screen.dart';
import '../features/suppliers/presentation/screens/suppliers_screen.dart';
import '../features/suppliers/presentation/screens/supplier_detail_screen.dart';
import '../features/jobs/presentation/screens/jobs_screen.dart';
import '../features/jobs/presentation/screens/job_detail_screen.dart';
import '../features/orders/presentation/screens/my_orders_screen.dart';
import '../features/services/presentation/screens/services_screen.dart';
import '../features/services/presentation/screens/service_detail_screen.dart';
import '../features/notifications/presentation/screens/notifications_screen.dart';

/// GoRouter provider with role-based guards
final goRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: AppRoutes.splash,

    // // TESTING: Direct to organizer dashboard without auth
    // initialLocation: AppRoutes.organizerDashboard,
    debugLogDiagnostics: true,
    refreshListenable: RouterRefreshNotifier(ref),
    redirect: (context, state) {
      // // TESTING: Disable all auth checks temporarily
      // return null;

      final authState = ref.read(authNotifierProvider);
      AppLogger.info('🔀 Router redirect: path=${state.matchedLocation}, authStatus=${authState.status}', tag: 'Router');

      final isAuthenticated = authState.status == AuthStatus.authenticated;
      final isProfileIncomplete = authState.status == AuthStatus.profileIncomplete;
      final isAuthRoute = state.matchedLocation == AppRoutes.login ||
          state.matchedLocation == AppRoutes.signup ||
          state.matchedLocation == AppRoutes.otp ||
          state.matchedLocation == AppRoutes.requestAccount ||
          state.matchedLocation == AppRoutes.splash;

      // If profile incomplete, redirect to complete profile
      if (isProfileIncomplete && state.matchedLocation != AppRoutes.completeProfile) {
        AppLogger.info('🔀 Router: Redirecting to complete profile', tag: 'Router');
        return AppRoutes.completeProfile;
      }

      // If not authenticated and not on auth route, redirect to login
      if (!isAuthenticated && !isAuthRoute && !isProfileIncomplete) {
        AppLogger.info('🔀 Router: Not authenticated, redirecting to login', tag: 'Router');
        return AppRoutes.login;
      }

      // If authenticated and on auth route, redirect to appropriate home
      if (isAuthenticated && isAuthRoute) {
        final homeRoute = _getHomeRoute(authState.user?.role);
        AppLogger.info('🔀 Router: Authenticated on auth route, redirecting to $homeRoute', tag: 'Router');
        return homeRoute;
      }

      // Role-based route protection
      if (isAuthenticated && authState.user != null) {
        final role = authState.user!.role;
        final path = state.matchedLocation;

        // Admin routes - only admin can access
        if (path.startsWith('/admin') && !role.isAdmin) {
          return _getHomeRoute(role);
        }

        // Owner routes - only owner and admin can access
        if (path.startsWith('/owner') && !role.isOwner && !role.isAdmin) {
          return _getHomeRoute(role);
        }

        // Organizer routes - only organizer, owner, and admin can access
        if (path.startsWith('/organizer') &&
            !role.isOrganizer &&
            !role.isOwner &&
            !role.isAdmin) {
          return _getHomeRoute(role);
        }

        // Supplier routes - only supplier can access their dashboard
        if (path.startsWith('/supplier/dashboard') && !role.isSupplier) {
          return _getHomeRoute(role);
        }
      }

      return null;
    },
    routes: [
      // Splash
      GoRoute(
        path: AppRoutes.splash,
        builder: (context, state) => const SplashScreen(),
      ),

      // Auth Routes
      GoRoute(
        path: AppRoutes.login,
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: AppRoutes.signup,
        builder: (context, state) => const SignupScreen(),
      ),
      GoRoute(
        path: AppRoutes.otp,
        builder: (context, state) => const OtpScreen(),
      ),
      GoRoute(
        path: AppRoutes.completeProfile,
        builder: (context, state) => const CompleteProfileScreen(),
      ),
      GoRoute(
        path: AppRoutes.requestAccount,
        builder: (context, state) => const RequestAccountScreen(),
      ),

      // Home Route
      GoRoute(
        path: AppRoutes.home,
        builder: (context, state) => const HomeScreen(),
      ),

      // Admin Routes
      GoRoute(
        path: AppRoutes.adminDashboard,
        builder: (context, state) => const AdminDashboardScreen(),
      ),
      GoRoute(
        path: AppRoutes.adminUsers,
        builder: (context, state) => const AdminUsersScreen(),
      ),
      GoRoute(
        path: AppRoutes.adminCreateOrganizer,
        builder: (context, state) => const CreateOrganizerScreen(),
      ),
      GoRoute(
        path: AppRoutes.adminCreateSupplier,
        builder: (context, state) => const CreateSupplierScreen(),
      ),
      GoRoute(
        path: AppRoutes.adminAccountRequests,
        builder: (context, state) => const AdminAccountRequestsScreen(),
      ),
      GoRoute(
        path: AppRoutes.adminOrders,
        builder: (context, state) => const AdminOrdersScreen(),
      ),
      GoRoute(
        path: AppRoutes.adminBookings,
        builder: (context, state) => const AdminBookingsScreen(),
      ),
      GoRoute(
        path: AppRoutes.adminEvents,
        builder: (context, state) => const AdminEventsScreen(),
      ),
      GoRoute(
        path: AppRoutes.adminEditEvent,
        builder: (context, state) {
          final eventId = state.pathParameters['eventId']!;
          return AdminEditEventScreen(eventId: eventId);
        },
      ),
      GoRoute(
        path: AppRoutes.adminJobApplications,
        builder: (context, state) => const AdminJobApplicationsScreen(),
      ),
      GoRoute(
        path: AppRoutes.adminJobs,
        builder: (context, state) => const AdminJobsScreen(),
      ),

      // Owner Routes
      GoRoute(
        path: AppRoutes.ownerDashboard,
        builder: (context, state) => const OwnerDashboardScreen(),
      ),

      // Organizer Routes
      GoRoute(
        path: AppRoutes.organizerDashboard,
        builder: (context, state) => const OrganizerDashboardScreen(),
      ),
      GoRoute(
        path: AppRoutes.organizerCreateExhibition,
        builder: (context, state) => const CreateExhibitionScreen(),
      ),
      GoRoute(
        path: '/organizer/events/:eventId/manage-booths',
        builder: (context, state) {
          final eventId = state.pathParameters['eventId']!;
          return ManageBoothsScreen(eventId: eventId);
        },
      ),
      GoRoute(
        path: '/organizer/events/:eventId/booths/create',
        builder: (context, state) {
          final eventId = state.pathParameters['eventId']!;
          return CreateBoothScreen(eventId: eventId);
        },
      ),
      GoRoute(
        path: '/organizer/events/:eventId/booths/:boothId/edit',
        builder: (context, state) {
          final eventId = state.pathParameters['eventId']!;
          final boothId = state.pathParameters['boothId']!;
          return EditBoothScreen(eventId: eventId, boothId: boothId);
        },
      ),
      GoRoute(
        path: AppRoutes.organizerSuppliers,
        builder: (context, state) => const OrganizerSuppliersScreen(),
      ),
      GoRoute(
        path: AppRoutes.organizerBookSupplier,
        builder: (context, state) {
          final supplier = state.extra as SupplierModel;
          return BookSupplierScreen(supplier: supplier);
        },
      ),

      // Supplier Routes
      GoRoute(
        path: AppRoutes.supplierDashboard,
        builder: (context, state) => const SupplierDashboardScreen(),
      ),
      GoRoute(
        path: AppRoutes.supplierBusinessSettings,
        builder: (context, state) => const BusinessSettingsScreen(),
      ),

      // Events Routes (accessible to all authenticated users)
      GoRoute(
        path: AppRoutes.events,
        builder: (context, state) => const EventsScreen(),
      ),
      GoRoute(
        path: AppRoutes.eventDetail,
        builder: (context, state) {
          final eventId = state.pathParameters['eventId']!;
          return EventDetailScreen(eventId: eventId);
        },
      ),
      GoRoute(
        path: AppRoutes.eventBooths,
        builder: (context, state) {
          final eventId = state.pathParameters['eventId']!;
          return BoothsScreen(eventId: eventId);
        },
      ),

      // Booking Routes
      GoRoute(
        path: AppRoutes.myBookings,
        builder: (context, state) => const MyBookingsScreen(),
      ),

      // Chat Routes
      GoRoute(
        path: AppRoutes.chats,
        builder: (context, state) => const ChatsScreen(),
      ),
      GoRoute(
        path: AppRoutes.chat,
        builder: (context, state) {
          final chatId = state.pathParameters['chatId']!;
          return ChatScreen(chatId: chatId);
        },
      ),

      // Profile Routes
      GoRoute(
        path: AppRoutes.profile,
        builder: (context, state) => const ProfileScreen(),
      ),
      GoRoute(
        path: AppRoutes.editProfile,
        builder: (context, state) => const EditProfileScreen(),
      ),

      // Interested Events Route
      GoRoute(
        path: AppRoutes.interestedEvents,
        builder: (context, state) => const InterestedEventsScreen(),
      ),

      // Suppliers Routes
      GoRoute(
        path: AppRoutes.suppliers,
        builder: (context, state) => const SuppliersScreen(),
      ),
      GoRoute(
        path: AppRoutes.supplierDetail,
        builder: (context, state) {
          final supplierId = state.pathParameters['supplierId']!;
          return SupplierDetailScreen(supplierId: supplierId);
        },
      ),

      // Services Routes
      GoRoute(
        path: AppRoutes.services,
        builder: (context, state) => const ServicesScreen(),
      ),
      GoRoute(
        path: AppRoutes.serviceDetail,
        builder: (context, state) {
          final serviceId = state.pathParameters['serviceId']!;
          return ServiceDetailScreen(serviceId: serviceId);
        },
      ),

      // Jobs Routes
      GoRoute(
        path: AppRoutes.jobs,
        builder: (context, state) => const JobsScreen(),
      ),
      GoRoute(
        path: AppRoutes.jobDetail,
        builder: (context, state) {
          final jobId = state.pathParameters['jobId']!;
          return JobDetailScreen(jobId: jobId);
        },
      ),

      // Orders Routes
      GoRoute(
        path: AppRoutes.myOrders,
        builder: (context, state) => const MyOrdersScreen(),
      ),

      // Notifications Route
      GoRoute(
        path: AppRoutes.notifications,
        builder: (context, state) => const NotificationsScreen(),
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text('Page not found: ${state.matchedLocation}'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => context.go(AppRoutes.events),
              child: const Text('Go Home'),
            ),
          ],
        ),
      ),
    ),
  );
});

/// Get home route based on role
String _getHomeRoute(UserRole? role) {
  switch (role) {
    case UserRole.admin:
      return AppRoutes.adminDashboard;
    case UserRole.owner:
      return AppRoutes.ownerDashboard;
    case UserRole.organizer:
      return AppRoutes.organizerDashboard;
    case UserRole.supplier:
      return AppRoutes.supplierDashboard;
    case UserRole.visitor:
    default:
      return AppRoutes.home;
  }
}

/// Router refresh notifier for auth state changes
class RouterRefreshNotifier extends ChangeNotifier {
  RouterRefreshNotifier(this._ref) {
    _ref.listen(authNotifierProvider, (previous, next) {
      AppLogger.info('🔄 RouterRefreshNotifier: auth state changed ${previous?.status} -> ${next.status}', tag: 'Router');
      notifyListeners();
    });
  }

  final Ref _ref;
}
