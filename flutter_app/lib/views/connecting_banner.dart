import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/dashboard_viewmodel.dart';
import '../theme/app_theme.dart';

class ConnectingBannerView extends StatefulWidget {
  const ConnectingBannerView({super.key});
  @override
  State<ConnectingBannerView> createState() => _ConnectingBannerViewState();
}

class _ConnectingBannerViewState extends State<ConnectingBannerView>
    with SingleTickerProviderStateMixin {
  late AnimationController _shimmerCtrl;
  late Animation<double> _shimmerAnim;

  @override
  void initState() {
    super.initState();
    _shimmerCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat();
    _shimmerAnim = Tween<double>(begin: -1.0, end: 2.0).animate(
      CurvedAnimation(parent: _shimmerCtrl, curve: Curves.linear),
    );
  }

  @override
  void dispose() {
    _shimmerCtrl.dispose();
    super.dispose();
  }

  Color _statusColor(NodeStatus s) {
    switch (s) {
      case NodeStatus.online: return AppTheme.green;
      case NodeStatus.connecting:
      case NodeStatus.reconnecting: return AppTheme.amber;
      case NodeStatus.dreaming: return AppTheme.purple;
      case NodeStatus.talk: return AppTheme.blue;
      case NodeStatus.offline: return AppTheme.muted;
    }
  }

  String _statusLabel(NodeStatus s) {
    const labels = ['Offline', 'Connecting', 'Reconnecting', 'Online', 'Dreaming', 'Talk'];
    return labels[s.index];
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<DashboardViewModel>(
      builder: (context, vm, _) {
        final status = vm.status;
        final color = _statusColor(status);
        final showShimmer = status == NodeStatus.reconnecting || status == NodeStatus.connecting;

        return Container(
          height: 34,
          decoration: BoxDecoration(
            color: color.withOpacity(0.2),
            borderRadius: BorderRadius.circular(999),
            border: Border.all(color: color.withOpacity(0.4), width: 1),
            boxShadow: status == NodeStatus.online
                ? [BoxShadow(color: AppTheme.green.withOpacity(0.3), blurRadius: 12)]
                : null,
          ),
          clipBehavior: Clip.antiAlias,
          child: Stack(
            children: [
              if (showShimmer)
                AnimatedBuilder(
                  animation: _shimmerAnim,
                  builder: (context, child) {
                    return ShaderMask(
                      shaderCallback: (bounds) {
                        return LinearGradient(
                          colors: [Colors.transparent, Colors.white.withOpacity(0.3), Colors.transparent],
                          stops: [_shimmerAnim.value - 0.3, _shimmerAnim.value, _shimmerAnim.value + 0.3],
                        ).createShader(bounds);
                      },
                      child: Container(color: Colors.white),
                    );
                  },
                ),
              Center(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(width: 8, height: 8, decoration: BoxDecoration(color: Colors.white, shape: BoxShape.circle, boxShadow: [BoxShadow(color: Colors.white.withOpacity(0.5), blurRadius: 4)])),
                    const SizedBox(width: 8),
                    Text(_statusLabel(status), style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600, fontFamily: '.SF Mono')),
                    if (showShimmer) ...[
                      const SizedBox(width: 8),
                      const Icon(CupertinoIcons.arrow_2_circlepath, size: 14, color: Colors.white),
                    ],
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}