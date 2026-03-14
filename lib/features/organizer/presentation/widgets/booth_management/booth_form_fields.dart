import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../../core/constants/enums.dart';
import '../../../../../core/theme/app_colors.dart';

class BoothFormFields extends StatelessWidget {
  final TextEditingController boothNumberController;
  final BoothSize selectedSize;
  final TextEditingController? categoryController;
  final TextEditingController priceController;
  final List<String> selectedAmenities;
  final TextEditingController? descriptionController;
  final Function(BoothSize) onSizeChanged;
  final Function(List<String>) onAmenitiesChanged;
  final bool enabled;

  const BoothFormFields({
    super.key,
    required this.boothNumberController,
    required this.selectedSize,
    this.categoryController,
    required this.priceController,
    required this.selectedAmenities,
    this.descriptionController,
    required this.onSizeChanged,
    required this.onAmenitiesChanged,
    this.enabled = true,
  });

  static const List<String> availableAmenities = [
    'WiFi',
    'Power Outlet',
    'Display Screen',
    'Table',
    'Chair',
    'Lighting',
    'Storage',
    'Sound System',
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Booth Number
        TextFormField(
          controller: boothNumberController,
          enabled: enabled,
          decoration: const InputDecoration(
            labelText: 'Booth Number *',
            hintText: 'e.g., A-1, B-15',
            prefixIcon: Icon(Icons.tag),
            border: OutlineInputBorder(),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter a booth number';
            }
            return null;
          },
        ),
        const SizedBox(height: 16),

        // Size
        Text(
          'Booth Size *',
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: BoothSize.values.map((size) {
            return ChoiceChip(
              label: Text(_getSizeDisplayText(size)),
              selected: selectedSize == size,
              onSelected: enabled ? (selected) {
                if (selected) {
                  onSizeChanged(size);
                }
              } : null,
              selectedColor: AppColors.organizerColor.withOpacity(0.3),
              checkmarkColor: AppColors.organizerColor,
            );
          }).toList(),
        ),
        const SizedBox(height: 16),

        // Category (optional)
        if (categoryController != null)
          TextFormField(
            controller: categoryController,
            enabled: enabled,
            decoration: const InputDecoration(
              labelText: 'Category (Optional)',
              hintText: 'e.g., Technology, Art, Food',
              prefixIcon: Icon(Icons.category),
              border: OutlineInputBorder(),
            ),
          ),
        if (categoryController != null) const SizedBox(height: 16),

        // Price
        TextFormField(
          controller: priceController,
          enabled: enabled,
          keyboardType: TextInputType.number,
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
          ],
          decoration: const InputDecoration(
            labelText: 'Price *',
            hintText: 'Enter price',
            prefixText: '\$ ',
            prefixIcon: Icon(Icons.attach_money),
            border: OutlineInputBorder(),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter a price';
            }
            final price = double.tryParse(value);
            if (price == null || price <= 0) {
              return 'Please enter a valid price';
            }
            return null;
          },
        ),
        const SizedBox(height: 16),

        // Amenities
        Text(
          'Amenities',
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: availableAmenities.map((amenity) {
            final isSelected = selectedAmenities.contains(amenity);
            return FilterChip(
              label: Text(amenity),
              selected: isSelected,
              onSelected: enabled ? (selected) {
                final newAmenities = List<String>.from(selectedAmenities);
                if (selected) {
                  newAmenities.add(amenity);
                } else {
                  newAmenities.remove(amenity);
                }
                onAmenitiesChanged(newAmenities);
              } : null,
              selectedColor: AppColors.success.withOpacity(0.3),
              checkmarkColor: AppColors.success,
            );
          }).toList(),
        ),
        const SizedBox(height: 16),

        // Description (optional)
        if (descriptionController != null)
          TextFormField(
            controller: descriptionController,
            enabled: enabled,
            maxLines: 3,
            decoration: const InputDecoration(
              labelText: 'Description (Optional)',
              hintText: 'Add any additional details about this booth',
              prefixIcon: Icon(Icons.description),
              border: OutlineInputBorder(),
              alignLabelWithHint: true,
            ),
          ),
      ],
    );
  }

  String _getSizeDisplayText(BoothSize size) {
    switch (size) {
      case BoothSize.small:
        return 'Small (3x3m)';
      case BoothSize.medium:
        return 'Medium (4x4m)';
      case BoothSize.large:
        return 'Large (5x5m)';
      case BoothSize.premium:
        return 'Premium (6x6m)';
    }
  }
}
