import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../viewmodels/dashboard_viewmodel.dart';
import '../theme/app_theme.dart';

class GatewaySettingsView extends StatefulWidget {
  const GatewaySettingsView({super.key});
  @override
  State<GatewaySettingsView> createState() => _GatewaySettingsViewState();
}

class _GatewaySettingsViewState extends State<GatewaySettingsView> with SingleTickerProviderStateMixin {
  bool _manual = false;
  bool _tls = false;
  final _hostCtrl = TextEditingController(text: '127.0.0.1');
  final _portCtrl = TextEditingController(text: '18789');
  final _tokenCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  late AnimationController _animCtrl;
  late Animation<double> _slideAnim;

  @override
  void initState() {
    super.initState();
    _animCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 350));
    _slideAnim = CurvedAnimation(parent: _animCtrl, curve: Curves.easeOut);
  }

  @override
  void dispose() {
    _hostCtrl.dispose(); _portCtrl.dispose(); _tokenCtrl.dispose(); _passCtrl.dispose();
    _animCtrl.dispose();
    super.dispose();
  }

  void _toggleManual(bool v) {
    setState(() => _manual = v);
    if (v) { _animCtrl.forward(); } else { _animCtrl.reverse(); }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<DashboardViewModel>(
      builder: (context, vm, _) {
        return CupertinoScrollbar(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Padding(
                padding: const EdgeInsets.only(bottom: 14),
                child: Text('GATEWAY', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: AppTheme.muted, letterSpacing: 1)),
              ),
              Container(
                decoration: AppTheme.cardStyle,
                child: Column(children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                      const Text('Use Manual Gateway', style: TextStyle(fontSize: 13, color: AppTheme.text)),
                      CupertinoSwitch(value: _manual, activeColor: AppTheme.purple, onChanged: _toggleManual),
                    ]),
                  ),
                  SizeTransition(
                    sizeFactor: _slideAnim,
                    axisAlignment: -1,
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        _GwField(label: 'Host', ctrl: _hostCtrl),
                        _GwField(label: 'Port', ctrl: _portCtrl),
                        _GwField(label: 'Auth Token', ctrl: _tokenCtrl, obscure: true),
                        _GwField(label: 'Password', ctrl: _passCtrl, obscure: true),
                        const SizedBox(height: 8),
                        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                          const Text('Use TLS', style: TextStyle(fontSize: 12, color: AppTheme.muted)),
                          CupertinoSwitch(value: _tls, activeColor: AppTheme.purple, onChanged: (v) => setState(() => _tls = v)),
                        ]),
                        const SizedBox(height: 12),
                        Row(children: [
                          Expanded(child: _ActionBtn(label: '📷 Scan QR', bg: AppTheme.card, fg: AppTheme.text, onTap: () { HapticFeedback.mediumImpact(); vm.scanQR(); })),
                          const SizedBox(width: 10),
                          Expanded(child: _ActionBtn(label: '🔌 Connect', bg: AppTheme.purple, fg: Colors.white,
                            onTap: () { HapticFeedback.mediumImpact(); vm.connectManual(_hostCtrl.text, _portCtrl.text, _tls); },
                            disabled: !_manual)),
                        ]),
                      ]),
                    ),
                  ),
                ]),
              ),
            ]),
          ),
        );
      },
    );
  }
}

class _GwField extends StatelessWidget {
  final String label; final TextEditingController ctrl; final bool obscure;
  const _GwField({required this.label, required this.ctrl, this.obscure = false});
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(label, style: const TextStyle(fontSize: 10, color: AppTheme.muted)),
        const SizedBox(height: 4),
        Container(
          decoration: BoxDecoration(
            color: const Color(0xFF09090B),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: AppTheme.border),
          ),
          child: CupertinoTextField(
            controller: ctrl, obscureText: obscure,
            style: const TextStyle(fontSize: 13, fontFamily: '.SF Mono', color: AppTheme.text),
            padding: const EdgeInsets.all(10),
            decoration: const BoxDecoration(),
          ),
        ),
      ]),
    );
  }
}

class _ActionBtn extends StatelessWidget {
  final String label; final Color bg; final Color fg; final VoidCallback onTap; final bool disabled;
  const _ActionBtn({required this.label, required this.bg, required this.fg, required this.onTap, this.disabled = false});
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: disabled ? null : onTap,
      child: AnimatedOpacity(
        opacity: disabled ? 0.4 : 1.0,
        duration: const Duration(milliseconds: 200),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppTheme.border),
          ),
          child: Text(label, textAlign: TextAlign.center, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: fg)),
        ),
      ),
    );
  }
}