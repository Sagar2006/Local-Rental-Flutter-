import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:localrental_flutter/models/item_display_model.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

// Comment out these imports for now
// import 'package:firebase_storage/firebase_storage.dart';
// import 'package:flutter_tags_x/flutter_tags_x.dart';

class EditItemPage extends StatefulWidget {
  final ItemDisplayModel item;

  const EditItemPage({super.key, required this.item});

  @override
  State<EditItemPage> createState() => _EditItemPageState();
}

class _EditItemPageState extends State<EditItemPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _dailyPriceController = TextEditingController();
  final _hourlyPriceController = TextEditingController();
  final _tagController = TextEditingController();

  String _selectedPriceType = 'per_day';
  bool _isLoading = false;
  List<String> _tags = [];
  List<String> _mediaUrls = [];
  List<bool> _isVideo = [];
  final List<File> _newMediaFiles = [];
  final List<bool> _newMediaIsVideo = [];

  @override
  void initState() {
    super.initState();
    // Initialize controllers with existing item data
    _nameController.text = widget.item.name;
    _descriptionController.text = widget.item.description;
    _dailyPriceController.text = widget.item.dailyPrice?.toString() ?? '';
    _hourlyPriceController.text = widget.item.hourlyPrice?.toString() ?? '';
    _selectedPriceType = widget.item.priceType;
    _tags = List.from(widget.item.tags);
    _mediaUrls = List.from(widget.item.mediaUrls);
    _isVideo = List.from(widget.item.isVideo);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _dailyPriceController.dispose();
    _hourlyPriceController.dispose();
    _tagController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _newMediaFiles.add(File(pickedFile.path));
        _newMediaIsVideo.add(false);
      });
    }
  }

  Future<void> _pickVideo() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickVideo(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _newMediaFiles.add(File(pickedFile.path));
        _newMediaIsVideo.add(true);
      });
    }
  }

  void _removeExistingMedia(int index) {
    setState(() {
      _mediaUrls.removeAt(index);
      _isVideo.removeAt(index);
    });
  }

  void _removeNewMedia(int index) {
    setState(() {
      _newMediaFiles.removeAt(index);
      _newMediaIsVideo.removeAt(index);
    });
  }

  // Temporarily modify this method to not use Firebase Storage
  Future<List<String>> _uploadNewMedia() async {
    // For now, return empty list since we can't upload without Firebase Storage
    return [];

    // Original implementation (commented out)
    /*
    if (_newMediaFiles.isEmpty) return [];

    final List<String> uploadedUrls = [];
    final storage = FirebaseStorage.instance;
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) throw Exception('User not authenticated');

    for (int i = 0; i < _newMediaFiles.length; i++) {
      final file = _newMediaFiles[i];
      final isVideo = _newMediaIsVideo[i];
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final path = 'items/${currentUser.uid}/${timestamp}_${file.path.split('/').last}';
      
      final ref = storage.ref().child(path);
      await ref.putFile(file);
      final downloadUrl = await ref.getDownloadURL();
      uploadedUrls.add(downloadUrl);
      _isVideo.add(isVideo);
    }

    return uploadedUrls;
    */
  }

  Future<void> _updateItem() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      // Upload any new media files
      // const newUrls = []; // Temporary empty list
      final newUrls = await _uploadNewMedia();
      final allMediaUrls = [..._mediaUrls, ...newUrls];

      // Prepare updated item data
      final updatedItem = {
        'id': widget.item.id,
        'name': _nameController.text,
        'description': _descriptionController.text,
        'dailyPrice': _selectedPriceType == 'per_day'
            ? double.parse(_dailyPriceController.text)
            : null,
        'hourlyPrice': _selectedPriceType == 'per_hour'
            ? double.parse(_hourlyPriceController.text)
            : null,
        'priceType': _selectedPriceType,
        'tags': _tags,
        'mediaUrls': allMediaUrls,
        'isVideo': _isVideo,
        'featuredImageUrl': allMediaUrls.isNotEmpty && !_isVideo[0]
            ? allMediaUrls[0]
            : widget.item.featuredImageUrl,
        'userId': widget.item.userId,
        'createdAt': widget.item.createdAt,
        'updatedAt': DateTime.now().millisecondsSinceEpoch,
      };

      // Update in Firebase
      final databaseRef = FirebaseDatabase.instance.ref();
      await databaseRef.child('items/${widget.item.id}').update(updatedItem);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Item updated successfully!'),
          backgroundColor: Color(0xff92A3FD),
          duration: Duration(seconds: 2),
        ),
      );

      Navigator.pop(context, true); // Return true to indicate successful update
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to update item: $e'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 2),
        ),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Item'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Media section
                    const Text(
                      'Item Media',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 10),
                    SizedBox(
                      height: 120,
                      child: ListView(
                        scrollDirection: Axis.horizontal,
                        children: [
                          // Existing media
                          ..._mediaUrls.asMap().entries.map((entry) {
                            final index = entry.key;
                            final url = entry.value;
                            return Stack(
                              children: [
                                Container(
                                  width: 120,
                                  margin: const EdgeInsets.only(right: 8),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(8),
                                    image: !_isVideo[index]
                                        ? DecorationImage(
                                            image: NetworkImage(url),
                                            fit: BoxFit.cover,
                                          )
                                        : null,
                                  ),
                                  child: _isVideo[index]
                                      ? const Center(
                                          child: Icon(Icons.play_circle,
                                              size: 40, color: Colors.white))
                                      : null,
                                ),
                                Positioned(
                                  top: 5,
                                  right: 5,
                                  child: GestureDetector(
                                    onTap: () => _removeExistingMedia(index),
                                    child: Container(
                                      padding: const EdgeInsets.all(4),
                                      decoration: const BoxDecoration(
                                        color: Colors.red,
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Icon(Icons.close,
                                          color: Colors.white, size: 16),
                                    ),
                                  ),
                                ),
                              ],
                            );
                          }),

                          // New media
                          ..._newMediaFiles.asMap().entries.map((entry) {
                            final index = entry.key;
                            final file = entry.value;
                            return Stack(
                              children: [
                                Container(
                                  width: 120,
                                  margin: const EdgeInsets.only(right: 8),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(8),
                                    image: !_newMediaIsVideo[index]
                                        ? DecorationImage(
                                            image: FileImage(file),
                                            fit: BoxFit.cover,
                                          )
                                        : null,
                                  ),
                                  child: _newMediaIsVideo[index]
                                      ? const Center(
                                          child: Icon(Icons.play_circle,
                                              size: 40, color: Colors.white))
                                      : null,
                                ),
                                Positioned(
                                  top: 5,
                                  right: 5,
                                  child: GestureDetector(
                                    onTap: () => _removeNewMedia(index),
                                    child: Container(
                                      padding: const EdgeInsets.all(4),
                                      decoration: const BoxDecoration(
                                        color: Colors.red,
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Icon(Icons.close,
                                          color: Colors.white, size: 16),
                                    ),
                                  ),
                                ),
                              ],
                            );
                          }),

                          // Add media buttons
                          GestureDetector(
                            onTap: _pickImage,
                            child: Container(
                              width: 120,
                              margin: const EdgeInsets.only(right: 8),
                              decoration: BoxDecoration(
                                color: Colors.grey[200],
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.add_photo_alternate, size: 40),
                                  Text('Add Image')
                                ],
                              ),
                            ),
                          ),
                          GestureDetector(
                            onTap: _pickVideo,
                            child: Container(
                              width: 120,
                              decoration: BoxDecoration(
                                color: Colors.grey[200],
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.videocam, size: 40),
                                  Text('Add Video')
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Item name
                    TextFormField(
                      controller: _nameController,
                      decoration: const InputDecoration(
                        labelText: 'Item Name',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter an item name';
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: 16),

                    // Item description
                    TextFormField(
                      controller: _descriptionController,
                      decoration: const InputDecoration(
                        labelText: 'Description',
                        border: OutlineInputBorder(),
                        alignLabelWithHint: true,
                      ),
                      maxLines: 5,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a description';
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: 16),

                    // Price type selection
                    const Text(
                      'Price Type',
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    Row(
                      children: [
                        Radio<String>(
                          value: 'per_day',
                          groupValue: _selectedPriceType,
                          onChanged: (String? value) {
                            setState(() {
                              _selectedPriceType = value!;
                            });
                          },
                        ),
                        const Text('Per Day'),
                        Radio<String>(
                          value: 'per_hour',
                          groupValue: _selectedPriceType,
                          onChanged: (String? value) {
                            setState(() {
                              _selectedPriceType = value!;
                            });
                          },
                        ),
                        const Text('Per Hour'),
                      ],
                    ),

                    const SizedBox(height: 16),

                    // Price fields
                    if (_selectedPriceType == 'per_day')
                      TextFormField(
                        controller: _dailyPriceController,
                        decoration: const InputDecoration(
                          labelText: 'Daily Price (\$)',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.attach_money),
                        ),
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter a price';
                          }
                          if (double.tryParse(value) == null) {
                            return 'Please enter a valid number';
                          }
                          return null;
                        },
                      ),

                    if (_selectedPriceType == 'per_hour')
                      TextFormField(
                        controller: _hourlyPriceController,
                        decoration: const InputDecoration(
                          labelText: 'Hourly Price (\$)',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.attach_money),
                        ),
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter a price';
                          }
                          if (double.tryParse(value) == null) {
                            return 'Please enter a valid number';
                          }
                          return null;
                        },
                      ),

                    const SizedBox(height: 16),

                    // Tags section - Replace Tags widget with a simple chip display for now
                    const Text(
                      'Tags',
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8.0,
                      children: _tags
                          .map((tag) => Chip(
                                label: Text(tag),
                                onDeleted: () {
                                  setState(() {
                                    _tags.remove(tag);
                                  });
                                },
                              ))
                          .toList(),
                    ),

                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _tagController,
                            decoration: const InputDecoration(
                              labelText: 'Add Tag',
                              border: OutlineInputBorder(),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton(
                          onPressed: () {
                            if (_tagController.text.isNotEmpty) {
                              setState(() {
                                _tags.add(_tagController.text);
                                _tagController.clear();
                              });
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xff92A3FD),
                          ),
                          child: const Text('Add'),
                        ),
                      ],
                    ),

                    const SizedBox(height: 24),

                    // Update button
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: _updateItem,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xff92A3FD),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          'Update Item',
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
            ),
    );
  }
}
