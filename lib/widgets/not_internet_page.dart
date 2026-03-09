import 'package:flutter/material.dart';

class NotInternetPage extends StatelessWidget {
  final VoidCallback onRetry;
  const NotInternetPage({super.key, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(38.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset("assets/images/not_connected.png", width: width * 0.5),
            SizedBox(height: 30),
            Text("Whoops!"),
            Text("No Internet connection found. Check your connection or try again."),
            SizedBox(),
            ElevatedButton(onPressed: onRetry, child: Text("Try Again")),
          ],
        ),
      ),
    );
  }
}
