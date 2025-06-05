import 'package:flutter/services.dart';
import 'package:tflite_flutter/tflite_flutter.dart';

class SentimentService {
  static final SentimentService _instance = SentimentService._internal();
  factory SentimentService() => _instance;
  SentimentService._internal();

  Interpreter? _interpreter;
  final int _maxLen = 256;
  final List<String> _labels = ['negative', 'positive'];
  List<String>? _vocab;
  Map<String, int>? _vocabMap;

  Future<void> loadModel() async {
    _interpreter ??= await Interpreter.fromAsset('assets/models/text_classification.tflite');
    if (_vocab == null) {
      final vocabStr = await rootBundle.loadString('assets/models/text_classification_vocab.txt');
      _vocab = vocabStr.split('\n').map((line) => line.split(' ')[0]).toList();
      _vocabMap = {for (var i = 0; i < _vocab!.length; i++) _vocab![i]: i};
    }
  }

  List<int> _tokenize(String text) {
    final unknownIdx = _vocabMap?['<UNKNOWN>'] ?? 2;
    final startIdx = _vocabMap?['<START>'] ?? 1;
    final tokens = text.toLowerCase().replaceAll(RegExp(r'[^a-z0-9 ]'), ' ').split(RegExp(r'\s+')).where((w) => w.isNotEmpty).toList();
    final indices = [startIdx];
    for (final word in tokens) {
      indices.add(_vocabMap?[word] ?? unknownIdx);
      if (indices.length >= _maxLen) break;
    }
    // Pad if needed
    while (indices.length < _maxLen) {
      indices.add(_vocabMap?['<PAD>'] ?? 0);
    }
    return indices;
  }

  Future<String> analyze(String text) async {
    await loadModel();
    final input = _tokenize(text);
    final output = List.filled(1 * _labels.length, 0.0).reshape([1, _labels.length]);
    _interpreter!.run([input], output);
    final scores = output[0] as List<double>;
    final maxScore = scores.reduce((double a, double b) => a > b ? a : b);
    final maxIdx = scores.indexOf(maxScore);
    final confidence = maxScore;
    if (confidence < 0.6) return 'neutral';
    return _labels[maxIdx];
  }
} 