import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../../core/constants/enums.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/widgets/app_button.dart';
import '../../../../../shared/models/booth_model.dart';
import '../../providers/organizer_booth_provider.dart';

class BatchCreateDialog extends ConsumerStatefulWidget {
  final String eventId;

  const BatchCreateDialog({super.key, required this.eventId});

  @override
  ConsumerState<BatchCreateDialog> createState() => _BatchCreateDialogState();
}

class _BatchCreateDialogState extends ConsumerState<BatchCreateDialog> {
  final _formKey = GlobalKey<FormState>();
  final _numberController = TextEditingController(text: '10');
  final _prefixController = TextEditingController(text: 'A-');
  final _startNumberController = TextEditingController(text: '1');
  final _priceController = TextEditingController();
  final _customWidthController = TextEditingController();
  final _customHeightController = TextEditingController();
  BoothSize _selectedSize = BoothSize.medium;
  List<String> _selectedAmenities = [];

  static const List<String> availableAmenities = [
    'WiFi',
    'Power Outlet',
    'Display Screen',
    'Table',
    'Chair',
    'Lighting',
  ];

  List<String> _generateBoothNumbers() {
    final count = int.tryParse(_numberController.text) ?? 0;
    final prefix = _prefixController.text;
    final startNum = int.tryParse(_startNumberController.text) ?? 1;

    return List.generate(
      count,
      (index) => '$prefix${startNum + index}',
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(organizerBoothsProvider(widget.eventId));
    final boothNumbers = _generateBoothNumbers();

    return AlertDialog(
      title: const Text('Batch Create Booths'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Number of booths
              TextFormField(
                controller: _numberController,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                decoration: const InputDecoration(
                  labelText: 'Number of Booths',
                  hintText: 'Enter count (1-50)',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  final count = int.tryParse(value ?? '');
                  if (count == null || count < 1 || count > 50) {
                    return 'Enter a number between 1 and 50';
                  }
                  return null;
                },
                onChanged: (_) => setState(() {}),
              ),
              const SizedBox(height: 16),

              // Prefix and start number
              Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: TextFormField(
                      controller: _prefixController,
                      decoration: const InputDecoration(
                        labelText: 'Prefix',
                        hintText: 'e.g., A-, B-',
                        border: OutlineInputBorder(),
                      ),
                      onChanged: (_) => setState(() {}),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    flex: 1,
                    child: TextFormField(
                      controller: _startNumberController,
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      decoration: const InputDecoration(
                        labelText: 'Start #',
                        border: OutlineInputBorder(),
                      ),
                      onChanged: (_) => setState(() {}),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Size selection
              Text(
                'Booth Size',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: BoothSize.values.map((size) {
                  return ChoiceChip(
                    label: Text(size.displayName),
                    selected: _selectedSize == size,
                    onSelected: (selected) {
                      if (selected) {
                        setState(() => _selectedSize = size);
                      }
                    },
                    selectedColor: AppColors.organizerColor.withOpacity(0.3),
                  );
                }).toList(),
              ),
              if (_selectedSize == BoothSize.custom) ...[
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _customWidthController,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
                        ],
                        decoration: const InputDecoration(
                          labelText: 'Width (m) *',
                          hintText: 'e.g., 3.5',
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (_selectedSize != BoothSize.custom) return null;
                          final v = double.tryParse(value ?? '');
                          if (v == null || v <= 0) return 'Enter valid width';
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextFormField(
                        controller: _customHeightController,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
                        ],
                        decoration: const InputDecoration(
                          labelText: 'Height (m) *',
                          hintText: 'e.g., 4.0',
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (_selectedSize != BoothSize.custom) return null;
                          final v = double.tryParse(value ?? '');
                          if (v == null || v <= 0) return 'Enter valid height';
                          return null;
                        },
                      ),
                    ),
                  ],
                ),
              ],
              const SizedBox(height: 16),

              // Price
              TextFormField(
                controller: _priceController,
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
                ],
                decoration: const InputDecoration(
                  labelText: 'Price (same for all)',
                  prefixText: 'KD ',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  final price = double.tryParse(value ?? '');
                  if (price == null || price <= 0) {
                    return 'Enter a valid price';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Amenities
              Text(
                'Amenities (same for all)',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: availableAmenities.map((amenity) {
                  final isSelected = _selectedAmenities.contains(amenity);
                  return FilterChip(
                    label: Text(amenity),
                    selected: isSelected,
                    onSelected: (selected) {
                      setState(() {
                        if (selected) {
                          _selectedAmenities.add(amenity);
                        } else {
                          _selectedAmenities.remove(amenity);
                        }
                      });
                    },
                    selectedColor: AppColors.success.withOpacity(0.3),
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),

              // Preview
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.grey800,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Preview',
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Will create ${boothNumbers.length} booths:',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      boothNumbers.take(5).join(', ') +
                          (boothNumbers.length > 5 ? '...' : ''),
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppColors.organizerColor,
                            fontWeight: FontWeight.w500,
                          ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: state.isCreating ? null : () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        AppButton(
          text: state.isCreating ? 'Creating...' : 'Create Booths',
          onPressed: state.isCreating ? null : _createBooths,
        ),
      ],
    );
  }

  Future<void> _createBooths() async {
    if (!_formKey.currentState!.validate()) return;

    final price = double.parse(_priceController.text);
    final boothNumbers = _generateBoothNumbers();
    final customWidth = _selectedSize == BoothSize.custom
        ? double.tryParse(_customWidthController.text)
        : null;
    final customHeight = _selectedSize == BoothSize.custom
        ? double.tryParse(_customHeightController.text)
        : null;

    final booths = boothNumbers.map((number) {
      return BoothModel(
        id: '', // Will be generated by Firestore
        eventId: widget.eventId,
        boothNumber: number,
        size: _selectedSize,
        price: price,
        amenities: _selectedAmenities,
        status: BoothStatus.available,
        customWidth: customWidth,
        customHeight: customHeight,
        createdAt: DateTime.now(),
      );
    }).toList();

    final notifier = ref.read(organizerBoothsProvider(widget.eventId).notifier);
    final success = await notifier.createBooths(booths: booths);

    if (mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            success
                ? '${booths.length} booths created successfully!'
                : 'Failed to create booths. ${ref.read(organizerBoothsProvider(widget.eventId)).actionError ?? ""}',
          ),
          backgroundColor: success ? AppColors.success : AppColors.error,
        ),
      );
    }
  }

  @override
  void dispose() {
    _numberController.dispose();
    _prefixController.dispose();
    _startNumberController.dispose();
    _priceController.dispose();
    _customWidthController.dispose();
    _customHeightController.dispose();
    super.dispose();
  }
}
