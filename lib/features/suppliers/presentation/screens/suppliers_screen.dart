import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
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

    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      appBar: AppBar(
        backgroundColor: AppColors.surfaceDark,
        elevation: 0,
        title: const Text(
          'Suppliers',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () => _showSearchSheet(),
          ),
        ],
      ),
      body: Column(
        children: [
          // Explore Suppliers Title
          Padding(
            padding: EdgeInsets.fromLTRB(AppDimensions.spacingLg.w, AppDimensions.spacingLg.h, AppDimensions.spacingLg.w, AppDimensions.spacingSm.h),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Explore Suppliers',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          // Category Filter Chips
          SizedBox(
            height: 50.h,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: EdgeInsets.symmetric(horizontal: AppDimensions.spacingLg.w),
              children: [
                _CategoryChip(
                  label: 'All',
                  isSelected: _selectedCategory == null,
                  onTap: () {
                    setState(() {
                      _selectedCategory = null;
                    });
                    ref.read(suppliersNotifierProvider.notifier).applyFilter(
                          const SupplierFilter(),
                        );
                  },
                ),
                _CategoryChip(
                  label: 'Catering',
                  isSelected: _selectedCategory == 'Catering',
                  onTap: () {
                    setState(() {
                      _selectedCategory = 'Catering';
                    });
                    ref.read(suppliersNotifierProvider.notifier).applyFilter(
                          const SupplierFilter(category: 'Catering'),
                        );
                  },
                ),
                _CategoryChip(
                  label: 'Decoration',
                  isSelected: _selectedCategory == 'Decoration',
                  onTap: () {
                    setState(() {
                      _selectedCategory = 'Decoration';
                    });
                    ref.read(suppliersNotifierProvider.notifier).applyFilter(
                          const SupplierFilter(category: 'Decoration'),
                        );
                  },
                ),
                _CategoryChip(
                  label: 'Photography',
                  isSelected: _selectedCategory == 'Photography',
                  onTap: () {
                    setState(() {
                      _selectedCategory = 'Photography';
                    });
                    ref.read(suppliersNotifierProvider.notifier).applyFilter(
                          const SupplierFilter(category: 'Photography'),
                        );
                  },
                ),
                _CategoryChip(
                  label: 'Audio & Visual',
                  isSelected: _selectedCategory == 'Audio & Visual',
                  onTap: () {
                    setState(() {
                      _selectedCategory = 'Audio & Visual';
                    });
                    ref.read(suppliersNotifierProvider.notifier).applyFilter(
                          const SupplierFilter(category: 'Audio & Visual'),
                        );
                  },
                ),
              ],
            ),
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
        padding: EdgeInsets.all(AppDimensions.spacingLg.w),
        itemCount: state.suppliers.length + (state.hasMore ? 1 : 0),
        itemBuilder: (context, index) {
          if (index == state.suppliers.length) {
            return Padding(
              padding: EdgeInsets.all(AppDimensions.spacingLg.r),
              child: const Center(child: CircularProgressIndicator()),
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
          color: AppColors.surfaceDark,
          borderRadius: BorderRadius.circular(20),
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Cover Image with Logo Overlay
            Stack(
              clipBehavior: Clip.none,
              children: [
                // Cover Image
                SizedBox(
                  height: 180,
                  width: double.infinity,
                  child: supplier.images.isNotEmpty
                      ? Image.network(
                          supplier.images.first,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Container(
                            color: AppColors.grey800,
                            child: const Center(
                              child: Icon(Icons.store, size: 48, color: AppColors.grey600),
                            ),
                          ),
                        )
                      : Container(
                          color: AppColors.grey800,
                          child: const Center(
                            child: Icon(Icons.store, size: 48, color: AppColors.grey600),
                          ),
                        ),
                ),
                // Verified Badge
                if (supplier.isVerified)
                  Positioned(
                    right: 12,
                    top: 12,
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: AppColors.success,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.verified, color: Colors.white, size: 18),
                    ),
                  ),
                // Logo overlapping bottom of image
                Positioned(
                  left: 16,
                  bottom: -28,
                  child: Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(14),
                      child: supplier.images.length > 1
                          ? Image.network(
                              supplier.images[1],
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) =>
                                  const Icon(Icons.store, color: AppColors.primary, size: 30),
                            )
                          : const Icon(Icons.store, color: AppColors.primary, size: 30),
                    ),
                  ),
                ),
              ],
            ),
            // Spacing to account for overlapping logo
            const SizedBox(height: 36),
            // Supplier Info
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    supplier.name,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      const Icon(Icons.star, color: Colors.amber, size: 16),
                      const SizedBox(width: 4),
                      Text(
                        supplier.rating.toStringAsFixed(1),
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '(${supplier.reviewCount} reviews)',
                        style: const TextStyle(color: AppColors.textSecondaryDark, fontSize: 13),
                      ),
                    ],
                  ),
                  if (supplier.description.isNotEmpty) ...[
                    const SizedBox(height: 6),
                    Text(
                      supplier.description,
                      style: const TextStyle(color: AppColors.textSecondaryDark, fontSize: 13),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                  if (supplier.category != null) ...[
                    const SizedBox(height: 10),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                      decoration: BoxDecoration(
                        border: Border.all(color: AppColors.textSecondaryDark),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        supplier.category!,
                        style: const TextStyle(color: Colors.white, fontSize: 13),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ServiceTag extends StatelessWidget {
  final String label;

  const _ServiceTag({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.primary.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: AppColors.primary,
          fontSize: 12,
          fontWeight: FontWeight.w500,
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
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (_) => onTap(),
        backgroundColor: AppColors.surfaceDark,
        selectedColor: AppColors.primary,
        labelStyle: TextStyle(
          color: isSelected ? Colors.white : AppColors.textSecondaryDark,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(
            color: isSelected ? AppColors.primary : AppColors.grey700,
            width: 1,
          ),
        ),
        showCheckmark: false,
      ),
    );
  }
}
