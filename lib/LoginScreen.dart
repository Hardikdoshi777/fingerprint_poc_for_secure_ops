import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:local_auth/local_auth.dart';

import 'HomeScreen.dart';

class LoginScreen extends StatefulWidget {
  final FlutterSecureStorage secureStorage;

  const LoginScreen({required this.secureStorage, super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {

  final LocalAuthentication auth = LocalAuthentication();
  bool _isAuthenticating = false;
  String _status = "Not Authenticated";
  final _mpinController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tryBiometricLogin();
  }

  Future<void> _tryBiometricLogin() async {
    bool canCheckBiometrics = await auth.canCheckBiometrics;
    bool isSupported = await auth.isDeviceSupported();

    if (canCheckBiometrics && isSupported) {
      try {
        setState(() => _isAuthenticating = true);
        bool didAuthenticate = await auth.authenticate(
          localizedReason: 'Scan your fingerprint or face to log in',
          options: const AuthenticationOptions(
            biometricOnly: true,
          ),
        );

        if (didAuthenticate) {
          await widget.secureStorage.write(key: 'token', value: 'secure_token_xyz');
          _navigateToHome();
        } else {
          setState(() {
            _status = "Biometric failed. Please enter MPIN.";
          });
        }
      } catch (e) {
        setState(() => _status = "Error: ${e.toString()}");
      } finally {
        setState(() => _isAuthenticating = false);
      }
    } else {
      setState(() {
        _status = "Biometric not supported. Please enter MPIN.";
      });
    }
  }

  void _validateMPIN() async {
    if (_mpinController.text == "1234") {
      await widget.secureStorage.write(key: 'token', value: 'secure_token_xyz');
      _navigateToHome();
    } else {
      setState(() => _status = "Incorrect MPIN");
    }
  }

  void _navigateToHome() {
    Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => HomeScreen()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Login")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text(_status),
            const SizedBox(height: 20),
            TextField(
              controller: _mpinController,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Enter MPIN',
              ),
              obscureText: true,
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: _validateMPIN,
              child: const Text("Login with MPIN"),
            ),
          ],
        ),
      ),
    );
  }
}
