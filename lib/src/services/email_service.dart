import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server.dart';

class EmailService {
  static Future<void> sendPasswordResetEmail(String recipientEmail) async {
    final smtpServer = gmail('lamdaimotcaidi.com', 'mkiy nvfg dzua hqsb');
    
    final message = Message()
      ..from = Address('your_email@gmail.com', 'OCOP App')
      ..recipients.add(recipientEmail)
      ..subject = 'Yêu cầu đặt lại mật khẩu'
      ..text = 'Bạn đã yêu cầu đặt lại mật khẩu cho tài khoản OCOP của mình. '
               'Đây là email xác nhận yêu cầu đổi mật khẩu của bạn.';

    try {
      final sendReport = await send(message, smtpServer);
      print('Message sent: ' + sendReport.toString());
    } on MailerException catch (e) {
      print('Message not sent.');
      for (var p in e.problems) {
        print('Problem: ${p.code}: ${p.msg}');
      }
    }
  }
}