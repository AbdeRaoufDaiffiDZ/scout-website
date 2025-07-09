// lib/presentation/widgets/mobile_drawer.dart
import 'package:flutter/material.dart';
import 'package:scout/presentation/activityProvider%20.dart';

class MobileDrawer extends StatelessWidget {
  final LocalizationProvider localization;
  // Change onTap to specific scroll callbacks
  final VoidCallback scrollToHero;
  final VoidCallback scrollToActivities;
  final VoidCallback scrollToContact;
  final VoidCallback scrollToFooter;

  const MobileDrawer({
    super.key,
    required this.localization,
    required this.scrollToHero,
    required this.scrollToActivities,
    required this.scrollToContact,
    required this.scrollToFooter,
  });

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          DrawerHeader(
            decoration: BoxDecoration(color: Colors.green.shade700),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // You can add your logo here if desired
                // Image.asset('assets/logo.png', height: 60),
                Text(
                  localization.translate('brandName'),
                  style: const TextStyle(color: Colors.white, fontSize: 24),
                ),
                Text(
                  localization.translate('groupName'),
                  style: const TextStyle(color: Colors.white70, fontSize: 16),
                ),
              ],
            ),
          ),
          ListTile(
            leading: const Icon(Icons.home),
            title: Text(localization.translate('home')),
            onTap: scrollToHero,
          ),
          ListTile(
            leading: const Icon(Icons.local_activity),
            title: Text(localization.translate('activitiesHeadline')),
            onTap: scrollToActivities,
          ),
          ListTile(
            leading: const Icon(Icons.contact_mail),
            title: Text(localization.translate('contactHeadline')),
            onTap: scrollToContact,
          ),
          ListTile(
            leading: const Icon(
              Icons.info,
            ), // Or a more relevant icon for footer
            title: Text(localization.translate('footerHeadline')),
            onTap: scrollToFooter,
          ),
          const Divider(), // Divider for language options
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 8.0,
            ),
            child: Text(
              localization.translate(
                'language',
              ), // Assuming 'language' translation
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade700,
              ),
            ),
          ),
          ListTile(
            title: Text(
              'English',
              style: TextStyle(
                color: localization.locale.languageCode == 'en'
                    ? Colors.green.shade900
                    : Colors.black87,
                fontWeight: localization.locale.languageCode == 'en'
                    ? FontWeight.bold
                    : FontWeight.normal,
              ),
            ),
            onTap: () {
              localization.setLocale('en');
              localization.saveLocale('en');
              Navigator.of(context).pop(); // Close drawer
            },
          ),
          ListTile(
            title: Text(
              'العربية',
              style: TextStyle(
                color: localization.locale.languageCode == 'ar'
                    ? Colors.green.shade900
                    : Colors.black87,
                fontWeight: localization.locale.languageCode == 'ar'
                    ? FontWeight.bold
                    : FontWeight.normal,
              ),
            ),
            onTap: () {
              localization.setLocale('ar');
              localization.saveLocale('ar');
              Navigator.of(context).pop(); // Close drawer
            },
          ),
        ],
      ),
    );
  }
}
