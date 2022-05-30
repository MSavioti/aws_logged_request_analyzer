import 'dart:convert';
import 'dart:io';

import '../model/request.dart';
import '../model/requests_of_content_type.dart';
import 'request_parser.dart';

class FileReader {
  final String rootDirectoryPath;
  final RequestParser requestParser = RequestParser();
  final GZipCodec gZipCodec = GZipCodec();
  int _errors = 0;

  FileReader({required this.rootDirectoryPath});

  void readFiles() async {
    final stopwatch = Stopwatch();
    stopwatch.start();
    final rootDirectory = Directory(rootDirectoryPath);
    final fileEntities = _getFilesFromRootDirectory(rootDirectory);
    final requests = _extractRequests(fileEntities);
    final appRequests = _analyzeRequestsByContentType(
        requests, ['text/html', 'application/xhtml']);
    final apiRequests =
        _analyzeRequestsByContentType(requests, ['application/json']);
    final emptyRequests = _analyzeRequestsByContentType(requests, ['']);
    stopwatch.stop();

    _exportResultsToFile(
      requestsOfContentType: appRequests,
      outputPath: '${rootDirectoryPath}_app_requests.txt',
      elapsedMilisseconds: stopwatch.elapsedMilliseconds,
    );

    _exportResultsToFile(
      requestsOfContentType: apiRequests,
      outputPath: '${rootDirectoryPath}_api_requests.txt',
      elapsedMilisseconds: stopwatch.elapsedMilliseconds,
    );

    _exportResultsToFile(
      requestsOfContentType: emptyRequests,
      outputPath: '${rootDirectoryPath}_empty_requests.txt',
      elapsedMilisseconds: stopwatch.elapsedMilliseconds,
    );
  }

  Iterable<FileSystemEntity> _getFilesFromRootDirectory(
    Directory rootDirectory,
  ) {
    final subdirectories = rootDirectory.listSync(recursive: true);
    final files = _filterFilesByNames(subdirectories);
    print('Found ${files.length} files.');
    return files;
  }

  Iterable<FileSystemEntity> _filterFilesByNames(
    Iterable<FileSystemEntity> subdirectories,
  ) {
    var files = subdirectories.where((f) => f.path.endsWith('.gz'));
    return files;
  }

  List<Request> _extractRequests(Iterable<FileSystemEntity> fileEntities) {
    final requests = <Request>[];
    int filesExtracted = 0;
    int totalFiles = fileEntities.length;

    for (var fileEntity in fileEntities) {
      final decodedFile = _decodeFile(fileEntity.path);
      final lines = _extractFileContentsSeparatedByLines(decodedFile);
      final extractedRequests =
          requestParser.extractRequestsFromFileContent(lines);
      requests.addAll(extractedRequests);

      decodedFile.delete();
      filesExtracted++;
      print('$filesExtracted/$totalFiles files extracted');
    }

    return requests;
  }

  List<String> _extractFileContentsSeparatedByLines(File decodedFile) {
    try {
      final contentBytes = decodedFile.readAsBytesSync();
      final fileContent = utf8.decode(contentBytes);
      final lines = fileContent.split('\n');
      return lines;
    } catch (_) {
      _errors++;
      return [];
    }
  }

  File _decodeFile(String filePath) {
    final file = File(filePath);
    final decodedBytes = gZipCodec.decode(file.readAsBytesSync());
    final decodedFile = File(filePath.split('.').first + '.log');
    decodedFile.writeAsBytesSync(decodedBytes);
    return decodedFile;
  }

  RequestsOfContentType _analyzeRequestsByContentType(
    List<Request> requests,
    List<String> contentTypes,
  ) {
    final requestsByContentType =
        requests.where((e) => contentTypes.contains(e.contentType));
    final mappedRequests = requestParser.mapRequests(requestsByContentType);
    final listedRequests = requestParser.listMappedRequests(mappedRequests);
    final sortedRequests = requestParser.sortRequests(listedRequests);
    final requestsOfContentType = RequestsOfContentType(
      contentTypes: contentTypes,
      requests: sortedRequests,
    );
    return requestsOfContentType;
  }

  void _exportResultsToFile({
    required RequestsOfContentType requestsOfContentType,
    required String outputPath,
    required int elapsedMilisseconds,
  }) {
    final outputAnalysisFile = File(outputPath);
    final outputRequestData = requestParser
        .generateRequestsOutputFromList(requestsOfContentType.requests);

    outputAnalysisFile.writeAsStringSync(
        'Content type: ${requestsOfContentType.contentTypes.toString()}\n');
    outputAnalysisFile.writeAsStringSync(
      'Errors: $_errors\n',
      mode: FileMode.append,
    );
    outputAnalysisFile.writeAsStringSync(
      'Elapsed time: ${elapsedMilisseconds}ms\n',
      mode: FileMode.append,
    );
    outputAnalysisFile.writeAsStringSync(
      outputRequestData,
      mode: FileMode.append,
    );
  }
}
