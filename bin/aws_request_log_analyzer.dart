import 'file_reader.dart';

void main(List<String> arguments) {
  if (arguments.length != 1) {
    throw FormatException('Provide a directory path.');
  }

  final rootDirectoryPath = arguments.first;
  final reader = FileReader(rootDirectoryPath: rootDirectoryPath);
  reader.analyze();
}
