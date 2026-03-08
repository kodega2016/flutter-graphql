import 'package:hive_flutter/hive_flutter.dart';

import '../../features/todo/data/models/todo_model.dart';
import 'hive_boxes.dart';

class HiveService {
  Future<void> init() async {
    await Hive.initFlutter();

    if (!Hive.isAdapterRegistered(1)) {
      Hive.registerAdapter(TodoModelAdapter());
    }
  }

  Future<void> openBoxes() async {
    if (!Hive.isBoxOpen(HiveBoxes.todos)) {
      await Hive.openBox<TodoModel>(HiveBoxes.todos);
    }
  }

  Box<TodoModel> get todosBox => Hive.box<TodoModel>(HiveBoxes.todos);
}
