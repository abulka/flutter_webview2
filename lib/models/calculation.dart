import 'package:flutter/material.dart';
import 'dart:collection';
// import 'package:provider/provider.dart';

class Calculation {
  String expression;
  String answer;
  bool completed;

  Calculation({@required this.expression, this.completed = false});

  void toggleCompleted() {
    completed = !completed;
  }
}

class CalculationsModel extends ChangeNotifier {
  // final List<Calculation> _calculations = [];

  // Demo data
  final List<Calculation> _calculations = [
    Calculation(expression: '1 + 1'),
    Calculation(expression: '1 + 2'),
    Calculation(expression: 'sin(90) / 1'),
  ];

  bool justAdded = false;

  get allCalculations => _calculations;
  get incompleteCalculations => _calculations.where((c) => !c.completed);
  get completedCalculations => _calculations.where((c) => c.completed);

  void add(Calculation c) {
    _calculations.add(c);
    justAdded = true;
    notifyListeners();
  }

  void toggleComplete(Calculation c) {
    final itemIndex = _calculations.indexOf(c);
    _calculations[itemIndex].toggleCompleted();
    justAdded = false;
    notifyListeners();
  }

  void delete(Calculation c) {
    _calculations.remove(c);
    justAdded = false;
    notifyListeners();
  }

  void clear() {
    _calculations.clear();
    notifyListeners();
    justAdded = false;
  }
}
