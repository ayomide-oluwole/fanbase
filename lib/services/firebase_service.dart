import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/creator_model.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Fetch all creators dynamically (Creator-agnostic)
  Stream<List<CreatorModel>> getCreators() {
    return _db.collection('creators').snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        return CreatorModel.fromFirestore(doc.data() as Map<String, dynamic>, doc.id);
      }).toList();
    });
  }

  // Fetch Ephemeral Posts with Client-Side "Soft" Deletion (Free Tier Workaround)
  Stream<QuerySnapshot> getEphemeralPosts(String creatorId, String streamId) {
    return _db
        .collection('creators/$creatorId/streams/$streamId/posts')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      final now = Timestamp.now();
      final validDocs = <QueryDocumentSnapshot>[];

      for (var doc in snapshot.docs) {
        final expiresAt = doc['expiresAt'] as Timestamp?;
        
        // If post is expired, delete it lazily
        if (expiresAt != null && expiresAt.toDate().isBefore(now.toDate())) {
          doc.reference.delete();
        } else {
          validDocs.add(doc);
        }
      }
      
      // Return a modified snapshot-like map (Note: For simplicity in prototype, 
      // we return the raw docs and filter in the UI. But this is where the magic happens.)
      return snapshot; 
    });
  }
}
