import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/loading_widget.dart';
import '../../../../core/widgets/error_widget.dart';
import '../../../../shared/models/supplier_model.dart';
import '../providers/supplier_provider.dart';

class SuppliersScreen extends ConsumerStatefulWidget {
  const SuppliersScreen({super.key});

  @override
  ConsumerState<SuppliersScreen> createState() => _SuppliersScreenState();
}

class _SuppliersScreenState extends ConsumerState<SuppliersScreen> {
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
      ref.read(suppliersNotifierProvider.notifier).loadMore();
    }
  }

  @override
  Widget build(BuildContext context) {
    final suppliersState = ref.watch(suppliersNotifierProvider);
    final categoriesAsync = ref.watch(supplierCategoriesProvider);

    return Scaffold(
      backgroundColor: AppColors.scaffoldDark,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: const Text(
          'Suppliers',
          style: TextStyle(color: AppColors.textPrimaryDark),
        ),
        iconTheme: const IconThemeData(color: AppColors.textPrimaryDark),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () => _showSearchSheet(),
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
                        ref.read(suppliersNotifierProvider.notifier).clearFilter();
                      },
                    );
                  }
                  final category = categories[index - 1];
                  return _CategoryChip(
                    label: category,
                    isSelected: _selectedCategory == category,
                    onTap: () {
                      setState(() => _selectedCategory = category);
                      ref.read(suppliersNotifierProvider.notifier).applyFilter(
                            SupplierFilter(category: category),
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
          // Suppliers list
          Expanded(
            child: _buildBody(suppliersState),
          ),
        ],
      ),
    );
  }

  Widget _buildBody(SuppliersState state) {
    if (state.isLoading && state.suppliers.isEmpty) {
      return const LoadingWidget();
    }

    if (state.errorMessage != null && state.suppliers.isEmpty) {
      return AppErrorWidget(
        message: state.errorMessage!,
        onRetry: () => ref.read(suppliersNotifierProvider.notifier).refresh(),
      );
    }

    if (state.suppliers.isEmpty) {
      return const EmptyStateWidget(
        title: 'No suppliers found',
        subtitle: 'Check back later or try different filters',
        icon: Icons.store,
      );
    }

    return RefreshIndicator(
      onRefresh: () => ref.read(suppliersNotifierProvider.notifier).refresh(),
      child: ListView.builder(
        controller: _scrollController,
        padding: const EdgeInsets.all(16),
        itemCount: state.suppliers.length + (state.hasMore ? 1 : 0),
        itemBuilder: (context, index) {
          if (index == state.suppliers.length) {
            return const Padding(
              padding: EdgeInsets.all(16),
              child: Center(child: CircularProgressIndicator()),
            );
          }

          return _SupplierCard(
            supplier: state.suppliers[index],
            onTap: () => context.push('/suppliers/${state.suppliers[index].id}'),
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
                  hintText: 'Search suppliers...',
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
                  ref.read(suppliersNotifierProvider.notifier).applyFilter(
                        SupplierFilter(searchQuery: query),
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

class _SupplierCard extends StatelessWidget {
  final SupplierModel supplier;
  final VoidCallback onTap;

  const _SupplierCard({
    required this.supplier,
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
                child: supplier.coverImage != null
                    ? Image.network(
                        supplier.coverImage!,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => const Center(
                          child: Icon(
                            Icons.store,
                            size: 48,
                            color: AppColors.grey500,
                          ),
                        ),
                      )
                    : const Center(
                        child: Icon(
                          Icons.store,
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
                          supplier.businessName,
                          style: const TextStyle(
                            color: AppColors.textPrimaryDark,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (supplier.isVerified)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.success.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.verified,
                                size: 14,
                                color: AppColors.success,
                              ),
                              SizedBox(width: 4),
                              Text(
                                'Verified',
                                style: TextStyle(
                                  color: AppColors.success,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  // Categories
                  if (supplier.categories.isNotEmpty)
                    Wrap(
                      spacing: 8,
                      children: supplier.categories.take(3).map((cat) {
                        return Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            cat,
                            style: const TextStyle(
                              color: AppColors.primary,
                              fontSize: 12,
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  const SizedBox(height: 12),
                  // Rating and stats
                  Row(
                    children: [
                      const Icon(
                        Icons.star,
                        color: AppColors.warning,
                        size: 18,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        supplier.rating.toStringAsFixed(1),
                        style: const TextStyle(
                          color: AppColors.textPrimaryDark,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        ' (${supplier.reviewsCount})',
                        style: const TextStyle(
                          color: AppColors.textSecondaryDark,
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(width: 16),
                      const Icon(
                        Icons.shopping_bag_outlined,
                        color: AppColors.textSecondaryDark,
                        size: 18,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${supplier.ordersCount} orders',
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
