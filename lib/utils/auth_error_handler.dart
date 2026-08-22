import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Translates raw Supabase / network exceptions into short, user friendly
/// messages so we never dump something like
/// `AuthApiException(message: email rate limit exceeded, statusCode: 429,
/// code: over_email_send_rate_limit)` into a toast.
class AuthErrorHandler {
  AuthErrorHandler._();

  /// Returns a human readable message for any exception thrown by Supabase.
  static String getMessage(Object error) {
    if (error is AuthException) {
      return _fromAuthException(error);
    }

    if (error is PostgrestException) {
      final message = error.message.toLowerCase();
      if (message.contains('duplicate key') ||
          message.contains('already exists')) {
        return 'This account already exists.'.tr;
      }
      if (message.contains('row-level security') ||
          message.contains('violates row-level')) {
        return 'You are not allowed to perform this action. Please sign in again.'
            .tr;
      }
      return 'Something went wrong. Please try again.'.tr;
    }

    if (error is StorageException) {
      return 'File upload failed. Please try again.'.tr;
    }

    final raw = error.toString().toLowerCase();
    if (raw.contains('socketexception') ||
        raw.contains('failed host lookup') ||
        raw.contains('clientexception') ||
        raw.contains('network is unreachable') ||
        raw.contains('connection closed') ||
        raw.contains('timeout')) {
      return 'No internet connection. Please check your network and try again.'
          .tr;
    }

    return 'Something went wrong. Please try again.'.tr;
  }

  /// True when the failure is caused by Supabase throttling e-mails / requests.
  /// Useful when the caller wants to keep the form data instead of resetting it.
  static bool isRateLimit(Object error) {
    if (error is! AuthException) return false;
    final code = error.code?.toLowerCase() ?? '';
    final message = error.message.toLowerCase();
    return error.statusCode == '429' ||
        code.contains('rate_limit') ||
        message.contains('rate limit') ||
        message.contains('too many requests');
  }

  /// True when signup succeeded but the account still needs e-mail confirmation.
  static bool needsEmailConfirmation(AuthResponse response) {
    return response.user != null && response.session == null;
  }

  static String _fromAuthException(AuthException error) {
    final code = error.code?.toLowerCase() ?? '';
    final message = error.message.toLowerCase();

    // ── Rate limiting (HTTP 429) ────────────────────────────────
    if (code == 'over_email_send_rate_limit' ||
        message.contains('email rate limit')) {
      return 'Too many confirmation e-mails were sent. Please wait a few minutes before trying again.'
          .tr;
    }
    if (code == 'over_sms_send_rate_limit') {
      return 'Too many SMS codes were sent. Please wait a few minutes before trying again.'
          .tr;
    }
    if (code == 'over_request_rate_limit' ||
        error.statusCode == '429' ||
        message.contains('rate limit') ||
        message.contains('too many requests')) {
      return 'Too many attempts. Please wait a moment and try again.'.tr;
    }

    // ── Existing / invalid accounts ─────────────────────────────
    if (code == 'user_already_exists' ||
        code == 'email_exists' ||
        message.contains('already registered') ||
        message.contains('already been registered')) {
      return 'This e-mail is already registered. Please sign in instead.'.tr;
    }
    if (code == 'email_address_invalid' ||
        code == 'validation_failed' ||
        message.contains('invalid email') ||
        message.contains('unable to validate email')) {
      return 'Please enter a valid e-mail address.'.tr;
    }
    if (code == 'email_not_confirmed' ||
        message.contains('email not confirmed')) {
      return 'Please confirm your e-mail address before signing in.'.tr;
    }
    if (code == 'invalid_credentials' ||
        message.contains('invalid login credentials')) {
      return 'Invalid e-mail or password.'.tr;
    }

    // ── Passwords ───────────────────────────────────────────────
    if (code == 'weak_password' ||
        message.contains('password should be at least') ||
        message.contains('password is too short')) {
      return 'Password is too weak. Use at least 6 characters.'.tr;
    }
    if (code == 'same_password') {
      return 'The new password must be different from the old one.'.tr;
    }

    // ── OTP / phone ─────────────────────────────────────────────
    if (code == 'otp_expired' || message.contains('token has expired')) {
      return 'This code has expired. Please request a new one.'.tr;
    }
    if (code == 'otp_disabled' || message.contains('invalid otp')) {
      return 'Invalid verification code. Please try again.'.tr;
    }
    if (code == 'phone_exists') {
      return 'This phone number is already registered.'.tr;
    }

    // ── Configuration / permissions ─────────────────────────────
    if (code == 'signup_disabled' || message.contains('signups not allowed')) {
      return 'New sign-ups are currently disabled. Please contact support.'.tr;
    }
    if (code == 'not_admin' ||
        message.contains('user not allowed') ||
        error.statusCode == '403') {
      return 'This action requires administrator privileges.'.tr;
    }
    if (code == 'provider_disabled') {
      return 'This sign-in method is disabled. Please try another one.'.tr;
    }
    if (error.statusCode == '500' ||
        message.contains('error sending confirmation') ||
        message.contains('smtp')) {
      return 'We could not send the confirmation e-mail. Please try again later.'
          .tr;
    }

    // Fall back to the server text, which is usually already readable.
    return error.message;
  }
}
