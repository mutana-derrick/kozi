import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/user_profile.dart';

// Define a provider for user profile
final userProfileProvider = Provider<UserProfile>((ref) {
  return UserProfile(
    name: 'Mutesi Allen',
    imageUrl: 'assets/profile.png', // Local asset image
    age: 24,
    location: 'Kigali',
    specialization: 'Housekeeping and Cleaning',
    rating: 4,
  );
});
