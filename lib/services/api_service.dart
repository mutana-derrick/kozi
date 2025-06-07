import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'dart:math' as math;

import 'package:kozi/dashboard/job_provider/models/service_category.dart';

class ApiService {
  // Base URL should point to your local server
  // For physical devices, use your computer's local IP address, not localhost
  static const String baseUrl = "http://192.168.1.82:3000";
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

  // Add this method to your ApiService class:
  Future<String?> getUserEmail() async {
    try {
      return await _storage.read(key: 'user_email');
    } catch (e) {
      print("Error reading user email from storage: $e");
      return null;
    }
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
        await _storage.write(key: 'auth_token', value: response.data['token']);
        await _storage.write(key: 'user_email', value: email);
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
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        return {
          'success': false,
          'message': 'Wrong email or password',
        };
      }
      print('Login error: $e');
      return {
        'success': false,
        'message': 'An unexpected error occurred',
      };
    } catch (e) {
      print('Login error: $e');
      return {
        'success': false,
        'message': 'An unexpected error occurred',
      };
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

//get category id by name
  Future<int?> getCategoryIdByName(String categoryName) async {
    try {
      final response = await _dio.get(
        '$baseUrl/category-by-name_mobile',
        queryParameters: {'name': categoryName},
        options: Options(
          headers: {
            'Authorization': 'Bearer ${await _storage.read(key: 'auth_token')}'
          },
        ),
      );

      if (response.statusCode == 200 && response.data != null) {
        return int.tryParse(response.data['id'].toString());
      }

      // If no API endpoint exists, use hardcoded mapping for now (based on your screenshot)
      final Map<String, int> categoryMap = {
        'baby sitters': 5,
        'pool cleaners': 9,
        'pet sitters': 10,
        // Add more mappings as needed
      };

      return categoryMap[categoryName];
    } catch (e) {
      print('Error getting category ID: $e');
      return null;
    }
  }

// Method to load all categories and build a mapping
  Future<Map<String, int>> loadCategoryMapping() async {
    try {
      final response = await _dio.get(
        '$baseUrl/category-types-with-categories',
        options: Options(
          headers: {
            'Authorization': 'Bearer ${await _storage.read(key: 'auth_token')}'
          },
        ),
      );

      if (response.statusCode == 200 && response.data != null) {
        final Map<String, int> mapping = {};

        final List<dynamic> categoryTypes = response.data;
        for (final typeData in categoryTypes) {
          final List<dynamic> categories = typeData['categories'] ?? [];
          for (final category in categories) {
            mapping[category['name']] = category['id'];
          }
        }

        return mapping;
      }

      return {};
    } catch (e) {
      print('Error loading category mapping: $e');
      return {};
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
          'message': 'Signup successful. Please verify your email.',
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

  // Verify OTP method
  Future<Map<String, dynamic>> verifyOtp(String email, String otp) async {
    try {
      final response = await _dio.post(
        '$baseUrl/seeker/verify-otp',
        data: {
          'email': email,
          'otp': otp,
        },
      );

      if (response.statusCode == 200) {
        return {
          'success': true,
          'message': 'Email verified successfully!',
          'data': response.data
        };
      } else {
        return {
          'success': false,
          'message': response.data['message'] ?? 'Verification failed',
          'data': response.data
        };
      }
    } catch (e) {
      print('OTP verification error: $e');

      String errorMessage = 'Network error occurred';
      if (e is DioException) {
        if (e.response?.statusCode == 400) {
          errorMessage = e.response?.data?['message'] ?? 'Invalid OTP';
        }
      }

      return {'success': false, 'message': errorMessage, 'error': e.toString()};
    }
  }

  // Resend OTP method
  Future<Map<String, dynamic>> resendOtp(String email) async {
    try {
      final response = await _dio.post(
        '$baseUrl/seeker/resend-otp',
        data: {
          'email': email,
        },
      );

      if (response.statusCode == 200) {
        return {
          'success': true,
          'message': 'New OTP sent successfully!',
          'data': response.data
        };
      } else {
        return {
          'success': false,
          'message': response.data['message'] ?? 'Failed to resend OTP',
          'data': response.data
        };
      }
    } catch (e) {
      print('Resend OTP error: $e');

      String errorMessage = 'Network error occurred';
      if (e is DioException) {
        if (e.response?.statusCode == 400) {
          errorMessage = e.response?.data?['message'] ?? 'Email not found';
        }
      }

      return {'success': false, 'message': errorMessage, 'error': e.toString()};
    }
  }

  // Forgot password method
  Future<Map<String, dynamic>> forgotPassword(String email) async {
    try {
      final response = await _dio.post(
        '$baseUrl/seeker/forgot-password',
        data: {
          'email': email,
        },
      );

      if (response.statusCode == 200) {
        return {
          'success': true,
          'message': 'OTP sent to your email.',
          'data': response.data
        };
      } else {
        return {
          'success': false,
          'message': response.data['message'] ?? 'Failed to process request',
          'data': response.data
        };
      }
    } catch (e) {
      print('Forgot password error: $e');

      String errorMessage = 'Network error occurred';
      if (e is DioException) {
        if (e.response?.statusCode == 404) {
          errorMessage = 'Email not found';
        }
      }

      return {'success': false, 'message': errorMessage, 'error': e.toString()};
    }
  }

  // Verify forgot password OTP
  Future<Map<String, dynamic>> verifyForgotPasswordOtp(String email, String otp,
      {bool resend = false}) async {
    try {
      final response = await _dio.post(
        '$baseUrl/seeker/verify-forgot-otp',
        data: {
          'email': email,
          'otp': otp,
          'resend': resend,
        },
      );

      if (response.statusCode == 200) {
        return {
          'success': true,
          'message': resend
              ? 'New OTP has been sent to your email.'
              : 'OTP verified. You can now reset your password.',
          'data': response.data
        };
      } else {
        return {
          'success': false,
          'message': response.data['message'] ?? 'Verification failed',
          'data': response.data
        };
      }
    } catch (e) {
      print('Verify forgot password OTP error: $e');

      String errorMessage = 'Network error occurred';
      if (e is DioException) {
        if (e.response?.statusCode == 400) {
          errorMessage = e.response?.data?['message'] ?? 'Invalid OTP';
          // Check if OTP expired
          if (e.response?.data?['expired'] == true) {
            errorMessage = 'OTP expired. Please request a new one.';
          }
        } else if (e.response?.statusCode == 404) {
          errorMessage = 'Email not found';
        }
      }

      return {'success': false, 'message': errorMessage, 'error': e.toString()};
    }
  }

  // Reset password
  Future<Map<String, dynamic>> resetPassword(
      String email, String newPassword) async {
    try {
      final response = await _dio.post(
        '$baseUrl/seeker/password-change',
        data: {
          'email': email,
          'newPassword': newPassword,
        },
      );

      if (response.statusCode == 200) {
        return {
          'success': true,
          'message': 'Password changed successfully. You can now log in.',
          'data': response.data
        };
      } else {
        return {
          'success': false,
          'message': response.data['message'] ?? 'Failed to change password',
          'data': response.data
        };
      }
    } catch (e) {
      print('Reset password error: $e');

      String errorMessage = 'Network error occurred';
      if (e is DioException) {
        errorMessage =
            e.response?.data?['message'] ?? 'Failed to change password';
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
      final token = await _storage.read(key: 'auth_token');
      if (token == null) {
        return {
          'success': false,
          'message': 'Not authenticated',
        };
      }

      final response = await _dio.get(
        '$baseUrl/seeker/view_profile/$userId',
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
          },
        ),
      );

      if (response.statusCode == 200) {
        // Log the response data to debug
        print('Profile data: ${response.data}');

        // Make sure job_seeker_id is included in the returned data
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
      // Log the data being sent for debugging
      print('Updating profile for user $userId with data: $data');

      // Create FormData for file uploads
      final formData = FormData();

      // Add text fields
      data.forEach((key, value) {
        if (key != 'image' && key != 'id' && key != 'cv') {
          if (value != null) {
            print('Adding field: $key = $value');
            formData.fields.add(MapEntry(key, value.toString()));
          } else {
            print('Warning: Field $key is null');
          }
        }
      });

      // Add image files if present
      if (data['image'] != null && data['image'].toString().isNotEmpty) {
        print('Adding image file: ${data['image']}');
        try {
          formData.files.add(MapEntry(
            'image',
            await MultipartFile.fromFile(data['image'],
                filename: data['image'].split('/').last),
          ));
        } catch (e) {
          print('Error adding image file: $e');
          throw Exception('Failed to process image file: $e');
        }
      } else {
        print('Warning: No image file provided');
      }

      if (data['id'] != null && data['id'].toString().isNotEmpty) {
        print('Adding ID file: ${data['id']}');
        try {
          formData.files.add(MapEntry(
            'id',
            await MultipartFile.fromFile(data['id'],
                filename: data['id'].split('/').last),
          ));
        } catch (e) {
          print('Error adding ID file: $e');
          throw Exception('Failed to process ID file: $e');
        }
      } else {
        print('Warning: No ID file provided');
      }

      if (data['cv'] != null && data['cv'].toString().isNotEmpty) {
        print('Adding CV file: ${data['cv']}');
        try {
          formData.files.add(MapEntry(
            'cv',
            await MultipartFile.fromFile(data['cv'],
                filename: data['cv'].split('/').last),
          ));
        } catch (e) {
          print('Error adding CV file: $e');
          throw Exception('Failed to process CV file: $e');
        }
      } else {
        print('Warning: No CV file provided');
      }

      // Get the auth token
      final token = await _storage.read(key: 'auth_token');
      if (token == null) {
        print('Error: No auth token found');
        return {
          'success': false,
          'message': 'Authentication token not found',
        };
      }

      // Log the request URL and headers
      print(
          'Making PUT request to: $baseUrl/seeker/update_profile_mobile/$userId');
      print('With token: ${token.substring(0, math.min(10, token.length))}...');

      // Add more detailed error handling
      try {
        final response = await _dio.put(
          '$baseUrl/seeker/update_profile_mobile/$userId',
          data: formData,
          options: Options(
            headers: {
              'Authorization': 'Bearer $token',
              'Content-Type': 'multipart/form-data',
            },
          ),
        );

        print('Response status: ${response.statusCode}');
        print('Response data: ${response.data}');

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
      } on DioException catch (e) {
        // Log detailed Dio error information
        print('DioException during profile update:');
        print('  Status code: ${e.response?.statusCode}');
        print('  Response data: ${e.response?.data}');
        print('  Request data: ${e.requestOptions.data}');
        print('  Request path: ${e.requestOptions.path}');

        return {
          'success': false,
          'message':
              'Server error: ${e.response?.data?['message'] ?? e.message}',
          'details': e.response?.data,
        };
      }
    } catch (e) {
      print('Unhandled error updating profile: $e');
      return {
        'success': false,
        'message': 'An error occurred: $e',
      };
    }
  }

// job seeker Change password method
  Future<Map<String, dynamic>> changePassword(
      Map<String, dynamic> passwordData) async {
    try {
      final token = await _storage.read(key: 'auth_token');
      if (token == null) {
        return {'success': false, 'message': 'Not authenticated'};
      }

      // Note: The server uses the email from the JWT token, so we don't need to send it explicitly
      // We're only sending the passwords as required by the API endpoint
      final requestData = {
        'current_password': passwordData['current_password'],
        'new_password': passwordData['new_password'],
        'confirm_password':
            passwordData['new_password'], // Server requires this field
      };

      final response = await _dio.post(
        '$baseUrl/change-password', // Make sure this matches the exact endpoint path
        data: requestData,
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json'
          },
        ),
      );

      if (response.statusCode == 200 && response.data['success'] == true) {
        return {
          'success': true,
          'message': response.data['message'] ?? 'Password changed successfully'
        };
      } else {
        return {
          'success': false,
          'message': response.data['message'] ?? 'Failed to change password'
        };
      }
    } on DioException catch (e) {
      // Handle Dio-specific errors
      String errorMessage = 'Network error occurred';

      if (e.response != null) {
        if (e.response?.statusCode == 401) {
          errorMessage = 'Current password is incorrect';
        } else if (e.response?.statusCode == 400) {
          errorMessage = e.response?.data['message'] ?? 'Invalid request';
        } else if (e.response?.data != null &&
            e.response?.data['message'] != null) {
          errorMessage = e.response!.data['message'];
        }
      }

      return {'success': false, 'message': errorMessage};
    } catch (e) {
      return {'success': false, 'message': 'An error occurred: $e'};
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
        '$baseUrl/admin/select_jobss',
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
      print("Starting apply for job process for job ID: $jobId");

      // Check authentication
      final token = await _storage.read(key: 'auth_token');
      if (token == null) {
        print("No auth token found - user not authenticated");
        return {'success': false, 'message': 'Not authenticated'};
      }

      // Get email from storage
      final email = await _storage.read(key: 'user_email');
      if (email == null) {
        print("No user email found in storage");
        return {'success': false, 'message': 'User email not found'};
      }

      print("Found user email: $email");

      // Use email to get user ID
      print("Getting user ID for email: $email");
      final userId = await getUserIdByEmail(email);
      if (userId == null) {
        print("Failed to get user ID from email");
        return {'success': false, 'message': 'User ID not found'};
      }

      print("Successfully retrieved user ID: $userId");

      // Use user ID to get profile data
      print("Fetching user profile data");
      final profileResult = await getUserProfile(userId);

      if (!profileResult['success']) {
        print("Failed to fetch profile: ${profileResult['message']}");
        return {'success': false, 'message': 'Failed to fetch profile data'};
      }

      if (profileResult['data'] == null) {
        print("Profile data is null");
        return {'success': false, 'message': 'Profile data not found'};
      }

      // Extract job_seeker_id from profile data
      final profileData = profileResult['data'];
      print("Profile data: $profileData");

      // Try to use job_seeker_id if available, otherwise use userId as fallback
      final jobSeekerId = profileData['job_seeker_id'] ?? userId;
      print("Using job_seeker_id: $jobSeekerId");

      // Make the API call to apply for the job
      print("Making API request to apply for job");
      print("Request data: { job_id: $jobId, job_seeker_id: $jobSeekerId }");

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

      print("API response status: ${response.statusCode}");
      print("API response data: ${response.data}");

      if (response.statusCode == 201 || response.statusCode == 200) {
        print("Successfully applied for job");
        return {
          'success': true,
          'message': 'Successfully applied for job',
        };
      } else {
        print("Failed to apply for job");
        return {
          'success': false,
          'message': response.data['message'] ?? 'Failed to apply for job',
        };
      }
    } on DioException catch (e) {
      print("DioException occurred: ${e.message}");

      // On a 400 error, try one more time with integer format
      if (e.response?.statusCode == 400) {
        try {
          print("Got 400 error, trying with integer format");

          final token = await _storage.read(key: 'auth_token');
          final jobIdInt = int.tryParse(jobId);
          final userId = await getUserId();

          if (jobIdInt != null && userId != null) {
            final userIdInt = int.tryParse(userId);

            final response = await _dio.post(
              '$baseUrl/seeker/apply',
              data: {
                'job_id': jobIdInt,
                'job_seeker_id': userIdInt ?? userId,
              },
              options: Options(
                headers: {'Authorization': 'Bearer $token'},
              ),
            );

            if (response.statusCode == 201 || response.statusCode == 200) {
              print("Successfully applied for job with integer format");
              return {
                'success': true,
                'message': 'Successfully applied for job',
              };
            }
          }
        } catch (retryError) {
          print("Error during retry: $retryError");
        }
      }

      if (e.response?.statusCode == 409) {
        return {
          'success': false,
          'message': 'You have already applied for this job'
        };
      }

      return {
        'success': false,
        'message': 'Network error: ${e.message}',
      };
    } catch (e) {
      print("General exception occurred: $e");
      return {
        'success': false,
        'message': 'An error occurred: $e',
      };
    }
  }

// Additional method to submit detailed job application
  Future<Map<String, dynamic>> submitJobApplication(
      String jobId, Map<String, dynamic> applicationData) async {
    try {
      final token = await _storage.read(key: 'auth_token');
      if (token == null) {
        return {'success': false, 'message': 'Not authenticated'};
      }

      final userId = await getUserId();
      if (userId == null) {
        return {'success': false, 'message': 'User ID not found'};
      }

      // Add userId to application data
      applicationData['user_id'] = userId;
      applicationData['job_id'] = jobId;

      // Create form data for file uploads if needed
      final formData = FormData.fromMap(applicationData);

      // If there's a CV file to upload
      if (applicationData['cv_file'] != null) {
        formData.files.add(MapEntry(
          'cv_file',
          await MultipartFile.fromFile(
            applicationData['cv_file'],
            filename: applicationData['cv_file'].split('/').last,
          ),
        ));
      }

      final response = await _dio.post(
        '$baseUrl/seeker/submit_application',
        data: formData,
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'multipart/form-data',
          },
        ),
      );

      if (response.statusCode == 201) {
        return {
          'success': true,
          'message': 'Application submitted successfully',
          'data': response.data,
        };
      } else {
        return {
          'success': false,
          'message': response.data['message'] ?? 'Failed to submit application',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'An error occurred: $e',
      };
    }
  }

// Method to get user's applied jobs
  Future<List<Map<String, dynamic>>> getAppliedJobs() async {
    try {
      final token = await _storage.read(key: 'auth_token');
      if (token == null) {
        return [];
      }

      final userId = await getUserId();
      if (userId == null) {
        return [];
      }

      final response = await _dio.get(
        '$baseUrl/seeker/applied_jobs/$userId',
        options: Options(
          headers: {'Authorization': 'Bearer $token'},
        ),
      );

      if (response.statusCode == 200 && response.data != null) {
        final List<dynamic> appliedJobs = response.data;
        return appliedJobs
            .map((job) => Map<String, dynamic>.from(job))
            .toList();
      }

      return [];
    } catch (e) {
      print('Error fetching applied jobs: $e');
      return [];
    }
  }

// Method to check if user has applied for a specific job
  Future<bool> hasAppliedForJob(String jobId) async {
    try {
      final token = await _storage.read(key: 'auth_token');
      if (token == null) {
        return false;
      }

      final userId = await getUserId();
      if (userId == null) {
        return false;
      }

      final response = await _dio.get(
        '$baseUrl/seeker/check_application',
        queryParameters: {
          'user_id': userId,
          'job_id': jobId,
        },
        options: Options(
          headers: {'Authorization': 'Bearer $token'},
        ),
      );

      if (response.statusCode == 200 && response.data != null) {
        return response.data['applied'] == true;
      }

      return false;
    } catch (e) {
      print('Error checking job application status: $e');
      return false;
    }
  }
//=================================================================================================================================================
//jobprovider's apis consumption
// Add these methods to your existing ApiService class in lib/services/api_service.dart

// Job Provider Login
  Future<Map<String, dynamic>> loginJobProvider(
      String email, String password) async {
    try {
      final response = await _dio.post(
        '$baseUrl/login',
        data: {
          'email': email,
          'password': password,
          'role_id': 2, //2 is for job providers
        },
      );

      if (response.statusCode == 200 && response.data['token'] != null) {
        await _storage.write(key: 'auth_token', value: response.data['token']);
        await _storage.write(key: 'user_email', value: email);
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
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        return {
          'success': false,
          'message': 'Wrong email or password',
        };
      }
      print('Login error: $e');
      return {
        'success': false,
        'message': 'An unexpected error occurred',
      };
    } catch (e) {
      print('Login error: $e');
      return {
        'success': false,
        'message': 'An unexpected error occurred',
      };
    }
  }

// Job Provider Signup
  Future<Map<String, dynamic>> signupJobProvider(
      Map<String, dynamic> userData) async {
    try {
      final response = await _dio.post(
        '$baseUrl/provider/signup',
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

// Get Provider Profile
  Future<Map<String, dynamic>> getProviderProfile(String userId) async {
    try {
      final token = await _storage.read(key: 'auth_token');
      if (token == null) {
        return {
          'success': false,
          'message': 'Not authenticated',
        };
      }

      final response = await _dio.get(
        '$baseUrl/provider/view_profile/$userId',
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
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
      print('Error fetching provider profile: $e');
      return {
        'success': false,
        'message': 'An error occurred: $e',
      };
    }
  }

// Update Provider Profile
  Future<Map<String, dynamic>> updateProviderProfile(
      String userId, Map<String, dynamic> data) async {
    try {
      final token = await _storage.read(key: 'auth_token');
      if (token == null) {
        return {
          'success': false,
          'message': 'Not authenticated',
        };
      }

      // Handle profile image
      final formData = FormData();

      // Add text fields (excluding profileImagePath)
      data.forEach((key, value) {
        if (key != 'profileImagePath' &&
            value != null &&
            value.toString().isNotEmpty) {
          formData.fields.add(MapEntry(key, value.toString()));
        }
      });

      // Add profile image if available
      if (data['profileImagePath'] != null &&
          data['profileImagePath'].toString().isNotEmpty) {
        try {
          final imagePath = data['profileImagePath'].toString();
          final file = File(imagePath);

          // Check if file exists
          if (await file.exists()) {
            formData.files.add(MapEntry(
              'image', // This should match your backend field name
              await MultipartFile.fromFile(
                imagePath,
                filename: imagePath.split('/').last,
              ),
            ));
          } else {
            print('Profile image file does not exist: $imagePath');
          }
        } catch (e) {
          print('Error adding profile image file: $e');
        }
      }

      print('Sending data to API: ${formData.fields}');
      print('Sending files: ${formData.files.length} files');

      final response = await _dio.put(
        '$baseUrl/provider/update_profile/$userId',
        data: formData,
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'multipart/form-data',
          },
          validateStatus: (status) => status! < 500, // Accept 4xx status codes
        ),
      );

      print('API Response Status: ${response.statusCode}');
      print('API Response Data: ${response.data}');

      if (response.statusCode == 200) {
        return {
          'success': true,
          'message': response.data['message'] ?? 'Profile updated successfully',
        };
      } else {
        return {
          'success': false,
          'message': response.data['message'] ?? 'Failed to update profile',
        };
      }
    } catch (e) {
      print('Error updating provider profile: $e');
      if (e is DioException) {
        print('DioException details: ${e.response?.data}');
        return {
          'success': false,
          'message': e.response?.data['message'] ?? 'Network error occurred',
        };
      }
      return {
        'success': false,
        'message': 'An error occurred: $e',
      };
    }
  }

// Get All Job Seekers
  Future<List<Map<String, dynamic>>> getAllJobSeekers() async {
    try {
      final token = await _storage.read(key: 'auth_token');
      if (token == null) {
        return [];
      }

      final response = await _dio.get(
        '$baseUrl/provider/job_seekers',
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
      print('Error fetching job seekers: $e');
      return [];
    }
  }

// Get Job Seeker Detail
  Future<Map<String, dynamic>> getJobSeekerDetail(String seekerId) async {
    try {
      final token = await _storage.read(key: 'auth_token');
      if (token == null) {
        return {'success': false, 'message': 'Not authenticated'};
      }

      final response = await _dio.get(
        '$baseUrl/provider/job_seeker/$seekerId',
        options: Options(
          headers: {'Authorization': 'Bearer $token'},
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
          'message': 'Failed to fetch job seeker details',
        };
      }
    } catch (e) {
      print('Error fetching job seeker detail: $e');
      return {
        'success': false,
        'message': 'An error occurred: $e',
      };
    }
  }

// Hire Job Seeker
  Future<Map<String, dynamic>> hireJobSeeker(
      Map<String, dynamic> hireData) async {
    try {
      final token = await _storage.read(key: 'auth_token');
      if (token == null) {
        return {'success': false, 'message': 'Not authenticated'};
      }

      final response = await _dio.post(
        '$baseUrl/provider/hire',
        data: hireData,
        options: Options(
          headers: {'Authorization': 'Bearer $token'},
        ),
      );

      if (response.statusCode == 201) {
        return {
          'success': true,
          'message': 'Job seeker hired successfully',
          'data': response.data,
        };
      } else {
        return {
          'success': false,
          'message': response.data['message'] ?? 'Failed to hire job seeker',
        };
      }
    } catch (e) {
      print('Error hiring job seeker: $e');

      String errorMessage = 'An error occurred';
      if (e is DioException && e.response?.statusCode == 409) {
        errorMessage = 'You have already hired this job seeker';
      }

      return {
        'success': false,
        'message': errorMessage,
      };
    }
  }

//count jobseekers
  Future<int> getSeekersCount() async {
    try {
      final token = await _storage.read(key: 'auth_token');
      final response = await _dio.get(
        '$baseUrl/seekers/count',
        options: Options(
          headers: {'Authorization': 'Bearer $token'},
        ),
      );

      if (response.statusCode == 200) {
        return response.data['count'] ?? 0;
      }
      return 0;
    } catch (e) {
      print('Error fetching seekers count: $e');
      return 0;
    }
  }

//count companies
  Future<int> getCompanyProvidersCount() async {
    try {
      final token = await _storage.read(key: 'auth_token');
      final response = await _dio.get(
        '$baseUrl/providers/count',
        options: Options(
          headers: {'Authorization': 'Bearer $token'},
        ),
      );

      if (response.statusCode == 200) {
        return response.data['count'] ?? 0;
      }
      return 0;
    } catch (e) {
      print('Error fetching providers count: $e');
      return 0;
    }
  }

//count individuals
  Future<int> getIndividualProvidersCount() async {
    try {
      final token = await _storage.read(key: 'auth_token');
      final response = await _dio.get(
        '$baseUrl/providers/individual/count',
        options: Options(
          headers: {'Authorization': 'Bearer $token'},
        ),
      );

      if (response.statusCode == 200) {
        return response.data['count'] ?? 0;
      }
      return 0;
    } catch (e) {
      print('Error fetching providers count: $e');
      return 0;
    }
  }

  // Future<List<dynamic>> fetchCategories() async {
  //   final response = await _dio.get('$baseUrl/name_and_id');
  //   return response.data;
  // }

  // method to fetch worker details by ID
  Future<List<dynamic>> fetchWorkers() async {
    final response = await _dio.get('$baseUrl/provider/job_seekers');
    return response.data;
  }

  // method to fetch worker details by ID
  Future<Map<String, dynamic>> getWorkerById(String workerId) async {
    try {
      final response = await _dio.get('$baseUrl/provider/job_seeker/$workerId');

      if (response.statusCode == 200) {
        return response.data;
      } else if (response.statusCode == 404) {
        throw Exception('Worker not found');
      } else {
        throw Exception('Failed to load worker details');
      }
    } on DioException catch (e) {
      print('Error fetching worker details: $e');
      throw Exception('Failed to load worker details: ${e.message}');
    } catch (e) {
      print('Unexpected error fetching worker details: $e');
      throw Exception('An unexpected error occurred');
    }
  }

  Future<List<ServiceCategory>> fetchCategories() async {
    try {
      final response = await _dio.get('$baseUrl/name_and_id');

      if (response.statusCode == 200) {
        final List<dynamic> categoriesData = response.data;

        return categoriesData.map((category) {
          return ServiceCategory(
            id: category['id'].toString(),
            name: category['name'],
            icon: _mapIconToCategory(category['name']),
          );
        }).toList();
      } else {
        throw Exception('Failed to load categories');
      }
    } on DioException catch (e) {
      print('Error fetching categories: $e');
      throw Exception('Failed to load categories: ${e.message}');
    } catch (e) {
      print('Unexpected error fetching categories: $e');
      throw Exception('An unexpected error occurred');
    }
  }

// Fetch workers by category ID
  Future<List<dynamic>> fetchWorkersByCategory(String categoryId) async {
    try {
      final response =
          await _dio.get('$baseUrl/select_user_based_on_category/$categoryId');

      if (response.statusCode == 200) {
        return response.data;
      } else if (response.statusCode == 404) {
        // No workers found for this category
        return [];
      } else {
        throw Exception('Failed to load workers');
      }
    } on DioException catch (e) {
      print('Error fetching workers by category: $e');
      throw Exception('Failed to load workers: ${e.message}');
    } catch (e) {
      print('Unexpected error fetching workers: $e');
      throw Exception('An unexpected error occurred');
    }
  }

  // Method to fetch job provider id
  Future<int> getJobProviderId(int usersId) async {
    try {
      final response =
          await _dio.get('$baseUrl/provider/job_provider_id/$usersId');

      if (response.statusCode == 200 && response.data != null) {
        return response.data['job_provider_id'];
      } else {
        throw Exception('Job provider ID not found');
      }
    } on DioException catch (e) {
      print('Error fetching job_provider_id: $e');
      throw Exception('Failed to fetch job_provider_id: ${e.message}');
    } catch (e) {
      print('Unexpected error: $e');
      throw Exception('An unexpected error occurred');
    }
  }

  // Method to fetch job provider profile data
  Future<Map<String, dynamic>> fetchJobProviderProfile(int usersId) async {
    try {
      final response =
          await _dio.get('$baseUrl/provider/view_profile/$usersId');

      if (response.statusCode == 200) {
        return response.data;
      } else {
        throw Exception('Failed to fetch job provider profile');
      }
    } on DioException catch (e) {
      print('Dio error fetching job provider profile: $e');
      throw Exception('Failed to fetch job provider profile: ${e.message}');
    } catch (e) {
      print('Unexpected error fetching job provider profile: $e');
      throw Exception('An unexpected error occurred');
    }
  }

  Future<Map<String, dynamic>> getJobSeekerByUserId(String userId) async {
    final response = await _dio.get('$baseUrl/provider/job_seeker/$userId');
    if (response.statusCode == 200) {
      return response.data;
    } else {
      throw Exception('Failed to fetch job seeker by user ID');
    }
  }

// Method to hire a worker
  Future<Map<String, dynamic>> hireWorker({
    required String jobSeekerId,
    required String jobProviderId,
    required String providerFirstName,
    required String providerLastName,
    required String seekerFirstName,
    required String seekerLastName,
    required String whenNeedWorker,
    required String workingMode,
    required String accommodationPreference,
    required String jobDescription,
  }) async {
    try {
      final response = await _dio.post(
        '$baseUrl/provider/hire',
        data: {
          'job_seeker_id': jobSeekerId,
          'job_provider_id': jobProviderId,
          'provider_first_name': providerFirstName,
          'provider_last_name': providerLastName,
          'seeker_first_name': seekerFirstName,
          'seeker_last_name': seekerLastName,
          'when_need_worker': whenNeedWorker,
          'working_mode': workingMode,
          'accommodation_preference': accommodationPreference,
          'job_description': jobDescription,
        },
        options: Options(
          validateStatus: (status) {
            return status != null && status >= 200 && status <= 409;
          },
        ),
      );

      if (response.statusCode == 201) {
        return response.data;
      } else if (response.statusCode == 409) {
        // Return message from backend directly
        return {'status': 'conflict', 'message': response.data['message']};
      } else {
        throw Exception('Failed to hire worker');
      }
    } on DioException catch (e) {
      print('Error hiring worker: $e');
      throw Exception('Failed to hire worker: ${e.message}');
    } catch (e) {
      print('Unexpected error hiring worker: $e');
      throw Exception('An unexpected error occurred');
    }
  }

// Helper function to map category names to icons
  IconData _mapIconToCategory(String categoryName) {
    switch (categoryName.toLowerCase()) {
      case 'home service':
        return FontAwesomeIcons.house;
      case 'office cleaning':
      case 'pool cleaners':
        return FontAwesomeIcons.broom;
      case 'baby sitters':
      case 'babysitting':
        return FontAwesomeIcons.baby;
      case 'chefs service':
        return FontAwesomeIcons.utensils;
      case 'movers':
        return FontAwesomeIcons.truckMoving;
      case 'drivers':
        return FontAwesomeIcons.car;
      case 'gardeners':
        return FontAwesomeIcons.leaf;
      case 'electricians':
        return FontAwesomeIcons.plug;
      case 'plumbers':
        return FontAwesomeIcons.faucet;
      default:
        return FontAwesomeIcons.layerGroup;
    }
  }

  // Logout
  Future<void> logout() async {
    await _storage.delete(key: 'auth_token');
    await _storage.delete(key: 'user_id');
  }
}
