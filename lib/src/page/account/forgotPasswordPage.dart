import 'dart:async';
import 'package:flutter/material.dart';
import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server.dart';
import 'package:ocop/src/page/elements/background.dart';
import 'package:ocop/src/page/elements/logo.dart';
import 'package:ocop/mainData/database/databases.dart';

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({Key? key}) : super(key: key);

  @override
  _ForgotPasswordPageState createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  late DefaultDatabaseOptions databaseOptions;
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _codeController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _isSending = false;
  bool _isCodeSent = false;
  bool _isCodeVerified = false;
  int _countdownSeconds = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    databaseOptions = DefaultDatabaseOptions();
    _connectToDatabase();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _codeController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    _timer?.cancel();
    _disconnectFromDatabase();
    super.dispose();
  }

  Future<void> _connectToDatabase() async {
    try {
      await databaseOptions.connect();
      print('Connected to database');
    } catch (e) {
      print('Failed to connect to database: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to connect to database. Please try again later.')),
      );
    }
  }

  Future<void> _disconnectFromDatabase() async {
    try {
      await databaseOptions.close();
      print('Disconnected from database');
    } catch (e) {
      print('Error disconnecting from database: $e');
    }
  }

  void startCountdown() {
    _countdownSeconds = 120; // 2 minutes
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      setState(() {
        if (_countdownSeconds > 0) {
          _countdownSeconds--;
        } else {
          _timer?.cancel();
        }
      });
    });
  }

  Future<void> checkExistingCode() async {
    bool emailExists = await databaseOptions.accountDatabase.checkEmailExists(_emailController.text);
    
    if (!emailExists) {
      setState(() {
        _isCodeSent = false;
        _countdownSeconds = 0;
      });
      return;
    }

    int remainingTime = await databaseOptions.accountDatabase.getRemainingTimeForResetCode(_emailController.text);
    if (remainingTime > 0) {
      setState(() {
        _isCodeSent = true;
        _countdownSeconds = remainingTime;
      });
      startCountdown();
    } else {
      setState(() {
        _isCodeSent = false;
        _countdownSeconds = 0;
      });
    }
  }

  Future<void> sendResetCode() async {
    if (_formKey.currentState!.validate()) {
      await _sendResetCodeImpl();
    }
  }

  Future<void> resendCode() async {
    await _sendResetCodeImpl();
  }

  Future<void> _sendResetCodeImpl() async {
    setState(() {
      _isSending = true;
    });

    try {
      bool emailExists = await databaseOptions.accountDatabase.checkEmailExists(_emailController.text);

      if (!emailExists) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('This email is not associated with any account.')),
        );
        setState(() {
          _isSending = false;
        });
        return;
      }

      String resetCode = await databaseOptions.accountDatabase.createPasswordResetToken(_emailController.text);

      if (resetCode.isNotEmpty) {
        final smtpServer = gmail('lamdaimotcaidi@gmail.com', 'mkiy nvfg dzua hqsb');

        final message = Message()
          ..from = Address('lamdaimotcaidi@gmail.com', 'OCOP Password Reset')
          ..recipients.add(_emailController.text)
          ..subject = 'Reset Password Code'
          ..text = 'Your reset password code is: $resetCode. This code will expire in 15 minutes.';

        try {
          await send(message, smtpServer);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('New reset code sent successfully to ${_emailController.text}!')),
          );
          setState(() {
            _isCodeSent = true;
            _codeController.clear(); // Clear previous code
          });
          startCountdown();
        } catch (e) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to send reset code. Please try again.')),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to generate reset code. Please try again.')),
        );
      }
    } catch (e) {
      print('Error sending reset code: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('An error occurred. Please try again later.')),
      );
    } finally {
      setState(() {
        _isSending = false;
      });
    }
  }

  Future<void> verifyCode() async {
    if (_formKey.currentState!.validate()) {
      try {
        bool isVerified = await databaseOptions.accountDatabase.verifyPasswordResetToken(_emailController.text, _codeController.text);

        if (isVerified) {
          setState(() {
            _isCodeVerified = true;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Code verified successfully. Please enter your new password.')),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Invalid or expired code. Please try again or request a new code.')),
          );
        }
      } catch (e) {
        print('Error verifying code: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('An error occurred. Please try again later.')),
        );
      }
    }
  }

Future<void> resetPassword() async {
  if (_formKey.currentState!.validate()) {
    if (_newPasswordController.text == _confirmPasswordController.text) {
      try {
        bool isReset = await databaseOptions.accountDatabase.resetPassword(_emailController.text, _newPasswordController.text);

        if (isReset) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Password reset successfully. You can now log in with your new password.')),
          );
          Navigator.pop(context); // Return to login page
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to reset password. Please try again.')),
          );
        }
      } catch (e) {
        print('Error resetting password: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('An error occurred. Please try again later.')),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Passwords do not match. Please try again.')),
      );
    }
  }
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Quên mật khẩu"),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Stack(
        children: [
          const BackGround(),
          Center(
            child: SingleChildScrollView(
              child: Container(
                width: MediaQuery.of(context).size.width * 0.9,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.5),
                      spreadRadius: 5,
                      blurRadius: 7,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Logo(),
                      const SizedBox(height: 20),
                      TextFormField(
                        controller: _emailController,
                        decoration: const InputDecoration(
                          labelText: 'Email',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.email),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your email';
                          }
                          return null;
                        },
                        onChanged: (value) {
                          if (value.isNotEmpty) {
                            checkExistingCode();
                          }
                        },
                      ),
                      const SizedBox(height: 20),
                      if (_isCodeSent && !_isCodeVerified) ...[
                        TextFormField(
                          controller: _codeController,
                          decoration: const InputDecoration(
                            labelText: 'Reset Code',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.lock),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter the reset code';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 10),
                        if (_countdownSeconds > 0)
                          Text('Resend code in ${_countdownSeconds}s'),
                        if (_countdownSeconds == 0)
                          TextButton(
                            onPressed: resendCode,
                            child: Text('Resend Code'),
                          ),
                      ],
                      if (_isCodeVerified) ...[
                        TextFormField(
                          controller: _newPasswordController,
                          decoration: const InputDecoration(
                            labelText: 'New Password',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.lock),
                          ),
                          obscureText: true,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter a new password';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 20),
                        TextFormField(
                          controller: _confirmPasswordController,
                          decoration: const InputDecoration(
                            labelText: 'Confirm New Password',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.lock),
                          ),
                          obscureText: true,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please confirm your new password';
                            }
                            if (value != _newPasswordController.text) {
                              return 'Passwords do not match';
                            }
                            return null;
                          },
                        ),
                      ],
                      const SizedBox(height: 20),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 15),
                            backgroundColor: Colors.green,
                          ),
                          onPressed: _isSending
                              ? null
                              : !_isCodeSent
                                  ? sendResetCode
                                  : !_isCodeVerified
                                      ? verifyCode
                                      : resetPassword,
                          child: _isSending
                              ? const CircularProgressIndicator(color: Colors.white)
                              : Text(
                                  !_isCodeSent
                                      ? 'Send Reset Code'
                                      : !_isCodeVerified
                                          ? 'Verify Code'
                                          : 'Reset Password',
                                  style: const TextStyle(fontSize: 16),
                                ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}