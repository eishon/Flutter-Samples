import 'package:speech_to_text/speech_recognition_error.dart';
import 'package:speech_to_text/speech_recognition_result.dart';

abstract class SpeechToTextListeners {
  void resultListener(SpeechRecognitionResult result);

  void soundLevelListener(double level);

  void errorListener(SpeechRecognitionError error);

  void statusListener(String status);
}
