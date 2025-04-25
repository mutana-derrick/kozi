import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class ApiService {
  // Base URL should point to your local server
  // For physical devices, use your computer's local IP address, not localhost
  static const String baseUrl = "http://192.168.0.106:3000";
  final Dio _dio = Dio();
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  // Constructor sets up Dio interceptors for authentication
  ApiService() {
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          // Add authentication token to each request if available
          final token = await _storage.read(key: 'auth_token');
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          return handler.next(options);
        },
        onError: (DioException error, handler) {
          // Handle authentication errors
          if (error.response?.statusCode == 401) {
            // Token expired or invalid - could navigate to login screen
            print('Authentication error: Token may be expired');
            // Clear the invalid token
            _storage.delete(key: 'auth_token');
          }
          return handler.next(error);
        },
      ),
    );
  }

  // Job Seeker Login
  Future<Map<String, dynamic>> loginJobSeeker(
      String email, String password) async {
    try {
      final response = await _dio.post(
        '$baseUrl/login',
        data: {
          'email': email,
          'password': password,
          'role_id': 1,
        },
      );

      if (response.statusCode == 200 && response.data['token'] != null) {
        // Store the token securely
        await _storage.write(key: 'auth_token', value: response.data['token']);
        // Store the email for user ID retrieval
        await _storage.write(key: 'user_email', value: email);

        // Get user ID immediately after login
        final userId = await getUserIdByEmail(email);

        return {
          'success': true,
          'message': 'Login successful',
          'userId': userId,
          'data': response.data
        };
      } else {
        return {
          'success': false,
          'message': 'Login failed',
          'data': response.data
        };
      }
    } catch (e) {
      print('Login error: $e');
      return {'success': false, 'message': 'An error occurred: $e'};
    }
  }

  // getUserIdByEmail
  Future<String?> getUserIdByEmail(String email) async {
    try {
      final token = await _storage.read(key: 'auth_token');
      if (token == null) return null;

      final response = await _dio.get(
        '$baseUrl/get_user_id_by_email/$email',
        options: Options(
          headers: {'Authorization': 'Bearer $token'},
        ),
      );

      if (response.statusCode == 200 &&
          response.data != null &&
          response.data['users_id'] != null) {
        final userId = response.data['users_id'].toString();
        // Store it for future use
        await _storage.write(key: 'user_id', value: userId);
        print("Retrieved user ID by email: $userId");
        return userId;
      } else {
        print("Failed to get user ID by email. Response: ${response.data}");
        return null;
      }
    } catch (e) {
      print("Error getting user ID by email: $e");
      return null;
    }
  }

  // Job Seeker Signup
  Future<Map<String, dynamic>> signupJobSeeker(
      Map<String, dynamic> userData) async {
    try {
      final response = await _dio.post(
        '$baseUrl/seeker/signup',
        data: userData,
      );

      if (response.statusCode == 200) {
        return {
          'success': true,
          'message': 'Signup successful',
          'data': response.data
        };
      } else {
        return {
          'success': false,
          'message': 'Signup failed',
          'data': response.data
        };
      }
    } catch (e) {
      print('Signup error: $e');
      String errorMessage = 'Network error occurred';

      if (e is DioException) {
        if (e.response?.statusCode == 400) {
          errorMessage = e.response?.data?['message'] ?? 'Invalid signup data';
        } else if (e.response?.statusCode == 409) {
          errorMessage = 'Email already exists';
        }
      }

      return {'success': false, 'message': errorMessage, 'error': e.toString()};
    }
  }

  // Check if user is logged in
  Future<bool> isLoggedIn() async {
    final token = await _storage.read(key: 'auth_token');
    return token != null;
  }

  // Get the current user ID
  Future<String?> getUserId() async {
    // First try to get from storage
    final storedId = await _storage.read(key: 'user_id');
    if (storedId != null) return storedId;

    // If not in storage, try to get by email
    final email = await _storage.read(key: 'user_email');
    if (email != null) {
      return await getUserIdByEmail(email);
    }

    return null;
  }

  // Get user profile
  Future<Map<String, dynamic>> getUserProfile(String userId) async {
    try {
      final response = await _dio.get(
        '$baseUrl/seeker/view_profile/$userId',
        options: Options(
          headers: {
            'Authorization': 'Bearer ${await _storage.read(key: 'auth_token')}'
          },
        ),
      );

      if (response.statusCode == 200) {
        return {
          'success': true,
          'data': response.data,
        };
      } else {
        return {
          'success': false,
          'message': 'Failed to fetch profile',
        };
      }
    } catch (e) {
      print('Error fetching user profile: $e');
      return {
        'success': false,
        'message': 'An error occurred: $e',
      };
    }
  }

// Update profile
  Future<Map<String, dynamic>> updateUserProfile(
      String userId, Map<String, dynamic> data) async {
    try {
      // Create FormData for file uploads
      final formData = FormData();

      // Add text fields
      data.forEach((key, value) {
        if (key != 'image' && key != 'id' && key != 'cv') {
          formData.fields.add(MapEntry(key, value.toString()));
        }
      });

      // Add image files if present
      if (data['image'] != null && data['image'].toString().isNotEmpty) {
        formData.files.add(MapEntry(
          'image',
          await MultipartFile.fromFile(data['image'],
              filename: data['image'].split('/').last),
        ));
      }

      if (data['id'] != null && data['id'].toString().isNotEmpty) {
        formData.files.add(MapEntry(
          'id',
          await MultipartFile.fromFile(data['id'],
              filename: data['id'].split('/').last),
        ));
      }

      if (data['cv'] != null && data['cv'].toString().isNotEmpty) {
        formData.files.add(MapEntry(
          'cv',
          await MultipartFile.fromFile(data['cv'],
              filename: data['cv'].split('/').last),
        ));
      }

      final response = await _dio.put(
        '$baseUrl/seeker/update_profile/$userId',
        data: formData,
        options: Options(
          headers: {
            'Authorization': 'Bearer ${await _storage.read(key: 'auth_token')}',
            'Content-Type': 'multipart/form-data',
          },
        ),
      );

      if (response.statusCode == 200) {
        return {
          'success': true,
          'message': 'Profile updated successfully',
        };
      } else {
        return {
          'success': false,
          'message': response.data['message'] ?? 'Failed to update profile',
        };
      }
    } catch (e) {
      print('Error updating profile: $e');
      return {
        'success': false,
        'message': 'An error occurred: $e',
      };
    }
  }

  // Get categories from the API
  Future<List<Map<String, dynamic>>> getCategories() async {
    try {
      final token = await _storage.read(key: 'auth_token');
      if (token == null) {
        return [];
      }

      final response = await _dio.get(
        '$baseUrl/category-types-with-categories',
        options: Options(
          headers: {'Authorization': 'Bearer $token'},
        ),
      );

      if (response.statusCode == 200 && response.data != null) {
        // Parse the response data as List<Map<String, dynamic>>
        final List<dynamic> rawData = response.data;
        return rawData.map((item) => Map<String, dynamic>.from(item)).toList();
      }

      return [];
    } catch (e) {
      print('Error fetching categories: $e');
      // Return an empty list as fallback
      return [];
    }
  }

// Add this method to get a specific category type
  Future<Map<String, dynamic>?> getCategoryType(String typeId) async {
    try {
      final token = await _storage.read(key: 'auth_token');
      if (token == null) {
        return null;
      }

      final response = await _dio.get(
        '$baseUrl/category-types/$typeId',
        options: Options(
          headers: {'Authorization': 'Bearer $token'},
        ),
      );

      if (response.statusCode == 200 && response.data != null) {
        return Map<String, dynamic>.from(response.data);
      }

      return null;
    } catch (e) {
      print('Error fetching category type: $e');
      return null;
    }
  }

// Add this method to get categories by type
  Future<List<Map<String, dynamic>>> getCategoriesByType(String typeId) async {
    try {
      final token = await _storage.read(key: 'auth_token');
      if (token == null) {
        return [];
      }

      final response = await _dio.get(
        '$baseUrl/categories/$typeId',
        options: Options(
          headers: {'Authorization': 'Bearer $token'},
        ),
      );

      if (response.statusCode == 200 && response.data != null) {
        final List<dynamic> rawData = response.data;
        return rawData.map((item) => Map<String, dynamic>.from(item)).toList();
      }

      return [];
    } catch (e) {
      print('Error fetching categories by type: $e');
      return [];
    }
  }

// Get user profile progress
  Future<Map<String, dynamic>> getProfileProgress(String userId) async {
    try {
      final token = await _storage.read(key: 'auth_token');
      if (token == null) {
        return {'success': false, 'message': 'Not authenticated'};
      }

      final response = await _dio.get(
        '$baseUrl/progress/$userId',
        options: Options(
          headers: {'Authorization': 'Bearer $token'},
        ),
      );

      if (response.statusCode == 200) {
        return {
          'success': true,
          'progress': response.data['progress'],
        };
      } else {
        return {
          'success': false,
          'message': 'Failed to fetch progress',
        };
      }
    } catch (e) {
      print('Error fetching profile progress: $e');
      return {
        'success': false,
        'message': 'An error occurred: $e',
      };
    }
  }

// Get all jobs
  Future<List<Map<String, dynamic>>> getJobs() async {
    try {
      final token = await _storage.read(key: 'auth_token');
      if (token == null) {
        return [];
      }

      final response = await _dio.get(
        '$baseUrl/admin/select_jobs',
        options: Options(
          headers: {'Authorization': 'Bearer $token'},
        ),
      );

      if (response.statusCode == 200 && response.data != null) {
        final List<dynamic> rawData = response.data;
        return rawData.map((item) => Map<String, dynamic>.from(item)).toList();
      }

      return [];
    } catch (e) {
      print('Error fetching jobs: $e');
      return [];
    }
  }

// Apply for a job
  Future<Map<String, dynamic>> applyForJob(String jobId) async {
    try {
      final token = await _storage.read(key: 'auth_token');
      if (token == null) {
        return {'success': false, 'message': 'Not authenticated'};
      }

      final userId = await getUserId();
      if (userId == null) {
        return {'success': false, 'message': 'User ID not found'};
      }

      // Get job_seeker_id from profile
      final profileResult = await getUserProfile(userId);
      if (!profileResult['success'] || profileResult['data'] == null) {
        return {'success': false, 'message': 'Failed to fetch profile'};
      }

      final jobSeekerId = profileResult['data']['job_seeker_id'];
      if (jobSeekerId == null) {
        return {'success': false, 'message': 'Job seeker ID not found'};
      }

      final response = await _dio.post(
        '$baseUrl/seeker/apply',
        data: {
          'job_id': jobId,
          'job_seeker_id': jobSeekerId,
        },
        options: Options(
          headers: {'Authorization': 'Bearer $token'},
        ),
      );

      if (response.statusCode == 201) {
        return {
          'success': true,
          'message': 'Successfully applied for job',
        };
      } else {
        return {
          'success': false,
          'message': response.data['message'] ?? 'Failed to apply for job',
        };
      }
    } catch (e) {
      print('Error applying for job: $e');
      return {
        'success': false,
        'message': 'An error occurred: $e',
      };
    }
  }

  // Logout
  Future<void> logout() async {
    await _storage.delete(key: 'auth_token');
    await _storage.delete(key: 'user_id');
  }
}
