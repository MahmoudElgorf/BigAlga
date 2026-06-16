/// App general constants
class AppConstants {
  static const String historyKey = 'analysis_history';
  static const int maxHistoryItems = 50;

  static const String appName = 'BioAlga';
  static const String appVersion = '1.0.0';
}

class AppAssets {
  static const String appLogo = 'assets/images/App_Logo.png';
  static const String defaultAlgaeImage = 'assets/default_algae.png';
  static const String nontoxicImage = 'assets/images/Nontoxic.png';

  // Home Page Errors
  static const String unableToConnectService = 'Unable to connect to analysis service. Check internet and try again';
  static const String connectingToService = 'Connecting to analysis service. Please wait...';
  static const String serviceNotAvailable = 'Analysis service not available. Try again later';
  static const String unableToConnectServer = 'Unable to connect to analysis server';
}