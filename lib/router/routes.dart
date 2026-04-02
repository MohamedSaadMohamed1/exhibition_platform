/// Route names and paths
abstract class AppRoutes {
  // Auth routes
  static const String splash = '/';
  static const String login = '/login';
  static const String signup = '/signup';
  static const String otp = '/otp';
  static const String completeProfile = '/complete-profile';
  static const String requestAccount = '/request-account';

  // Main routes (Visitor/Home)
  static const String home = '/home';

  // Admin routes
  static const String adminDashboard = '/admin/dashboard';
  static const String adminUsers = '/admin/users';
  static const String adminCreateOrganizer = '/admin/create-organizer';
  static const String adminCreateSupplier = '/admin/create-supplier';
  static const String adminAccountRequests = '/admin/account-requests';
  static const String adminOrders = '/admin/orders';
  static const String adminBookings = '/admin/bookings';
  static const String adminEvents = '/admin/events';
  static const String adminEditEvent = '/admin/events/:eventId/edit';

  // Owner routes
  static const String ownerDashboard = '/owner/dashboard';
  static const String ownerUsers = '/owner/users';
  static const String ownerExhibitions = '/owner/exhibitions';
  static const String ownerSuppliers = '/owner/suppliers';
  static const String ownerAnalytics = '/owner/analytics';

  // Organizer routes
  static const String organizerDashboard = '/organizer/dashboard';
  static const String organizerExhibitions = '/organizer/exhibitions';
  static const String organizerCreateExhibition = '/organizer/exhibitions/create';
  static const String organizerEditExhibition = '/organizer/exhibitions/:exhibitionId/edit';
  static const String organizerExhibitionDetail = '/organizer/exhibitions/:exhibitionId';
  static const String organizerBooths = '/organizer/exhibitions/:exhibitionId/booths';
  static const String organizerBookings = '/organizer/bookings';
  static const String organizerJobs = '/organizer/jobs';
  static const String organizerSuppliers = '/organizer/suppliers';
  static const String organizerBookSupplier = '/organizer/suppliers/book/:supplierId';

  static String organizerBookSupplierPath(String supplierId) =>
      '/organizer/suppliers/book/$supplierId';

  // Supplier routes
  static const String supplierDashboard = '/supplier/dashboard';
  static const String supplierServices = '/supplier/services';
  static const String supplierOrders = '/supplier/orders';
  static const String supplierProfile = '/supplier/profile';
  static const String supplierBusinessSettings = '/supplier/business-settings';

  // Visitor routes (exhibitions, events, services, etc.)
  static const String exhibitions = '/exhibitions';
  static const String exhibitionDetail = '/exhibitions/:exhibitionId';
  static const String exhibitionBooths = '/exhibitions/:exhibitionId/booths';
  static const String boothDetail = '/exhibitions/:exhibitionId/booths/:boothId';
  static const String events = '/events';
  static const String eventDetail = '/events/:eventId';
  static const String eventBooths = '/events/:eventId/booths';
  static const String myBookings = '/my-bookings';
  static const String bookingDetail = '/bookings/:bookingId';
  static const String myOrders = '/my-orders';

  // Services & Suppliers (for visitors)
  static const String suppliers = '/suppliers';
  static const String supplierDetail = '/suppliers/:supplierId';
  static const String services = '/services';
  static const String serviceDetail = '/services/:serviceId';

  // Orders
  static const String orders = '/orders';
  static const String orderDetail = '/orders/:orderId';

  // Chat routes
  static const String chats = '/chats';
  static const String chat = '/chats/:chatId';

  // Jobs routes
  static const String jobs = '/jobs';
  static const String jobDetail = '/jobs/:jobId';
  static const String jobApplications = '/jobs/:jobId/applications';

  // Profile routes
  static const String profile = '/profile';
  static const String editProfile = '/profile/edit';
  static const String settings = '/settings';

  // Interested events
  static const String interestedEvents = '/interested-events';

  // Notifications
  static const String notifications = '/notifications';
}
