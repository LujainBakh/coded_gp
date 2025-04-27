import 'package:get/get.dart';
import 'package:coded_gp/features/onboarding/screens/on_boarding_screen.dart';
import 'package:coded_gp/features/auth/views/screens/sign_in_screen.dart';
import 'package:coded_gp/features/splash/screens/splash_screen.dart';
import 'package:coded_gp/features/home/views/screens/homescreen.dart';
import 'package:coded_gp/features/profile/views/screens/profile_screen.dart';
import 'package:coded_gp/features/settings/views/screens/settings_screen.dart';
import 'package:coded_gp/features/settings/views/screens/privacy_screen.dart';
import 'package:coded_gp/features/settings/views/screens/notifications_screen.dart';
import 'package:coded_gp/features/settings/views/screens/about_screen.dart';
import 'package:coded_gp/features/settings/views/screens/security_screen.dart';
import 'package:coded_gp/features/settings/views/screens/help_support_screen.dart';
import 'package:coded_gp/features/settings/views/screens/terms_policies_screen.dart';
import 'package:coded_gp/features/home/views/screens/faq_screen.dart';
import 'package:coded_gp/features/gpa/views/screens/gpa_calculator_screen.dart';
import 'package:coded_gp/features/filemanager/views/screens/file_manager_screen.dart';
import 'package:coded_gp/features/filemanager/views/screens/add_file_screen.dart';
import 'package:coded_gp/features/filemanager/views/screens/view_files_screen.dart';
import 'package:coded_gp/features/timer/views/screens/timer_screen.dart';
import 'package:coded_gp/features/summariser/views/screens/summariser_screen.dart';
import 'package:coded_gp/features/summariser/views/screens/upload_file_summariser_screen.dart';

class AppRoutes {
  static const String onboarding = '/onboarding';
  static const String signin = '/signin';
  static const String splash = '/splash';
  static const String home = '/home';
  static const String profile = '/profile';
  static const String settings = '/settings';
  static const String privacy = '/privacy';
  static const notifications = '/notifications';
  static const about = '/about';
  static const security = '/security';
  static const helpSupport = '/help-support';
  static const termsPolicies = '/terms-policies';
  static const faq = '/faq';
  static const gpaCalculator = '/gpa-calculator';
  static const fileManager = '/file-manager';
  static const addFile = '/add-file';
  static const viewFiles = '/view-files';
  static const timer = '/timer';
  static const summariser = '/summariser';
  static const uploadFileSummariser = '/upload-file-summariser';

  static final routes = [
    GetPage(name: onboarding, page: () => const OnBoardingScreen()),
    GetPage(name: signin, page: () => const SignInScreen()),
    GetPage(name: splash, page: () => const SplashScreen()),
    GetPage(name: home, page: () => const HomeScreen()),
    GetPage(name: profile, page: () => const ProfileScreen()),
    GetPage(name: settings, page: () => const SettingsScreen()),
    GetPage(name: privacy, page: () => const PrivacyScreen()),
    GetPage(name: about, page: () => const AboutScreen()),
    GetPage(
      name: security,
      page: () => const SecurityScreen(),
    ),
    GetPage(
      name: notifications,
      page: () => const NotificationsScreen(),
    ),
    GetPage(
      name: helpSupport,
      page: () => const HelpSupportScreen(),
    ),
    GetPage(
      name: termsPolicies,
      page: () => const TermsPoliciesScreen(),
    ),
    GetPage(
      name: faq,
      page: () => const FAQScreen(),
    ),
    GetPage(
      name: gpaCalculator,
      page: () => const GPACalculatorScreen(),
    ),
    GetPage(
      name: fileManager,
      page: () => FileManagerScreen(),
    ),
    GetPage(
      name: addFile,
      page: () => const AddFileScreen(),
    ),
    GetPage(
      name: viewFiles,
      page: () => ViewFilesScreen(
        folderId: Get.arguments is Map
            ? Get.arguments['folderId'] ?? ''
            : Get.arguments?.toString() ?? '',
        folderName: Get.arguments is Map
            ? Get.arguments['folderName'] ?? 'Files'
            : 'Files',
      ),
    ),
    GetPage(
      name: timer,
      page: () => TimerScreen(),
    ),
    GetPage(
      name: summariser,
      page: () => SummariserScreen(),
    ),
    GetPage(
      name: uploadFileSummariser,
      page: () => UploadFileSummariserScreen(),
    ),
  ];
}
