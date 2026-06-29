import 'package:flutter/material.dart';
import 'screens/customers_screen.dart';
import 'screens/reviews_screen.dart';
import 'screens/tickets_screen.dart';
import 'screens/login_screen.dart';
import 'screens/dashboard_screen.dart';
import 'screens/admins_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'DeskFlow',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        scaffoldBackgroundColor: const Color(0xFF0D0D1A),
        colorScheme: ColorScheme.dark(
          primary: const Color(0xFF6366F1),
          secondary: const Color(0xFF4F46E5),
          surface: const Color(0xFF111827),
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF0D0D1A),
          foregroundColor: Colors.white,
          elevation: 0,
          centerTitle: true,
          titleTextStyle: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.5,
          ),
        ),
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          backgroundColor: Color(0xFF111827),
          selectedItemColor: Color(0xFF6366F1),
          unselectedItemColor: Color(0xFF4B5563),
          elevation: 0,
        ),
        chipTheme: ChipThemeData(
          labelStyle: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        ),
        useMaterial3: true,
      ),
      initialRoute: '/login',
      routes: {
        '/login': (context) => const LoginScreen(),
        '/home': (context) => const HomeScreen(),
      },
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const DashboardScreen(),
    const CustomersScreen(),
    const ReviewsScreen(),
    const TicketsScreen(),
  ];

  final List<String> _titles = [
    'Dashboard',
    'Customers',
    'Reviews',
    'Tickets',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: const Color(0xFF6366F1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.shield, color: Colors.white, size: 16),
            ),
            const SizedBox(width: 10),
            Text(_titles[_currentIndex]),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.person_add_outlined,
                color: Colors.white54, size: 20),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const AdminsScreen(),
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white54, size: 20),
            onPressed: () {
              Navigator.pushReplacementNamed(context, '/login');
            },
          ),
        ],
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
      body: _screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard_outlined),
            activeIcon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.people_outline),
            activeIcon: Icon(Icons.people),
            label: 'Customers',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.star_outline),
            activeIcon: Icon(Icons.star),
            label: 'Reviews',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.confirmation_number_outlined),
            activeIcon: Icon(Icons.confirmation_number),
            label: 'Tickets',
          ),
        ],
      ),
    );
  }
}