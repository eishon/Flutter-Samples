import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:speech_to_text_test/ui/sppech_to_text/api/speech_to_text_listeners.dart';

class SpeechToTextAPI {
  SpeechToTextAPI({
    @required this.listeners,
  });
  bool _hasSpeech = false;
  bool get hasSpeech => _hasSpeech;

  final SpeechToTextListeners listeners;

  List<LocaleName> _localeNames = [];
  List<LocaleName> get localeNames => _localeNames;

  String currentLocaleId = '';

  final SpeechToText speech = SpeechToText();

  Future<bool> init() async {
    _hasSpeech = await speech.initialize(
      onError: listeners.errorListener,
      onStatus: listeners.statusListener,
      debugLogging: true,
      finalTimeout: Duration(milliseconds: 0),
    );

    if (hasSpeech) {
      _localeNames = await speech.locales();

      var systemLocale = await speech.systemLocale();
      currentLocaleId = systemLocale.localeId;
    }

    return _hasSpeech;
  }

  bool isListening() {
    return speech.isListening;
  }

  Future<void> startListening() async {
    await speech.listen(
      onResult: listeners.resultListener,
      listenFor: Duration(seconds: 5),
      pauseFor: Duration(seconds: 5),
      partialResults: false,
      localeId: currentLocaleId,
      onSoundLevelChange: listeners.soundLevelListener,
      cancelOnError: true,
      listenMode: ListenMode.confirmation,
    );
  }

  Future<void> stopListening() async {
    await speech.stop();
    listeners.soundLevelListener(0.0);
  }

  Future<void> cancelListening() async {
    await speech.cancel();
    listeners.soundLevelListener(0.0);
  }
}
