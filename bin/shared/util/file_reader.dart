import 'dart:convert';
import 'dart:io';

import '../model/grouped_requests_by_path.dart';
import '../model/request.dart';
import 'request_parser.dart';

class FileReader {
  final String rootDirectoryPath;
  final RequestParser requestParser = RequestParser();
  final GZipCodec gZipCodec = GZipCodec();

  FileReader({required this.rootDirectoryPath});

  void readFiles() async {
    final rootDirectory = Directory(rootDirectoryPath);
    final fileEntities = _getFilesFromRootDirectory(rootDirectory);
    final requests = _extractRequests(fileEntities);
    final groupedRequests = requestParser.groupRequests(requests);
    final sortedRequests = requestParser.sortRequests(groupedRequests);
    _exportResultsToFile(sortedRequests, rootDirectory);
  }

  Iterable<FileSystemEntity> _getFilesFromRootDirectory(
    Directory rootDirectory,
  ) {
    final subdirectories = rootDirectory.listSync(recursive: true);
    final files = subdirectories.where((f) => f.path.contains('.gz'));
    return files;
  }

  List<Request> _extractRequests(Iterable<FileSystemEntity> fileEntities) {
    final requests = <Request>[];

    for (var fileEntity in fileEntities) {
      final decodedFile = _decodeFile(fileEntity.path);
      final lines = _extractFileContentsSeparatedByLines(decodedFile);
      final extractedRequests =
          requestParser.extractRequestsFromFileContent(lines);
      requests.addAll(extractedRequests);

      decodedFile.delete();
    }

    return requests;
  }

  List<String> _extractFileContentsSeparatedByLines(File decodedFile) {
    final contentBytes = decodedFile.readAsBytesSync();
    final fileContent = utf8.decode(contentBytes);
    final lines = fileContent.split('\n');
    return lines;
  }

  File _decodeFile(String filePath) {
    final file = File(filePath);
    final decodedBytes = gZipCodec.decode(file.readAsBytesSync());
    final decodedFile = File(filePath.split('.').first + '.log');
    decodedFile.writeAsBytesSync(decodedBytes);
    return decodedFile;
  }

  void _exportResultsToFile(
      List<GroupedRequestsByPath> groupedRequests, Directory rootDirectory) {
    final outputAnalysisFile = File('${rootDirectory.path}.txt');
    final outputRequestData =
        requestParser.generateRequestsOutput(groupedRequests);
    outputAnalysisFile.writeAsStringSync(outputRequestData);
  }
}
