import 'package:flutter/material.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/creator_model.dart';
import '../services/firestore_service.dart';
import '../widgets/ephemeral_post.dart';
import '../widgets/create_post_modal.dart';

class CreatorPage extends StatefulWidget {
  final CreatorModel creator;

  const CreatorPage({Key? key, required this.creator}) : super(key: key);

  @override
  State<CreatorPage> createState() => _CreatorPageState();
}

class _CreatorPageState extends State<CreatorPage> {
  final FirestoreService _firestoreService = FirestoreService();
  late YoutubePlayerController _ytController;
  bool _isBookmarked = false;

  @override
  void initState() {
    super.initState();
    // Initialize YouTube Player. 
    // If offline, currentStreamId is null, so we load a placeholder or empty string.
    String videoId = widget.creator.currentStreamId ?? '';
    
    _ytController = YoutubePlayerController(
      initialVideoId: videoId,
      flags: const YoutubePlayerFlags(
        autoPlay: true,
        mute: false,
      ),
    );
  }

  @override
  void dispose() {
    _ytController.dispose();
    super.dispose();
  }

  void _toggleBookmark() {
    // Auth Gate: Check if user is anonymous
    User? user = FirebaseAuth.instance.currentUser;
    if (user == null || user.isAnonymous) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please log in to bookmark moments.'),
          duration: Duration(seconds: 2),
        ),
      );
      Navigator.pushNamed(context, '/login');
      return;
    }

    setState(() {
      _isBookmarked = !_isBookmarked;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(_isBookmarked ? 'Moment Bookmarked!' : 'Bookmark Removed'),
        duration: const Duration(seconds: 1),
      ),
    );
    // TODO: Save to Tier 2 highlights collection in Firestore
  }

  @override
  Widget build(BuildContext context) {
    return YoutubePlayerBuilder(
      player: YoutubePlayer(
        controller: _ytController,
        showVideoProgressIndicator: true,
        progressColors: const ProgressBarColors(
          playedColor: Colors.indigoAccent,
          handleColor: Colors.indigo,
        ),
      ),
      builder: (context, player) {
        return Scaffold(
          appBar: AppBar(
            title: Text(widget.creator.name),
          ),
          // Floating Action Button for Post Creation (Only shows if stream is live)
          floatingActionButton: widget.creator.currentStreamId != null
              ? FloatingActionButton.extended(
                  onPressed: () {
                    // Auth Gate: Check if user is anonymous
                    User? user = FirebaseAuth.instance.currentUser;
                    if (user == null || user.isAnonymous) {
                      // Force Login
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Please log in to post.'),
                          duration: Duration(seconds: 2),
                        ),
                      );
                      Navigator.pushNamed(context, '/login');
                    } else {
                      // Allow Posting
                      showModalBottomSheet(
                        context: context,
                        isScrollControlled: true,
                        backgroundColor: Colors.transparent,
                        builder: (context) => Padding(
                          padding: EdgeInsets.only(
                            bottom: MediaQuery.of(context).viewInsets.bottom,
                          ),
                          child: CreatePostModal(
                            creatorId: widget.creator.id,
                            streamId: widget.creator.currentStreamId!,
                            // Now uses the actual logged-in user ID!
                            userId: user.uid, 
                          ),
                        ),
                      );
                    }
                  },
                  icon: const Icon(Icons.edit),
                  label: const Text('Post'),
                )
              : null,
          body: Column(
            children: [
              // YouTube Player (Adapts to full screen when rotated to landscape)
              AspectRatio(
                aspectRatio: 16 / 9,
                child: player,
              ),
              
              // Action Bar (One-handed thumb reach)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Catch Me Up (AI Recap)
                    TextButton.icon(
                      icon: const Icon(Icons.auto_awesome, size: 18),
                      label: const Text('Catch Me Up'),
                      onPressed: () {
                        // Show AI Recap Modal
                        showModalBottomSheet(
                          context: context,
                          backgroundColor: const Color(0xFF1E1E1E),
                          builder: (context) => Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('AI Stream Recap', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                                const SizedBox(height: 16),
                                const Text(
                                  'Speed started the stream by reacting to fan art, then played a game of FIFA, and finally attempted a backflip on camera.',
                                  style: TextStyle(color: Colors.grey),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                    // Moment Bookmarking
                    TextButton.icon(
                      icon: Icon(
                        _isBookmarked ? Icons.bookmark : Icons.bookmark_border,
                        color: _isBookmarked ? Colors.indigoAccent : Colors.grey,
                        size: 18,
                      ),
                      label: Text(
                        'Bookmark',
                        style: TextStyle(color: _isBookmarked ? Colors.indigoAccent : Colors.grey),
                      ),
                      onPressed: _toggleBookmark,
                    ),
                  ],
                ),
              ),

              // Required Disclaimer
              Container(
                width: double.infinity,
                color: const Color(0xFF1A1A1A),
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: Text(
                  'Unofficial fan companion. Not affiliated with or endorsed by ${widget.creator.name}.',
                  style: const TextStyle(color: Colors.grey, fontSize: 11, fontStyle: FontStyle.italic),
                  textAlign: TextAlign.center,
                ),
              ),

              // Community Feed (Ephemeral Posts)
              Expanded(
                child: widget.creator.currentStreamId == null
                    ? const Center(
                        child: Padding(
                          padding: EdgeInsets.all(32.0),
                          child: Text(
                            'Creator is offline. Ephemeral community feed is closed. Check back during the next stream!',
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Colors.grey),
                          ),
                        ),
                      )
                    : StreamBuilder(
                        stream: _firestoreService.getEphemeralPosts(
                          widget.creator.id,
                          widget.creator.currentStreamId!,
                        ),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState == ConnectionState.waiting) {
                            return const Center(child: CircularProgressIndicator());
                          }
                          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                            return const Center(
                              child: Text('No posts yet. Be the first!', style: TextStyle(color: Colors.grey)),
                            );
                          }

                          // Filter out expired posts visually just in case 
                          // the backend hasn't deleted them yet (Free Tier Workaround)
                          final now = DateTime.now();
                          final validPosts = snapshot.data!.docs.where((doc) {
                            final expiresAt = (doc['expiresAt'] as dynamic)?.toDate() as DateTime?;
                            return expiresAt == null || expiresAt.isAfter(now);
                          }).toList();

                          return ListView.builder(
                            padding: const EdgeInsets.only(bottom: 80),
                            itemCount: validPosts.length,
                            itemBuilder: (context, index) {
                              var post = validPosts[index];
                              // Calculate time remaining for UI indicator
                              final expiresAt = (post['expiresAt'] as dynamic).toDate() as DateTime;
                              final timeLeft = expiresAt.difference(now).inHours;

                              return EphemeralPostWidget(
                                postData: post,
                                timeLeftHours: timeLeft,
                              );
                            },
                          );
                        },
                      ),
              ),
            ],
          ),
        );
      },
    );
  }
}
