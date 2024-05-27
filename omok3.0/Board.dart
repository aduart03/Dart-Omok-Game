import 'dart:io';

class Board{
  //initialize empty starter board
  List< List<String> > board = List.generate(15, (_) => List.filled(15, '.'));
  String? strategy;

  // Constructor with default values
  Board() : board = List.generate(15, (_) => List.filled(15, '.')), strategy = null;

  // Constructor with parameters to initialize board and strategy
  Board.initialize(this.board, this.strategy);

  //checking if a valid move by checking if empty tile and within the constants
  bool validMove(int x, int y)  {
    int temp = x;
    x = y;      //update x to fit board
    y = temp;
    if ((emptyTile(x, y)) && ((x < 15 && x > -1) && (y < 16 && 15 > -1))) {
      return true;
    }
    return false;
  }//end valid

  //checking empty tilev
  bool emptyTile(int x, int y){
    if(board[x][y] == '.'){
      return true;
    }
    return false;
  }


  void updateBoard(String playerPiece, int x, int y){
    int temp = x;
    x = y;      //update x to fit board
    y = temp;
    board[x][y] = playerPiece;

  }//end update board


  void displayOmokBoard() {
    print('');
    int z = 0; //y counter after 10
    int a = 0; //y counter up to 10

    //x line counters
    int b = 0;
    int c = 0;

    stdout.write('');
    stdout.write(' x |');
    for (int i = 0; i < board.length; i++) {

      if(i > 9 ){
        stdout.write(' $b  ');
        b++;
      }else {
        c = i;
        if (i == 0){
          stdout.write(' $c  ');
        }else{
          stdout.write(' $c  ');
        }
      }

    }

    //y line counters

    stdout.writeln('    ');
    stdout.write(' y ');
    for (int i = 0; i < board.length; i++) {
      stdout.write('----');
    }
    stdout.writeln('');

    //actual board
    for (int i = 0; i < board.length; i++) {

      //Print numbers
      if(i > 9 ){
        stdout.write(' $z | ');
        z++;
      }else {
        a = i;
        if (i == 0){
          stdout.write(' $a | ');
        }else{
          stdout.write(' $a | ');
        }
      }
      //Board UI
      for (int j = 0; j < board[i].length; j++) {
        //color appropriate pieces
        if (board[i][j] == 'X') {
          stdout.write('\x1B[33m'); // orange ANSI X
          stdout.write('X   ');
          stdout.write('\x1B[0m'); // Reset color
        } else if (board[i][j] == 'O') {
          stdout.write('\x1B[95m'); // Purple color  O
          stdout.write('O   ');
          stdout.write('\x1B[0m'); // Reset color
        } else if(board[i][j] =='W'){
          stdout.write('\x1B[32m'); // Green color  W
          stdout.write('W   ');
          stdout.write('\x1B[0m');
        }else if(board[i][j] == 'L'){
          stdout.write('\x1B[31m'); // Red color  L
          stdout.write('L   ');
          stdout.write('\x1B[0m');
        }else{
          stdout.write('${board[i][j]}   '); // Print each cell
        }
      }

      stdout.writeln(''); // End the row , allow new row to be printed
    }
  }


  //Check for win
  bool checkForWin(String playerPiece) {
    // Check rows
    for (int i = 0; i < 15; i++) {
      // check columns
      for (int j = 0; j < 11; j++) {
        if (board[i].sublist(j, j + 5).every((cell) => cell == playerPiece)) {
          return true;
          //return [[i, j], [i, j + 1], [i, j + 2], [i, j + 3], [i, j + 4]];
        }
      }
    }

    // Check columns
    for (int i = 0; i < 11; i++) {
      for (int j = 0; j < 15; j++) {
        bool win = true;
        for (int k = 0; k < 5; k++) {
          if (board[i + k][j] != playerPiece) {
            win = false;
            break;
          }
        }
        if (win) {
          return true;
        }
      }
    }

    // Check diagonals
    for (int i = 0; i < 11; i++) {
      for (int j = 0; j < 11; j++) {
        bool win1 = true;
        bool win2 = true;
        for (int k = 0; k < 5; k++) {
          if (board[i + k][j + k] != playerPiece) {
            win1 = false;
          }
          if (board[i + k][j + 4 - k] != playerPiece) {
            win2 = false;
          }
        }
        if (win1 || win2) {
          return true;
        }
      }
    }

    return false;
  }//checkforWin end


}