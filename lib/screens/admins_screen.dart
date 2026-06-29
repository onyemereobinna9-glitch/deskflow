import 'dart:convert';
import 'package:flutter/material.dart';
import '../services/api_service.dart';

class AdminsScreen extends StatefulWidget {
  const AdminsScreen({super.key});

  @override
  State<AdminsScreen> createState() => _AdminsScreenState();
}

class _AdminsScreenState extends State<AdminsScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();
  bool _loading = false;
  bool _obscurePassword = true;
  bool _obscureConfirm = true;
  String? _error;
  String? _success;

  Future<void> _createAdmin() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text;
    final confirm = _confirmController.text;

    if (email.isEmpty || password.isEmpty || confirm.isEmpty) {
      setState(() => _error = 'Please fill in all fields.');
      return;
    }
    if (!email.contains('@')) {
      setState(() => _error = 'Please enter a valid email.');
      return;
    }
    if (password.length < 6) {
      setState(() => _error = 'Password must be at least 6 characters.');
      return;
    }
    if (password != confirm) {
      setState(() => _error = 'Passwords do not match.');
      return;
    }

    setState(() {
      _loading = true;
      _error = null;
      _success = null;
    });

    try {
      final response = await apiPost('/admins', {
        'email': email,
        'password': password,
      });

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        setState(() {
          _success = 'Admin account created for $email';
          _emailController.clear();
          _passwordController.clear();
          _confirmController.clear();
        });
      } else {
        setState(() => _error = data['error'] ?? 'Failed to create admin.');
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
        title: const Text('Add Admin'),
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
            // Info banner
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFF6366F1).withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                    color: const Color(0xFF6366F1).withOpacity(0.3)),
              ),
              child: const Row(
                children: [
                  Icon(Icons.info_outline,
                      color: Color(0xFF6366F1), size: 18),
                  SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'New admins can log in with their email and password to access the dashboard.',
                      style: TextStyle(
                          color: Color(0xFF818CF8), fontSize: 13),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 28),

            // Success message
            if (_success != null) ...[
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFF10B981).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                      color: const Color(0xFF10B981).withOpacity(0.3)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.check_circle_outline,
                        color: Color(0xFF10B981), size: 18),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(_success!,
                          style: const TextStyle(
                              color: Color(0xFF10B981), fontSize: 13)),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
            ],

            // Error message
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

            // Email field
            const Text('Email Address',
                style: TextStyle(color: Colors.white70, fontSize: 13)),
            const SizedBox(height: 8),
            TextField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'e.g. admin@company.com',
                hintStyle: const TextStyle(color: Colors.white24),
                prefixIcon: const Icon(Icons.email_outlined,
                    color: Color(0xFF6366F1)),
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
            const SizedBox(height: 20),

            // Password field
            const Text('Password',
                style: TextStyle(color: Colors.white70, fontSize: 13)),
            const SizedBox(height: 8),
            TextField(
              controller: _passwordController,
              obscureText: _obscurePassword,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Min 6 characters',
                hintStyle: const TextStyle(color: Colors.white24),
                prefixIcon: const Icon(Icons.lock_outline,
                    color: Color(0xFF6366F1)),
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscurePassword
                        ? Icons.visibility_outlined
                        : Icons.visibility_off_outlined,
                    color: Colors.white38,
                  ),
                  onPressed: () => setState(
                      () => _obscurePassword = !_obscurePassword),
                ),
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
            const SizedBox(height: 20),

            // Confirm password field
            const Text('Confirm Password',
                style: TextStyle(color: Colors.white70, fontSize: 13)),
            const SizedBox(height: 8),
            TextField(
              controller: _confirmController,
              obscureText: _obscureConfirm,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Repeat password',
                hintStyle: const TextStyle(color: Colors.white24),
                prefixIcon: const Icon(Icons.lock_outline,
                    color: Color(0xFF6366F1)),
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscureConfirm
                        ? Icons.visibility_outlined
                        : Icons.visibility_off_outlined,
                    color: Colors.white38,
                  ),
                  onPressed: () => setState(
                      () => _obscureConfirm = !_obscureConfirm),
                ),
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
                onPressed: _loading ? null : _createAdmin,
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
                        'Create Admin Account',
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