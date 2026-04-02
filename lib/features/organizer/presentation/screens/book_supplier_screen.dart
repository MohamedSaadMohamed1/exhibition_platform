import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../shared/models/event_model.dart';
import '../../../../shared/models/order_model.dart';
import 'organizer_suppliers_screen.dart';
import '../../../../shared/models/supplier_model.dart';
import '../../../../shared/providers/providers.dart';
import '../../../events/presentation/providers/events_provider.dart';

class BookSupplierScreen extends ConsumerStatefulWidget {
  final SupplierModel supplier;

  const BookSupplierScreen({super.key, required this.supplier});

  @override
  ConsumerState<BookSupplierScreen> createState() => _BookSupplierScreenState();
}

class _BookSupplierScreenState extends ConsumerState<BookSupplierScreen> {
  final _formKey = GlobalKey<FormState>();
  final _budgetController = TextEditingController();
  final _notesController = TextEditingController();

  String? _selectedEventId;
  String? _selectedEventTitle;
  DateTime? _selectedDate;
  bool _isSubmitting = false;

  @override
  void dispose() {
    _budgetController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? now.add(const Duration(days: 1)),
      firstDate: now,
      lastDate: now.add(const Duration(days: 365 * 2)),
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedEventId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select an event'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }
    if (_selectedDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a service date'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    final currentUser = ref.read(currentUserProvider).valueOrNull;
    final orderRepository = ref.read(orderRepositoryProvider);

    final budget = double.tryParse(_budgetController.text.trim()) ?? 0.0;

    final order = OrderModel(
      id: const Uuid().v4(),
      serviceId: widget.supplier.id,
      supplierId: widget.supplier.id,
      customerId: currentUser?.id ?? '',
      eventId: _selectedEventId,
      serviceName: _selectedEventTitle,
      supplierName: widget.supplier.name,
      customerName: currentUser?.name,
      serviceDate: _selectedDate,
      totalPrice: budget,
      notes: _notesController.text.trim().isEmpty
          ? null
          : _notesController.text.trim(),
      status: OrderStatus.pending,
      createdAt: DateTime.now(),
    );

    final result = await orderRepository.createOrder(order);

    if (!mounted) return;
    setState(() => _isSubmitting = false);

    result.fold(
      (failure) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(failure.message),
            backgroundColor: AppColors.error,
          ),
        );
      },
      (_) {
        // Refresh organizer supplier bookings list
        final userId = currentUser?.id;
        if (userId != null) {
          ref.invalidate(organizerSupplierBookingsProvider(userId));
        }
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                'Booking request sent to ${widget.supplier.name}!'),
            backgroundColor: AppColors.success,
          ),
        );
        context.pop();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentUserId = ref.watch(currentUserIdProvider);
    final eventsAsync = currentUserId != null
        ? ref.watch(organizerEventsProvider(currentUserId))
        : const AsyncValue<List<EventModel>>.data([]);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Book Supplier'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Supplier info card
              _SupplierInfoCard(supplier: widget.supplier),
              const SizedBox(height: 24),

              // Select Event
              Text(
                'Select Event *',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 8),
              eventsAsync.when(
                data: (events) {
                  if (events.isEmpty) {
                    return Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        border: Border.all(color: AppColors.grey600),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Text(
                        'No events found. Create an event first.',
                        style:
                            TextStyle(color: AppColors.textSecondaryDark),
                      ),
                    );
                  }
                  return DropdownButtonFormField<String>(
                    value: _selectedEventId,
                    decoration: const InputDecoration(
                      hintText: 'Choose an event',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.event),
                    ),
                    items: events.map((EventModel e) {
                      return DropdownMenuItem<String>(
                        value: e.id,
                        child: Text(
                          e.title,
                          overflow: TextOverflow.ellipsis,
                        ),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedEventId = value;
                        _selectedEventTitle = events
                            .firstWhere((e) => e.id == value)
                            .title;
                      });
                    },
                    validator: (v) =>
                        v == null ? 'Please select an event' : null,
                  );
                },
                loading: () => const LinearProgressIndicator(),
                error: (_, __) => const Text(
                  'Failed to load events',
                  style: TextStyle(color: AppColors.error),
                ),
              ),
              const SizedBox(height: 16),

              // Service Date
              Text(
                'Service Date *',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 8),
              GestureDetector(
                onTap: _pickDate,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 15),
                  decoration: BoxDecoration(
                    border: Border.all(color: AppColors.grey600),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.calendar_today,
                          size: 20, color: AppColors.textSecondaryDark),
                      const SizedBox(width: 12),
                      Text(
                        _selectedDate != null
                            ? DateFormat('EEEE, MMMM d, yyyy')
                                .format(_selectedDate!)
                            : 'Select date',
                        style: TextStyle(
                          color: _selectedDate != null
                              ? AppColors.textPrimaryDark
                              : AppColors.textSecondaryDark,
                          fontSize: 15,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Budget
              Text(
                'Budget (Optional)',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _budgetController,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(
                      RegExp(r'^\d+\.?\d{0,2}')),
                ],
                decoration: const InputDecoration(
                  hintText: 'e.g., 500',
                  prefixText: '\$ ',
                  prefixIcon: Icon(Icons.attach_money),
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),

              // Notes
              Text(
                'Notes / Message',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _notesController,
                maxLines: 4,
                decoration: const InputDecoration(
                  hintText:
                      'Describe what you need from this supplier for your event...',
                  border: OutlineInputBorder(),
                  alignLabelWithHint: true,
                ),
              ),
              const SizedBox(height: 32),

              AppButton(
                text: _isSubmitting ? 'Sending Request...' : 'Send Booking Request',
                onPressed: _isSubmitting ? null : _submit,
                icon: Icons.send,
              ),
              const SizedBox(height: 12),
              OutlinedButton(
                onPressed: _isSubmitting ? null : () => context.pop(),
                style: OutlinedButton.styleFrom(
                    minimumSize: const Size.fromHeight(48)),
                child: const Text('Cancel'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SupplierInfoCard extends StatelessWidget {
  final SupplierModel supplier;

  const _SupplierInfoCard({required this.supplier});

  @override
  Widget build(BuildContext context) {
    return Container(
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
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: supplier.coverImage != null
                ? Image.network(
                    supplier.coverImage!,
                    width: 60,
                    height: 60,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) =>
                        const _SupplierAvatarPlaceholder(),
                  )
                : const _SupplierAvatarPlaceholder(),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        supplier.name,
                        style: const TextStyle(
                          color: AppColors.textPrimaryDark,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    if (supplier.isVerified)
                      const Icon(Icons.verified,
                          color: AppColors.organizerColor, size: 18),
                  ],
                ),
                if (supplier.category != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    supplier.category!,
                    style: const TextStyle(
                      color: AppColors.textSecondaryDark,
                      fontSize: 13,
                    ),
                  ),
                ],
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.star,
                        color: Colors.amber, size: 14),
                    const SizedBox(width: 2),
                    Text(
                      supplier.rating.toStringAsFixed(1),
                      style: const TextStyle(
                        color: AppColors.textSecondaryDark,
                        fontSize: 12,
                      ),
                    ),
                    Text(
                      ' (${supplier.reviewCount})',
                      style: const TextStyle(
                        color: AppColors.textSecondaryDark,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SupplierAvatarPlaceholder extends StatelessWidget {
  const _SupplierAvatarPlaceholder();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 60,
      height: 60,
      color: AppColors.grey700,
      child: const Icon(Icons.business, color: AppColors.grey400, size: 28),
    );
  }
}
