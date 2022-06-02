import 'dart:convert';
import 'dart:io';

import 'shared/model/request.dart';
import 'shared/model/requests_from_path.dart';
import 'request_parser.dart';

class FileReader {
  final String rootDirectoryPath;
  final RequestParser requestParser = RequestParser();
  final GZipCodec gZipCodec = GZipCodec();
  int _errors = 0;

  FileReader({required this.rootDirectoryPath});

  void analyze({bool Function(Request)? requestFilter}) {
    final stopwatch = Stopwatch();
    stopwatch.start();
    final files = _readFiles();
    final requests = _extractRequests(files, requestFilter);
    final pathRequests = _analyzeRequests(requests);
    stopwatch.stop();

    _exportResultsToFile(
      requests: pathRequests.toList(),
      elapsedMilisseconds: stopwatch.elapsedMilliseconds,
    );
  }

  Iterable<FileSystemEntity> _readFiles() {
    final rootDirectory = Directory(rootDirectoryPath);

    if (!rootDirectory.existsSync()) {
      throw FileSystemException('Directory path provided is does not exist.');
    }

    return _getFilesFromRootDirectory(rootDirectory);
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

  List<Request> _extractRequests(
    Iterable<FileSystemEntity> fileEntities,
    bool Function(Request)? requestFilter,
  ) {
    var requests = <Request>[];
    int filesExtracted = 0;
    int totalFiles = fileEntities.length;

    for (var fileEntity in fileEntities) {
      final decodedFile = _decodeGzipFile(fileEntity.path);
      final lines = _extractFileContentsSeparatedByLines(decodedFile);
      final extractedRequests =
          requestParser.extractRequestsFromFileContent(lines);
      requests.addAll(extractedRequests);

      decodedFile.delete();
      print('${filesExtracted++}/$totalFiles files extracted');
    }

    if (requestFilter != null) {
      requests = requests.where(requestFilter).toList();
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

  File _decodeGzipFile(String filePath) {
    final file = File(filePath);
    final decodedBytes = gZipCodec.decode(file.readAsBytesSync());
    final decodedFile = File(filePath.split('.').first + '.log');
    decodedFile.writeAsBytesSync(decodedBytes);
    return decodedFile;
  }

  Iterable<RequestsFromPath> _analyzeRequests(
    List<Request> requests,
  ) {
    final mappedRequests = requestParser.mapRequests(requests);
    final listedRequests = requestParser.listMappedRequests(mappedRequests);
    final sortedRequests = requestParser.sortRequests(listedRequests);
    return sortedRequests;
  }

  void _exportResultsToFile({
    required List<RequestsFromPath> requests,
    required int elapsedMilisseconds,
  }) {
    final outputPath = '${rootDirectoryPath}_requests.txt';
    final outputAnalysisFile = File(outputPath);
    final outputRequestData =
        requestParser.generateRequestsOutputFromList(requests);

    outputAnalysisFile.writeAsStringSync(
      'Errors: $_errors\n',
      mode: FileMode.write,
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
