import 'package:flutter/material.dart';
import 'package:doc_query/features/models/presentation/model_manager_screen.dart';

void main() {
  runApp(const DocQueryApp());
}

class DocQueryApp extends StatelessWidget {
  const DocQueryApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Doc Query AI',
      debugShowCheckedModeBanner:
          false, // Removes the little red "DEBUG" banner
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.blue,
        brightness: Brightness.light,
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.blue,
        brightness: Brightness.dark,
      ),
      themeMode: ThemeMode.system,

      home: const ModelManagerScreen(),
    );
  }
}
