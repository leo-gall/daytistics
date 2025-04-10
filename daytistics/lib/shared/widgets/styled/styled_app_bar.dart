import 'package:daytistics/config/settings.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class StyledAppBar extends StatelessWidget implements PreferredSizeWidget {
  final IconButton? shoppingCartOverride;

  const StyledAppBar({super.key, this.shoppingCartOverride});

  @override
  Widget build(BuildContext context) {
    final bool isDashboard = ModalRoute.of(context)?.settings.name == '/';

    return AppBar(
      backgroundColor: ColorSettings.primary,
      leading: isDashboard
          ? IconButton(
              icon: const Icon(
                Icons.menu,
                color: Colors.white,
                size: 30,
              ),
              onPressed: () {
                Scaffold.of(context).openDrawer();
              },
            )
          : null,
      title: SvgPicture.asset(
        'assets/svg/daytistics_mono.svg',
        height: 55,
      ),
      centerTitle: true,
      actions: [
        shoppingCartOverride ??
            IconButton(
              onPressed: () {},
              icon: const Icon(
                Icons.shopping_cart_outlined,
                size: 30,
              ),
            ),
      ],
    );
  }

  @override
  Size get preferredSize =>
      const Size.fromHeight(56.0); // Default app bar height
}
