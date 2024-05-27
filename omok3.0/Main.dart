import 'dart:math';
import 'package:http/http.dart' as http;
import 'dart:io';
import 'Board.dart';
import 'OmokMVC.dart';

void main() async {
  stdout.write('Enter the server URL [default: https://www.cs.utep.edu/cheon/cs3360/project/omok/ ] Type Here (without spaces or press enter for default): ');
  String? userInput = stdin.readLineSync();
  String url = userInput?.isEmpty ?? true
      ? 'https://www.cs.utep.edu/cheon/cs3360/project/omok/'
      : userInput!;

  var model = ServerModel(url: url, strategies: []);
  var view = ConsoleUI();
  var controller = ServerController(model, view);

  await controller.initialize();

  String? readline = stdin.readLineSync();
  String line = readline ?? '';
  Board board = Board();

  // PID
  String? pid = await view.handleStrategySelection(board, model, line);
  if (pid != null) {
    await view.promptMove(pid, model, board);
  }

} //end main