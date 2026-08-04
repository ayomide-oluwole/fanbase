import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class EphemeralPostWidget extends StatelessWidget {
  final QueryDocumentSnapshot postData;
  final int timeLeftHours;

  const EphemeralPostWidget({
    Key? key, 
    required this.postData, 
    required this.timeLeftHours,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final data = postData.data() as Map<String, dynamic>;
    final String text = data['text'] ?? '';
    final String? imageUrl = data['imageUrl'];

    return Card(
      color: const Color(0xFF1E1E1E),
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header: Username & Expiry Indicator
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: Colors.grey[800],
                      child: const Icon(Icons.person, color: Colors.grey, size: 18),
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      'FanUser123', // Replace with actual user data later
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                    ),
                  ],
                ),
                // Ephemeral Indicator (WhatsApp Status style)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.black54,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.hourglass_bottom, size: 12, color: Colors.grey),
                      const SizedBox(width: 4),
                      Text(
                        '${timeLeftHours}h left',
                        style: const TextStyle(fontSize: 10, color: Colors.grey),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            // Post Text
            if (text.isNotEmpty)
              Text(
                text,
                style: const TextStyle(fontSize: 15, color: Colors.white70),
              ),
            // Post Image
            if (imageUrl != null && imageUrl.isNotEmpty) ...[
              const SizedBox(height: 12),
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  imageUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => 
                    Container(height: 200, color: Colors.grey[900]), // Fallback if image fails
                ),
              ),
            ],
            const SizedBox(height: 12),
            // Actions (Reactions/Comments)
            Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.favorite_border, color: Colors.grey, size: 20),
                  onPressed: () {},
                ),
                const Text('12', style: TextStyle(color: Colors.grey, fontSize: 12)),
                const SizedBox(width: 16),
                IconButton(
                  icon: const Icon(Icons.chat_bubble_outline, color: Colors.grey, size: 20),
                  onPressed: () {},
                ),
                const Text('3', style: TextStyle(color: Colors.grey, fontSize: 12)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
