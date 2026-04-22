import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../shared/models/event_model.dart';
import '../../../../shared/models/order_model.dart';
import '../../../../shared/models/service_model.dart';
import 'organizer_suppliers_screen.dart';
import '../../../../shared/models/supplier_model.dart';
import '../../../../shared/providers/providers.dart';
import '../../../chat/presentation/providers/chat_provider.dart';
import '../../../events/presentation/providers/events_provider.dart';
import '../../../suppliers/presentation/providers/supplier_provider.dart';

class BookSupplierScreen extends ConsumerStatefulWidget {
  final SupplierModel supplier;

  const BookSupplierScreen({super.key, required this.supplier});

  @override
  ConsumerState<BookSupplierScreen> createState() => _BookSupplierScreenState();
}

class _BookSupplierScreenState extends ConsumerState<BookSupplierScreen> {
  final _formKey = GlobalKey<FormState>();
  final _notesController = TextEditingController();

  String? _selectedEventId;
  bool _isSubmitting = false;

  final Set<String> _selectedServiceIds = {};
  final Map<String, DateTime?> _serviceStartTimes = {};
  final Map<String, DateTime?> _serviceEndTimes = {};

  double _totalPrice(List<ServiceModel> services) => services
      .where((s) => _selectedServiceIds.contains(s.id) && s.price != null)
      .fold(0.0, (sum, s) => sum + s.price!);

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  Future<DateTime?> _pickDateTime({DateTime? initial}) async {
    final now = DateTime.now();
    final date = await showDatePicker(
      context: context,
      initialDate: initial ?? now.add(const Duration(days: 1)),
      firstDate: now,
      lastDate: now.add(const Duration(days: 365 * 2)),
    );
    if (date == null || !mounted) return null;
    final time = await showTimePicker(
      context: context,
      initialTime: initial != null
          ? TimeOfDay.fromDateTime(initial)
          : const TimeOfDay(hour: 9, minute: 0),
    );
    if (time == null) return null;
    return DateTime(date.year, date.month, date.day, time.hour, time.minute);
  }

  Future<void> _pickServiceStartTime(String serviceId) async {
    final picked = await _pickDateTime(initial: _serviceStartTimes[serviceId]);
    if (picked != null) {
      setState(() {
        _serviceStartTimes[serviceId] = picked;
        final end = _serviceEndTimes[serviceId];
        if (end != null && end.isBefore(picked)) {
          _serviceEndTimes[serviceId] = null;
        }
      });
    }
  }

  Future<void> _pickServiceEndTime(String serviceId) async {
    final start = _serviceStartTimes[serviceId];
    final picked = await _pickDateTime(
        initial: _serviceEndTimes[serviceId] ??
            start?.add(const Duration(hours: 2)));
    if (picked != null) {
      if (start != null && picked.isBefore(start)) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('End time must be after start time'),
            backgroundColor: AppColors.error,
          ),
        );
        return;
      }
      setState(() => _serviceEndTimes[serviceId] = picked);
    }
  }

  String _buildRequestMessage(
      List<ServiceModel> services, double total, String notes) {
    final fmt = DateFormat('EEE, MMM d – h:mm a');
    final buffer = StringBuffer();
    buffer.writeln('📋 Booking Request');
    buffer.writeln();
    buffer.writeln('Services:');
    for (final s in services) {
      final price = s.price != null ? s.formattedPrice : 'Contact for price';
      final start = _serviceStartTimes[s.id];
      final end = _serviceEndTimes[s.id];
      buffer.writeln('  • ${s.title} — $price');
      if (start != null) buffer.writeln('    Start: ${fmt.format(start)}');
      if (end != null) buffer.writeln('    End:   ${fmt.format(end)}');
    }
    buffer.writeln();
    buffer.writeln('Total: ${total.toStringAsFixed(2)} KD');
    if (notes.isNotEmpty) {
      buffer.writeln();
      buffer.writeln('Notes: $notes');
    }
    return buffer.toString().trim();
  }

  Future<void> _submit(List<ServiceModel> allServices) async {
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
    if (_selectedServiceIds.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select at least one service'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    // Validate each selected service has start and end times
    for (final id in _selectedServiceIds) {
      final service = allServices.firstWhere((s) => s.id == id);
      if (_serviceStartTimes[id] == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Please set a start time for "${service.title}"'),
            backgroundColor: AppColors.error,
          ),
        );
        return;
      }
      if (_serviceEndTimes[id] == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Please set an end time for "${service.title}"'),
            backgroundColor: AppColors.error,
          ),
        );
        return;
      }
    }

    setState(() => _isSubmitting = true);

    final currentUser = ref.read(currentUserProvider).valueOrNull;
    final orderRepository = ref.read(orderRepositoryProvider);

    final selectedServices = allServices
        .where((s) => _selectedServiceIds.contains(s.id))
        .toList();
    final total = _totalPrice(allServices);
    final notes = _notesController.text.trim();

    // Build per-service schedules map
    final schedules = <String, dynamic>{};
    for (final id in _selectedServiceIds) {
      schedules[id] = {
        'start': _serviceStartTimes[id]!.toIso8601String(),
        'end': _serviceEndTimes[id]!.toIso8601String(),
      };
    }

    // Derive overall start/end for backward compatibility
    final allStarts = _selectedServiceIds
        .map((id) => _serviceStartTimes[id]!)
        .toList()
      ..sort();
    final allEnds = _selectedServiceIds
        .map((id) => _serviceEndTimes[id]!)
        .toList()
      ..sort();

    final order = OrderModel(
      id: const Uuid().v4(),
      serviceId: selectedServices.first.id,
      supplierId: widget.supplier.id,
      customerId: currentUser?.id ?? '',
      eventId: _selectedEventId,
      serviceIds: selectedServices.map((s) => s.id).toList(),
      serviceNames: selectedServices.map((s) => s.title).toList(),
      serviceName: selectedServices.length == 1
          ? selectedServices.first.title
          : '${selectedServices.length} services',
      supplierName: widget.supplier.name,
      customerName: currentUser?.name,
      serviceDate: allStarts.first,
      serviceEndDate: allEnds.last,
      serviceSchedules: schedules,
      totalPrice: total,
      notes: notes.isEmpty ? null : notes,
      status: OrderStatus.pending,
      createdAt: DateTime.now(),
    );

    final result = await orderRepository.createOrder(order);

    if (!mounted) return;

    result.fold(
      (failure) {
        setState(() => _isSubmitting = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(failure.message),
            backgroundColor: AppColors.error,
          ),
        );
      },
      (_) async {
        final userId = currentUser?.id;
        if (userId != null) {
          ref.invalidate(organizerSupplierBookingsProvider(userId));
        }

        try {
          final chatResult = await ref.read(getOrCreateChatProvider((
            currentUserId: currentUser!.id,
            otherUserId: widget.supplier.userId,
            currentUserName: currentUser.name,
            otherUserName: widget.supplier.name,
            currentUserImage: currentUser.profileImage,
            otherUserImage: widget.supplier.profileImage,
          )).future);

          if (chatResult != null && mounted) {
            await ref.read(chatRepositoryProvider).sendMessage(
                  chatId: chatResult.id,
                  senderId: currentUser.id,
                  text: _buildRequestMessage(selectedServices, total, notes),
                );
            if (mounted) {
              setState(() => _isSubmitting = false);
              context.push('/chats/${chatResult.id}');
            }
          } else {
            if (mounted) {
              setState(() => _isSubmitting = false);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                      'Booking request sent to ${widget.supplier.name}!'),
                  backgroundColor: AppColors.success,
                ),
              );
              context.pop();
            }
          }
        } catch (_) {
          if (mounted) {
            setState(() => _isSubmitting = false);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                    'Booking request sent to ${widget.supplier.name}!'),
                backgroundColor: AppColors.success,
              ),
            );
            context.pop();
          }
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentUserId = ref.watch(currentUserIdProvider);
    final eventsAsync = currentUserId != null
        ? ref.watch(organizerEventsProvider(currentUserId))
        : const AsyncValue<List<EventModel>>.data([]);
    final servicesAsync =
        ref.watch(supplierServicesProvider(widget.supplier.id));

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

              // Select Services
              Text(
                'Select Services *',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 8),
              servicesAsync.when(
                data: (services) {
                  if (services.isEmpty) {
                    return Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        border: Border.all(color: AppColors.grey600),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Text(
                        'This supplier has no services listed.',
                        style:
                            TextStyle(color: AppColors.textSecondaryDark),
                      ),
                    );
                  }
                  return Column(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          border: Border.all(color: AppColors.grey600),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Column(
                          children: services.map((service) {
                            final isChecked =
                                _selectedServiceIds.contains(service.id);
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                CheckboxListTile(
                                  value: isChecked,
                                  onChanged: (val) {
                                    setState(() {
                                      if (val == true) {
                                        _selectedServiceIds.add(service.id);
                                      } else {
                                        _selectedServiceIds.remove(service.id);
                                        _serviceStartTimes.remove(service.id);
                                        _serviceEndTimes.remove(service.id);
                                      }
                                    });
                                  },
                                  title: Text(
                                    service.title,
                                    style: const TextStyle(
                                      color: AppColors.textPrimaryDark,
                                      fontSize: 14,
                                    ),
                                  ),
                                  subtitle: Text(
                                    service.formattedPrice,
                                    style: const TextStyle(
                                      color: AppColors.primary,
                                      fontSize: 13,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  activeColor: AppColors.organizerColor,
                                  controlAffinity:
                                      ListTileControlAffinity.leading,
                                  dense: true,
                                ),
                                if (isChecked)
                                  Padding(
                                    padding: const EdgeInsets.fromLTRB(
                                        16, 0, 16, 12),
                                    child: Column(
                                      children: [
                                        _DateTimePicker(
                                          label: 'Start',
                                          icon: Icons.play_circle_outline,
                                          dateTime:
                                              _serviceStartTimes[service.id],
                                          onTap: () => _pickServiceStartTime(
                                              service.id),
                                        ),
                                        const SizedBox(height: 6),
                                        _DateTimePicker(
                                          label: 'End',
                                          icon: Icons.stop_circle_outlined,
                                          dateTime:
                                              _serviceEndTimes[service.id],
                                          onTap: () => _pickServiceEndTime(
                                              service.id),
                                        ),
                                      ],
                                    ),
                                  ),
                              ],
                            );
                          }).toList(),
                        ),
                      ),
                      if (_selectedServiceIds.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 12),
                          decoration: BoxDecoration(
                            color: AppColors.organizerColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color:
                                  AppColors.organizerColor.withOpacity(0.3),
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                '${_selectedServiceIds.length} service(s) selected',
                                style: const TextStyle(
                                  color: AppColors.textSecondaryDark,
                                  fontSize: 13,
                                ),
                              ),
                              Text(
                                'Total: ${_totalPrice(services).toStringAsFixed(2)} KD',
                                style: const TextStyle(
                                  color: AppColors.organizerColor,
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  );
                },
                loading: () => const LinearProgressIndicator(),
                error: (_, __) => const Text(
                  'Failed to load services',
                  style: TextStyle(color: AppColors.error),
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

              servicesAsync.when(
                data: (services) => AppButton(
                  text: _isSubmitting
                      ? 'Sending Request...'
                      : 'Send Booking Request',
                  onPressed: _isSubmitting ? null : () => _submit(services),
                  icon: Icons.send,
                ),
                loading: () => AppButton(
                  text: 'Send Booking Request',
                  onPressed: null,
                  icon: Icons.send,
                ),
                error: (_, __) => AppButton(
                  text: 'Send Booking Request',
                  onPressed: null,
                  icon: Icons.send,
                ),
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
                    const Icon(Icons.star, color: Colors.amber, size: 14),
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

class _DateTimePicker extends StatelessWidget {
  final String label;
  final IconData icon;
  final DateTime? dateTime;
  final VoidCallback onTap;

  const _DateTimePicker({
    required this.label,
    required this.icon,
    required this.dateTime,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.grey600),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Icon(icon, size: 20, color: AppColors.textSecondaryDark),
            const SizedBox(width: 12),
            Text(
              '$label: ',
              style: const TextStyle(
                color: AppColors.textSecondaryDark,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
            Expanded(
              child: Text(
                dateTime != null
                    ? DateFormat('EEE, MMM d, yyyy – h:mm a').format(dateTime!)
                    : 'Select date & time',
                style: TextStyle(
                  color: dateTime != null
                      ? AppColors.textPrimaryDark
                      : AppColors.textSecondaryDark,
                  fontSize: 14,
                ),
              ),
            ),
            const Icon(Icons.edit_calendar_outlined,
                size: 16, color: AppColors.textSecondaryDark),
          ],
        ),
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
