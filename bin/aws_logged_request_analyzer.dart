import 'shared/util/file_reader.dart';

void main(List<String> arguments) {
  if (arguments.length != 1) {}

  final rootDirectoryPath = arguments.first;
  final reader = FileReader(rootDirectoryPath: rootDirectoryPath);
  reader.readFiles();
}
