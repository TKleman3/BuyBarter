import 'package:flutter/material.dart';
import 'screens/produce_list_screen.dart';

void main() => runApp(const ProduceShareApp());

class ProduceShareApp extends StatelessWidget {
  const ProduceShareApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Produce Share',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
        useMaterial3: true,
      ),
      home: const ProduceListScreen(),
    );
  }
}
