import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:webview_flutter_android/webview_flutter_android.dart';
import 'package:permission_handler/permission_handler.dart';

void main() {
  runApp(const SplitPeApp());
}

class SplitPeApp extends StatelessWidget {
  const SplitPeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: SplitPeWebViewScreen(),
    );
  }
}

class SplitPeWebViewScreen extends StatefulWidget {
  const SplitPeWebViewScreen({super.key});

  @override
  State<SplitPeWebViewScreen> createState() => _SplitPeWebViewScreenState();
}

class _SplitPeWebViewScreenState extends State<SplitPeWebViewScreen> {
  late final WebViewController _controller;

  @override
  void initState() {
    super.initState();
    // অ্যাপ চালু হওয়ার সাথে সাথে ক্যামেরা পারমিশন চেয়ে নেওয়া
    _requestCameraPermission();

    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..loadRequest(Uri.parse('https://splitpe-lovat.vercel.app/'));

    // Android WebView-এর জন্য ক্যামেরা ও মিডিয়া পারমিশন হ্যান্ডেল করা
    if (_controller.platform is AndroidWebViewController) {
      final AndroidWebViewController androidController =
          _controller.platform as AndroidWebViewController;
      androidController.setMediaPlaybackRequiresUserGesture(false);
      
      androidController.setOnPlatformPermissionRequest(
        (PlatformWebViewPermissionRequest request) async {
          // ওয়েভভিউ থেকে ক্যামেরা চাইলে পপ-আপ বা পারমিশন গ্র্যান্ট করা
          var status = await Permission.camera.status;
          if (!status.isGranted) {
            await Permission.camera.request();
          }
          request.grant();
        },
      );
    }
  }

  // ক্যামেরা পারমিশনের ফাংশন
  Future<void> _requestCameraPermission() async {
    var status = await Permission.camera.status;
    if (!status.isDenied && !status.isGranted) {
      await Permission.camera.request();
    } else if (status.isDenied) {
      await Permission.camera.request();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: WebViewWidget(controller: _controller),
      ),
    );
  }
}
