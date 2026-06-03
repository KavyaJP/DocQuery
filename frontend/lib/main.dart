import 'dart:async';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:doc_query/main_layout_screen.dart';
import 'package:doc_query/config/api_config.dart';

void main() {
  runApp(const DocQueryApp());
}

class DocQueryApp extends StatelessWidget {
  const DocQueryApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Doc Query AI',
      debugShowCheckedModeBanner: false,
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
      home: const ServerCheckScreen(),
    );
  }
}

class ServerCheckScreen extends StatefulWidget {
  const ServerCheckScreen({super.key});

  @override
  State<ServerCheckScreen> createState() => _ServerCheckScreenState();
}

class _ServerCheckScreenState extends State<ServerCheckScreen> {
  Timer? _pollingTimer;
  bool _isConnected = false;

  @override
  void initState() {
    super.initState();
    _startPolling();
  }

  @override
  void dispose() {
    _pollingTimer?.cancel();
    super.dispose();
  }

  // Pings the backend every 2 seconds and automatically cancels itself once a 200 OK is received
  void _startPolling() {
    _pollingTimer = Timer.periodic(const Duration(seconds: 2), (timer) async {
      try {
        final response = await Dio().get(ApiConfig.rootUrl);
        if (response.statusCode == 200) {
          timer.cancel();
          if (mounted) {
            setState(() {
              _isConnected = true;
            });
          }
        }
      } catch (_) {
        // Silently ignore connection errors so the timer keeps looping
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isConnected) {
      return const MainLayoutScreen();
    }

    return const Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 24),
            Text(
              'Initializing environment...',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              'Connecting to local processing engine.',
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}
