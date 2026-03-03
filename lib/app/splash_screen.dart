import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:restaurant_td/controller/splash_controller.dart';
import 'package:restaurant_td/themes/app_them_data.dart';
import 'package:restaurant_td/utils/dark_theme_provider.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final themeChange = Provider.of<DarkThemeProvider>(context);
    return GetBuilder<SplashController>(
      init: SplashController(),
      builder: (controller) {
        return Scaffold(
          body: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: themeChange.getThem()
                    ? [
                        AppThemeData.grey900,
                        AppThemeData.grey800,
                        AppThemeData.secondary300.withOpacity(0.3),
                      ]
                    : [
                        AppThemeData.secondary300,
                        AppThemeData.secondary300.withOpacity(0.8),
                        AppThemeData.secondary300.withOpacity(0.6),
                      ],
              ),
            ),
            child: Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Logo with shadow
                    Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            blurRadius: 20,
                            spreadRadius: 5,
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(100),
                        child: Image.asset(
                          "assets/launcher/icon.png",
                          width: 140,
                          height: 140,
                        ),
                      ),
                    ),
                    const SizedBox(height: 40),
                    // App Title
                    Text(
                      "Food TD Restaurant".tr,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: AppThemeData.grey50,
                        fontSize: 28,
                        fontFamily: AppThemeData.bold,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.2,
                        shadows: [
                          Shadow(
                            color: Colors.black.withOpacity(0.3),
                            offset: Offset(0, 2),
                            blurRadius: 4,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    // Subtitle
                    Text(
                      "Manage Your Restaurant with Ease".tr,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: AppThemeData.grey50.withOpacity(0.9),
                        fontSize: 16,
                        fontFamily: AppThemeData.medium,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 8),
                    // Tagline
                    Text(
                      "Your Favorite Food Delivered Fast!".tr,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: AppThemeData.grey50.withOpacity(0.8),
                        fontSize: 14,
                        fontFamily: AppThemeData.regular,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                    const SizedBox(height: 60),
                    // Loading indicator
                    SizedBox(
                      width: 40,
                      height: 40,
                      child: CircularProgressIndicator(
                        strokeWidth: 3,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          AppThemeData.grey50.withOpacity(0.8),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
