import 'dart:io';
import 'dart:math';
import 'dart:typed_data';

void main() {
  const int sampleRate = 44100;
  const int durationSeconds = 10;
  const int numSamples = sampleRate * durationSeconds;
  final int dataSize = numSamples * 2; // 16-bit mono

  // Build WAV header (44 bytes)
  final ByteData header = ByteData(44);
  // RIFF
  header.setUint8(0, 0x52); header.setUint8(1, 0x49);
  header.setUint8(2, 0x46); header.setUint8(3, 0x46);
  header.setUint32(4, 36 + dataSize, Endian.little);
  header.setUint8(8, 0x57); header.setUint8(9, 0x41);
  header.setUint8(10, 0x56); header.setUint8(11, 0x45);
  // fmt
  header.setUint8(12, 0x66); header.setUint8(13, 0x6D);
  header.setUint8(14, 0x74); header.setUint8(15, 0x20);
  header.setUint32(16, 16, Endian.little);
  header.setUint16(20, 1, Endian.little);  // PCM
  header.setUint16(22, 1, Endian.little);  // mono
  header.setUint32(24, sampleRate, Endian.little);
  header.setUint32(28, sampleRate * 2, Endian.little);
  header.setUint16(32, 2, Endian.little);
  header.setUint16(34, 16, Endian.little);
  // data
  header.setUint8(36, 0x64); header.setUint8(37, 0x61);
  header.setUint8(38, 0x74); header.setUint8(39, 0x61);
  header.setUint32(40, dataSize, Endian.little);

  // Generate audio
  final Int16List samples = Int16List(numSamples);

  for (int i = 0; i < numSamples; i++) {
    final double t = i / sampleRate;
    final double T = durationSeconds.toDouble();

    // Layer 1: Deep sub drone 55 Hz with slow vibrato ±1 Hz
    final double drone =
        sin(2 * pi * (55 + sin(2 * pi * 0.25 * t) * 1.0) * t) * 0.30;

    // Layer 2: Mid sweep oscillates 110–220 Hz over 10 s
    final double sweepFreq = 110 + 55 * (1 + sin(2 * pi * 0.1 * t));
    final double sweep = sin(2 * pi * sweepFreq * t) * 0.18 *
        (0.5 + 0.5 * sin(2 * pi * 0.17 * t));

    // Layer 3: High shimmer 440 Hz with ring-mod at 0.6 Hz
    final double shimmer =
        sin(2 * pi * 440 * t) * 0.10 * (0.5 + 0.5 * sin(2 * pi * 0.6 * t));

    // Layer 4: Eerie 3rd harmonic 165 Hz phase-shifted by slow LFO
    final double eerie =
        sin(2 * pi * 165 * t + pi * sin(2 * pi * 0.08 * t)) * 0.12;

    // Layer 5: Upper shimmer 880 Hz soft sparkle
    final double sparkle =
        sin(2 * pi * 880 * t) * 0.05 * (0.5 + 0.5 * sin(2 * pi * 1.3 * t));

    double sample = drone + sweep + shimmer + eerie + sparkle;

    // Fade in/out 1 s at each end for seamless loop
    const double fadeTime = 1.0;
    double fade = 1.0;
    if (t < fadeTime) fade = t / fadeTime;
    if (t > T - fadeTime) fade = (T - t) / fadeTime;
    sample *= fade;

    samples[i] = (sample * 28000).round().clamp(-32768, 32767);
  }

  final File file = File('assets/sounds/echo_ambient.wav');
  final RandomAccessFile raf = file.openSync(mode: FileMode.write);
  raf.writeFromSync(header.buffer.asUint8List());
  raf.writeFromSync(samples.buffer.asUint8List());
  raf.closeSync();

  final double sizekb = (44 + dataSize) / 1024;
  // ignore: avoid_print
  print('Generated ${file.path} (${sizekb.toStringAsFixed(0)} KB)');
}
