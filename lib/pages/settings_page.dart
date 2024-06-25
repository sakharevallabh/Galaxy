import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pattern_lock/pattern_lock.dart';
import 'package:pin_code_fields/pin_code_fields.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  SettingsPageState createState() => SettingsPageState();
}

class SettingsPageState extends State<SettingsPage> {
  String _lockMethod = 'none';
  String? _pattern;
  String? _pin;

  @override
  void initState() {
    super.initState();
    _loadPreferences();
  }

  Future<void> _loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _lockMethod = prefs.getString('lockMethod') ?? 'none';
      _pattern = prefs.getString('pattern');
      _pin = prefs.getString('pin');
    });
  }

  Future<void> _setLockMethod(String method) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('lockMethod', method);
    setState(() {
      _lockMethod = method;
    });
  }

  Future<void> _setPattern(List<int> pattern) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('pattern', pattern.join(','));
    setState(() {
      _pattern = pattern.join(',');
    });
  }

  Future<void> _setPin(String pin) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('pin', pin);
    setState(() {
      _pin = pin;
    });
  }

  void _verifyPattern(List<int> pattern) {
    _setPattern(pattern);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Pattern set successfully')),
    );
  }

  void _verifyPin(String pin) {
    _setPin(pin);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('PIN set successfully')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: Column(
        children: [
          ListTile(
            title: const Text('None'),
            leading: Radio(
              value: 'none',
              groupValue: _lockMethod,
              onChanged: (String? value) {
                if (value != null) {
                  _setLockMethod(value);
                }
              },
            ),
          ),
          ListTile(
            title: const Text('Pattern Lock'),
            leading: Radio(
              value: 'pattern',
              groupValue: _lockMethod,
              onChanged: (String? value) {
                if (value != null) {
                  _setLockMethod(value);
                }
              },
            ),
          ),
          if (_lockMethod == 'pattern') ...[
            const Text('Draw your pattern'),
            PatternLock(
              selectedColor: Colors.blue,
              notSelectedColor: Colors.grey,
              pointRadius: 10,
              showInput: true,
              dimension: 3,
              relativePadding: 0.7,
              onInputComplete: _verifyPattern,
            ),
          ],
          ListTile(
            title: const Text('PIN Code'),
            leading: Radio(
              value: 'pin',
              groupValue: _lockMethod,
              onChanged: (String? value) {
                if (value != null) {
                  _setLockMethod(value);
                }
              },
            ),
          ),
          if (_lockMethod == 'pin') ...[
            const Text('Enter your PIN'),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30),
              child: PinCodeTextField(
                appContext: context,
                length: 4,
                onChanged: (_) {},
                onCompleted: _verifyPin,
              ),
            ),
          ],
          ListTile(
            title: const Text('Face Unlock'),
            leading: Radio(
              value: 'face',
              groupValue: _lockMethod,
              onChanged: (String? value) {
                if (value != null) {
                  _setLockMethod(value);
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}
