import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'main.dart';
import 'game_setup.dart';
import 'game_data.dart';

class Game {
  bool myTurn;
  bool pieceSelected;
  int selectedPiece;
  Map<int, int> mPieces;
  BoardData mData;
  Game(
    this.myTurn,
    this.pieceSelected,
    this.selectedPiece,
    this.mPieces,
    this.mData,
  );
}

class TurnController extends Cubit<Game> {
  TurnController()
    : super(
        Game(false, false, 14, Map<int, int>.from(playerPieces), BoardData()),
      ); //TODO Fix so that my turn init via player controller

  void toggleHeatMap(int boardIndex) {
    if (state.myTurn) {
      final heatMapBoard = List<int>.from(state.mData.mPieces);
      final int right = boardIndex + 1;
      final int left = boardIndex - 1;
      final int below = boardIndex + 10;
      final int above = boardIndex - 10;
      if (right % 10 != 0 && heatMapBoard[right] == 0) heatMapBoard[right] = 15;
      if (left % 10 != 9 && heatMapBoard[left] == 0) heatMapBoard[left] = 15;
      if (below < 100 && heatMapBoard[below] == 0) heatMapBoard[below] = 15;
      if (above >= 0 && heatMapBoard[above] == 0) heatMapBoard[above] = 15;

      final newData = BoardData.withPieces(heatMapBoard);
      emit(
        Game(
          state.myTurn,
          true,
          newData.mPieces[boardIndex],
          state.mPieces,
          newData,
        ),
      );
    }
  }

  void untoggleHeatMap() {
    final undoHeatmap = List<int>.from(state.mData.mPieces);
    for (int i = 0; i < 100; i++) {
      if (undoHeatmap[i] == 15) {
        undoHeatmap[i] = 0;
      }
    }
    final newData = BoardData.withPieces(undoHeatmap);

    emit(Game(state.myTurn, false, 14, state.mPieces, newData));
  }
}
