import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/user_profile_model.dart';

// Provider for user profile data
final userProfileProvider = Provider<UserProfile>((ref) {
  return UserProfile(
    name: 'Mutesi Allen',
    imageUrl: 'https://example.com/profile.jpg',
    age: 24,
    location: 'Kacyiru-Kg 6470',
    specialization: 'housekeeping and cleaning',
    rating: 4,
    contactNumber: '+250180000000',
    dateOfBirth: 'DD MM YYYY',
  );
});