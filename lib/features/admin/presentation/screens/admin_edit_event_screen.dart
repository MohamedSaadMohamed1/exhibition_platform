import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/enums.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../shared/models/event_model.dart';
import '../../../../shared/providers/repository_providers.dart';
import '../providers/admin_events_provider.dart';

class AdminEditEventScreen extends ConsumerStatefulWidget {
  final String eventId;

  const AdminEditEventScreen({super.key, required this.eventId});

  @override
  ConsumerState<AdminEditEventScreen> createState() =>
      _AdminEditEventScreenState();
}

class _AdminEditEventScreenState extends ConsumerState<AdminEditEventScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _locationController = TextEditingController();

  DateTime? _startDate;
  DateTime? _endDate;
  EventStatus? _status;
  bool _isLoading = true;
  bool _isSaving = false;
  EventModel? _event;

  @override
  void initState() {
    super.initState();
    _loadEvent();
  }

  Future<void> _loadEvent() async {
    final result =
        await ref.read(eventRepositoryProvider).getEventById(widget.eventId);
    result.fold(
      (failure) {
        if (mounted) {
          setState(() => _isLoading = false);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(failure.message),
              backgroundColor: AppColors.error,
            ),
          );
        }
      },
      (event) {
        if (mounted) {
          setState(() {
            _event = event;
            _titleController.text = event.title;
            _descriptionController.text = event.description;
            _locationController.text = event.location;
            _startDate = event.startDate;
            _endDate = event.endDate;
            _status = event.status;
            _isLoading = false;
          });
        }
      },
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  Future<void> _saveEvent() async {
    if (!_formKey.currentState!.validate()) return;
    if (_startDate == null || _endDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select start and end dates'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    setState(() => _isSaving = true);

    final result = await ref.read(eventRepositoryProvider).updateEvent(
          eventId: widget.eventId,
          title: _titleController.text.trim(),
          description: _descriptionController.text.trim(),
          location: _locationController.text.trim(),
          startDate: _startDate,
          endDate: _endDate,
          status: _status,
        );

    setState(() => _isSaving = false);

    if (!mounted) return;

    result.fold(
      (failure) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update: ${failure.message}'),
            backgroundColor: AppColors.error,
          ),
        );
      },
      (_) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Event updated successfully'),
            backgroundColor: AppColors.success,
          ),
        );
        ref.read(adminEventsProvider.notifier).refresh();
        context.pop();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: AppColors.backgroundDark,
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      appBar: AppBar(
        backgroundColor: AppColors.surfaceDark,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          'Edit Event',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        actions: [
          TextButton(
            onPressed: _isSaving ? null : _saveEvent,
            child: _isSaving
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : const Text(
                    'Save',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Status selector
              _SectionLabel('Status'),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: EventStatus.values.map((s) {
                  final isSelected = _status == s;
                  final color = _statusColor(s);
                  return ChoiceChip(
                    label: Text(_statusLabel(s)),
                    selected: isSelected,
                    onSelected: (_) => setState(() => _status = s),
                    selectedColor: color.withOpacity(0.3),
                    backgroundColor: AppColors.surfaceDark,
                    labelStyle: TextStyle(
                      color: isSelected ? color : Colors.white70,
                      fontWeight: isSelected
                          ? FontWeight.bold
                          : FontWeight.normal,
                    ),
                    side: BorderSide(
                      color: isSelected ? color : AppColors.grey700,
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 20),

              // Title
              _SectionLabel('Exhibition Title'),
              const SizedBox(height: 8),
              _buildField(
                controller: _titleController,
                hint: 'e.g., Tech Summit 2026',
                validator: (v) =>
                    v == null || v.isEmpty ? 'Title is required' : null,
              ),
              const SizedBox(height: 20),

              // Description
              _SectionLabel('Description'),
              const SizedBox(height: 8),
              _buildField(
                controller: _descriptionController,
                hint: 'Describe the event...',
                maxLines: 4,
                validator: (v) =>
                    v == null || v.isEmpty ? 'Description is required' : null,
              ),
              const SizedBox(height: 20),

              // Location
              _SectionLabel('Location'),
              const SizedBox(height: 8),
              _buildField(
                controller: _locationController,
                hint: 'e.g., Kuwait International Fair',
                prefixIcon: Icons.location_on_outlined,
                validator: (v) =>
                    v == null || v.isEmpty ? 'Location is required' : null,
              ),
              const SizedBox(height: 20),

              // Dates
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _SectionLabel('Start Date'),
                        const SizedBox(height: 8),
                        _DatePicker(
                          date: _startDate,
                          firstDate: DateTime(2020),
                          onPicked: (d) => setState(() => _startDate = d),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _SectionLabel('End Date'),
                        const SizedBox(height: 8),
                        _DatePicker(
                          date: _endDate,
                          firstDate: _startDate ?? DateTime(2020),
                          onPicked: (d) => setState(() => _endDate = d),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildField({
    required TextEditingController controller,
    required String hint,
    int maxLines = 1,
    IconData? prefixIcon,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      style: const TextStyle(color: Colors.white),
      maxLines: maxLines,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: AppColors.grey600),
        prefixIcon: prefixIcon != null
            ? Icon(prefixIcon, color: AppColors.adminColor)
            : null,
        filled: true,
        fillColor: AppColors.surfaceDark,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.grey800),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.grey800),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.adminColor),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.error),
        ),
      ),
      validator: validator,
    );
  }

  String _statusLabel(EventStatus s) {
    switch (s) {
      case EventStatus.draft:
        return 'Draft';
      case EventStatus.published:
        return 'Published';
      case EventStatus.cancelled:
        return 'Cancelled';
      case EventStatus.completed:
        return 'Completed';
    }
  }

  Color _statusColor(EventStatus s) {
    switch (s) {
      case EventStatus.draft:
        return Colors.orange;
      case EventStatus.published:
        return Colors.green;
      case EventStatus.cancelled:
        return Colors.red;
      case EventStatus.completed:
        return Colors.blue;
    }
  }
}

class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        color: AppColors.textPrimaryDark,
        fontSize: 15,
        fontWeight: FontWeight.w600,
      ),
    );
  }
}

class _DatePicker extends StatelessWidget {
  final DateTime? date;
  final DateTime firstDate;
  final void Function(DateTime) onPicked;

  const _DatePicker({
    required this.date,
    required this.firstDate,
    required this.onPicked,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () async {
        final picked = await showDatePicker(
          context: context,
          initialDate: date ?? DateTime.now(),
          firstDate: firstDate,
          lastDate: DateTime(2035),
          builder: (context, child) => Theme(
            data: ThemeData.dark().copyWith(
              colorScheme: const ColorScheme.dark(
                primary: AppColors.adminColor,
                surface: AppColors.surfaceDark,
              ),
            ),
            child: child!,
          ),
        );
        if (picked != null) onPicked(picked);
      },
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.surfaceDark,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.grey800),
        ),
        child: Row(
          children: [
            const Icon(Icons.calendar_today,
                color: AppColors.adminColor, size: 18),
            const SizedBox(width: 10),
            Text(
              date == null
                  ? 'Select date'
                  : '${date!.day}/${date!.month}/${date!.year}',
              style: TextStyle(
                color: date == null ? AppColors.grey600 : Colors.white,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
