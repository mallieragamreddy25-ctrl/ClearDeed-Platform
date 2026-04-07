import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';
import '../../theme/app_theme.dart';
import '../../models/property.dart';
import '../../utils/app_logger.dart';

/// Full-screen property gallery viewer with swipe and pinch-to-zoom
class PropertyGalleryScreen extends StatefulWidget {
  final List<PropertyImage> images;
  final int initialIndex;
  final String propertyTitle;

  const PropertyGalleryScreen({
    Key? key,
    required this.images,
    this.initialIndex = 0,
    required this.propertyTitle,
  }) : super(key: key);

  @override
  State<PropertyGalleryScreen> createState() => _PropertyGalleryScreenState();
}

class _PropertyGalleryScreenState extends State<PropertyGalleryScreen> {
  late PageController _pageController;
  late int _currentIndex;
  bool _isFullscreen = true;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: _currentIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _downloadImage() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Image downloading...'),
        duration: Duration(seconds: 2),
      ),
    );
    // Implement actual download functionality
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(56),
        child: Container(
          color: Colors.black87,
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                  ),
                  Expanded(
                    child: Text(
                      widget.propertyTitle,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.download, color: Colors.white),
                    tooltip: 'Download',
                    onPressed: _downloadImage,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      body: Stack(
        children: [
          // Gallery Viewer with Pinch-to-Zoom
          PhotoViewGallery.builder(
            pageController: _pageController,
            itemCount: widget.images.length,
            builder: (context, index) {
              return PhotoViewGalleryPageOptions(
                imageProvider: NetworkImage(widget.images[index].imageUrl),
                initialScale: PhotoViewComputedScale.contained * 0.8,
                minScale: PhotoViewComputedScale.contained * 0.5,
                maxScale: PhotoViewComputedScale.covered * 3,
              );
            },
            onPageChanged: (index) {
              setState(() => _currentIndex = index);
            },
            loadingBuilder: (context, event) {
              return Center(
                child: SizedBox(
                  width: 60,
                  height: 60,
                  child: CircularProgressIndicator(
                    value: event == null
                        ? 0
                        : event.cumulativeBytesLoaded /
                            (event.expectedTotalBytes ?? 1),
                    strokeWidth: 3,
                    valueColor: const AlwaysStoppedAnimation<Color>(
                      Colors.white,
                    ),
                  ),
                ),
              );
            },
            backgroundDecoration: const BoxDecoration(color: Colors.black),
          ),

          // Image Counter & Navigation
          Positioned(
            bottom: 24,
            left: 0,
            right: 0,
            child: Column(
              children: [
                // Image Counter
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black54,
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Text(
                    '${_currentIndex + 1} / ${widget.images.length}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                // Slide Indicators
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(
                        widget.images.length,
                        (index) {
                          return Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 4),
                            child: GestureDetector(
                              onTap: () {
                                _pageController.jumpToPage(index);
                              },
                              child: Container(
                                width: _currentIndex == index ? 24 : 12,
                                height: 12,
                                decoration: BoxDecoration(
                                  color: _currentIndex == index
                                      ? Colors.white
                                      : Colors.white54,
                                  borderRadius: BorderRadius.circular(6),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Navigation Arrows (optional, for larger screens)
          if (MediaQuery.of(context).size.width > 600)
            Positioned(
              left: 12,
              top: 50,
              bottom: 50,
              child: Icon(
                _currentIndex > 0 ? Icons.arrow_back_ios : null,
                color: Colors.white54,
                size: 24,
              ),
            ),
          if (MediaQuery.of(context).size.width > 600)
            Positioned(
              right: 12,
              top: 50,
              bottom: 50,
              child: Icon(
                _currentIndex < widget.images.length - 1
                    ? Icons.arrow_forward_ios
                    : null,
                color: Colors.white54,
                size: 24,
              ),
            ),
        ],
      ),
                    );
                  },
                  loadingBuilder: (context, event) {
                    return Center(
                      child: CircularProgressIndicator(
                        value: event == null
                            ? 0
                            : event.cumulativeBytesLoaded /
                                event.expectedTotalBytes!,
                        strokeWidth: 2,
                        valueColor: const AlwaysStoppedAnimation<Color>(
                          Colors.white,
                        ),
                      ),
                    );
                  },
                );
              },
              scrollPhysics: const BouncingScrollPhysics(),
              backgroundDecoration: const BoxDecoration(color: Colors.black),
            ),
          ),

          // Bottom info bar
          Container(
            color: Colors.black87,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                if (widget.images[_currentIndex].imageTitle != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Text(
                      widget.images[_currentIndex].imageTitle!,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                Row(
                  children: List.generate(
                    widget.images.length,
                    (index) => Expanded(
                      child: GestureDetector(
                        onTap: () {
                          _pageController.animateToPage(
                            index,
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeInOut,
                          );
                        },
                        child: Container(
                          height: 4,
                          margin: const EdgeInsets.symmetric(horizontal: 2),
                          decoration: BoxDecoration(
                            color: index == _currentIndex
                                ? Colors.white
                                : Colors.white30,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showImageInfo() {
    final image = widget.images[_currentIndex];
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.black87,
      builder: (context) => Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Image Details',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: Colors.white,
                  ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Image Number',
                  style: TextStyle(color: Colors.white70),
                ),
                Text(
                  '${_currentIndex + 1} of ${widget.images.length}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (image.imageTitle != null)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Title',
                    style: TextStyle(color: Colors.white70),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    image.imageTitle!,
                    style: const TextStyle(color: Colors.white),
                  ),
                  const SizedBox(height: 12),
                ],
              ),
            if (image.displayOrder != null)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Display Order',
                    style: TextStyle(color: Colors.white70),
                  ),
                  Text(
                    '#${image.displayOrder}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}
