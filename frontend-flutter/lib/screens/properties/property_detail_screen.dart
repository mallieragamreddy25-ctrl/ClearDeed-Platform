import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'property_gallery_screen.dart';
import '../../theme/app_theme.dart';
import '../../utils/constants.dart';
import '../../utils/app_logger.dart';
import '../../providers/property_provider.dart';
import '../../models/property.dart';

/// Property detail screen - full property information and actions
class PropertyDetailScreen extends ConsumerStatefulWidget {
  final int propertyId;

  const PropertyDetailScreen({
    Key? key,
    required this.propertyId,
  }) : super(key: key);

  @override
  ConsumerState<PropertyDetailScreen> createState() =>
      _PropertyDetailScreenState();
}

class _PropertyDetailScreenState extends ConsumerState<PropertyDetailScreen> {
  int _currentImageIndex = 0;

  @override
  void initState() {
    super.initState();
    AppLogger.logFunctionEntry('PropertyDetailScreen.initState',
        {'propertyId': widget.propertyId});
    // Load property detail
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref
          .read(propertyDetailProvider(widget.propertyId).notifier)
          .loadPropertyDetail(widget.propertyId);
    });
  }

  Future<void> _toggleFavorite() async {
    await ref
        .read(propertyDetailProvider(widget.propertyId).notifier)
        .toggleFavorite();
  }

  Future<void> _expressInterest() async {
    final success = await ref
        .read(propertyDetailProvider(widget.propertyId).notifier)
        .expressInterest();

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Interest expressed! We\'ll contact you soon.'),
          backgroundColor: AppTheme.successGreen,
        ),
      );
      AppLogger.logAuthEvent('User expressed interest in property');
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to express interest. Please try again.'),
          backgroundColor: AppTheme.errorRed,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final propertyDetailAsync =
        ref.watch(propertyDetailProvider(widget.propertyId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Property Details'),
        elevation: 0,
        centerTitle: true,
      ),
      body: propertyDetailAsync.when(
        data: (detailState) {
          if (detailState.property == null) {
            return const Center(child: Text('Property not found'));
          }

          final property = detailState.property!;

          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Image Gallery
                Stack(
                  children: [
                    if (property.gallery.isNotEmpty)
                      CarouselSlider(
                        options: CarouselOptions(
                          height: 250,
                          enableInfiniteScroll: false,
                          onPageChanged: (index, reason) {
                            setState(() => _currentImageIndex = index);
                          },
                        ),
                        items: property.gallery
                            .map((image) => Container(
                                  width: double.infinity,
                                  decoration: BoxDecoration(
                                    image: DecorationImage(
                                      image:
                                          NetworkImage(image.imageUrl),
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ))
                            .toList(),
                      )
                    else
                      Container(
                        height: 250,
                        color: AppTheme.lightGrey,
                        child: const Center(
                          child: Icon(
                            Icons.image_not_supported,
                            size: 64,
                            color: AppTheme.textHint,
                          ),
                        ),
                      ),

                    // Favorite button
                    Positioned(
                      top: 12,
                      right: 12,
                      child: GestureDetector(
                        onTap: _toggleFavorite,
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 8,
                              ),
                            ],
                          ),
                          child: Icon(
                            detailState.isFavorite
                                ? Icons.favorite
                                : Icons.favorite_border,
                            color: detailState.isFavorite
                                ? AppTheme.errorRed
                                : AppTheme.textSecondary,
                            size: 24,
                          ),
                        ),
                      ),
                    ),

                    // Image counter
                    if (property.gallery.isNotEmpty)
                      Positioned(
                        bottom: 12,
                        right: 12,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.black54,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Text(
                            '${_currentImageIndex + 1}/${property.gallery.length}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),

                    // Verified badge
                    if (property.verifiedBadge)
                      Positioned(
                        top: 12,
                        left: 12,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: AppTheme.successGreen,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 8,
                              ),
                            ],
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.verified,
                                  color: Colors.white, size: 16),
                              SizedBox(width: 4),
                              Text(
                                'Verified',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),

                const SizedBox(height: 24),

                // Property Info
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Title and Price
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              property.title,
                              style: Theme.of(context)
                                  .textTheme
                                  .headlineSmall,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            '₹${(property.price / 10000000).toStringAsFixed(1)}Cr',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 20,
                              color: AppTheme.primaryBlue,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 8),

                      // Location
                      Row(
                        children: [
                          const Icon(Icons.location_on,
                              size: 16, color: AppTheme.textSecondary),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              property.location,
                              style: Theme.of(context).textTheme.bodyMedium,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 16),

                      // Key details
                      Row(
                        children: [
                          _DetailChip(
                            label: '${property.area.toStringAsFixed(0)} ${property.areaUnit}',
                            icon: Icons.square_foot,
                          ),
                          const SizedBox(width: 12),
                          _DetailChip(
                            label: property.category,
                            icon: Icons.category,
                          ),
                          const SizedBox(width: 12),
                          _DetailChip(
                            label: property.status,
                            icon: Icons.info,
                          ),
                        ],
                      ),

                      const SizedBox(height: 24),

                      // Description
                      Text(
                        'Description',
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        property.description,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),

                      const SizedBox(height: 24),

                      // Property Details
                      Text(
                        'Property Details',
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      const SizedBox(height: 12),
                      _PropertyDetailRow(
                        label: 'Ownership Status',
                        value: property.ownershipStatus,
                      ),
                      _PropertyDetailRow(
                        label: 'Category',
                        value: property.category,
                      ),
                      _PropertyDetailRow(
                        label: 'Status',
                        value: property.status,
                      ),

                      if (property.verificationSummary != null) ...[
                        const SizedBox(height: 24),
                        Text(
                          'Verification',
                          style: Theme.of(context).textTheme.headlineSmall,
                        ),
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppTheme.successGreen.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(
                                AppConstants.borderRadius),
                            border: Border.all(
                              color: AppTheme.successGreen,
                              width: 1,
                            ),
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.verified,
                                color: AppTheme.successGreen,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  property.verificationSummary!,
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyMedium,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],

                      const SizedBox(height: 24),

                      // Documents
                      if (property.documents.isNotEmpty) ...[
                        Text(
                          'Documents',
                          style: Theme.of(context).textTheme.headlineSmall,
                        ),
                        const SizedBox(height: 12),
                        Column(
                          children: property.documents
                              .map((doc) => Padding(
                                    padding: const EdgeInsets.only(bottom: 8),
                                    child: Card(
                                      child: Padding(
                                        padding: const EdgeInsets.all(12),
                                        child: Row(
                                          children: [
                                            Icon(Icons.description,
                                                color:
                                                    AppTheme.primaryBlue),
                                            const SizedBox(width: 12),
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment
                                                        .start,
                                                children: [
                                                  Text(
                                                    doc.documentName,
                                                    style: const TextStyle(
                                                      fontWeight:
                                                          FontWeight.w600,
                                                    ),
                                                  ),
                                                  const SizedBox(height: 2),
                                                  Text(
                                                    doc.documentType,
                                                    style: Theme.of(context)
                                                        .textTheme
                                                        .bodySmall,
                                                  ),
                                                ],
                                              ),
                                            ),
                                            if (doc.documentUrl != null)
                                              IconButton(
                                                icon: const Icon(
                                                    Icons.download),
                                                onPressed: () {
                                                  AppLogger.logNavigation(
                                                    'PropertyDetail',
                                                    'DownloadDocument',
                                                  );
                                                },
                                              ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ))
                              .toList(),
                        ),
                        const SizedBox(height: 24),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          );
        },
        loading: () => const Center(
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
        error: (error, stack) => Center(
          child: Text('Error: $error'),
        ),
      ),
      bottomNavigationBar: propertyDetailAsync.maybeWhen(
        data: (detailState) => detailState.property != null
            ? Padding(
                padding: const EdgeInsets.all(16),
                child: SafeArea(
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: detailState.isLoading ? null : _expressInterest,
                      icon: const Icon(Icons.handshake_outlined),
                      label: Text(
                        detailState.hasExpressedInterest
                            ? 'Interest Already Registered'
                            : 'Express Interest',
                      ),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                    ),
                  ),
                ),
              )
            : null,
        orElse: () => null,
      ),
    );
  }
}

// ==================== Detail Chip ====================

class _DetailChip extends StatelessWidget {
  final String label;
  final IconData icon;

  const _DetailChip({
    required this.label,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppTheme.lightGrey,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: AppTheme.primaryBlue),
          const SizedBox(width: 4),
          Text(
            label,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }
}

// ==================== Property Detail Row Widget ====================

class _PropertyDetailRow extends StatelessWidget {
  final String label;
  final String value;

  const _PropertyDetailRow({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppTheme.textSecondary,
            ),
          ),
          Text(
            value,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

// ==================== Property Detail Row ====================

class _PropertyDetailRow extends StatelessWidget {
  final String label;
  final String value;

  const _PropertyDetailRow({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          Text(
            value,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
          ),
        ],
      ),
    );
  }
}
