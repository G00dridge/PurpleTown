import 'package:hive/hive.dart';
part 'decision_map.g.dart';

@HiveType(typeId: 0)
class DecisionMap {

  @HiveField(0)
  int id = 0;
  @HiveField(1)
  int option1Id = 0;
  @HiveField(2)
  int option2Id = 0;
  @HiveField(3)
  String description = '';
  @HiveField(4)
  String question = '';
  @HiveField(5)
  String option1 = '';
  @HiveField(6)
  String option2 = '';
  @HiveField(7)
  String summary = '';
  @HiveField(8)
  String hint1 = '';
  @HiveField(9)
  String hint2 = '';
}