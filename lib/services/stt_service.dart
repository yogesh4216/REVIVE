import 'package:speech_to_text/speech_to_text.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:async';

class SttService {
  final SpeechToText _speechToText = SpeechToText();
  bool _isInitialized = false;
  bool _continuousMode = false;
  Function(String)? _onResultCallback;
  Timer? _restartTimer;

  Future<bool> initialize() async {
    if (_isInitialized) return true;

    var status = await Permission.microphone.request();
    if (status != PermissionStatus.granted) {
      return false;
    }

    _isInitialized = await _speechToText.initialize(
      onError: (val) {
        print('STT Error: ${val.errorMsg} - ${val.permanent}');
        if (_continuousMode) _scheduleRestart();
      },
      onStatus: (val) {
        print('STT Status: $val');
        if (val == 'done' || val == 'notListening') {
          if (_continuousMode) {
            _scheduleRestart();
          }
        }
      },
    );
    return _isInitialized;
  }

  void _scheduleRestart() {
    _restartTimer?.cancel();
    _restartTimer = Timer(const Duration(milliseconds: 1000), () {
      if (_continuousMode) {
        _startListeningInternal();
      }
    });
  }

  bool get isListening => _speechToText.isListening;

  Future<void> startContinuousListening({required Function(String) onResult}) async {
    if (!_isInitialized) await initialize();
    if (!_isInitialized) return;

    _continuousMode = true;
    _onResultCallback = onResult;
    _startListeningInternal();
  }

  Future<void> startListening({required Function(String) onResult}) async {
    if (!_isInitialized) await initialize();
    if (!_isInitialized) return;

    _continuousMode = false;
    _onResultCallback = onResult;
    _startListeningInternal();
  }
  void _startListeningInternal() {
    if (!_isInitialized || _speechToText.isListening) return;

    _speechToText.listen(
      onResult: (result) {
        if (result.recognizedWords.isNotEmpty) {
          // If it's a final result OR if it's a long enough phrase and we are in continuous mode
          if (result.finalResult) {
            _onResultCallback?.call(result.recognizedWords);
          }
        }
      },
      listenFor: const Duration(seconds: 60),
      pauseFor: const Duration(seconds: 3), // Faster timeout for quicker response
      listenMode: ListenMode.deviceDefault, // Use default for better noise handling
      cancelOnError: false,
      partialResults: true, // Let us see words immediately
    );
  }

  Future<void> pauseListening() async {
    _restartTimer?.cancel();
    await _speechToText.stop();
  }

  Future<void> resumeListening() async {
    if (_continuousMode && _onResultCallback != null) {
      _startListeningInternal();
    }
  }

  Future<void> stopListening() async {
    _continuousMode = false;
    _restartTimer?.cancel();
    _onResultCallback = null;
    await _speechToText.stop();
  }
}
