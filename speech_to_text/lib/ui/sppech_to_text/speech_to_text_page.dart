import 'dart:math';

import 'package:clipboard/clipboard.dart';
import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_recognition_error.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text_test/ui/widget/substring_highlighted.dart';
import 'package:speech_to_text_test/utils/command.dart';
import 'package:speech_to_text_test/utils/text_util.dart';

import 'api/speech_to_text_api.dart';
import 'api/speech_to_text_listeners.dart';

class SpeecghToTextPage extends StatefulWidget {
  @override
  _SpeecghToTextPageState createState() => _SpeecghToTextPageState();
}

class _SpeecghToTextPageState extends State<SpeecghToTextPage>
    with SingleTickerProviderStateMixin
    implements SpeechToTextListeners {
  int resultListened = 0;

  double level = 0.0;
  double minSoundLevel = 50000;
  double maxSoundLevel = -50000;

  String lastStatus = '';
  String lastWords = '';
  String lastError = '';

  SpeechToTextAPI speechToTextAPI;

  AnimationController _animationController;
  Animation<Color> _animateColor;
  Curve _curve = Curves.easeOut;

  void startListening() {
    lastWords = '';
    lastError = '';

    if (!speechToTextAPI.hasSpeech) {
      showSnackBar('Already listening or Doesn\'t support this feature');
    } else {
      speechToTextAPI.startListening().then(
        (value) {
          showSnackBar('Trying to listen...');
        },
      );
    }
  }

  void stopListening() {
    speechToTextAPI.stopListening().then(
      (value) {
        showSnackBar('Stopped listening');
      },
    );
  }

  void cancelListening() {
    speechToTextAPI.cancelListening().then(
          (value) => showSnackBar('Cancelled listening'),
        );
  }

  @override
  void initState() {
    super.initState();

    _animationController =
        AnimationController(vsync: this, duration: Duration(milliseconds: 1))
          ..addListener(() {
            setState(() {});
          });

    _animateColor = ColorTween(
      begin: Colors.blue,
      end: Colors.red,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Interval(
        0.00,
        1.00,
        curve: _curve,
      ),
    ));

    speechToTextAPI = SpeechToTextAPI(listeners: this);

    speechToTextAPI.init().then((value) {
      if (this.mounted) setState(() {});
    });
  }

  @override
  dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Speech to Text Example'),
        actions: [
          Builder(
            builder: (context) => IconButton(
              icon: Icon(Icons.content_copy),
              onPressed: () async {
                await FlutterClipboard.copy(lastWords);

                showSnackBar('✓   Copied to Clipboard');
              },
            ),
          ),
        ],
      ),
      floatingActionButton: AnimatedContainer(
        duration: Duration(milliseconds: 500),
        width: 60,
        height: 60,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              blurRadius: .26,
              spreadRadius: level * 1.5,
              color: Colors.black.withOpacity(.05),
            ),
          ],
          color: Colors.white,
          borderRadius: BorderRadius.all(Radius.circular(50)),
        ),
        child: FloatingActionButton(
          child: Icon(Icons.mic),
          backgroundColor: _animateColor.value,
          onPressed:
              speechToTextAPI.isListening() ? stopListening : startListening,
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      body: Column(
        children: [
          _localeDropdownWidget(),
          Expanded(
            child: Container(
              color: Theme.of(context).selectedRowColor,
              child: Center(
                child: SubstringHighlight(
                  text: lastWords,
                  terms: Command.all,
                  textStyle: TextStyle(
                    fontSize: 32.0,
                    color: Colors.black,
                    fontWeight: FontWeight.w400,
                  ),
                  textStyleHighlight: TextStyle(
                    fontSize: 32.0,
                    color: Colors.red,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _localeDropdownWidget() {
    return Container(
      child: Column(
        children: <Widget>[
          Container(
            padding: EdgeInsets.symmetric(horizontal: 16),
            width: double.infinity,
            child: DropdownButton(
              isExpanded: true,
              onChanged: (selectedVal) => _switchLang(selectedVal),
              value: speechToTextAPI.currentLocaleId,
              items: speechToTextAPI.localeNames
                  .map(
                    (localeName) => DropdownMenuItem(
                      value: localeName.localeId,
                      child: Text(localeName.name),
                    ),
                  )
                  .toList(),
            ),
          ),
        ],
      ),
    );
  }

  void showSnackBar(String msg) {
    final snackBar = SnackBar(content: Text('$msg'));
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  @override
  void errorListener(SpeechRecognitionError error) {
    lastError = '${error.errorMsg} - ${error.permanent}';

    showSnackBar(lastError);
  }

  @override
  void resultListener(SpeechRecognitionResult result) {
    ++resultListened;
    print('Result listener $resultListened');
    setState(() {
      lastWords = '${result.recognizedWords}';
    });

    Future.delayed(Duration(seconds: 1), () {
      TextUtil.scanText(lastWords);
    });
  }

  @override
  void soundLevelListener(double level) {
    minSoundLevel = min(minSoundLevel, level);
    maxSoundLevel = max(maxSoundLevel, level);
    // print("sound level $level: $minSoundLevel - $maxSoundLevel ");
    setState(() {
      this.level = level;
    });
  }

  @override
  void statusListener(String status) {
    if (speechToTextAPI.isListening()) {
      _animationController.forward();
    } else {
      _animationController.reverse();
    }
    setState(() {
      lastStatus = '$status';
    });
  }

  void _switchLang(selectedVal) {
    setState(() {
      speechToTextAPI.currentLocaleId = selectedVal;
    });
    print(selectedVal);
  }
}
