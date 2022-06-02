import 'dart:collection';
import 'dart:convert';

import 'shared/model/requests_from_path.dart';
import 'shared/model/request.dart';

class RequestParser {
  HashMap<String, RequestsFromPath> mapRequests(Iterable<Request> requests) {
    final mappedRequests = HashMap<String, RequestsFromPath>();
    int requestsGrouped = 0;
    int totalRequestsToBeGrouped = requests.length;

    for (var request in requests) {
      mappedRequests.update(
        request.url,
        (v) => _updateValue(v, request),
        ifAbsent: () => _addValue(request),
      );

      requestsGrouped++;
      print('$requestsGrouped/$totalRequestsToBeGrouped requests grouped');
    }

    return mappedRequests;
  }

  List<RequestsFromPath> listMappedRequests(
    HashMap<String, RequestsFromPath> mappedRequests,
  ) {
    final requests = <RequestsFromPath>[];

    mappedRequests.forEach((key, value) {
      requests.add(value);
    });

    return requests;
  }

  List<Request> extractRequestsFromFileContent(List<String> fileContentLines) {
    final filteredLines = _filterUploadedFiles(fileContentLines);
    final requests = <Request>[];

    for (var line in filteredLines) {
      if (line.isNotEmpty) {
        final map = json.decode(line);
        final request = Request.fromMap(map);
        requests.add(request);
      }
    }

    return requests;
  }

  String generateRequestsOutputFromMap(
    HashMap<String, RequestsFromPath> mappedRequests,
  ) {
    final buffer = StringBuffer();

    mappedRequests.forEach((key, value) {
      buffer.write('\nPath: "$key"\n');
      buffer.write('Requests: "${value.requestsCount}"\n');
    });

    return buffer.toString();
  }

  String generateRequestsOutputFromList(
    List<RequestsFromPath> pathRequests,
  ) {
    final buffer = StringBuffer();

    for (var request in pathRequests) {
      buffer.write('\nPath: "${request.path}"\n');
      buffer.write('Requests: "${request.requestsCount}"\n');
    }

    return buffer.toString();
  }

  List<RequestsFromPath> sortRequests(List<RequestsFromPath> pathRequests) {
    final sortedRequests = pathRequests
      ..sort(
        (a, b) => b.compareTo(a),
      );
    return sortedRequests;
  }

  RequestsFromPath _addValue(Request request) {
    final pathRequest = RequestsFromPath(path: request.url);
    pathRequest.requests.add(request);
    return pathRequest;
  }

  RequestsFromPath _updateValue(
    RequestsFromPath pathRequest,
    Request request,
  ) {
    pathRequest.requests.add(request);
    return pathRequest;
  }

  List<String> _filterUploadedFiles(List<String> fileContentLines) {
    return fileContentLines
        .where((line) => !line.contains('/wp-content/uploads'))
        .toList();
  }
}
