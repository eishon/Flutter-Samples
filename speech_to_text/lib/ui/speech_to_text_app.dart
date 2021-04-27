import 'package:flutter/material.dart';

import 'sppech_to_text/speech_to_text_page.dart';

class SpeecghToTextApp extends StatefulWidget {
  @override
  _SpeecghToTextAppState createState() => _SpeecghToTextAppState();
}

class _SpeecghToTextAppState extends State<SpeecghToTextApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: SpeecghToTextPage(),
    );
  }
}
