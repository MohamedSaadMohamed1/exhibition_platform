import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/loading_widget.dart';
import '../../../../core/widgets/error_widget.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../shared/models/service_model.dart';
import '../../../../shared/models/order_model.dart';
import '../../../../shared/providers/providers.dart';
import '../../../chat/presentation/providers/chat_provider.dart';
import '../../../services/presentation/providers/service_provider.dart';
import '../../../reviews/presentation/providers/review_provider.dart';
import '../providers/supplier_provider.dart';
import '../../../../shared/models/review_model.dart';

class SupplierDetailScreen extends ConsumerWidget {
  final String supplierId;

  const SupplierDetailScreen({super.key, required this.supplierId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final supplierAsync = ref.watch(supplierProvider(supplierId));
    final servicesAsync = ref.watch(supplierServicesProvider(supplierId));
    final reviewStatsAsync = ref.watch(reviewStatsProvider((
      targetId: supplierId,
      type: ReviewType.supplier,
    )));
    final currentUser = ref.watch(currentUserProvider).valueOrNull;
    final services = servicesAsync.maybeWhen(data: (s) => s, orElse: () => <ServiceModel>[]);

    return Scaffold(
      backgroundColor: AppColors.scaffoldDark,
      body: supplierAsync.when(
        data: (supplier) {
          if (supplier == null) {
            return const AppErrorWidget(message: 'Supplier not found');
          }

          return CustomScrollView(
            slivers: [
              // App Bar with Cover Image
              SliverAppBar(
                expandedHeight: 200,
                pinned: true,
                backgroundColor: AppColors.surfaceDark,
                iconTheme: const IconThemeData(color: Colors.white),
                flexibleSpace: FlexibleSpaceBar(
                  background: Stack(
                    fit: StackFit.expand,
                    children: [
                      supplier.coverImage != null
                          ? Image.network(
                              supplier.coverImage!,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => Container(
                                color: AppColors.grey700,
                              ),
                            )
                          : Container(color: AppColors.grey700),
                      Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.transparent,
                              Colors.black.withOpacity(0.7),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                actions: [
                  IconButton(
                    icon: const Icon(Icons.share),
                    onPressed: () {},
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
                      // Profile section
                      Row(
                        children: [
                          CircleAvatar(
                            radius: 35,
                            backgroundColor: AppColors.primary,
                            backgroundImage: supplier.profileImage != null
                                ? NetworkImage(supplier.profileImage!)
                                : null,
                            child: supplier.profileImage == null
                                ? Text(
                                    supplier.businessName[0].toUpperCase(),
                                    style: const TextStyle(
                                      fontSize: 28,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  )
                                : null,
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Flexible(
                                      child: Text(
                                        supplier.businessName,
                                        style: const TextStyle(
                                          color: AppColors.textPrimaryDark,
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    if (supplier.isVerified) ...[
                                      const SizedBox(width: 8),
                                      const Icon(
                                        Icons.verified,
                                        color: AppColors.success,
                                        size: 20,
                                      ),
                                    ],
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    const Icon(
                                      Icons.star,
                                      color: AppColors.warning,
                                      size: 16,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      '${supplier.rating.toStringAsFixed(1)} (${supplier.reviewsCount} reviews)',
                                      style: const TextStyle(
                                        color: AppColors.textSecondaryDark,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      // Categories
                      if (supplier.categories.isNotEmpty) ...[
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: supplier.categories.map((cat) {
                            return Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.primary.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Text(
                                cat,
                                style: const TextStyle(
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                        const SizedBox(height: 20),
                      ],
                      // Description
                      if (supplier.description.isNotEmpty) ...[
                        const Text(
                          'About',
                          style: TextStyle(
                            color: AppColors.textPrimaryDark,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          supplier.description,
                          style: const TextStyle(
                            color: AppColors.textSecondaryDark,
                            height: 1.5,
                          ),
                        ),
                        const SizedBox(height: 24),
                      ],
                      // Stats
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppColors.cardDark,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            _StatItem(
                              icon: Icons.shopping_bag,
                              value: '${supplier.ordersCount}',
                              label: 'Orders',
                            ),
                            _StatItem(
                              icon: Icons.star,
                              value: supplier.rating.toStringAsFixed(1),
                              label: 'Rating',
                            ),
                            _StatItem(
                              icon: Icons.reviews,
                              value: '${supplier.reviewsCount}',
                              label: 'Reviews',
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                      // Services section
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Services',
                            style: TextStyle(
                              color: AppColors.textPrimaryDark,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          TextButton(
                            onPressed: () {},
                            child: const Text('See All'),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      servicesAsync.when(
                        data: (services) {
                          if (services.isEmpty) {
                            return Container(
                              padding: const EdgeInsets.all(24),
                              decoration: BoxDecoration(
                                color: AppColors.cardDark,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Center(
                                child: Text(
                                  'No services yet',
                                  style: TextStyle(
                                    color: AppColors.textSecondaryDark,
                                  ),
                                ),
                              ),
                            );
                          }
                          return Column(
                            children: services
                                .take(3)
                                .map((service) => _ServiceCard(
                                      service: service,
                                      onTap: () => context
                                          .push('/services/${service.id}'),
                                    ))
                                .toList(),
                          );
                        },
                        loading: () => const Center(
                          child: CircularProgressIndicator(),
                        ),
                        error: (_, __) => const SizedBox(),
                      ),
                      const SizedBox(height: 24),
                      // Reviews preview
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
                            onPressed: () {},
                            child: const Text('See All'),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      reviewStatsAsync.when(
                        data: (stats) => _ReviewStatsCard(stats: stats),
                        loading: () => const SizedBox(),
                        error: (_, __) => const SizedBox(),
                      ),
                      const SizedBox(height: 100),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
        loading: () => const LoadingWidget(),
        error: (error, _) => AppErrorWidget(message: error.toString()),
      ),
      bottomNavigationBar: supplierAsync.whenOrNull(
        data: (supplier) {
          if (supplier == null || currentUser == null) return null;

          // Don't show contact button if looking at own profile
          if (currentUser.id == supplier.userId) {
            return Container(
              padding: const EdgeInsets.all(16),
              color: AppColors.surfaceDark,
              child: const SafeArea(
                child: Text(
                  'This is your business profile',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: AppColors.textSecondaryDark),
                ),
              ),
            );
          }

          return _ContactSupplierButton(
            currentUser: currentUser,
            supplier: supplier,
            services: services,
          );
        },
      ),
    );
  }
}

class _ContactSupplierButton extends StatelessWidget {
  final dynamic currentUser;
  final dynamic supplier;
  final List<ServiceModel> services;

  const _ContactSupplierButton({
    required this.currentUser,
    required this.supplier,
    required this.services,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceDark,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        child: AppButton(
          text: 'Request Service',
          icon: Icons.handshake_outlined,
          onPressed: () {
            if (supplier.userId.isEmpty) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('This supplier cannot be contacted at this moment.'),
                  backgroundColor: AppColors.error,
                ),
              );
              return;
            }

            showModalBottomSheet(
              context: context,
              isScrollControlled: true,
              backgroundColor: Colors.transparent,
              builder: (_) => _RequestServiceBottomSheet(
                currentUser: currentUser,
                supplier: supplier,
                services: services,
              ),
            );
          },
        ),
      ),
    );
  }
}

class _RequestServiceBottomSheet extends ConsumerStatefulWidget {
  final dynamic currentUser;
  final dynamic supplier;
  final List<ServiceModel> services;

  const _RequestServiceBottomSheet({
    required this.currentUser,
    required this.supplier,
    required this.services,
  });

  @override
  ConsumerState<_RequestServiceBottomSheet> createState() =>
      _RequestServiceBottomSheetState();
}

class _RequestServiceBottomSheetState
    extends ConsumerState<_RequestServiceBottomSheet> {
  final _notesController = TextEditingController();
  final _budgetController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  ServiceModel? _selectedService;
  bool _isLoading = false;

  @override
  void dispose() {
    _notesController.dispose();
    _budgetController.dispose();
    super.dispose();
  }

  String _buildRequestMessage(String serviceName, String notes, String budget) {
    final buffer = StringBuffer();
    buffer.writeln('🔧 Service Request');
    buffer.writeln();
    buffer.writeln('Service: $serviceName');
    if (budget.isNotEmpty) {
      buffer.writeln('Budget: \$$budget');
    } else {
      buffer.writeln('Budget: Flexible');
    }
    buffer.writeln();
    buffer.writeln('Notes: $notes');
    return buffer.toString().trim();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final serviceName =
          _selectedService?.title ?? 'General Inquiry';
      final notes = _notesController.text.trim();
      final budget = _budgetController.text.trim();
      final totalPrice = double.tryParse(budget) ?? 0.0;

      // 1. Create order
      final order = OrderModel(
        id: '',
        serviceId: _selectedService?.id ?? '',
        supplierId: widget.supplier.id,
        customerId: widget.currentUser.id,
        serviceName: serviceName,
        supplierName: widget.supplier.businessName,
        customerName: widget.currentUser.name,
        customerPhone: widget.currentUser.phone,
        notes: notes,
        totalPrice: totalPrice,
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
        currentUserId: widget.currentUser.id,
        otherUserId: widget.supplier.userId,
        currentUserName: widget.currentUser.name,
        otherUserName: widget.supplier.businessName,
        currentUserImage: widget.currentUser.profileImage,
        otherUserImage: widget.supplier.profileImage,
      )).future);

      if (chatResult == null) throw Exception('Failed to create chat');

      // 3. Auto-send request details as first message
      await ref.read(chatRepositoryProvider).sendMessage(
            chatId: chatResult.id,
            senderId: widget.currentUser.id,
            text: _buildRequestMessage(serviceName, notes, budget),
          );

      if (mounted) {
        Navigator.of(context).pop();
        context.push('/chats/${chatResult.id}');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surfaceDark,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: EdgeInsets.fromLTRB(16, 16, 16, 16 + bottomPadding),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Handle
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.grey600,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            // Title
            Text(
              'Request from ${widget.supplier.businessName}',
              style: const TextStyle(
                color: AppColors.textPrimaryDark,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            // Service selector
            if (widget.services.isNotEmpty) ...[
              const Text(
                'Service',
                style: TextStyle(
                  color: AppColors.textSecondaryDark,
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  color: AppColors.cardDark,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<ServiceModel?>(
                    value: _selectedService,
                    isExpanded: true,
                    dropdownColor: AppColors.cardDark,
                    hint: const Text(
                      'General Inquiry',
                      style: TextStyle(color: AppColors.textSecondaryDark),
                    ),
                    items: [
                      const DropdownMenuItem<ServiceModel?>(
                        value: null,
                        child: Text(
                          'General Inquiry',
                          style: TextStyle(color: AppColors.textPrimaryDark),
                        ),
                      ),
                      ...widget.services.map((s) => DropdownMenuItem<ServiceModel?>(
                            value: s,
                            child: Text(
                              s.title,
                              style: const TextStyle(
                                  color: AppColors.textPrimaryDark),
                              overflow: TextOverflow.ellipsis,
                            ),
                          )),
                    ],
                    onChanged: (value) =>
                        setState(() => _selectedService = value),
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],
            // Notes field
            const Text(
              'Message *',
              style: TextStyle(
                color: AppColors.textSecondaryDark,
                fontSize: 13,
              ),
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _notesController,
              maxLines: 4,
              style: const TextStyle(color: AppColors.textPrimaryDark),
              decoration: InputDecoration(
                hintText: 'Describe what you need...',
                hintStyle:
                    const TextStyle(color: AppColors.textSecondaryDark),
                filled: true,
                fillColor: AppColors.cardDark,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.all(14),
              ),
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? 'Message is required' : null,
            ),
            const SizedBox(height: 16),
            // Budget field
            const Text(
              'Budget (optional)',
              style: TextStyle(
                color: AppColors.textSecondaryDark,
                fontSize: 13,
              ),
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _budgetController,
              keyboardType: TextInputType.number,
              style: const TextStyle(color: AppColors.textPrimaryDark),
              decoration: InputDecoration(
                hintText: 'e.g. 500',
                prefixText: '\$ ',
                prefixStyle:
                    const TextStyle(color: AppColors.textSecondaryDark),
                hintStyle:
                    const TextStyle(color: AppColors.textSecondaryDark),
                filled: true,
                fillColor: AppColors.cardDark,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.all(14),
              ),
            ),
            const SizedBox(height: 24),
            // Submit button
            AppButton(
              text: 'Send Request',
              icon: Icons.send,
              isLoading: _isLoading,
              onPressed: _submit,
            ),
          ],
        ),
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;

  const _StatItem({
    required this.icon,
    required this.value,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: AppColors.primary, size: 24),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            color: AppColors.textPrimaryDark,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            color: AppColors.textSecondaryDark,
            fontSize: 12,
          ),
        ),
      ],
    );
  }
}

class _ServiceCard extends StatelessWidget {
  final ServiceModel service;
  final VoidCallback onTap;

  const _ServiceCard({
    required this.service,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.cardDark,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Container(
                width: 70,
                height: 70,
                color: AppColors.grey700,
                child: service.images.isNotEmpty
                    ? Image.network(
                        service.images.first,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => const Icon(
                          Icons.handyman,
                          color: AppColors.grey500,
                        ),
                      )
                    : const Icon(
                        Icons.handyman,
                        color: AppColors.grey500,
                      ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    service.title,
                    style: const TextStyle(
                      color: AppColors.textPrimaryDark,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    service.category,
                    style: const TextStyle(
                      color: AppColors.textSecondaryDark,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(
                        Icons.star,
                        color: AppColors.warning,
                        size: 14,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        service.rating.toStringAsFixed(1),
                        style: const TextStyle(
                          color: AppColors.textSecondaryDark,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  service.formattedPrice,
                  style: const TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                const Icon(
                  Icons.arrow_forward_ios,
                  color: AppColors.textMutedDark,
                  size: 14,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ReviewStatsCard extends StatelessWidget {
  final ReviewStats stats;

  const _ReviewStatsCard({required this.stats});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardDark,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          // Average rating
          Column(
            children: [
              Text(
                stats.averageRating.toStringAsFixed(1),
                style: const TextStyle(
                  color: AppColors.textPrimaryDark,
                  fontSize: 40,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Row(
                children: List.generate(5, (index) {
                  return Icon(
                    index < stats.averageRating.round()
                        ? Icons.star
                        : Icons.star_border,
                    color: AppColors.warning,
                    size: 16,
                  );
                }),
              ),
              const SizedBox(height: 4),
              Text(
                '${stats.totalReviews} reviews',
                style: const TextStyle(
                  color: AppColors.textSecondaryDark,
                  fontSize: 12,
                ),
              ),
            ],
          ),
          const SizedBox(width: 24),
          // Rating bars
          Expanded(
            child: Column(
              children: [
                _RatingBar(stars: 5, percent: stats.getPercentage(5)),
                _RatingBar(stars: 4, percent: stats.getPercentage(4)),
                _RatingBar(stars: 3, percent: stats.getPercentage(3)),
                _RatingBar(stars: 2, percent: stats.getPercentage(2)),
                _RatingBar(stars: 1, percent: stats.getPercentage(1)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _RatingBar extends StatelessWidget {
  final int stars;
  final double percent;

  const _RatingBar({
    required this.stars,
    required this.percent,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Text(
            '$stars',
            style: const TextStyle(
              color: AppColors.textSecondaryDark,
              fontSize: 12,
            ),
          ),
          const SizedBox(width: 4),
          const Icon(Icons.star, color: AppColors.warning, size: 12),
          const SizedBox(width: 8),
          Expanded(
            child: Container(
              height: 6,
              decoration: BoxDecoration(
                color: AppColors.grey700,
                borderRadius: BorderRadius.circular(3),
              ),
              child: FractionallySizedBox(
                alignment: Alignment.centerLeft,
                widthFactor: percent / 100,
                child: Container(
                  decoration: BoxDecoration(
                    color: AppColors.warning,
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
