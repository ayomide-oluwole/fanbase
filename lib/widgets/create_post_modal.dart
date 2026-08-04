import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../services/post_service.dart';

class CreatePostModal extends StatefulWidget {
  final String creatorId;
  final String streamId;
  final String userId;

  const CreatePostModal({
    Key? key,
    required this.creatorId,
    required this.streamId,
    required this.userId,
  }) : super(key: key);

  @override
  State<CreatePostModal> createState() => _CreatePostModalState();
}

class _CreatePostModalState extends State<CreatePostModal> {
  final TextEditingController _textController = TextEditingController();
  final PostService _postService = PostService();
  final ImagePicker _picker = ImagePicker();
  
  XFile? _selectedImage;
  bool _isPosting = false;

  Future<void> _pickImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() => _selectedImage = image);
    }
  }

  Future<void> _submitPost() async {
    if (_textController.text.isEmpty && _selectedImage == null) return;

    setState(() => _isPosting = true);

    try {
      await _postService.createPost(
        creatorId: widget.creatorId,
        streamId: widget.streamId,
        text: _textController.text,
        imageFile: _selectedImage,
        userId: widget.userId,
        isPremium: false, // Hardcoded to standard 24h user for now
      );
      Navigator.pop(context); // Close modal on success
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error posting. Please try again.')),
      );
      setState(() => _isPosting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: Color(0xFF1E1E1E),
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'Share a Moment',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _textController,
            maxLines: 3,
            autofocus: true,
            decoration: const InputDecoration(
              hintText: 'What\'s happening in the stream?',
            ),
          ),
          const SizedBox(height: 12),
          // Image Preview
          if (_selectedImage != null)
            Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.file(File(_selectedImage!.path), height: 150, fit: BoxFit.cover),
                ),
                Positioned(
                  top: 4, right: 4,
                  child: GestureDetector(
                    onTap: () => setState(() => _selectedImage = null),
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(color: Colors.black54, shape: BoxShape.circle),
                      child: const Icon(Icons.close, size: 16, color: Colors.white),
                    ),
                  ),
                ),
              ],
            )
          else
            Align(
              alignment: Alignment.centerLeft,
              child: TextButton.icon(
                icon: const Icon(Icons.image_outlined),
                label: const Text('Add Image (Watermarked)'),
                onPressed: _pickImage,
              ),
            ),
          const SizedBox(height: 16),
          // Submit Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.indigoAccent,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: _isPosting ? null : _submitPost,
              child: _isPosting
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text('Post to Community (Expires in 24h)'),
            ),
          ),
          const SizedBox(height: 20), // Bottom safe area spacing
        ],
      ),
    );
  }
}
