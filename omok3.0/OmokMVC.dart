import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';
import 'Board.dart';

// Model (M)
class ServerModel {
  late String _url;
  late List<String> _strategies;
  late String defaultURL = "https://www.cs.utep.edu/cheon/cs3360/project/omok/";

  String get url => _url;
  List<String> get strategies => _strategies;

  ServerModel({required String url, required List<String> strategies}) {
    _url = url;
    _strategies = strategies;
  }

  Future<void> fetchServerInfo() async {
    var def = "info";
    var response = await http.get(Uri.parse(_url+def));
    print('Obtaining Server Information...');
    print('Response status: ${response.statusCode}');
    print('Response body: ${response.body}');
    var info = json.decode(response.body);
    print('this is url$_url');
    print('This is info $info');

    if (info != null && info is Map<String, dynamic> && info.containsKey('strategies')) {
      _strategies = List<String>.from(info['strategies']);


    } else {
      print('Error: Invalid server response format');
    }
  }

  List<String> getStrategies() {
    return _strategies;
  }

}//end M

// View (V) : used to be 'ServerView', and is 'ConsoleUI' now.
class ConsoleUI {

  void displayServerInfo(String url, List<String> strategies) {
    print('Server URL: $url');
    print('Available Strategies: $strategies'); //Available Strategies: [Smart, Random]
  }

  void displayStrategySelectionPrompt() {
    print('Select the server strategy: 1. Smart 2. Random [default: 1]');
  }

  void displayInvalidSelection() {
    print('Invalid Selection');
  }

  Future<String?> handleStrategySelection(Board board, ServerModel model, String userInput) async {
    try {
      List<String> strategies = model.getStrategies();
      var selection = int.parse(userInput);

      late var gameType;
      late String? pid;
      // Determines between Random and Smart strategy
      if (selection == 1 || selection == 2) {
        if (selection == 1) {
          print('${strategies[0]} Strategy chosen');
          board.strategy = strategies[0];
          gameType = 'new/index.php?strategy=Smart';
          var uri  = Uri.parse(model.defaultURL + gameType);
          print('print uri for smart $uri');
          var response = await http.get(uri);
          print('print response for smart $response');
          var info = json.decode(response.body);
          print('print info for smart $info');
          pid = info["pid"];
          print('print pid for smart $pid');

        } else {
          print('${strategies[1]} Strategy chosen');
          board.strategy = strategies[1];
          gameType = 'new/index.php?strategy=Random';
          var uri  = Uri.parse(model.defaultURL + gameType);
          var response = await http.get(uri);
          var info = json.decode(response.body);
          pid = info["pid"];
          print('print random pid $pid');

        }

        print('model thing in the end ${model.defaultURL}');
        print('Creating a new game');
        return pid;

      } else {
        displayInvalidSelection();
        return ' ';
      }
    } on FormatException {
      displayInvalidSelection();
      return '';
    }
  }

  List<int>currentMove = []; // Array that will take in x and y position

  Future<void> promptMove(String? pid, ServerModel model, Board board) async {

    bool win = true;
    while(win){
      board.displayOmokBoard();
      bool validCoords = false;

      while(!validCoords){

        currentMove = [];
        stdout.write('Enter your your x position: '); // Prompting the user for input
        String? inputx = stdin.readLineSync(); // Reading user input from console
        int x;
        try {
          x = int.parse(inputx!); // Attempt to parse the input
        } on FormatException {
          // Handle invalid input (empty string or letters)
          x = -1;
        }


        stdout.write('Enter your your y position: '); // Prompting the user for input
        String? inputy = stdin.readLineSync(); // Reading user input from console
        int y;
        try {
          y = int.parse(inputy!);
        } on FormatException {
          // Handle invalid input (empty string or letters)
          y = -1;
        }

        currentMove.add(x); // Parsing user input as an integer
        currentMove.add(y); // Parsing user input as an integer

        if( currentMove[0] > 14 || currentMove[0] < 0 ||
            currentMove[1] > 14 || currentMove[1] < 0 || !(board.emptyTile(currentMove[1], currentMove[0]))){ // 0,0 -> X <- is empty if u just called emptyTIle - > T
          print('Invalid Index, Try again :D');
        }else{

          //update board . create the URL for coding the next thing
          board.updateBoard('X',currentMove[0], currentMove[1]);
          var fullUrl = "${model.defaultURL}play/?pid=${pid}&x=${currentMove[0]}&y=${currentMove[1]}";
          //print(fullUrl);

          //New Code
          var uri  = Uri.parse(fullUrl);
          var response = await http.get(uri);
          var info = json.decode(response.body);

          //find move , get the x y at move, pass thru updateboard
          //response false unknown pid
          print('this is the info print statement ${info}');
          var computerMove = info['move'];

          late var isCompWin;
          if(computerMove == null){ //no exist
            isCompWin = false;
          }else if (info != null && info.containsKey('move')) {

            int computerX = computerMove['x'];
            int computerY = computerMove['y'];
            validCoords = true;
            board.displayOmokBoard();
            isCompWin = computerMove['isWin'];
            bool isDraw = computerMove['isDraw'];
            // Update the board with the computer's move
            board.updateBoard('O', computerX, computerY);
          }else {//The computer has lost lost there is no more 'move'
            print('Invalid response format or missing move object');
            win = false;
            break;
            //here
          }

          //Computer

          //human
          var human = info['ack_move'];
          var isHumanWin = human['isWin'];
          //TODO: Win method, passes in, make a var for

          if(isCompWin || isHumanWin ){

            win = true;

            if(isHumanWin){
              var wHumRow = human['row'];
              changeToHighLight(board, wHumRow ,'W');
              print('Congrats you Win!!');
              board.displayOmokBoard();
              return;
            }else if (isCompWin){
              var wComRow = computerMove['row'];
              changeToHighLight(board, wComRow ,'L');
              print('Uh oh, Try again :(');
              board.displayOmokBoard();
              return;
            }
          }// || thing ^^

        }//end else
      }//end while loop for user selection
    } //end while win loop

  }//end prompt move

  //method that changes winning row to W or L's
  void changeToHighLight(Board final_board, List <dynamic> winRow, String letter){
    for(int i = 0; i <winRow.length -1; i += 2){
      int b = winRow[i];
      int a = winRow[i+1];
      final_board.board[a][b] = letter;
    }
  }//end ctHL

} //end View

// Controller (C)
class ServerController {
  final ServerModel _model;
  final ConsoleUI _view;

  ServerController(this._model, this._view);

  Future<void> initialize() async {
    await _model.fetchServerInfo();
    _view.displayServerInfo(_model.url, _model.strategies);
    _view.displayStrategySelectionPrompt();
  }
}//end C
