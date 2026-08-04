class CreatorModel {
  final String id;
  final String name;
  final String youtubeChannelId;
  final bool isLive;
  final String? currentStreamId;
  final String heroImageUrl;
  final int followerCount;

  CreatorModel({
    required this.id,
    required this.name,
    required this.youtubeChannelId,
    required this.isLive,
    this.currentStreamId,
    required this.heroImageUrl,
    required this.followerCount,
  });

  factory CreatorModel.fromFirestore(Map<String, dynamic> data, String id) {
    return CreatorModel(
      id: id,
      name: data['name'] ?? 'Unknown Creator',
      youtubeChannelId: data['youtubeChannelId'] ?? '',
      isLive: data['isLive'] ?? false,
      currentStreamId: data['currentStreamId'],
      heroImageUrl: data['heroImageUrl'] ?? '',
      followerCount: data['followerCount'] ?? 0,
    );
  }
}
