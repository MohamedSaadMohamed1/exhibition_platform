import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/enums.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_button.dart';
import '../providers/organizer_booth_provider.dart';
import '../widgets/booth_management/booth_form_fields.dart';

class CreateBoothScreen extends ConsumerStatefulWidget {
  final String eventId;

  const CreateBoothScreen({super.key, required this.eventId});

  @override
  ConsumerState<CreateBoothScreen> createState() => _CreateBoothScreenState();
}

class _CreateBoothScreenState extends ConsumerState<CreateBoothScreen> {
  final _formKey = GlobalKey<FormState>();
  final _boothNumberController = TextEditingController();
  final _categoryController = TextEditingController();
  final _priceController = TextEditingController();
  final _descriptionController = TextEditingController();

  BoothSize _selectedSize = BoothSize.medium;
  List<String> _selectedAmenities = [];

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(organizerBoothsProvider(widget.eventId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Booth'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Info card
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.organizerColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: AppColors.organizerColor.withOpacity(0.3),
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.info_outline,
                      color: AppColors.organizerColor,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Fill in the details below to create a new booth for your event.',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: AppColors.organizerColor,
                            ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Form fields
              BoothFormFields(
                boothNumberController: _boothNumberController,
                selectedSize: _selectedSize,
                categoryController: _categoryController,
                priceController: _priceController,
                selectedAmenities: _selectedAmenities,
                descriptionController: _descriptionController,
                onSizeChanged: (size) => setState(() => _selectedSize = size),
                onAmenitiesChanged: (amenities) => setState(() => _selectedAmenities = amenities),
              ),

              const SizedBox(height: 24),

              // Error message
              if (state.actionError != null)
                Container(
                  padding: const EdgeInsets.all(12),
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: AppColors.errorLight,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppColors.error),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.error_outline, color: AppColors.error),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          state.actionError!,
                          style: const TextStyle(color: AppColors.error),
                        ),
                      ),
                    ],
                  ),
                ),

              // Create button
              AppButton(
                text: state.isCreating ? 'Creating...' : 'Create Booth',
                onPressed: state.isCreating ? null : _createBooth,
                icon: Icons.add,
              ),
              const SizedBox(height: 16),

              // Cancel button
              OutlinedButton(
                onPressed: state.isCreating ? null : () => context.pop(),
                child: const Text('Cancel'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _createBooth() async {
    if (!_formKey.currentState!.validate()) return;

    final price = double.parse(_priceController.text);
    final notifier = ref.read(organizerBoothsProvider(widget.eventId).notifier);

    final success = await notifier.createBooth(
      boothNumber: _boothNumberController.text.trim(),
      size: _selectedSize,
      category: _categoryController.text.trim().isEmpty
          ? null
          : _categoryController.text.trim(),
      price: price,
      amenities: _selectedAmenities,
      description: _descriptionController.text.trim().isEmpty
          ? null
          : _descriptionController.text.trim(),
    );

    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Booth created successfully!'),
          backgroundColor: AppColors.success,
        ),
      );
      context.pop();
    }
  }

  @override
  void dispose() {
    _boothNumberController.dispose();
    _categoryController.dispose();
    _priceController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }
}
