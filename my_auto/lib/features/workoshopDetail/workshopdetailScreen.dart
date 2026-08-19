import 'package:flutter/material.dart';
import 'package:my_auto/core/model/workshop/index.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';

class WorkshopDetailScreen extends StatefulWidget {
  final Workshop workshop;
  final String imageBaseUrl;

  const WorkshopDetailScreen({
    super.key,
    required this.workshop,
    this.imageBaseUrl = 'https://your_image_base_url/',
  });

  @override
  State<WorkshopDetailScreen> createState() => _WorkshopDetailScreenState();
}

class _WorkshopDetailScreenState extends State<WorkshopDetailScreen> {
  bool isFavorite = false;

  String _formatOpeningHours(DateTime? from, DateTime? until) {
    if (from == null && until == null) return "No hours info";
    final format = DateFormat('HH:mm');
    final fromStr = from != null ? format.format(from) : '';
    final untilStr = until != null ? format.format(until) : '';
    return "$fromStr - $untilStr";
  }

  String _getFullImageUrl(String imagePath) {
    if (imagePath.startsWith('http://') || imagePath.startsWith('https://')) {
      return imagePath;
    }
    return widget.imageBaseUrl + imagePath;
  }

  void _toggleFavorite() {
    setState(() {
      isFavorite = !isFavorite;
    });
  }

  void _shareWorkshop() {
    final title = widget.workshop.title ?? "Workshop";
    final url = _getFullImageUrl(
      widget.workshop.images.isNotEmpty ? widget.workshop.images[0] : '',
    );
    final text = '$title\n$url';

    Share.share(text);
  }

  @override
  Widget build(BuildContext context) {
    final openingHours = _formatOpeningHours(
        widget.workshop.openFrom, widget.workshop.openUntil);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? Colors.black : Colors.grey[100],
      appBar: AppBar(
        backgroundColor: isDark ? Colors.black : Colors.white,
        elevation: 0,
        foregroundColor: isDark ? Colors.white : Colors.black87,
        title: Text(
          widget.workshop.title?.isNotEmpty == true
              ? widget.workshop.title!
              : "No title",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 22,
            letterSpacing: 0.4,
            color: isDark ? Colors.white : Colors.black87,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image with rounded corners, shadow, favorite & share icons
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color:
                        isDark ? Colors.black54 : Colors.grey.withOpacity(0.3),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Stack(
                  children: [
                    if (widget.workshop.images.isNotEmpty &&
                        widget.workshop.images[0].isNotEmpty)
                      Image.network(
                        _getFullImageUrl(widget.workshop.images[0]),
                        height: 230,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => Container(
                          height: 230,
                          color: Colors.grey[800],
                          child: const Center(
                            child: Icon(Icons.broken_image,
                                size: 80, color: Colors.grey),
                          ),
                        ),
                        loadingBuilder: (context, child, progress) {
                          if (progress == null) return child;
                          return SizedBox(
                            height: 230,
                            child: Center(
                              child: CircularProgressIndicator(
                                value: progress.expectedTotalBytes != null
                                    ? progress.cumulativeBytesLoaded /
                                        progress.expectedTotalBytes!
                                    : null,
                              ),
                            ),
                          );
                        },
                      )
                    else
                      Container(
                        height: 230,
                        color: Colors.grey[800],
                        child: const Center(
                          child: Icon(Icons.image_not_supported,
                              size: 80, color: Colors.grey),
                        ),
                      ),

                    // Favorite and Share icons
                    Positioned(
                      top: 12,
                      right: 12,
                      child: Row(
                        children: [
                          IconButton(
                            icon: Icon(
                              isFavorite
                                  ? Icons.favorite
                                  : Icons.favorite_border,
                              color: const Color.fromARGB(255, 250, 248, 248),
                              size: 28,
                            ),
                            onPressed: _toggleFavorite,
                            tooltip: isFavorite ? "Unfavorite" : "Favorite",
                          ),
                          const SizedBox(width: 8),
                          IconButton(
                            icon: const Icon(
                              Icons.share,
                              color: Colors.white,
                              size: 28,
                            ),
                            onPressed: _shareWorkshop,
                            tooltip: "Share",
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Title
            Text(
              widget.workshop.title ?? "No title",
              style: theme.textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : Colors.black87,
              ),
            ),

            const SizedBox(height: 14),

            // Opening hours
            if (openingHours != "No hours info")
              Row(
                children: [
                  Icon(Icons.access_time,
                      color: isDark ? Colors.blue[300] : Colors.blueAccent),
                  const SizedBox(width: 8),
                  Text(
                    openingHours,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: isDark ? Colors.blue[300] : Colors.blueAccent,
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),

            const SizedBox(height: 30),

            // Description
            if (widget.workshop.description != null &&
                widget.workshop.description!.trim().isNotEmpty)
              Text(
                widget.workshop.description!,
                style: theme.textTheme.bodyLarge?.copyWith(
                  height: 1.5,
                  fontSize: 16,
                  color: isDark ? Colors.grey[300] : Colors.grey[800],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
