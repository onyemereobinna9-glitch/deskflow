import 'package:flutter/material.dart';
import '../services/api_service.dart';

class TicketsScreen extends StatefulWidget {
  const TicketsScreen({super.key});

  @override
  State<TicketsScreen> createState() => _TicketsScreenState();
}

class _TicketsScreenState extends State<TicketsScreen> {
  late Future<List<dynamic>> _tickets;

  @override
  void initState() {
    super.initState();
    _tickets = fetchTickets();
  }

  Future<void> _refresh() async {
    final data = fetchTickets();
    setState(() => _tickets = data);
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'open': return const Color(0xFF10B981);
      case 'pending': return const Color(0xFFF59E0B);
      case 'closed': return const Color(0xFF6B7280);
      default: return const Color(0xFF6B7280);
    }
  }

  IconData _statusIcon(String status) {
    switch (status) {
      case 'open': return Icons.radio_button_checked;
      case 'pending': return Icons.hourglass_empty;
      case 'closed': return Icons.check_circle_outline;
      default: return Icons.help_outline;
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<dynamic>>(
      future: _tickets,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(color: Color(0xFF6366F1)),
          );
        } else if (snapshot.hasError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.wifi_off, color: Color(0xFF6366F1), size: 48),
                const SizedBox(height: 16),
                const Text('Could not connect to server',
                    style: TextStyle(color: Colors.white70, fontSize: 16)),
                const SizedBox(height: 8),
                const Text('Make sure the backend is running',
                    style: TextStyle(color: Colors.white38, fontSize: 13)),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: _refresh,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF6366F1),
                  ),
                  child: const Text('Retry'),
                ),
              ],
            ),
          );
        }

        final tickets = snapshot.data!;

        if (tickets.isEmpty) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.confirmation_number_outlined,
                    color: Color(0xFF6366F1), size: 48),
                SizedBox(height: 16),
                Text('No tickets yet',
                    style: TextStyle(color: Colors.white70, fontSize: 16)),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: _refresh,
          color: const Color(0xFF6366F1),
          backgroundColor: const Color(0xFF111827),
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            itemCount: tickets.length,
            itemBuilder: (context, index) {
              final t = tickets[index];
              final status = t['status'] ?? '';
              return Container(
                margin: const EdgeInsets.only(bottom: 10),
                decoration: BoxDecoration(
                  color: const Color(0xFF111827),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: const Color(0xFF1E2030), width: 1),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: _statusColor(status).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(
                          _statusIcon(status),
                          color: _statusColor(status),
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              t['subject'] ?? '',
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 14),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              t['customer_name'] ?? '',
                              style: const TextStyle(
                                  color: Colors.white38, fontSize: 12),
                            ),
                          ],
                        ),
                      ),
                      Chip(
                        label: Text(status),
                        backgroundColor: _statusColor(status).withOpacity(0.15),
                        labelStyle: TextStyle(
                            color: _statusColor(status),
                            fontSize: 11,
                            fontWeight: FontWeight.w600),
                        side: BorderSide(
                            color: _statusColor(status).withOpacity(0.3)),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }
}