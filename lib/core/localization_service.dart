import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocalizationService {
  static const List<Locale> supportedLocales = [
    Locale('en', 'US'), // English
    Locale('pa', 'IN'), // Punjabi
    Locale('hi', 'IN'), // Hindi
    Locale('te', 'IN'), // Telugu
    Locale('ta', 'IN'), // Tamil
    Locale('ml', 'IN'), // Malayalam
    Locale('kn', 'IN'), // Kannada
    Locale('mr', 'IN'), // Marathi
    Locale('bn', 'IN'), // Bengali
  ];

  static Map<String, Map<String, String>> localizedValues = {
    'en': {
      'app_title': 'Public Transport Tracker',
      'login': 'Login',
      'signup': 'Sign Up',
      'email': 'Email',
      'password': 'Password',
      'phone': 'Phone Number',
      'continue': 'Continue',
      'passenger': 'Passenger',
      'driver_conductor': 'Driver/Conductor',
      'select_role': 'Select Your Role',
      'dashboard': 'Dashboard',
      'live_tracking': 'Live Bus Tracking',
      'book_ticket': 'Book Ticket',
      'my_passes': 'My Passes',
      'sos': 'SOS',
      'trip_logs': 'Trip Logs',
      'passenger_count': 'Passenger Count',
      'start_trip': 'Start Trip',
      'stop_trip': 'Stop Trip',
      'route_selection': 'Route Selection',
      'notifications': 'Notifications',
      'settings': 'Settings',
      'logout': 'Logout',
      'language': 'Language',
      'english': 'English',
      'punjabi': 'ਪੰਜਾਬੀ',
      'hindi': 'हिंदी',
      'telugu': 'తెలుగు',
      'tamil': 'தமிழ்',
      'malayalam': 'മലയാളം',
      'kannada': 'ಕನ್ನಡ',
      'marathi': 'मराठी',
      'bengali': 'বাংলা',
      'my_tickets': 'My Tickets',
      'manage_routes': 'Manage Routes',
      'manage_passengers': 'Manage Passengers',
      'raise_complaint': 'Raise Complaint',
    },
    'pa': {
      'app_title': 'ਜਨਤਕ ਟਰਾਂਸਪੋਰਟ ਟ੍ਰੈਕਰ',
      'login': 'ਲਾਗਿਨ',
      'signup': 'ਸਾਇਨ ਅੱਪ',
      'email': 'ਈਮੇਲ',
      'password': 'ਪਾਸਵਰਡ',
      'phone': 'ਫ਼ੋਨ ਨੰਬਰ',
      'continue': 'ਜਾਰੀ ਰੱਖੋ',
      'passenger': 'ਯਾਤਰੀ',
      'driver_conductor': 'ਡਰਾਈਵਰ/ਕੰਡਕਟਰ',
      'select_role': 'ਆਪਣੀ ਭੂਮਿਕਾ ਚੁਣੋ',
      'dashboard': 'ਡੈਸ਼ਬੋਰਡ',
      'live_tracking': 'ਲਾਈਵ ਬੱਸ ਟ੍ਰੈਕਿੰਗ',
      'book_ticket': 'ਟਿਕਟ ਬੁੱਕ ਕਰੋ',
      'my_passes': 'ਮੇਰੇ ਪਾਸ',
      'sos': 'ਐਸ.ਓ.ਐਸ.',
      'trip_logs': 'ਯਾਤਰਾ ਲੌਗ',
      'passenger_count': 'ਯਾਤਰੀ ਗਿਣਤੀ',
      'start_trip': 'ਯਾਤਰਾ ਸ਼ੁਰੂ ਕਰੋ',
      'stop_trip': 'ਯਾਤਰਾ ਰੋਕੋ',
      'route_selection': 'ਰੂਟ ਚੋਣ',
      'notifications': 'ਸੂਚਨਾਵਾਂ',
      'settings': 'ਸੈਟਿੰਗਾਂ',
      'logout': 'ਲਾਗਆਉਟ',
      'language': 'ਭਾਸ਼ਾ',
      'english': 'English',
      'punjabi': 'ਪੰਜਾਬੀ',
      'hindi': 'हिंदी',
      'telugu': 'తెలుగు',
      'tamil': 'தமிழ்',
      'malayalam': 'മലയാളം',
      'kannada': 'ಕನ್ನಡ',
      'marathi': 'मराठी',
      'bengali': 'বাংলা',
      'my_tickets': 'ਮੇਰੀਆਂ ਟਿਕਟਾਂ',
      'manage_routes': 'ਰੂਟਾਂ ਦਾ ਪ੍ਰਬੰਧਨ ਕਰੋ',
      'manage_passengers': 'ਯਾਤਰੀਆਂ ਦਾ ਪ੍ਰਬੰਧਨ ਕਰੋ',
      'raise_complaint': 'ਸ਼ਿਕਾਇਤ ਦਰਜ ਕਰੋ',
    },
    'hi': {
      'app_title': 'सार्वजनिक परिवहन ट्रैकर',
      'login': 'लॉगिन',
      'signup': 'साइन अप',
      'email': 'ईमेल',
      'password': 'पासवर्ड',
      'phone': 'फोन नंबर',
      'continue': 'जारी रखें',
      'passenger': 'यात्री',
      'driver_conductor': 'ड्राइवर/कंडक्टर',
      'select_role': 'अपनी भूमिका चुनें',
      'dashboard': 'डैशबोर्ड',
      'live_tracking': 'लाइव बस ट्रैकिंग',
      'book_ticket': 'टिकट बुक करें',
      'my_passes': 'मेरे पास',
      'sos': 'एसओएस',
      'trip_logs': 'यात्रा लॉग',
      'passenger_count': 'यात्री संख्या',
      'start_trip': 'यात्रा शुरू करें',
      'stop_trip': 'यात्रा बंद करें',
      'route_selection': 'मार्ग चयन',
      'notifications': 'सूचनाएं',
      'settings': 'सेटिंग्स',
      'logout': 'लॉगआउट',
      'language': 'भाषा',
      'english': 'English',
      'punjabi': 'ਪੰਜਾਬੀ',
      'hindi': 'हिंदी',
      'telugu': 'తెలుగు',
      'tamil': 'தமிழ்',
      'malayalam': 'മലയാളം',
      'kannada': 'ಕನ್ನಡ',
      'marathi': 'मराठी',
      'bengali': 'বাংলা',
      'my_tickets': 'मेरे टिकट',
      'manage_routes': 'मार्ग प्रबंधन',
      'manage_passengers': 'यात्री प्रबंधन',
      'raise_complaint': 'शिकायत दर्ज करें',
    },
    'te': {
      'app_title': 'పబ్లిక్ ట్రాన్స్‌పోర్ట్ ట్రాకర్',
      'login': 'లాగిన్',
      'signup': 'సైన్ అప్',
      'email': 'ఇమెయిల్',
      'password': 'పాస్‌వర్డ్',
      'phone': 'ఫోన్ నంబర్',
      'continue': 'కొనసాగించు',
      'passenger': 'ప్రయాణికుడు',
      'driver_conductor': 'డ్రైవర్/కండక్టర్',
      'select_role': 'మీ పాత్రను ఎంచుకోండి',
      'dashboard': 'డ్యాష్‌బోర్డ్',
      'live_tracking': 'లైవ్ బస్ ట్రాకింగ్',
      'book_ticket': 'టిక్కెట్ బుక్ చేయండి',
      'my_passes': 'నా పాస్‌లు',
      'sos': 'ఎస్‌ఒఎస్',
      'trip_logs': 'ట్రిప్ లాగ్‌లు',
      'passenger_count': 'ప్రయాణికుల సంఖ్య',
      'start_trip': 'ట్రిప్ ప్రారంభించండి',
      'stop_trip': 'ట్రిప్ ఆపండి',
      'route_selection': 'రూట్ ఎంపిక',
      'notifications': 'నోటిఫికేషన్‌లు',
      'settings': 'సెట్టింగ్‌లు',
      'logout': 'లాగ్‌అవుట్',
      'language': 'భాష',
      'english': 'English',
      'punjabi': 'ਪੰਜਾਬੀ',
      'hindi': 'हिंदी',
      'telugu': 'తెలుగు',
      'tamil': 'தமிழ்',
      'malayalam': 'മലയാളം',
      'kannada': 'ಕನ್ನಡ',
      'marathi': 'मराठी',
      'bengali': 'বাংলা',
      'my_tickets': 'నా టిక్కెట్లు',
      'manage_routes': 'రూట్లను నిర్వహించండి',
      'manage_passengers': 'ప్రయాణికులను నిర్వహించండి',
      'raise_complaint': 'ఫిర్యాదు చేయండి',
    },
    'ta': {
      'app_title': 'பொது போக்குவரத்து ட்ராக்கர்',
      'login': 'உள்நுழைய',
      'signup': 'பதிவு செய்யவும்',
      'email': 'மின்னஞ்சல்',
      'password': 'கடவுச்சொல்',
      'phone': 'தொலைபேசி எண்',
      'continue': 'தொடரவும்',
      'passenger': 'பயணிகள்',
      'driver_conductor': 'இயக்குனர்/கடத்தலாளர்',
      'select_role': 'உங்கள் பங்கைத் தேர்ந்தெடுக்கவும்',
      'dashboard': 'டாஷ்போர்ட்',
      'live_tracking': 'லைவ் பேருந்து கண்காணிப்பு',
      'book_ticket': 'டிக்கெட் முன்பதிவு',
      'my_passes': 'எனது பாஸ்கள்',
      'sos': 'எஸ்.ஓ.எஸ்',
      'trip_logs': 'பயண பதிவுகள்',
      'passenger_count': 'பயணிகள் எண்ணிக்கை',
      'start_trip': 'பயணத்தைத் தொடங்கவும்',
      'stop_trip': 'பயணத்தை நிறுத்தவும்',
      'route_selection': 'இடத்தைத் தேர்ந்தெடுக்கவும்',
      'notifications': 'அறிவிப்புகள்',
      'settings': 'அமைப்புகள்',
      'logout': 'வெளியேறு',
      'language': 'மொழி',
      'english': 'English',
      'punjabi': 'ਪੰਜਾਬੀ',
      'hindi': 'हिंदी',
      'telugu': 'తెలుగు',
      'tamil': 'தமிழ்',
      'malayalam': 'മലയാളം',
      'kannada': 'ಕನ್ನಡ',
      'marathi': 'मराठी',
      'bengali': 'বাংলা',
      'my_tickets': 'எனது டிக்கெட்டுகள்',
      'manage_routes': 'இடங்களை நிர்வகிக்கவும்',
      'manage_passengers': 'பயணிகளை நிர்வகிக்கவும்',
      'raise_complaint': 'புகார் தாக்கல்',
    },
    'ml': {
      'app_title': 'പൊതു ഗതാഗത ട്രാക്കർ',
      'login': 'ലോഗിൻ',
      'signup': 'സൈൻ അപ്പ്',
      'email': 'ഇമെയിൽ',
      'password': 'പാസ്സ്‌വേഡ്',
      'phone': 'ഫോൺ നമ്പർ',
      'continue': 'തുടരുക',
      'passenger': 'യാത്രക്കാരൻ',
      'driver_conductor': 'ഡ്രൈവർ/കണ്ടക്ടർ',
      'select_role': 'നിങ്ങളുടെ പങ്ക് തിരഞ്ഞെടുക്കുക',
      'dashboard': 'ഡാഷ്ബോർഡ്',
      'live_tracking': 'തത്സമയ ബസ് ട്രാക്കിംഗ്',
      'book_ticket': 'ടിക്കറ്റ് ബുക്ക് ചെയ്യുക',
      'my_passes': 'എന്റെ പാസുകൾ',
      'sos': 'എസ്.ഒ.എസ്',
      'trip_logs': 'ട്രിപ്പ് ലോഗുകൾ',
      'passenger_count': 'യാത്രക്കാർ എണ്ണം',
      'start_trip': 'ട്രിപ്പ് ആരംഭിക്കുക',
      'stop_trip': 'ട്രിപ്പ് നിർത്തുക',
      'route_selection': 'റൂട്ട് തിരഞ്ഞെടുക്കൽ',
      'notifications': 'അറിയിപ്പുകൾ',
      'settings': 'ക്രമീകരണങ്ങൾ',
      'logout': 'ലോഗ്ഔട്ട്',
      'language': 'ഭാഷ',
      'english': 'English',
      'punjabi': 'ਪੰਜਾਬੀ',
      'hindi': 'हिंदी',
      'telugu': 'తెలుగు',
      'tamil': 'தமிழ்',
      'malayalam': 'മലയാളം',
      'kannada': 'ಕನ್ನಡ',
      'marathi': 'मराठी',
      'bengali': 'বাংলা',
      'my_tickets': 'എന്റെ ടിക്കറ്റുകൾ',
      'manage_routes': 'റൂട്ടുകൾ കൈകാര്യം ചെയ്യുക',
      'manage_passengers': 'യാത്രക്കാരെ കൈകാര്യം ചെയ്യുക',
      'raise_complaint': 'പരാതി രേഖപ്പെടുത്തുക',
    },
    'kn': {
      'app_title': 'ಸಾರ್ವಜನಿಕ ಸಾರಿಗೆ ಟ್ರಾಕರ್',
      'login': 'ಲಾಗಿನ್',
      'signup': 'ಸೈನ್ ಅಪ್',
      'email': 'ಇಮೇಲ್',
      'password': 'ಪಾಸ್ವರ್ಡ್',
      'phone': 'ಫೋನ್ ಸಂಖ್ಯೆ',
      'continue': 'ಮುಂದುವರಿಸಿ',
      'passenger': 'ಪ್ರಯಾಣಿಕ',
      'driver_conductor': 'ಚಾಲಕ/ಕಂಡಕ್ಟರ್',
      'select_role': 'ನಿಮ್ಮ ಪಾತ್ರವನ್ನು ಆಯ್ಕೆಮಾಡಿ',
      'dashboard': 'ಡ್ಯಾಶ್ಬೋರ್ಡ್',
      'live_tracking': 'ಲೈವ್ ಬಸ್ ಟ್ರಾಕಿಂಗ್',
      'book_ticket': 'ಟಿಕೆಟ್ ಬುಕ್ ಮಾಡಿ',
      'my_passes': 'ನನ್ನ ಪಾಸ್ ಗಳು',
      'sos': 'ಎಸ್.ಒ.ಎಸ್',
      'trip_logs': 'ಪ್ರವಾಸ ದಾಖಲೆಗಳು',
      'passenger_count': 'ಪ್ರಯಾಣಿಕರ ಎಣಿಕೆ',
      'start_trip': 'ಪ್ರವಾಸ ಪ್ರಾರಂಭಿಸಿ',
      'stop_trip': 'ಪ್ರವಾಸ ನಿಲ್ಲಿಸಿ',
      'route_selection': 'ಮಾರ್ಗ ಆಯ್ಕೆ',
      'notifications': 'ಸೂಚನೆಗಳು',
      'settings': 'ಸಿದ್ಧತೆಗಳು',
      'logout': 'ಲಾಗ್ ಔಟ್',
      'language': 'ಭಾಷೆ',
      'english': 'English',
      'punjabi': 'ਪੰਜਾਬੀ',
      'hindi': 'हिंदी',
      'telugu': 'తెలుగు',
      'tamil': 'தமிழ்',
      'malayalam': 'മലയാളം',
      'kannada': 'ಕನ್ನಡ',
      'marathi': 'मराठी',
      'bengali': 'বাংলা',
      'my_tickets': 'ನನ್ನ ಟಿಕೆಟ್ ಗಳು',
      'manage_routes': 'ಮಾರ್ಗಗಳನ್ನು ನಿರ್ವಹಿಸಿ',
      'manage_passengers': 'ಪ್ರಯಾಣಿಕರನ್ನು ನಿರ್ವಹಿಸಿ',
      'raise_complaint': 'ಫಿರ್ಯಾದು ದಾಖಲಿಸಿ',
    },
    'mr': {
      'app_title': 'सार्वजनिक वाहतूक ट्रॅकर',
      'login': 'लॉग इन करा',
      'signup': 'साइन अप करा',
      'email': 'ईमेल',
      'password': 'पासवर्ड',
      'phone': 'फोन नंबर',
      'continue': 'पुढे चला',
      'passenger': 'प्रवाश',
      'driver_conductor': 'ड्रायव्हर/कंडक्टर',
      'select_role': 'तुमचे भूमिका निवडा',
      'dashboard': 'डॅशबोर्ड',
      'live_tracking': 'थेट बस ट्रॅकिंग',
      'book_ticket': 'तिकिट बुक करा',
      'my_passes': 'माझे पास',
      'sos': 'एस.ओ.एस.',
      'trip_logs': 'प्रवास लॉग',
      'passenger_count': 'प्रवाश संख्या',
      'start_trip': 'प्रवास सुरू करा',
      'stop_trip': 'प्रवास थांबवा',
      'route_selection': 'मार्ग निवड',
      'notifications': 'सूचना',
      'settings': 'सेटिंग्ज',
      'logout': 'बाहेर पडा',
      'language': 'भाषा',
      'english': 'English',
      'punjabi': 'ਪੰਜਾਬੀ',
      'hindi': 'हिंदी',
      'telugu': 'తెలుగు',
      'tamil': 'தமிழ்',
      'malayalam': 'മലയാളം',
      'kannada': 'ಕನ್ನಡ',
      'marathi': 'मराठी',
      'bengali': 'বাংলা',
      'my_tickets': 'माझी तिकिटे',
      'manage_routes': 'मार्ग व्यवस्थापित करा',
      'manage_passengers': 'प्रवाश व्यवस्थापित करा',
      'raise_complaint': 'तक्रार नोंदवा',
    },
    'bn': {
      'app_title': 'পাবলিক ট্রান্সপোর্ট ট্র্যাকার',
      'login': 'লগইন',
      'signup': 'সাইন আপ',
      'email': 'ইমেইল',
      'password': 'পাসওয়ার্ড',
      'phone': 'ফোন নম্বর',
      'continue': 'চালিয়ে যান',
      'passenger': 'যাত্রী',
      'driver_conductor': 'ড্রাইভার/কন্ডাক্টর',
      'select_role': 'আপনার ভূমিকা নির্বাচন করুন',
      'dashboard': 'ড্যাশবোর্ড',
      'live_tracking': 'লাইভ বাস ট্র্যাকিং',
      'book_ticket': 'টিকিট বুক করুন',
      'my_passes': 'আমার পাস',
      'sos': 'এস.ও.এস.',
      'trip_logs': 'ট্রিপ লগ',
      'passenger_count': 'যাত্রী সংখ্যা',
      'start_trip': 'ট্রিপ শুরু করুন',
      'stop_trip': 'ট্রিপ বন্ধ করুন',
      'route_selection': 'রুট নির্বাচন',
      'notifications': 'বিজ্ঞপ্তি',
      'settings': 'সেটিংস',
      'logout': 'লগআউট',
      'language': 'ভাষা',
      'english': 'English',
      'punjabi': 'ਪੰਜਾਬੀ',
      'hindi': 'हिंदी',
      'telugu': 'తెలుగు',
      'tamil': 'தமிழ்',
      'malayalam': 'മലയാളം',
      'kannada': 'ಕನ್ನಡ',
      'marathi': 'मराठी',
      'bengali': 'বাংলা',
      'my_tickets': 'আমার টিকিটগুলি',
      'manage_routes': 'রুট পরিচালনা করুন',
      'manage_passengers': 'যাত্রীদের পরিচালনা করুন',
      'raise_complaint': 'অভিযোগ তোলা',
    },
  };

  static String? getLocalizedValue(String key, Locale locale) {
    return localizedValues[locale.languageCode]?[key];
  }
  
  // Load saved language preference
  static Future<Locale> loadSavedLocale() async {
    final prefs = await SharedPreferences.getInstance();
    final languageCode = prefs.getString('language_code') ?? 'en';
    final countryCode = prefs.getString('country_code') ?? 'US';
    
    // Validate the saved locale
    final savedLocale = Locale(languageCode, countryCode);
    if (supportedLocales.contains(savedLocale)) {
      return savedLocale;
    }
    
    // Return default locale if saved locale is not supported
    return const Locale('en', 'US');
  }
  
  // Save language preference
  static Future<void> saveLocale(Locale locale) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('language_code', locale.languageCode);
    await prefs.setString('country_code', locale.countryCode ?? 'US');
  }
}

// LocalizationProvider class for state management
class LocalizationProvider with ChangeNotifier {
  Locale _currentLocale = const Locale('en', 'US');

  Locale get currentLocale => _currentLocale;

  LocalizationProvider() {
    _loadSavedLocale();
  }

  void setLocale(Locale locale) {
    // Optimized locale setting with minimal processing
    if (LocalizationService.supportedLocales.contains(locale) && _currentLocale != locale) {
      _currentLocale = locale;
      notifyListeners();
      
      // Asynchronous save to avoid blocking UI
      _saveLocale(locale);
    }
  }
  
  void setLocaleByLanguageCode(String languageCode) {
    final locale = LocalizationService.supportedLocales.firstWhere(
      (locale) => locale.languageCode == languageCode,
      orElse: () => const Locale('en', 'US'),
    );
    setLocale(locale);
  }
  
  Future<void> _loadSavedLocale() async {
    try {
      final savedLocale = await LocalizationService.loadSavedLocale();
      if (savedLocale != _currentLocale) {
        _currentLocale = savedLocale;
        // Only notify if there's an actual change
        notifyListeners();
      }
    } catch (e) {
      // If there's an error loading the saved locale, use the default
      _currentLocale = const Locale('en', 'US');
    }
  }
  
  // Asynchronous save to avoid blocking UI during locale changes
  Future<void> _saveLocale(Locale locale) async {
    try {
      await LocalizationService.saveLocale(locale);
    } catch (e) {
      // Silently handle save errors to prevent UI blocking
      print('Failed to save locale: $e');
    }
  }
}

extension AppLocalizations on BuildContext {
  String translate(String key) {
    final locale = Localizations.localeOf(this);
    return LocalizationService.getLocalizedValue(key, locale) ?? key;
  }
}
