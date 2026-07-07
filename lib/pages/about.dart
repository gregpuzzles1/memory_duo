import 'package:flutter/material.dart';
import 'package:memory_duo/site_footer.dart';

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
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const <Widget>[
            Text(
              'MemoryDuo is a simple, colorful memory game designed to be fun, quick to play, and easy for anyone to enjoy. Players match pairs of emoji cards by remembering where each one is hidden, turning a familiar memory challenge into a cheerful little brain workout. Whether you are playing for a few minutes or trying to improve your best time, MemoryDuo offers a lighthearted way to practice focus, pattern recognition, and recall.\n\nThe game was created as a small web project with a clean, playful design and the goal of making memory practice feel approachable rather than complicated. MemoryDuo is built for casual play, but it also celebrates the kind of concentration and persistence that make puzzle games satisfying. More games and features may be added over time, giving visitors new ways to test their memory and enjoy a quick mental challenge.',
              style: TextStyle(fontSize: 18, height: 1.6),
            ),
            SiteFooter(),
          ],
        ),
      ),
    );
  }
}
