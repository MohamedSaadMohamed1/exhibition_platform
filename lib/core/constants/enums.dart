/// User roles in the system
enum UserRole {
  visitor('visitor'),
  exhibitor('exhibitor'),
  supplier('supplier'),
  organizer('organizer'),
  owner('owner'),
  admin('admin');

  const UserRole(this.value);
  final String value;

  static UserRole fromString(String value) {
    return UserRole.values.firstWhere(
      (role) => role.value == value,
      orElse: () => UserRole.visitor,
    );
  }

  bool get isAdmin => this == UserRole.admin;
  bool get isOwner => this == UserRole.owner;
  bool get isOrganizer => this == UserRole.organizer;
  bool get isSupplier => this == UserRole.supplier;
  bool get isExhibitor => this == UserRole.exhibitor;
  bool get isVisitor => this == UserRole.visitor;

  /// Check if this role can manage users
  bool get canManageUsers => this == UserRole.admin || this == UserRole.owner;

  /// Check if this role can create events/exhibitions
  bool get canCreateEvents =>
      this == UserRole.admin ||
      this == UserRole.owner ||
      this == UserRole.organizer;

  /// Check if this role can manage suppliers
  bool get canManageSuppliers =>
      this == UserRole.admin ||
      this == UserRole.owner ||
      this == UserRole.supplier;

  /// Check if this role can book booths
  bool get canBookBooths => this == UserRole.visitor;

  /// Check if this role can post jobs
  bool get canPostJobs =>
      this == UserRole.admin ||
      this == UserRole.owner ||
      this == UserRole.organizer;

  /// Get display name
  String get displayName {
    switch (this) {
      case UserRole.visitor:
        return 'Visitor';
      case UserRole.exhibitor:
        return 'Exhibitor';
      case UserRole.supplier:
        return 'Supplier';
      case UserRole.organizer:
        return 'Organizer';
      case UserRole.owner:
        return 'Owner';
      case UserRole.admin:
        return 'Admin';
    }
  }

  /// Get home route for this role
  String get homeRoute {
    switch (this) {
      case UserRole.visitor:
        return '/home';
      case UserRole.exhibitor:
        return '/exhibitor/dashboard';
      case UserRole.supplier:
        return '/supplier/dashboard';
      case UserRole.organizer:
        return '/organizer/dashboard';
      case UserRole.owner:
        return '/owner/dashboard';
      case UserRole.admin:
        return '/admin/dashboard';
    }
  }
}

/// Supplier sort options
enum SupplierSortBy {
  name,
  rating,
  reviewCount,
  ordersCount,
  createdAt,
}

/// Service sort options
enum ServiceSortBy {
  name,
  price,
  rating,
  createdAt,
}

/// Job sort options
enum JobSortBy {
  deadline,
  salary,
  createdAt,
  title,
  applicationsCount,
}

/// Event status
enum EventStatus {
  draft('draft'),
  published('published'),
  cancelled('cancelled'),
  completed('completed');

  const EventStatus(this.value);
  final String value;

  static EventStatus fromString(String value) {
    return EventStatus.values.firstWhere(
      (status) => status.value == value,
      orElse: () => EventStatus.draft,
    );
  }

  bool get isDraft => this == EventStatus.draft;
  bool get isPublished => this == EventStatus.published;
  bool get isCancelled => this == EventStatus.cancelled;
  bool get isCompleted => this == EventStatus.completed;
}

/// Booth size categories
enum BoothSize {
  small('small', 'Small (3x3m)'),
  medium('medium', 'Medium (4x4m)'),
  large('large', 'Large (5x5m)'),
  premium('premium', 'Premium (6x6m)'),
  custom('custom', 'Custom');

  const BoothSize(this.value, this.displayName);
  final String value;
  final String displayName;

  static BoothSize fromString(String value) {
    return BoothSize.values.firstWhere(
      (size) => size.value == value,
      orElse: () => BoothSize.small,
    );
  }
}

/// Booth availability status
enum BoothStatus {
  available('available'),
  reserved('reserved'),
  booked('booked'),
  occupied('occupied');

  const BoothStatus(this.value);
  final String value;

  static BoothStatus fromString(String value) {
    return BoothStatus.values.firstWhere(
      (status) => status.value == value,
      orElse: () => BoothStatus.available,
    );
  }

  bool get isAvailable => this == BoothStatus.available;
  bool get isReserved => this == BoothStatus.reserved;
  bool get isBooked => this == BoothStatus.booked;
  bool get isOccupied => this == BoothStatus.occupied;
}

/// Booking request status
enum BookingStatus {
  pending('pending'),
  approved('approved'),
  rejected('rejected'),
  confirmed('confirmed'),
  cancelled('cancelled');

  const BookingStatus(this.value);
  final String value;

  static BookingStatus fromString(String value) {
    return BookingStatus.values.firstWhere(
      (status) => status.value == value,
      orElse: () => BookingStatus.pending,
    );
  }

  bool get isPending => this == BookingStatus.pending;
  bool get isApproved => this == BookingStatus.approved;
  bool get isRejected => this == BookingStatus.rejected;
  bool get isConfirmed => this == BookingStatus.confirmed;
  bool get isCancelled => this == BookingStatus.cancelled;
}

/// Message type in chat
enum MessageType {
  text('text'),
  image('image'),
  file('file');

  const MessageType(this.value);
  final String value;

  static MessageType fromString(String value) {
    return MessageType.values.firstWhere(
      (type) => type.value == value,
      orElse: () => MessageType.text,
    );
  }
}

/// Job status
enum JobStatus {
  open('open'),
  closed('closed');

  const JobStatus(this.value);
  final String value;

  static JobStatus fromString(String value) {
    return JobStatus.values.firstWhere(
      (status) => status.value == value,
      orElse: () => JobStatus.open,
    );
  }
}

/// Job application status
enum ApplicationStatus {
  pending('pending'),
  reviewed('reviewed'),
  accepted('accepted'),
  rejected('rejected');

  const ApplicationStatus(this.value);
  final String value;

  static ApplicationStatus fromString(String value) {
    return ApplicationStatus.values.firstWhere(
      (status) => status.value == value,
      orElse: () => ApplicationStatus.pending,
    );
  }
}

/// Auth state for the app
enum AuthState {
  initial,
  loading,
  authenticated,
  unauthenticated,
  error,
}

/// Loading state for async operations
enum LoadingState {
  initial,
  loading,
  success,
  error,
}

/// Account request status
enum RequestStatus {
  pending('pending'),
  approved('approved'),
  rejected('rejected');

  const RequestStatus(this.value);
  final String value;

  static RequestStatus fromString(String value) {
    return RequestStatus.values.firstWhere(
      (status) => status.value == value,
      orElse: () => RequestStatus.pending,
    );
  }

  bool get isPending => this == RequestStatus.pending;
  bool get isApproved => this == RequestStatus.approved;
  bool get isRejected => this == RequestStatus.rejected;
}
