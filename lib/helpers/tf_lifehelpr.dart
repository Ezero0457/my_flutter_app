import 'dart:io';
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:image/image.dart' as img;

class ClassificationResult {
  final String label;
  final double confidence;

  ClassificationResult({required this.label, required this.confidence});
}

class TFLiteHelper {
  static Interpreter? _interpreter;
  static bool _isInitialized = false;
  static List<String> _labels = [];

  static Future<void> init() async {
    try {
      _interpreter = await Interpreter.fromAsset('model_unquant.tflite');
      final labelsData = await rootBundle.loadString('assets/labels.txt');
      _labels = labelsData
          .split('\n')
          .where((l) => l.trim().isNotEmpty)
          .map((l) {
            final parts = l.trim().split(' ');
            if (parts.length > 1 && int.tryParse(parts[0]) != null) {
              return parts.sublist(1).join(' ');
            }
            return l.trim();
          })
          .toList();
      _isInitialized = true;
      debugPrint("TFLite model loaded successfully. Labels: $_labels");
    } catch (e) {
      debugPrint("Failed to load model: $e");
      _isInitialized = false;
    }
  }

  static bool get isInitialized => _isInitialized;
  static int get labelCount => _labels.length;

  static Interpreter get interpreter {
    if (!_isInitialized || _interpreter == null) {
      throw Exception("Model not initialized");
    }
    return _interpreter!;
  }

  static List<List<List<List<double>>>> preprocessImage(File imageFile) {
    final image = img.decodeImage(imageFile.readAsBytesSync())!;
    final resizedImage = img.copyResize(image, width: 224, height: 224);

    // Create 4D input [1, 224, 224, 3]
    final input = List.generate(
      1,
      (_) => List.generate(
        224,
        (y) => List.generate(
          224,
          (x) {
            final pixel = resizedImage.getPixel(x, y);
            return [
              (pixel.r.toDouble() - 127.5) / 127.5, // R
              (pixel.g.toDouble() - 127.5) / 127.5, // G
              (pixel.b.toDouble() - 127.5) / 127.5, // B
            ];
          },
        ),
      ),
    );
    return input;
  }

  static Future<String> classifyImage(File imageFile) async {
    final results = await classifyImageTopN(imageFile, topN: 1);
    if (results.isNotEmpty) {
      return '${results[0].label} (${(results[0].confidence * 100).toStringAsFixed(1)}%)';
    }
    return 'Unknown';
  }

  static Future<List<ClassificationResult>> classifyImageTopN(
    File imageFile, {
    int topN = 3,
  }) async {
    if (!_isInitialized || _interpreter == null) {
      throw Exception("Model not initialized");
    }

    final numLabels = _labels.length;
    final input = preprocessImage(imageFile);
    final output = List.filled(1 * numLabels, 0.0).reshape([1, numLabels]);

    _interpreter!.run(input, output);

    List<MapEntry<int, double>> scores = [];
    for (int i = 0; i < numLabels; i++) {
      scores.add(MapEntry(i, (output[0][i] as double)));
    }
    scores.sort((a, b) => b.value.compareTo(a.value));

    final top = scores.take(topN).toList();
    return top.map((entry) {
      final label = entry.key < _labels.length
          ? _labels[entry.key]
          : 'Unknown (${entry.key})';
      return ClassificationResult(label: label, confidence: entry.value);
    }).toList();
  }
}  
