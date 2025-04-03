import 'package:daytistics/shared/widgets/styled/styled_app_bar.dart';
import 'package:daytistics/shared/widgets/styled/styled_scaffold_drawer.dart';
import 'package:flutter/material.dart';

class StyledScaffold extends StatelessWidget {
  final Widget body;

  const StyledScaffold({super.key, required this.body});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: const StyledAppBar(),
      body: body,
      drawer: const StyledScaffoldDrawer(),
    );
  }
}
