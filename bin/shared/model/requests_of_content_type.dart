import 'dart:core';

import 'requests_from_path.dart';

class RequestsOfContentType {
  final List<String> contentTypes;
  final List<RequestsFromPath> requests;

  RequestsOfContentType({
    required this.contentTypes,
    required this.requests,
  });
}
