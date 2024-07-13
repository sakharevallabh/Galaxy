class ShareUtils {
  static String generateShareableDetails(Map<String, String> fields) {
    return fields.entries
        .map((entry) => '${entry.key}: ${entry.value}')
        .join('\n');
  }
}
