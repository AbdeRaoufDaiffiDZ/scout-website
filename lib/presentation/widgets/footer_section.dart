import 'package:flutter/material.dart';
import 'package:scout/presentation/activityProvider%20.dart';
import 'package:url_launcher/url_launcher.dart';

class FooterSection extends StatelessWidget {
  final LocalizationProvider localization;
  const FooterSection({super.key, required this.localization});

  Future<bool> launchExternalUrl(BuildContext context, String url) async {
    final Uri uri = Uri.parse(url);
    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(
          uri,
          mode: LaunchMode.externalApplication, // Opens in external browser app
        );
        return true;
      } else {
        // Fallback for web, if externalApplication mode fails, try platformDefault
        // This is particularly useful for web where externalApplication might open a new tab
        // but platformDefault might try to navigate within the current tab (less common for true external links)
        if (await launchUrl(uri, mode: LaunchMode.platformDefault)) {
          return true;
        } else {
          // ignore: use_build_context_synchronously

          return false;
        }
      }
    } catch (e) {
      // ignore: use_build_context_synchronously

      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 30.0, horizontal: 16.0),
      color: Colors.grey.shade800,
      child: Column(
        children: [
          Text(
            localization.translate('footerCopyright'),
            style: TextStyle(color: Colors.grey.shade300, fontSize: 14),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          IconButton(
            alignment: Alignment.center,
            icon: const Icon(Icons.facebook, color: Colors.white, size: 30),
            onPressed: () {
              launchExternalUrl(context, "https://www.facebook.com/RGBSMA");
            },
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // TextButton(
              //   onPressed: () {},
              //   child: Text(
              //     localization.translate('footerPrivacy'),
              //     style: TextStyle(color: Colors.green.shade400, fontSize: 14),
              //   ),
              // ),
              // Text(
              //   ' | ',
              //   style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
              // ),
              // // TextButton(
              // //   onPressed: () {},
              // //   child: Text(
              // //     localization.translate('footerTerms'),
              // //     style: TextStyle(color: Colors.green.shade400, fontSize: 14),
              // //   ),
              // // ),
            ],
          ),
        ],
      ),
    );
  }
}
