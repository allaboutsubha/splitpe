import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
// Import for Android features to handle camera permissions in WebView
import 'package:webview_flutter_android/webview_flutter_android.dart';

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
    
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..loadRequest(Uri.parse('https://splitpe-lovat.vercel.app/'));

    // Android-er WebView-e Camera ba Mic permission popup allow korar jonno ei block ti dorkar
    if (_controller.platform is AndroidWebViewController) {
      final AndroidWebViewController androidController =
          _controller.platform as AndroidWebViewController;
      androidController.setMediaPlaybackRequiresUserGesture(false);
      
      // Camera permission request automatically handle korar jonno
      androidController.setOnPlatformPermissionRequest(
        (PlatformWebViewPermissionRequest request) {
          request.grant();
        },
      );
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
