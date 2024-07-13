import 'dart:convert';

class JsonUtils {
  static String? toJsonList(List<dynamic>? items) {
    if (items != null) {
      const jsonEncoder = JsonEncoder();
      return jsonEncoder.convert(items);
    }
    return null;
  }
}
