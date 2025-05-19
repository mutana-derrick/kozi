import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kozi/authentication/job_provider/providers/auth_provider.dart';
import 'package:kozi/dashboard/job_provider/models/worker.dart';
import 'package:kozi/services/api_service.dart';
import 'package:kozi/dashboard/job_provider/screens/home/work_hiring_screen.dart';

class WorkerDetailScreen extends ConsumerStatefulWidget {
  final String workerId;

  const WorkerDetailScreen({super.key, required this.workerId});

  @override
  ConsumerState<WorkerDetailScreen> createState() => _WorkerDetailScreenState();
}

class _WorkerDetailScreenState extends ConsumerState<WorkerDetailScreen> {
  Map<String, dynamic>? _workerData;
  List<dynamic> _otherWorkers = [];
  bool _isLoading = true;
  String? _error;
  bool _isQuickSupportExpanded = false;

  @override
  void initState() {
    super.initState();
    _fetchWorkerDetails();
  }

  Future<void> _fetchWorkerDetails() async {
    final apiService = ref.read(apiServiceProvider);

    try {
      final data = await apiService.getWorkerById(widget.workerId);
      _workerData = data;

      // Fetch other workers in same category
      if (data['categories_id'] != null) {
        final allInCategory = await apiService.fetchWorkersByCategory(
          data['categories_id'].toString(),
        );
        _otherWorkers = allInCategory.where((w) {
          final id = w['users_id'].toString();
          return id != widget.workerId;
        }).toList();
      }

      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_error != null) {
      return Scaffold(
        appBar: AppBar(title: const Text("Worker Profile")),
        body: Center(child: Text("Error: $_error")),
      );
    }

    final data = _workerData!;
    final String name =
        data['full_name'] ?? '${data['first_name']} ${data['last_name']}';
    final String bio =
        data['bio'] ?? 'Specialist in housekeeping and cleaning.';
    final String imageUrl = data['image'] != null
        ? '${ApiService.baseUrl}/uploads/profile/${data['image']}'
        : 'https://via.placeholder.com/150';

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.grey[50],
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Worker Profile',
            style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Worker card
            Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(color: Colors.grey.withOpacity(0.1), blurRadius: 5)
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(
                          imageUrl,
                          width: 90,
                          height: 90,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Container(
                            width: 90,
                            height: 90,
                            color: Colors.grey[300],
                            child: const Icon(Icons.person, size: 40),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(name,
                                style: const TextStyle(
                                    fontSize: 18, fontWeight: FontWeight.bold)),
                            const SizedBox(height: 8),
                            Text(bio,
                                style: const TextStyle(
                                    fontSize: 14, color: Colors.grey)),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _buildBulletPoint("Level: ${data['level'] ?? 'Unknown'}"),
                  _buildBulletPoint(
                      "Location: ${data['province'] ?? ''}, ${data['district'] ?? ''}"),
                  _buildBulletPoint("Phone: ${data['telephone'] ?? 'N/A'}"),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => HireWorkerFormScreen(
                                worker: _convertToWorker(data)),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.pink,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text('Hire',
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
            ),

            // Quick Support
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(color: Colors.grey.withOpacity(0.1), blurRadius: 5)
                ],
              ),
              child: Column(
                children: [
                  InkWell(
                    onTap: () => setState(() =>
                        _isQuickSupportExpanded = !_isQuickSupportExpanded),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Quick Support',
                              style: TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.bold)),
                          Icon(
                            _isQuickSupportExpanded
                                ? Icons.keyboard_arrow_up
                                : Icons.keyboard_arrow_down,
                            color: Colors.grey[600],
                          ),
                        ],
                      ),
                    ),
                  ),
                  if (_isQuickSupportExpanded)
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      child: Column(
                        children: [
                          _buildTextField('Fullname'),
                          const SizedBox(height: 12),
                          _buildTextField('Contact Number'),
                          const SizedBox(height: 12),
                          _buildTextField('Your Message', maxLines: 4),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: () {}, // Add your support logic here
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.pink,
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 32, vertical: 12),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(30)),
                            ),
                            child: const Text('Submit',
                                style: TextStyle(
                                    color: Colors.white, fontSize: 16)),
                          )
                        ],
                      ),
                    ),
                ],
              ),
            ),

            // Other Movers
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Other Workers',
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold)),
                      TextButton(
                        onPressed: () {},
                        child: const Row(
                          children: [
                            Text('See all',
                                style: TextStyle(
                                    color: Colors.grey, fontSize: 14)),
                            Icon(Icons.arrow_forward_ios,
                                size: 12, color: Colors.grey),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    height: 120,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: _otherWorkers.length,
                      itemBuilder: (context, index) {
                        final w = _otherWorkers[index];
                        final other = Worker(
                          id: w['users_id'].toString(),
                          name: w['full_name'] ??
                              '${w['first_name'] ?? ''} ${w['last_name'] ?? ''}',
                          specialty: w['category'] ?? 'Specialist',
                          imageUrl: w['image'] != null
                              ? '${ApiService.baseUrl}/uploads/profile/${w['image']}'
                              : 'assets/default_worker.png',
                          rating: 0.0,
                        );
                        return _buildOtherWorkerItem(context, other);
                      },
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBulletPoint(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('• ',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          Expanded(
              child: Text(text,
                  style: const TextStyle(
                      fontSize: 14, fontWeight: FontWeight.w500))),
        ],
      ),
    );
  }

  Widget _buildTextField(String hintText, {int maxLines = 1}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: TextField(
        maxLines: maxLines,
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: TextStyle(color: Colors.grey[400], fontSize: 14),
          border: InputBorder.none,
        ),
      ),
    );
  }

  Widget _buildOtherWorkerItem(BuildContext context, Worker worker) {
    return GestureDetector(
      onTap: () {
        if (worker.id != widget.workerId) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => WorkerDetailScreen(workerId: worker.id),
            ),
          );
        }
      },
      child: Container(
        width: 100,
        margin: const EdgeInsets.only(right: 12),
        child: Column(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                worker.imageUrl,
                width: 80,
                height: 80,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  width: 80,
                  height: 80,
                  color: Colors.grey[300],
                  child: const Icon(Icons.person, size: 40, color: Colors.grey),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(worker.name,
                style:
                    const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
                textAlign: TextAlign.center,
                overflow: TextOverflow.ellipsis),
          ],
        ),
      ),
    );
  }

  Worker _convertToWorker(Map<String, dynamic> data) {
    return Worker(
      id: data['users_id'].toString(),
      name: data['full_name'] ??
          '${data['first_name'] ?? ''} ${data['last_name'] ?? ''}',
      specialty: data['category'] ?? 'Specialist',
      imageUrl: data['image'] != null
          ? '${ApiService.baseUrl}/uploads/profile/${data['image']}'
          : 'assets/default_worker.png',
      rating: (data['rating'] != null)
          ? double.tryParse(data['rating'].toString()) ?? 0.0
          : 0.0,
    );
  }
}
