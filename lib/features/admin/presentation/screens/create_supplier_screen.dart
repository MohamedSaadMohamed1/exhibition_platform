import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/responsive_layout.dart';
import '../../../../core/utils/validators.dart';
import '../../../../shared/models/supplier_model.dart';
import '../../../../shared/providers/providers.dart';
import '../providers/admin_provider.dart';

class CreateSupplierScreen extends ConsumerStatefulWidget {
  const CreateSupplierScreen({super.key});

  @override
  ConsumerState<CreateSupplierScreen> createState() =>
      _CreateSupplierScreenState();
}

class _CreateSupplierScreenState extends ConsumerState<CreateSupplierScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _supplierNameController = TextEditingController();
  final _descriptionController = TextEditingController();
  String _phoneNumber = '';
  String _countryCode = '+966';
  String? _selectedCategory;
  final List<String> _selectedServices = [];

  final List<String> _availableServices = [
    'Booth Setup',
    'Catering',
    'Audio/Visual',
    'Decoration',
    'Printing',
    'Furniture Rental',
    'Security',
    'Cleaning',
    'Photography',
    'Transportation',
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _supplierNameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _createSupplier() async {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedServices.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select at least one service'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    final currentUserId = ref.read(currentUserIdProvider);
    if (currentUserId == null) return;

    final success = await ref.read(adminUsersNotifierProvider.notifier).createSupplier(
          name: _nameController.text.trim(),
          phone: '$_countryCode$_phoneNumber',
          supplierName: _supplierNameController.text.trim(),
          supplierDescription: _descriptionController.text.trim(),
          services: _selectedServices,
          category: _selectedCategory,
          email: _emailController.text.trim().isNotEmpty
              ? _emailController.text.trim()
              : null,
          adminId: currentUserId,
        );

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Supplier created successfully'),
          backgroundColor: AppColors.success,
        ),
      );
      context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(adminUsersNotifierProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Supplier'),
      ),
      body: ResponsiveConstrainedBox(
        maxWidth: AppDimensions.maxWidthTablet,
        child: SingleChildScrollView(
        padding: EdgeInsets.all(AppDimensions.spacingLg.w),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Info Card
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.supplierColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.store,
                      color: AppColors.supplierColor,
                      size: 32,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Supplier Account',
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium
                                ?.copyWith(fontWeight: FontWeight.bold),
                          ),
                          Text(
                            'Suppliers can showcase their services and apply for event jobs.',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              // Section: User Details
              Text(
                'User Details',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const Divider(),
              const SizedBox(height: 12),
              // Name
              Text('Contact Name *', style: Theme.of(context).textTheme.titleSmall),
              const SizedBox(height: 8),
              TextFormField(
                controller: _nameController,
                textCapitalization: TextCapitalization.words,
                decoration: InputDecoration(
                  hintText: 'Enter contact person name',
                  prefixIcon: const Icon(Icons.person_outline),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                validator: Validators.validateName,
              ),
              const SizedBox(height: 16),
              // Phone
              Text('Phone Number *', style: Theme.of(context).textTheme.titleSmall),
              const SizedBox(height: 8),
              IntlPhoneField(
                decoration: InputDecoration(
                  hintText: 'Enter phone number',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                initialCountryCode: 'SA',
                onChanged: (phone) {
                  _phoneNumber = phone.number;
                  _countryCode = phone.countryCode;
                },
                validator: (value) {
                  if (value == null || value.number.isEmpty) {
                    return 'Phone number is required';
                  }
                  final dialCode = value.countryCode.startsWith('+')
                      ? value.countryCode
                      : '+${value.countryCode}';
                  return Validators.validateLocalPhone(value.number, dialCode);
                },
              ),
              const SizedBox(height: 16),
              // Email
              Text('Email (Optional)', style: Theme.of(context).textTheme.titleSmall),
              const SizedBox(height: 8),
              TextFormField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  hintText: 'Enter email address',
                  prefixIcon: const Icon(Icons.email_outlined),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              // Section: Business Details
              Text(
                'Business Details',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const Divider(),
              const SizedBox(height: 12),
              // Supplier Name
              Text('Business Name *', style: Theme.of(context).textTheme.titleSmall),
              const SizedBox(height: 8),
              TextFormField(
                controller: _supplierNameController,
                textCapitalization: TextCapitalization.words,
                decoration: InputDecoration(
                  hintText: 'Enter business/company name',
                  prefixIcon: const Icon(Icons.business),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                validator: (value) =>
                    Validators.validateRequired(value, 'Business name'),
              ),
              const SizedBox(height: 16),
              // Category
              Text('Category', style: Theme.of(context).textTheme.titleSmall),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: _selectedCategory,
                decoration: InputDecoration(
                  hintText: 'Select category',
                  prefixIcon: const Icon(Icons.category),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                items: SupplierCategories.all
                    .map((cat) => DropdownMenuItem(
                          value: cat,
                          child: Text(cat),
                        ))
                    .toList(),
                onChanged: (value) {
                  setState(() => _selectedCategory = value);
                },
              ),
              const SizedBox(height: 16),
              // Description
              Text('Description *', style: Theme.of(context).textTheme.titleSmall),
              const SizedBox(height: 8),
              TextFormField(
                controller: _descriptionController,
                maxLines: 3,
                decoration: InputDecoration(
                  hintText: 'Describe your business...',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                validator: (value) =>
                    Validators.validateRequired(value, 'Description'),
              ),
              const SizedBox(height: 16),
              // Services
              Text('Services *', style: Theme.of(context).textTheme.titleSmall),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _availableServices.map((service) {
                  final isSelected = _selectedServices.contains(service);
                  return FilterChip(
                    label: Text(service),
                    selected: isSelected,
                    onSelected: (selected) {
                      setState(() {
                        if (selected) {
                          _selectedServices.add(service);
                        } else {
                          _selectedServices.remove(service);
                        }
                      });
                    },
                    selectedColor: AppColors.supplierColor.withOpacity(0.2),
                    checkmarkColor: AppColors.supplierColor,
                  );
                }).toList(),
              ),
              const SizedBox(height: 32),
              // Create Button
              AppButton(
                text: 'Create Supplier',
                isLoading: state.isLoading,
                onPressed: _createSupplier,
              ),
            ],
          ),
        ),
        ),
      ),
    );
  }
}
