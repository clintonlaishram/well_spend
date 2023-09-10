import 'package:sentry_flutter/sentry_flutter.dart';


import 'package:flutter/material.dart';
import 'package:well_spend/tabs.dart';

Future<void> main() async {
  await SentryFlutter.init(
    (options) {
      options.dsn = 'https://a44d55ef246391d4c9dc23ada6bdc66f@o4505823460196352.ingest.sentry.io/4505823476318208';
      options.tracesSampleRate = 0.01;
      options.attachScreenshot = true;
    },
    appRunner: ()  => runApp(
      const SentryScreenshotWidget(
        child: MyApp(),
      ),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Well Spend',
      theme: ThemeData( 
        primarySwatch: Colors.blue,
        brightness: Brightness.dark,
      ),
      home: const TabsController());
  }
}

