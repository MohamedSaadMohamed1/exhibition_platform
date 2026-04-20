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
import '../../../../shared/providers/providers.dart';
import '../providers/admin_provider.dart';

class CreateOrganizerScreen extends ConsumerStatefulWidget {
  const CreateOrganizerScreen({super.key});

  @override
  ConsumerState<CreateOrganizerScreen> createState() =>
      _CreateOrganizerScreenState();
}

class _CreateOrganizerScreenState extends ConsumerState<CreateOrganizerScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  String _phoneNumber = '';
  String _countryCode = '+966';

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _createOrganizer() async {
    if (!_formKey.currentState!.validate()) return;

    final currentUserId = ref.read(currentUserIdProvider);
    if (currentUserId == null) return;

    final success = await ref.read(adminUsersNotifierProvider.notifier).createOrganizer(
          name: _nameController.text.trim(),
          phone: '$_countryCode$_phoneNumber',
          email: _emailController.text.trim().isNotEmpty
              ? _emailController.text.trim()
              : null,
          adminId: currentUserId,
        );

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Organizer created successfully'),
          backgroundColor: AppColors.success,
        ),
      );
      context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(adminUsersNotifierProvider);

    ref.listen(adminUsersNotifierProvider, (previous, next) {
      if (next.errorMessage != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.errorMessage!),
            backgroundColor: AppColors.error,
          ),
        );
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Organizer'),
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
                  color: AppColors.organizerColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.business,
                      color: AppColors.organizerColor,
                      size: 32,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Organizer Account',
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium
                                ?.copyWith(fontWeight: FontWeight.bold),
                          ),
                          Text(
                            'Organizers can create and manage events, booths, and approve bookings.',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              // Name
              Text(
                'Full Name *',
                style: Theme.of(context).textTheme.titleSmall,
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _nameController,
                textCapitalization: TextCapitalization.words,
                decoration: InputDecoration(
                  hintText: 'Enter organizer name',
                  prefixIcon: const Icon(Icons.person_outline),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                validator: Validators.validateName,
              ),
              const SizedBox(height: 20),
              // Phone
              Text(
                'Phone Number *',
                style: Theme.of(context).textTheme.titleSmall,
              ),
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
              const SizedBox(height: 20),
              // Email
              Text(
                'Email (Optional)',
                style: Theme.of(context).textTheme.titleSmall,
              ),
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
                validator: (value) {
                  if (value != null && value.isNotEmpty) {
                    return Validators.validateEmail(value);
                  }
                  return null;
                },
              ),
              const SizedBox(height: 32),
              // Create Button
              AppButton(
                text: 'Create Organizer',
                isLoading: state.isLoading,
                onPressed: _createOrganizer,
              ),
              const SizedBox(height: 16),
              // Note
              Text(
                'Note: The organizer will be able to login using the provided phone number.',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.textSecondary,
                    ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
        ),
      ),
    );
  }
}
