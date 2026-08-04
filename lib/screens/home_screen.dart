import 'package:flutter/material.dart';
import '../services/firestore_service.dart';
import '../models/creator_model.dart';
import '../widgets/creator_card.dart';
import 'creator_page.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final FirestoreService _firestoreService = FirestoreService();

  void _showExternalLinkConfirmation() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1E1E1E),
        title: const Text('Leave App?', style: TextStyle(color: Colors.white)),
        content: const Text(
          'You are about to open an external link in your browser. Do you want to continue?',
          style: TextStyle(color: Colors.grey),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              // Add url_launcher logic here later
            },
            child: const Text('Continue', style: TextStyle(color: Colors.indigoAccent)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Fanbase', style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: const Icon(Icons.person_outline),
            onPressed: () {
              // Navigate to profile/auth screen later
            },
          ),
        ],
      ),
      body: StreamBuilder<List<CreatorModel>>(
        stream: _firestoreService.getCreators(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Text(
                'No creators found.\nAdd a creator document in Firestore!',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey),
              ),
            );
          }

          // Sort creators: Live first, then by follower count (Flagship prioritization)
          final creators = snapshot.data!;
          creators.sort((a, b) {
            if (a.isLive != b.isLive) return a.isLive ? -1 : 1;
            return b.followerCount.compareTo(a.followerCount);
          });

          return ListView(
            children: [
              // Featured Banner (16:9)
              GestureDetector(
                onTap: _showExternalLinkConfirmation,
                child: Container(
                  margin: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E1E1E),
                    borderRadius: BorderRadius.circular(16),
                    image: const DecorationImage(
                      image: NetworkImage('https://via.placeholder.com/640x360/1E1E1E/FFFFFF?text=Featured+Banner'),
                      fit: BoxFit.cover,
                    ),
                  ),
                  child: AspectRatio(
                    aspectRatio: 16 / 9,
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        gradient: LinearGradient(
                          begin: Alignment.bottomCenter,
                          end: Alignment.topCenter,
                          colors: [Colors.black.withOpacity(0.7), Colors.transparent],
                        ),
                      ),
                      padding: const EdgeInsets.all(16),
                      alignment: Alignment.bottomLeft,
                      child: const Text(
                        'Special Announcement',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: Text(
                  'CREATORS',
                  style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold, fontSize: 12),
                ),
              ),
              // Creator List
              ...creators.map((creator) => CreatorCard(
                creator: creator,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => CreatorPage(creator: creator),
                    ),
                  );
                },
              )).toList(),
              const SizedBox(height: 80), // Bottom padding for thumb reach
            ],
          );
        },
      ),
    );
  }
}
