import 'package:flutter/material.dart';

class VerseLabels {
  static const Map<String, Map<int, String>> _labels = {
    'genesis_1': {
      1: 'Creation',
      3: 'Command',
      26: 'Creation',
    },
    'psalm_23': {
      1: 'Trust',
      4: 'Comfort',
    },
    'psalm_119': {
      1: 'Wisdom',
      9: 'Instruction',
    },
    'matthew_5': {
      3: 'Beatitudes',
      17: 'Teaching',
    },
    'john_14': {
      1: 'Comfort',
      2: 'Promise',
      27: 'Peace',
    },
    'romans_8': {
      1: 'Doctrine',
      28: 'Assurance',
    },
    '1corinthians_13': {
      1: 'Love',
      13: 'Love',
    },
    'revelation_21': {
      1: 'Prophecy',
      2: 'New Creation',
    },
  };

  static String? getLabel(String bookId, int chapter, int verse) {
    final key = '${bookId.toLowerCase()}_$chapter';
    return _labels[key]?[verse];
  }

  static Color getLabelColor(String label) {
    switch (label) {
      case 'Creation':
      case 'Narrative':
        return Colors.blue; // Narrative -> blue
      case 'Comfort':
      case 'Promise':
      case 'Peace':
        return Colors.green; // Dialogue -> green
      case 'Prayer':
        return Colors.purple; // Prayer -> purple
      case 'Trust':
      case 'Love':
        return Colors.amber.shade700; // Poetry/Song -> gold
      case 'Command':
      case 'Teaching':
      case 'Beatitudes':
      case 'Instruction':
        return Colors.red; // Law/Command -> red
      case 'Prophecy':
      case 'New Creation':
        return Colors.orange; // Prophecy -> orange
      case 'Wisdom':
      case 'Doctrine':
      case 'Assurance':
      default:
        return Colors.teal; // Wisdom -> teal
    }
  }
}
