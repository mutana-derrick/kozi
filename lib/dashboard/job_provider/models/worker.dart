class Worker {
  final String id;
  final String name;
  final String specialty;
  final String imageUrl;
  final double rating; 
  final double? hourlyRate;
  // Additional fields from API
  final String? experience;
  final String? education;
  final String? location;
  final String? about;
  final String? telephone;
  final String? province;
  final String? district;
  final String? sector;
  final String? cell;
  final String? village;

  Worker({
    required this.id,
    required this.name,
    required this.specialty,
    required this.imageUrl,
    required this.rating,
    this.hourlyRate,
    this.experience,
    this.education,
    this.location,
    this.about,
    this.telephone,
    this.province,
    this.district,
    this.sector,
    this.cell,
    this.village,
  });
}