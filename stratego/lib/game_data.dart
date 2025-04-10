import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'game_setup.dart';

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
  }
  BoardData.withPieces(this.mPieces);
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
    final boardController = context.read<SetUpBoardController>();

    return BlocBuilder<SetUpBoardController, SetUpBoard>(
      builder: (context, state) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(gridSize, (row) {
            return Row(
              mainAxisSize: MainAxisSize.min,
              children: List.generate(gridSize, (col) {
                int index = row * gridSize + col;
                return GestureDetector(
                  onTap: () {
                    if (state.pieceSelected) {
                      boardController.updateBag(state.selectedPiece, index);
                    }
                  },
                  child: NineByNinePixelWidget(boardData[index], index),
                );
              }),
            );
          }),
        );
      },
    );
  }
}


// class BagTile extends StatelessWidget {
//   final int mIndex;
//   const BagTile(this.mIndex, {super.key});

//   @override
//   Widget build(BuildContext context) {
//     return BlocBuilder<SetUpBoardController, SetUpBoard>(
//       builder: (context, state) {
//         // Choose widget depending on whether the mIndex matches the selectedPiece in the state.
//         if (mIndex == state.selectedPiece) {
//           print("Here 1");
//           return Container(
//             decoration: BoxDecoration(
//               border: Border.all(color: Colors.black, width: 2.0),
//             ),
//             height: 45,
//             width: 45,
//             child:
//                 mIndex < 10
//                     ? Container(
//                       decoration: BoxDecoration(color: tanColor),
//                       height: 45,
//                       width: 45,
//                       child: Text(
//                         " $mIndex",
//                         style: const TextStyle(fontSize: 35, color: redColor),
//                       ),
//                     )
//                     : SizedBox(child: assetMap[mIndex]),
//           );
//         } else {
//           print("Here 2");

//           return mIndex < 10
//               ? Container(
//                 decoration: BoxDecoration(color: tanColor),
//                 height: 45,
//                 width: 45,
//                 child: Text(
//                   " $mIndex",
//                   style: const TextStyle(fontSize: 35, color: redColor),
//                 ),
//               )
//               : SizedBox(child: assetMap[mIndex]);
//         }
//       },
//     );
//   }
// }

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