import 'dart:math';

import 'package:audioplayers/audioplayers.dart';
import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';

// ---- Boulder data ----

class _BoulderData {
  final String name;
  final Color base;
  final Color light;
  final Color dark;
  const _BoulderData({
    required this.name,
    required this.base,
    required this.light,
    required this.dark,
  });
}

const List<_BoulderData> _kBoulders = <_BoulderData>[
  _BoulderData(name: 'Red',    base: Color(0xFFE53935), light: Color(0xFFEF9A9A), dark: Color(0xFFB71C1C)),
  _BoulderData(name: 'Green',  base: Color(0xFF388E3C), light: Color(0xFFA5D6A7), dark: Color(0xFF1B5E20)),
  _BoulderData(name: 'Black',  base: Color(0xFF424242), light: Color(0xFF9E9E9E), dark: Color(0xFF212121)),
  _BoulderData(name: 'Yellow', base: Color(0xFFFDD835), light: Color(0xFFFFF9C4), dark: Color(0xFFF9A825)),
  _BoulderData(name: 'White',  base: Color(0xFFEEEEEE), light: Color(0xFFFFFFFF), dark: Color(0xFFBDBDBD)),
  _BoulderData(name: 'Purple', base: Color(0xFF8E24AA), light: Color(0xFFCE93D8), dark: Color(0xFF4A148C)),
  _BoulderData(name: 'Blue',   base: Color(0xFF1E88E5), light: Color(0xFF90CAF9), dark: Color(0xFF0D47A1)),
];

// ---- Rock shape painter ----
// Each boulder index has a unique fixed irregular polygon with facet shading.

class _RockPainter extends CustomPainter {
  const _RockPainter({required this.data, required this.shapeIndex});

  final _BoulderData data;
  final int shapeIndex;

  // Pre-defined rock outlines: a list of (angleFraction, radiusFraction) per
  // boulder index. Values hand-tuned so each rock looks distinct.
  // Each entry: [angleFraction 0..1, radiusFraction 0.5..1.0]
  // 8-10 vertices, large radius swings = clearly irregular rock sides.
  static const List<List<List<double>>> _shapes = <List<List<double>>>[
    // 0 Red – 9-sided chunky asymmetric slab
    <List<double>>[[0.00,0.95],[0.11,0.62],[0.22,0.90],[0.33,0.55],
                   [0.45,0.92],[0.57,0.60],[0.68,0.88],[0.80,0.58],[0.91,0.84]],
    // 1 Green – 10-sided tall narrow spire
    <List<double>>[[0.00,0.58],[0.10,0.92],[0.20,0.55],[0.30,0.88],[0.40,0.60],
                   [0.52,0.95],[0.63,0.58],[0.74,0.90],[0.85,0.54],[0.94,0.86]],
    // 2 Black – 8-sided wide flat cap
    <List<double>>[[0.00,0.90],[0.13,0.60],[0.25,0.85],[0.38,0.55],
                   [0.50,0.92],[0.63,0.58],[0.76,0.88],[0.89,0.62]],
    // 3 Yellow – 9-sided sharp jagged asteroid
    <List<double>>[[0.00,0.92],[0.11,0.52],[0.22,0.94],[0.33,0.50],
                   [0.44,0.90],[0.55,0.53],[0.67,0.93],[0.78,0.55],[0.89,0.88]],
    // 4 White – 10-sided lumpy rounded rock
    <List<double>>[[0.00,0.88],[0.10,0.75],[0.20,0.92],[0.31,0.68],[0.42,0.95],
                   [0.53,0.72],[0.63,0.90],[0.73,0.70],[0.83,0.93],[0.93,0.74]],
    // 5 Purple – 8-sided angular cleaved chunk
    <List<double>>[[0.00,0.55],[0.13,0.94],[0.25,0.52],[0.38,0.90],
                   [0.50,0.56],[0.63,0.92],[0.75,0.54],[0.88,0.88]],
    // 6 Blue – 9-sided squat wide lumpy rock
    <List<double>>[[0.00,0.85],[0.11,0.58],[0.23,0.92],[0.35,0.60],
                   [0.47,0.88],[0.58,0.55],[0.69,0.90],[0.80,0.62],[0.91,0.86]],
  ];

  Path _buildPath(Size size) {
    final double cx = size.width  * 0.48;
    final double cy = size.height * 0.50;
    final double rx = size.width  * 0.46;
    final double ry = size.height * 0.44;
    final List<List<double>> pts =
        _shapes[shapeIndex % _shapes.length];
    final Path path = Path();
    for (int i = 0; i < pts.length; i++) {
      final double angle  = pts[i][0] * 2 * pi;
      final double radius = pts[i][1];
      final double x = cx + cos(angle) * rx * radius;
      final double y = cy + sin(angle) * ry * radius;
      if (i == 0) { path.moveTo(x, y); } else { path.lineTo(x, y); }
    }
    path.close();
    return path;
  }

  @override
  void paint(Canvas canvas, Size size) {
    final Path path = _buildPath(size);

    // Drop shadow
    canvas.drawShadow(path, Colors.black.withValues(alpha: 0.55), 5, false);

    // Base fill with radial gradient from top-left (light source)
    final Paint fill = Paint()
      ..shader = RadialGradient(
          center: const Alignment(-0.4, -0.4),
          radius: 1.0,
          colors: <Color>[data.light, data.base, data.dark],
          stops: const <double>[0.0, 0.45, 1.0],
        ).createShader(
          Rect.fromLTWH(0, 0, size.width, size.height),
        );
    canvas.drawPath(path, fill);

    // Facet crack lines – unique per shape, dark tinted
    final Paint crack = Paint()
      ..color = data.dark.withValues(alpha: 0.35)
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;
    final double cx = size.width * 0.48;
    final double cy = size.height * 0.50;
    // Two diagonal facet lines
    canvas.save();
    canvas.clipPath(path);
    canvas.drawLine(
      Offset(cx - size.width * 0.28, cy - size.height * 0.10),
      Offset(cx + size.width * 0.10, cy + size.height * 0.32),
      crack,
    );
    canvas.drawLine(
      Offset(cx + size.width * 0.05, cy - size.height * 0.30),
      Offset(cx + size.width * 0.25, cy + size.height * 0.15),
      crack,
    );
    canvas.restore();

    // Outline
    final Paint outline = Paint()
      ..color = data.dark.withValues(alpha: 0.60)
      ..strokeWidth = 1.2
      ..style = PaintingStyle.stroke;
    canvas.drawPath(path, outline);
  }

  @override
  bool shouldRepaint(_RockPainter old) =>
      old.data != data || old.shapeIndex != shapeIndex;
}

// ---- Game phases ----

enum _Phase { idle, sequence, input, roundResult, gameOver, paused }

// ---- Page ----

class EchoSequencePage extends StatefulWidget {
  const EchoSequencePage({
    super.key,
    required this.isDarkMode,
    required this.onThemeToggle,
  });

  final bool isDarkMode;
  final VoidCallback onThemeToggle;

  @override
  State<EchoSequencePage> createState() => _EchoSequencePageState();
}

class _EchoSequencePageState extends State<EchoSequencePage>
    with SingleTickerProviderStateMixin {

  static const int _totalRounds   = 5;
  static const int _minBoulders   = 3;
  static const int _maxBoulders   = 7;
  static const int _startBoulders = 4;
  static const Duration _fadeDuration = Duration(milliseconds: 500);
  static const Duration _holdDuration = Duration(milliseconds: 3500);

  _Phase _phase           = _Phase.idle;
  _Phase _phaseBeforePause = _Phase.idle;

  int   _round         = 0;
  int   _n             = _startBoulders;
  bool? _roundSuccess;

  List<int> _seq        = <int>[];
  int       _showIdx    = -1;
  double    _seqOpacity = 0.0;

  List<int>  _shelf        = <int>[];
  List<bool> _live         = <bool>[];
  int        _nextExpected = 0;
  int        _strikes      = 0;
  int?       _shakeIdx;

  late final AnimationController    _shakeCtrl;
  late final Animation<Offset>      _shakeAnim;
  late final ConfettiController     _confettiCtrl;
  late final AudioPlayer            _ambientPlayer;

  @override
  void initState() {
    super.initState();
    _confettiCtrl = ConfettiController(duration: const Duration(seconds: 3));
    _ambientPlayer = AudioPlayer();
    _shakeCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 420),
    );
    _shakeAnim = TweenSequence<Offset>(<TweenSequenceItem<Offset>>[
      TweenSequenceItem<Offset>(
        tween: Tween<Offset>(begin: Offset.zero, end: const Offset(0.18, 0)),
        weight: 20,
      ),
      TweenSequenceItem<Offset>(
        tween: Tween<Offset>(begin: const Offset(0.18, 0), end: const Offset(-0.18, 0)),
        weight: 40,
      ),
      TweenSequenceItem<Offset>(
        tween: Tween<Offset>(begin: const Offset(-0.18, 0), end: const Offset(0.08, 0)),
        weight: 20,
      ),
      TweenSequenceItem<Offset>(
        tween: Tween<Offset>(begin: const Offset(0.08, 0), end: Offset.zero),
        weight: 20,
      ),
    ]).animate(_shakeCtrl);
  }

  @override
  void dispose() {
    _ambientPlayer.dispose();
    _shakeCtrl.dispose();
    _confettiCtrl.dispose();
    super.dispose();
  }

  Future<void> _playAmbient() async {
    await _ambientPlayer.setReleaseMode(ReleaseMode.loop);
    await _ambientPlayer.play(AssetSource('sounds/echo_ambient.wav'));
  }

  Future<void> _stopAmbient() async {
    await _ambientPlayer.stop();
  }

  // ---- Game logic ----

  void _startGame() {
    setState(() { _round = 0; _n = _startBoulders; _roundSuccess = null; });
    _beginRound();
  }

  void _beginRound() {
    _stopAmbient();
    final Random rng = Random();
    final List<int> pool =
        (List<int>.generate(_kBoulders.length, (int i) => i)..shuffle(rng))
            .take(_n)
            .toList();
    setState(() {
      _seq        = pool;
      _showIdx    = -1;
      _seqOpacity = 0.0;
      _phase      = _Phase.sequence;
    });
    _runSequence();
  }

  Future<void> _runSequence() async {
    await Future<void>.delayed(const Duration(milliseconds: 600));
    for (int i = 0; i < _seq.length; i++) {
      if (!mounted || _phase != _Phase.sequence) return;
      setState(() { _showIdx = i; _seqOpacity = 0.0; });
      await Future<void>.delayed(const Duration(milliseconds: 50));
      if (!mounted || _phase != _Phase.sequence) return;
      setState(() => _seqOpacity = 1.0);
      await Future<void>.delayed(_holdDuration);
      if (!mounted || _phase != _Phase.sequence) return;
      setState(() => _seqOpacity = 0.0);
      await Future<void>.delayed(_fadeDuration);
      if (!mounted || _phase != _Phase.sequence) return;
    }
    if (mounted && _phase == _Phase.sequence) _beginInput();
  }

  void _beginInput() {
    _playAmbient();
    final Random rng = Random();
    List<int> shuffled = List<int>.from(_seq);
    if (shuffled.length > 1) {
      do { shuffled.shuffle(rng); } while (_listsIdentical(shuffled, _seq));
    }
    setState(() {
      _shelf        = shuffled;
      _live         = List<bool>.filled(shuffled.length, true);
      _nextExpected = 0;
      _strikes      = 0;
      _shakeIdx     = null;
      _phase        = _Phase.input;
    });
  }

  bool _listsIdentical(List<int> a, List<int> b) {
    for (int i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }

  void _onTap(int idx) {
    if (_phase != _Phase.input) return;
    if (!_live[idx])             return;
    if (_shakeIdx != null)       return;

    if (_shelf[idx] == _seq[_nextExpected]) {
      setState(() { _live[idx] = false; _nextExpected++; _strikes = 0; });
      if (_nextExpected >= _seq.length) _endRound(true);
    } else {
      _strikes++;
      setState(() => _shakeIdx = idx);
      _shakeCtrl.forward(from: 0).then((_) {
        if (mounted) setState(() => _shakeIdx = null);
      });
      if (_strikes >= 3) {
        Future<void>.delayed(const Duration(milliseconds: 650), () {
          if (mounted) _endRound(false);
        });
      }
    }
  }

  void _endRound(bool success) {
    final int nextRound = _round + 1;
    final int nextN     = success
        ? min(_n + 1, _maxBoulders)
        : max(_n - 1, _minBoulders);
    setState(() {
      _roundSuccess = success;
      _round        = nextRound;
      _n            = nextN;
      _phase = nextRound >= _totalRounds ? _Phase.gameOver : _Phase.roundResult;
    });
    if (nextRound >= _totalRounds) {
      _confettiCtrl.play();
    } else {
      _playAmbient();
    }
    if (nextRound < _totalRounds) {
      Future<void>.delayed(const Duration(seconds: 2), () {
        if (mounted && _phase == _Phase.roundResult) _beginRound();
      });
    }
  }

  void _togglePause() {
    if (_phase == _Phase.paused) {
      final _Phase resume = _phaseBeforePause;
      setState(() => _phase = resume);
      if (resume == _Phase.sequence) _beginRound();
    } else if (_phase == _Phase.sequence || _phase == _Phase.input) {
      _stopAmbient();
      setState(() { _phaseBeforePause = _phase; _phase = _Phase.paused; });
    }
  }

  void _reset() {
    _stopAmbient();
    setState(() {
      _phase        = _Phase.idle;
      _round        = 0;
      _n            = _startBoulders;
      _seq          = <int>[];
      _showIdx      = -1;
      _seqOpacity   = 0.0;
      _shelf        = <int>[];
      _live         = <bool>[];
      _nextExpected = 0;
      _strikes      = 0;
      _shakeIdx     = null;
      _roundSuccess = null;
    });
  }

  // ---- Build ----

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text('Echo Sequence'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(56),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.only(left: 16, right: 16, bottom: 8),
            child: const Text(
              'Watch the colored boulders appear on the right, then tap them on the shelves (left) in the same order.',
              style: TextStyle(fontSize: 16.5, fontStyle: FontStyle.italic),
              softWrap: true,
            ),
          ),
        ),
        actions: <Widget>[
          IconButton(
            tooltip: 'Home',
            onPressed: () =>
                Navigator.of(context).popUntil((Route<dynamic> r) => r.isFirst),
            icon: const Icon(Icons.home_outlined),
          ),
          IconButton(
            tooltip: 'About',
            onPressed: () => Navigator.of(context).pushNamed('/about'),
            icon: const Icon(Icons.info_outline),
          ),
          IconButton(
            tooltip: widget.isDarkMode ? 'Switch to Day Mode' : 'Switch to Night Mode',
            onPressed: widget.onThemeToggle,
            icon: Icon(widget.isDarkMode ? Icons.light_mode : Icons.dark_mode),
          ),
        ],
      ),
      body: Column(
        children: <Widget>[
          _buildControlBar(),
          Expanded(child: _buildGameField()),
        ],
      ),
    );
  }

  Widget _buildControlBar() {
    final bool canPause = _phase == _Phase.sequence ||
        _phase == _Phase.input ||
        _phase == _Phase.paused;

    return Container(
      color: Theme.of(context)
          .colorScheme
          .surfaceContainerHighest
          .withValues(alpha: 0.9),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: <Widget>[
          if (_phase == _Phase.idle || _phase == _Phase.gameOver)
            FilledButton.icon(
              onPressed: _startGame,
              icon: const Icon(Icons.play_arrow),
              label: Text(_phase == _Phase.gameOver ? 'Play Again' : 'Start'),
            )
          else if (canPause)
            FilledButton.icon(
              onPressed: _togglePause,
              icon: Icon(_phase == _Phase.paused ? Icons.play_arrow : Icons.pause),
              label: Text(_phase == _Phase.paused ? 'Resume' : 'Pause'),
            ),
          const SizedBox(width: 12),
          OutlinedButton.icon(
            onPressed: _reset,
            icon: const Icon(Icons.restart_alt),
            label: const Text('Reset'),
          ),
          const Spacer(),
          if (_phase != _Phase.idle)
            Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: <Widget>[
                Text(
                  'Round ${min(_round + 1, _totalRounds)} of $_totalRounds',
                  style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                ),
                Text('$_n boulders', style: const TextStyle(fontSize: 12)),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildGameField() {
    return LayoutBuilder(
      builder: (BuildContext ctx, BoxConstraints box) {
        final bool showSeqBoulder =
            (_phase == _Phase.sequence ||
                (_phase == _Phase.paused &&
                    _phaseBeforePause == _Phase.sequence)) &&
            _showIdx >= 0 &&
            _seq.isNotEmpty;

        final bool showShelves =
            _phase == _Phase.input ||
            (_phase == _Phase.paused && _phaseBeforePause == _Phase.input);

        return Stack(
          children: <Widget>[
            Positioned.fill(
              child: Image.asset(
                'assets/images/echo-sequence-robot-mountains.png',
                fit: BoxFit.cover,
              ),
            ),
            if (showSeqBoulder) _buildSeqBoulder(box),
            if (showShelves && _shelf.isNotEmpty) _buildShelves(),
            if (_phase == _Phase.input) _buildInputPrompt(),
            if (_phase == _Phase.roundResult) _buildResultBanner(),
            if (_phase == _Phase.paused) _buildPauseOverlay(),
            if (_phase == _Phase.gameOver) _buildGameOverOverlay(),
          ],
        );
      },
    );
  }

  // ---- Sequence boulder (upper right) ----

  Widget _buildSeqBoulder(BoxConstraints box) {
    const double sz = 64.0;
    final _BoulderData d = _kBoulders[_seq[_showIdx]];
    return Positioned(
      right: box.maxWidth * 0.07,
      top:   box.maxHeight * 0.05,
      child: AnimatedOpacity(
        key:      ValueKey<int>(_showIdx),
        opacity:  _seqOpacity,
        duration: _fadeDuration,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            _boulder(d, sz),
            const SizedBox(height: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: Colors.black54,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                '${_showIdx + 1} / ${_seq.length}',
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ---- Shelves (upper left) ----

  Widget _buildShelves() {
    const double sz         = 52.0;
    const double gap        = 8.0;
    const double plankH     = 12.0;
    const double rowSpacing = 20.0;

    final int total = _shelf.length;
    final int r1    = (total / 2).ceil();
    final int r2    = total - r1;

    return Positioned(
      left: 10,
      top:  14,
      child: Column(
        mainAxisSize:       MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          _shelfRow(0, r1, sz, gap, plankH),
          SizedBox(height: rowSpacing),
          if (r2 > 0) _shelfRow(r1, r2, sz, gap, plankH),
        ],
      ),
    );
  }

  Widget _shelfRow(int start, int count, double sz, double gap, double plankH) {
    final double plankW = count * sz + (count - 1) * gap + 16;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            for (int i = 0; i < count; i++) ...<Widget>[
              if (i > 0) SizedBox(width: gap),
              _shelfBoulder(start + i, sz),
            ],
          ],
        ),
        Container(
          width:  plankW,
          height: plankH,
          decoration: BoxDecoration(
            color: const Color(0xFF5D4037),
            borderRadius: const BorderRadius.only(
              bottomLeft:  Radius.circular(3),
              bottomRight: Radius.circular(3),
            ),
            boxShadow: <BoxShadow>[
              BoxShadow(
                color:      Colors.black.withValues(alpha: 0.5),
                blurRadius: 5,
                offset:     const Offset(0, 4),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _shelfBoulder(int idx, double sz) {
    if (!_live[idx]) return SizedBox(width: sz, height: sz);
    final _BoulderData d = _kBoulders[_shelf[idx]];
    final Widget inner = GestureDetector(
      onTap: () => _onTap(idx),
      child: Tooltip(message: d.name, child: _boulder(d, sz)),
    );
    if (_shakeIdx == idx) {
      return SlideTransition(position: _shakeAnim, child: inner);
    }
    return inner;
  }

  // ---- Shared boulder widget ----

  Widget _boulder(_BoulderData d, double sz) {
    final int idx = _kBoulders.indexOf(d);
    return SizedBox(
      width:  sz,
      height: sz,
      child: CustomPaint(
        painter: _RockPainter(data: d, shapeIndex: idx < 0 ? 0 : idx),
      ),
    );
  }

  // ---- Overlays ----

  Widget _buildInputPrompt() {
    return Positioned(
      bottom: 12,
      left:   12,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.6),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          'Tap boulder ${_nextExpected + 1} of ${_seq.length}',
          style: const TextStyle(
              color: Colors.white, fontSize: 13, fontWeight: FontWeight.w500),
        ),
      ),
    );
  }

  Widget _buildResultBanner() {
    final bool ok = _roundSuccess == true;
    return Positioned(
      bottom: 40,
      left:   20,
      right:  20,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        decoration: BoxDecoration(
          color: ok ? const Color(0xDD2E7D32) : const Color(0xDDC62828),
          borderRadius: BorderRadius.circular(12),
          boxShadow: <BoxShadow>[
            BoxShadow(
                color: Colors.black.withValues(alpha: 0.4), blurRadius: 8),
          ],
        ),
        child: Text(
          ok
              ? '✓ Correct!  Next round: $_n boulders'
              : '✗ Sequence missed — Next round: $_n boulders',
          textAlign: TextAlign.center,
          style: const TextStyle(
              color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }

  Widget _buildPauseOverlay() {
    return Positioned.fill(
      child: Container(
        color: Colors.black.withValues(alpha: 0.55),
        alignment: Alignment.center,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            const Icon(Icons.pause_circle_outline, color: Colors.white, size: 72),
            const SizedBox(height: 12),
            const Text(
              'Paused',
              style: TextStyle(
                  color: Colors.white, fontSize: 30, fontWeight: FontWeight.w700),
            ),
            if (_phaseBeforePause == _Phase.sequence)
              const Padding(
                padding: EdgeInsets.only(top: 8),
                child: Text(
                  'Resuming will restart this round\'s sequence',
                  style: TextStyle(color: Colors.white70, fontSize: 13),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildGameOverOverlay() {
    return Positioned.fill(
      child: Stack(
        alignment: Alignment.center,
        children: <Widget>[
          Container(
            color: Colors.black.withValues(alpha: 0.72),
            alignment: Alignment.center,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                const Text(
                  '🎉 Good Job! 🎉',
                  style: TextStyle(
                      color: Colors.yellow, fontSize: 38, fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 10),
                const Text(
                  'Game Over',
                  style: TextStyle(
                      color: Colors.white, fontSize: 28, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 8),
                Text(
                  '$_totalRounds rounds complete',
                  style: const TextStyle(color: Colors.white70, fontSize: 18),
                ),
                const SizedBox(height: 28),
                FilledButton.icon(
                  onPressed: _startGame,
                  icon:  const Icon(Icons.replay),
                  label: const Text('Play Again'),
                ),
              ],
            ),
          ),
          // Confetti burst from top-centre
          Align(
            alignment: Alignment.topCenter,
            child: ConfettiWidget(
              confettiController: _confettiCtrl,
              blastDirectionality: BlastDirectionality.explosive,
              numberOfParticles: 40,
              emissionFrequency: 0.04,
              gravity: 0.25,
              shouldLoop: false,
              colors: const <Color>[
                Colors.red, Colors.green, Colors.blue,
                Colors.yellow, Colors.purple, Colors.pink, Colors.orange,
              ],
            ),
          ),
        ],
      ),
    );
  }
}
