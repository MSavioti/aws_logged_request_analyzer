import 'request.dart';

class GroupedRequestsByPath {
  final String path;
  final List<Request> requests = <Request>[];

  GroupedRequestsByPath({
    required this.path,
  });

  @override
  String toString() {
    final buffer = StringBuffer('\n');
    buffer.write('Requests with path "$path"\n');
    buffer.write('Count: ${requests.length}\n');
    buffer.write('Requests: ${requests.length}\n');

    for (var request in requests) {
      buffer.write(' - ${request.timestamp}\n');
    }

    return buffer.toString();
  }

  @override
  bool operator ==(Object other) =>
      other is GroupedRequestsByPath && path == other.path;

  @override
  int get hashCode => Object.hash(path, path);
}
