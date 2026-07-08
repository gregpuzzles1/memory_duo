import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:memory_duo/site_footer.dart';

class HomePage extends StatefulWidget {
  const HomePage({
    super.key,
    required this.isDarkMode,
    required this.onThemeToggle,
  });

  final bool isDarkMode;
  final VoidCallback onThemeToggle;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
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
        centerTitle: true,
        title: const Text(
          'Welcome to Memory Duo',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w400,
          ),
        ),
        actions: <Widget>[
          IconButton(
            tooltip: 'About',
            onPressed: () => Navigator.of(context).pushNamed('/about'),
            icon: const Icon(Icons.info_outline),
          ),
          IconButton(
            tooltip: widget.isDarkMode
                ? 'Switch to Day Mode'
                : 'Switch to Night Mode',
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
          child: SafeArea(
            child: SingleChildScrollView(
              controller: _scrollController,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 320),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      const Text(
                        'Memory Duo',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Flip matching pairs, complete levels and track your results',
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 20),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: Image.asset(
                          'assets/images/memory-duo-card.png',
                          fit: BoxFit.contain,
                        ),
                      ),
                      const SizedBox(height: 16),
                      FilledButton.icon(
                        onPressed: () =>
                            Navigator.of(context).pushNamed('/memory-duo'),
                        icon: const Icon(Icons.play_arrow),
                        label: const Text('Start Game'),
                      ),
                      const SizedBox(height: 32),
                      const Text(
                        'Echo Sequence',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Watch the boulder sequence, repeat it back, and survive all rounds',
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 20),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: Image.asset(
                          'assets/images/echo-sequence-card.png',
                          fit: BoxFit.contain,
                        ),
                      ),
                      const SizedBox(height: 16),
                      FilledButton.icon(
                        onPressed: () =>
                            Navigator.of(context).pushNamed('/echo-sequence'),
                        icon: const Icon(Icons.play_arrow),
                        label: const Text('Start Game'),
                      ),
                      const SizedBox(height: 20),
                      const SiteFooter(),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
