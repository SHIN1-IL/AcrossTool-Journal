import 'package:flutter/material.dart';

import 'repositories/task_repository.dart';
import 'screens/acrosstool_main_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final taskRepository = await TaskRepository.create();
  runApp(AcrossToolJournalApp(taskRepository: taskRepository));
}

class AcrossToolJournalApp extends StatelessWidget {
  const AcrossToolJournalApp({
    super.key,
    required this.taskRepository,
  });

  final TaskRepository taskRepository;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AcrossTool Journal',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: AcrossToolMainScreen(taskRepository: taskRepository),
    );
  }
}
