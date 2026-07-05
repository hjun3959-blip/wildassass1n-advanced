import 'dart:async';
import 'package:flutter/foundation.dart';

enum NodeStatus { offline, connecting, reconnecting, online, dreaming, talk }

class DashboardViewModel extends ChangeNotifier {
  NodeStatus _status = NodeStatus.offline;
  NodeStatus get status => _status;

  bool _isVoiceActive = false;
  bool get isVoiceActive => _isVoiceActive;

  bool _isBackgroundListening = false;
  bool get isBackgroundListening => _isBackgroundListening;

  bool _isSpeakerphone = false;
  bool get isSpeakerphone => _isSpeakerphone;

  bool _isDreaming = false;
  bool get isDreaming => _isDreaming;

  List<double> _chartData = [];
  List<double> get chartData => _chartData;

  List<String> _recentActivities = [];
  List<String> get recentActivities => _recentActivities;

  int _pendingSkills = 3;
  int get pendingSkills => _pendingSkills;

  List<(String, bool)> _agents = [];
  List<(String, bool)> get agents => _agents;

  Timer? _chartTimer;

  DashboardViewModel() {
    _chartData = List.generate(20, (_) => (DateTime.now().millisecondsSinceEpoch % 90 + 10).toDouble());
    _recentActivities = ['Jailbreak scan completed', 'Port scan: 4 open ports', 'Agent handoff ready'];
    _agents = [('Recon', true), ('Scan', true), ('Exploit', false), ('Report', true)];
    _startChartUpdates();
  }

  void _startChartUpdates() {
    _chartTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      _chartData.add((DateTime.now().millisecondsSinceEpoch % 90 + 10).toDouble());
      if (_chartData.length > 30) _chartData.removeAt(0);
      notifyListeners();
    });
  }

  @override
  void dispose() {
    _chartTimer?.cancel();
    super.dispose();
  }

  void connect() {
    _status = NodeStatus.connecting;
    notifyListeners();
    Future.delayed(const Duration(milliseconds: 1500), () {
      _status = NodeStatus.online;
      notifyListeners();
    });
  }

  void reconnect() {
    _status = NodeStatus.reconnecting;
    notifyListeners();
    Future.delayed(const Duration(milliseconds: 2000), () {
      _status = NodeStatus.online;
      notifyListeners();
    });
  }

  void disconnect() {
    _status = NodeStatus.offline;
    _isVoiceActive = false;
    notifyListeners();
  }

  void toggleVoice() {
    _isVoiceActive = !_isVoiceActive;
    notifyListeners();
  }

  void toggleBackground() {
    _isBackgroundListening = !_isBackgroundListening;
    notifyListeners();
  }

  void toggleSpeakerphone() {
    _isSpeakerphone = !_isSpeakerphone;
    notifyListeners();
  }

  void connectManual(String host, String port, bool tls) {
    debugPrint('[KTF] ${tls ? "wss" : "ws"}://$host:$port');
    connect();
  }

  void scanQR() => debugPrint('[KTF] QR scan');
}