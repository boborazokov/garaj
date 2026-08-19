import 'package:shared_preferences/shared_preferences.dart';

/// OTP signup JWT from [signUp] — stored until [confirmSignUp] succeeds.
const String pendingSignupTokenKey = 'pending_signup_token';

Future<void> savePendingSignupToken(String token) async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setString(pendingSignupTokenKey, token);
}

Future<String?> readPendingSignupToken() async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getString(pendingSignupTokenKey);
}

Future<void> clearPendingSignupToken() async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.remove(pendingSignupTokenKey);
}
