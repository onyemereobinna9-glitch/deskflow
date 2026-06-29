import 'dart:convert';
import 'package:flutter/material.dart';
import '../services/api_service.dart';

class AddCustomerScreen extends StatefulWidget {
  const AddCustomerScreen({super.key});

  @override
  State<AddCustomerScreen> createState() => _AddCustomerScreenState();
}

class _AddCustomerScreenState extends State<AddCustomerScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  String _status = 'active';
  bool _loading = false;
  String? _error;

  final List<String> _statuses = ['active', 'inactive', 'flagged'];

  Future<void> _submit() async {
    if (_nameController.text.trim().isEmpty ||
        _emailController.text.trim().isEmpty) {
      setState(() => _error = 'Please fill in all fields.');
      return;
    }

    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final response = await apiPost('/customers', {
        'name': _nameController.text.trim(),
        'email': _emailController.text.trim(),
        'status': _status,
      });

      if (response.statusCode == 200 || response.statusCode == 201) {
        if (mounted) Navigator.pop(context, true);
      } else {
        final data = jsonDecode(response.body);
        setState(() => _error = data['error'] ?? 'Failed to add customer.');
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
        title: const Text('Add Customer'),
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
      body: SingleChildScrollView(
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

            // Name field
            const Text('Full Name',
                style: TextStyle(color: Colors.white70, fontSize: 13)),
            const SizedBox(height: 8),
            TextField(
              controller: _nameController,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'e.g. John Doe',
                hintStyle: const TextStyle(color: Colors.white24),
                prefixIcon:
                    const Icon(Icons.person_outline, color: Color(0xFF6366F1)),
                filled: true,
                fillColor: const Color(0xFF111827),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFF1E2030)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFF1E2030)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFF6366F1)),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Email field
            const Text('Email Address',
                style: TextStyle(color: Colors.white70, fontSize: 13)),
            const SizedBox(height: 8),
            TextField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'e.g. john@example.com',
                hintStyle: const TextStyle(color: Colors.white24),
                prefixIcon:
                    const Icon(Icons.email_outlined, color: Color(0xFF6366F1)),
                filled: true,
                fillColor: const Color(0xFF111827),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFF1E2030)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFF1E2030)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFF6366F1)),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Status selector
            const Text('Status',
                style: TextStyle(color: Colors.white70, fontSize: 13)),
            const SizedBox(height: 8),
            Row(
              children: _statuses.map((s) {
                final isSelected = _status == s;
                Color color;
                switch (s) {
                  case 'active':
                    color = const Color(0xFF10B981);
                    break;
                  case 'inactive':
                    color = const Color(0xFF6B7280);
                    break;
                  case 'flagged':
                    color = const Color(0xFFF87171);
                    break;
                  default:
                    color = const Color(0xFF6B7280);
                }
                return Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => _status = s),
                    child: Container(
                      margin: const EdgeInsets.only(right: 8),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? color.withOpacity(0.15)
                            : const Color(0xFF111827),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: isSelected
                              ? color
                              : const Color(0xFF1E2030),
                        ),
                      ),
                      child: Center(
                        child: Text(
                          s,
                          style: TextStyle(
                            color: isSelected ? color : Colors.white38,
                            fontWeight: isSelected
                                ? FontWeight.w600
                                : FontWeight.normal,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
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
                        'Add Customer',
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.w600),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}