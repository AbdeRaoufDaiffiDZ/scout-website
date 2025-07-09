import 'package:flutter/material.dart';
import 'package:flutter_svg_provider/flutter_svg_provider.dart';
import 'package:provider/provider.dart';
import 'package:scout/presentation/activityProvider%20.dart';
import 'package:scout/presentation/widgets/activities_section.dart';
import 'package:scout/presentation/widgets/contact_us_section.dart';
import 'package:scout/presentation/widgets/footer_section.dart';
import 'package:scout/presentation/widgets/hero_section.dart';
import 'package:scout/presentation/widgets/mobile_drawer.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final ScrollController _scrollController = ScrollController();
  bool _isMobileMenuOpen = false;

  void _toggleMobileMenu() {
    setState(() {
      _isMobileMenuOpen = !_isMobileMenuOpen;
    });
  }

  void _scrollToSection() {
    if (_isMobileMenuOpen) {
      _toggleMobileMenu(); // Close menu after clicking a link
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // This part of the code was causing issues as GlobalKey().currentContext
      // should only be used to get context of a widget attached to the tree.
      // Removed the problematic scrolling logic. Actual scrolling logic should
      // use a different approach (e.g., using GlobalKeys properly or PageView).
      _scrollController.animateTo(
        400, // Adjust this value based on the actual position of the Activities section
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final localization = Provider.of<LocalizationProvider>(context);

    // Wrap Scaffold with Builder to ensure MaterialLocalizations are available for AppBar
    return Builder(
      builder: (BuildContext innerContext) {
        return Scaffold(
          appBar: AppBar(
            title: Row(
              children: [
                Image(
                  width: 100,
                  height: 100,
                  image: Svg(
                    'https://upload.wikimedia.org/wikipedia/en/6/69/Algerian_Muslim_Scouts.svg',
                    source: SvgSource.network,
                  ),
                ),

                // Image.network(
                //   "https://en.wikipedia.org/wiki/Algerian_Muslim_Scouts#/media/File:Algerian_Muslim_Scouts.svg",
                //   height: 40,
                //   width: 40,
                // ),
                const SizedBox(width: 8),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
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
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            actions: [
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

              // Mobile Menu Button (Hamburger)
            ],
          ),
          endDrawer: MobileDrawer(
            localization: localization,
            onTap: _toggleMobileMenu,
          ),
          body: SingleChildScrollView(
            controller: _scrollController,
            child: Column(
              children: [
                HeroSection(
                  localization: localization,
                  onPressed: _scrollToSection,
                ),
                ActivitiesSection(localization: localization),
                ContactUsSection(localization: localization),
                FooterSection(localization: localization),
              ],
            ),
          ),
        );
      },
    );
  }
}
