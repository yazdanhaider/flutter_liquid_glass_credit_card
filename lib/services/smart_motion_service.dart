import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:sensors_plus/sensors_plus.dart';

class SmartMotionService extends ChangeNotifier {
  static final SmartMotionService _instance = SmartMotionService._internal();
  factory SmartMotionService() => _instance;
  SmartMotionService._internal();

  StreamSubscription<AccelerometerEvent>? _accelerometerSubscription;
  StreamSubscription<GyroscopeEvent>? _gyroscopeSubscription;

  bool _isActive = false;
  bool _isCardFocused = false;
  bool _isUserTyping = false;

  double _currentTiltX = 0.0;
  double _currentTiltY = 0.0;
  double _smoothTiltX = 0.0;
  double _smoothTiltY = 0.0;

  final double _sensitivity = 0.15;
  final double _maxTilt = 25.0;
  final double _deadZone = 3.0;

  Timer? _smoothingTimer;
  DateTime _lastUpdate = DateTime.now();

  double get tiltX => _smoothTiltX;
  double get tiltY => _smoothTiltY;
  bool get isActive => _isActive && _isCardFocused && !_isUserTyping;

  void startListening() {
    if (_isActive) return;

    _isActive = true;
    _initializeSensors();
    _startSmoothingTimer();
  }

  void stopListening() {
    _isActive = false;
    _accelerometerSubscription?.cancel();
    _gyroscopeSubscription?.cancel();
    _smoothingTimer?.cancel();

    _resetToNeutral();
  }

  void setCardFocused(bool focused) {
    _isCardFocused = focused;
    if (!focused) _resetToNeutral();
    notifyListeners();
  }

  void setUserTyping(bool typing) {
    _isUserTyping = typing;
    if (typing) _resetToNeutral();
    notifyListeners();
  }

  void _initializeSensors() {
    _accelerometerSubscription = accelerometerEventStream(
      samplingPeriod: const Duration(milliseconds: 33), // ~30Hz
    ).listen(_handleAccelerometerData);
  }

  void _handleAccelerometerData(AccelerometerEvent event) {
    if (!isActive) return;

    final now = DateTime.now();
    if (now.difference(_lastUpdate).inMilliseconds < 16) return; // ~60fps max
    _lastUpdate = now;

    double rawTiltX = _calculateTiltX(event.x, event.y, event.z);
    double rawTiltY = _calculateTiltY(event.x, event.y, event.z);

    rawTiltX = _applyDeadZone(rawTiltX);
    rawTiltY = _applyDeadZone(rawTiltY);

    rawTiltX = _clampTilt(rawTiltX);
    rawTiltY = _clampTilt(rawTiltY);

    if (_isIntentionalMovement(rawTiltX, rawTiltY)) {
      _currentTiltX = rawTiltX;
      _currentTiltY = rawTiltY;
    }
  }

  double _calculateTiltX(double x, double y, double z) {
    return atan2(x, sqrt(y * y + z * z)) * (180 / pi);
  }

  double _calculateTiltY(double x, double y, double z) {
    return atan2(y, sqrt(x * x + z * z)) * (180 / pi);
  }

  double _applyDeadZone(double tilt) {
    if (tilt.abs() < _deadZone) return 0.0;
    return tilt > 0 ? tilt - _deadZone : tilt + _deadZone;
  }

  double _clampTilt(double tilt) {
    return tilt.clamp(-_maxTilt, _maxTilt);
  }

  bool _isIntentionalMovement(double newTiltX, double newTiltY) {
    double deltaX = (newTiltX - _currentTiltX).abs();
    double deltaY = (newTiltY - _currentTiltY).abs();

    return deltaX > 1.0 || deltaY > 1.0;
  }

  void _startSmoothingTimer() {
    _smoothingTimer = Timer.periodic(
      const Duration(milliseconds: 16), // ~60fps
      (_) => _updateSmoothValues(),
    );
  }

  void _updateSmoothValues() {
    if (!isActive) {
      _smoothToNeutral();
      return;
    }

    _smoothTiltX = _lerp(_smoothTiltX, _currentTiltX, _sensitivity);
    _smoothTiltY = _lerp(_smoothTiltY, _currentTiltY, _sensitivity);

    if (_hasValueChanged()) {
      notifyListeners();
    }
  }

  void _smoothToNeutral() {
    _smoothTiltX = _lerp(_smoothTiltX, 0.0, _sensitivity * 1.5);
    _smoothTiltY = _lerp(_smoothTiltY, 0.0, _sensitivity * 1.5);

    if (_smoothTiltX.abs() > 0.1 || _smoothTiltY.abs() > 0.1) {
      notifyListeners();
    } else {
      _smoothTiltX = 0.0;
      _smoothTiltY = 0.0;
    }
  }

  double _lerp(double start, double end, double factor) {
    return start + (end - start) * factor;
  }

  double _lastNotifiedX = 0.0;
  double _lastNotifiedY = 0.0;

  bool _hasValueChanged() {
    bool changed =
        (_smoothTiltX - _lastNotifiedX).abs() > 0.1 ||
        (_smoothTiltY - _lastNotifiedY).abs() > 0.1;

    if (changed) {
      _lastNotifiedX = _smoothTiltX;
      _lastNotifiedY = _smoothTiltY;
    }

    return changed;
  }

  void _resetToNeutral() {
    _currentTiltX = 0.0;
    _currentTiltY = 0.0;
  }

  @override
  void dispose() {
    stopListening();
    super.dispose();
  }
}
