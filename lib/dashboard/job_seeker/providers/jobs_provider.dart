import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/job.dart';

final jobsProvider = Provider<List<Job>>((ref) {
  return [
    Job(
      title: 'Country Manager',
      company: 'Yellow',
      description: 'Yellow\'s purpose is to make life...',
      companyLogo: 'Y',
      companyLogoColor: Colors.amber,
      rating: 2.8,
      views: 2821,
    ),
    Job(
      title: 'Marketing Manager',
      company: 'Sanson Group',
      description: 'Sanson Group is a IT Consultan......',
      companyLogo: 'S',
      companyLogoColor: Colors.blue.shade200,
      rating: 2.8,
      views: 2821,
    ),
    Job(
      title: 'Marketing Manager',
      company: 'Sanson Group',
      description: 'Sanson Group is a IT Consultan......',
      companyLogo: 'S',
      companyLogoColor: Colors.blue.shade200,
      rating: 2.8,
      views: 2821,
    )
  ];
});
