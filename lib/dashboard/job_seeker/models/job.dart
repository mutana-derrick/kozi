import 'package:flutter/material.dart';

class Job {
  final String title;
  final String company;
  final String description;
  final String companyLogo;
  final Color companyLogoColor;
  final double rating;
  final int views;

  Job({
    required this.title,
    required this.company,
    required this.description,
    required this.companyLogo,
    required this.companyLogoColor,
    required this.rating,
    required this.views,
  });
}