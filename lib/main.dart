import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:webview_flutter_android/webview_flutter_android.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:url_launcher/url_launcher.dart';

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
  bool _hasConnection = true;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _requestCameraPermission();

    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (String url) {
            setState(() {
              _isLoading = true;
            });
          },
          onPageFinished: (String url) {
            setState(() {
              _isLoading = false;
              _hasConnection = true;
            });
          },
          onWebResourceError: (WebResourceError error) {
            setState(() {
              _hasConnection = false;
              _isLoading = false;
            });
          },
          onNavigationRequest: (NavigationRequest request) async {
            if (request.url.startsWith('upi://') ||
                request.url.startsWith('otpauth://') ||
                request.url.startsWith('whatsapp://') ||
                request.url.startsWith('mailto:') ||
                request.url.startsWith('tel:')) {
              final Uri uri = Uri.parse(request.url);
              try {
                if (await canLaunchUrl(uri)) {
                  await launchUrl(uri, mode: LaunchMode.externalApplication);
                }
              } catch (e) {
                debugPrint('Could not launch ${request.url}: $e');
              }
              return NavigationDecision.prevent;
            }
            return NavigationDecision.navigate;
          },
        ),
      )
      ..loadRequest(Uri.parse('https://splitpe-lovat.vercel.app/'));

    if (_controller.platform is AndroidWebViewController) {
      final AndroidWebViewController androidController =
          _controller.platform as AndroidWebViewController;
      androidController.setMediaPlaybackRequiresUserGesture(false);
      androidController.setOnPlatformPermissionRequest(
        (PlatformWebViewPermissionRequest request) async {
          var status = await Permission.camera.status;
          if (!status.isGranted) {
            await Permission.camera.request();
          }
          request.grant();
        },
      );
    }
  }

  Future<void> _requestCameraPermission() async {
    var status = await Permission.camera.status;
    if (!status.isGranted) {
      await Permission.camera.request();
    }
  }

  void _reloadPage() {
    setState(() {
      _hasConnection = true;
      _isLoading = true;
    });
    _controller.reload();
  }

  Future<bool> _onWillPop() async {
    if (await _controller.canGoBack()) {
      _controller.goBack();
      return false;
    } else {
      bool? exitApp = await showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Exit App?'),
          content: const Text('Are you sure you want to exit SplitPe?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('No'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Yes'),
            ),
          ],
        ),
      );
      if (exitApp == true) {
        SystemNavigator.pop();
      }
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        body: SafeArea(
          child: Stack(
            children: [
              if (!_hasConnection)
                Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.wifi_off, size: 80, color: Colors.redAccent),
                        const SizedBox(height: 16),
                        const Text(
                          'No Internet Connection\nor Page Not Available',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Please check your internet connection and try again.',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.grey),
                        ),
                        const SizedBox(height: 24),
                        ElevatedButton.icon(
                          onPressed: _reloadPage,
                          icon: const Icon(Icons.refresh),
                          label: const Text('Refresh'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.indigo,
                            foregroundColor: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              else
                WebViewWidget(controller: _controller),

              if (_isLoading && _hasConnection)
                const Center(
                  child: CircularProgressIndicator(),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
