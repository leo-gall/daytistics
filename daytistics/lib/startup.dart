import 'package:daytistics/shared/presets/home_view_preset.dart';
import 'package:daytistics/shared/utils/internet.dart';
import 'package:daytistics/shared/widgets/styled/styled_text.dart';
import 'package:daytistics/ui/dashboard/views/dashboard_view.dart';
import 'package:flutter/material.dart';

class StartupView extends StatefulWidget {
  const StartupView({super.key});
  @override
  State<StartupView> createState() => _StartupViewState();
}

class _StartupViewState extends State<StartupView> {
  bool _isConnected = false;
  bool _checking = true;
  String? _reason;

  @override
  void initState() {
    super.initState();
    _checkInternet();
  }

  void _restartApp() {
    setState(() {
      _checking = true;
    });
    _checkInternet();
  }

  Future<void> _checkInternet() async {
    try {
      final bool connectedToNetwork = await checkNetworkConnection();
      final bool connectedToSupabase = await checkSupabaseConnection();

      if (connectedToNetwork && connectedToSupabase) {
        setState(() {
          _isConnected = true;
          _checking = false;
        });
      } else if (connectedToNetwork && !connectedToSupabase) {
        setState(() {
          _isConnected = false;
          _checking = false;
          _reason =
              'We are currently experiencing issues connecting to our server. Please try again later.';
        });
      } else {
        setState(() {
          _isConnected = false;
          _checking = false;
          _reason = 'Please check your internet connection and try again.';
        });
      }
    } on Exception catch (_) {
      setState(() {
        _isConnected = false;
        _checking = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_checking) {
      return const HomeViewPreset(
        child: Center(child: CircularProgressIndicator()),
      );
    }

    return _isConnected
        ? const DashboardView() // Load your actual home screen
        : HomeViewPreset(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    StyledText(
                      _reason ?? 'An error occurred.',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 20),
                    TextButton(
                      onPressed: _restartApp,
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.refresh, color: Colors.white),
                          SizedBox(width: 5),
                          StyledText('Retry'),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
  }
}
