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
            border: Border.all(color: Colors.black),
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
  }
}

class SetUpBoard {
  bool pieceSelected;
  Map<int, int> mPieces;
  BoardData mData;
  SetUpBoard(this.pieceSelected, this.mPieces, this.mData);
}

class SetUpBoardController extends Cubit<SetUpBoard> {
  SetUpBoardController()
    : super(SetUpBoard(false, Map<int, int>.from(playerPieces), BoardData()));

  void updateBag(int sprite, int selected) {
    // Check that the piece exists and has a count greater than 0
    if (state.mPieces.containsKey(sprite) && state.mPieces[sprite]! > 0) {
      // Create a copy of the pieces map to preserve immutability.
      final updatedPieces = Map<int, int>.from(state.mPieces);
      int newCount = updatedPieces[sprite]! - 1;
      updatedPieces[sprite] = newCount;

      // Create a copy of the board's piece list.
      final updatedBoardPieces = List<int>.from(state.mData.mPieces);
      updatedBoardPieces[selected] = newCount;

      // Create a new BoardData with the updated board pieces.
      final updatedBoardData = BoardData();
      updatedBoardData.mPieces = updatedBoardPieces;

      // Emit the new state.
      emit(SetUpBoard(false, updatedPieces, updatedBoardData));
    }
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
