import 'shared/util/file_reader.dart';

void main(List<String> arguments) {
  if (arguments.length != 1) {
    throw FormatException(
        'Specify a single string with the path to the files.');
  }

  final rootDirectoryPath = arguments.first;
  final reader = FileReader(rootDirectoryPath: rootDirectoryPath);
  reader.analyze();
}
