import 'package:flutter/material.dart';
import 'package:timelay_health/features/camp/dashboard/presentation/theme/camp_colors.dart';

class CampHeroBanner extends StatefulWidget {
  const CampHeroBanner({super.key});

  @override
  State<CampHeroBanner> createState() => _CampHeroBannerState();
}

class _CampHeroBannerState extends State<CampHeroBanner> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  static const _totalPages = 5;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 0),
      child: Column(
        children: [
          SizedBox(
            height: 172,
            child: PageView.builder(
              controller: _pageController,
              itemCount: _totalPages,
              onPageChanged: (i) => setState(() => _currentPage = i),
              itemBuilder: (context, index) {
                return Container(
                  margin: const EdgeInsets.symmetric(horizontal: 2),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x0F1A1A2E),
                        blurRadius: 10,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: Image.asset(
                      'assets/images/camp_banner.png',
                      fit: BoxFit.cover,
                      alignment: Alignment.center,
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              _totalPages,
              (i) => AnimatedContainer(
                duration: const Duration(milliseconds: 220),
                margin: const EdgeInsets.symmetric(horizontal: 3),
                width: i == _currentPage ? 18 : 6,
                height: 6,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(3),
                  color: i == _currentPage
                      ? CampColors.primary
                      : const Color(0xFFD1D5DB),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Combined Date + 5 Stats Card ────────────────────────────────────────────
