import 'dart:ui';
import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

/// Country model for picker
class Country {
  final String name;
  final String code;
  final String dialCode;
  final String flag;

  const Country({
    required this.name,
    required this.code,
    required this.dialCode,
    required this.flag,
  });
}

/// List of countries (commonly used in Middle East region)
const List<Country> countries = [
  Country(name: 'Saudi Arabia', code: 'SA', dialCode: '+966', flag: '🇸🇦'),
  Country(name: 'United Arab Emirates', code: 'AE', dialCode: '+971', flag: '🇦🇪'),
  Country(name: 'Kuwait', code: 'KW', dialCode: '+965', flag: '🇰🇼'),
  Country(name: 'Qatar', code: 'QA', dialCode: '+974', flag: '🇶🇦'),
  Country(name: 'Bahrain', code: 'BH', dialCode: '+973', flag: '🇧🇭'),
  Country(name: 'Oman', code: 'OM', dialCode: '+968', flag: '🇴🇲'),
  Country(name: 'Egypt', code: 'EG', dialCode: '+20', flag: '🇪🇬'),
  Country(name: 'Jordan', code: 'JO', dialCode: '+962', flag: '🇯🇴'),
  Country(name: 'Lebanon', code: 'LB', dialCode: '+961', flag: '🇱🇧'),
  Country(name: 'Iraq', code: 'IQ', dialCode: '+964', flag: '🇮🇶'),
  Country(name: 'Syria', code: 'SY', dialCode: '+963', flag: '🇸🇾'),
  Country(name: 'Palestine', code: 'PS', dialCode: '+970', flag: '🇵🇸'),
  Country(name: 'Yemen', code: 'YE', dialCode: '+967', flag: '🇾🇪'),
  Country(name: 'Morocco', code: 'MA', dialCode: '+212', flag: '🇲🇦'),
  Country(name: 'Tunisia', code: 'TN', dialCode: '+216', flag: '🇹🇳'),
  Country(name: 'Algeria', code: 'DZ', dialCode: '+213', flag: '🇩🇿'),
  Country(name: 'Libya', code: 'LY', dialCode: '+218', flag: '🇱🇾'),
  Country(name: 'Sudan', code: 'SD', dialCode: '+249', flag: '🇸🇩'),
  Country(name: 'United States', code: 'US', dialCode: '+1', flag: '🇺🇸'),
  Country(name: 'United Kingdom', code: 'GB', dialCode: '+44', flag: '🇬🇧'),
  Country(name: 'India', code: 'IN', dialCode: '+91', flag: '🇮🇳'),
  Country(name: 'Pakistan', code: 'PK', dialCode: '+92', flag: '🇵🇰'),
  Country(name: 'Turkey', code: 'TR', dialCode: '+90', flag: '🇹🇷'),
  Country(name: 'Germany', code: 'DE', dialCode: '+49', flag: '🇩🇪'),
  Country(name: 'France', code: 'FR', dialCode: '+33', flag: '🇫🇷'),
];

/// Country picker bottom sheet with glassmorphism design
class CountryPickerSheet extends StatefulWidget {
  final Function(String dialCode, String flag, String name) onCountrySelected;

  const CountryPickerSheet({
    super.key,
    required this.onCountrySelected,
  });

  @override
  State<CountryPickerSheet> createState() => _CountryPickerSheetState();
}

class _CountryPickerSheetState extends State<CountryPickerSheet> {
  final TextEditingController _searchController = TextEditingController();
  List<Country> _filteredCountries = countries;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _filterCountries(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredCountries = countries;
      } else {
        _filteredCountries = countries
            .where((country) =>
                country.name.toLowerCase().contains(query.toLowerCase()) ||
                country.dialCode.contains(query))
            .toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          height: MediaQuery.of(context).size.height * 0.7,
          decoration: BoxDecoration(
            color: const Color(0xFF1A1A2E).withOpacity(0.95),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            border: Border.all(
              color: Colors.white.withOpacity(0.1),
              width: 1,
            ),
          ),
          child: Column(
            children: [
              // Handle bar
              Container(
                margin: const EdgeInsets.only(top: 12),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              // Title
              Padding(
                padding: const EdgeInsets.all(20),
                child: Text(
                  'Select Country',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
              // Search field
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.2),
                    ),
                  ),
                  child: TextField(
                    controller: _searchController,
                    onChanged: _filterCountries,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: 'Search country...',
                      hintStyle: TextStyle(
                        color: Colors.white.withOpacity(0.5),
                      ),
                      prefixIcon: Icon(
                        Icons.search,
                        color: Colors.white.withOpacity(0.5),
                      ),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 14,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              // Country list
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  itemCount: _filteredCountries.length,
                  itemBuilder: (context, index) {
                    final country = _filteredCountries[index];
                    return _buildCountryTile(country);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCountryTile(Country country) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          widget.onCountrySelected(
            country.dialCode,
            country.flag,
            country.name,
          );
          Navigator.pop(context);
        },
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          margin: const EdgeInsets.symmetric(vertical: 2),
          child: Row(
            children: [
              // Flag
              Text(
                country.flag,
                style: const TextStyle(fontSize: 24),
              ),
              const SizedBox(width: 16),
              // Country name
              Expanded(
                child: Text(
                  country.name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                  ),
                ),
              ),
              // Dial code
              Text(
                country.dialCode,
                style: TextStyle(
                  color: AppColors.secondary,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
