class DateFormatter {
  // Format any date string into a standardized format
  static String formatDate(String? dateString) {
    if (dateString == null || dateString.isEmpty) {
      return '';
    }
    
    try {
      // Handle ISO format with T separator
      if (dateString.contains('T')) {
        final datePart = dateString.split('T')[0];
        return datePart; // Returns YYYY-MM-DD
      }
      
      // Handle date string with Z suffix (UTC indicator)
      if (dateString.contains('Z')) {
        final cleanedDate = dateString.replaceAll('Z', '');
        if (cleanedDate.contains('T')) {
          return cleanedDate.split('T')[0]; // Returns YYYY-MM-DD
        }
      }
      
      // For dates that are just text with no specific format
      // Just take the first 10 characters if longer
      return dateString.length > 10 ? dateString.substring(0, 10) : dateString;
    } catch (e) {
      print('Error formatting date: $e');
      return dateString;
    }
  }
  
  // Format with a prefix like "Due:" or "Deadline:"
  static String formatWithPrefix(String prefix, String? dateString) {
    final formattedDate = formatDate(dateString);
    if (formattedDate.isEmpty) {
      return '';
    }
    return '$prefix $formattedDate';
  }
  
  // Format specifically for deadlines
  static String formatDeadline(String? dateString) {
    return formatWithPrefix('Deadline:', dateString);
  }
  
  // Format specifically for published dates
  static String formatPublished(String? dateString) {
    return formatWithPrefix('Published:', dateString);
  }
}