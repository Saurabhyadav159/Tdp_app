import 'dart:io';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:logger/logger.dart';
import '../../features/category/domain/category.dart';
import '../../features/dashboard/presentation/PageContentScreen .dart';
import '../models/FooterImage.dart';
import '../models/ProtocolImage.dart';
import '../models/SelfImage.dart';
import 'api_constants.dart';
import 'local_storage.dart';

class ApiService {
  final Dio _dio = Dio(BaseOptions(
    baseUrl: ApiConstants.baseUrl,
    connectTimeout: const Duration(seconds: 30),
    receiveTimeout: const Duration(seconds: 30),
  ));
  final Logger logger = Logger();

  // Check internet connection
  Future<bool> _hasInternetConnection() async {
    try {
      final connectivityResult = await Connectivity().checkConnectivity();
      if (connectivityResult == ConnectivityResult.none) {
        return false;
      }
      return true;
    } catch (e) {
      logger.e("Internet check failed: $e");
      return false;
    }
  }

  // Handle different types of errors
  void _handleError(dynamic e) {
    if (e is DioException) {
      switch (e.type) {
        case DioExceptionType.connectionTimeout:
        case DioExceptionType.receiveTimeout:
        case DioExceptionType.sendTimeout:
          throw Exception("Connection timeout. Please try again.");
        case DioExceptionType.badResponse:
          if (e.response?.statusCode == 404) {
            throw Exception("API endpoint not found (404)");
          } else if (e.response?.statusCode == 401) {
            throw Exception("Unauthorized access. Please login again.");
          } else if (e.response?.statusCode == 500) {
            throw Exception("Server error. Please try again later.");
          } else {
            throw Exception("Request failed with status ${e.response?.statusCode}");
          }
        case DioExceptionType.cancel:
          throw Exception("Request cancelled");
        case DioExceptionType.unknown:
          if (e.error is SocketException) {
            throw Exception("No internet connection");
          }
          throw Exception("Unknown error occurred");
        default:
          throw Exception("Network error occurred");
      }
    }
    throw Exception("An unexpected error occurred");
  }

  /// Sends a POST request to the specified endpoint with the provided data
  Future<Map<String, dynamic>> post(String endpoint, Map<String, dynamic> data) async {
    if (!await _hasInternetConnection()) {
      throw Exception("No internet connection");
    }

    try {
      logger.d("POST $endpoint with data: $data");
      Response response = await _dio.post(endpoint, data: data);
      return response.data;
    } catch (e) {
      logger.e("POST $endpoint failed: $e");
      _handleError(e);
      rethrow;
    }
  }

  /// Fetches a list of banners from the API
  Future<List<dynamic>> getBanners({
    required BuildContext context,
    int limit = 10,
    int offset = 0,
  }) async {
    if (!await _hasInternetConnection()) {
      throw Exception("No internet connection");
    }

    try {
      logger.d("Fetching banners with limit: $limit, offset: $offset");
      final response = await _dio.get(
        "banner/all",
        queryParameters: {"limit": limit, "offset": offset},
      );

      final List<dynamic> banners = response.data["result"] as List;

      // Preload all banner images before returning
      for (var banner in banners) {
        final imageUrl = banner['image'];
        if (imageUrl != null && imageUrl is String && imageUrl.isNotEmpty) {
          await precacheImage(NetworkImage(imageUrl), context);
        }
      }

      return banners;
    } catch (e) {
      logger.e("Failed to fetch banners: $e");
      _handleError(e);
      return [];
    }
  }


  /// Fetches a list of categories for the user
  Future<List<Category>> fetchCategories() async {
    if (!await _hasInternetConnection()) {
      throw Exception("No internet connection");
    }

    try {
      String? token = await getToken();
      if (token == null) throw Exception("Authentication required");

      _dio.options.headers["Authorization"] = "Bearer $token";
      final response = await _dio.get("category/user/list");
      List<Category> categories = [];

      for (var item in response.data["result"]) {
        String id = item["id"];
        String name = item["name"];
        List<Poster> posters = (item["poster"] as List).map((poster) {
          SpecialDay? specialDay;
          if (poster["specialDay"] != null) {
            specialDay = SpecialDay(
              name: poster["specialDay"]["name"],
              month: poster["specialDay"]["month"],
              day: poster["specialDay"]["day"],
            );
          }

          bool isVideo = poster["poster"].toLowerCase().endsWith('.mp4') ||
              poster["poster"].toLowerCase().endsWith('.mov');

          return Poster(
            id: poster["id"],
            posterUrl: poster["poster"],
            specialDay: specialDay,
            isVideo: isVideo,
            videoThumb: poster["videoThumb"],
            date: poster["date"],  // Added date field
          );
        }).toList();

        categories.add(Category(id: id, name: name, posters: posters));
      }

      return categories;
    } catch (e) {
      logger.e("Failed to fetch categories: $e");
      _handleError(e);
      return [];
    }
  }
  /// Fetches notifications for the user
  Future<List<Map<String, dynamic>>> fetchNotifications({int limit = 10, int offset = 0}) async {
    if (!await _hasInternetConnection()) {
      throw Exception("No internet connection");
    }

    try {
      String? token = await getToken();
      if (token == null) throw Exception("Authentication required");

      _dio.options.headers["Authorization"] = "Bearer $token";
      logger.d("Fetching notifications");

      final response = await _dio.get(
        "notifications",
        queryParameters: {"limit": limit, "offset": offset},
      );

      return List<Map<String, dynamic>>.from(response.data["result"]);
    } catch (e) {
      logger.e("Failed to fetch notifications: $e");
      _handleError(e);
      return [];
    }
  }

  /// Fetches the user's profile information
  Future<Map<String, dynamic>> getProfile() async {
    if (!await _hasInternetConnection()) {
      throw Exception("No internet connection");
    }

    try {
      String? token = await getToken();
      if (token == null) throw Exception("Authentication required");

      _dio.options.headers["Authorization"] = "Bearer $token";
      logger.d("Fetching user profile");

      final response = await _dio.get("account/user/profile");
      return response.data;
    } catch (e) {
      logger.e("Failed to fetch profile: $e");
      _handleError(e);
      rethrow;
    }
  }

  /// Fetches special days (events) from the API
  Future<List<Map<String, dynamic>>> fetchEvents() async {
    if (!await _hasInternetConnection()) {
      throw Exception("No internet connection");
    }

    try {
      String? token = await getToken();
      if (token == null) throw Exception("Authentication required");

      _dio.options.headers["Authorization"] = "Bearer $token";
      logger.d("Fetching events");

      final response = await _dio.get("special-day/all");
      logger.d("Fetched Events: ${response.data}");

      return List<Map<String, dynamic>>.from(response.data["result"]);
    } catch (e) {
      logger.e("Failed to fetch events: $e");
      _handleError(e);
      return [];
    }
  }

  /// Fetches posters based on category and special day
  Future<List<Map<String, dynamic>>> fetchPosters({
    required String categoryId,
    required String specialDayId,
    int limit = 10,
    int offset = 0,
  }) async {
    if (!await _hasInternetConnection()) {
      throw Exception("No internet connection");
    }

    try {
      String? token = await getToken();
      if (token == null) throw Exception("Authentication required");

      _dio.options.headers["Authorization"] = "Bearer $token";
      logger.d("Fetching posters for category: $categoryId");

      final response = await _dio.get(
        "poster/all/$categoryId",
        queryParameters: {
          "limit": limit,
          "offset": offset,
          "specialDayId": specialDayId,
        },
      );

      logger.d("Posters API Response: ${response.data}");
      return List<Map<String, dynamic>>.from(response.data["result"]);
    } catch (e) {
      logger.e("Failed to fetch posters: $e");
      _handleError(e);
      return [];
    }
  }

  /// Registers a new user
  Future<Map<String, dynamic>> registerUser({
    required String name,
    required String phoneNumber,
    String? email,
  }) async {
    try {
      final response = await _dio.post(
        'auth/user/register',
        data: {
          'name': name,
          'phoneNumber': phoneNumber,
          if (email != null && email.isNotEmpty) 'email': email,
        },
        options: Options(
          headers: {
            'Accept': 'application/json',
            'Content-Type': 'application/json',
          },
        ),
      );
      return response.data;
    } on DioException catch (e) {
      // Error handling here
      rethrow;
    }
  }


  Future<Response> sendOtpForRegistration({required String phoneNumber}) async {
    return await _dio.post(
      'auth/phone/otp',
      data: {'phoneNumber': phoneNumber},
    );
  }

  Future<Response> verifyOtpForRegistration({
    required String phoneNumber,
    required String otp,
  }) async {
    return await _dio.post(
      'auth/phone/verify',
      data: {
        'phoneNumber': phoneNumber,
        'otp': otp,
      },
    );
  }


  /// Uploads profile image
  Future<bool> uploadProfileImage(File imageFile) async {
    if (!await _hasInternetConnection()) {
      throw Exception("No internet connection");
    }

    try {
      String? token = await getToken();
      if (token == null) throw Exception("Authentication required");

      logger.d("Uploading profile image");
      FormData formData = FormData.fromMap({
        "file": await MultipartFile.fromFile(
          imageFile.path,
          filename: "profile.jpg",
        ),
      });

      Response response = await _dio.put(
        "/user-details/profileImage",
        data: formData,
        options: Options(headers: {
          "Content-Type": "multipart/form-data",
          "Authorization": "Bearer $token"
        }),
      );

      if (response.statusCode == 200) {
        logger.i("Profile image uploaded successfully");
        return true;
      } else {
        logger.e("Failed to upload profile image: ${response.statusCode}");
        return false;
      }
    } catch (e) {
      logger.e("Upload error: $e");
      _handleError(e);
      return false;
    }
  }

  /// Searches posters based on keyword
  Future<List<Map<String, dynamic>>> searchPosters({
    String keyword = "",
    int limit = 10,
    int offset = 0,
    String? categoryId,
  }) async {
    if (!await _hasInternetConnection()) {
      throw Exception("No internet connection");
    }

    try {
      String? token = await getToken();
      if (token == null) throw Exception("Authentication required");

      _dio.options.headers["Authorization"] = "Bearer $token";
      logger.d("Searching posters for keyword: $keyword");

      final response = await _dio.get(
        "poster/search",
        queryParameters: {
          "limit": limit,
          "offset": offset,
          "keyword": keyword,
          if (categoryId != null) "categoryId": categoryId,
        },
      );

      return List<Map<String, dynamic>>.from(response.data["result"]);
    } catch (e) {
      logger.e("Failed to search posters: $e");
      _handleError(e);
      return [];
    }
  }

  /// Fetches categories for search
  Future<List<Category>> fetchCategoriesSearch() async {
    if (!await _hasInternetConnection()) {
      throw Exception("No internet connection");
    }

    try {
      String? token = await getToken();
      if (token == null) throw Exception("Authentication required");

      _dio.options.headers["Authorization"] = "Bearer $token";
      logger.d("Fetching categories for search");

      final response = await _dio.get(ApiConstants.categoriesEndpoint);
      List<Category> categories = (response.data["result"] as List)
          .map((item) => Category(
        id: item["id"],
        name: item["name"],
        posters: [],
        // events: {},
      ))
          .toList();

      return categories;
    } catch (e) {
      logger.e("Failed to fetch categories: $e");
      _handleError(e);
      return [];
    }
  }

  /// Sends OTP for password reset
  // Future<Map<String, dynamic>> sendOtp(String email) async {
  //   if (!await _hasInternetConnection()) {
  //     throw Exception("No internet connection");
  //   }
  //
  //   try {
  //     logger.d("Sending OTP to: $email");
  //     Response response = await _dio.post(
  //       "auth/user/forgotPass",
  //       data: {"email": email},
  //     );
  //     return response.data;
  //   } catch (e) {
  //     logger.e("Failed to send OTP: $e");
  //     _handleError(e);
  //     throw Exception("Failed to send OTP. Please try again.");
  //   }
  // }

  /// Verifies OTP
  // Future<bool> verifyOtp(String email, String otp) async {
  //   if (!await _hasInternetConnection()) {
  //     throw Exception("No internet connection");
  //   }
  //
  //   try {
  //     logger.d("Verifying OTP for: $email");
  //     final response = await post(
  //       "auth/user/verify",
  //       {"email": email, "otp": otp},
  //     );
  //     return response["message"] == "OTP Matched.";
  //   } catch (e) {
  //     logger.e("OTP Verification Failed: $e");
  //     _handleError(e);
  //     return false;
  //   }
  // }

  /// Resets user password
  Future<Map<String, dynamic>> resetPassword(
      String email,
      String newPassword,
      ) async {
    if (!await _hasInternetConnection()) {
      throw Exception("No internet connection");
    }

    try {
      logger.d("Resetting password for: $email");
      final response = await _dio.post(
        "auth/resetPass",
        data: {
          "email": email,
          "newPassword": newPassword,
        },
      );
      return response.data;
    } catch (e) {
      logger.e("Password Reset Error: $e");
      _handleError(e);
      throw Exception("Failed to reset password. Please try again.");
    }
  }



  // In ApiService class to veryfy mobile number when login

  Future<Map<String, dynamic>> sendOtp(String mobile) async {
    if (!await _hasInternetConnection()) {
      throw Exception("No internet connection");
    }

    try {
      logger.d("Sending OTP to mobile: $mobile");
      Response response = await _dio.post(
        "auth/user/login",
        data: {"phoneNumber": mobile},
      );

      // Checking if the response is successful
      if (response.statusCode == 200 || response.statusCode == 201) {
        return response.data;
      } else {
        logger.e("Failed to send OTP: Unexpected status code ${response.statusCode}");
        throw Exception("Failed to send OTP. Status code: ${response.statusCode}");
      }
    } catch (e) {
      // If it's a DioException (like a 404 or 500), handle it specifically
      if (e is DioException) {
        if (e.response?.statusCode == 404) {
          logger.e("Endpoint not found: ${e.response?.data}");
          throw Exception("The requested endpoint is not found. Please check the API URL.");
        } else if (e.response?.statusCode == 500) {
          logger.e("Server error: ${e.response?.data}");
          throw Exception("Server error. Please try again later.");
        } else {
          logger.e("Dio error: $e");
          throw Exception("Failed to send OTP. Please try again.");
        }
      } else {
        // Generic error handling if it's not a DioException
        logger.e("General error: $e");
        throw Exception("Failed to send OTP. Please try again.");
      }
    }
  }

///////for login new api
  Future<Map<String, dynamic>> verifyOtp(String mobile, String otp) async {
    if (!await _hasInternetConnection()) {
      throw Exception("No internet connection");
    }

    try {
      logger.d("Verifying OTP for mobile: $mobile");

      // Make the POST request to the API
      Response response = await _dio.post(
        "auth/verify", // Endpoint for OTP verification
        data: {
          "phoneNumber": mobile, // Send the mobile number and OTP
          "otp": otp,
        },
      );

      // Check the response status
      if (response.statusCode == 200 || response.statusCode == 201) {
        // Successful OTP verification
        return response.data; // Return the response data
      } else {
        // Log the response data for debugging
        logger.e("Failed to verify OTP: Unexpected status code ${response.statusCode}, Response: ${response.data}");
        throw Exception("Failed to verify OTP. Status code: ${response.statusCode}");
      }
    } catch (e) {
      // Handle DioException and other errors
      if (e is DioException) {
        if (e.response?.statusCode == 404) {
          logger.e("Endpoint not found: ${e.response?.data}");
          throw Exception("The requested endpoint is not found. Please check the API URL.");
        } else if (e.response?.statusCode == 500) {
          logger.e("Server error: ${e.response?.data}");
          throw Exception("Server error. Please try again later.");
        } else {
          logger.e("Dio error: $e");
          throw Exception("Failed to verify OTP. Please try again.");
        }
      } else {
        logger.e("General error: $e");
        throw Exception("Failed to verify OTP. Please try again.");
      }
    }
  }


  Future<PageContent> getPageContent(int pageId) async {
    if (!await _hasInternetConnection()) {
      throw Exception("No internet connection");
    }

    try {
      // Get token from local storage
      final token = await getToken();
      if (token == null) {
        throw Exception("No authentication token found");
      }

      logger.d("Fetching page content for ID: $pageId");
      final response = await _dio.get(
        "pages/$pageId",
        options: Options(headers: {
          'Authorization': 'Bearer $token',
        }),
      );

      return PageContent.fromJson(response.data);
    } catch (e) {
      logger.e("Failed to fetch page content: $e");
      _handleError(e);
      rethrow;
    }
  }

  /// Sends a PATCH request to the specified endpoint with the provided data
  // Add to ApiService class

  /// Generic PATCH request method
  Future<Map<String, dynamic>> patch(
      String endpoint,
      Map<String, dynamic> data,
      ) async {
    if (!await _hasInternetConnection()) {
      throw Exception("No internet connection");
    }

    try {
      String? token = await getToken();
      if (token == null) throw Exception("Authentication required");

      _dio.options.headers["Authorization"] = "Bearer $token";
      logger.d("PATCH $endpoint with data: $data");

      Response response = await _dio.patch(
        endpoint,
        data: data,
      );
      return response.data;
    } catch (e) {
      logger.e("PATCH $endpoint failed: $e");
      _handleError(e);
      rethrow;
    }
  }

  /// Updates user details (name and email)
  Future<Map<String, dynamic>> updateUserDetails({
    required String name,
    required String email,
  }) async {
    try {
      final response = await patch(
        'user-details/update',
        {
          'name': name,
          'email': email,
        },
      );
      logger.i("User details updated successfully: $response");
      return response;
    } catch (e) {
      logger.e("Failed to update user details: $e");
      rethrow;
    }
  }


  ////////fetch list
  Future<List<SelfImage>> fetchSelfImages() async {
    if (!await _hasInternetConnection()) {
      throw Exception("No internet connection");
    }

    try {
      String? token = await getToken();
      if (token == null) throw Exception("Authentication required");

      _dio.options.headers["Authorization"] = "Bearer $token";
      logger.d("Fetching self images");

      final response = await _dio.get("self-image/user-list");
      return (response.data["result"] as List)
          .map((item) => SelfImage.fromJson(item))
          .toList();
    } catch (e) {
      logger.e("Failed to fetch self images: $e");
      _handleError(e);
      return [];
    }
  }



  /////protocall
  Future<List<ProtocolImage>> fetchProtocolImages() async {
    if (!await _hasInternetConnection()) {
      throw Exception("No internet connection");
    }
    try {
      String? token = await getToken();
      if (token == null) throw Exception("Authentication required");
      _dio.options.headers["Authorization"] = "Bearer $token";
      final response = await _dio.get("top-image/user-list");
      return (response.data["result"] as List)
          .map((item) => ProtocolImage.fromJson(item))
          .toList();
    } catch (e) {
      logger.e("Failed to fetch protocol images: $e");
      _handleError(e);
      return [];
    }
  }
/////////footer
  Future<List<FooterImage>> fetchFooterImages() async {
    if (!await _hasInternetConnection()) {
      throw Exception("No internet connection");
    }
    String? token = await getToken();
    if (token == null) throw Exception("Authentication required");

    _dio.options.headers["Authorization"] = "Bearer $token";
    final response = await _dio.get("bottom-image/user-list");
    return (response.data["result"] as List)
        .map((item) => FooterImage.fromJson(item))
        .toList();
  }

}
