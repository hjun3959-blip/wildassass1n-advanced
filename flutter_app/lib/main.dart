import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'theme/app_theme.dart';
import 'viewmodels/dashboard_viewmodel.dart';
import 'views/connecting_banner.dart';
import 'views/bento_dashboard.dart';
import 'views/talk_view.dart';
import 'views/gateway_settings.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    ChangeNotifierProvider(
      create: (_) => DashboardViewModel(),
      child: const KTFMobileApp(),
    ),
  );
}

class KTFMobileApp extends StatelessWidget {
  const KTFMobileApp({super.key});

  @override
  Widget build(BuildContext context) {
    return CupertinoApp(
      title: 'KTF-Mobile',
      theme: AppTheme.dark,
      home: const MainScreen(),
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});
  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _tab = 0;

  final _pages = const [
    BentoDashboardView(),
    TalkView(),
    GatewaySettingsView(),
  ];

  @override
  Widget build(BuildContext context) {
    return CupertinoTabScaffold(
      tabBar: CupertinoTabBar(
        items: const [
          BottomNavigationBarItem(icon: Icon(CupertinoIcons.square_grid_2x2), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(CupertinoIcons.waveform), label: 'Talk'),
          BottomNavigationBarItem(icon: Icon(CupertinoIcons.gear), label: 'Settings'),
        ],
        activeColor: const Color(0xFFA855F7),
        border: const Border(top: BorderSide(color: Color(0xFF27272A), width: 0.5)),
        backgroundColor: const Color(0xFF18181B),
      ),
      tabBuilder: (context, index) {
        return CupertinoTabView(
          builder: (context) {
            return CupertinoPageScaffold(
              navigationBar: index == 0
                  ? CupertinoNavigationBar(
                      middle: const ConnectingBannerView(),
                      backgroundColor: const Color(0xFF09090B),
                      border: const Border(bottom: BorderSide(color: Color(0xFF27272A))),
                    )
                  : null,
              child: SafeArea(child: _pages[index]),
            );
          },
        );
      },
    );
  }
}