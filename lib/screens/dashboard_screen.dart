import 'package:flutter/material.dart';
import '../services/api_service.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  late Future<Map<String, dynamic>> _stats;

  @override
  void initState() {
    super.initState();
    _stats = fetchStats();
  }

  Future<void> _refresh() async {
    setState(() {
      _stats = fetchStats();
    });
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>>(
      future: _stats,
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

        final stats = snapshot.data!;
        final totalCustomers = stats['totalCustomers'] ?? 0;
        final openTickets = stats['openTickets'] ?? 0;
        final avgRating = stats['avgRating'] ?? 0.0;
        final totalReviews = stats['totalReviews'] ?? 0;
        final recentTickets = stats['recentTickets'] as List<dynamic>? ?? [];

        return RefreshIndicator(
          onRefresh: _refresh,
          color: const Color(0xFF6366F1),
          backgroundColor: const Color(0xFF111827),
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              // Welcome header
              const Text(
                'Overview',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'Here\'s what\'s happening today',
                style: TextStyle(color: Colors.white38, fontSize: 13),
              ),
              const SizedBox(height: 24),

              // Stat cards row 1
              Row(
                children: [
                  Expanded(
                    child: _StatCard(
                      label: 'Customers',
                      value: totalCustomers.toString(),
                      icon: Icons.people,
                      color: const Color(0xFF6366F1),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _StatCard(
                      label: 'Open Tickets',
                      value: openTickets.toString(),
                      icon: Icons.confirmation_number,
                      color: const Color(0xFF10B981),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Stat cards row 2
              Row(
                children: [
                  Expanded(
                    child: _StatCard(
                      label: 'Avg Rating',
                      value: avgRating.toStringAsFixed(1),
                      icon: Icons.star,
                      color: const Color(0xFFFBBF24),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _StatCard(
                      label: 'Reviews',
                      value: totalReviews.toString(),
                      icon: Icons.rate_review,
                      color: const Color(0xFF8B5CF6),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 28),

              // Recent tickets
              const Text(
                'Recent Tickets',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 12),

              if (recentTickets.isEmpty)
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: const Color(0xFF111827),
                    borderRadius: BorderRadius.circular(14),
                    border:
                        Border.all(color: const Color(0xFF1E2030), width: 1),
                  ),
                  child: const Center(
                    child: Text('No tickets yet',
                        style: TextStyle(color: Colors.white38)),
                  ),
                )
              else
                ...recentTickets.map((t) {
                  final status = t['status'] ?? '';
                  Color statusColor;
                  switch (status) {
                    case 'open':
                      statusColor = const Color(0xFF10B981);
                      break;
                    case 'pending':
                      statusColor = const Color(0xFFF59E0B);
                      break;
                    default:
                      statusColor = const Color(0xFF6B7280);
                  }
                  return Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: const Color(0xFF111827),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                          color: const Color(0xFF1E2030), width: 1),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: statusColor,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                t['subject'] ?? '',
                                style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 13),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                t['customer_name'] ?? '',
                                style: const TextStyle(
                                    color: Colors.white38, fontSize: 11),
                              ),
                            ],
                          ),
                        ),
                        Chip(
                          label: Text(status),
                          backgroundColor: statusColor.withOpacity(0.15),
                          labelStyle: TextStyle(
                              color: statusColor,
                              fontSize: 10,
                              fontWeight: FontWeight.w600),
                          side: BorderSide(
                              color: statusColor.withOpacity(0.3)),
                          padding: EdgeInsets.zero,
                        ),
                      ],
                    ),
                  );
                }),
            ],
          ),
        );
      },
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _StatCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF111827),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFF1E2030), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(color: Colors.white38, fontSize: 12),
          ),
        ],
      ),
    );
  }
}