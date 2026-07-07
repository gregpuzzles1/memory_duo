# Memory Duo

Memory Duo is a browser-based memory game site built with Flutter and available at [memoryduo.com](https://memoryduo.com). The site currently features two playable memory games, with room for more challenges to be added over time.

## Why Memory Games Matter

Keeping a sharp memory matters in everyday life. Memory-focused games can help reinforce attention, pattern recognition, short-term recall, and mental flexibility. While games are not a substitute for healthy habits, they are a simple and enjoyable way to keep your brain engaged and practice focus under light pressure.

## Games On The Site

### Memory Duo

Memory Duo is a classic matching game where players flip cards, look for pairs, and clear the board. The game ramps up through multiple board sizes, so it starts approachable and gradually asks the player to track more information at once. It is designed to exercise visual memory, concentration, and accuracy.

### Echo Sequence

Echo Sequence challenges players to watch a sequence of colored boulders and repeat it correctly from memory. Each round asks the player to hold and replay a short visual pattern, making it a quick test of short-term recall and attention. It is built to feel simple to start but more demanding as sequences grow.

## Tech Stack

- Flutter
- Dart
- Material 3
- GitHub Pages for hosting
- GitHub Actions for automated deployment

The project also uses packages such as `audioplayers` and `confetti` for game feedback and presentation.

## Deployment

The website is deployed with GitHub Actions from the `main` branch only. The deployment workflow builds the Flutter web app, prepares the static site output, and publishes it to GitHub Pages. Pushes to other branches do not trigger the production deployment.

## License

This project is available under the MIT License. See [LICENSE](LICENSE) for the full text.

## Local Development

```bash
flutter pub get
flutter run -d chrome
```

To create a production web build locally:

```bash
flutter build web --release
```
