import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:url_launcher/url_launcher.dart' as url_launcher;
import 'package:url_launcher/url_launcher.dart';

// Advertisement data model
class Advertisement {
  final String image;
  final String url;
  final String title;

  Advertisement({
    required this.image,
    required this.url,
    required this.title,
  });
}

// Provider for advertisement data
final advertisementsProvider = Provider<List<Advertisement>>((ref) {
  return [
    Advertisement(
      image: 'assets/images/ads/simba.jpg',
      url: 'https://hydrostationers.rw/',
      title: 'Upcoming Job Fair',
    ),
    Advertisement(
      image: 'assets/images/ads/ilpd.jpg',
      url: 'https://www.ilpd.ac.rw/home',
      title: 'Professional Skills Workshop',
    ),
    Advertisement(
      image: 'assets/images/ads/bpr.jpg',
      url: 'https://bpr.rw/',
      title: 'Career Coaching Services',
    ),
  ];
});

// Provider for current ad index
final currentAdIndexProvider = StateProvider<int>((ref) => 0);

// URL launcher service
class UrlLauncherService {
  Future<bool> launchUrl(String urlString) async {
    final Uri url = Uri.parse(urlString);
    try {
      return await url_launcher.launchUrl(
        url,
        mode: LaunchMode.externalApplication,
      );
    } catch (e) {
      return false;
    }
  }
}

// Provider for URL launcher service
final urlLauncherProvider = Provider<UrlLauncherService>((ref) {
  return UrlLauncherService();
});

class AdvertisementCarousel extends ConsumerWidget {
  const AdvertisementCarousel({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final advertisements = ref.watch(advertisementsProvider);
    final urlLauncher = ref.read(urlLauncherProvider);

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          CarouselSlider(
            options: CarouselOptions(
              height: 75,
              autoPlay: true,
              autoPlayInterval: const Duration(seconds: 3),
              enlargeCenterPage: true,
              viewportFraction: 1,
              onPageChanged: (index, reason) {
                // Update current ad index when page changes
                ref.read(currentAdIndexProvider.notifier).state = index;
              },
            ),
            items: advertisements.map((ad) {
              return Builder(
                builder: (BuildContext context) {
                  return GestureDetector(
                    onTap: () async {
                      final success = await urlLauncher.launchUrl(ad.url);
                      if (!success && context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Could not launch ${ad.url}')),
                        );
                      }
                    },
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(9),
                      child: Image.asset(
                        ad.image,
                        fit: BoxFit.fill,
                      ),
                    ),
                  );
                },
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}
