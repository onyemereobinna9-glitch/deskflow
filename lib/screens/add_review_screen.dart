import 'dart:convert';
import 'package:flutter/material.dart';
import '../services/api_service.dart';

class AddReviewScreen extends StatefulWidget {
  const AddReviewScreen({super.key});

  @override
  State<AddReviewScreen> createState() => _AddReviewScreenState();
}

class _AddReviewScreenState extends State<AddReviewScreen> {
  final _bodyController = TextEditingController();
  int _rating = 5;
  String? _selectedCustomerId;
  List<dynamic> _customers = [];
  bool _loading = false;
  bool _loadingCustomers = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadCustomers();
  }

  Future<void> _loadCustomers() async {
    try {
      final customers = await fetchCustomers();
      setState(() {
        _customers = customers;
        _loadingCustomers = false;
      });
    } catch (e) {
      setState(() => _loadingCustomers = false);
    }
  }

  Future<void> _submit() async {
    if (_selectedCustomerId == null || _bodyController.text.trim().isEmpty) {
      setState(() => _error = 'Please select a customer and write a review.');
      return;
    }

    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final response = await apiPost('/reviews', {
        'customer_id': _selectedCustomerId,
        'rating': _rating,
        'body': _bodyController.text.trim(),
      });

      if (response.statusCode == 200 || response.statusCode == 201) {
        if (mounted) Navigator.pop(context, true);
      } else {
        final data = jsonDecode(response.body);
        setState(() => _error = data['error'] ?? 'Failed to add review.');
      }
    } catch (e) {
      setState(() => _error = 'Could not connect to server.');
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D0D1A),
      appBar: AppBar(
        title: const Text('Add Review'),
        backgroundColor: const Color(0xFF0D0D1A),
        foregroundColor: Colors.white,
        elevation: 0,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(
            height: 1,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF6366F1), Color(0xFF4F46E5)],
              ),
            ),
          ),
        ),
      ),
      body: _loadingCustomers
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xFF6366F1)))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (_error != null) ...[
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF87171).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                            color: const Color(0xFFF87171).withOpacity(0.3)),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.error_outline,
                              color: Color(0xFFF87171), size: 18),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(_error!,
                                style: const TextStyle(
                                    color: Color(0xFFF87171), fontSize: 13)),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],

                  // Customer selector
                  const Text('Customer',
                      style: TextStyle(color: Colors.white70, fontSize: 13)),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: const Color(0xFF111827),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFF1E2030)),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: _selectedCustomerId,
                        hint: const Text('Select a customer',
                            style: TextStyle(color: Colors.white38)),
                        dropdownColor: const Color(0xFF111827),
                        isExpanded: true,
                        icon: const Icon(Icons.keyboard_arrow_down,
                            color: Color(0xFF6366F1)),
                        items: _customers.map((c) {
                          return DropdownMenuItem<String>(
                            value: c['id'].toString(),
                            child: Text(c['name'] ?? '',
                                style:
                                    const TextStyle(color: Colors.white)),
                          );
                        }).toList(),
                        onChanged: (val) =>
                            setState(() => _selectedCustomerId = val),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Star rating
                  const Text('Rating',
                      style: TextStyle(color: Colors.white70, fontSize: 13)),
                  const SizedBox(height: 8),
                  Row(
                    children: List.generate(5, (i) {
                      return GestureDetector(
                        onTap: () => setState(() => _rating = i + 1),
                        child: Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: Icon(
                            i < _rating ? Icons.star : Icons.star_outline,
                            color: i < _rating
                                ? const Color(0xFFFBBF24)
                                : const Color(0xFF4B5563),
                            size: 36,
                          ),
                        ),
                      );
                    }),
                  ),
                  const SizedBox(height: 20),

                  // Review body
                  const Text('Review',
                      style: TextStyle(color: Colors.white70, fontSize: 13)),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _bodyController,
                    style: const TextStyle(color: Colors.white),
                    maxLines: 5,
                    decoration: InputDecoration(
                      hintText: 'Write the customer review here...',
                      hintStyle: const TextStyle(color: Colors.white24),
                      filled: true,
                      fillColor: const Color(0xFF111827),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide:
                            const BorderSide(color: Color(0xFF1E2030)),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide:
                            const BorderSide(color: Color(0xFF1E2030)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide:
                            const BorderSide(color: Color(0xFF6366F1)),
                      ),
                    ),
                  ),
                  const SizedBox(height: 36),

                  // Submit button
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      onPressed: _loading ? null : _submit,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF6366F1),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                      child: _loading
                          ? const SizedBox(
                              width: 22,
                              height: 22,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : const Text(
                              'Add Review',
                              style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600),
                            ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}