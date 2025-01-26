import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:localrental_flutter/models/item_model.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../services/imgur_service.dart';

class AddItemPage extends StatefulWidget {
  const AddItemPage({super.key});

  @override
  State<AddItemPage> createState() => _AddItemPageState();
}

class _AddItemPageState extends State<AddItemPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _priceController = TextEditingController();
  String _selectedPriceType = 'per_day';
  final List<String> _selectedTags = [];
  bool _isLoading = false;
  final _quantityController = TextEditingController();
  final List<File> _selectedMedia = [];
  final List<bool> _isVideo = [];
  final ImagePicker _picker = ImagePicker();
  bool _uploadingMedia = false;
  int _featuredImageIndex = -1;
  final List<String> _selectedCategories = [];

  final List<String> _availableCategories = [
    'Electronics',
    'Sports',
    'Entertainment',
    'Beauty',
    'Cooking',
    'Fitness',
    'Travel',
  ];

  // Predefined tags
  final List<String> _availableTags = [
    'Fragile',
    'Heavy',
    'Electronic',
    'Outdoor',
    'Indoor',
    'Tools',
    'Sports',
    'Entertainment',
  ];

  Future<void> _pickMedia(ImageSource source, bool isVideo) async {
    try {
      if (isVideo) {
        final XFile? file = await _picker.pickVideo(
          source: source,
          maxDuration: const Duration(seconds: 30), // Limit video duration
        );

        if (file != null) {
          final fileSize = await file.length();
          if (fileSize > 200 * 1024 * 1024) { // 200MB limit
            if (!mounted) return;
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Video is too large. Maximum size is 200MB'),
                backgroundColor: Colors.red,
              ),
            );
            return;
          }
          setState(() {
            _selectedMedia.add(File(file.path));
            _isVideo.add(true);
          });
        }
      } else {
        final XFile? file = await _picker.pickImage(source: source);
        if (file != null) {
          setState(() {
            _selectedMedia.add(File(file.path));
            _isVideo.add(false);
          });
        }
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<List<String>> _uploadMedia() async {
    List<String> urls = [];
    for (int i = 0; i < _selectedMedia.length; i++) {
      final bytes = await _selectedMedia[i].readAsBytes();
      final url = await ImgurService.uploadFile(
        bytes,
        'item_media_${DateTime.now().millisecondsSinceEpoch}',
        isVideo: _isVideo[i],
      );
      if (url != null) urls.add(url);
    }
    return urls;
  }

  void _resetForm() {
    setState(() {
      _nameController.clear();
      _descriptionController.clear();
      _priceController.clear();
      _quantityController.clear();
      _selectedPriceType = 'per_day';
      _selectedTags.clear();
      _selectedMedia.clear();
      _isVideo.clear();
      _isLoading = false;
      _uploadingMedia = false;
      _featuredImageIndex = -1;
      _selectedCategories.clear();
    });
  }

  Future<void> _submitItem() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedTags.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select at least one tag'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    if (_selectedMedia.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please add at least one image'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    if (_featuredImageIndex == -1) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a featured image'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    if (_selectedCategories.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select at least one category'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    try {
      setState(() {
        _isLoading = true;
        _uploadingMedia = true;
      });

      final mediaUrls = await _uploadMedia();

      // Check if media upload was successful
      if (mediaUrls.isEmpty) {
        throw Exception('Failed to upload media files');
      }

      // Ensure featured image index is valid
      final featuredImageUrl = _featuredImageIndex < mediaUrls.length
          ? mediaUrls[_featuredImageIndex]
          : mediaUrls[0];

      final user = FirebaseAuth.instance.currentUser;
      if (user == null) throw Exception('User not authenticated');

      final databaseRef = FirebaseDatabase.instance.ref();
      final newItemRef = databaseRef.child('items').push();

      final item = ItemModel(
        id: newItemRef.key!,
        name: _nameController.text.trim(),
        description: _descriptionController.text.trim(),
        price: double.parse(_priceController.text),
        priceType: _selectedPriceType,
        tags: _selectedTags,
        userId: user.uid,
        quantity: int.parse(_quantityController.text),
        mediaUrls: mediaUrls,
        isVideo: _isVideo,
        featuredImageUrl: featuredImageUrl,
        categories: _selectedCategories,
      );

      await newItemRef.set(item.toJson());

      if (!mounted) return;

      // Clear loading states
      setState(() {
        _isLoading = false;
        _uploadingMedia = false;
      });

      // Reset form
      _resetForm();

      // Show success message and navigate back to home
      if (!mounted) return;

      // Navigate back to home and replace the current page
      Navigator.of(context).pushReplacementNamed('/home');

      // Show success message after navigation
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Item added successfully!'),
          backgroundColor: Color(0xff92A3FD),
          duration: Duration(seconds: 2),
        ),
      );

    } catch (e) {
      if (!mounted) return;

      setState(() {
        _isLoading = false;
        _uploadingMedia = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString()}'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  void _showMediaSourceDialog(bool isVideo) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(isVideo ? 'Add Video' : 'Add Image'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Choose from Gallery'),
              onTap: () {
                Navigator.pop(context);
                _pickMedia(ImageSource.gallery, isVideo);
              },
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Take from Camera'),
              onTap: () {
                Navigator.pop(context);
                _pickMedia(ImageSource.camera, isVideo);
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: true,
      onPopInvoked: (_) {
        _resetForm();
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Add Item'),
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
          elevation: 0,
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Name Field
                    TextFormField(
                      controller: _nameController,
                      decoration: InputDecoration(
                        labelText: 'Item Name',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        prefixIcon: const Icon(Icons.inventory),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter item name';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Description Field
                    TextFormField(
                      controller: _descriptionController,
                      decoration: InputDecoration(
                        labelText: 'Description',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        prefixIcon: const Icon(Icons.description),
                      ),
                      maxLines: 3,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter item description';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Price Field with Type Dropdown
                    Row(
                      children: [
                        Expanded(
                          flex: 2,
                          child: TextFormField(
                            controller: _priceController,
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                              labelText: 'Price',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                              prefixIcon: const Icon(Icons.attach_money),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter price';
                              }
                              if (double.tryParse(value) == null) {
                                return 'Please enter a valid number';
                              }
                              return null;
                            },
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            value: _selectedPriceType,
                            decoration: InputDecoration(
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
                            items: const [
                              DropdownMenuItem(
                                value: 'per_hour',
                                child: Text('Per Hour'),
                              ),
                              DropdownMenuItem(
                                value: 'per_day',
                                child: Text('Per Day'),
                              ),
                            ],
                            onChanged: (value) {
                              if (value != null) {
                                setState(() => _selectedPriceType = value);
                              }
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Quantity Field
                    TextFormField(
                      controller: _quantityController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: 'Quantity',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        prefixIcon: const Icon(Icons.inventory),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter quantity';
                        }
                        if (int.tryParse(value) == null) {
                          return 'Please enter a valid number';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Tags Section
                    const Text(
                      'Select Tags',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      children: _availableTags.map((tag) {
                        final isSelected = _selectedTags.contains(tag);
                        return FilterChip(
                          label: Text(tag),
                          selected: isSelected,
                          onSelected: (selected) {
                            setState(() {
                              if (selected) {
                                _selectedTags.add(tag);
                              } else {
                                _selectedTags.remove(tag);
                              }
                            });
                          },
                          selectedColor: const Color(0xff92A3FD),
                          checkmarkColor: Colors.white,
                          labelStyle: TextStyle(
                            color: isSelected ? Colors.white : Colors.black,
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 16),

                    // Category Selection
                    _buildCategorySelection(),
                    const SizedBox(height: 24),

                    // Media Selection Section
                    const Text(
                      'Add Images/Videos',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),

                    // Display selected media previews
                    _buildMediaPreview(),
                    const SizedBox(height: 16),

                    // Media Selection Buttons
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        ElevatedButton.icon(
                          onPressed: () => _showMediaSourceDialog(false),
                          icon: const Icon(Icons.photo_library),
                          label: const Text('Add Image'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xff92A3FD),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                        ),
                        ElevatedButton.icon(
                          onPressed: () => _showMediaSourceDialog(true),
                          icon: const Icon(Icons.video_library),
                          label: const Text('Add Video'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xff92A3FD),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Submit Button with padding at bottom
                    Padding(
                      padding: EdgeInsets.only(
                        top: 24.0,
                        bottom: MediaQuery.of(context).padding.bottom + 24.0, // Add extra padding for system navigation
                      ),
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _submitItem,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xff92A3FD),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        child: _isLoading
                            ? const CircularProgressIndicator(color: Colors.white)
                            : const Text(
                          'Add Item',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              // Add permanent bottom padding
              SizedBox(height: MediaQuery.of(context).padding.bottom + 80), // 80dp for navigation bar + extra padding
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMediaPreview() {
    if (_selectedMedia.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Selected Media:',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 100,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: _selectedMedia.length,
            itemBuilder: (context, index) {
              final isSelected = index == _featuredImageIndex;
              return Stack(
                children: [
                  GestureDetector(
                    onTap: () {
                      if (!_isVideo[index]) {
                        setState(() {
                          _featuredImageIndex = index;
                        });
                      }
                    },
                    child: Container(
                      margin: const EdgeInsets.only(right: 8),
                      width: 100,
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: isSelected ? const Color(0xff92A3FD) : Colors.grey,
                          width: isSelected ? 2 : 1,
                        ),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Stack(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: _isVideo[index]
                                ? const Icon(Icons.video_file, size: 50)
                                : Image.file(
                              _selectedMedia[index],
                              fit: BoxFit.cover,
                              height: 100,
                              width: 100,
                            ),
                          ),
                          if (!_isVideo[index])
                            Positioned(
                              bottom: 4,
                              right: 4,
                              child: Container(
                                padding: const EdgeInsets.all(4),
                                decoration: BoxDecoration(
                                  color: isSelected ? const Color(0xff92A3FD) : Colors.white,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  isSelected ? 'Featured' : 'Tap to feature',
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: isSelected ? Colors.white : Colors.black,
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                  Positioned(
                    top: 4,
                    right: 12,
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          if (_featuredImageIndex == index) {
                            _featuredImageIndex = -1;
                          } else if (_featuredImageIndex > index) {
                            _featuredImageIndex--;
                          }
                          _selectedMedia.removeAt(index);
                          _isVideo.removeAt(index);
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.all(2),
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.close, size: 20),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildCategorySelection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Select Categories',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          children: _availableCategories.map((category) {
            final isSelected = _selectedCategories.contains(category);
            return FilterChip(
              label: Text(category),
              selected: isSelected,
              onSelected: (selected) {
                setState(() {
                  if (selected) {
                    _selectedCategories.add(category);
                  } else {
                    _selectedCategories.remove(category);
                  }
                });
              },
              selectedColor: const Color(0xff92A3FD),
              checkmarkColor: Colors.white,
              labelStyle: TextStyle(
                color: isSelected ? Colors.white : Colors.black,
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _quantityController.dispose();
    super.dispose();
  }
}
