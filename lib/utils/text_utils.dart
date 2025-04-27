class TextUtils {
  /// Cleans HTML markup from API text
  static String cleanHtmlText(String? text) {
    if (text == null || text.isEmpty) {
      return '';
    }
    
    // Replace <br> tags with newline characters
    String cleaned = text.replaceAll('<br>', '\n');
    
    // Replace other common HTML tags
    cleaned = cleaned.replaceAll('<p>', '').replaceAll('</p>', '\n');
    cleaned = cleaned.replaceAll('&nbsp;', ' ');
    
    // Remove any other HTML tags that might be present
    cleaned = cleaned.replaceAll(RegExp(r'<[^>]*>'), '');
    
    return cleaned;
  }
}