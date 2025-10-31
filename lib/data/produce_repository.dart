import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import '../models/produce_item.dart';

class ProduceRepository {
  const ProduceRepository();

  Future<List<ProduceItem>> fetchAll() async {
    final raw = await rootBundle.loadString('assets/produce.json');
    final data = json.decode(raw) as List<dynamic>;
    return data
        .cast<Map<String, dynamic>>()
        .map(ProduceItem.fromJson)
        .toList();
  }
}
