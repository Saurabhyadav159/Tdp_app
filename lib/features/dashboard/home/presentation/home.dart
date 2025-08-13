import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shimmer/shimmer.dart';

import '../../../../core/network/api_service.dart';
import '../../../category/domain/category.dart';
import '../../../category/presentation/Allbannershowpage.dart';
import '../../presentation/VideoPlayerPopup.dart';
import 'category_highlight.dart';
import 'home_slider.dart';
import '../../../../config/colors.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with AutomaticKeepAliveClientMixin {
  List<Category> allCategories = [];
  List<dynamic> bannerList = [];
  bool _isLoading = true;
  bool _hasError = false;
  bool _initialLoadComplete = false;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    if (!_initialLoadComplete) {
      _loadData();
    }
  }

  Future<void> _loadData() async {
    if (_initialLoadComplete) return;

    setState(() {
      _isLoading = true;
      _hasError = false;
    });

    try {
      final apiService = ApiService();
      final results = await Future.wait([
        apiService.fetchCategories(),
        apiService.getBanners(context: context, limit: 10, offset: 0),
      ]);

      setState(() {
        allCategories = results[0] as List<Category>;
        bannerList = results[1] as List<dynamic>;
        _isLoading = false;
        _initialLoadComplete = true;
      });
    } catch (e) {
      debugPrint("Error fetching data: $e");
      setState(() {
        _isLoading = false;
        _hasError = true;
      });
    }
  }

  Widget _buildErrorWidget() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, color: Colors.red, size: 48),
          const SizedBox(height: 16),
          Text(
            'Failed to load data',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _loadData,
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return Scaffold(
      body: _isLoading
          ? const _HomeShimmer()
          : _hasError
          ? _buildErrorWidget()
          : RefreshIndicator(
        onRefresh: _loadData,
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            SliverToBoxAdapter(
              child: Column(
                children: [
                  const SizedBox(height: 8),
                  HomeSlider(banners: bannerList),
                  const SizedBox(height: 16),
                ],
              ),
            ),
            if (allCategories.isNotEmpty)
              SliverList(
                delegate: SliverChildBuilderDelegate(
                      (context, index) => CategoryHighlightDisplay(
                    allCategories[index],
                    key: ValueKey(allCategories[index].id),
                  ),
                  childCount: allCategories.length,
                ),
              )
            else
              SliverFillRemaining(
                child: Center(
                  child: Text(
                    'No categories found',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _HomeShimmer extends StatelessWidget {
  const _HomeShimmer();

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        const SizedBox(height: 12),
        Shimmer.fromColors(
          baseColor: Colors.grey.shade300,
          highlightColor: Colors.grey.shade100,
          child: Container(
            height: 180,
            margin: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
        const SizedBox(height: 24),
        ...List.generate(
          3,
              (_) => Padding(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            child: Shimmer.fromColors(
              baseColor: Colors.grey.shade300,
              highlightColor: Colors.grey.shade100,
              child: Container(
                height: 100,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}