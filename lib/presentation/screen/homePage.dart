// ignore_for_file: file_names

import 'package:flutter/material.dart';
import 'package:flutter_svg_provider/flutter_svg_provider.dart';
import 'package:provider/provider.dart';
import 'package:scout/presentation/activityProvider%20.dart';
import 'package:scout/presentation/widgets/activities_section.dart';
import 'package:scout/presentation/widgets/contact_us_section.dart';
import 'package:scout/presentation/widgets/footer_section.dart';
import 'package:scout/presentation/widgets/hero_section.dart';
// Ensure this exists and is correctly implemented

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final ScrollController _scrollController = ScrollController();

  // Define GlobalKeys for each section you want to scroll to
  final GlobalKey _heroSectionKey = GlobalKey();
  final GlobalKey _activitiesSectionKey = GlobalKey();
  final GlobalKey _contactUsSectionKey = GlobalKey();
  final GlobalKey _footerSectionKey = GlobalKey();

  // Function to scroll to a specific section
  void _scrollToSection(GlobalKey key) {
    if (key.currentContext != null) {
      Scrollable.ensureVisible(
        key.currentContext!,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
        alignment: 0.0, // Scroll to the top of the target widget
      );
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final localization = Provider.of<LocalizationProvider>(context);
    final double screenWidth = MediaQuery.of(context).size.width;
    const double breakpoint =
        700.0; // Define your breakpoint for mobile/desktop
    bool isMobile = screenWidth < breakpoint;

    return Scaffold(
      appBar: AppBar(
        backgroundColor:
            Colors.white, // Or a transparent background, adjust as needed
        elevation: 0, // Remove shadow
        toolbarHeight: isMobile ? 150 : 80, // Adjust height as needed
        title: isMobile
            ? Column(
                children: [
                  // Logo
                  if (!isMobile)
                    Image(
                      width: 50, // Smaller logo for AppBar
                      height: 50,
                      image: Svg(
                        'https://upload.wikimedia.org/wikipedia/en/6/69/Algerian_Muslim_Scouts.svg',
                        source: SvgSource.network,
                      ),
                      errorBuilder: (context, error, stackTrace) => const Icon(
                        Icons.error,
                        color: Colors.red,
                      ), // Fallback for SVG
                    ),
                  const SizedBox(width: 8),
                  // Brand Name / Group Name
                  Column(
                    crossAxisAlignment: isMobile
                        ? CrossAxisAlignment.center
                        : CrossAxisAlignment.start,
                    children: [
                      if (isMobile)
                        Image(
                          width: 50, // Smaller logo for AppBar
                          height: 50,
                          image: Svg(
                            'https://upload.wikimedia.org/wikipedia/en/6/69/Algerian_Muslim_Scouts.svg',
                            source: SvgSource.network,
                          ),
                          errorBuilder: (context, error, stackTrace) =>
                              const Icon(
                                Icons.error,
                                color: Colors.red,
                              ), // Fallback for SVG
                        ),
                      const SizedBox(width: 8),
                      // Brand Name / Group Name
                      Text(
                        localization.translate('brandName'),
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.green,
                        ),
                      ),
                      Text(
                        localization.translate('groupName'),
                        style: const TextStyle(
                          fontSize: 14, // Slightly smaller for group name
                          fontWeight: FontWeight.normal,
                          color: Colors.green,
                        ),
                      ),
                    ],
                  ),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      TextButton(
                        onPressed: () {
                          localization.setLocale('en');
                          localization.saveLocale('en');
                        },
                        child: Text(
                          'EN',
                          style: TextStyle(
                            color: localization.locale.languageCode == 'en'
                                ? Colors.green.shade900
                                : Colors.green.shade700,
                            fontWeight: localization.locale.languageCode == 'en'
                                ? FontWeight.bold
                                : FontWeight.normal,
                          ),
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          localization.setLocale('ar');
                          localization.saveLocale('ar');
                        },
                        child: Text(
                          'AR',
                          style: TextStyle(
                            color: localization.locale.languageCode == 'ar'
                                ? Colors.green.shade900
                                : Colors.green.shade700,
                            fontWeight: localization.locale.languageCode == 'ar'
                                ? FontWeight.bold
                                : FontWeight.normal,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              )
            : Row(
                children: [
                  // Logo
                  if (!isMobile)
                    Image(
                      width: 50, // Smaller logo for AppBar
                      height: 50,
                      image: Svg(
                        'https://upload.wikimedia.org/wikipedia/en/6/69/Algerian_Muslim_Scouts.svg',
                        source: SvgSource.network,
                      ),
                      errorBuilder: (context, error, stackTrace) => const Icon(
                        Icons.error,
                        color: Colors.red,
                      ), // Fallback for SVG
                    ),
                  const SizedBox(width: 8),
                  // Brand Name / Group Name
                  Column(
                    crossAxisAlignment: isMobile
                        ? CrossAxisAlignment.center
                        : CrossAxisAlignment.start,
                    children: [
                      if (isMobile)
                        Image(
                          width: 50, // Smaller logo for AppBar
                          height: 50,
                          image: Svg(
                            'https://upload.wikimedia.org/wikipedia/en/6/69/Algerian_Muslim_Scouts.svg',
                            source: SvgSource.network,
                          ),
                          errorBuilder: (context, error, stackTrace) =>
                              const Icon(
                                Icons.error,
                                color: Colors.red,
                              ), // Fallback for SVG
                        ),
                      const SizedBox(width: 8),
                      // Brand Name / Group Name
                      Text(
                        localization.translate('brandName'),
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.green,
                        ),
                      ),
                      Text(
                        localization.translate('groupName'),
                        style: const TextStyle(
                          fontSize: 14, // Slightly smaller for group name
                          fontWeight: FontWeight.normal,
                          color: Colors.green,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
        actions: isMobile
            ? []
            : [
                // Desktop Navigation Links

                // Language Buttons
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: Row(
                    children: [
                      TextButton(
                        onPressed: () {
                          localization.setLocale('en');
                          localization.saveLocale('en');
                        },
                        child: Text(
                          'EN',
                          style: TextStyle(
                            color: localization.locale.languageCode == 'en'
                                ? Colors.green.shade900
                                : Colors.green.shade700,
                            fontWeight: localization.locale.languageCode == 'en'
                                ? FontWeight.bold
                                : FontWeight.normal,
                          ),
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          localization.setLocale('ar');
                          localization.saveLocale('ar');
                        },
                        child: Text(
                          'AR',
                          style: TextStyle(
                            color: localization.locale.languageCode == 'ar'
                                ? Colors.green.shade900
                                : Colors.green.shade700,
                            fontWeight: localization.locale.languageCode == 'ar'
                                ? FontWeight.bold
                                : FontWeight.normal,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],

        // Mobile Menu Button (Hamburger)
      ),

      // Mobile Drawer
      body: SingleChildScrollView(
        controller: _scrollController,
        child: Column(
          children: [
            HeroSection(
              key: _heroSectionKey, // Assign GlobalKey
              localization: localization,
              onPressed: () => _scrollToSection(
                _activitiesSectionKey,
              ), // Scroll to activities from Hero
            ),
            ActivitiesSection(
              key: _activitiesSectionKey, // Assign GlobalKey
              localization: localization,
            ),
            ContactUsSection(
              key: _contactUsSectionKey, // Assign GlobalKey
              localization: localization,
            ),
            FooterSection(
              key: _footerSectionKey, // Assign GlobalKey
              localization: localization,
            ),
          ],
        ),
      ),
    );
  }
}

// Helper Widget for AppBar Text Buttons
