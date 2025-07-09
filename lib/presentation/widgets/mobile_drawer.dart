import 'package:flutter/material.dart';
import 'package:flutter_svg_provider/flutter_svg_provider.dart';
import 'package:scout/presentation/activityProvider%20.dart';

class MobileDrawer extends StatelessWidget {
  final LocalizationProvider localization;
  final VoidCallback onTap;

  const MobileDrawer({
    super.key,
    required this.localization,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          DrawerHeader(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.green.shade600, Colors.green.shade800],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Image(
                  width: 70,
                  height: 70,
                  image: Svg(
                    'https://upload.wikimedia.org/wikipedia/en/6/69/Algerian_Muslim_Scouts.svg',
                    source: SvgSource.network,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  localization.translate('brandName'),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  localization.translate('groupName'),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          ListTile(
            title: Text(localization.translate('navHome')),
            onTap: () {
              Navigator.pop(context); // Close the drawer
              onTap();
            },
          ),
          ListTile(
            title: Text(localization.translate('navActivities')),
            onTap: () {
              Navigator.pop(context);
              onTap();
            },
          ),
          ListTile(
            title: Text(localization.translate('navContact')),
            onTap: () {
              Navigator.pop(context);
              onTap();
            },
          ),
        ],
      ),
    );
  }
}
