import 'package:url_launcher/url_launcher.dart';

Future<void> launchSocialOrPhone(String input) async {
  Uri? uri;

  if (input.startsWith('+') || input.startsWith('998')) {
    // Telefon raqami
    uri = Uri.parse('tel:$input');
  } else if (input.startsWith('@')) {
    // Telegram username
    final username = input.substring(1);
    uri = Uri.parse('https://t.me/$username');
  } else if (input.startsWith('telegram:')) {
    final username = input.replaceFirst('telegram:', '');
    uri = Uri.parse('https://t.me/$username');
  } else if (input.startsWith('instagram:')) {
    final username = input.replaceFirst('instagram:', '');
    uri = Uri.parse('https://instagram.com/$username');
  } else if (input.startsWith('facebook:')) {
    final username = input.replaceFirst('facebook:', '');
    uri = Uri.parse('https://facebook.com/$username');
  } else if (input.startsWith('google:')) {
    final query = input.replaceFirst('google:', '');
    uri = Uri.parse('https://www.google.com/search?q=$query');
  } else if (input.startsWith('http')) {
    uri = Uri.parse(input);
  } else {
    // Default — Google search
    uri = Uri.parse('https://www.google.com/search?q=$input');
  }

  if (await canLaunchUrl(uri)) {
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  } else {
    throw 'URL ochib bo‘lmadi: $uri';
  }
}
