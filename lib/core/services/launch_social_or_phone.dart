import 'package:url_launcher/url_launcher.dart';

Future<void> launchSocialOrPhone(String input) async {
  final uri = _resolveLaunchUri(input);
  if (uri == null) {
    throw 'URL ochib bo‘lmadi: $input';
  }

  final opened = await launchUrl(uri, mode: LaunchMode.externalApplication);
  if (opened) return;

  if (uri.scheme == 'https' || uri.scheme == 'http') {
    final openedInApp = await launchUrl(uri, mode: LaunchMode.inAppBrowserView);
    if (openedInApp) return;
  }

  throw 'URL ochib bo‘lmadi: $uri';
}

Uri? _resolveLaunchUri(String input) {
  if (input.startsWith('+') || input.startsWith('998')) {
    return Uri.parse('tel:$input');
  }
  if (input.startsWith('@')) {
    final username = input.substring(1);
    return Uri.parse('https://t.me/$username');
  }
  if (input.startsWith('telegram:')) {
    final username = input.replaceFirst('telegram:', '');
    return Uri.parse('https://t.me/$username');
  }
  if (input.startsWith('instagram:')) {
    final username = input.replaceFirst('instagram:', '');
    return Uri.parse('https://www.instagram.com/$username');
  }
  if (input.startsWith('whatsapp:')) {
    final value = input.replaceFirst('whatsapp:', '').trim();
    final digitsOnly = value.replaceAll(RegExp(r'\D'), '');
    if (digitsOnly.length >= 10) {
      return Uri.parse('https://wa.me/$digitsOnly');
    }
    return Uri.parse('https://wa.me/$value');
  }
  if (input.startsWith('facebook:')) {
    final username = input.replaceFirst('facebook:', '');
    return Uri.parse('https://facebook.com/$username');
  }
  if (input.startsWith('google:')) {
    final query = input.replaceFirst('google:', '');
    return Uri.parse('https://www.google.com/search?q=$query');
  }
  if (input.startsWith('http')) {
    return Uri.parse(input);
  }
  return Uri.parse('https://www.google.com/search?q=$input');
}
