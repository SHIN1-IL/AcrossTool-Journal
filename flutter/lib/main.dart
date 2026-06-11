import 'package:flutter/material.dart';

import 'screens/acrosstool_main_screen.dart';

void main() {
  runApp(const AcrossToolJournalApp());
}

class AcrossToolJournalApp extends StatelessWidget {
  const AcrossToolJournalApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AcrossTool Journal',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const AcrossToolMainScreen(),
    );
  }
}
