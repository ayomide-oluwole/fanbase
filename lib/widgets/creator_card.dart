import 'package:flutter/material.dart';
import '../models/creator_model.dart';

class CreatorCard extends StatelessWidget {
  final CreatorModel creator;
  final VoidCallback onTap;

  const CreatorCard({Key? key, required this.creator, required this.onTap}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: const Color(0xFF1E1E1E),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: creator.isLive ? Colors.redAccent : Colors.transparent,
          width: 2,
        ),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(
            children: [
              // Creator Hero Image
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(
                  creator.heroImageUrl.isNotEmpty ? creator.heroImageUrl : 'https://via.placeholder.com/80',
                  width: 60,
                  height: 60,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => 
                    Container(width: 60, height: 60, color: Colors.grey[800]),
                ),
              ),
              const SizedBox(width: 16),
              // Name and Status
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      creator.name,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          creator.isLive ? Icons.radio_button_checked : Icons.circle,
                          color: creator.isLive ? Colors.redAccent : Colors.grey,
                          size: 12,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          creator.isLive ? 'LIVE' : 'Offline',
                          style: TextStyle(
                            color: creator.isLive ? Colors.redAccent : Colors.grey,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          '${(creator.followerCount / 1000).toStringAsFixed(1)}k fans',
                          style: const TextStyle(color: Colors.grey, fontSize: 12),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: Colors.grey),
            ],
          ),
        ),
      ),
    );
  }
}
