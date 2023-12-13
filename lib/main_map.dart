import "package:flutter/material.dart";
import "package:webview_flutter/webview_flutter.dart";

String parse_url = "";
class MainMap extends StatelessWidget
{
    MainMap(String puri)
    {
      parse_url = puri;
      print("\nmain map $puri");
    }
    @override
    Widget build(BuildContext context) {
      return MainMap_View();
    }
}

class MainMap_View extends StatefulWidget
{
  @override
    Map_View createState()
   {
    return Map_View();
   }
}

class Map_View extends State<MainMap_View>
{
  late WebViewController wvcontroller, acontroller;

  @override
  void initState()
  {
    acontroller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..loadRequest(
        Uri.dataFromString('''<html>
            <head><meta name="viewport" content="width=device-width, initial-scale=1.0"></head>
            <body><iframe src="$parse_url" 
            title="YouTube video player" frameborder="0"></iframe></body></html>''',
            mimeType: 'text/html'),
      );

      wvcontroller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..loadRequest(
        Uri.parse(parse_url),
      );
  }

  @override
  Widget build(BuildContext bc)
  {
    return WebViewWidget(controller: wvcontroller);
  }
}

