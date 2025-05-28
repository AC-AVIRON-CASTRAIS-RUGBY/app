class ApiConfig {
  static const String baseUrl = 'http://192.168.1.75:3000/api';
  static const String serverBaseUrl = 'http://192.168.1.75:3000';
  static const int timeoutDuration = 30;
  
  // Method to resolve image URLs
  static String resolveImageUrl(String imageUrl) {
    if (imageUrl.startsWith('http://localhost:3000')) {
      return imageUrl.replaceFirst('http://localhost:3000', serverBaseUrl);
    }
    if (imageUrl.startsWith('/uploads/')) {
      return '$serverBaseUrl$imageUrl';
    }
    if (!imageUrl.startsWith('http')) {
      return '$serverBaseUrl/$imageUrl';
    }
    return imageUrl;
  }
}