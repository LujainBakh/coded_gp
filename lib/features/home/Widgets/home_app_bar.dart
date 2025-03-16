import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:coded_gp/features/profile/views/screens/profile_screen.dart';

class HomeAppBar extends StatelessWidget implements PreferredSizeWidget {
  final VoidCallback? onMenuTap;

  const HomeAppBar({super.key, this.onMenuTap});

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    // ignore: unused_local_variable
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return AppBar(
      backgroundColor: Theme.of(context).cardColor,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: true,
      title: Container(
        padding: EdgeInsets.zero,
        decoration: const BoxDecoration(
          color: Colors.transparent,
        ),
        child: Image.asset(
          'assets/images/CodedLogo1.png',
          height: 40,
          fit: BoxFit.contain,
          filterQuality: FilterQuality.high,
        ),
      ),
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 8.0),
          child: GestureDetector(
            onTap: () {
              print('Profile tap detected');
              Get.to(() => const ProfileScreen());
            },
            child: CircleAvatar(
              radius: 18,
              backgroundImage: const AssetImage('assets/images/profile.png'),
            ),
          ),
        ),
      ],
      leading: IconButton(
        icon: const Icon(Icons.menu),
        onPressed: onMenuTap ??
            () {
              Scaffold.of(context).openDrawer();
            },
      ),
    );
  }
}
