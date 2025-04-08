import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'main.dart';
import 'game_data.dart';

class GameSetUpLayout extends StatelessWidget {
  const GameSetUpLayout({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SetUpBoardController, SetUpBoard>(
      builder: (context, state) {
        final int gridSize = 10;
        final double cellSize = 45.0;
        final double totalSize = gridSize * cellSize;

        return Center(
          child: SizedBox(
            width: totalSize,
            height: totalSize,
            child: PixelGrid(boardData: state.mData.mPieces),
          ),
        );
      },
    );
  }
}

class SetUpBoard {
  bool pieceSelected;
  int selectedPiece;
  Map<int, bool> emptyPieces;
  Map<int, int> mPieces;
  BoardData mData;
  SetUpBoard(
    this.pieceSelected,
    this.selectedPiece,
    this.emptyPieces,
    this.mPieces,
    this.mData,
  );
}

class SetUpBoardController extends Cubit<SetUpBoard> {
  // Add the playerController as a dependency.
  final PlayerController playerController;

  // Modify the constructor to require a PlayerController.
  SetUpBoardController({required this.playerController})
    : super(
        SetUpBoard(
          false,
          14,
          fullBag,
          Map<int, int>.from(playerPieces),
          BoardData(),
        ),
      );

  void updateBag(int sprite, int selectedBoardIndex) {
    if (selectedBoardIndex >= 60 &&
        state.mData.mPieces[selectedBoardIndex] == 0 &&
        state.mPieces.containsKey(sprite) &&
        state.mPieces[sprite]! > 0) {
      final updatedPieces = Map<int, int>.from(state.mPieces);
      int newCount = updatedPieces[sprite]! - 1;
      updatedPieces[sprite] = newCount;

      final updatedBoardPieces = List<int>.from(state.mData.mPieces);
      updatedBoardPieces[selectedBoardIndex] = sprite;

      final updatedBoardData = BoardData();
      updatedBoardData.mPieces = updatedBoardPieces;

      final updatedEmptyPieces = Map<int, bool>.from(state.emptyPieces);
      if (newCount == 0) {
        updatedEmptyPieces[sprite] = true;
      }
      if (updatedEmptyPieces.values.every((value) => value == true)) {
        print("Here"); // this isnt working!
        sendData();
      }
      // Emit the new state.
      emit(
        SetUpBoard(
          false,
          14,
          updatedEmptyPieces,
          updatedPieces,
          updatedBoardData,
        ),
      );
      untoggleHeatMap();
    }
  }

  void sendData() async {
    playerController.initGame(state.mData);
    await playerController.sendGameData();
    playerController.getGameData();
  }

  void toggleHeatMap(int sprite) {
    final heatMapBoard = List<int>.from(state.mData.mPieces);
    for (int i = 60; i < 100; i++) {
      if (heatMapBoard[i] == 0) {
        heatMapBoard[i] = 15;
      }
    }
    final newData = BoardData.withPieces(heatMapBoard);
    emit(SetUpBoard(true, sprite, state.emptyPieces, state.mPieces, newData));
  }

  void untoggleHeatMap() {
    final undoHeatmap = List<int>.from(state.mData.mPieces);
    for (int i = 60; i < 100; i++) {
      if (undoHeatmap[i] == 15) {
        undoHeatmap[i] = 0;
      }
    }
    final newData = BoardData.withPieces(undoHeatmap);
    emit(SetUpBoard(false, 14, state.emptyPieces, state.mPieces, newData));
  }
}

class NineByNinePixelWidgetBag extends StatelessWidget {
  final int mSprite;
  const NineByNinePixelWidgetBag(this.mSprite, {super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SetUpBoardController, SetUpBoard>(
      builder: (context, state) {
        return Center(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              mSprite == 14 || mSprite == 15
                  ? SoldierTile(mSprite)
                  : mSprite >= 10 || mSprite == 0
                  ? SizedBox(child: assetMap[mSprite])
                  : SoldierTile(mSprite),
              SizedBox(
                height: 45.0,
                width: 45.0,
                child:
                    mSprite == state.selectedPiece
                        ? Container(
                          decoration: BoxDecoration(
                            color: turquoiseBlue,
                            border: Border.all(
                              color: turquoiseBlue,
                              width: 2.0,
                            ),
                          ),
                          child: Text(
                            " ${state.mPieces[mSprite]}",
                            style: TextStyle(fontSize: 35, color: Colors.black),
                          ),
                        )
                        : Text(
                          " ${state.mPieces[mSprite]}",
                          style: TextStyle(fontSize: 35, color: turquoiseBlue),
                        ),
              ),
            ],
          ),
          //},
          //),
        );
      },
    );
  }
}

class BagUI extends StatelessWidget {
  const BagUI({super.key});

  @override
  Widget build(BuildContext context) {
    final boardController = context.read<SetUpBoardController>();
    final int gridSize = 12;
    final double cellSize = 45.0;
    final double totalSize = gridSize * cellSize;
    return BlocBuilder<SetUpBoardController, SetUpBoard>(
      builder: (context, state) {
        return Column(
          children: [
            Center(
              child: SizedBox(
                width: cellSize * 2,
                height: totalSize,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: List.generate(gridSize, (index) {
                    return GestureDetector(
                      onTap: () {
                        if (!boardController.state.pieceSelected) {
                          boardController.toggleHeatMap(
                            index + 1 > 10 ? index + 2 : index + 1,
                          );
                        } else {
                          boardController.untoggleHeatMap();
                        }
                        // Handle tap on individual grid cell if needed.
                        // highlight yellow pieces the ones in their border that index at 0
                        //set bool to true so that if clicked on the grid it places the piece and decrements
                      },
                      child: ClipOval(
                        child: NineByNinePixelWidgetBag(
                          index + 1 > 10 ? index + 2 : index + 1,
                        ),
                      ),
                    );
                  }),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
