import 'package:flutter/material.dart';
/*import 'package:flutter_inappwebview/flutter_inappwebview.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: Text('WebView Communication Example')),
        body: WebViewExample(),
      ),
    );
  }
}

class WebViewExample extends StatefulWidget {
  @override
  _WebViewExampleState createState() => _WebViewExampleState();
}

class _WebViewExampleState extends State<WebViewExample> {
  final _controller = InAppWebViewController();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ElevatedButton(
          onPressed: () {
           // _controller.evaluateJavascript('callFlutterFunction("Hello from JavaScript")');
          },
          child: Text('Call Flutter Function from JS'),
        ),
        Expanded(
          child: InAppWebView(
            initialUrlRequest: URLRequest(url: Uri.parse('assets/js_example.html')),
            onWebViewCreated: (controller) {
            //  _controller = controller;
            },
            onConsoleMessage: (controller, consoleMessage) {
              print('Console Message: ${consoleMessage.message}');
            },
          ),
        ),
      ],
    );
  }
}

// The function that can be called from JavaScript
void flutterFunction(String message) {
  print("Flutter function was called from JavaScript with message: $message");
}
*/