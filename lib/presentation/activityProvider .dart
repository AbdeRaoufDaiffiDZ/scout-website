// ignore_for_file: file_names

import 'package:flutter/material.dart';
import 'package:scout/domain/entities/activity .dart';
import 'package:scout/domain/repositories/activityRepository .dart';

/// Manages the application's localization (language).
class LocalizationProvider with ChangeNotifier {
  Locale _locale = const Locale('ar', ''); // Default to English

  Locale get locale => _locale;

  /// Map of translations for different languages.
  static final Map<String, Map<String, String>> _localizedValues = {
    'en': {
      'loginButton': "Login",
      'pageTitle': "SMA Group Rahim Galia Bachir",
      'brandName': "Algerian Muslim Scouts",
      'groupName': "Group Rahim Galia Bachir - Bouira",
      'navHome': "Home",
      'navActivities': "Activities",
      'navContact': "Contact Us",
      'heroHeadline': "Building Tomorrow's Leaders, Today.",
      'heroText':
          "Join the Algerian Scouts Muslims and embark on a journey of adventure, learning, and community service.",
      'heroButton': "Discover Our Activities",
      'activitiesHeadline': "Our Latest Adventures",
      'readMore': "Read More",
      'viewAllActivities': "View All Activities",
      'contactHeadline': "Get in Touch",
      'contactText':
          "We'd love to hear from you! Whether you have questions about joining, our activities, or anything else, feel free to reach out.",
      'contactAddress':
          "المخيم الكشفي للشباب غربي باهية القمراوي \nمقابل دار المسنين، بلدية البويرة، ولاية البويرة",
      'formHeadline': "Send Us a Message",
      'formNameLabel': "Your Name",
      'formNamePlaceholder': "SMA Group Member",
      'formEmailLabel': "Your Email",
      'formEmailPlaceholder': "sma.RGB@gmail.com",
      'formSubjectLabel': "Subject",
      'formSubjectPlaceholder': "Inquiry about activities",
      'formMessageLabel': "Message",
      'formMessagePlaceholder': "Write your message here...",
      'formButton': "Send Message",
      'footerCopyright':
          "© 2024 SMA, Group Rahim Galia Bachir Wiliya of Bouira. All rights reserved.",
      'footerPrivacy': "Privacy Policy",
      'footerTerms': "Terms of Service",
      'loadingActivities': "Loading activities...",
      'activitiesError': "Failed to load activities. Please try again later.",
      'dateLabel': "Date",
      'viewGallery': "View Gallery",
    },
    'ar': {
      'loginButton': "تسجيل الدخول",
      'pageTitle': "ك إ ج  فوج الشهيد رحيم قالية بشير",
      'brandName': "الكشافة الاسلامية الجزائرية",
      'groupName': "فوج الشهيد رحيم قالية بشير - بلدية البويرة",
      'navHome': "الرئيسية",
      'navActivities': "الأنشطة",
      'navContact': "اتصل بنا",
      'heroHeadline': "بناء قادة الغد، اليوم.",
      'heroText':
          "انضم إلى الكشافة الاسلامية الجزائرية وانطلق في رحلة من المغامرة والتعلم وخدمة المجتمع.",
      'heroButton': "اكتشف أنشطتنا",
      'activitiesHeadline': "آخر مغامراتنا",
      'readMore': "اقرأ المزيد",
      'viewAllActivities': "عرض كل الأنشطة",
      'contactHeadline': "ابق على اتصال",
      'contactText':
          "يسعدنا أن نسمع منك! سواء كانت لديك أسئلة حول الانضمام، أنشطتنا، أو أي شيء آخر، لا تتردد في التواصل معنا.",
      'contactAddress':
          "المخيم الكشفي للشباب غربي باهية القمراوي \nمقابل دار المسنين، بلدية البويرة، ولاية البويرة",
      'formHeadline': "أرسل لنا رسالة",
      'formNameLabel': "اسمك",
      'formNamePlaceholder': "عضو فوج الشهيد رحيم قالية بشير",
      'formEmailLabel': "بريدك الإلكتروني",
      'formEmailPlaceholder': "sma.RGB@gmail.com",
      'formSubjectLabel': "الموضوع",
      'formSubjectPlaceholder': "استفسار حول الأنشطة",
      'formMessageLabel': "رسالتك",
      'formMessagePlaceholder': "اكتب رسالتك هنا...",
      'formButton': "إرسال الرسالة",
      'footerCopyright':
          "© 2024 ك إ ج فوج الشهيد رحيم قالية بشير ولاية البويرة. جميع الحقوق محفوظة.",
      'footerPrivacy': "سياسة الخصوصية",
      'footerTerms': "شروط الخدمة",
      'loadingActivities': "جاري تحميل الأنشطة...",
      'activitiesError': "فشل تحميل الأنشطة. يرجى المحاولة مرة أخرى لاحقًا.",
      'dateLabel': "التاريخ",
      'viewGallery': "عرض الصور",
    },
  };

  /// Returns the translated string for a given key in the current locale.
  String translate(String key) {
    return _localizedValues[_locale.languageCode]![key] ?? key;
  }

  /// Sets the application's locale.
  void setLocale(String languageCode) {
    if (_localizedValues.containsKey(languageCode)) {
      _locale = Locale(languageCode);
      notifyListeners();
    }
  }

  // Load preferred language from local storage (simulated here)
  Future<void> loadLocale() async {
    // In a real app, use shared_preferences
    // final prefs = await SharedPreferences.getInstance();
    // final langCode = prefs.getString('lang') ?? 'en';
    final String? langCode = null; // Simulating no stored preference for now
    _locale = Locale(langCode ?? 'ar');
    notifyListeners();
  }

  // Save preferred language to local storage (simulated here)
  Future<void> saveLocale(String languageCode) async {
    // In a real app, use shared_preferences
    // final prefs = await SharedPreferences.getInstance();
    // prefs.setString('lang', languageCode);
    debugPrint('Language saved to local storage: $languageCode');
  }
}

class ActivityProvider with ChangeNotifier {
  final ActivityRepository _repository;
  List<Activity> _activities = [];
  bool _isLoading = false;
  bool _isFetchingMore = false; // New state for loading more activities
  bool _sendingEmail = false;

  String? _errorMessage;
  String? _errorSendEmail;

  bool _seeAllActivities = false;
  int _currentPage = 1; // Track current page
  bool _hasMore = true; // Track if there are more activities to load

  /// Toggles the visibility of all activities.
  void toggleSeeAllActivities() {
    _seeAllActivities = !_seeAllActivities;
    notifyListeners();
  }

  bool get seeAll => _seeAllActivities;
  List<Activity> get activities => _activities;
  bool get isLoading => _isLoading;
  bool get isFetchingMore => _isFetchingMore; // Expose new loading state
  String? get errorMessage => _errorMessage;
  String? get errorSendEmail => _errorSendEmail;
  bool get sendingEmail => _sendingEmail;
  bool get hasMore => _hasMore; // Expose hasMore state

  ActivityProvider(this._repository);

  Future<void> sendEmail({
    required String name,
    required String email,
    required String subject,
    required String message,
  }) async {
    _sendingEmail = true;
    _errorSendEmail = null;
    notifyListeners();
    // Simulate sending an email
    try {
      await _repository.sendEmail(
        name: name,
        email: email,
        subject: subject,
        message: message,
      );
      _sendingEmail = false;
      notifyListeners();
    } catch (e) {
      _errorSendEmail = 'Failed to send email: ${e.toString()}';
      _sendingEmail = false;
      notifyListeners();
    }
    await Future.delayed(const Duration(seconds: 2));
    debugPrint('Email sent: $name, $email, $subject, $message');
  }

  // Initial fetch or refresh
  Future<void> fetchActivities({bool refresh = false}) async {
    if (_isLoading || _isFetchingMore) {
      return; // Prevent multiple simultaneous fetches
    }

    if (refresh) {
      _activities = [];
      _currentPage = 1;
      _hasMore = true;
    }

    if (!_hasMore && !refresh) return; // Don't fetch if no more activities

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final newActivities = await _repository.getActivities(
        page: _currentPage,
        limit: 10,
      );
      _activities.addAll(newActivities);
      _currentPage++;
      _hasMore =
          newActivities.length ==
          10; // Assuming 10 is the limit, if less, no more pages
    } catch (e) {
      _errorMessage = 'Failed to load activities: ${e.toString()}';
      // Do not clear activities on error during incremental load, just show error
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Load more activities for infinite scrolling
  Future<void> loadMoreActivities() async {
    if (_isLoading || _isFetchingMore || !_hasMore) {
      return; // Prevent multiple fetches
    }

    _isFetchingMore = true;
    _errorMessage = null; // Clear previous error
    notifyListeners();

    try {
      final newActivities = await _repository.getActivities(
        page: _currentPage,
        limit: 10,
      );
      _activities.addAll(newActivities);
      _currentPage++;
      _hasMore =
          newActivities.length == 10; // If less than limit, it's the last page
    } catch (e) {
      _errorMessage = 'Failed to load more activities: ${e.toString()}';
    } finally {
      _isFetchingMore = false;
      notifyListeners();
    }
  }
}
