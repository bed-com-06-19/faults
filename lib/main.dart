import 'package:faults/features/user_auth/firebase_auth_implementation/authWrapper.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart';
import 'features/user_auth/presentation/pages/theme.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (kIsWeb) {
    await Firebase.initializeApp(
      options: const FirebaseOptions(
        apiKey: "AIzaSyBfyyLutVWu8cOHtZS8NtnJf3IeH3Rx1xI",
        appId: "1:664103674812:web:4408c024503b178b2e01b9",
        messagingSenderId: "664103674812",
        projectId: "faults-2a6ef",
      ),
    );
  } else {
    await Firebase.initializeApp();
  }

  await initializeNotifications();

  final isDarkMode = await _getDarkModePreference();

  runApp(FaultDetectionApp(isDarkMode));
}

Future<void> initializeNotifications() async {
  const AndroidInitializationSettings androidInit =
      AndroidInitializationSettings('@mipmap/ic_launcher');

  const InitializationSettings initSettings =
      InitializationSettings(android: androidInit);

  await flutterLocalNotificationsPlugin.initialize(initSettings);
}

Future<bool> _getDarkModePreference() async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getBool('isDarkMode') ?? false;
}

class FaultDetectionApp extends StatefulWidget {
  final bool isDarkMode;
  const FaultDetectionApp(this.isDarkMode, {super.key});

  @override
  State<FaultDetectionApp> createState() => _FaultDetectionAppState();
}

class _FaultDetectionAppState extends State<FaultDetectionApp> {
  late bool isDarkMode;

  @override
  void initState() {
    super.initState();
    isDarkMode = widget.isDarkMode;
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Fault Detection System',
      themeMode: isDarkMode ? ThemeMode.dark : ThemeMode.light,
      theme: lightTheme,
      darkTheme: darkTheme,
      home: const AuthWrapper(),
    );
  }
}
