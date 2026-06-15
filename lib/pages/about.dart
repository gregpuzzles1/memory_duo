import 'package:flutter/material.dart';

class AboutPage extends StatelessWidget {
  const AboutPage({
    super.key,
    required this.isDarkMode,
    required this.onThemeToggle,
  });

  final bool isDarkMode;
  final VoidCallback onThemeToggle;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('About'),
        actions: <Widget>[
          IconButton(
            tooltip: 'Home',
            onPressed: () =>
                Navigator.of(context).popUntil((Route<dynamic> route) => route.isFirst),
            icon: const Icon(Icons.home_outlined),
          ),
          IconButton(
            tooltip: isDarkMode ? 'Switch to Day Mode' : 'Switch to Night Mode',
            onPressed: onThemeToggle,
            icon: Icon(isDarkMode ? Icons.light_mode : Icons.dark_mode),
          ),
        ],
      ),
      body: const Center(
        child: Text('About page is under construction.'),
      ),
    );
  }
}
