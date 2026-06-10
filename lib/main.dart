import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'constants/app_colors.dart';
import 'providers/movie_provider.dart';
import 'screens/splash_screen.dart';
import 'services/remote_config_service.dart';
import 'services/ad_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await RemoteConfigService.initialize();
  await AdService.initialize();
  runApp(const MoviFlixApp());
}

class MoviFlixApp extends StatelessWidget {
  const MoviFlixApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => MovieProvider()),
      ],
      child: MaterialApp(
        title: 'MoviFlix',
        debugShowCheckedModeBanner: false,
        theme: ThemeData.dark().copyWith(
          scaffoldBackgroundColor: AppColors.scaffoldBackground,
          primaryColor: AppColors.primaryColor,
          colorScheme: const ColorScheme.dark(
            primary: AppColors.primaryColor,
            secondary: AppColors.primaryDark,
          ),
          appBarTheme: const AppBarTheme(
            backgroundColor: AppColors.scaffoldBackground,
            elevation: 0,
          ),
        ),
        home: const SplashScreen(),
      ),
    );
  }
}