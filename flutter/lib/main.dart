import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'repositories/task_repository.dart';
import 'screens/acrosstool_main_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('ko_KR');
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
      locale: const Locale('ko', 'KR'),
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('ko', 'KR'),
      ],
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: AcrossToolMainScreen(taskRepository: taskRepository),
    );
  }
}
