import 'dart:convert';
import 'package:http/http.dart' as http;

const String baseUrl = 'http://10.94.157.50:3000/api';
const String authUrl = 'http://10.94.157.50:3000';

String? sessionCookie;

Map<String, String> get _headers => {
      'Content-Type': 'application/json',
      if (sessionCookie != null) 'Cookie': sessionCookie!,
    };

Future<Map<String, dynamic>> login(String email, String password) async {
  final response = await http.post(
    Uri.parse('$authUrl/api/auth/login'),
    headers: {'Content-Type': 'application/json'},
    body: jsonEncode({'email': email, 'password': password}),
  );

  final data = jsonDecode(response.body);

  if (response.statusCode == 200 && data['success'] == true) {
    final rawCookie = response.headers['set-cookie'];
    if (rawCookie != null) {
      sessionCookie = rawCookie.split(';').first;
    }
    return {'success': true};
  } else {
    return {'success': false, 'error': data['error'] ?? 'Login failed'};
  }
}

Future<List<dynamic>> fetchCustomers() async {
  final response = await http.get(
    Uri.parse('$baseUrl/customers'),
    headers: _headers,
  );
  if (response.statusCode == 200) {
    return jsonDecode(response.body);
  }
  throw Exception('Failed to load customers (${response.statusCode})');
}

Future<List<dynamic>> fetchReviews() async {
  final response = await http.get(
    Uri.parse('$baseUrl/reviews'),
    headers: _headers,
  );
  if (response.statusCode == 200) {
    return jsonDecode(response.body);
  }
  throw Exception('Failed to load reviews (${response.statusCode})');
}

Future<List<dynamic>> fetchTickets() async {
  final response = await http.get(
    Uri.parse('$baseUrl/tickets'),
    headers: _headers,
  );
  if (response.statusCode == 200) {
    return jsonDecode(response.body);
  }
  throw Exception('Failed to load tickets (${response.statusCode})');
}

Future<http.Response> apiPost(String endpoint, Map<String, dynamic> body) async {
  final response = await http.post(
    Uri.parse('$baseUrl$endpoint'),
    headers: {
      'Content-Type': 'application/json',
      if (sessionCookie != null) 'Cookie': sessionCookie!,
    },
    body: jsonEncode(body),
  );
  return response;
}

Future<Map<String, dynamic>> fetchStats() async {
  final results = await Future.wait([
    http.get(Uri.parse('$baseUrl/customers'), headers: _headers),
    http.get(Uri.parse('$baseUrl/tickets'), headers: _headers),
    http.get(Uri.parse('$baseUrl/reviews'), headers: _headers),
  ]);

  final customers = jsonDecode(results[0].body) as List<dynamic>;
  final tickets = jsonDecode(results[1].body) as List<dynamic>;
  final reviews = jsonDecode(results[2].body) as List<dynamic>;

  final openTickets = tickets.where((t) => t['status'] == 'open').length;
  final avgRating = reviews.isEmpty
      ? 0.0
      : reviews.fold<double>(0, (sum, r) => sum + (r['rating'] as num)) /
          reviews.length;

  final recentTickets = tickets.take(5).toList();

  return {
    'totalCustomers': customers.length,
    'openTickets': openTickets,
    'avgRating': avgRating,
    'totalReviews': reviews.length,
    'recentTickets': recentTickets,
  };
}