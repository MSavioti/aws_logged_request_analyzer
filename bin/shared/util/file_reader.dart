import 'dart:collection';
import 'dart:convert';
import 'dart:io';

import '../model/requests_from_path.dart';
import '../model/request.dart';
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
    final mappedRequests = requestParser.mapRequests(requests);
    final listedRequests = requestParser.listMappedRequests(mappedRequests);
    final sortedRequests = requestParser.sortRequests(listedRequests);
    stopwatch.stop();
    _exportResultsFromListToFile(
      sortedRequests,
      rootDirectory,
      stopwatch.elapsedMilliseconds,
    );
    // _exportResultsFromMapToFile(
    //   mappedRequests,
    //   rootDirectory,
    //   stopwatch.elapsedMilliseconds,
    // );
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

  void _exportResultsFromMapToFile(
    HashMap<String, RequestsFromPath> mappedRequests,
    Directory rootDirectory,
    int elapsedMilisseconds,
  ) {
    final outputAnalysisFile = File('${rootDirectory.path}.txt');
    final outputRequestData =
        requestParser.generateRequestsOutputFromMap(mappedRequests);
    outputAnalysisFile.writeAsStringSync('Errors: $_errors\n');
    outputAnalysisFile.writeAsStringSync(
      'Elapsed time: ${elapsedMilisseconds}ms\n',
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

  void _exportResultsFromListToFile(
    List<RequestsFromPath> groupedRequests,
    Directory rootDirectory,
    int elapsedMilisseconds,
  ) {
    final outputAnalysisFile = File('${rootDirectory.path}.txt');
    final outputRequestData =
        requestParser.generateRequestsOutputFromList(groupedRequests);
    outputAnalysisFile.writeAsStringSync('Errors: $_errors\n');
    outputAnalysisFile.writeAsStringSync(
      'Elapsed time: ${elapsedMilisseconds}ms\n',
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
