// Define the profile state data class
class ProfileState {
  final String firstName;
  final String lastName;
  final String fathersName;
  final String mothersName;
  final String dateOfBirth;
  final String gender;
  final String province;
  final String district;
  final String sector;
  final String village;
  final String cell;
  final String telephone;
  final String disability;
  final String expectedSalary;
  final String category;
  final String skills;
  final String newIdCardPath;
  final String profileImagePath;
  final String cvPath;
  final bool isSubmitting;
  final int currentStep;

  ProfileState({
    this.firstName = '',
    this.lastName = '',
    this.fathersName = '',
    this.mothersName = '',
    this.dateOfBirth = 'DD/MM/YYYY',
    this.gender = 'select gender',
    this.province = '',
    this.district = '',
    this.sector = '',
    this.village = '',
    this.cell = '',
    this.telephone = '',
    this.disability = 'None',
    this.expectedSalary = 'select range',
    this.category = 'select category',
    this.skills = '',
    this.newIdCardPath = '',
    this.profileImagePath = '',
    this.cvPath = '',
    this.isSubmitting = false,
    this.currentStep = 0,
  });

  // Create a copy of the current state with some values modified
  ProfileState copyWith({
    String? firstName,
    String? lastName,
    String? fathersName,
    String? mothersName,
    String? dateOfBirth,
    String? gender,
    String? province,
    String? district,
    String? sector,
    String? village,
    String? cell,
    String? telephone,
    String? disability,
    String? expectedSalary,
    String? category,
    String? skills,
    String? newIdCardPath,
    String? profileImagePath,
    String? cvPath,
    bool? isSubmitting,
    int? currentStep,
  }) {
    return ProfileState(
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      fathersName: fathersName ?? this.fathersName,
      mothersName: mothersName ?? this.mothersName,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      gender: gender ?? this.gender,
      province: province ?? this.province,
      district: district ?? this.district,
      sector: sector ?? this.sector,
      village: village ?? this.village,
      cell: cell ?? this.cell,
      telephone: telephone ?? this.telephone,
      disability: disability ?? this.disability,
      expectedSalary: expectedSalary ?? this.expectedSalary,
      category: category ?? this.category,
      skills: skills ?? this.skills,
      newIdCardPath: newIdCardPath ?? this.newIdCardPath,
      profileImagePath: profileImagePath ?? this.profileImagePath,
      cvPath: cvPath ?? this.cvPath,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      currentStep: currentStep ?? this.currentStep,
    );
  }
}
