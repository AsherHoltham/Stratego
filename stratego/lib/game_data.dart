import 'package:flutter/material.dart';

Color tanColor = Color(0xfff2d2a8);
Color greyColor = Color(0xff9f9b96);
Color redColor = Color(0xffb52525);

Map<int, Widget> assetMap = {
  10: Image.asset('lib/assets/general.png', width: 45, height: 45),
  0: Image.asset('lib/assets/grassblock.png', width: 45, height: 45),
  11: Image.asset('lib/assets/watertile.png', width: 45, height: 45),
  12: Image.asset('lib/assets/bomb.png', width: 45, height: 45),
  13: Image.asset('lib/assets/flag.png', width: 45, height: 45),
};

Map<int, int> playerPieces = {
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
  }
}

class SoldierTile extends StatelessWidget {
  final int mIndex;
  const SoldierTile(this.mIndex, {super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
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

  const NineByNinePixelWidget(this.mSprite, {super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child:
          mSprite >= 10 || mSprite == 0
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
    return GridView.count(
      crossAxisCount: 10,
      mainAxisSpacing: 1,
      crossAxisSpacing: 1,
      shrinkWrap: true,
      children: List.generate(100, (index) {
        return FloatingActionButton(
          onPressed: () {},
          child: NineByNinePixelWidget(boardData[index]),
        );
      }),
    );
  }
}

BoardData testData = BoardData();

void main() => runApp(const TestApp());

class TestApp extends StatelessWidget {
  const TestApp({super.key});

  @override
  Widget build(BuildContext context) {
    final int gridSize = 10;
    final double cellSize = 45.0;
    final double totalSize = gridSize * cellSize;

    return MaterialApp(
      home: Scaffold(
        body: Center(
          child: SizedBox(
            width: totalSize,
            height: totalSize,
            child: PixelGrid(boardData: testData.mPieces),
          ),
        ),
      ),
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
