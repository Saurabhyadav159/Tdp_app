import 'package:shared_preferences/shared_preferences.dart';
import 'package:logger/logger.dart';

final Logger logger = Logger(); // Initialize the logger

/// Saves the authentication token to SharedPreferences.
Future<void> saveToken(String token) async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setString('auth_token', token);

  // Log the token being saved
  logger.i("Token saved: $token");
}

/// Logs out the user by removing the authentication token from SharedPreferences.
Future<void> logout() async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.remove('auth_token');

  // Log the action of logging out
  logger.i("Token removed on logout");
}

/// Retrieves the authentication token from SharedPreferences.
Future<String?> getToken() async {
  final prefs = await SharedPreferences.getInstance();
  String? token = prefs.getString('auth_token');

  // Log the token being retrieved
  logger.i("Token retrieved: $token");

  return token;
}

/// Saves the clicked category ID to SharedPreferences.
Future<void> saveCategoryId(String categoryId) async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setString('last_clicked_category', categoryId);

  // Log the stored category ID
  logger.i("Category ID saved: $categoryId");
}

Future<String?> getCategoryId() async {
  final prefs = await SharedPreferences.getInstance();
  String? categoryId = prefs.getString('last_clicked_category');

  // Log the retrieved category ID
  logger.i("Retrieved Category ID: $categoryId");

  return categoryId;
}


/// Saves the clicked category ID to SharedPreferences.
Future<void> saveSearchCategoryClickId(String categoryId) async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setString('search_category_click_id', categoryId);
  logger.i("Search Category Click ID saved: $categoryId");
}

/// Retrieves the clicked category ID from SharedPreferences.
Future<String?>getSearchCategoryClickId() async {
  final prefs = await SharedPreferences.getInstance();
  String? categoryId = prefs.getString('search_category_click_id');
  logger.i("Retrieved Search Category Click ID: $categoryId");
  return categoryId;
}
