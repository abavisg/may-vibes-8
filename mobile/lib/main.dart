import 'package:flutter/material.dart';
import 'package:mobile/screens/reframe_screen.dart';

void main() {
  runApp(const MindFlipApp());
}

class MindFlipApp extends StatelessWidget {
  const MindFlipApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MindFlip',
      theme: ThemeData(primarySwatch: Colors.blueGrey),
      home: const ReframeScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}
