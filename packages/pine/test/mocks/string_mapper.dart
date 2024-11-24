import 'package:pine/pine.dart';

class StringMapper extends Mapper<String, int> {
  @override
  int from(String from) => int.parse(from);

  @override
  String to(int to) => to.toString();
}
