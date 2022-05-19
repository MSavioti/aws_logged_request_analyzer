class Request {
  final String url; // "request_url"
  final String type; // "request_type"
  final DateTime timestamp; // "timestamp_iso8601"
  final String host; // "http_host"
  final String referer; // "http_referer"
  final String status; // "status"
  final String ip; // "remote_addr"

  Request({
    required this.url,
    required this.type,
    required this.timestamp,
    required this.host,
    required this.referer,
    required this.status,
    required this.ip,
  });

  factory Request.fromMap(Map<String, dynamic> map) {
    final String timestamp = map["timestamp_iso8601"] ?? '';

    return Request(
      url: map["request_url"] ?? '',
      type: map["request_type"] ?? '',
      timestamp: DateTime.tryParse(timestamp) ?? DateTime(0),
      host: map["http_host"] ?? '',
      referer: map["http_referer"] ?? '',
      status: map["status"] ?? '',
      ip: map["remote_addr"] ?? '',
    );
  }

  @override
  String toString() {
    final buffer = StringBuffer('\n');
    buffer.write('Request content:\n');
    buffer.write('URL: $url\n');
    buffer.write('Request type: $type\n');
    buffer.write('Timestamp: $timestamp\n');
    buffer.write('HTTP host: $host\n');
    buffer.write('HTTP referer: $referer\n');
    buffer.write('Status code: $status\n');
    buffer.write('IP: $ip\n');
    return buffer.toString();
  }
}
