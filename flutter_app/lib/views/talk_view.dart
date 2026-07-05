import 'dart:math';
import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../viewmodels/dashboard_viewmodel.dart';
import '../theme/app_theme.dart';

class TalkView extends StatefulWidget {
  const TalkView({super.key});
  @override
  State<TalkView> createState() => _TalkViewState();
}

class _TalkViewState extends State<TalkView> with SingleTickerProviderStateMixin {
  final List<double> _amplitudes = List.filled(32, 8.0);
  Timer? _waveTimer;
  bool _speaking = false;

  @override
  void dispose() {
    _waveTimer?.cancel();
    super.dispose();
  }

  void _toggleSpeaking(BuildContext context, DashboardViewModel vm) {
    HapticFeedback.mediumImpact();
    setState(() => _speaking = !_speaking);
    vm.toggleVoice();
    if (_speaking) {
      _waveTimer = Timer.periodic(const Duration(milliseconds: 60), (_) {
        setState(() {
          for (var i = 0; i < _amplitudes.length; i++) {
            _amplitudes[i] = 6 + Random().nextDouble() * 42;
          }
        });
      });
    } else {
      _waveTimer?.cancel();
      setState(() => _amplitudes.fillRange(0, _amplitudes.length, 8.0));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<DashboardViewModel>(
      builder: (context, vm, _) {
        return SingleChildScrollView(
          child: Column(children: [
            const SizedBox(height: 40),
            // Waveform
            SizedBox(
              height: 50,
              child: Row(mainAxisAlignment: MainAxisAlignment.center, children: List.generate(_amplitudes.length, (i) {
                return Container(
                  width: 4, height: _amplitudes[i].clamp(4, 50),
                  margin: const EdgeInsets.symmetric(horizontal: 1.5),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(4),
                    gradient: const LinearGradient(colors: [AppTheme.blue, AppTheme.ocean], begin: Alignment.bottomCenter, end: Alignment.topCenter),
                  ),
                );
              })),
            ),
            const SizedBox(height: 30),
            // Glassmorphic button
            GestureDetector(
              onTap: () => _toggleSpeaking(context, vm),
              child: Container(
                width: 100, height: 100,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _speaking ? AppTheme.blue.withOpacity(0.2) : Colors.white.withOpacity(0.03),
                  border: Border.all(color: _speaking ? AppTheme.blue.withOpacity(0.6) : Colors.white.withOpacity(0.1)),
                  boxShadow: _speaking
                      ? [BoxShadow(color: AppTheme.blue.withOpacity(0.35), blurRadius: 24, spreadRadius: 4)]
                      : null,
                ),
                child: Icon(
                  _speaking ? CupertinoIcons.waveform : CupertinoIcons.mic_fill,
                  size: 36,
                  color: _speaking ? AppTheme.blue : AppTheme.text,
                ),
              ),
            ),
            const SizedBox(height: 20),
            // Toggles
            Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              _ToggleBtn(label: '后台监听', icon: CupertinoIcons.ear, value: vm.isBackgroundListening, onChanged: (_) { HapticFeedback.mediumImpact(); vm.toggleBackground(); }),
              const SizedBox(width: 20),
              _ToggleBtn(label: '扬声器', icon: CupertinoIcons.speaker_wave_2, value: vm.isSpeakerphone, onChanged: (_) { HapticFeedback.mediumImpact(); vm.toggleSpeakerphone(); }),
            ]),
            const SizedBox(height: 20),
            Text(_speaking ? '🎙️ 正在录音...' : '点击圆形按钮开始语音交互',
              style: const TextStyle(fontSize: 11, color: AppTheme.muted)),
          ]),
        );
      },
    );
  }
}

class _ToggleBtn extends StatelessWidget {
  final String label; final IconData icon; final bool value; final ValueChanged<bool> onChanged;
  const _ToggleBtn({required this.label, required this.icon, required this.value, required this.onChanged});
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onChanged(!value),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.3),
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: AppTheme.border),
        ),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          Icon(icon, size: 16, color: value ? AppTheme.purple : AppTheme.muted),
          const SizedBox(width: 6),
          Text(label, style: TextStyle(fontSize: 11, color: value ? AppTheme.purple : AppTheme.muted)),
        ]),
      ),
    );
  }
}