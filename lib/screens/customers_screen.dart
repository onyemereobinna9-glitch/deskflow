import 'package:flutter/material.dart';
import '../services/api_service.dart';

class CustomersScreen extends StatefulWidget {
  const CustomersScreen({super.key});

  @override
  State<CustomersScreen> createState() => _CustomersScreenState();
}

class _CustomersScreenState extends State<CustomersScreen> {
  late Future<List<dynamic>> _customers;

  @override
  void initState() {
    super.initState();
    _customers = fetchCustomers();
  }

  Future<void> _refresh() async {
    final data = fetchCustomers();
    setState(() => _customers = data);
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'active': return const Color(0xFF10B981);
      case 'inactive': return const Color(0xFF6B7280);
      case 'flagged': return const Color(0xFFF87171);
      default: return const Color(0xFF6B7280);
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<dynamic>>(
      future: _customers,
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

        final customers = snapshot.data!;

        if (customers.isEmpty) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.people_outline, color: Color(0xFF6366F1), size: 48),
                SizedBox(height: 16),
                Text('No customers yet',
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
            itemCount: customers.length,
            itemBuilder: (context, index) {
              final c = customers[index];
              final status = c['status'] ?? '';
              return Container(
                margin: const EdgeInsets.only(bottom: 10),
                decoration: BoxDecoration(
                  color: const Color(0xFF111827),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: const Color(0xFF1E2030), width: 1),
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 8),
                  leading: CircleAvatar(
                    backgroundColor: const Color(0xFF1E2030),
                    child: Text(
                      (c['name'] ?? '?')[0].toUpperCase(),
                      style: const TextStyle(
                          color: Color(0xFF6366F1), fontWeight: FontWeight.bold),
                    ),
                  ),
                  title: Text(
                    c['name'] ?? '',
                    style: const TextStyle(
                        color: Colors.white, fontWeight: FontWeight.w600),
                  ),
                  subtitle: Text(
                    c['email'] ?? '',
                    style: const TextStyle(color: Colors.white38, fontSize: 12),
                  ),
                  trailing: Chip(
                    label: Text(status),
                    backgroundColor: _statusColor(status).withOpacity(0.15),
                    labelStyle: TextStyle(
                        color: _statusColor(status),
                        fontSize: 11,
                        fontWeight: FontWeight.w600),
                    side: BorderSide(color: _statusColor(status).withOpacity(0.3)),
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