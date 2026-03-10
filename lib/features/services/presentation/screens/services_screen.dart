import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/loading_widget.dart';
import '../../../../core/widgets/error_widget.dart';
import '../../../../shared/models/service_model.dart';
import '../providers/service_provider.dart';

class ServicesScreen extends ConsumerStatefulWidget {
  const ServicesScreen({super.key});

  @override
  ConsumerState<ServicesScreen> createState() => _ServicesScreenState();
}

class _ServicesScreenState extends ConsumerState<ServicesScreen> {
  String? _selectedCategory;
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      ref.read(servicesNotifierProvider.notifier).loadMore();
    }
  }

  @override
  Widget build(BuildContext context) {
    final servicesState = ref.watch(servicesNotifierProvider);
    final categoriesAsync = ref.watch(serviceCategoriesProvider);

    return Scaffold(
      backgroundColor: AppColors.scaffoldDark,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: const Text(
          'Services',
          style: TextStyle(color: AppColors.textPrimaryDark),
        ),
        iconTheme: const IconThemeData(color: AppColors.textPrimaryDark),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () => _showSearchSheet(),
          ),
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () => _showFilterSheet(),
          ),
        ],
      ),
      body: Column(
        children: [
          // Categories horizontal list
          categoriesAsync.when(
            data: (categories) => SizedBox(
              height: 50,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: categories.length + 1,
                itemBuilder: (context, index) {
                  if (index == 0) {
                    return _CategoryChip(
                      label: 'All',
                      isSelected: _selectedCategory == null,
                      onTap: () {
                        setState(() => _selectedCategory = null);
                        ref.read(servicesNotifierProvider.notifier).clearFilter();
                      },
                    );
                  }
                  final category = categories[index - 1];
                  return _CategoryChip(
                    label: category,
                    isSelected: _selectedCategory == category,
                    onTap: () {
                      setState(() => _selectedCategory = category);
                      ref.read(servicesNotifierProvider.notifier).applyFilter(
                            ServiceFilter(category: category),
                          );
                    },
                  );
                },
              ),
            ),
            loading: () => const SizedBox(height: 50),
            error: (_, __) => const SizedBox(height: 50),
          ),
          const SizedBox(height: 8),
          // Services list
          Expanded(
            child: _buildBody(servicesState),
          ),
        ],
      ),
    );
  }

  Widget _buildBody(ServicesState state) {
    if (state.isLoading && state.services.isEmpty) {
      return const LoadingWidget();
    }

    if (state.errorMessage != null && state.services.isEmpty) {
      return AppErrorWidget(
        message: state.errorMessage!,
        onRetry: () => ref.read(servicesNotifierProvider.notifier).refresh(),
      );
    }

    if (state.services.isEmpty) {
      return const EmptyStateWidget(
        title: 'No services found',
        subtitle: 'Check back later or try different filters',
        icon: Icons.miscellaneous_services,
      );
    }

    return RefreshIndicator(
      onRefresh: () => ref.read(servicesNotifierProvider.notifier).refresh(),
      child: ListView.builder(
        controller: _scrollController,
        padding: const EdgeInsets.all(16),
        itemCount: state.services.length + (state.hasMore ? 1 : 0),
        itemBuilder: (context, index) {
          if (index == state.services.length) {
            return const Padding(
              padding: EdgeInsets.all(16),
              child: Center(child: CircularProgressIndicator()),
            );
          }

          return _ServiceCard(
            service: state.services[index],
            onTap: () => context.push('/services/${state.services[index].id}'),
          );
        },
      ),
    );
  }

  void _showSearchSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surfaceDark,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                autofocus: true,
                style: const TextStyle(color: AppColors.textPrimaryDark),
                decoration: InputDecoration(
                  hintText: 'Search services...',
                  hintStyle: const TextStyle(color: AppColors.textMutedDark),
                  prefixIcon: const Icon(Icons.search, color: AppColors.textMutedDark),
                  filled: true,
                  fillColor: AppColors.cardDark,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
                onSubmitted: (query) {
                  Navigator.pop(context);
                  ref.read(servicesNotifierProvider.notifier).applyFilter(
                        ServiceFilter(searchQuery: query),
                      );
                },
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  void _showFilterSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surfaceDark,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Sort By',
              style: TextStyle(
                color: AppColors.textPrimaryDark,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _FilterOption(
              label: 'Price: Low to High',
              icon: Icons.arrow_upward,
              onTap: () {
                Navigator.pop(context);
                ref.read(servicesNotifierProvider.notifier).applyFilter(
                      const ServiceFilter(sortBy: 'price_asc'),
                    );
              },
            ),
            _FilterOption(
              label: 'Price: High to Low',
              icon: Icons.arrow_downward,
              onTap: () {
                Navigator.pop(context);
                ref.read(servicesNotifierProvider.notifier).applyFilter(
                      const ServiceFilter(sortBy: 'price_desc'),
                    );
              },
            ),
            _FilterOption(
              label: 'Highest Rated',
              icon: Icons.star,
              onTap: () {
                Navigator.pop(context);
                ref.read(servicesNotifierProvider.notifier).applyFilter(
                      const ServiceFilter(sortBy: 'rating'),
                    );
              },
            ),
            _FilterOption(
              label: 'Most Popular',
              icon: Icons.trending_up,
              onTap: () {
                Navigator.pop(context);
                ref.read(servicesNotifierProvider.notifier).applyFilter(
                      const ServiceFilter(sortBy: 'popular'),
                    );
              },
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}

class _CategoryChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _CategoryChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          gradient: isSelected
              ? LinearGradient(
                  colors: [AppColors.primary, AppColors.primaryLight],
                )
              : null,
          color: isSelected ? null : AppColors.surfaceDark,
          borderRadius: BorderRadius.circular(20),
          border: isSelected ? null : Border.all(color: AppColors.grey600),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              color: isSelected ? Colors.white : AppColors.textSecondaryDark,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
        ),
      ),
    );
  }
}

class _FilterOption extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onTap;

  const _FilterOption({
    required this.label,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: AppColors.textSecondaryDark),
      title: Text(
        label,
        style: const TextStyle(color: AppColors.textPrimaryDark),
      ),
      onTap: onTap,
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
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: AppColors.cardDark,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
              child: Container(
                height: 150,
                width: double.infinity,
                color: AppColors.grey700,
                child: service.images.isNotEmpty
                    ? Image.network(
                        service.images.first,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => const Center(
                          child: Icon(
                            Icons.miscellaneous_services,
                            size: 48,
                            color: AppColors.grey500,
                          ),
                        ),
                      )
                    : const Center(
                        child: Icon(
                          Icons.miscellaneous_services,
                          size: 48,
                          color: AppColors.grey500,
                        ),
                      ),
              ),
            ),
            // Content
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          service.name,
                          style: const TextStyle(
                            color: AppColors.textPrimaryDark,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (service.isFeatured)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.warning.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.star,
                                size: 14,
                                color: AppColors.warning,
                              ),
                              SizedBox(width: 4),
                              Text(
                                'Featured',
                                style: TextStyle(
                                  color: AppColors.warning,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  if (service.supplierName != null)
                    Text(
                      'by ${service.supplierName}',
                      style: const TextStyle(
                        color: AppColors.textSecondaryDark,
                        fontSize: 14,
                      ),
                    ),
                  const SizedBox(height: 8),
                  // Category
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      service.category,
                      style: const TextStyle(
                        color: AppColors.primary,
                        fontSize: 12,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  // Price and Rating
                  Row(
                    children: [
                      Text(
                        '\$${service.price.toStringAsFixed(2)}',
                        style: const TextStyle(
                          color: AppColors.primary,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        ' / ${service.priceUnit}',
                        style: const TextStyle(
                          color: AppColors.textSecondaryDark,
                          fontSize: 14,
                        ),
                      ),
                      const Spacer(),
                      const Icon(
                        Icons.star,
                        color: AppColors.warning,
                        size: 18,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        service.rating.toStringAsFixed(1),
                        style: const TextStyle(
                          color: AppColors.textPrimaryDark,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        ' (${service.reviewsCount})',
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
          ],
        ),
      ),
    );
  }
}
