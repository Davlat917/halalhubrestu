import 'package:flutter/material.dart';
import 'package:halal_hub_resto/push_notification_service.dart';
import 'package:halal_hub_resto/web_page.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await PushNotificationHelper.initialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'HalalHub Restu',
      home: const WebViewPage(), //
    );
  }
}
