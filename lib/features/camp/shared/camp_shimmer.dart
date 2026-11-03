import 'package:flutter/material.dart';
import 'package:timelay_health/core/widgets/shimmer.dart';
import 'package:timelay_health/features/camp/dashboard/presentation/theme/camp_colors.dart';

const _base = Color(0xFFE4E1EF);
const _highlight = Color(0xFFF8F7FC);

class CampDashboardShimmer extends StatelessWidget {
  const CampDashboardShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return const SingleChildScrollView(
      physics: NeverScrollableScrollPhysics(),
      child: Shimmer(
        baseColor: _base,
        highlightColor: _highlight,
        child: Padding(
          padding: EdgeInsets.only(bottom: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: EdgeInsets.fromLTRB(16, 12, 16, 0),
                child: ShimmerBox(height: 88, radius: 18),
              ),
              SizedBox(height: 12),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    Expanded(child: ShimmerBox(height: 78, radius: 14)),
                    SizedBox(width: 10),
                    Expanded(child: ShimmerBox(height: 78, radius: 14)),
                    SizedBox(width: 10),
                    Expanded(child: ShimmerBox(height: 78, radius: 14)),
                  ],
                ),
              ),
              SizedBox(height: 14),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: ShimmerBox(height: 56, radius: 14),
              ),
              SizedBox(height: 14),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: ShimmerBox(height: 180, radius: 18),
              ),
              SizedBox(height: 14),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: ShimmerBox(height: 160, radius: 18),
              ),
              SizedBox(height: 14),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: ShimmerBox(height: 170, radius: 18),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class CampListShimmer extends StatelessWidget {
  const CampListShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return const SingleChildScrollView(
      physics: NeverScrollableScrollPhysics(),
      child: Shimmer(
        baseColor: _base,
        highlightColor: _highlight,
        child: Padding(
          padding: EdgeInsets.fromLTRB(14, 12, 14, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ShimmerBox(height: 44, radius: 12),
              SizedBox(height: 12),
              Row(
                children: [
                  Expanded(child: ShimmerBox(height: 64, radius: 14)),
                  SizedBox(width: 8),
                  Expanded(child: ShimmerBox(height: 64, radius: 14)),
                  SizedBox(width: 8),
                  Expanded(child: ShimmerBox(height: 64, radius: 14)),
                  SizedBox(width: 8),
                  Expanded(child: ShimmerBox(height: 64, radius: 14)),
                ],
              ),
              SizedBox(height: 12),
              Row(
                children: [
                  ShimmerBox(width: 72, height: 32, radius: 999),
                  SizedBox(width: 8),
                  ShimmerBox(width: 64, height: 32, radius: 999),
                  SizedBox(width: 8),
                  ShimmerBox(width: 78, height: 32, radius: 999),
                  SizedBox(width: 8),
                  ShimmerBox(width: 86, height: 32, radius: 999),
                ],
              ),
              SizedBox(height: 16),
              ShimmerBox(width: 110, height: 14, radius: 6),
              SizedBox(height: 10),
              _CampCardBone(),
              SizedBox(height: 8),
              _CampCardBone(),
              SizedBox(height: 8),
              _CampCardBone(),
              SizedBox(height: 8),
              _CampCardBone(),
            ],
          ),
        ),
      ),
    );
  }
}

class CampPatientsShimmer extends StatelessWidget {
  const CampPatientsShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return const SingleChildScrollView(
      physics: NeverScrollableScrollPhysics(),
      child: Shimmer(
        baseColor: _base,
        highlightColor: _highlight,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: EdgeInsets.fromLTRB(18, 18, 18, 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ShimmerBox(width: 110, height: 22, radius: 999),
                  SizedBox(height: 14),
                  ShimmerBox(width: 180, height: 22, radius: 8),
                  SizedBox(height: 8),
                  ShimmerBox(width: 220, height: 12, radius: 6),
                  SizedBox(height: 16),
                  ShimmerBox(width: 130, height: 40, radius: 12),
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(16, 0, 16, 0),
              child: Row(
                children: [
                  Expanded(child: ShimmerBox(height: 72, radius: 14)),
                  SizedBox(width: 10),
                  Expanded(child: ShimmerBox(height: 72, radius: 14)),
                ],
              ),
            ),
            SizedBox(height: 10),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  Expanded(child: ShimmerBox(height: 72, radius: 14)),
                  SizedBox(width: 10),
                  Expanded(child: ShimmerBox(height: 72, radius: 14)),
                ],
              ),
            ),
            SizedBox(height: 14),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: ShimmerBox(height: 44, radius: 12),
            ),
            SizedBox(height: 12),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  ShimmerBox(width: 56, height: 32, radius: 999),
                  SizedBox(width: 8),
                  ShimmerBox(width: 70, height: 32, radius: 999),
                  SizedBox(width: 8),
                  ShimmerBox(width: 58, height: 32, radius: 999),
                  SizedBox(width: 8),
                  ShimmerBox(width: 68, height: 32, radius: 999),
                ],
              ),
            ),
            SizedBox(height: 16),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: ShimmerBox(width: 120, height: 14, radius: 6),
            ),
            SizedBox(height: 10),
            _PatientCardBone(),
            _PatientCardBone(),
            _PatientCardBone(),
            _PatientCardBone(),
          ],
        ),
      ),
    );
  }
}

class _CampCardBone extends StatelessWidget {
  const _CampCardBone();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: CampColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: CampColors.border),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(child: ShimmerBox(width: 160, height: 14, radius: 6)),
              ShimmerBox(width: 64, height: 22, radius: 999),
            ],
          ),
          SizedBox(height: 10),
          ShimmerBox(width: 180, height: 11, radius: 5),
          SizedBox(height: 8),
          ShimmerBox(width: double.infinity, height: 10, radius: 5),
          SizedBox(height: 12),
          Row(
            children: [
              ShimmerBox(width: 72, height: 28, radius: 8),
              SizedBox(width: 8),
              ShimmerBox(width: 72, height: 28, radius: 8),
              Spacer(),
              ShimmerBox(width: 28, height: 28, radius: 8),
            ],
          ),
        ],
      ),
    );
  }
}

class _PatientCardBone extends StatelessWidget {
  const _PatientCardBone();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: CampColors.surface,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: CampColors.border),
        ),
        child: const Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ShimmerBox(height: 44, circle: true),
            SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: ShimmerBox(width: 140, height: 14, radius: 6),
                      ),
                      ShimmerBox(width: 64, height: 20, radius: 999),
                    ],
                  ),
                  SizedBox(height: 8),
                  ShimmerBox(width: 100, height: 11, radius: 5),
                  SizedBox(height: 6),
                  ShimmerBox(width: 160, height: 11, radius: 5),
                  SizedBox(height: 12),
                  Row(
                    children: [
                      ShimmerBox(width: 56, height: 28, radius: 8),
                      SizedBox(width: 6),
                      ShimmerBox(width: 56, height: 28, radius: 8),
                      SizedBox(width: 6),
                      ShimmerBox(width: 56, height: 28, radius: 8),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
