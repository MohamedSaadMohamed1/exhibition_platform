import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/loading_widget.dart';
import '../../../../core/widgets/error_widget.dart';
import '../../../../shared/models/service_model.dart';
import '../../../../shared/models/order_model.dart';
import '../../../../shared/models/review_model.dart';
import '../../../../shared/providers/providers.dart';
import '../../../../shared/providers/repository_providers.dart';
import '../providers/service_provider.dart';
import '../../../chat/presentation/providers/chat_provider.dart';
import '../../../reviews/presentation/providers/review_provider.dart';
import '../../../suppliers/presentation/providers/supplier_provider.dart';

class ServiceDetailScreen extends ConsumerWidget {
  final String serviceId;

  const ServiceDetailScreen({super.key, required this.serviceId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final serviceAsync = ref.watch(serviceProvider(serviceId));

    return serviceAsync.when(
      data: (service) {
        if (service == null) {
          return Scaffold(
            backgroundColor: AppColors.scaffoldDark,
            appBar: AppBar(
              backgroundColor: Colors.transparent,
              iconTheme: const IconThemeData(color: AppColors.textPrimaryDark),
            ),
            body: const Center(
              child: Text(
                'Service not found',
                style: TextStyle(color: AppColors.textPrimaryDark),
              ),
            ),
          );
        }
        return _ServiceDetailContent(service: service);
      },
      loading: () => Scaffold(
        backgroundColor: AppColors.scaffoldDark,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          iconTheme: const IconThemeData(color: AppColors.textPrimaryDark),
        ),
        body: const LoadingWidget(),
      ),
      error: (error, _) => Scaffold(
        backgroundColor: AppColors.scaffoldDark,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          iconTheme: const IconThemeData(color: AppColors.textPrimaryDark),
        ),
        body: AppErrorWidget(
          message: error.toString(),
          onRetry: () => ref.invalidate(serviceProvider(serviceId)),
        ),
      ),
    );
  }
}

class _ServiceDetailContent extends ConsumerWidget {
  final ServiceModel service;

  const _ServiceDetailContent({required this.service});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final reviewsAsync = ref.watch(
      targetReviewsProvider((targetId: service.id, type: ReviewType.service)),
    );

    return Scaffold(
      backgroundColor: AppColors.scaffoldDark,
      body: CustomScrollView(
        slivers: [
          // App Bar with Image
          SliverAppBar(
            expandedHeight: 250,
            pinned: true,
            backgroundColor: AppColors.cardDark,
            iconTheme: const IconThemeData(color: Colors.white),
            flexibleSpace: FlexibleSpaceBar(
              background: service.images.isNotEmpty
                  ? PageView.builder(
                      itemCount: service.images.length,
                      itemBuilder: (context, index) => Image.network(
                        service.images[index],
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(
                          color: AppColors.grey700,
                          child: const Center(
                            child: Icon(
                              Icons.miscellaneous_services,
                              size: 64,
                              color: AppColors.grey500,
                            ),
                          ),
                        ),
                      ),
                    )
                  : Container(
                      color: AppColors.grey700,
                      child: const Center(
                        child: Icon(
                          Icons.miscellaneous_services,
                          size: 64,
                          color: AppColors.grey500,
                        ),
                      ),
                    ),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.share),
                onPressed: () {
                  // TODO: Implement share
                },
              ),
            ],
          ),

          // Content
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title and Featured Badge
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          service.name,
                          style: const TextStyle(
                            color: AppColors.textPrimaryDark,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      if (service.isFeatured)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.warning.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.star, size: 16, color: AppColors.warning),
                              SizedBox(width: 4),
                              Text(
                                'Featured',
                                style: TextStyle(
                                  color: AppColors.warning,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 8),

                  // Supplier Info
                  if (service.supplierName != null)
                    GestureDetector(
                      onTap: () => context.push('/suppliers/${service.supplierId}'),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.store,
                            size: 18,
                            color: AppColors.textSecondaryDark,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'by ${service.supplierName}',
                            style: const TextStyle(
                              color: AppColors.primary,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(width: 4),
                          const Icon(
                            Icons.chevron_right,
                            size: 18,
                            color: AppColors.primary,
                          ),
                        ],
                      ),
                    ),
                  const SizedBox(height: 12),

                  // Category
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      service.category,
                      style: const TextStyle(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Rating and Stats
                  Row(
                    children: [
                      const Icon(Icons.star, color: AppColors.warning, size: 20),
                      const SizedBox(width: 4),
                      Text(
                        service.rating.toStringAsFixed(1),
                        style: const TextStyle(
                          color: AppColors.textPrimaryDark,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        ' (${service.reviewsCount} reviews)',
                        style: const TextStyle(
                          color: AppColors.textSecondaryDark,
                        ),
                      ),
                      const Spacer(),
                      const Icon(
                        Icons.shopping_bag_outlined,
                        size: 18,
                        color: AppColors.textSecondaryDark,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${service.ordersCount} orders',
                        style: const TextStyle(
                          color: AppColors.textSecondaryDark,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Price Card
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          AppColors.primary.withOpacity(0.1),
                          AppColors.primaryLight.withOpacity(0.1),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: AppColors.primary.withOpacity(0.3),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Price',
                              style: TextStyle(
                                color: AppColors.textSecondaryDark,
                              ),
                            ),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  'KD ${service.price?.toStringAsFixed(2) ?? '0.00'}',
                                  style: const TextStyle(
                                    color: AppColors.primary,
                                    fontSize: 28,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  ' / ${service.priceUnit}',
                                  style: const TextStyle(
                                    color: AppColors.textSecondaryDark,
                                    fontSize: 16,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: service.isAvailable
                                ? AppColors.success.withOpacity(0.2)
                                : AppColors.error.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            service.isAvailable ? 'Available' : 'Unavailable',
                            style: TextStyle(
                              color: service.isAvailable
                                  ? AppColors.success
                                  : AppColors.error,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Description
                  const Text(
                    'Description',
                    style: TextStyle(
                      color: AppColors.textPrimaryDark,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    service.description,
                    style: const TextStyle(
                      color: AppColors.textSecondaryDark,
                      fontSize: 14,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Features
                  if (service.features.isNotEmpty) ...[
                    const Text(
                      'Features',
                      style: TextStyle(
                        color: AppColors.textPrimaryDark,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    ...service.features.map((feature) => Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(4),
                                decoration: BoxDecoration(
                                  color: AppColors.primary.withOpacity(0.2),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.check,
                                  size: 14,
                                  color: AppColors.primary,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  feature,
                                  style: const TextStyle(
                                    color: AppColors.textPrimaryDark,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        )),
                    const SizedBox(height: 24),
                  ],

                  // Reviews Section
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Reviews',
                        style: TextStyle(
                          color: AppColors.textPrimaryDark,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          // TODO: Navigate to all reviews
                        },
                        child: const Text('See All'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _buildReviewsSection(reviewsAsync),
                  const SizedBox(height: 100), // Space for bottom button
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.cardDark,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: SafeArea(
          child: Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    // TODO: Implement chat with supplier
                  },
                  icon: const Icon(Icons.chat_bubble_outline),
                  label: const Text('Chat'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.primary,
                    side: const BorderSide(color: AppColors.primary),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                flex: 2,
                child: ElevatedButton(
                  onPressed: service.isAvailable
                      ? () {
                          // TODO: Implement order service
                          _showOrderSheet(context, service);
                        }
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    disabledBackgroundColor: AppColors.grey600,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Order Service',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildReviewsSection(ReviewsState state) {
    if (state.isLoading) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(20),
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (state.reviews.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: AppColors.surfaceDark,
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Center(
          child: Text(
            'No reviews yet',
            style: TextStyle(color: AppColors.textSecondaryDark),
          ),
        ),
      );
    }

    return Column(
      children: state.reviews.take(3).map((review) => _ReviewCard(review: review)).toList(),
    );
  }

  void _showOrderSheet(BuildContext context, ServiceModel service) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _OrderServiceSheet(service: service),
    );
  }
}

class _OrderServiceSheet extends ConsumerStatefulWidget {
  final ServiceModel service;

  const _OrderServiceSheet({required this.service});

  @override
  ConsumerState<_OrderServiceSheet> createState() => _OrderServiceSheetState();
}

class _OrderServiceSheetState extends ConsumerState<_OrderServiceSheet> {
  final _notesController = TextEditingController();
  bool _isLoading = false;
  DateTime? _startDateTime;
  DateTime? _endDateTime;

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  Future<DateTime?> _pickDateTime({DateTime? initial}) async {
    final now = DateTime.now();
    final date = await showDatePicker(
      context: context,
      initialDate: initial ?? now.add(const Duration(days: 1)),
      firstDate: now,
      lastDate: now.add(const Duration(days: 365 * 2)),
    );
    if (date == null || !mounted) return null;
    final time = await showTimePicker(
      context: context,
      initialTime: initial != null
          ? TimeOfDay.fromDateTime(initial)
          : const TimeOfDay(hour: 9, minute: 0),
    );
    if (time == null) return null;
    return DateTime(date.year, date.month, date.day, time.hour, time.minute);
  }

  Future<void> _pickStartDateTime() async {
    final picked = await _pickDateTime(initial: _startDateTime);
    if (picked != null) {
      setState(() {
        _startDateTime = picked;
        if (_endDateTime != null && _endDateTime!.isBefore(picked)) {
          _endDateTime = null;
        }
      });
    }
  }

  Future<void> _pickEndDateTime() async {
    final picked = await _pickDateTime(
        initial: _endDateTime ?? _startDateTime?.add(const Duration(hours: 2)));
    if (picked != null) {
      if (_startDateTime != null && picked.isBefore(_startDateTime!)) {
        if (!mounted) return;
        _showError('End time must be after start time');
        return;
      }
      setState(() => _endDateTime = picked);
    }
  }

  Future<void> _submit() async {
    setState(() => _isLoading = true);

    try {
      final currentUser = ref.read(currentUserProvider).valueOrNull;
      if (currentUser == null) {
        _showError('You must be logged in to place an order');
        return;
      }

      // Load supplier to get userId and profile info for chat
      final supplier =
          await ref.read(supplierProvider(widget.service.supplierId).future);
      if (supplier == null) {
        _showError('Supplier not found');
        return;
      }

      if (_startDateTime == null) {
        _showError('Please select a start date & time');
        return;
      }
      if (_endDateTime == null) {
        _showError('Please select an end date & time');
        return;
      }

      final notes = _notesController.text.trim();

      // 1. Create order
      final order = OrderModel(
        id: '',
        serviceId: widget.service.id,
        supplierId: widget.service.supplierId,
        customerId: currentUser.id,
        serviceIds: [widget.service.id],
        serviceNames: [widget.service.title],
        serviceName: widget.service.title,
        supplierName: supplier.businessName,
        customerName: currentUser.name,
        customerPhone: currentUser.phone,
        notes: notes.isEmpty ? null : notes,
        totalPrice: widget.service.price ?? 0,
        serviceDate: _startDateTime,
        serviceEndDate: _endDateTime,
        status: OrderStatus.pending,
        createdAt: DateTime.now(),
      );

      final orderResult =
          await ref.read(orderRepositoryProvider).createOrder(order);
      orderResult.fold(
        (failure) => throw Exception(failure.message),
        (_) {},
      );

      // 2. Create or get chat
      final chatResult = await ref.read(getOrCreateChatProvider((
        currentUserId: currentUser.id,
        otherUserId: supplier.userId,
        currentUserName: currentUser.name,
        otherUserName: supplier.businessName,
        currentUserImage: currentUser.profileImage,
        otherUserImage: supplier.profileImage,
      )).future);

      if (chatResult == null) throw Exception('Failed to create chat');

      // 3. Auto-send request details as first message
      final fmt = DateFormat('EEE, MMM d, yyyy – h:mm a');
      final message = '📋 Service Request: ${widget.service.title}\n'
          'Price: KD ${widget.service.price?.toStringAsFixed(2) ?? '0.00'} / ${widget.service.priceUnit ?? 'unit'}\n'
          'Start: ${fmt.format(_startDateTime!)}\n'
          'End:   ${fmt.format(_endDateTime!)}'
          '${notes.isNotEmpty ? '\n\nNotes: $notes' : ''}';

      await ref.read(chatRepositoryProvider).sendMessage(
            chatId: chatResult.id,
            senderId: currentUser.id,
            text: message,
          );

      if (mounted) {
        Navigator.of(context).pop();
        context.push('/chats/${chatResult.id}');
      }
    } catch (e) {
      if (mounted) _showError('Error: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: AppColors.error),
    );
  }

  @override
  Widget build(BuildContext context) {
    final service = widget.service;

    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surfaceDark,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: EdgeInsets.fromLTRB(
        20,
        20,
        20,
        20 + MediaQuery.of(context).viewInsets.bottom,
      ),
      child: SingleChildScrollView(
        child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Order Service',
            style: TextStyle(
              color: AppColors.textPrimaryDark,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.cardDark,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: AppColors.grey700,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: service.images.isNotEmpty
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.network(
                            service.images.first,
                            fit: BoxFit.cover,
                          ),
                        )
                      : const Icon(
                          Icons.miscellaneous_services,
                          color: AppColors.grey500,
                        ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        service.name,
                        style: const TextStyle(
                          color: AppColors.textPrimaryDark,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'KD ${service.price?.toStringAsFixed(2) ?? '0.00'} / ${service.priceUnit ?? 'unit'}',
                        style: const TextStyle(color: AppColors.primary),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Booking Date & Time *',
            style: TextStyle(
              color: AppColors.textPrimaryDark,
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 8),
          _ServiceDateTile(
            label: 'Start',
            icon: Icons.play_circle_outline,
            dateTime: _startDateTime,
            onTap: _pickStartDateTime,
          ),
          const SizedBox(height: 8),
          _ServiceDateTile(
            label: 'End',
            icon: Icons.stop_circle_outlined,
            dateTime: _endDateTime,
            onTap: _pickEndDateTime,
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _notesController,
            maxLines: 3,
            style: const TextStyle(color: AppColors.textPrimaryDark),
            decoration: const InputDecoration(
              hintText: 'Add notes for the supplier (optional)',
              hintStyle: TextStyle(color: AppColors.textMutedDark),
              filled: true,
              fillColor: AppColors.cardDark,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(12)),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _isLoading ? null : _submit,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                disabledBackgroundColor: AppColors.grey600,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: _isLoading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                  : const Text(
                      'Confirm Order',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
            ),
          ),
        ],
      ),
      ),
    );
  }
}

class _ServiceDateTile extends StatelessWidget {
  final String label;
  final IconData icon;
  final DateTime? dateTime;
  final VoidCallback onTap;

  const _ServiceDateTile({
    required this.label,
    required this.icon,
    required this.dateTime,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        decoration: BoxDecoration(
          color: AppColors.cardDark,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(icon, size: 20, color: AppColors.textMutedDark),
            const SizedBox(width: 12),
            Text(
              '$label: ',
              style: const TextStyle(
                color: AppColors.textMutedDark,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
            Expanded(
              child: Text(
                dateTime != null
                    ? DateFormat('EEE, MMM d, yyyy – h:mm a').format(dateTime!)
                    : 'Select date & time',
                style: TextStyle(
                  color: dateTime != null
                      ? AppColors.textPrimaryDark
                      : AppColors.textMutedDark,
                  fontSize: 14,
                ),
              ),
            ),
            const Icon(Icons.edit_calendar_outlined,
                size: 16, color: AppColors.textMutedDark),
          ],
        ),
      ),
    );
  }
}

class _ReviewCard extends StatelessWidget {
  final ReviewModel review;

  const _ReviewCard({required this.review});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceDark,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: AppColors.grey600,
                backgroundImage: review.userAvatar != null
                    ? NetworkImage(review.userAvatar!)
                    : null,
                child: review.userAvatar == null
                    ? Text(
                        (review.userName?.isNotEmpty ?? false)
                            ? review.userName![0].toUpperCase()
                            : 'U',
                        style: const TextStyle(color: AppColors.textPrimaryDark),
                      )
                    : null,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      review.userName ?? 'Anonymous',
                      style: const TextStyle(
                        color: AppColors.textPrimaryDark,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Row(
                      children: [
                        ...List.generate(
                          5,
                          (index) => Icon(
                            index < review.rating
                                ? Icons.star
                                : Icons.star_border,
                            size: 14,
                            color: AppColors.warning,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          _formatDate(review.createdAt),
                          style: const TextStyle(
                            color: AppColors.textMutedDark,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (review.comment != null && review.comment!.isNotEmpty) ...[
            const SizedBox(height: 12),
            Text(
              review.comment!,
              style: const TextStyle(
                color: AppColors.textSecondaryDark,
                height: 1.4,
              ),
            ),
          ],
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);

    if (diff.inDays == 0) {
      return 'Today';
    } else if (diff.inDays == 1) {
      return 'Yesterday';
    } else if (diff.inDays < 7) {
      return '${diff.inDays} days ago';
    } else if (diff.inDays < 30) {
      return '${(diff.inDays / 7).floor()} weeks ago';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }
}
