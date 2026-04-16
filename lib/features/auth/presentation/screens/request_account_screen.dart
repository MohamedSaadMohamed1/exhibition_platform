import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/constants/enums.dart';
import '../widgets/auth_background.dart';
import '../widgets/glassmorphic_card.dart';
import '../widgets/country_picker.dart';
import '../providers/request_account_provider.dart';

class RequestAccountScreen extends ConsumerStatefulWidget {
  const RequestAccountScreen({super.key});

  @override
  ConsumerState<RequestAccountScreen> createState() => _RequestAccountScreenState();
}

class _RequestAccountScreenState extends ConsumerState<RequestAccountScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _companyController = TextEditingController();
  final _notesController = TextEditingController();
  
  String _selectedCountryCode = '+965';
  String _selectedCountryFlag = '🇰🇼';
  UserRole _selectedRole = UserRole.organizer;

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _companyController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _onCountrySelected(String code, String flag, String country) {
    setState(() {
      _selectedCountryCode = code;
      _selectedCountryFlag = flag;
    });
  }

  void _showCountryPicker() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => CountryPickerSheet(
        onCountrySelected: _onCountrySelected,
      ),
    );
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    
    final phone = _phoneController.text.trim();
    if (phone.isEmpty || phone.length < 8) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a valid phone number'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    final success = await ref.read(requestAccountProvider.notifier).submitRequest(
      name: _nameController.text.trim(),
      phone: '$_selectedCountryCode$phone',
      email: _emailController.text.trim().isNotEmpty ? _emailController.text.trim() : null,
      requestedRole: _selectedRole,
      companyName: _companyController.text.trim().isNotEmpty ? _companyController.text.trim() : null,
      notes: _notesController.text.trim().isNotEmpty ? _notesController.text.trim() : null,
    );

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Request sent successfully! Admin will review it shortly.'),
          backgroundColor: AppColors.success,
        ),
      );
      context.pop();
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to send request. Please try again.'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  Widget _buildTextField(
    TextEditingController controller,
    String label, {
    TextInputType keyboardType = TextInputType.text,
    IconData? icon,
    int maxLines = 1,
    bool isRequired = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label + (isRequired ? ' *' : ''),
            style: TextStyle(
              fontSize: 14,
              color: Colors.white.withOpacity(0.9),
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            decoration: BoxDecoration(
              color: const Color(0xFF2A2A4A).withOpacity(0.6),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: const Color(0xFF4A4A6A).withOpacity(0.8),
                width: 1.5,
              ),
            ),
            child: TextFormField(
              controller: controller,
              keyboardType: keyboardType,
              maxLines: maxLines,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                prefixIcon: icon != null
                    ? Icon(icon, color: Colors.white.withOpacity(0.5), size: 22)
                    : null,
                border: InputBorder.none,
                contentPadding: EdgeInsets.all(maxLines > 1 ? 16 : 8),
              ),
              validator: isRequired
                  ? (value) => value == null || value.trim().isEmpty ? 'Required' : null
                  : null,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPhoneInput() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Phone Number *',
            style: TextStyle(
              fontSize: 14,
              color: Colors.white.withOpacity(0.9),
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            height: 58,
            decoration: BoxDecoration(
              color: const Color(0xFF2A2A4A).withOpacity(0.6),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: const Color(0xFF4A4A6A).withOpacity(0.8),
                width: 1.5,
              ),
            ),
            child: Row(
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 14),
                  child: Icon(
                    Icons.phone_outlined,
                    color: Colors.white.withOpacity(0.5),
                    size: 22,
                  ),
                ),
                GestureDetector(
                  onTap: _showCountryPicker,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Text(
                      _selectedCountryCode,
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.6),
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: TextFormField(
                    controller: _phoneController,
                    keyboardType: TextInputType.phone,
                    style: const TextStyle(color: Colors.white, fontSize: 16),
                    decoration: const InputDecoration(
                      hintText: '5XX XXX XXXX',
                      hintStyle: TextStyle(color: Colors.white38, fontSize: 16),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(requestAccountProvider);

    return Scaffold(
      body: AuthBackground(
        child: SafeArea(
          child: Column(
            children: [
              // Top Bar
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                      onPressed: () => context.pop(),
                    ),
                    const Text(
                      'Request Professional Account',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              
              // Form Content
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  child: GlassmorphicCard(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Join as an Organizer or Supplier',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.white.withOpacity(0.8),
                              ),
                            ),
                            const SizedBox(height: 24),
                            
                            // Role Selection
                            Text(
                              'I want to become a: *',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.white.withOpacity(0.9),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Container(
                              decoration: BoxDecoration(
                                color: const Color(0xFF2A2A4A).withOpacity(0.6),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: const Color(0xFF4A4A6A).withOpacity(0.8),
                                  width: 1.5,
                                ),
                              ),
                              padding: const EdgeInsets.symmetric(horizontal: 16),
                              child: DropdownButtonHideUnderline(
                                child: DropdownButton<UserRole>(
                                  value: _selectedRole,
                                  dropdownColor: const Color(0xFF2A2A4A),
                                  isExpanded: true,
                                  icon: const Icon(Icons.arrow_drop_down, color: Colors.white),
                                  style: const TextStyle(color: Colors.white, fontSize: 16),
                                  onChanged: (UserRole? newValue) {
                                    if (newValue != null) {
                                      setState(() {
                                        _selectedRole = newValue;
                                      });
                                    }
                                  },
                                  items: const [
                                    DropdownMenuItem(
                                      value: UserRole.organizer,
                                      child: Text('Organizer (Create events & manage booths)'),
                                    ),
                                    DropdownMenuItem(
                                      value: UserRole.supplier,
                                      child: Text('Supplier (Offer services for events)'),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),

                            _buildTextField(_nameController, 'Full Name', icon: Icons.person_outline, isRequired: true),
                            _buildPhoneInput(),
                            _buildTextField(_emailController, 'Email Address', icon: Icons.email_outlined),
                            _buildTextField(_companyController, 'Company/Business Name', icon: Icons.business),
                            _buildTextField(_notesController, 'Additional Notes / Portfolio (Optional)', maxLines: 4),
                            
                            const SizedBox(height: 24),
                            
                            // Submit Button
                            SizedBox(
                              width: double.infinity,
                              height: 56,
                              child: ElevatedButton(
                                onPressed: isLoading ? null : _submit,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.primary,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(28),
                                  ),
                                ),
                                child: isLoading
                                    ? const CircularProgressIndicator(color: Colors.white)
                                    : const Text(
                                        'Submit Request',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
