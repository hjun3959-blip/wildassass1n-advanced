import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/dashboard_viewmodel.dart';
import '../theme/app_theme.dart';

class BentoDashboardView extends StatelessWidget {
  const BentoDashboardView({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<DashboardViewModel>(
      builder: (context, vm, _) {
        return CupertinoScrollbar(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(spacing: 10, children: [
              Row(children: [
                Expanded(child: _OverviewCard(data: vm.chartData)),
              ]),
              Row(children: [
                Expanded(child: _ActivityCard(activities: vm.recentActivities)),
                const SizedBox(width: 10),
                Expanded(child: _SkillWorkshopCard(pending: vm.pendingSkills)),
              ]),
              Row(children: [
                Expanded(child: _DreamingCard(isDreaming: vm.isDreaming)),
                const SizedBox(width: 10),
                Expanded(child: _AgentStatusCard(agents: vm.agents)),
              ]),
            ]),
          ),
        );
      },
    );
  }
}

class _Card extends StatelessWidget {
  final Widget child;
  const _Card({required this.child});
  @override
  Widget build(BuildContext context) => Container(padding: const EdgeInsets.all(14), decoration: AppTheme.cardStyle, child: child);
}

class _OverviewCard extends StatelessWidget {
  final List<double> data;
  const _OverviewCard({required this.data});
  @override
  Widget build(BuildContext context) {
    return _Card(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text('OVERVIEW', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: AppTheme.muted, letterSpacing: 1)),
      const SizedBox(height: 8),
      SizedBox(height: 60, child: CustomPaint(painter: _ChartPainter(data, AppTheme.purple, AppTheme.indigo))),
    ]));
  }
}

class _ChartPainter extends CustomPainter {
  final List<double> data; final Color c1; final Color c2;
  _ChartPainter(this.data, this.c1, this.c2);
  @override
  void paint(Canvas canvas, Size size) {
    if (data.isEmpty) return;
    final paint = Paint()
      ..shader = LinearGradient(colors: [c1, c2]).createShader(Rect.fromLTWH(0, 0, size.width, size.height))
      ..style = PaintingStyle.stroke..strokeWidth = 2..strokeCap = StrokeCap.round..strokeJoin = StrokeJoin.round;
    final path = Path();
    final dx = size.width / (data.length - 1);
    final min = data.reduce((a,b) => a<b?a:b);
    final max = data.reduce((a,b) => a>b?a:b);
    final range = (max - min).clamp(1.0, double.infinity);
    for (var i = 0; i < data.length; i++) {
      final x = i * dx;
      final y = size.height - ((data[i] - min) / range) * size.height * 0.8 - size.height * 0.1;
      i == 0 ? path.moveTo(x, y) : path.lineTo(x, y);
    }
    canvas.drawPath(path, paint);
    if (data.isNotEmpty) {
      final last = data.last;
      final ly = size.height - ((last - min) / range) * size.height * 0.8 - size.height * 0.1;
      canvas.drawCircle(Offset((data.length - 1) * dx, ly), 4, Paint()..color = AppTheme.indigo);
    }
  }
  @override bool shouldRepaint(covariant _ChartPainter o) => data != o.data;
}

class _ActivityCard extends StatelessWidget {
  final List<String> activities;
  const _ActivityCard({required this.activities});
  @override
  Widget build(BuildContext context) {
    return _Card(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text('ACTIVITY', style: TextStyle(fontSize: 9, fontWeight: FontWeight.w600, color: AppTheme.muted)),
      const SizedBox(height: 6),
      ...activities.take(3).map((a) => Padding(padding: const EdgeInsets.only(bottom: 4), child: Row(children: [
        Container(width: 5, height: 5, decoration: const BoxDecoration(color: AppTheme.green, shape: BoxShape.circle)),
        const SizedBox(width: 6),
        Flexible(child: Text(a, style: const TextStyle(fontSize: 10, color: AppTheme.text), overflow: TextOverflow.ellipsis)),
      ]))),
    ]));
  }
}

class _SkillWorkshopCard extends StatelessWidget {
  final int pending;
  const _SkillWorkshopCard({required this.pending});
  @override
  Widget build(BuildContext context) {
    return _Card(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [
        Text('SKILLS', style: TextStyle(fontSize: 9, fontWeight: FontWeight.w600, color: AppTheme.muted)),
        const Spacer(),
        if (pending > 0) Container(padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
          decoration: BoxDecoration(color: AppTheme.red, borderRadius: BorderRadius.circular(999)),
          child: Text('$pending', style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.white))),
      ]),
      const SizedBox(height: 4),
      const Text('Workshop', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppTheme.text)),
    ]));
  }
}

class _DreamingCard extends StatefulWidget {
  final bool isDreaming;
  const _DreamingCard({required this.isDreaming});
  @override
  State<_DreamingCard> createState() => _DreamingCardState();
}

class _DreamingCardState extends State<_DreamingCard> with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  @override
  void initState() { super.initState(); _ctrl = AnimationController(vsync: this, duration: const Duration(seconds: 3))..repeat(); }
  @override void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return _Card(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [
        Text('MEMORY', style: TextStyle(fontSize: 9, fontWeight: FontWeight.w600, color: AppTheme.muted)),
        const Spacer(),
        if (widget.isDreaming) Container(width: 8, height: 8,
          decoration: BoxDecoration(color: AppTheme.purple, shape: BoxShape.circle, boxShadow: [BoxShadow(color: AppTheme.purple.withOpacity(0.6), blurRadius: 8)])),
      ]),
      Text(widget.isDreaming ? 'Dreaming...' : 'Idle',
        style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: widget.isDreaming ? AppTheme.indigo : AppTheme.muted)),
      if (widget.isDreaming) SizedBox(height: 40, child: AnimatedBuilder(animation: _ctrl, builder: (context, _) {
        return CustomPaint(painter: _ParticlePainter(_ctrl.value * 2 * 3.14159));
      })),
    ]));
  }
}

class _ParticlePainter extends CustomPainter {
  final double t; _ParticlePainter(this.t);
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = AppTheme.purple.withOpacity(0.15);
    for (var i = 0; i < 6; i++) {
      final x = (sin(t + i * 1.3) * 0.45 + 0.5) * size.width;
      final y = (cos(t * 0.7 + i * 0.9) * 0.45 + 0.5) * size.height;
      canvas.drawCircle(Offset(x, y), 3, paint);
    }
  }
  @override bool shouldRepaint(covariant CustomPainter o) => true;
}

class _AgentStatusCard extends StatelessWidget {
  final List<(String, bool)> agents;
  const _AgentStatusCard({required this.agents});
  @override
  Widget build(BuildContext context) {
    return _Card(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text('AGENTS', style: TextStyle(fontSize: 9, fontWeight: FontWeight.w600, color: AppTheme.muted)),
      const SizedBox(height: 8),
      Row(children: agents.take(4).map((a) {
        final (name, online) = a;
        return Expanded(child: Column(children: [
          Container(width: 8, height: 8,
            decoration: BoxDecoration(color: online ? AppTheme.green : AppTheme.muted, shape: BoxShape.circle,
              boxShadow: online ? [BoxShadow(color: AppTheme.green.withOpacity(0.4), blurRadius: 6)] : null)),
          const SizedBox(height: 4),
          Text(name, style: const TextStyle(fontSize: 9, color: AppTheme.muted)),
        ]));
      }).toList()),
    ]));
  }
}