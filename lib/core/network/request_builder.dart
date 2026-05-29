// lib/core/network/request_builder.dart

import '../utils/constants/api_constants.dart';

class RequestBuilder {
  RequestBuilder._();

  /// Replace `{param}` placeholders in [template] with values from [pathParams].
  /// Throws [FormatException] if a placeholder has no matching value.
  static String buildPath(String template, Map<String, Object?> pathParams) {
    var result = template;
    final regex = RegExp(r"\{([^}]+)\}");
    for (final match in regex.allMatches(template)) {
      final key = match.group(1);
      if (key == null) continue;
      if (!pathParams.containsKey(key) || pathParams[key] == null) {
        throw FormatException('Missing required path param: $key for template $template');
      }
      result = result.replaceAll('{$key}', Uri.encodeComponent(pathParams[key].toString()));
    }
    return result;
  }

  /// Build full URL including base, api prefix, path and optional query params.
  /// If [requiredQueryKeys] is provided, ensure those keys are present in [queryParameters].
  static String buildFullUrl(
    String template,
    Map<String, Object?> pathParams, {
    Map<String, Object?>? queryParameters,
    List<String>? requiredQueryKeys,
  }) {
    final path = buildPath(template, pathParams);

    if (requiredQueryKeys != null) {
      for (final k in requiredQueryKeys) {
        if (queryParameters == null || !queryParameters.containsKey(k) || queryParameters[k] == null) {
          throw FormatException('Missing required query parameter: $k for endpoint $template');
        }
      }
    }

    final buffer = StringBuffer();
    buffer.write(ApiConstants.baseUrl);
    buffer.write(ApiConstants.apiPrefix);
    buffer.write(path);

    if (queryParameters != null && queryParameters.isNotEmpty) {
      final qp = queryParameters.entries
          .map((e) => '${Uri.encodeQueryComponent(e.key)}=${Uri.encodeQueryComponent(e.value.toString())}')
          .join('&');
      buffer.write('?$qp');
    }

    return buffer.toString();
  }
}
