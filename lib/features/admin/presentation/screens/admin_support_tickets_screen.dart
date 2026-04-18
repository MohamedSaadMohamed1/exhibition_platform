import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../shared/models/support_ticket_model.dart';
import '../providers/admin_support_tickets_provider.dart';

class AdminSupportTicketsScreen extends ConsumerWidget {
  const AdminSupportTicketsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(adminSupportTicketsProvider);

    ref.listen(adminSupportTicketsProvider, (previous, next) {
      if (next.errorMessage != null &&
          previous?.errorMessage != next.errorMessage) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.errorMessage!),
            backgroundColor: AppColors.error,
          ),
        );
      }
    });

    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      appBar: AppBar(
        backgroundColor: AppColors.surfaceDark,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          'Support Tickets',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () =>
                ref.read(adminSupportTicketsProvider.notifier).refresh(),
          ),
        ],
      ),
      body: Column(
        children: [
          _FilterChips(
            current: state.statusFilter,
            onChanged: (filter) =>
                ref.read(adminSupportTicketsProvider.notifier).setStatusFilter(filter),
          ),
          Expanded(
            child: state.isLoading && state.tickets.isEmpty
                ? const Center(child: CircularProgressIndicator())
                : state.filteredTickets.isEmpty
                    ? _buildEmpty(state.statusFilter)
                    : ListView.builder(
                        padding: const EdgeInsets.all(12),
                        itemCount: state.filteredTickets.length,
                        itemBuilder: (context, i) {
                          final ticket = state.filteredTickets[i];
                          return _TicketCard(ticket: ticket);
                        },
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmpty(String? filter) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.inbox_outlined, size: 64, color: AppColors.textSecondaryDark),
          const SizedBox(height: 16),
          Text(
            filter == null ? 'No Support Tickets' : 'No ${_label(filter)} Tickets',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimaryDark,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'User support messages will appear here.',
            style: TextStyle(color: AppColors.textSecondaryDark),
          ),
        ],
      ),
    );
  }

  static String _label(String status) {
    switch (status) {
      case 'open':
        return 'Open';
      case 'inProgress':
        return 'In Progress';
      case 'resolved':
        return 'Resolved';
      default:
        return status;
    }
  }
}

class _FilterChips extends StatelessWidget {
  final String? current;
  final ValueChanged<String?> onChanged;

  const _FilterChips({required this.current, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final filters = <String?, String>{
      null: 'All',
      'open': 'Open',
      'inProgress': 'In Progress',
      'resolved': 'Resolved',
    };

    return Container(
      color: AppColors.surfaceDark,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: filters.entries.map((e) {
            final selected = current == e.key;
            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: FilterChip(
                label: Text(e.value),
                selected: selected,
                onSelected: (_) => onChanged(e.key),
                selectedColor: AppColors.primary.withOpacity(0.25),
                checkmarkColor: AppColors.primary,
                labelStyle: TextStyle(
                  color: selected ? AppColors.primary : AppColors.textSecondaryDark,
                  fontWeight:
                      selected ? FontWeight.bold : FontWeight.normal,
                ),
                backgroundColor: AppColors.backgroundDark,
                side: BorderSide(
                  color: selected ? AppColors.primary : Colors.transparent,
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}

class _TicketCard extends ConsumerStatefulWidget {
  final SupportTicketModel ticket;
  const _TicketCard({required this.ticket});

  @override
  ConsumerState<_TicketCard> createState() => _TicketCardState();
}

class _TicketCardState extends ConsumerState<_TicketCard> {
  bool _expanded = false;
  final _notesController = TextEditingController();
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _notesController.text = widget.ticket.adminNotes ?? '';
  }

  @override
  void didUpdateWidget(_TicketCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.ticket.adminNotes != widget.ticket.adminNotes) {
      _notesController.text = widget.ticket.adminNotes ?? '';
    }
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'open':
        return Colors.orange;
      case 'inProgress':
        return Colors.blue;
      case 'resolved':
        return Colors.green;
      default:
        return AppColors.textSecondaryDark;
    }
  }

  String _statusLabel(String status) {
    switch (status) {
      case 'open':
        return 'Open';
      case 'inProgress':
        return 'In Progress';
      case 'resolved':
        return 'Resolved';
      default:
        return status;
    }
  }

  Future<void> _changeStatus(String newStatus) async {
    setState(() => _saving = true);
    final notes = _notesController.text.trim();
    await ref.read(adminSupportTicketsProvider.notifier).updateTicketStatus(
          widget.ticket.id,
          newStatus,
          adminNotes: notes.isNotEmpty ? notes : null,
        );
    if (mounted) setState(() => _saving = false);
  }

  @override
  Widget build(BuildContext context) {
    final ticket = widget.ticket;
    final date = DateFormat('d MMM yyyy').format(ticket.createdAt);

    return Card(
      color: AppColors.surfaceDark,
      margin: const EdgeInsets.only(bottom: 10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => setState(() => _expanded = !_expanded),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header row
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          ticket.userName,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          ticket.subject,
                          style: TextStyle(
                            color: AppColors.textSecondaryDark,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: _statusColor(ticket.status).withOpacity(0.15),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          _statusLabel(ticket.status),
                          style: TextStyle(
                            color: _statusColor(ticket.status),
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        date,
                        style: TextStyle(
                          color: AppColors.textSecondaryDark,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              // Expanded detail
              if (_expanded) ...[
                const SizedBox(height: 16),
                const Divider(color: Colors.white12),
                const SizedBox(height: 12),

                // Contact info
                _InfoRow(icon: Icons.phone, text: ticket.userPhone),
                if (ticket.userEmail != null && ticket.userEmail!.isNotEmpty)
                  _InfoRow(icon: Icons.email, text: ticket.userEmail!),
                const SizedBox(height: 12),

                // Message
                Text(
                  'Message',
                  style: TextStyle(
                    color: AppColors.textSecondaryDark,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  ticket.message,
                  style: const TextStyle(color: Colors.white, fontSize: 14),
                ),
                const SizedBox(height: 16),

                // Admin notes
                Text(
                  'Admin Notes',
                  style: TextStyle(
                    color: AppColors.textSecondaryDark,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 6),
                TextField(
                  controller: _notesController,
                  maxLines: 3,
                  style: const TextStyle(color: Colors.white, fontSize: 13),
                  decoration: InputDecoration(
                    hintText: 'Add internal notes...',
                    hintStyle: TextStyle(color: AppColors.textSecondaryDark),
                    filled: true,
                    fillColor: AppColors.backgroundDark,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.all(12),
                  ),
                ),
                const SizedBox(height: 14),

                // Status buttons
                if (_saving)
                  const Center(child: CircularProgressIndicator())
                else
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      if (ticket.status != 'inProgress')
                        _ActionButton(
                          label: 'Mark In Progress',
                          color: Colors.blue,
                          onTap: () => _changeStatus('inProgress'),
                        ),
                      if (ticket.status != 'resolved')
                        _ActionButton(
                          label: 'Mark Resolved',
                          color: Colors.green,
                          onTap: () => _changeStatus('resolved'),
                        ),
                      if (ticket.status != 'open')
                        _ActionButton(
                          label: 'Reopen',
                          color: Colors.orange,
                          onTap: () => _changeStatus('open'),
                        ),
                    ],
                  ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String text;
  const _InfoRow({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          Icon(icon, size: 14, color: AppColors.textSecondaryDark),
          const SizedBox(width: 6),
          Text(
            text,
            style: TextStyle(color: AppColors.textSecondaryDark, fontSize: 13),
          ),
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final String label;
  final Color color;
  final VoidCallback onTap;
  const _ActionButton(
      {required this.label, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: onTap,
      style: OutlinedButton.styleFrom(
        foregroundColor: color,
        side: BorderSide(color: color),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      ),
      child: Text(label, style: const TextStyle(fontSize: 13)),
    );
  }
}
