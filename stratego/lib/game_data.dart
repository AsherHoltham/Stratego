import 'package:flutter/material.dart';

Color tanColor = Color(0xfff2d2a8);
Color greyColor = Color(0xff9f9b96);
Color redColor = Color(0xffb52525);

Map<int, Widget> assetMap = {
  10: Image.asset('lib/assets/general.png', width: 9, height: 9),
  0: Image.asset('lib/assets/grassblock.png', width: 9, height: 9),
  11: Image.asset('lib/assets/waterblock.png', width: 9, height: 9),
  12: Image.asset('lib/assets/bomb.png', width: 9, height: 9),
  13: Image.asset('lib/assets/flag.png', width: 9, height: 9),
};

class BoardData {
  late List<int> mPieces;
  BoardData() {
    mPieces = List.generate(100, (index) => 0);
    mPieces[52] = 11;
    mPieces[53] = 11;
    mPieces[56] = 11;
    mPieces[57] = 11;
    mPieces[62] = 11;
    mPieces[63] = 11;
    mPieces[66] = 11;
    mPieces[67] = 11;
  }
}

class Dot extends Positioned {
  Dot({super.key, super.top, super.left})
    : super(
        child: Container(
          height: 2,
          width: 2,
          decoration: BoxDecoration(color: redColor, shape: BoxShape.circle),
        ),
      );
}

class SoldierTile extends StatelessWidget {
  final int mIndex;
  final List<Dot> mDots = [];
  SoldierTile(this.mIndex, {super.key}) {
    if (mIndex % 2 == 1) {
      mDots.add(Dot(top: 4, left: 4)); // middle dot
    }
    if (mIndex == 3 ||
        mIndex == 8 ||
        mIndex == 9 ||
        mIndex == 7) // other corners
    {
      mDots.add(Dot(top: 1, left: 4));
      mDots.add(Dot(top: 7, left: 4));
    }
    if (mIndex == 9) // other corners
    {
      mDots.add(Dot(top: 4, left: 1));
      mDots.add(Dot(top: 4, left: 7));
    }
    if (mIndex == 8 || mIndex == 6) // middle side dots
    {
      mDots.add(Dot(top: 4, left: 3));
      mDots.add(Dot(top: 4, left: 6));
    }
    if (mIndex == 9 || mIndex == 8 || mIndex == 5 || mIndex == 7) //corners
    {
      mDots.add(Dot(top: 1, left: 1));
      mDots.add(Dot(top: 1, left: 7));
      mDots.add(Dot(top: 7, left: 1));
      mDots.add(Dot(top: 7, left: 7));
    }
    if (mIndex == 4) //corners
    {
      mDots.add(Dot(top: 3, left: 3));
      mDots.add(Dot(top: 3, left: 6));
      mDots.add(Dot(top: 6, left: 3));
      mDots.add(Dot(top: 6, left: 6));
    }
    if (mIndex == 2 || mIndex == 6 || mIndex == 8) //corners
    {
      mDots.add(Dot(top: 4, left: 3));
      mDots.add(Dot(top: 4, left: 6));
    }

    if (mIndex == 6) //corners
    {
      mDots.add(Dot(top: 1, left: 3));
      mDots.add(Dot(top: 1, left: 6));
      mDots.add(Dot(top: 7, left: 3));
      mDots.add(Dot(top: 7, left: 6));
    }
  }
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(width: 1),
        color: (tanColor),
      ),
      height: 9,
      width: 9,
      child: Stack(children: mDots),
    );
  }
}

// Make ambient tile

class NineByNinePixelWidget extends StatelessWidget {
  final int mSprite;

  const NineByNinePixelWidget(this.mSprite, {super.key});

  @override
  Widget build(BuildContext context) {
    return mSprite > 0 && mSprite < 10
        ? SoldierTile(mSprite)
        : SizedBox(width: 9, height: 9, child: assetMap[mSprite]);
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
        return NineByNinePixelWidget(boardData[index]);
      }),
    );
  }
}

// class Dice1 extends StatelessWidget
// { final int id;
//   Dice1(this.id, {super.key});

//   static final randy = Random();
//   late BuildContext bc;
//   @override
//   Widget build( BuildContext context )
//   { bc = context;
//     List<Dot> dots = [];
//     DiceCubit dCubit = BlocProvider.of<DiceCubit>(context);
//     DiceState dState = dCubit.state;
//     int face = dState.face;
//     bool holding = dState.hold;
//     if ( face>1 ) // upper left and lower right
//     { dots.add( Dot(top:10,left:20) );
//       dots.add( Dot(top:70, left:70) );
//     }
//     if ( face>3 ) // other corners
//     { dots.add( Dot(top:10,left:70) );
//       dots.add( Dot(top:70, left:20) );
//     }
//     if ( face==6 ) // middle side dots
//     { dots.add( Dot(top:40,left:20) );
//       dots.add( Dot(top:40, left:70) );
//     }
//     if ( face==1 || face==3 || face==5 ) // center dot
//     { dots.add( Dot(top:40,left:45) );
//     }
