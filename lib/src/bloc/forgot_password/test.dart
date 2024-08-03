import 'package:flutter/material.dart';
import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Email Sender Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: EmailSenderPage(),
    );
  }
}

class EmailSenderPage extends StatefulWidget {
  @override
  _EmailSenderPageState createState() => _EmailSenderPageState();
}

class _EmailSenderPageState extends State<EmailSenderPage> {
  final _formKey = GlobalKey<FormState>();
  String _senderEmail = '';
  String _senderPassword = '';
  bool _isSending = false;

  Future<void> sendEmail() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      setState(() {
        _isSending = true;
      });

      final smtpServer = gmail(_senderEmail, _senderPassword);

      final message = Message()
        ..from = Address(_senderEmail, 'Sender Name')
        ..recipients.add('khanhk66uet@gmail.com')
        ..subject = 'Test Email from Flutter'
        ..text = 'This is a test email sent from a Flutter application.';

      try {
        final sendReport = await send(message, smtpServer);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Email sent successfully!')),
        );
        print('Message sent: ' + sendReport.toString());
      } on MailerException catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to send email. Please check your credentials.')),
        );
        print('Message not sent.');
        for (var p in e.problems) {
          print('Problem: ${p.code}: ${p.msg}');
        }
      } finally {
        setState(() {
          _isSending = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Email Sender Demo'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                decoration: InputDecoration(labelText: 'Sender Email'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter sender email';
                  }
                  return null;
                },
                onSaved: (value) => _senderEmail = value!,
              ),
              SizedBox(height: 16),
              TextFormField(
                decoration: InputDecoration(labelText: 'Sender Password'),
                obscureText: true,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter sender password';
                  }
                  return null;
                },
                onSaved: (value) => _senderPassword = value!,
              ),
              SizedBox(height: 24),
              ElevatedButton(
                onPressed: _isSending ? null : sendEmail,
                child: _isSending
                    ? CircularProgressIndicator()
                    : Text('Send Email to khanhk66uet@gmail.com'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}