import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kozi/services/api_service.dart';
import '../models/profile_model.dart';

// Create a notifier class to handle the state
class ProfileNotifier extends StateNotifier<ProfileState> {
  ProfileNotifier() : super(ProfileState());

  void updateFirstName(String value) {
    state = state.copyWith(firstName: value);
  }

  void updateLastName(String value) {
    state = state.copyWith(lastName: value);
  }

  void updateFathersName(String value) {
    state = state.copyWith(fathersName: value);
  }

  void updateMothersName(String value) {
    state = state.copyWith(mothersName: value);
  }

  void updateDateOfBirth(String value) {
    state = state.copyWith(dateOfBirth: value);
  }

  void updateGender(String value) {
    state = state.copyWith(gender: value);
  }

  void updateProvince(String value) {
    state = state.copyWith(province: value);
  }

  void updateDistrict(String value) {
    state = state.copyWith(district: value);
  }

  void updateSector(String value) {
    state = state.copyWith(sector: value);
  }

  void updateVillage(String value) {
    state = state.copyWith(village: value);
  }

  void updateCell(String value) {
    state = state.copyWith(cell: value);
  }

  void updateTelephone(String value) {
    state = state.copyWith(telephone: value);
  }

  void updateDisability(String value) {
    state = state.copyWith(disability: value);
  }

  void updateExpectedSalary(String value) {
    state = state.copyWith(expectedSalary: value);
  }

  void updateCategory(String value) {
    state = state.copyWith(category: value);
  }

  void updateSkills(String value) {
    state = state.copyWith(skills: value);
  }

  void updateNewIdCardPath(String value) {
    state = state.copyWith(newIdCardPath: value);
  }

  void updateProfileImagePath(String value) {
    state = state.copyWith(profileImagePath: value);
  }

  void updateCvPath(String value) {
    state = state.copyWith(cvPath: value);
  }

  void goToNextStep() {
    if (state.currentStep < 2) {
      state = state.copyWith(currentStep: state.currentStep + 1);
    }
  }

  void goToPreviousStep() {
    if (state.currentStep > 0) {
      state = state.copyWith(currentStep: state.currentStep - 1);
    }
  }

  void goToStep(int step) {
    if (step >= 0 && step <= 2) {
      state = state.copyWith(currentStep: step);
    }
  }

  // Method to submit profile data to backend
  Future<bool> submitProfile() async {
    state = state.copyWith(isSubmitting: true);

    try {
      // Get API service (however you access it in your app)
      final apiService = ApiService();

      // Get user ID
      final userId = await apiService.getUserId();
      if (userId == null) {
        state = state.copyWith(isSubmitting: false);
        return false;
      }

      // Get category ID from the selected category name
      final categoryMapping = await apiService.loadCategoryMapping();
      final categoryId = categoryMapping[state.category];

      if (categoryId == null) {
        print('Could not find ID for category: ${state.category}');
        state = state.copyWith(isSubmitting: false);
        return false;
      }

      // Create data for API request
      final data = {
        'first_name': state.firstName,
        'last_name': state.lastName,
        'gender': state.gender,
        'fathers_name': state.fathersName,
        'mothers_name': state.mothersName,
        'telephone': state.telephone,
        'province': state.province,
        'district': state.district,
        'sector': state.sector,
        'cell': state.cell,
        'village': state.village,
        'bio': state.skills,
        'salary': state.expectedSalary,
        'date_of_birth': state.dateOfBirth,
        'disability': state.disability,
        'categories_id': categoryId.toString(), // Send the ID, not the name
        'category': state.category,
        'image': state.profileImagePath,
        'id': state.newIdCardPath,
        'cv': state.cvPath,
      };

      // Send update request
      final result = await apiService.updateUserProfile(userId, data);

      state = state.copyWith(isSubmitting: false);
      return result['success'] == true;
    } catch (e) {
      print('Error during profile submission: $e');
      state = state.copyWith(isSubmitting: false);
      return false;
    }
  }
}

// Create a provider for the ProfileNotifier
final profileProvider =
    StateNotifierProvider<ProfileNotifier, ProfileState>((ref) {
  return ProfileNotifier();
});
