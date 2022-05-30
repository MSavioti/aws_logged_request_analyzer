class Request {
  final String url;
  final String requestType;
  final String contentType;
  final DateTime timestamp;
  final String host;
  final String referer;
  final String status;
  final String ip;
  final String httpUserAgent;

  Request({
    required this.url,
    required this.requestType,
    required this.contentType,
    required this.timestamp,
    required this.host,
    required this.referer,
    required this.status,
    required this.ip,
    required this.httpUserAgent,
  });

  factory Request.fromMap(Map<String, dynamic> map) {
    final String timestamp = map["timestamp_iso8601"] ?? '';
    String url = map["request_url"] ?? '';

    if (url.isNotEmpty && url.contains('?')) {
      url = url.split('?').first;
    }

    String _contentType = map["content_type"] ?? '';

    if (_contentType.contains(';')) {
      _contentType = _contentType.split(';').first;
    }

    return Request(
      url: url,
      requestType: map["request_type"] ?? '',
      contentType: _contentType,
      timestamp: DateTime.tryParse(timestamp) ?? DateTime(0),
      host: map["http_host"] ?? '',
      referer: map["http_referer"] ?? '',
      status: map["status"] ?? '',
      ip: map["remote_addr"] ?? '',
      httpUserAgent: map["http_user_agent"] ?? '',
    );
  }

  @override
  String toString() {
    final buffer = StringBuffer('\n');
    buffer.write('Request content:\n');
    buffer.write('URL: $url\n');
    buffer.write('Request type: $requestType\n');
    buffer.write('Timestamp: $timestamp\n');
    buffer.write('HTTP host: $host\n');
    buffer.write('HTTP referer: $referer\n');
    buffer.write('Status code: $status\n');
    buffer.write('IP: $ip\n');
    buffer.write('HTTP User Agent: $httpUserAgent\n');
    return buffer.toString();
  }
}
