import 'package:daytistics/config/settings.dart';
import 'package:daytistics/shared/widgets/styled/styled_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class HomeViewPreset extends StatelessWidget {
  final Widget child;

  const HomeViewPreset({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.maxFinite,
        height: double.maxFinite,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: <Color>[ColorSettings.secondary, ColorSettings.primary],
            transform: GradientRotation(-0.6),
          ),
        ),
        child: Column(
          children: <Widget>[
            const SizedBox(height: 80),
            SvgPicture.asset(
              'assets/svg/daytistics_mono.svg',
              width: 130,
              height: 130,
            ),
            const StyledText(
              // Removed Expanded
              'Daytistics',
              style: TextStyle(
                color: Colors.white,
                fontSize: 40,
                fontWeight: FontWeight.bold,
              ),
            ),
            Expanded(child: child), // Wrap child with Expanded
            const SizedBox(height: 50),
          ],
        ),
      ),
    );
  }
}
