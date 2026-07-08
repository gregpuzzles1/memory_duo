import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:memory_duo/site_footer.dart';

class AboutPage extends StatefulWidget {
  const AboutPage({
    super.key,
    required this.isDarkMode,
    required this.onThemeToggle,
  });

  final bool isDarkMode;
  final VoidCallback onThemeToggle;

  @override
  State<AboutPage> createState() => _AboutPageState();
}

class _AboutPageState extends State<AboutPage> {
  final ScrollController _scrollController = ScrollController();
  final FocusNode _focusNode = FocusNode();

  @override
  void dispose() {
    _scrollController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  KeyEventResult _handleKeyEvent(FocusNode node, KeyEvent event) {
    if (event is! KeyDownEvent && event is! KeyRepeatEvent) {
      return KeyEventResult.ignored;
    }
    if (!_scrollController.hasClients) {
      return KeyEventResult.ignored;
    }

    const double step = 120;
    double? nextOffset;

    if (event.logicalKey == LogicalKeyboardKey.arrowDown) {
      nextOffset = _scrollController.offset + step;
    } else if (event.logicalKey == LogicalKeyboardKey.arrowUp) {
      nextOffset = _scrollController.offset - step;
    }

    if (nextOffset == null) {
      return KeyEventResult.ignored;
    }

    final double clamped = nextOffset.clamp(
      _scrollController.position.minScrollExtent,
      _scrollController.position.maxScrollExtent,
    );

    _scrollController.animateTo(
      clamped,
      duration: const Duration(milliseconds: 140),
      curve: Curves.easeOut,
    );
    return KeyEventResult.handled;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        centerTitle: true,
        leadingWidth: 96,
        leading: Align(
          alignment: Alignment.centerLeft,
          child: IconButton(
            tooltip: 'Back',
            onPressed: () => Navigator.of(context).maybePop(),
            icon: const Icon(Icons.arrow_back),
          ),
        ),
        title: const Text('About'),
        actions: <Widget>[
          IconButton(
            tooltip: 'Home',
            onPressed: () =>
                Navigator.of(context).popUntil((Route<dynamic> route) => route.isFirst),
            icon: const Icon(Icons.home_outlined),
          ),
          IconButton(
            tooltip: widget.isDarkMode ? 'Switch to Day Mode' : 'Switch to Night Mode',
            onPressed: widget.onThemeToggle,
            icon: Icon(widget.isDarkMode ? Icons.light_mode : Icons.dark_mode),
          ),
        ],
      ),
      body: Listener(
        onPointerDown: (_) => _focusNode.requestFocus(),
        child: Focus(
          focusNode: _focusNode,
          autofocus: true,
          onKeyEvent: _handleKeyEvent,
          child: SingleChildScrollView(
            controller: _scrollController,
            padding: const EdgeInsets.all(24),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 320),
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
            ),
          ),
        ),
      ),
    );
  }
}
