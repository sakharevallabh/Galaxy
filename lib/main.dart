import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:galaxy/pages/home_page.dart';
import 'package:galaxy/pages/lock_screen.dart';
import 'package:galaxy/provider/navigation_provider.dart';
import 'package:provider/provider.dart';

Future main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  static const String title = "Galaxy Application";

  const MyApp({super.key});

  @override
  Widget build(BuildContext context) => ChangeNotifierProvider(
        create: (context) => NavigationProvider(),
        child: MaterialApp(
          title: title,
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(seedColor: Colors.black),
            useMaterial3: true,
          ),
          // home: const LockScreenPage(),
          home: const MyHomePage(title: 'Galaxy View'),
        ),
      );
}

class LockScreenPage extends StatefulWidget {
  const LockScreenPage({super.key});

  @override
  LockScreenPageState createState() => LockScreenPageState();
}

class LockScreenPageState extends State<LockScreenPage> {
  bool _isUnlocked = false;

  void _onUnlock() {
    setState(() {
      _isUnlocked = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return _isUnlocked ? const MyHomePage(title: 'Galaxy View') : LockScreen(onUnlock: _onUnlock);
  }
}
