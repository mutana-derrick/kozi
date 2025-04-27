// models/job.dart
import 'package:flutter/material.dart';
import 'package:kozi/utils/text_utils.dart';

class Job {
  final String id;
  final String title;
  final String company;
  final String description;
  final String? fullDescription;
  final String? companyDescription;
  final String companyLogo;
  final Color companyLogoColor;
  final double rating;
  final int views;
  final String? category;
  final String? location; // Added location field
  final String? publishedDate; // Added published date
  final String? deadlineDate; // Added deadline date

  Job({
    String? id,
    required this.title,
    required this.company,
    required this.description,
    this.fullDescription,
    this.companyDescription,
    required this.companyLogo,
    required this.companyLogoColor,
    required this.rating,
    required this.views,
    this.category,
    this.location,
    this.publishedDate,
    this.deadlineDate,
  }) : id = id ?? _generateId(company, title);

  // Helper method to generate an ID
  static String _generateId(String company, String title) {
    return '${company.toLowerCase().replaceAll(' ', '-')}-${title.toLowerCase().replaceAll(' ', '-')}-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}';
  }

  // Factory constructor to create a Job from API data
  factory Job.fromApi(Map<String, dynamic> data) {
  return Job(
    id: data['job_id']?.toString() ?? '',
    title: data['job_title'] ?? 'Untitled Job',
    company: data['company'] ?? 'Unknown Company',
    // Clean description at the model level (can also be done in UI)
    description: TextUtils.cleanHtmlText(data['job_description']),
    fullDescription: TextUtils.cleanHtmlText(data['job_description']),
    companyDescription: 'Company specializing in their field',
    companyLogo: (data['company'] ?? 'C').isNotEmpty 
        ? (data['company'] ?? 'C')[0].toUpperCase()
        : 'C',
    companyLogoColor: _getColorForCompany(data['company'] ?? ''),
    rating: 4.5,
    views: 100,
    location: data['location'],
    publishedDate: data['published_date'],
    deadlineDate: data['deadline_date'],
  );
}

  // Helper method to generate color based on company name
  static Color _getColorForCompany(String company) {
    if (company.isEmpty) return Colors.blueGrey;

    // Generate a color based on the first character of the company name
    final int charCode = company.toLowerCase().codeUnitAt(0);
    final hue = (charCode % 360).toDouble();

    return HSLColor.fromAHSL(1.0, hue, 0.6, 0.8).toColor();
  }
}
