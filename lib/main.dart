import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'provider/restaurant_provider.dart';
import 'provider/detail_provider.dart';
import 'provider/search_provider.dart';
import 'provider/review_provider.dart';
import 'provider/theme_provider.dart';
import 'provider/favorites_provider.dart';
import 'provider/reminder_provider.dart';
import 'services/notification_service.dart';
import 'ui/page/home_page.dart';
import 'utils/theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize notification service
  await NotificationService().initialize();
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => RestaurantProvider()),
        ChangeNotifierProvider(create: (_) => DetailProvider()),
        ChangeNotifierProvider(create: (_) => SearchProvider()),
        ChangeNotifierProvider(create: (_) => ReviewProvider()),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => FavoritesProvider()),
        ChangeNotifierProvider(create: (_) => ReminderProvider()),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          // Show loading screen while theme is being initialized
          if (!themeProvider.isInitialized) {
            return MaterialApp(
              title: 'Restaurant App',
              theme: AppTheme.lightTheme,
              home: const Scaffold(
                body: Center(
                  child: CircularProgressIndicator(),
                ),
              ),
              debugShowCheckedModeBanner: false,
            );
          }

          return MaterialApp(
            title: 'Restaurant App',
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: themeProvider.isDarkMode
                ? ThemeMode.dark
                : ThemeMode.light,
            home: const HomePage(),
            debugShowCheckedModeBanner: false,
          );
        },
      ),
    );
  }
}
