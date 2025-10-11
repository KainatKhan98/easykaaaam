import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:flutter/foundation.dart' show debugPrint;
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../../features/Customer/home/presentation/model/category_model.dart';
import '../constants/api_constants.dart';

class ApiConstants {
  static const String baseUrl = "https://easy-kaam-48281873f974.herokuapp.com/";
  static const String _jwtTokenKey = 'jwt_token';
  static const String _userIdKey = 'user_id';
  static const String defaultUserId = '9ac1fff9-ea5f-4faf-9764-fa5c42167c6f';
}

class ApiService {

  static const _refreshKey = 'refresh_token';
  static const _jwtKey = 'jwt_token';
  static const _phoneKey = 'user_phone';
  static const _roleKey = 'user_role';


  static Future<void> _storeRefreshToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_refreshKey, token);
  }

  static Future<String?> _getStoredRefreshToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_refreshKey);
  }

  static Future<String?> getJwtToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(ApiConstants._jwtTokenKey);
    } catch (e) {
      debugPrint('Error retrieving JWT token: $e');
      return null;
    }
  }

  static Future<void> _storeJwtToken(String token) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(ApiConstants._jwtTokenKey, token);
    } catch (e) {
      debugPrint('Error storing JWT token: $e');
    }
  }

  static Future<String?> _getStoredJwtToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_jwtKey);
  }

  static Future<void> storeUserId(String userId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(ApiConstants._userIdKey, userId);
    } catch (e) {
      debugPrint('Error storing user ID: $e');
    }
  }

  static Future<String?> getUserId() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(ApiConstants._userIdKey);
    } catch (e) {
      debugPrint('Error retrieving user ID: $e');
      return null;
    }
  }

  static Future<void> storeUserPhone(String phone) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_phoneKey, phone);
    } catch (e) {
      debugPrint('Error storing user phone: $e');
    }
  }

  static Future<String?> getUserPhone() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(_phoneKey);
    } catch (e) {
      debugPrint('Error retrieving user phone: $e');
      return null;
    }
  }

  static Future<void> storeUserRole(int role) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(_roleKey, role);
    } catch (e) {
      debugPrint('Error storing user role: $e');
    }
  }

  static Future<int?> getUserRole() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getInt(_roleKey);
    } catch (e) {
      debugPrint('Error retrieving user role: $e');
      return null;
    }
  }

  static Future<void> clearAuthData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(ApiConstants._jwtTokenKey);
      await prefs.remove(ApiConstants._userIdKey);
      await prefs.remove(_refreshKey);
      await prefs.remove(_phoneKey);
      await prefs.remove(_roleKey);
    } catch (e) {
      debugPrint('Error clearing auth data: $e');
    }
  }

  static Future<bool> isAuthenticated() async {
    final token = await getJwtToken();
    return token != null && token.isNotEmpty;
  }

  static Future<bool> canAutoLogin() async {
    try {
      final token = await getJwtToken();
      final refreshToken = await _getStoredRefreshToken();
      
      if (token == null || token.isEmpty || refreshToken == null || refreshToken.isEmpty) {
        return false;
      }
      
      final isValid = await _validateCurrentToken(token);
      if (isValid) {
        return true;
      }
      
      final refreshResult = await _attemptTokenRefresh();
      return refreshResult;
    } catch (e) {
      debugPrint('Error checking auto-login capability: $e');
      return false;
    }
  }

  static Future<bool> _validateCurrentToken(String token) async {
    try {
      return true;
    } catch (e) {
      debugPrint('Error validating token: $e');
      return false;
    }
  }

  static Future<bool> _attemptTokenRefresh() async {
    try {
      final refreshToken = await _getStoredRefreshToken();
      if (refreshToken == null) return false;
      
      final phoneNo = await getUserPhone();
      final roleId = await getUserRole();
      
      if (phoneNo == null || roleId == null) {
        return false;
      }
      
      final result = await refreshJwtToken(
        phoneNo: phoneNo,
        roleId: roleId,
      );
      
      return result['success'] == true;
    } catch (e) {
      debugPrint('Error attempting token refresh: $e');
      return false;
    }
  }

  static Future<Map<String, String>> _getHeaders() async {
    final token = await getJwtToken();
    return {
      'Content-Type': 'application/json',
      'accept': '*/*',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  static Future<Map<String, dynamic>> verifyOtp({
    required String phoneNo,
    required String otpCode,
  }) async {
    try {
      final url = Uri.parse('${ApiConstants.baseUrl}api/users/verify-otp');

      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json', 'accept': '*/*'},
        body: jsonEncode({
          "phoneNo": phoneNo,
          "otpCode": otpCode,
        }),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        final token = _extractToken(data);
        final refreshToken = data['refreshToken']?.toString();

        if (token != null && token.isNotEmpty && refreshToken != null) {
          await _storeJwtToken(token);
          await _storeRefreshToken(refreshToken);

          if (data['userId'] != null) {
            await storeUserId(data['userId']);
          }

          await storeUserPhone(phoneNo);
          await storeUserRole(1);

          return {
            'success': true,
            'token': token,
            'refreshToken': refreshToken,
            'userId': data['userId'],
            'message': 'OTP verified successfully',
          };
        }

        return {'success': false, 'message': 'No token/refreshToken found'};
      }

      return {
        'success': false,
        'message': (data is Map && data['message'] != null)
            ? data['message']
            : (data is String
            ? data
            : 'OTP verification failed'),
      };

    } catch (e, stack) {
      debugPrint('Error in verifyOtp: $e');
      return {'success': false, 'message': 'Network error: ${e.toString()}'};
    }
  }



  static String? _extractToken(dynamic data) {
    if (data is Map<String, dynamic>) {
      if (data.containsKey('accessToken')) {
        return data['accessToken']?.toString();
      }

      if (data.containsKey('value')) {
        return data['value']?.toString();
      }

      if (data['data'] is Map<String, dynamic>) {
        return data['data']['value']?.toString();
      }
    }
    return null;
  }

  static Future<Map<String, dynamic>> refreshJwtToken({
    required String phoneNo,
    required int roleId,
  }) async {
    try {
      final refreshToken = await _getStoredRefreshToken();
      final oldToken = await _getStoredJwtToken();

      if (refreshToken == null) {
        return {'success': false, 'message': 'No refresh token found'};
      }

      final url = Uri.parse('${ApiConstants.baseUrl}api/auth/refresh');

      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'accept': '*/*',
          'Authorization': 'Bearer $oldToken',
        },
        body: jsonEncode({
          "refreshToken": refreshToken,
          "phoneNumber": phoneNo,
          "roleId": roleId,
        }),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        final newToken = _extractToken(data);
        if (newToken != null && newToken.isNotEmpty) {
          await _storeJwtToken(newToken);
          return {'success': true, 'token': newToken};
        }
      }

      return {'success': false, 'message': data['message'] ?? 'Failed to refresh token'};
    } catch (e) {
      debugPrint('Error in refreshJwtToken: $e');
      return {'success': false, 'message': 'Network error: ${e.toString()}'};
    }
  }


  static Future<Map<String, dynamic>> sendOtp(String name, String phoneNo) async {
    try {
      final url = Uri.parse('${ApiConstants.baseUrl}api/users/send-otp');
      
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json', 'accept': '*/*'},
        body: jsonEncode({"name": name, "phoneNo": phoneNo}),
      );
      
      final data = jsonDecode(response.body);
      if (response.statusCode == 200) {
        return {'success': true, 'message': 'OTP sent successfully'};
      }
      return {'success': false, 'message': data['message'] ?? 'Failed to send OTP'};
    } catch (e) {
      debugPrint('Error in sendOtp: $e');
      return {'success': false, 'message': 'Network error: ${e.toString()}'};
    }
  }

  static Future<Map<String, dynamic>> makeRequest({
    required String endpoint,
    required String method,
    Map<String, dynamic>? body,
  }) async {
    try {
      final url = Uri.parse('${ApiConstants.baseUrl}$endpoint');
      final headers = await _getHeaders();

      late http.Response response;
      switch (method.toUpperCase()) {
        case 'GET':
          response = await http.get(url, headers: headers);
          break;
        case 'POST':
          response = await http.post(url, headers: headers, body: body != null ? jsonEncode(body) : null);
          break;
        case 'PUT':
          response = await http.put(url, headers: headers, body: body != null ? jsonEncode(body) : null);
          break;
        case 'DELETE':
          response = await http.delete(url, headers: headers);
          break;
        default:
          throw Exception('Unsupported HTTP method: $method');
      }

      final responseData = jsonDecode(response.body);
      final isSuccess = response.statusCode >= 200 && response.statusCode < 300;

      return {
        'success': isSuccess,
        'statusCode': response.statusCode,
        'data': responseData,
        'message': responseData is Map<String, dynamic>
            ? (responseData['message'] ?? responseData['error'] ?? 'Request completed')
            : 'Request completed',
      };
    } catch (e) {
      debugPrint('Error in makeRequest: $e');
      return {'success': false, 'message': 'Network error: ${e.toString()}'};
    }
  }

  static Future<List<Category>> fetchCategories() async {
    try {
      final response = await http.get(
        Uri.parse('${ApiConstants.baseUrl}api/Categories/get-all-categories'),
        headers: {'accept': '*/*'},
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => Category.fromJson(json)).toList();
      }
      throw Exception('Failed to load categories: ${response.statusCode}');
    } catch (e) {
      debugPrint('Exception in fetchCategories: $e');
      rethrow;
    }
  }

  static Future<List<SubCategory>> fetchAllSubCategories(String categoryKey) async {
    try {
      final response = await http.get(
        Uri.parse('${ApiConstants.baseUrl}api/sub-categories/get-all-sub-categories'),
        headers: {'accept': '*/*'},
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => SubCategory.fromJson(json)).toList();
      }
      throw Exception('Failed to load sub-categories: ${response.statusCode}');
    } catch (e) {
      debugPrint('Exception in fetchAllSubCategories: $e');
      rethrow;
    }
  }

  static Future<SubCategory?> createSubCategory({
    required String name,
    required String description,
    required String imagePath,
  }) async {
    try {
      final url = Uri.parse("${ApiConstants.baseUrl}api/create-sub-category");
      final request = http.MultipartRequest('POST', url)
        ..fields['name'] = name
        ..fields['description'] = description
        ..files.add(await http.MultipartFile.fromPath('image', imagePath));

      final response = await request.send();
      final responseBody = await response.stream.bytesToString();

      if (response.statusCode == 200 || response.statusCode == 201) {
        return SubCategory.fromJson(json.decode(responseBody));
      }
      debugPrint("Failed to create sub-category: $responseBody");
      return null;
    } catch (e) {
      debugPrint("Exception while creating sub-category: $e");
      return null;
    }
  }
  static Future<void> _saveProfileImageUrl(String url) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('profileImageUrl', url);
  }

  static Future<String?> _getSavedProfileImageUrl() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('profileImageUrl');
  }

  static Future<Map<String, dynamic>> uploadProfilePicture(
      String userId, String imagePath) async {
    try {
      final token = await getJwtToken();
      if (token == null) {
        return {'success': false, 'message': 'No authentication token found'};
      }

      final url =
      Uri.parse('${ApiConstants.baseUrl}${AppConstants.uploadProfileEndpoint}');
      final request = http.MultipartRequest('POST', url)
        ..headers.addAll({
          'Authorization': 'Bearer $token',
          'Accept': '*/*',
          'Connection': 'keep-alive',
        })
        ..fields['userId'] = userId
        ..files.add(await http.MultipartFile.fromPath('profileImage', imagePath));

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);

        // ✅ Save new URL locally if present
        if (responseData['imageUrl'] != null) {
          await _saveProfileImageUrl(responseData['imageUrl']);
        }

        return {
          'success': true,
          'message': 'Profile picture uploaded successfully',
          'data': responseData
        };
      } else if (response.statusCode == 401) {
        // refresh token flow ...
        final phoneNo = await getUserPhone();
        final roleId = await getUserRole();
        if (phoneNo != null && roleId != null) {
          final refreshResult =
          await refreshJwtToken(phoneNo: phoneNo, roleId: roleId);
          if (refreshResult['success'] == true) {
            return await uploadProfilePicture(userId, imagePath);
          }
        }

        return {
          'success': false,
          'message': 'Authentication failed. Please login again.',
          'error': 'Token expired or invalid'
        };
      } else {
        return {
          'success': false,
          'message': 'Failed to upload profile picture. Status: ${response.statusCode}',
          'error': response.body
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Error uploading profile picture: $e'};
    }
  }

  /// ✅ Get profile image URL (API → fallback local)
  static Future<String?> getProfileImage(String userId, String token) async {
    try {
      final url = Uri.parse(
          '${ApiConstants.baseUrl}api/users/upload-profile-picture?userId=$userId');

      final response = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        if (data['imageUrl'] != null && data['imageUrl'].isNotEmpty) {
          // ✅ Update cache
          await _saveProfileImageUrl(data['imageUrl']);
          return data['imageUrl'];
        }
      } else if (response.statusCode == 401) {
        debugPrint('❌ Unauthorized. Token may be invalid or expired.');
      }
    } catch (e) {
      debugPrint('❌ Error getting profile image: $e');
    }

    // ✅ fallback to local storage if API fails
    return await _getSavedProfileImageUrl();
  }

  /// ✅ Check if user is already registered as a worker
  /// Note: This method uses a fallback approach since the backend doesn't have a dedicated check-registration endpoint
  static Future<bool> checkWorkerRegistration() async {
    Future<bool> _attemptCheck(String token) async {
      try {
        final userId = await getUserId();
        if (userId == null) return false;

        final url = Uri.parse('${ApiConstants.baseUrl}api/worker-details/register-as-worker');
        final request = http.MultipartRequest('POST', url)
          ..headers.addAll({
            'Authorization': 'Bearer $token',
            'Accept': '*/*',
          })
          ..fields['userId'] = userId
          ..fields['workRadius'] = '0'
          ..fields['extraDetails'] = 'check'
          ..fields['Key'] = '2';

        // 🔒 Force timeout here
        final streamedResponse = await request.send().timeout(
          const Duration(seconds: 6),
          onTimeout: () {
            debugPrint("❌ Worker check request timed out after 6s");
            throw TimeoutException("Worker check request timed out");
          },
        );

        final responseBody = await streamedResponse.stream.bytesToString();
        debugPrint("📥 Worker check response: ${streamedResponse.statusCode} | $responseBody");

        if (streamedResponse.statusCode == 400 &&
            responseBody.contains('Already Registered')) {
          return true;
        }
        return false;
      } catch (e) {
        debugPrint("❌ checkWorkerRegistration failed: $e");
        return false;
      }
    }

    try {
      String? token = await getJwtToken();
      if (token != null && await _attemptCheck(token)) return true;

      // 🔄 Retry with refreshed token (also with timeout)
      final refreshed = await _attemptTokenRefresh()
          .timeout(const Duration(seconds: 5), onTimeout: () {
        debugPrint("❌ Token refresh timed out");
        return false;
      });

      if (refreshed) {
        token = await getJwtToken();
        if (token != null) return await _attemptCheck(token);
      }

      return false;
    } catch (e) {
      debugPrint("❌ Outer error in checkWorkerRegistration: $e");
      return false;
    }
  }

  static Future<Map<String, dynamic>> registerAsWorker({
    required String userId,
    required String workRadius,
    required String extraDetails,
    required List<String> professions,
    String? idCardPath,
    String? policeClearanceFilePath,
  }) async {
    const String endpoint = 'api/worker-details/register-as-worker';
    const int maxRetries = 3;
    const Duration retryDelay = Duration(seconds: 3);

    Future<Map<String, dynamic>> _sendRequest(String token) async {
      final url = Uri.parse('${ApiConstants.baseUrl}$endpoint');

      debugPrint('🔑 Using JWT Token: $token');
      debugPrint('👤 User ID: $userId');
      debugPrint('📏 Work Radius: $workRadius');
      debugPrint('📝 Extra Details: $extraDetails');
      debugPrint('🔧 Selected Professions: $professions');

      var request = http.MultipartRequest('POST', url)
        ..fields['userId'] = userId
        ..fields['workRadius'] = workRadius
        ..fields['extraDetails'] = extraDetails
        ..fields['Key'] = "2"; // must be 2

      // 🔒 Do NOT change professions logic
      for (var profession in professions) {
        request.fields['professions[]'] = profession;
        debugPrint('➕ Adding profession: $profession');
      }

      if (idCardPath != null && idCardPath.isNotEmpty) {
        debugPrint("📎 Attaching ID card file: $idCardPath");
        request.files.add(await http.MultipartFile.fromPath('idCard', idCardPath));
      }
      if (policeClearanceFilePath != null && policeClearanceFilePath.isNotEmpty) {
        debugPrint("📎 Attaching Police Clearance file: $policeClearanceFilePath");
        request.files.add(await http.MultipartFile.fromPath(
          'policeClearanceFile',
          policeClearanceFilePath,
        ));
      }

      request.headers.addAll({
        'Accept': '*/*',
        'Authorization': 'Bearer $token',
        'Connection': 'keep-alive',
      });

      debugPrint("📡 Sending request to: $url");
      debugPrint("📬 Headers: ${request.headers}");
      debugPrint("📦 Fields: ${request.fields}");
      debugPrint("📂 Files: ${request.files.map((f) => f.filename).toList()}");

      try {
        final response = await request.send();
        final responseBody = await response.stream.bytesToString();

        dynamic decodedBody;
        try {
          decodedBody = responseBody.isNotEmpty ? jsonDecode(responseBody) : null;
        } catch (e) {
          decodedBody = responseBody;
        }

        debugPrint("📥 Response Code: ${response.statusCode}");
        debugPrint("📄 Response Body: $decodedBody");

        return {
          "statusCode": response.statusCode,
          "body": decodedBody,
        };
      } catch (e, stack) {
        debugPrint("❌ Network/Request error: $e");
        debugPrint("📌 Stacktrace: $stack");
        rethrow; // let retry logic handle it
      }
    }

    for (int attempt = 1; attempt <= maxRetries; attempt++) {
      try {
        final token = await getJwtToken();
        if (token == null) {
          return {
            "statusCode": 401,
            "error": "JWT token not found. User may not be authenticated."
          };
        }

        var result = await _sendRequest(token);

        if (result["statusCode"] == 401) {
          debugPrint("❌ Unauthorized. Attempting refresh...");
          final refreshed = await _attemptTokenRefresh();
          if (refreshed) {
            final newToken = await getJwtToken();
            if (newToken != null) {
              result = await _sendRequest(newToken);
            }
          } else {
            return {
              "statusCode": 401,
              "error": "Token expired and refresh failed"
            };
          }
        }

        return result;
      } catch (e) {
        debugPrint("❌ Attempt $attempt failed: $e");

        if (attempt < maxRetries &&
            (e.toString().contains('Connection reset') ||
                e.toString().contains('SocketException') ||
                e.toString().contains('timeout'))) {
          debugPrint("⏳ Retrying after ${retryDelay.inSeconds}s...");
          await Future.delayed(retryDelay);
          continue;
        }

        return {
          "statusCode": 500,
          "error": e.toString(),
          "attempts": attempt,
        };
      }
    }

    return {"statusCode": 500, "error": "Unexpected error in retry logic"};
  }

  ///Create Job API
  static Future<Map<String, dynamic>> createJob({
    required String title,
    required String description,
    required String address,
    required String token,
    required int serviceKey,
    required int minFee,
    required int maxFee,
    double? latitude,
    double? longitude,
    String? imagePath,
    String? videoPath,
    String? audioPath,
  }) async {
    try {
      final url = Uri.parse('${ApiConstants.baseUrl}api/Job/create-job');
      final request = http.MultipartRequest('POST', url);

      // ✅ Headers
      request.headers.addAll({
        'Authorization': 'Bearer $token',
        'Accept': '*/*',
        'Content-Type': 'multipart/form-data',
      });

      // ✅ Fields (all lowercase & matching API + additional fee fields)
      request.fields.addAll({
        'jobTitle': title,
        'jobDescription': description,
        'address': address,
        'key': serviceKey.toString(),
        'currentLat': (latitude ?? 0).toString(),
        'currentLon': (longitude ?? 0).toString(),
        'minFee': minFee.toString(),
        'maxFee': maxFee.toString(),
      });

      // ✅ Optional files
      if (imagePath != null && imagePath.isNotEmpty) {
        request.files.add(await http.MultipartFile.fromPath('referenceImage', imagePath));
      }
      if (videoPath != null && videoPath.isNotEmpty) {
        request.files.add(await http.MultipartFile.fromPath('referenceVideo', videoPath));
      }
      if (audioPath != null && audioPath.isNotEmpty) {
        request.files.add(await http.MultipartFile.fromPath('referenceAudio', audioPath));
      }

      // 🔍 Debug log
      print("➡️ Sending request to: $url");
      print("➡️ Headers: ${request.headers}");
      print("➡️ Fields:");
      request.fields.forEach((key, value) => print("   $key: $value"));
      print("➡️ Files: ${request.files.map((f) => f.filename).toList()}");

      // ✅ Send request
      final response = await request.send();
      final responseBody = await response.stream.bytesToString();

      print("⬅️ Response Code: ${response.statusCode}");
      print("⬅️ Response Body: $responseBody");

      // ✅ Decode safely
      Map<String, dynamic>? decoded;
      try {
        decoded = jsonDecode(responseBody);
      } catch (_) {
        decoded = {"raw": responseBody};
      }

      if (response.statusCode == 200 || response.statusCode == 201) {
        return {"success": true, "data": decoded};
      } else if (response.statusCode == 401) {
        return {"success": false, "error": "Unauthorized"};
      } else {
        return {
          "success": false,
          "error": "Unexpected error (${response.statusCode})",
          "details": decoded
        };
      }
    } catch (e, stackTrace) {
      log("❌ Exception in createJob: $e", stackTrace: stackTrace);
      return {"success": false, "error": e.toString()};
    }
  }


  static Future<List<Map<String, dynamic>>> testGetAvailableJobs({
    required String workerId,
    required String token,
    required double lat,
    required double lon,
    int pageNumber = 1,
    int pageSize = 10,
    double radiusKm = 4000.0,
}) async {
    try {
      final url = Uri.parse("${ApiConstants.baseUrl}api/worker-details/get-avaliable-jobs");

      // ✅ Request body exactly as per API
      final body = {
        "workerId": workerId,
        "pageNumber": pageNumber,
        "pageSize": pageSize,
        "currentLat": lat,
        "currentLon": lon,
        "radiusKm": radiusKm,
      };

      debugPrint("📡 Sending request to: $url");
      debugPrint("📦 Request body: ${jsonEncode(body)}");
      debugPrint("🔑 Worker ID: $workerId");
      debugPrint("🗺️ Coordinates: lat=$lat, lon=$lon");
      debugPrint("🔐 Token: ${token}");

      // ✅ POST request
      final response = await http.post(
        url,
        headers: {
          "Authorization": "Bearer $token",
          "Accept": "*/*",
          "Content-Type": "application/json",
        },
        body: jsonEncode(body),
      );

      debugPrint("📩 Response Code: ${response.statusCode}");
      debugPrint("📩 Response Body: ${response.body}");

      // ✅ Successful response
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        if (data is List) {
          debugPrint("✅ Response is a List with ${data.length} items");
          return List<Map<String, dynamic>>.from(data);
        } else if (data is Map) {
          // Handle possible nested list fields
          final possibleKeys = ["data", "jobs", "results"];
          for (final key in possibleKeys) {
            if (data.containsKey(key) && data[key] is List) {
              final jobs = List<Map<String, dynamic>>.from(data[key]);
              debugPrint("✅ Extracted ${jobs.length} jobs from '$key'");
              return jobs;
            }
          }

          debugPrint("⚠️ Map response but no job list found. Keys: ${data.keys}");
          return [];
        } else {
          debugPrint("⚠️ Unexpected response format: ${data.runtimeType}");
          return [];
        }
      } else {
        debugPrint("❌ API Error: ${response.statusCode}");
        debugPrint("❌ Response Body: ${response.body}");
        return [];
      }
    } catch (e, stack) {
      debugPrint("💥 Exception: $e");
      debugPrint("📜 Stack Trace: $stack");
      return [];
    }
  }

  static Future<Map<String, dynamic>> applyForJob({
    required String jobId,
    required String workerId,
  }) async {
    try {
      final token = await getJwtToken();
      debugPrint('🔑 Retrieved JWT token: ${token?.substring(0, 20)}...');
      
      if (token == null) {
        debugPrint('❌ No JWT token found in storage');
        throw Exception('No authentication token found');
      }

      final url = Uri.parse('${ApiConstants.baseUrl}api/worker-details/apply-for-job');
      debugPrint('🌐 API URL: $url');

      final requestBody = {
        'jobId': jobId,
        'workerId': workerId,
      };
      
      debugPrint('📦 Request body: ${jsonEncode(requestBody)}');
      debugPrint('📋 Request headers: Authorization: Bearer ${token.substring(0, 20)}..., Accept: */*, Content-Type: application/json');

      final response = await http.post(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': '*/*',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(requestBody),
      );

      debugPrint('📡 Apply for job response status: ${response.statusCode}');
      debugPrint('📡 Apply for job response body: ${response.body}');

      // Handle empty response body
      if (response.body.isEmpty) {
        debugPrint('⚠️ Empty response body received');
        if (response.statusCode == 200) {
          return {
            'success': true,
            'message': 'Successfully applied for job',
            'data': null,
            'jobId': jobId, // Include jobId in response
          };
        } else {
          return {
            'success': false,
            'message': 'Failed to apply for job: ${response.statusCode}',
            'error': 'Empty response body',
          };
        }
      }

      // Try to parse JSON response
      Map<String, dynamic> data;
      try {
        data = jsonDecode(response.body);
      } catch (jsonError) {
        debugPrint('❌ JSON parsing error: $jsonError');
        debugPrint('❌ Response body: ${response.body}');
        return {
          'success': false,
          'message': 'Invalid response format from server',
          'error': jsonError.toString(),
        };
      }

      if (response.statusCode == 200) {
        debugPrint('✅ Successfully applied for job: $jobId');
        return {
          'success': true,
          'message': 'Successfully applied for job',
          'data': data,
          'jobId': jobId, // Include jobId in response
        };
      } else if (response.statusCode == 401) {
        debugPrint('🔐 Unauthorized (401) - Token may be expired, attempting to refresh...');
        
        // Try to refresh the token
        final phoneNo = await getUserPhone();
        final roleId = await getUserRole();
        
        if (phoneNo != null && roleId != null) {
          debugPrint('🔄 Attempting token refresh with phone: $phoneNo, role: $roleId');
          final refreshResult = await refreshJwtToken(
            phoneNo: phoneNo, 
            roleId: roleId
          );
          
          if (refreshResult['success'] == true) {
            debugPrint('✅ Token refreshed successfully, retrying apply for job...');
            
            // Retry the request with new token
            final newToken = await getJwtToken();
            final retryResponse = await http.post(
              url,
              headers: {
                'Authorization': 'Bearer $newToken',
                'Accept': '*/*',
                'Content-Type': 'application/json',
              },
              body: jsonEncode(requestBody),
            );
            
            debugPrint('🔄 Retry response status: ${retryResponse.statusCode}');
            debugPrint('🔄 Retry response body: ${retryResponse.body}');
            
            if (retryResponse.statusCode == 200) {
              debugPrint('✅ Successfully applied for job after token refresh: $jobId');
              return {
                'success': true,
                'message': 'Successfully applied for job',
                'data': retryResponse.body.isEmpty ? null : jsonDecode(retryResponse.body),
                'jobId': jobId, // Include jobId in response
              };
            }
          }
        }
        
        return {
          'success': false,
          'message': 'Authentication failed. Please login again.',
          'error': 'Token expired and refresh failed',
        };
      } else {
        debugPrint('❌ Failed to apply for job: ${response.statusCode}');
        return {
          'success': false,
          'message': 'Failed to apply for job: ${response.statusCode}',
          'error': data,
        };
      }
    } catch (e) {
      debugPrint('💥 Exception applying for job: $e');
      return {
        'success': false,
        'message': 'Error applying for job: $e',
        'error': e.toString(),
      };
    }
  }


  static Future<Map<String, dynamic>> getAllJobApplicants({
    required String jobId,
    int pageNumber = 1,
    int pageSize = 15,
  }) async {
    try {
      final token = await _getStoredJwtToken();
      if (token == null) {
        return {
          'success': false,
          'message': 'No authentication token found',
        };
      }

      final url = Uri.parse('${ApiConstants.baseUrl}api/Job/get-all-job-applicants');
      
      final requestBody = {
        'jobId': jobId,
        'pageNumber': pageNumber,
        'pageSize': pageSize,
      };

      debugPrint('🔍 Getting job applicants for jobId: $jobId');
      debugPrint('🔍 Request body: ${jsonEncode(requestBody)}');

      final response = await http.post(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': '*/*',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(requestBody),
      );

      debugPrint('🔍 Response status: ${response.statusCode}');
      debugPrint('🔍 Response body: ${response.body}');

      if (response.statusCode == 200) {
        if (response.body.isEmpty) {
          return {
            'success': true,
            'message': 'No applicants found',
            'data': [],
          };
        }

        try {
          final responseData = jsonDecode(response.body);
          // Extract the data field from the response
          final List<dynamic> applicantsList = responseData['data'] ?? [];
          debugPrint('✅ Extracted ${applicantsList.length} applicants from response');
          
          return {
            'success': true,
            'message': 'Job applicants retrieved successfully',
            'data': applicantsList,
          };
        } catch (e) {
          debugPrint('💥 JSON decode error: $e');
          return {
            'success': false,
            'message': 'Error parsing response: ${e.toString()}',
          };
        }
      } else if (response.statusCode == 401) {
        debugPrint('🔐 Unauthorized - attempting token refresh...');
        
        final phoneNo = await getUserPhone();
        final roleId = await getUserRole();
        
        if (phoneNo != null && roleId != null) {
          debugPrint('🔄 Attempting token refresh with phone: $phoneNo, role: $roleId');
          final refreshResult = await refreshJwtToken(
            phoneNo: phoneNo, 
            roleId: roleId
          );
          
          if (refreshResult['success'] == true) {
            debugPrint('✅ Token refreshed successfully, retrying get job applicants...');
            
            final newToken = await _getStoredJwtToken();
            final retryResponse = await http.post(
              url,
              headers: {
                'Authorization': 'Bearer $newToken',
                'Accept': '*/*',
                'Content-Type': 'application/json',
              },
              body: jsonEncode(requestBody),
            );
            
            debugPrint('🔄 Retry response status: ${retryResponse.statusCode}');
            debugPrint('🔄 Retry response body: ${retryResponse.body}');
            
            if (retryResponse.statusCode == 200) {
              if (retryResponse.body.isEmpty) {
                return {
                  'success': true,
                  'message': 'No applicants found',
                  'data': [],
                };
              }
              
              try {
                final responseData = jsonDecode(retryResponse.body);
                // Extract the data field from the response
                final List<dynamic> applicantsList = responseData['data'] ?? [];
                debugPrint('✅ Extracted ${applicantsList.length} applicants from retry response');
                
                return {
                  'success': true,
                  'message': 'Job applicants retrieved successfully',
                  'data': applicantsList,
                };
              } catch (e) {
                debugPrint('💥 JSON decode error on retry: $e');
                return {
                  'success': false,
                  'message': 'Error parsing response: ${e.toString()}',
                };
              }
            }
          }
        }
        
        return {
          'success': false,
          'message': 'Unauthorized - please login again',
        };
      } else {
        return {
          'success': false,
          'message': 'Failed to get job applicants: ${response.statusCode}',
        };
      }
    } catch (e) {
      debugPrint('💥 Exception getting job applicants: $e');
      return {
        'success': false,
        'message': 'Error getting job applicants: ${e.toString()}',
      };
    }
  }


}



class SubCategory {
  final int id;
  final String name;
  final String? description;
  final String? imageUrl;

  SubCategory({
    required this.id,
    required this.name,
    this.description,
    this.imageUrl,
  });

  factory SubCategory.fromJson(Map<String, dynamic> json) {
    return SubCategory(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id'].toString()) ?? 0,
      name: json['name'] ?? '',
      description: json['description'],
      imageUrl: json['imageUrl'],
    );
  }
}


