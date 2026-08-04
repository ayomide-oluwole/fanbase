import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloudinary_public/cloudinary_public.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class PostService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  
  // Initialize Cloudinary (FREE TIER - NO CREDIT CARD)
  // TODO: Replace 'YOUR_CLOUD_NAME' and 'YOUR_UNSIGNED_PRESET' with your Cloudinary details
  final cloudinary = CloudinaryPublic('l4pihnnk', 'fanbase_unsigned', cache: false);

  Future<void> createPost({
    required String creatorId,
    required String streamId,
    required String text,
    XFile? imageFile,
    required String userId,
    bool isPremium = false, // Defaulting to standard 24h for now
  }) async {
    String? imageUrl;

    // 1. Upload image to Cloudinary if selected
    if (imageFile != null) {
      try {
        CloudinaryResponse response = await cloudinary.uploadFile(
          CloudinaryFile.fromFile(imageFile.path, resourceType: CloudinaryResourceType.Image),
        );
        imageUrl = response.secureUrl;
      } catch (e) {
        throw Exception("Failed to upload image.");
      }
    }

    // 2. Calculate Expiry Time (24h or 72h based on premium status)
    final expiryDuration = isPremium ? const Duration(hours: 72) : const Duration(hours: 24);
    final expiresAt = Timestamp.fromDate(DateTime.now().add(expiryDuration));

    // 3. Save to Firestore (Tier 1: Ephemeral)
    await _db.collection('creators/$creatorId/streams/$streamId/posts').add({
      'authorId': userId,
      'text': text,
      'imageUrl': imageUrl,
      'createdAt': FieldValue.serverTimestamp(),
      'expiresAt': expiresAt, // The free-tier client-side auto-delete trigger
    });

    // 4. Update Tier 2: Permanent User Stats Ledger (Independent of post lifecycle)
    await _db.collection('users').doc(userId).set({
      'totalPosts': FieldValue.increment(1)
    }, SetOptions(merge: true));
  }
}
