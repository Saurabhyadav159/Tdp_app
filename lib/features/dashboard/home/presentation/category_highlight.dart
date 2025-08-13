import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:intl/intl.dart';

import '../../../../config/colors.dart';
import '../../../category/domain/category.dart';
import '../../../category/presentation/Allbannershowpage.dart';
import '../../../category/presentation/edit_banner_screen.dart';
import 'VideoEditorPage.dart';

class CategoryHighlightDisplay extends StatefulWidget {
  final Category category;

  const CategoryHighlightDisplay(this.category, {super.key});

  @override
  State<CategoryHighlightDisplay> createState() => _CategoryHighlightDisplayState();
}

class _CategoryHighlightDisplayState extends State<CategoryHighlightDisplay> {
  @override
  Widget build(BuildContext context) {
    List<Poster> displayedImages = widget.category.posters.take(10).toList();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  widget.category.name,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              GestureDetector(
                onTap: () => _navigateToAllPosters(),
                child: Container(
                  decoration: BoxDecoration(
                    color: SharedColors.primary,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                  child: const Text(
                    "View All",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 114,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: displayedImages.length,
              separatorBuilder: (_, __) => const SizedBox(width: 6),
              itemBuilder: (context, index) {
                final poster = displayedImages[index];
                return _buildPosterItem(poster);
              },
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Future<void> _navigateToAllPosters() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AllPosterPage(category: widget.category),
      ),
    );
  }

  Widget _buildPosterItem(Poster poster) {
    return GestureDetector(
      onTap: () => _handlePosterTap(poster),
      child: SizedBox(
        width: 112,
        height: 112,
        child: Stack(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(
                    color: SharedColors.categoryHighlightBorderColor,
                  ),
                ),
                child: poster.isVideo
                    ? _buildVideoThumbnail(poster)
                    : _buildImageThumbnail(poster),
              ),
            ),
            if (poster.specialDay != null || poster.date != null)
              Positioned(
                bottom: 0,
                left: 0,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: const BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.only(
                      topRight: Radius.circular(6),
                      bottomLeft: Radius.circular(6),
                    ),
                  ),
                  child: Text(
                    _getDisplayDate(poster),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            if (poster.isVideo)
              const Positioned.fill(
                child: Align(
                  alignment: Alignment.center,
                  child: Icon(
                    Icons.play_circle_fill,
                    color: Colors.white70,
                    size: 40,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _handlePosterTap(Poster poster) async {
    if (poster.isVideo) {
      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => VideoEditorPage(videoUrl: poster.posterUrl ?? ""),
        ),
      );
    } else {
      print("Navigating to SocialMediaDetailsPage with poster position: ${poster.position}");
      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => SocialMediaDetailsPage(
            assetPath: poster.posterUrl ?? "",
            categoryId: widget.category.id,
            initialPosition: poster.position,
            posterId: poster.id,
          ),
        ),
      );
    }
  }


  String _getDisplayDate(Poster poster) {
    if (poster.specialDay != null) {
      try {
        // Assuming specialDay has: day (int), month (full name like "October"), and optional year (default to current)
        final int day = int.tryParse(poster.specialDay!.day ?? '') ?? 1;
        final String monthName = poster.specialDay!.month ?? '';
        final int year = DateTime.now().year;

        // Parse full month name to month number
        final int month = DateFormat('MMMM').parse(monthName).month;

        final DateTime date = DateTime(year, month, day);
        return DateFormat("d MMM").format(date); // Output like: 26 Oct
      } catch (e) {
        return "";
      }
    } else if (poster.date != null) {
      try {
        // Optional fallback if poster.date is like "24 October"
        final parts = poster.date!.split(" ");
        if (parts.length == 2) {
          final int? day = int.tryParse(parts[0]);
          final int month = DateFormat('MMMM').parse(parts[1]).month;
          final DateTime date = DateTime(DateTime.now().year, month, day!);
          return DateFormat("d MMM").format(date);
        }
      } catch (e) {
        return poster.date!;
      }
    }
    return "";
  }


  Widget _buildVideoThumbnail(Poster poster) {
    final String? thumbUrl = poster.videoThumb;
    if (thumbUrl == null || thumbUrl.isEmpty) {
      return _buildPlaceholder();
    }

    return CachedNetworkImage(
      imageUrl: thumbUrl,
      height: 112,
      width: 112,
      fit: BoxFit.cover,
      placeholder: (context, url) => _buildPlaceholder(),
      errorWidget: (context, url, error) {
        debugPrint("Error loading video thumbnail: $error");
        return _buildPlaceholder(isError: true);
      },
      fadeInDuration: const Duration(milliseconds: 200),
      memCacheHeight: 224,
      memCacheWidth: 224,
    );
  }

  Widget _buildImageThumbnail(Poster poster) {
    final String? imageUrl = poster.posterUrl;
    if (imageUrl == null || imageUrl.isEmpty) {
      return _buildPlaceholder(isError: true);
    }

    return CachedNetworkImage(
      imageUrl: imageUrl,
      height: 112,
      width: 112,
      fit: BoxFit.cover,
      placeholder: (context, url) => _buildPlaceholder(),
      errorWidget: (context, url, error) {
        debugPrint("Error loading image: $error");
        return _buildPlaceholder(isError: true);
      },
      fadeInDuration: const Duration(milliseconds: 200),
      memCacheHeight: 224,
      memCacheWidth: 224,
    );
  }

  Widget _buildPlaceholder({bool isError = false}) {
    return Container(
      height: 112,
      width: 112,
      color: Colors.grey.shade300,
      child: Center(
        child: isError
            ? const Icon(Icons.broken_image, color: Colors.red, size: 30)
            : const CircularProgressIndicator(
          strokeWidth: 2,
          color: Colors.blue,
        ),
      ),
    );
  }
}
