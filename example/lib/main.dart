import 'package:flutter/material.dart';
import 'package:liquid_glass_bottom_nav/liquid_glass_bottom_nav.dart';

void main() => runApp(const ExampleApp());

class ExampleApp extends StatelessWidget {
  const ExampleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(colorSchemeSeed: Colors.teal),
      home: const ExampleHome(),
    );
  }
}

class ExampleHome extends StatefulWidget {
  const ExampleHome({super.key});

  @override
  State<ExampleHome> createState() => _ExampleHomeState();
}

class _ExampleHomeState extends State<ExampleHome> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      body: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFFE0F7FA), Color(0xFFFFF3E0)],
          ),
        ),
        child: Center(
          child: Text(
            ['Home', 'Explore', 'Profile'][_index],
            style: Theme.of(context).textTheme.displaySmall,
          ),
        ),
      ),
      bottomNavigationBar: SafeArea(
        top: false,
        minimum: const EdgeInsets.only(bottom: 12),
        child: LiquidGlassBottomNavBar(
          currentIndex: _index,
          onSelected: (value) => setState(() => _index = value),
          onDragSelected: (value) => setState(() => _index = value),
          items: const [
            LiquidGlassBottomNavItem(
              label: 'Home',
              icon: Icon(Icons.home_outlined),
              selectedIcon: Icon(Icons.home),
            ),
            LiquidGlassBottomNavItem(
              label: 'Explore',
              icon: Icon(Icons.explore_outlined),
              selectedIcon: Icon(Icons.explore),
            ),
            LiquidGlassBottomNavItem(
              label: 'Profile',
              icon: Icon(Icons.person_outline),
              selectedIcon: Icon(Icons.person),
            ),
          ],
        ),
      ),
    );
  }
}
