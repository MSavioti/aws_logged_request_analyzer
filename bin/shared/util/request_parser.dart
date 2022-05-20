import 'dart:convert';

import '../model/grouped_requests_by_path.dart';
import '../model/request.dart';

class RequestParser {
  List<GroupedRequestsByPath> groupRequests(List<Request> requests) {
    final groupedRequests = <GroupedRequestsByPath>[];

    for (var request in requests) {
      final groupedRequest = GroupedRequestsByPath(path: request.url);
      groupedRequest.requests.add(request);

      if (groupedRequests.contains(groupedRequest)) {
        final itemIndex = groupedRequests.indexOf(groupedRequest);
        final existingItem = groupedRequests.elementAt(itemIndex);
        groupedRequests.removeAt(itemIndex);
        groupedRequest.requests.addAll(existingItem.requests);
        groupedRequests.add(groupedRequest);
      } else {
        groupedRequests.add(groupedRequest);
      }
    }

    return groupedRequests;
  }

  List<Request> extractRequestsFromFileContent(List<String> fileContentLines) {
    final requests = <Request>[];

    for (var line in fileContentLines) {
      if (line.isNotEmpty) {
        final map = json.decode(line);
        final request = Request.fromMap(map);
        requests.add(request);
      }
    }

    return requests;
  }

  String generateRequestsOutput(List<GroupedRequestsByPath> groupedRequests) {
    final buffer = StringBuffer();

    for (var request in groupedRequests) {
      buffer.write(request.toString());
    }

    return buffer.toString();
  }

  List<GroupedRequestsByPath> sortRequests(
      List<GroupedRequestsByPath> groupedRequests) {
    final sortedRequests = groupedRequests..sort((a, b) => a.compareTo(b));
    return sortedRequests;
  }
}
