import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/enums.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/loading_widget.dart';
import '../../../../core/widgets/error_widget.dart';
import '../../../../features/booths/presentation/providers/booth_provider.dart';
import '../providers/organizer_booth_provider.dart';
import '../widgets/booth_management/booth_form_fields.dart';

class EditBoothScreen extends ConsumerStatefulWidget {
  final String eventId;
  final String boothId;

  const EditBoothScreen({
    super.key,
    required this.eventId,
    required this.boothId,
  });

  @override
  ConsumerState<EditBoothScreen> createState() => _EditBoothScreenState();
}

class _EditBoothScreenState extends ConsumerState<EditBoothScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _boothNumberController;
  late TextEditingController _categoryController;
  late TextEditingController _priceController;
  late TextEditingController _descriptionController;

  BoothSize _selectedSize = BoothSize.medium;
  List<String> _selectedAmenities = [];
  bool _isInitialized = false;

  @override
  Widget build(BuildContext context) {
    final boothAsync = ref.watch(
      boothProvider((eventId: widget.eventId, boothId: widget.boothId)),
    );
    final state = ref.watch(organizerBoothsProvider(widget.eventId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Booth'),
      ),
      body: boothAsync.when(
        data: (booth) {
          if (booth == null) {
            return const AppErrorWidget(message: 'Booth not found');
          }

          // Initialize controllers with booth data
          if (!_isInitialized) {
            _boothNumberController = TextEditingController(text: booth.boothNumber);
            _categoryController = TextEditingController(text: booth.category ?? '');
            _priceController = TextEditingController(text: booth.price.toStringAsFixed(2));
            _descriptionController = TextEditingController(text: booth.description ?? '');
            _selectedSize = booth.size;
            _selectedAmenities = List<String>.from(booth.amenities);
            _isInitialized = true;
          }

          final isBooked = booth.isBooked;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Warning if booked
                  if (isBooked)
                    Container(
                      padding: const EdgeInsets.all(16),
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        color: AppColors.warningLight,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.warning),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.warning_amber, color: AppColors.warning),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'This booth is currently booked. Editing is not recommended.',
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: AppColors.warning,
                                  ),
                            ),
                          ),
                        ],
                      ),
                    ),

                  // Status info
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: _getStatusColor(booth.status).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: _getStatusColor(booth.status).withOpacity(0.3),
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.info_outline,
                          color: _getStatusColor(booth.status),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Status: ${booth.status.value.toUpperCase()}',
                            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                  color: _getStatusColor(booth.status),
                                  fontWeight: FontWeight.bold,
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
                    onAmenitiesChanged: (amenities) =>
                        setState(() => _selectedAmenities = amenities),
                    enabled: !isBooked,
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

                  // Update button
                  if (!isBooked)
                    AppButton(
                      text: state.isUpdating ? 'Updating...' : 'Update Booth',
                      onPressed: state.isUpdating ? null : _updateBooth,
                      icon: Icons.save,
                    ),
                  const SizedBox(height: 16),

                  // Cancel button
                  OutlinedButton(
                    onPressed: state.isUpdating ? null : () => context.pop(),
                    child: const Text('Cancel'),
                  ),
                ],
              ),
            ),
          );
        },
        loading: () => const LoadingWidget(),
        error: (error, _) => AppErrorWidget(message: error.toString()),
      ),
    );
  }

  Future<void> _updateBooth() async {
    if (!_formKey.currentState!.validate()) return;

    final price = double.parse(_priceController.text);
    final notifier = ref.read(organizerBoothsProvider(widget.eventId).notifier);

    final success = await notifier.updateBooth(
      boothId: widget.boothId,
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
          content: Text('Booth updated successfully!'),
          backgroundColor: AppColors.success,
        ),
      );
      context.pop();
    }
  }

  Color _getStatusColor(BoothStatus status) {
    switch (status) {
      case BoothStatus.available:
        return AppColors.boothAvailable;
      case BoothStatus.reserved:
        return AppColors.boothReserved;
      case BoothStatus.booked:
      case BoothStatus.occupied:
        return AppColors.boothBooked;
    }
  }

  @override
  void dispose() {
    if (_isInitialized) {
      _boothNumberController.dispose();
      _categoryController.dispose();
      _priceController.dispose();
      _descriptionController.dispose();
    }
    super.dispose();
  }
}
