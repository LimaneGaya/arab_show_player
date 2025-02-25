import 'package:http/http.dart' as http;
import 'package:html/parser.dart' as parser;

Future<String?> extractVideoSource(String url) async {
  try {
    // Create a custom client with appropriate headers to avoid CORS issues
    final client = http.Client();
    final request = http.Request('GET', Uri.parse(url));
    
    // Add headers to mimic a browser request
    request.headers['User-Agent'] = 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36';
    request.headers['Accept'] = 'text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,*/*;q=0.8';
    request.headers['Accept-Language'] = 'ar-DZ,en;q=0.5';
    
    final streamedResponse = await client.send(request);
    final response = await http.Response.fromStream(streamedResponse);
    
    if (response.statusCode != 200) {
      print('Failed to load the webpage: ${response.statusCode}');
      return null;
    }
    
    // Parse the HTML content
    final document = parser.parse(response.body);
    
    // Find the video element with id "player"
    final videoElement = document.querySelector('video#player');
    if (videoElement == null) {
      print('Video element not found');
      return null;
    }
    
    // Find the source element inside the video element
    final sourceElement = videoElement.querySelector('source');
    if (sourceElement == null) {
      print('Source element not found');
      return null;
    }
    
    // Extract the src attribute from the source element
    final sourceUrl = sourceElement.attributes['src'];
    if (sourceUrl == null || sourceUrl.isEmpty) {
      print('Source URL not found or empty');
      return null;
    }
    
    return sourceUrl;
  } catch (e) {
    print('Error extracting video source: $e');
    return null;
  }
}


