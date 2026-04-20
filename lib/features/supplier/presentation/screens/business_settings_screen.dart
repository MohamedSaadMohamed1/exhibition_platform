import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/widgets/responsive_layout.dart';
import '../../../../shared/models/supplier_model.dart';
import '../../../../shared/models/service_model.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/constants/enums.dart';
import '../../../../core/services/image_upload_service.dart';
import '../providers/supplier_dashboard_provider.dart';

class BusinessSettingsScreen extends ConsumerStatefulWidget {
  const BusinessSettingsScreen({super.key});

  @override
  ConsumerState<BusinessSettingsScreen> createState() => _BusinessSettingsScreenState();
}

class _BusinessSettingsScreenState extends ConsumerState<BusinessSettingsScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _addressController;
  late final TextEditingController _phoneController;
  late final TextEditingController _emailController;
  late final TextEditingController _websiteController;

  String? _selectedCategory;
  List<String> _existingImages = [];
  List<XFile> _newImages = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _descriptionController = TextEditingController();
    _addressController = TextEditingController();
    _phoneController = TextEditingController();
    _emailController = TextEditingController();
    _websiteController = TextEditingController();
    
    // Defer initialization to after first build so we can read the provider safely
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initData();
    });
  }
  
  void _initData() {
    final currentSupplier = ref.read(currentSupplierProvider).valueOrNull;
    if (currentSupplier != null) {
      setState(() {
        _nameController.text = currentSupplier.name;
        _descriptionController.text = currentSupplier.description;
        _addressController.text = currentSupplier.address ?? '';
        _phoneController.text = currentSupplier.contactPhone ?? '';
        _emailController.text = currentSupplier.contactEmail ?? '';
        _websiteController.text = currentSupplier.website ?? '';
        _selectedCategory = currentSupplier.category;
        _existingImages = List.from(currentSupplier.images);
      });
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _addressController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _websiteController.dispose();
    super.dispose();
  }

  Future<void> _pickImages() async {
    final picker = ImagePicker();
    final images = await picker.pickMultiImage(
      imageQuality: 80,
      maxWidth: 1920,
    );
    if (images.isNotEmpty) {
      setState(() {
        _newImages.addAll(images);
      });
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedCategory == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a business category'), backgroundColor: AppColors.error),
      );
      return;
    }

    final currentSupplier = ref.read(currentSupplierProvider).valueOrNull;
    if (currentSupplier == null) return;

    setState(() => _isLoading = true);

    try {
      final uploadService = ref.read(imageUploadServiceProvider);
      List<String> finalUrls = [..._existingImages];

      // Upload new images
      for (final file in _newImages) {
        if (kIsWeb) {
          final bytes = await file.readAsBytes();
          final result = await uploadService.uploadImageFromBytes(
            bytes: bytes,
            storagePath: '${StoragePaths.supplierImages}/${currentSupplier.id}',
            fileName: file.name,
          );
           finalUrls.add(result.url);
        } else {
          final result = await uploadService.uploadSupplierImage(
            file: File(file.path),
            supplierId: currentSupplier.id,
          );
          finalUrls.add(result.url);
        }
      }

      // Update document
      final updatedSupplier = currentSupplier.copyWith(
        name: _nameController.text.trim(),
        description: _descriptionController.text.trim(),
        category: _selectedCategory,
        address: _addressController.text.trim().isEmpty ? null : _addressController.text.trim(),
        contactPhone: _phoneController.text.trim().isEmpty ? null : _phoneController.text.trim(),
        contactEmail: _emailController.text.trim().isEmpty ? null : _emailController.text.trim(),
        website: _websiteController.text.trim().isEmpty ? null : _websiteController.text.trim(),
        images: finalUrls,
      );

      // Using the provider method if exists, or just direct Firestore update
      final docRef = FirebaseFirestore.instance.collection(FirestoreCollections.suppliers).doc(currentSupplier.id);
      await docRef.update(updatedSupplier.toUpdateMap());

      // Invalidate to refresh UI
      ref.invalidate(currentSupplierProvider);
      ref.invalidate(userSuppliersProvider);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Business profile updated successfully!'), backgroundColor: AppColors.success),
        );
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
           SnackBar(content: Text('Failed to update: $e'), backgroundColor: AppColors.error),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      appBar: AppBar(
        backgroundColor: AppColors.surfaceDark,
        elevation: 0,
        title: const Text('Business Settings', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: ResponsiveConstrainedBox(
        maxWidth: AppDimensions.maxWidthMobile,
        child: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: EdgeInsets.all(AppDimensions.spacingLg.w),
              child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Images Section
                  const Text('Business Images (Logo / Cover)', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  SizedBox(
                    height: 100,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      children: [
                        // Add Button
                        GestureDetector(
                          onTap: _pickImages,
                          child: Container(
                            width: 100,
                            margin: const EdgeInsets.only(right: 12),
                            decoration: BoxDecoration(
                              color: AppColors.surfaceDark,
                              border: Border.all(color: AppColors.supplierColor.withOpacity(0.5)),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.add_photo_alternate, color: AppColors.supplierColor),
                                SizedBox(height: 4),
                                Text('Add Photo', style: TextStyle(color: AppColors.supplierColor, fontSize: 12)),
                              ],
                            ),
                          ),
                        ),
                        // Existing Network Images
                        ..._existingImages.asMap().entries.map((entry) {
                           return Stack(
                             children: [
                               Container(
                                 width: 100,
                                 margin: const EdgeInsets.only(right: 12),
                                 decoration: BoxDecoration(
                                   borderRadius: BorderRadius.circular(12),
                                   image: DecorationImage(image: NetworkImage(entry.value), fit: BoxFit.cover),
                                 ),
                               ),
                               Positioned(
                                 top: 4,
                                 right: 16,
                                 child: GestureDetector(
                                   onTap: () => setState(() => _existingImages.removeAt(entry.key)),
                                   child: Container(
                                     padding: const EdgeInsets.all(4),
                                     decoration: const BoxDecoration(color: Colors.black54, shape: BoxShape.circle),
                                     child: const Icon(Icons.close, color: Colors.white, size: 14),
                                   ),
                                 ),
                               ),
                             ],
                           );
                        }),
                        // New Local Images
                        ..._newImages.asMap().entries.map((entry) {
                           return Stack(
                             children: [
                               Container(
                                 width: 100,
                                 margin: const EdgeInsets.only(right: 12),
                                 decoration: BoxDecoration(
                                   borderRadius: BorderRadius.circular(12),
                                   image: DecorationImage(
                                     image: kIsWeb 
                                         ? NetworkImage(entry.value.path) 
                                         : FileImage(File(entry.value.path)) as ImageProvider, 
                                     fit: BoxFit.cover,
                                   ),
                                 ),
                               ),
                               Positioned(
                                 top: 4,
                                 right: 16,
                                 child: GestureDetector(
                                   onTap: () => setState(() => _newImages.removeAt(entry.key)),
                                   child: Container(
                                     padding: const EdgeInsets.all(4),
                                     decoration: const BoxDecoration(color: Colors.black54, shape: BoxShape.circle),
                                     child: const Icon(Icons.close, color: Colors.white, size: 14),
                                   ),
                                 ),
                               ),
                             ],
                           );
                        }),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Business Details
                  _buildLabel('Business Name'),
                  _buildTextField(
                    controller: _nameController,
                    hint: 'e.g. Elite Catering Co.',
                    validator: (v) => v?.trim().isEmpty == true ? 'Business name is required' : null,
                  ),
                  const SizedBox(height: 20),

                  _buildLabel('Category'),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceDark,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.grey800),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: _selectedCategory,
                        hint: const Text('Select Category', style: TextStyle(color: AppColors.textMutedDark)),
                        isExpanded: true,
                        dropdownColor: AppColors.surfaceDark,
                        style: const TextStyle(color: AppColors.textPrimaryDark),
                        items: ServiceCategories.all
                            .where((cat) => cat != 'All')
                            .map((cat) => DropdownMenuItem(value: cat, child: Text(cat)))
                            .toList(),
                        onChanged: (v) => setState(() => _selectedCategory = v),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  _buildLabel('Description'),
                  _buildTextField(
                    controller: _descriptionController,
                    hint: 'Describe your business',
                    maxLines: 4,
                    validator: (v) => v?.trim().isEmpty == true ? 'Description is required' : null,
                  ),
                  const SizedBox(height: 20),

                  _buildLabel('Address'),
                  _buildTextField(
                    controller: _addressController,
                    hint: 'Physical location of your business',
                  ),
                  const SizedBox(height: 20),

                  _buildLabel('Contact Phone'),
                  _buildTextField(
                    controller: _phoneController,
                    hint: '+1 234 567 8900',
                    keyboardType: TextInputType.phone,
                  ),
                  const SizedBox(height: 20),

                  _buildLabel('Contact Email'),
                  _buildTextField(
                    controller: _emailController,
                    hint: 'contact@business.com',
                    keyboardType: TextInputType.emailAddress,
                  ),
                  const SizedBox(height: 20),

                  _buildLabel('Website / Link'),
                  _buildTextField(
                    controller: _websiteController,
                    hint: 'https://...',
                    keyboardType: TextInputType.url,
                  ),
                  const SizedBox(height: 48),

                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      onPressed: _submit,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.supplierColor,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: const Text('Save Business Profile', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                    ),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        text,
        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 14),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    int maxLines = 1,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: keyboardType,
      validator: validator,
      style: const TextStyle(color: AppColors.textPrimaryDark),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: AppColors.textMutedDark),
        filled: true,
        fillColor: AppColors.surfaceDark,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: AppColors.grey800)),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: AppColors.grey800)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.supplierColor)),
      ),
    );
  }
}
