import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/loading_widget.dart';
import '../../../../core/widgets/error_widget.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/extensions/date_extensions.dart';
import '../../../../shared/providers/providers.dart';
import '../../../../shared/models/supplier_model.dart';
import '../../../../router/routes.dart';
import '../providers/events_provider.dart';
import '../../../interested/presentation/screens/interested_events_screen.dart';
import '../../../suppliers/presentation/providers/supplier_provider.dart';

class EventDetailScreen extends ConsumerStatefulWidget {
  final String eventId;

  const EventDetailScreen({super.key, required this.eventId});

  @override
  ConsumerState<EventDetailScreen> createState() => _EventDetailScreenState();
}

class _EventDetailScreenState extends ConsumerState<EventDetailScreen> {
  bool _isToggling = false;

  void _showFullImage(BuildContext context, String imageUrl) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: EdgeInsets.zero,
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Dark background
            GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(color: Colors.black87),
            ),
            // Image with zoom
            InteractiveViewer(
              minScale: 0.5,
              maxScale: 4.0,
              child: Center(
                child: Image.network(
                  imageUrl,
                  fit: BoxFit.contain,
                  errorBuilder: (_, __, ___) => const Icon(
                    Icons.broken_image,
                    size: 64,
                    color: Colors.white54,
                  ),
                ),
              ),
            ),
            // Close button
            Positioned(
              top: 40,
              right: 16,
              child: IconButton(
                icon: const Icon(Icons.close, color: Colors.white, size: 30),
                onPressed: () => Navigator.pop(context),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _toggleInterest() async {
    final userId = ref.read(currentUserIdProvider);
    if (userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please login to mark interest'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    setState(() => _isToggling = true);

    final result = await ref.read(eventRepositoryProvider).toggleInterest(
      eventId: widget.eventId,
      userId: userId,
    );

    setState(() => _isToggling = false);

    result.fold(
      (failure) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(failure.message),
            backgroundColor: AppColors.error,
          ),
        );
      },
      (isInterested) {
        // Refresh interest state and event details
        ref.invalidate(isUserInterestedProvider((eventId: widget.eventId, userId: userId)));
        ref.invalidate(eventDetailProvider(widget.eventId));
        ref.invalidate(interestedEventsProvider);
        ref.invalidate(upcomingEventsProvider);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              isInterested ? 'Added to interested' : 'Removed from interested',
            ),
            backgroundColor: AppColors.success,
            duration: const Duration(seconds: 1),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final eventAsync = ref.watch(eventDetailProvider(widget.eventId));
    final currentUser = ref.watch(currentUserProvider).valueOrNull;
    final userId = ref.watch(currentUserIdProvider);

    // Watch the interest state
    final isInterestedAsync = userId != null
        ? ref.watch(isUserInterestedProvider((eventId: widget.eventId, userId: userId)))
        : const AsyncValue<bool>.data(false);

    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      body: eventAsync.when(
        data: (event) {
          if (event == null) {
            return const AppErrorWidget(message: 'Event not found');
          }

          return CustomScrollView(
            slivers: [
              // App Bar with Image
              SliverAppBar(
                backgroundColor: AppColors.surfaceDark,
                expandedHeight: 250,
                pinned: true,
                iconTheme: const IconThemeData(color: Colors.white),
                flexibleSpace: FlexibleSpaceBar(
                  background: Stack(
                    fit: StackFit.expand,
                    children: [
                      // Cover Image
                      event.coverImage != null
                          ? Image.network(
                              event.coverImage!,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => Container(
                                color: AppColors.grey800,
                                child: const Icon(
                                  Icons.event,
                                  size: 64,
                                  color: AppColors.grey600,
                                ),
                              ),
                            )
                          : Container(
                              color: AppColors.grey800,
                              child: const Icon(
                                Icons.event,
                                size: 64,
                                color: AppColors.grey600,
                              ),
                            ),
                      // Image Action Buttons
                      Positioned(
                        right: 12,
                        top: 80,
                        child: Column(
                          children: [
                            _ImageActionButton(
                              icon: Icons.add,
                              onTap: () {
                                // Zoom in / View full image
                                if (event.coverImage != null) {
                                  _showFullImage(context, event.coverImage!);
                                }
                              },
                            ),
                            const SizedBox(height: 8),
                            _ImageActionButton(
                              icon: Icons.refresh,
                              onTap: () {
                                // Refresh / Reload image
                                ref.invalidate(eventDetailProvider(widget.eventId));
                              },
                            ),
                            const SizedBox(height: 8),
                            _ImageActionButton(
                              icon: Icons.remove,
                              onTap: () {
                                // Zoom out / minimize action
                              },
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                actions: [
                  IconButton(
                    icon: const Icon(Icons.share),
                    onPressed: () {
                      // Share event
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
                      // Category & Status
                      Row(
                        children: [
                          if (event.category != null)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.primary.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                event.category!,
                                style: const TextStyle(
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          const Spacer(),
                          Row(
                            children: [
                              const Icon(
                                Icons.favorite,
                                color: AppColors.error,
                                size: 20,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '${event.interestedCount} interested',
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color: AppColors.textSecondaryDark,
                                    ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      // Title
                      Text(
                        event.title,
                        style:
                            Theme.of(context).textTheme.headlineSmall?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                      ),
                      const SizedBox(height: 16),
                      // Date & Location
                      _InfoRow(
                        icon: Icons.calendar_today,
                        title: 'Date',
                        value: DateTimeX.formatEventDateRange(
                          event.startDate,
                          event.endDate,
                        ),
                      ),
                      const SizedBox(height: 12),
                      _InfoRow(
                        icon: Icons.location_on,
                        title: 'Location',
                        value: event.address ?? event.location,
                      ),
                      const SizedBox(height: 12),
                      _InfoRow(
                        icon: Icons.grid_view,
                        title: 'Available Booths',
                        value: '${event.boothCount} booths',
                      ),
                      const SizedBox(height: 24),
                      // Tags
                      if (event.tags.isNotEmpty) ...[
                        Text(
                          'Tags',
                          style:
                              Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                        ),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: event.tags
                              .map((tag) => Chip(
                                    label: Text(
                                      tag,
                                      style: const TextStyle(color: Colors.white),
                                    ),
                                    backgroundColor: AppColors.surfaceDark,
                                    side: const BorderSide(color: AppColors.grey700),
                                  ))
                              .toList(),
                        ),
                        const SizedBox(height: 24),
                      ],
                      // Description
                      Text(
                        'About Event',
                        style:
                            Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        event.description,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: AppColors.textSecondaryDark,
                              height: 1.6,
                            ),
                      ),
                      const SizedBox(height: 24),
                      // Suppliers Section
                      _SuppliersSection(eventCategory: event.category),
                      const SizedBox(height: 100), // Space for bottom buttons
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
      bottomNavigationBar: eventAsync.whenOrNull(
        data: (event) {
          if (event == null) return null;

          final isInterested = isInterestedAsync.valueOrNull ?? false;

          return Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.surfaceDark,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.3),
                  blurRadius: 10,
                  offset: const Offset(0, -5),
                ),
              ],
            ),
            child: SafeArea(
              child: Row(
                children: [
                  // Interest Button
                  Expanded(
                    child: AppButton(
                      text: isInterested ? 'Interested' : 'Interested',
                      style: isInterested ? AppButtonStyle.primary : AppButtonStyle.outline,
                      icon: isInterested ? Icons.favorite : Icons.favorite_border,
                      isLoading: _isToggling,
                      onPressed: _isToggling ? null : _toggleInterest,
                    ),
                  ),
                  const SizedBox(width: 12),
                  // View Booths Button
                  Expanded(
                    child: AppButton(
                      text: 'View Booths',
                      icon: Icons.grid_view,
                      onPressed: () => context.push(
                        AppRoutes.eventBooths.replaceFirst(':eventId', widget.eventId),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;

  const _InfoRow({
    required this.icon,
    required this.title,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: AppColors.primary, size: 20),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.textSecondaryDark,
                    ),
              ),
              Text(
                value,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w500,
                      color: Colors.white,
                    ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// Suppliers section showing featured suppliers for the event
class _SuppliersSection extends ConsumerWidget {
  final String? eventCategory;

  const _SuppliersSection({this.eventCategory});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final suppliersAsync = ref.watch(featuredSuppliersProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Suppliers & Services',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
            ),
            TextButton(
              onPressed: () => context.push(AppRoutes.suppliers),
              child: const Text(
                'View All',
                style: TextStyle(color: AppColors.primary),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        suppliersAsync.when(
          data: (suppliers) {
            if (suppliers.isEmpty) {
              return Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: AppColors.surfaceDark,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.grey800),
                ),
                child: Center(
                  child: Column(
                    children: [
                      Icon(
                        Icons.store_outlined,
                        size: 48,
                        color: AppColors.grey600,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'No suppliers available',
                        style: TextStyle(color: AppColors.grey500),
                      ),
                    ],
                  ),
                ),
              );
            }

            return SizedBox(
              height: 200,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: suppliers.length > 5 ? 5 : suppliers.length,
                separatorBuilder: (_, __) => const SizedBox(width: 12),
                itemBuilder: (context, index) {
                  final supplier = suppliers[index];
                  return _SupplierCard(supplier: supplier);
                },
              ),
            );
          },
          loading: () => const SizedBox(
            height: 200,
            child: Center(child: CircularProgressIndicator()),
          ),
          error: (error, _) => Container(
            padding: const EdgeInsets.all(16),
            child: Text(
              'Failed to load suppliers',
              style: TextStyle(color: AppColors.grey500),
            ),
          ),
        ),
      ],
    );
  }
}

/// Individual supplier card
class _SupplierCard extends StatelessWidget {
  final SupplierModel supplier;

  const _SupplierCard({required this.supplier});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.push(
        AppRoutes.supplierDetail.replaceFirst(':supplierId', supplier.id),
      ),
      child: Container(
        width: 160,
        decoration: BoxDecoration(
          color: AppColors.surfaceDark,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.grey800),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
              child: Container(
                height: 90,
                width: double.infinity,
                color: AppColors.grey800,
                child: supplier.coverImage != null
                    ? Image.network(
                        supplier.coverImage!,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => _buildPlaceholder(),
                      )
                    : _buildPlaceholder(),
              ),
            ),
            // Content
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    supplier.businessName,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  if (supplier.category != null)
                    Text(
                      supplier.category!,
                      style: TextStyle(
                        color: AppColors.grey500,
                        fontSize: 12,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(
                        Icons.star,
                        color: Colors.amber,
                        size: 14,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        supplier.rating.toStringAsFixed(1),
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w500,
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '(${supplier.reviewsCount})',
                        style: TextStyle(
                          color: AppColors.grey500,
                          fontSize: 12,
                        ),
                      ),
                      const Spacer(),
                      if (supplier.isVerified)
                        Icon(
                          Icons.verified,
                          color: AppColors.primary,
                          size: 16,
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlaceholder() {
    return Center(
      child: Icon(
        Icons.store,
        size: 32,
        color: AppColors.grey600,
      ),
    );
  }
}

/// Image action button with circular design
class _ImageActionButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _ImageActionButton({
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: const Color(0xFF2D2D3A),
          shape: BoxShape.circle,
          border: Border.all(
            color: Colors.white.withOpacity(0.1),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Icon(
          icon,
          color: Colors.white.withOpacity(0.8),
          size: 20,
        ),
      ),
    );
  }
}
