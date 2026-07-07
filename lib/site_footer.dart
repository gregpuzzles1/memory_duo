import 'dart:async';

import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class SiteFooter extends StatefulWidget {
  const SiteFooter({super.key});

  @override
  State<SiteFooter> createState() => _SiteFooterState();
}

class _SiteFooterState extends State<SiteFooter> {
  static final Uri _repoUri = Uri.parse('https://github.com/gregpuzzles1/memory_duo');
  static final Uri _emailUri = Uri(
    scheme: 'mailto',
    path: 'gregpuzzles1@gmail.com',
  );

  Timer? _yearTimer;
  late int _currentYear;

  @override
  void initState() {
    super.initState();
    _currentYear = DateTime.now().year;
    _scheduleYearRefresh();
  }

  @override
  void dispose() {
    _yearTimer?.cancel();
    super.dispose();
  }

  void _scheduleYearRefresh() {
    final DateTime now = DateTime.now();
    final DateTime nextYear = DateTime(now.year + 1);
    _yearTimer?.cancel();
    _yearTimer = Timer(nextYear.difference(now), () {
      if (!mounted) {
        return;
      }
      setState(() {
        _currentYear = DateTime.now().year;
      });
      _scheduleYearRefresh();
    });
  }

  Future<void> _openRepo() async {
    final bool launched = await launchUrl(
      _repoUri,
      mode: LaunchMode.platformDefault,
      webOnlyWindowName: '_blank',
    );
    if (!launched && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not open the GitHub repository.')),
      );
    }
  }

  Future<void> _openContact() async {
    final bool launched = await launchUrl(_emailUri);
    if (!launched && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not open the contact email link.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;

    return Column(
      children: <Widget>[
        const Divider(height: 40),
        Text(
          'Copyright $_currentYear MemoryDuo',
          textAlign: TextAlign.center,
          style: textTheme.bodyMedium,
        ),
        const SizedBox(height: 12),
        Wrap(
          alignment: WrapAlignment.center,
          spacing: 10,
          runSpacing: 10,
          children: <Widget>[
            TextButton.icon(
              onPressed: _openRepo,
              icon: const Icon(Icons.code),
              label: const Text('GitHub Repo'),
            ),
            TextButton.icon(
              onPressed: _openContact,
              icon: const Icon(Icons.email_outlined),
              label: const Text('Contact'),
            ),
          ],
        ),
      ],
    );
  }
}