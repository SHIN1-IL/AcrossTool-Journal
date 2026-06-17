import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'repositories/preferences_repository.dart';
import 'repositories/task_repository.dart';
import 'screens/acrosstool_main_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await initializeDateFormatting('ko_KR');
    final taskRepository = await TaskRepository.create();
    final preferencesRepository = await PreferencesRepository.create();
    if (preferencesRepository.needsTaskStoreReset()) {
      await taskRepository.clearAllTasks();
      await preferencesRepository.markTaskStoreResetDone();
    }
    runApp(
      AcrossToolJournalApp(
        taskRepository: taskRepository,
        preferencesRepository: preferencesRepository,
      ),
    );
  } catch (error, stackTrace) {
    debugPrint('앱 초기화 실패: $error\n$stackTrace');
    runApp(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Text(
                '앱을 시작하지 못했습니다.\n$error',
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class AcrossToolJournalApp extends StatelessWidget {
  const AcrossToolJournalApp({
    super.key,
    required this.taskRepository,
    required this.preferencesRepository,
  });

  final TaskRepository taskRepository;
  final PreferencesRepository preferencesRepository;

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
        useMaterial3: true,
        brightness: Brightness.light,
        scaffoldBackgroundColor: Colors.white,
        canvasColor: Colors.white,
        cardColor: Colors.white,
        dialogTheme: const DialogThemeData(backgroundColor: Colors.white),
        colorScheme: const ColorScheme.light(
          surface: Colors.white,
          onSurface: Colors.black,
          primary: Colors.black,
          onPrimary: Colors.white,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
          elevation: 0,
        ),
        iconTheme: const IconThemeData(color: Colors.black),
        textTheme: const TextTheme(
          bodyMedium: TextStyle(color: Colors.black),
          bodyLarge: TextStyle(color: Colors.black),
          titleMedium: TextStyle(color: Colors.black),
        ),
      ),
      home: AcrossToolMainScreen(
        taskRepository: taskRepository,
        preferencesRepository: preferencesRepository,
      ),
    );
  }
}
