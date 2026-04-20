import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../shared/models/event_model.dart';

class EventCard extends StatelessWidget {
  final EventModel event;
  final VoidCallback? onTap;
  final VoidCallback? onInterestTap;
  final VoidCallback? onBookmarkTap;
  final bool isBookmarked;

  const EventCard({
    super.key,
    required this.event,
    this.onTap,
    this.onInterestTap,
    this.onBookmarkTap,
    this.isBookmarked = false,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Container(
      decoration: BoxDecoration(
        color: AppColors.cardDark,
        borderRadius: BorderRadius.circular(20.r),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Event Image
          GestureDetector(
            onTap: onTap,
            child: ClipRRect(
              borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
              child: AspectRatio(
                aspectRatio: 16 / 9,
                child: event.images.isNotEmpty
                    ? Image.network(
                        event.images.first,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return _buildPlaceholderImage();
                        },
                      )
                    : _buildPlaceholderImage(),
              ),
            ),
          ),
          // Event Details
          Padding(
            padding: EdgeInsets.all(AppDimensions.spacingLg.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title
                Text(
                  event.title,
                  style: textTheme.titleMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 18.sp,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: AppDimensions.spacingMd.h),
                // Date Row
                Row(
                  children: [
                    Icon(
                      Icons.calendar_today_outlined,
                      color: AppColors.primary,
                      size: AppDimensions.iconSm.r,
                    ),
                    SizedBox(width: AppDimensions.spacingSm.w),
                    Text(
                      _formatDateRange(event.startDate, event.endDate),
                      style: textTheme.bodySmall?.copyWith(
                        color: Colors.white.withOpacity(0.7),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: AppDimensions.spacingSm.h),
                // Location Row
                Row(
                  children: [
                    Icon(
                      Icons.location_on_outlined,
                      color: AppColors.primary,
                      size: AppDimensions.iconSm.r,
                    ),
                    SizedBox(width: AppDimensions.spacingSm.w),
                    Expanded(
                      child: Text(
                        event.location,
                        style: textTheme.bodySmall?.copyWith(
                          color: Colors.white.withOpacity(0.7),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: AppDimensions.spacingMd.h),
                // Tags Row
                if (event.tags.isNotEmpty)
                  Wrap(
                    spacing: AppDimensions.spacingSm.w,
                    runSpacing: AppDimensions.spacingSm.h,
                    children: event.tags.take(3).map((tag) {
                      return _EventTag(label: tag);
                    }).toList(),
                  ),
                SizedBox(height: AppDimensions.spacingMd.h),
                // Interested count
                Row(
                  children: [
                    Icon(
                      Icons.favorite,
                      color: AppColors.interested,
                      size: AppDimensions.iconSm.r,
                    ),
                    SizedBox(width: 6.w),
                    Text(
                      '${event.interestedCount} People Interested',
                      style: textTheme.bodySmall?.copyWith(
                        color: AppColors.interested,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: AppDimensions.spacingLg.h),
                // Action Buttons Row
                Row(
                  children: [
                    // Explore & Book Button
                    Expanded(
                      child: ElevatedButton(
                        onPressed: onTap,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          padding: EdgeInsets.symmetric(vertical: 14.h),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                          elevation: 0,
                        ),
                        child: Text(
                          'Explore & Book',
                          style: textTheme.labelLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: AppDimensions.spacingMd.w),
                    // Bookmark Button
                    Container(
                      decoration: BoxDecoration(
                        color: AppColors.surfaceDark,
                        borderRadius: BorderRadius.circular(12.r),
                        border: Border.all(
                          color: AppColors.grey700,
                          width: 1,
                        ),
                      ),
                      child: IconButton(
                        onPressed: onBookmarkTap,
                        icon: Icon(
                          isBookmarked
                              ? Icons.bookmark
                              : Icons.bookmark_border,
                          color: isBookmarked
                              ? AppColors.primary
                              : Colors.white,
                          size: AppDimensions.iconLg.r,
                        ),
                        padding: EdgeInsets.all(10.r),
                        constraints: BoxConstraints(
                          minWidth: 48.r,
                          minHeight: 48.r,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlaceholderImage() {
    return Container(
      color: AppColors.surfaceDark,
      child: Center(
        child: Icon(
          Icons.image_outlined,
          color: AppColors.textMutedDark,
          size: AppDimensions.iconXxl.r,
        ),
      ),
    );
  }

  String _formatDateRange(DateTime start, DateTime end) {
    final startDay = start.day;
    final endDay = end.day;
    final month = _getMonthAbbr(start.month);
    final year = start.year;

    if (start.month == end.month && start.year == end.year) {
      return '$month $startDay-$endDay, $year';
    }
    return '$month $startDay - ${_getMonthAbbr(end.month)} $endDay, $year';
  }

  String _getMonthAbbr(int month) {
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
                    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return months[month - 1];
  }
}

class _EventTag extends StatelessWidget {
  final String label;

  const _EventTag({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color: Colors.white.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelMedium?.copyWith(
          color: Colors.white.withOpacity(0.8),
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}
