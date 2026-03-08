import 'package:app/features/todo/domain/entities/todo.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:hive/hive.dart';

part 'todo_model.freezed.dart';
part 'todo_model.g.dart';

@freezed
@HiveType(typeId: 1)
class TodoModel with _$TodoModel {
  const factory TodoModel({
    @HiveField(0) required String id,
    @HiveField(1) required String title,
    @HiveField(2) required String description,
    @HiveField(3) required bool completed,
    @HiveField(4) required DateTime createdAt,
    @HiveField(5) required String ownerId,
  }) = _TodoModel;

  factory TodoModel.fromJson(Map<String, dynamic> json) =>
      _$TodoModelFromJson(json);
}

extension TodoModelMapper on TodoModel {
  Todo toEntity() {
    return Todo(
      id: id,
      title: title,
      description: description,
      completed: completed,
      createdAt: createdAt,
      ownerId: ownerId,
    );
  }
}

extension TodoEntityMapper on Todo {
  TodoModel toModel() {
    return TodoModel(
      id: id,
      title: title,
      description: description,
      completed: completed,
      createdAt: createdAt,
      ownerId: ownerId,
    );
  }
}
