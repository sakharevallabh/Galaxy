import 'package:flutter/material.dart';
import 'package:local_auth/local_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:email_auth/email_auth.dart';
import 'package:Galaxy/pages/home_page.dart'; // Ensure this import is correct

class LockScreen extends StatefulWidget {
  final VoidCallback onUnlock;

  const LockScreen({super.key, required this.onUnlock});

  @override
  LockScreenState createState() => LockScreenState();
}

class LockScreenState extends State<LockScreen> {
  final LocalAuthentication _localAuthentication = LocalAuthentication();
  late SharedPreferences _prefs;
  String? _currentLockMethod;
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _otpController = TextEditingController();
  late EmailAuth emailAuth;
  String? _recoveryEmail;

  @override
  void initState() {
    super.initState();
    emailAuth = EmailAuth(sessionName: "Galaxy App");
    _initPrefs();
    _checkCurrentLockMethod();
  }

  Future<void> _initPrefs() async {
    _prefs = await SharedPreferences.getInstance();
  }

  Future<void> _checkCurrentLockMethod() async {
    _currentLockMethod = _prefs.getString('lockMethod');
    if (_currentLockMethod == null) {
      // First time setup, show setup options
      _showSetupOptions();
    } else {
      // Lock method already set, show authentication screen
      _showAuthentication();
    }
  }

  void _showSetupOptions() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Setup Lock Method'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ElevatedButton(
              onPressed: () => _setLockMethod('PIN'),
              child: const Text('Set PIN'),
            ),
            ElevatedButton(
              onPressed: () => _setLockMethod('Pattern'),
              child: const Text('Set Pattern'),
            ),
            ElevatedButton(
              onPressed: () async {
                // Simulate successful face authentication for demo
                bool success = true; // Replace with real authentication logic
                if (success) {
                  _setLockMethod('Face');
                }
              },
              child: const Text('Set Face Unlock'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _setLockMethod(String method) async {
    await _prefs.setString('lockMethod', method);
    setState(() {
      _currentLockMethod = method;
    });
    if (method == 'PIN' || method == 'Pattern') {
      _askForRecoveryEmail();
    } else {
      _navigateToHomePage();
    }
  }

  void _askForRecoveryEmail() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Setup Recovery Email'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(labelText: 'Enter your email'),
            ),
            ElevatedButton(
              onPressed: () {
                _sendOtpToEmail();
              },
              child: const Text('Send OTP'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _sendOtpToEmail() async {
    var res = await emailAuth.sendOtp(recipientMail: _emailController.text);
    if (res) {
      _showEmailVerificationDialog();
    } else {
      _showErrorDialog("Failed to send OTP. Please try again.");
    }
  }

  void _showEmailVerificationDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Enter OTP'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _otpController,
              decoration: const InputDecoration(labelText: 'OTP'),
            ),
            ElevatedButton(
              onPressed: () {
                _verifyOtp();
              },
              child: const Text('Verify'),
            ),
          ],
        ),
      ),
    );
  }

  void _verifyOtp() {
    bool isValid = emailAuth.validateOtp(
      recipientMail: _emailController.text,
      userOtp: _otpController.text,
    );
    if (isValid) {
      _setRecoveryEmail();
    } else {
      _showErrorDialog("Invalid OTP. Please try again.");
    }
  }

  Future<void> _setRecoveryEmail() async {
    _recoveryEmail = _emailController.text;
    await _prefs.setString('recoveryEmail', _recoveryEmail!);
    _navigateToHomePage();
  }

  void _navigateToHomePage() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => const MyHomePage(title: 'Galaxy View'),
      ),
    );
  }

  void _showAuthentication() {
    showDialog(
      context: context,
      barrierDismissible: false, // Prevent dismiss by tapping outside
      builder: (context) => AlertDialog(
        title: const Text('Authenticate'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Please authenticate with $_currentLockMethod'),
            if (_currentLockMethod == 'pin' || _currentLockMethod == 'Pattern')
              TextField(
                decoration: InputDecoration(
                  labelText: 'Enter $_currentLockMethod',
                ),
                obscureText: true,
                onSubmitted: (value) {
                  _verifyLockMethod(value);
                },
              ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              // Reset lock method: show reset dialog
              _showResetDialog();
            },
            child: const Text('Forgot Lock Method'),
          ),
        ],
      ),
    );
  }

  void _verifyLockMethod(String input) {
    // Implement the verification logic here
    // If successful, call widget.onUnlock()
    // For demonstration, we assume the verification is successful
    if (input.isNotEmpty) {
      widget.onUnlock();
      Navigator.pop(context); // Close the authentication dialog
    } else {
      _showErrorDialog("Invalid input. Please try again.");
    }
  }

  void _showResetDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reset Lock Method'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(labelText: 'Enter your email'),
            ),
            ElevatedButton(
              onPressed: () {
                _sendOtpToEmail();
              },
              child: const Text('Send OTP'),
            ),
          ],
        ),
      ),
    );
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Error'),
        content: Text(message),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Container(
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage('assets/images/Background.png'),
              fit: BoxFit.cover,
            ),
          ),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 300),
                const Text(
                  'Galaxy App',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 25),
                const Text(
                  'Welcome to your Universe',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 15),
                GestureDetector(
                  onTap: _checkCurrentLockMethod,
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    margin: const EdgeInsets.symmetric(horizontal: 100),
                    decoration: BoxDecoration(
                      color: Colors.black,
                      borderRadius: BorderRadius.circular(25),
                    ),
                    child: const Center(
                      child: Text(
                        "Setup Lock Screen",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 50),
              ], 
            ),
          ),
        ),
      ),
    );
  }
}
