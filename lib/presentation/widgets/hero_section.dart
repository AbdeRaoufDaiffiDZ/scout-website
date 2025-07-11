// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:scout/main.dart';
import 'package:scout/presentation/activityProvider%20.dart';

class HeroSection extends StatelessWidget {
  final void Function() onPressed;
  final LocalizationProvider localization;
  const HeroSection({
    super.key,
    required this.localization,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 80.0, horizontal: 16.0),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.green.shade600,
            const Color.fromARGB(255, 11, 104, 15),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              localization.translate('heroHeadline'),
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 36,
                fontWeight: FontWeight.bold,
                height: 1.2,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              localization.translate('heroText'),
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white.withOpacity(0.9),
                fontSize: 18,
              ),
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: onPressed,
              // () {
              //   // Scroll to activities section (implementation via ScrollController in HomePage)
              // },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 30,
                  vertical: 15,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                shadowColor: Colors.black.withOpacity(0.2),
                elevation: 5,
              ),
              child: Text(
                localization.translate('heroButton'),
                style: TextStyle(
                  color: Colors.green.shade700,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const MyApp()),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 30,
                  vertical: 15,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                shadowColor: Colors.black.withOpacity(0.2),
                elevation: 5,
              ),
              child: Text(
                localization.translate('loginButton'),
                style: TextStyle(
                  color: Colors.green.shade700,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
