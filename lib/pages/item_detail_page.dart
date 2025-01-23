// item_detail_page.dart
import 'package:flutter/material.dart';
import 'package:localrental_flutter/models/item_display_model.dart';
<<<<<<< HEAD
import 'package:flutter_carousel_widget/flutter_carousel_widget.dart';
import 'package:video_player/video_player.dart';
import 'package:cached_network_image/cached_network_image.dart';

class ItemDetailPage extends StatefulWidget {
=======

class ItemDetailPage extends StatelessWidget {
>>>>>>> 695ea4201ba1ae45ce934cdfedd50e1c631a7520
  final ItemDisplayModel item;

  const ItemDetailPage({super.key, required this.item});

  @override
<<<<<<< HEAD
  State<ItemDetailPage> createState() => _ItemDetailPageState();
}

class _ItemDetailPageState extends State<ItemDetailPage> {
  final Map<String, VideoPlayerController> _controllers = {};
  int _currentMediaIndex = 0;

  @override
  void initState() {
    super.initState();
    _initializeVideoControllers();
  }

  Future<void> _initializeVideoControllers() async {
    for (int i = 0; i < widget.item.mediaUrls.length; i++) {
      if (widget.item.isVideo[i]) {
        final controller = VideoPlayerController.networkUrl(
            Uri.parse(widget.item.mediaUrls[i])
        );
        await controller.initialize();
        _controllers[widget.item.mediaUrls[i]] = controller;
      }
    }
    setState(() {});
  }

  @override
  void dispose() {
    for (var controller in _controllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  Widget _buildMediaWidget(String url, bool isVideo) {
    if (isVideo) {
      final controller = _controllers[url];
      if (controller == null) return const CircularProgressIndicator();

      return AspectRatio(
        aspectRatio: controller.value.aspectRatio,
        child: Stack(
          alignment: Alignment.center,
          children: [
            VideoPlayer(controller),
            IconButton(
              icon: Icon(
                controller.value.isPlaying ? Icons.pause : Icons.play_arrow,
                size: 50,
                color: Colors.white,
              ),
              onPressed: () {
                setState(() {
                  controller.value.isPlaying
                      ? controller.pause()
                      : controller.play();
                });
              },
            ),
          ],
        ),
      );
    } else {
      return CachedNetworkImage(
        imageUrl: url,
        fit: BoxFit.cover,
        placeholder: (context, url) => const CircularProgressIndicator(),
        errorWidget: (context, url, error) => const Icon(Icons.error),
      );
    }
  }

  @override
=======
>>>>>>> 695ea4201ba1ae45ce934cdfedd50e1c631a7520
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Item Details'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
<<<<<<< HEAD
            if (widget.item.mediaUrls.isNotEmpty)
              FlutterCarousel(
                options: CarouselOptions(
                  height: 300.0,
                  showIndicator: true,
                  slideIndicator: const CircularSlideIndicator(),
                  onPageChanged: (index, reason) {
                    setState(() {
                      _currentMediaIndex = index;
                      for (final controller in _controllers.values) {
                        controller.pause();
                      }
                    });
                  },
                ),
                items: List.generate(
                  widget.item.mediaUrls.length,
                      (index) => _buildMediaWidget(
                    widget.item.mediaUrls[index],
                    widget.item.isVideo[index],
                  ),
                ),
              ),
            const SizedBox(height: 32),
            Text(
              widget.item.name,
=======
            Center(
              child: Container(
                height: 200,
                width: 200,
                decoration: BoxDecoration(
                  color: item.boxColor.withValues(alpha: 77),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Icon(
                  Icons.inventory,
                  size: 80,
                  color: Colors.black54,
                ),
              ),
            ),
            const SizedBox(height: 32),
            Text(
              item.name,
>>>>>>> 695ea4201ba1ae45ce934cdfedd50e1c631a7520
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Text(
<<<<<<< HEAD
              '\$${widget.item.price} ${widget.item.priceType == 'per_day' ? '/day' : '/hour'}',
=======
              '\$${item.price} ${item.priceType == 'per_day' ? '/day' : '/hour'}',
>>>>>>> 695ea4201ba1ae45ce934cdfedd50e1c631a7520
              style: const TextStyle(
                fontSize: 18,
                color: Color(0xff92A3FD),
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 16),
            const Text(
              'Description:',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
<<<<<<< HEAD
              widget.item.description,
=======
              item.description,
>>>>>>> 695ea4201ba1ae45ce934cdfedd50e1c631a7520
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 16),
            const Text(
              'Tags:',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8.0,
              runSpacing: 4.0,
<<<<<<< HEAD
              children: widget.item.tags.map((tag) {
=======
              children: item.tags.map((tag) {
>>>>>>> 695ea4201ba1ae45ce934cdfedd50e1c631a7520
                return Chip(
                  label: Text(tag),
                  backgroundColor: const Color(0xff92A3FD).withAlpha(77),
                );
              }).toList(),
            ),
            // Add more details or actions here as needed
          ],
        ),
      ),
    );
  }
}
