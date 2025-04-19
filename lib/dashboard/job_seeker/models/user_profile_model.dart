class UserProfile {
  final String name;
  final String imageUrl;
  final int age;
  final String location;
  final String specialization;
  final int rating;
  final String contactNumber;
  final String dateOfBirth;

  UserProfile({
    required this.name,
    required this.imageUrl,
    required this.age,
    required this.location,
    required this.specialization,
    required this.rating,
    this.contactNumber = '+250180000000',
    this.dateOfBirth = 'DD MM YYYY',
  });
}