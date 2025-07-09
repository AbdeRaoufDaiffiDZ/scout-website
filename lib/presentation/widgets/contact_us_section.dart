import 'package:flutter/material.dart';
import 'package:scout/presentation/activityProvider%20.dart';
import 'package:url_launcher/url_launcher.dart';

class ContactUsSection extends StatefulWidget {
  final LocalizationProvider localization;
  const ContactUsSection({super.key, required this.localization});

  @override
  State<ContactUsSection> createState() => _ContactUsSectionState();
}

class _ContactUsSectionState extends State<ContactUsSection> {
  // Add controllers for the text fields
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _subjectController = TextEditingController();
  final TextEditingController _messageController = TextEditingController();

  // Your existing launchExternalUrl function
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
        if (await launchUrl(uri, mode: LaunchMode.platformDefault)) {
          return true;
        } else {
          // Show SnackBar error feedback
          // ignore: use_build_context_synchronously
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(widget.localization.translate('emailLaunchError')),
            ),
          );
          return false;
        }
      }
    } catch (e) {
      // Show SnackBar error feedback
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            widget.localization.translate('emailLaunchErrorGeneric') + ' $e',
          ),
        ),
      );
      return false;
    }
  }

  // Function to send email
  void _sendEmail() async {
    if (_formKey.currentState!.validate()) {
      final String recipientEmail = 'scoutrgb@gmail.com'; // Your target email
      final String subject = _subjectController.text.trim().isEmpty
          ? widget.localization.translate(
              'defaultEmailSubject',
            ) // Use translation if needed
          : _subjectController.text.trim();
      final String body =
          '${widget.localization.translate('emailBodyFromName')}: ${_nameController.text.trim()}\n'
          '${widget.localization.translate('emailBodyFromEmail')}: ${_emailController.text.trim()}\n\n'
          '${_messageController.text.trim()}';

      // Encode subject and body for URL
      final String encodedSubject = Uri.encodeComponent(subject);
      final String encodedBody = Uri.encodeComponent(body);

      final Uri mailtoUri = Uri.parse(
        'mailto:$recipientEmail?subject=$encodedSubject&body=$encodedBody',
      );

      bool launched = await launchExternalUrl(context, mailtoUri.toString());
      if (launched) {
        // Optionally clear the form or show a success message
        // ignore: use_build_context_synchronously
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(widget.localization.translate('emailSentSuccess')),
          ),
        );
        _nameController.clear();
        _emailController.clear();
        _subjectController.clear();
        _messageController.clear();
      }
      // Error message is handled by launchExternalUrl
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _subjectController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 60.0, horizontal: 16.0),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.green.shade500,
            const Color.fromARGB(255, 10, 133, 16),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Center(
        child: LayoutBuilder(
          builder: (context, constraints) {
            bool isMobile = constraints.maxWidth < 700;
            return Flex(
              direction: isMobile ? Axis.vertical : Axis.horizontal,
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: isMobile ? 0 : 1,
                  child: Padding(
                    padding: EdgeInsets.only(
                      right: isMobile ? 0 : 30,
                      bottom: isMobile ? 40 : 0,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.localization.translate('contactHeadline'),
                          style: const TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                          textAlign:
                              widget.localization.locale.languageCode == 'ar'
                              ? TextAlign.right
                              : TextAlign.left,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          widget.localization.translate('contactText'),
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.white.withOpacity(0.9),
                          ),
                          textAlign:
                              widget.localization.locale.languageCode == 'ar'
                              ? TextAlign.right
                              : TextAlign.left,
                        ),
                        const SizedBox(height: 32),
                        _ContactInfoRow(
                          icon: Icons.email,
                          text: 'scoutrgb@gmail.com',
                          isRTL:
                              widget.localization.locale.languageCode == 'ar',
                          onTap: () => launchExternalUrl(
                            context,
                            'mailto:scoutrgb@gmail.com',
                          ),
                        ),
                        const SizedBox(height: 20),
                        _ContactInfoRow(
                          icon: Icons.phone,
                          text: '+213 697 346 015',
                          isRTL:
                              widget.localization.locale.languageCode == 'ar',
                          onTap: () =>
                              launchExternalUrl(context, 'tel:+213697346015'),
                        ),
                        const SizedBox(height: 20),
                        _ContactInfoRow(
                          icon: Icons.location_on,
                          text: widget.localization.translate('contactAddress'),
                          isRTL:
                              widget.localization.locale.languageCode == 'ar',
                          isAddress: true,
                          // Optional: Add onTap for location (e.g., launch Google Maps)
                          onTap: () => launchExternalUrl(
                            context,
                            'https://www.google.com/maps/search/?api=1&query=${Uri.encodeComponent(widget.localization.translate('contactAddress'))}',
                          ),
                        ),
                        const SizedBox(height: 40),
                      ],
                    ),
                  ),
                ),
                Expanded(
                  flex: isMobile ? 0 : 1,
                  child: Container(
                    padding: const EdgeInsets.all(30),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 10,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Form(
                      // Wrap the form fields with a Form widget
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.localization.translate('formHeadline'),
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                            textAlign:
                                widget.localization.locale.languageCode == 'ar'
                                ? TextAlign.right
                                : TextAlign.left,
                          ),
                          const SizedBox(height: 24),
                          TextFormField(
                            // Use TextFormField for validation
                            controller: _nameController,
                            decoration: InputDecoration(
                              labelText: widget.localization.translate(
                                'formNameLabel',
                              ),
                              hintText: widget.localization.translate(
                                'formNamePlaceholder',
                              ),
                              border: const OutlineInputBorder(
                                borderRadius: BorderRadius.all(
                                  Radius.circular(8),
                                ),
                              ),
                              fillColor: Colors.grey.shade50,
                              filled: true,
                            ),
                            textAlign:
                                widget.localization.locale.languageCode == 'ar'
                                ? TextAlign.right
                                : TextAlign.left,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return widget.localization.translate(
                                  'validationRequired',
                                );
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            // Use TextFormField for validation
                            controller: _emailController,
                            keyboardType: TextInputType.emailAddress,
                            decoration: InputDecoration(
                              labelText: widget.localization.translate(
                                'formEmailLabel',
                              ),
                              hintText: widget.localization.translate(
                                'formEmailPlaceholder',
                              ),
                              border: const OutlineInputBorder(
                                borderRadius: BorderRadius.all(
                                  Radius.circular(8),
                                ),
                              ),
                              fillColor: Colors.grey.shade50,
                              filled: true,
                            ),
                            textAlign:
                                widget.localization.locale.languageCode == 'ar'
                                ? TextAlign.right
                                : TextAlign.left,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return widget.localization.translate(
                                  'validationRequired',
                                );
                              }
                              if (!RegExp(
                                r'^[^@]+@[^@]+\.[^@]+',
                              ).hasMatch(value)) {
                                return widget.localization.translate(
                                  'validationInvalidEmail',
                                );
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            // Use TextFormField for validation
                            controller: _subjectController,
                            decoration: InputDecoration(
                              labelText: widget.localization.translate(
                                'formSubjectLabel',
                              ),
                              hintText: widget.localization.translate(
                                'formSubjectPlaceholder',
                              ),
                              border: const OutlineInputBorder(
                                borderRadius: BorderRadius.all(
                                  Radius.circular(8),
                                ),
                              ),
                              fillColor: Colors.grey.shade50,
                              filled: true,
                            ),
                            textAlign:
                                widget.localization.locale.languageCode == 'ar'
                                ? TextAlign.right
                                : TextAlign.left,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return widget.localization.translate(
                                  'validationRequired',
                                );
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            // Use TextFormField for validation
                            controller: _messageController,
                            maxLines: 5,
                            decoration: InputDecoration(
                              labelText: widget.localization.translate(
                                'formMessageLabel',
                              ),
                              hintText: widget.localization.translate(
                                'formMessagePlaceholder',
                              ),
                              border: const OutlineInputBorder(
                                borderRadius: BorderRadius.all(
                                  Radius.circular(8),
                                ),
                              ),
                              fillColor: Colors.grey.shade50,
                              filled: true,
                            ),
                            textAlign:
                                widget.localization.locale.languageCode == 'ar'
                                ? TextAlign.right
                                : TextAlign.left,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return widget.localization.translate(
                                  'validationRequired',
                                );
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 24),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed:
                                  _sendEmail, // Call the _sendEmail function
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.green.shade700,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 18,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                elevation: 5,
                              ),
                              child: Text(
                                widget.localization.translate('formButton'),
                                style: const TextStyle(fontSize: 18),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _ContactInfoRow extends StatelessWidget {
  final IconData icon;
  final String text;
  final bool isRTL;
  final bool isAddress;
  final VoidCallback? onTap; // Add onTap callback

  const _ContactInfoRow({
    required this.icon,
    required this.text,
    required this.isRTL,
    this.isAddress = false,
    this.onTap, // Initialize onTap
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      // Use InkWell for tap feedback
      onTap: onTap, // Assign the onTap callback
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Icon(icon, color: Colors.green.shade200, size: 28),
          SizedBox(width: isRTL ? 0 : 16),
          SizedBox(width: isRTL ? 16 : 0), // Adjust spacing for RTL
          Flexible(
            child: Text(
              text,
              style: const TextStyle(fontSize: 16, color: Colors.white),
              textAlign: isRTL
                  ? TextAlign.right
                  : TextAlign.left, // Adjusted textAlign
            ),
          ),
        ],
      ),
    );
  }
}

// Ensure your LocalizationProvider has these keys:
/*
class LocalizationProvider extends ChangeNotifier {
  Locale _locale = const Locale('en'); // Default locale
  Locale get locale => _locale;

  String translate(String key) {
    final Map<String, Map<String, String>> translations = {
      'en': {
        'contactHeadline': 'Get in Touch',
        'contactText': 'Have a question or want to collaborate? Reach out to us!',
        'formHeadline': 'Send Us a Message',
        'formNameLabel': 'Your Name',
        'formNamePlaceholder': 'Enter your full name',
        'formEmailLabel': 'Your Email',
        'formEmailPlaceholder': 'name@example.com',
        'formSubjectLabel': 'Subject',
        'formSubjectPlaceholder': 'Regarding...',
        'formMessageLabel': 'Your Message',
        'formMessagePlaceholder': 'Type your message here...',
        'formButton': 'Send Message',
        'contactAddress': 'El Affroun, Blida Province, Algeria',
        'validationRequired': 'This field is required',
        'validationInvalidEmail': 'Please enter a valid email address',
        'emailLaunchError': 'Could not launch email client.',
        'emailLaunchErrorGeneric': 'Failed to send email.',
        'emailSentSuccess': 'Email client opened successfully!',
        'defaultEmailSubject': 'Inquiry from Website', // New translation key
      },
      'ar': {
        'contactHeadline': 'تواصل معنا',
        'contactText': 'هل لديك سؤال أو ترغب في التعاون؟ تواصل معنا!',
        'formHeadline': 'أرسل لنا رسالة',
        'formNameLabel': 'اسمك',
        'formNamePlaceholder': 'أدخل اسمك الكامل',
        'formEmailLabel': 'بريدك الإلكتروني',
        'formEmailPlaceholder': 'name@example.com',
        'formSubjectLabel': 'الموضوع',
        'formSubjectPlaceholder': 'بخصوص...',
        'formMessageLabel': 'رسالتك',
        'formMessagePlaceholder': 'اكتب رسالتك هنا...',
        'formButton': 'أرسل الرسالة',
        'contactAddress': 'العفرون، ولاية البليدة، الجزائر',
        'validationRequired': 'هذا الحقل مطلوب',
        'validationInvalidEmail': 'الرجاء إدخال عنوان بريد إلكتروني صالح',
        'emailLaunchError': 'تعذر تشغيل تطبيق البريد الإلكتروني.',
        'emailLaunchErrorGeneric': 'فشل إرسال البريد الإلكتروني.',
        'emailSentSuccess': 'تم فتح عميل البريد الإلكتروني بنجاح!',
        'defaultEmailSubject': 'استفسار من الموقع الإلكتروني',
      },
    };
    return translations[_locale.languageCode]?[key] ?? key;
  }

  void setLocale(Locale newLocale) {
    if (_locale != newLocale) {
      _locale = newLocale;
      notifyListeners();
    }
  }
}
*/
