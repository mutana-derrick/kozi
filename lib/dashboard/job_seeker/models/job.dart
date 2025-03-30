// models/job.dart
import 'package:flutter/material.dart';

class Job {
  final String id; // Added id field
  final String title;
  final String company;
  final String description;
  final String? fullDescription; // Added optional field
  final String? companyDescription; // Added optional field
  final String companyLogo;
  final Color companyLogoColor;
  final double rating;
  final int views;
  
  Job({
    String? id, // Optional in constructor, but will be generated if not provided
    required this.title,
    required this.company,
    required this.description,
    this.fullDescription,
    this.companyDescription,
    required this.companyLogo,
    required this.companyLogoColor,
    required this.rating,
    required this.views,
  }) : id = id ?? _generateId(company, title); // Auto-generate ID if not provided
  
  // Helper method to generate an ID
  static String _generateId(String company, String title) {
    return '${company.toLowerCase().replaceAll(' ', '-')}-${title.toLowerCase().replaceAll(' ', '-')}-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}';
  }
}