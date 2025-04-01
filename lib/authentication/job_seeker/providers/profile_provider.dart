import 'package:flutter_riverpod/flutter_riverpod.dart';
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
    // Set submitting state to true
    state = state.copyWith(isSubmitting: true);

    try {
      // TODO: Implement actual API call
      // For now, simulate a network request
      await Future.delayed(const Duration(seconds: 1));

      // Set submitting state to false
      state = state.copyWith(isSubmitting: false);
      return true;
    } catch (e) {
      // Set submitting state to false and handle error
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