import 'dart:async';

class CancelableCompleter {
  CancelableCompleter.auto(Duration delay) : _completer = Completer() {
    _timer = Timer(delay, _complete);
  }

  final Completer<bool> _completer;
  Timer? _timer;

  bool _isCompleted = false;
  bool _isCanceled = false;

  Future<bool> get future => _completer.future;

  void cancel() {
    if (!_isCompleted && !_isCanceled) {
      _timer?.cancel();
      _isCanceled = true;
      _completer.complete(false);
    }
  }

  void _complete() {
    if (!_isCompleted && !_isCanceled) {
      _isCompleted = true;
      _completer.complete(true);
    }
  }
}