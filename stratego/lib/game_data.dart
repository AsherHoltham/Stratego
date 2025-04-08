import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

const Color tanColor = Color(0xfff2d2a8);
const Color greyColor = Color(0xff9f9b96);
const Color redColor = Color(0xffb52525);
const Color turquoiseBlue = Color(0xFF40E0D0);

Map<int, Widget> assetMap = {
  10: Image.asset('lib/assets/general.png', width: 45, height: 45),
  0: Image.asset('lib/assets/grassblock.png', width: 45, height: 45),
  11: Image.asset('lib/assets/watertile.png', width: 45, height: 45),
  12: Image.asset('lib/assets/bomb.png', width: 45, height: 45),
  13: Image.asset('lib/assets/flag.png', width: 45, height: 45),
};

Map<int, int> playerPieces = {
  13: 1,
  12: 6,
  10: 1,
  9: 1,
  8: 2,
  7: 3,
  6: 4,
  5: 4,
  4: 4,
  3: 5,
  2: 8,
  1: 1,
};

Map<int, bool> fullBag = {
  13: false,
  12: false,
  10: false,
  9: false,
  8: false,
  7: false,
  6: false,
  5: false,
  4: false,
  3: false,
  2: false,
  1: false,
};

class BoardData {
  late List<int> mPieces;
  BoardData() {
    mPieces = List.generate(100, (index) => 0);
    mPieces[52] = 11;
    mPieces[53] = 11;
    mPieces[56] = 11;
    mPieces[57] = 11;
    mPieces[42] = 11;
    mPieces[43] = 11;
    mPieces[46] = 11;
    mPieces[47] = 11;
    // for (int i = 60; i < 100; i++) {
    //   mPieces[i] = 15; // opponent pieces
    // }
  }
  BoardData(List<int> data) {
    mPieces = data;
  }
}

class SoldierTile extends StatelessWidget {
  final int mIndex;
  const SoldierTile(this.mIndex, {super.key});

  @override
  Widget build(BuildContext context) {
    return mIndex == 15
        ? Container(
          decoration: BoxDecoration(
            color: (turquoiseBlue),
            border: Border.all(color: Colors.black, width: 1.0),
          ),
          height: 45,
          width: 45,
        )
        : mIndex == 14
        ? Container(
          decoration: BoxDecoration(
            color: (greyColor),
            border: Border.all(color: Colors.black),
          ),
          height: 45,
          width: 45,
        )
        : Container(
          decoration: BoxDecoration(color: (tanColor)),
          height: 45,
          width: 45,
          child: Text(
            " $mIndex",
            style: TextStyle(
              fontSize: 35, // Adjust font size as needed
              color: redColor,
            ),
          ),
        );
  }
}

class NineByNinePixelWidget extends StatelessWidget {
  final int mSprite;
  final int index;
  const NineByNinePixelWidget(this.mSprite, this.index, {super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child:
          mSprite == 14 || mSprite == 15
              ? SoldierTile(mSprite)
              : mSprite >= 10 || mSprite == 0
              ? SizedBox(child: assetMap[mSprite])
              : SoldierTile(mSprite),
    );
  }
}

class PixelGrid extends StatelessWidget {
  final List<int> boardData;

  const PixelGrid({super.key, required this.boardData});

  @override
  Widget build(BuildContext context) {
    const int gridSize = 10;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(gridSize, (row) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(gridSize, (col) {
            int index = row * gridSize + col;
            return GestureDetector(
              onTap: () {
                // Handle tap on individual grid cell if needed.
              },
              child: NineByNinePixelWidget(boardData[index], index),
            );
          }),
        );
      }),
    );
  }
}

//BoardData testData = BoardData();
//void main() => runApp(const TestApp());

class GameLayout extends StatelessWidget {
  final BoardData gameData;
  const GameLayout(this.gameData, {super.key});

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
            child: PixelGrid(boardData: gameData.mPieces),
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
  SetUpBoardController()
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
    // Check that the piece exists and has a count greater than 0
    if (state.mPieces.containsKey(sprite) && state.mPieces[sprite]! > 0) {
      // Create a copy of the pieces map to preserve immutability.
      final updatedPieces = Map<int, int>.from(state.mPieces);
      int newCount = updatedPieces[sprite]! - 1;
      updatedPieces[sprite] = newCount;

      // Create a copy of the board's piece list.
      final updatedBoardPieces = List<int>.from(state.mData.mPieces);
      updatedBoardPieces[selectedBoardIndex] = sprite;

      // Create a new BoardData with the updated board pieces.
      final updatedBoardData = BoardData();
      updatedBoardData.mPieces = updatedBoardPieces;

      final updatedEmptyPieces = Map<int, bool>.from(state.emptyPieces);
      if (newCount == 0) {
        updatedEmptyPieces[sprite] = true;
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
    }
  }

  void toggleHeatMap(int sprite) {
    final heatMapBoard = List<int>.from(state.mData.mPieces);
    for (int i = 60; i < 100; i++) {
      if (heatMapBoard[i] == 0) {
        heatMapBoard[i] = 15;
      }
    }
    emit(
      SetUpBoard(true, sprite, state.emptyPieces, state.mPieces, heatMapBoard),
    );
  }

  void untoggleHeatMap() {
    final updatedPieces = Map<int, int>.from(state.mPieces);
    for (int i = 60; i < 100; i++) {
      if (updatedPieces[i] == 15) {
        updatedPieces[i] = 0;
      }
    }
    emit(SetUpBoard(false, 14, state.emptyPieces, updatedPieces, state.mData));
  }
}

class BagTile extends StatelessWidget {
  final int mIndex;
  const BagTile(this.mIndex, {super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SetUpBoardController, SetUpBoard>(
      builder: (context, state) {
        // Choose widget depending on whether the mIndex matches the selectedPiece in the state.
        if (mIndex == state.selectedPiece) {
          return Container(
            decoration: BoxDecoration(
              border: Border.all(color: turquoiseBlue, width: 2.0),
            ),
            height: 45,
            width: 45,
            child:
                mIndex < 10
                    ? Container(
                      decoration: BoxDecoration(color: tanColor),
                      height: 45,
                      width: 45,
                      child: Text(
                        " $mIndex",
                        style: const TextStyle(fontSize: 35, color: redColor),
                      ),
                    )
                    : SizedBox(child: assetMap[mIndex]),
          );
        } else {
          return mIndex < 10
              ? Container(
                decoration: BoxDecoration(color: tanColor),
                height: 45,
                width: 45,
                child: Text(
                  " $mIndex",
                  style: const TextStyle(fontSize: 35, color: redColor),
                ),
              )
              : SizedBox(child: assetMap[mIndex]);
        }
      },
    );
  }
}

class NineByNinePixelWidgetBag extends StatelessWidget {
  final int mSprite;
  const NineByNinePixelWidgetBag(this.mSprite, {super.key});

  @override
  Widget build(BuildContext context) {
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
            child: Text(
              " ${playerPieces[mSprite]}",
              style: TextStyle(fontSize: 35, color: turquoiseBlue),
            ),
          ),
        ],
      ),
      //},
      //),
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
                    print("Tapped");
                    print("${boardController.state.pieceSelected}");
                    print("${boardController.state.selectedPiece}");

                    if (!boardController.state.pieceSelected) {
                      boardController.toggleHeatMap(
                        index + 1 > 10 ? index + 2 : index + 1,
                      );
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
  }
}

// class Dot extends Positioned {
//   Dot({super.key, super.top, super.left})
//     : super(
//         child: Container(
//           height: 8,
//           width: 8,
//           decoration: BoxDecoration(color: redColor, shape: BoxShape.circle),
//         ),
//       );
// }

// class SoldierTile extends StatelessWidget {
//   final int mIndex;
//   final List<Dot> mDots = [];
//   const SoldierTile(this.mIndex, {super.key});
//   {
//     if (mIndex % 2 == 1) {
//       mDots.add(Dot(top: 18, left: 18)); // middle dot
//     }
//     if (mIndex == 3 ||
//         mIndex == 8 ||
//         mIndex == 9 ||
//         mIndex == 7) // other corners
//     {
//       mDots.add(Dot(top: 3, left: 18));
//       mDots.add(Dot(top: 33, left: 18));
//     }
//     if (mIndex == 9) // other corners
//     {
//       mDots.add(Dot(top: 4, left: 1));
//       mDots.add(Dot(top: 4, left: 7));
//     }
//     if (mIndex == 8 || mIndex == 6) // middle side dots
//     {
//       mDots.add(Dot(top: 4, left: 3));
//       mDots.add(Dot(top: 4, left: 6));
//     }
//     if (mIndex == 9 || mIndex == 8 || mIndex == 5 || mIndex == 7) //corners
//     {
//       mDots.add(Dot(top: 1, left: 1));
//       mDots.add(Dot(top: 1, left: 7));
//       mDots.add(Dot(top: 7, left: 1));
//       mDots.add(Dot(top: 7, left: 7));
//     }
//     if (mIndex == 4) //corners
//     {
//       mDots.add(Dot(top: 3, left: 3));
//       mDots.add(Dot(top: 3, left: 6));
//       mDots.add(Dot(top: 6, left: 3));
//       mDots.add(Dot(top: 6, left: 6));
//     }
//     if (mIndex == 2 || mIndex == 6 || mIndex == 8) //corners
//     {
//       mDots.add(Dot(top: 4, left: 3));
//       mDots.add(Dot(top: 4, left: 6));
//     }

//     if (mIndex == 6) //corners
//     {
//       mDots.add(Dot(top: 1, left: 3));
//       mDots.add(Dot(top: 1, left: 6));
//       mDots.add(Dot(top: 7, left: 3));
//       mDots.add(Dot(top: 7, left: 6));
//     }
//   }
//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       decoration: BoxDecoration(color: (tanColor)),
//       height: 45,
//       width: 45,
//       child: Text(
//         "$mIndex",
//         style: TextStyle(
//           fontSize: 35, // Adjust font size as needed
//           color: redColor,
//         ),
//       ),
//     );
//   }
// }

// Make ambient tile
