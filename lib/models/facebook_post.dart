class FacebookPost {
  final String id;
  final String message;
  final String? imageUrl;
  final DateTime createdTime;
  final String permalink;
  final int likesCount;
  final int commentsCount;

  FacebookPost({
    required this.id,
    required this.message,
    this.imageUrl,
    required this.createdTime,
    required this.permalink,
    this.likesCount = 0,
    this.commentsCount = 0,
  });

  factory FacebookPost.fromJson(Map<String, dynamic> json) {
    return FacebookPost(
      id: json['id'] ?? '',
      message: json['message'] ?? '',
      imageUrl: json['full_picture'],
      createdTime: DateTime.parse(json['created_time'] ?? DateTime.now().toIso8601String()),
      permalink: json['permalink_url'] ?? '',
      likesCount: json['likes']?['summary']?['total_count'] ?? 0,
      commentsCount: json['comments']?['summary']?['total_count'] ?? 0,
    );
  }
}
