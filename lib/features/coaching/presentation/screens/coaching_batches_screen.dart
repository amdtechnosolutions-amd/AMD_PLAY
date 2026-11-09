import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_endpoints.dart';
import '../../../../core/routes/app_routes.dart';
import '../../../../core/widgets/empty_state.dart';

/// Live Coaching Batches Screen powered by GET /api/v1/coaching/batches.
/// Strictly displays live server data with pure white background and gold styling.
class CoachingBatchesScreen extends StatefulWidget {
  const CoachingBatchesScreen({super.key});

  @override
  State<CoachingBatchesScreen> createState() => _CoachingBatchesScreenState();
}

class _CoachingBatchesScreenState extends State<CoachingBatchesScreen> {
  final ApiClient _apiClient = Get.isRegistered<ApiClient>() ? Get.find<ApiClient>() : ApiClient();

  bool _isLoading = true;
  String _errorMessage = '';
  List<Map<String, dynamic>> _batches = [];

  @override
  void initState() {
    super.initState();
    _fetchLiveBatches();
  }

  Future<void> _fetchLiveBatches() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      final res = await _apiClient.dio.get(ApiEndpoints.coachingBatches);
      if (res.data != null && res.data['success'] == true && res.data['data'] is List) {
        final list = (res.data['data'] as List)
            .map((e) => Map<String, dynamic>.from(e as Map))
            .toList();
        setState(() {
          _batches = list;
          _isLoading = false;
        });
        return;
      }
    } catch (e) {
      _errorMessage = e.toString();
    }

    setState(() {
      _batches = [];
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          'Coaching Academy & Batches',
          style: TextStyle(
            fontFamily: 'Nunito',
            fontWeight: FontWeight.w800,
            fontSize: 17.sp,
            color: const Color(0xFF0F172A),
          ),
        ),
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.assessment_outlined, size: 22.sp, color: const Color(0xFFD4AF37)),
            onPressed: () => Get.toNamed(AppRoutes.coachingReport),
            tooltip: 'Performance Report',
          ),
          IconButton(
            icon: Icon(Icons.refresh_rounded, size: 22.sp, color: const Color(0xFF0F172A)),
            onPressed: _fetchLiveBatches,
            tooltip: 'Refresh Batches',
          ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(
              strokeWidth: 2.5,
              color: Color(0xFFD4AF37),
            ),
            SizedBox(height: 16.h),
            Text(
              'Loading coaching batches...',
              style: TextStyle(
                fontFamily: 'Nunito',
                fontSize: 13.5.sp,
                color: const Color(0xFF64748B),
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      );
    }

    if (_batches.isEmpty) {
      return RefreshIndicator(
        color: const Color(0xFFD4AF37),
        backgroundColor: Colors.white,
        onRefresh: _fetchLiveBatches,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 60.h),
          child: EmptyState(
            title: 'No Active Coaching Batches',
            message: _errorMessage.isNotEmpty && _errorMessage.contains('401')
                ? 'Please sign in to your student account to view enrolled coaching batches and training schedules.'
                : 'There are no coaching batches scheduled at this time. Please check back later or contact academy administration.',
            icon: Icons.fitness_center_rounded,
            buttonText: 'REFRESH',
            onButtonPressed: _fetchLiveBatches,
          ),
        ),
      );
    }

    return RefreshIndicator(
      color: const Color(0xFFD4AF37),
      backgroundColor: Colors.white,
      onRefresh: _fetchLiveBatches,
      child: ListView.builder(
        padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 30.h),
        itemCount: _batches.length,
        itemBuilder: (context, index) {
          final b = _batches[index];
          final title = b['name']?.toString() ?? b['title']?.toString() ?? 'Coaching Batch';
          final sport = (b['sport'] is Map ? b['sport']['name'] : b['sport'])?.toString() ?? 'Sports';
          final coach = (b['coach'] is Map ? (b['coach']['name'] ?? b['coach']['fullName']) : b['coach'])?.toString() ?? 'Academy Coach';
          final timing = b['schedule']?.toString() ?? b['timing']?.toString() ?? 'Schedule as per batch';
          final fee = b['fee'] != null ? '₹${b['fee']}/mo' : '';
          final enrolled = (b['enrolledCount'] ?? b['enrolled'] as num?)?.toInt() ?? 0;
          final capacity = (b['capacity'] as num?)?.toInt() ?? 10;
          final isFull = enrolled >= capacity && capacity > 0;

          return Container(
            margin: EdgeInsets.only(bottom: 16.h),
            padding: EdgeInsets.all(18.w),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18.r),
              border: Border.all(color: const Color(0x60D4AF37), width: 1.3),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x20D4AF37),
                  blurRadius: 16,
                  offset: Offset(0, 6),
                ),
                BoxShadow(
                  color: Color(0x0C000000),
                  blurRadius: 6,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFFDF5),
                        borderRadius: BorderRadius.circular(6.r),
                        border: Border.all(color: const Color(0xFFD4AF37), width: 1),
                      ),
                      child: Text(
                        sport.toUpperCase(),
                        style: TextStyle(
                          fontFamily: 'Nunito',
                          fontSize: 10.5.sp,
                          fontWeight: FontWeight.w800,
                          color: const Color(0xFF9E7B1A),
                        ),
                      ),
                    ),
                    if (fee.isNotEmpty)
                      Text(
                        fee,
                        style: TextStyle(
                          fontFamily: 'Nunito',
                          fontSize: 15.sp,
                          fontWeight: FontWeight.w900,
                          color: const Color(0xFF0F172A),
                        ),
                      ),
                  ],
                ),
                SizedBox(height: 12.h),
                Text(
                  title,
                  style: TextStyle(
                    fontFamily: 'Nunito',
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF0F172A),
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  'Coach: $coach',
                  style: TextStyle(
                    fontFamily: 'Nunito',
                    fontSize: 12.5.sp,
                    color: const Color(0xFF64748B),
                  ),
                ),
                const Divider(color: Color(0x20D4AF37), height: 22),
                Row(
                  children: [
                    const Icon(Icons.schedule_rounded, size: 16, color: Color(0xFFD4AF37)),
                    SizedBox(width: 8.w),
                    Expanded(
                      child: Text(
                        timing,
                        style: TextStyle(
                          fontFamily: 'Nunito',
                          fontSize: 12.sp,
                          color: const Color(0xFF0F172A),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                if (capacity > 0) ...[
                  SizedBox(height: 12.h),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Batch Capacity',
                        style: TextStyle(
                          fontFamily: 'Nunito',
                          fontSize: 11.5.sp,
                          color: const Color(0xFF64748B),
                        ),
                      ),
                      Text(
                        isFull ? 'BATCH FULL ($capacity/$capacity)' : '$enrolled / $capacity Enrolled',
                        style: TextStyle(
                          fontFamily: 'Nunito',
                          fontSize: 11.5.sp,
                          fontWeight: FontWeight.w800,
                          color: isFull ? const Color(0xFFEF4444) : const Color(0xFF10B981),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 6.h),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4.r),
                    child: LinearProgressIndicator(
                      value: (enrolled / capacity).clamp(0.0, 1.0),
                      backgroundColor: const Color(0xFFF1F5F9),
                      valueColor: AlwaysStoppedAnimation<Color>(
                        isFull ? const Color(0xFFEF4444) : const Color(0xFFD4AF37),
                      ),
                      minHeight: 6.h,
                    ),
                  ),
                ],
              ],
            ),
          );
        },
      ),
    );
  }
}
