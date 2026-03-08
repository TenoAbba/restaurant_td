import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:restaurant_td/main.dart';

class SupabaseAuthService {
  // ─── Phone / OTP ───────────────────────────────────────────

  /// Send OTP to phone number
  static Future<void> sendOTP({
    required String phoneNumber,
    required String countryCode,
  }) async {
    final fullPhone = '$countryCode$phoneNumber';
    await supabase.auth.signInWithOtp(phone: fullPhone);
  }

  /// Verify OTP
  static Future<AuthResponse> verifyOTP({
    required String phoneNumber,
    required String countryCode,
    required String otp,
  }) async {
    final fullPhone = '$countryCode$phoneNumber';
    return await supabase.auth.verifyOTP(
      phone: fullPhone,
      token: otp,
      type: OtpType.sms,
    );
  }

  // ─── Email / Password ──────────────────────────────────────

  /// Sign up with email and password
  static Future<AuthResponse> signUpWithEmail({
    required String email,
    required String password,
  }) async {
    return await supabase.auth.signUp(
      email: email,
      password: password,
    );
  }

  /// Login with email and password
  static Future<AuthResponse> loginWithEmail({
    required String email,
    required String password,
  }) async {
    return await supabase.auth.signInWithPassword(
      email: email,
      password: password,
    );
  }

  // ─── Google ────────────────────────────────────────────────

  /// Login with Google
  static Future<void> loginWithGoogle() async {
    await supabase.auth.signInWithOAuth(
      OAuthProvider.google,
      redirectTo: 'io.supabase.restauranttd://login-callback/',
    );
  }

  // ─── Password Reset ────────────────────────────────────────

  /// Send password reset email
  static Future<void> resetPassword({required String email}) async {
    await supabase.auth.resetPasswordForEmail(email);
  }

  // ─── Session ───────────────────────────────────────────────

  /// Get current logged in user
  static User? getCurrentUser() {
    return supabase.auth.currentUser;
  }

  /// Check if user is logged in
  static bool isLoggedIn() {
    return supabase.auth.currentUser != null;
  }

  /// Sign out
  static Future<void> signOut() async {
    await supabase.auth.signOut();
  }

  // ─── User Profile ──────────────────────────────────────────

  /// Save user profile to users table after signup
  static Future<void> saveUserProfile({
    required String id,
    required String firstName,
    required String lastName,
    required String email,
    required String phoneNumber,
    required String countryCode,
    String role = 'vendor',
    String? fcmToken,
  }) async {
    await supabase.from('users').upsert({
      'id': id,
      'first_name': firstName,
      'last_name': lastName,
      'email': email,
      'phone_number': phoneNumber,
      'country_code': countryCode,
      'role': role,
      'fcm_token': fcmToken,
      'active': true,
    });
  }

  /// Get user profile from users table
  static Future<Map<String, dynamic>?> getUserProfile(String id) async {
    final response =
        await supabase.from('users').select().eq('id', id).single();
    return response;
  }

  /// Update FCM token
  static Future<void> updateFcmToken({
    required String userId,
    required String fcmToken,
  }) async {
    await supabase
        .from('users')
        .update({'fcm_token': fcmToken}).eq('id', userId);
  }
}
