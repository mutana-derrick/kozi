// Create a notifier class to handle the state
// lib/authentication/job_provider/providers/profile_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Profile state model
class ProviderProfileState {
  final String email;
  final String firstName;
  final String lastName;
  final String dateOfBirth;
  final String gender;
  final String province;
  final String district;
  final String sector;
  final String cell;
  final String village;
  final String telephone;
  final String password;
  final String id;
  final String description;
  final String profileImagePath; // Add this field
  final int currentStep;
  final bool isSubmitting;

  ProviderProfileState({
    this.email = '',
    this.firstName = '',
    this.lastName = '',
    this.dateOfBirth = 'DD/MM/YYYY',
    this.gender = '',
    this.province = '',
    this.district = '',
    this.sector = '',
    this.cell = '',
    this.village = '',
    this.telephone = '',
    this.password = '',
    this.id = '',
    this.description = '',
    this.profileImagePath = '', // Initialize it as empty
    this.currentStep = 0,
    this.isSubmitting = false,
  });

  ProviderProfileState copyWith({
    String? email,
    String? firstName,
    String? lastName,
    String? dateOfBirth,
    String? gender,
    String? province,
    String? district,
    String? sector,
    String? cell,
    String? village,
    String? telephone,
    String? password,
    String? id,
    String? description,
    String? profileImagePath, // Add it to the copyWith method
    int? currentStep,
    bool? isSubmitting,
  }) {
    return ProviderProfileState(
      email: email ?? this.email,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      gender: gender ?? this.gender,
      province: province ?? this.province,
      district: district ?? this.district,
      sector: sector ?? this.sector,
      cell: cell ?? this.cell,
      village: village ?? this.village,
      telephone: telephone ?? this.telephone,
      password: password ?? this.password,
      id: id ?? this.id,
      description: description ?? this.description,
      profileImagePath: profileImagePath ?? this.profileImagePath, // Include it in the return
      currentStep: currentStep ?? this.currentStep,
      isSubmitting: isSubmitting ?? this.isSubmitting,
    );
  }
}

// Profile notifier
class ProfileNotifier extends StateNotifier<ProviderProfileState> {
  ProfileNotifier() : super(ProviderProfileState());

  void updateEmail(String value) {
    state = state.copyWith(email: value);
  }

  void updateFirstName(String value) {
    state = state.copyWith(firstName: value);
  }

  void updateLastName(String value) {
    state = state.copyWith(lastName: value);
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

  void updateProfileImagePath(String value) {
  state = state.copyWith(profileImagePath: value);
}

  void updatePassword(String value) {
    state = state.copyWith(password: value);
  }

  void updateDescription(String value) {
    state = state.copyWith(description: value);
  }

  void updateId(String value) {
    state = state.copyWith(id: value);
  }

  void goToNextStep() {
    if (state.currentStep < 1) {
      state = state.copyWith(currentStep: state.currentStep + 1);
    }
  }

  void goToPreviousStep() {
    if (state.currentStep > 0) {
      state = state.copyWith(currentStep: state.currentStep - 1);
    }
  }

  void goToStep(int step) {
    if (step >= 0 && step <= 1) {
      state = state.copyWith(currentStep: step);
    }
  }
}

// Create a provider for the ProfileNotifier
final profileProvider =
    StateNotifierProvider<ProfileNotifier, ProviderProfileState>((ref) {
  return ProfileNotifier();
});