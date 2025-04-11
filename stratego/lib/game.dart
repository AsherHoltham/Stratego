import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'main.dart';
import 'game_data.dart';

const Color tanColor = Color(0xfff2d2a8);
const Color greyColor = Color(0xff9f9b96);
const Color redColor = Color(0xffb52525);
const Color turquoiseBlue = Color(0xFF40E0D0);

class GameLayout extends StatelessWidget {
  const GameLayout({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PlayerController, Player>(
      builder: (context, state) {
        final int gridSize = 10;
        final double cellSize = 45.0;
        final double totalSize = gridSize * cellSize;

        return Center(
          child: SizedBox(
            width: totalSize,
            height: totalSize,
            child: PixelGridGame(boardData: state.mGameData.mData),
          ),
        );
      },
    );
  }
}

class PixelGridGame extends StatelessWidget {
  final List<TileType> boardData;

  const PixelGridGame({super.key, required this.boardData});

  @override
  Widget build(BuildContext context) {
    const int gridSize = 10;
    return BlocBuilder<PlayerController, Player>(
      builder: (context, state) {
        final controller = context.read<PlayerController>();
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(gridSize, (row) {
            return Row(
              mainAxisSize: MainAxisSize.min,
              children: List.generate(gridSize, (col) {
                int index = row * gridSize + col;
                return GestureDetector(
                  onTap: () {
                    if (state.mCurrSelectedPiece) {
                      controller.toggleHeatMap(index);
                    } else {
                      controller.untoggleHeatMap();
                    }
                  },
                  child: GameTileUI(
                    boardData[index],
                    index,
                    state.mPlayerID == "Player1" ? 1 : 2,
                  ),
                );
              }),
            );
          }),
        );
      },
    );
  }
}

class GameTileUI extends StatelessWidget {
  final TileType mSprite;
  final int index;
  final int playerType;
  const GameTileUI(this.mSprite, this.index, this.playerType, {super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child:
          mSprite.type == playerType || mSprite.type == 0 || mSprite.type == 11
              ? (mSprite.pieceVal >= 10 || mSprite.pieceVal == 0) &&
                      mSprite.pieceVal != 15
                  ? SizedBox(child: assetMap[mSprite.pieceVal])
                  : SoldierTile(mSprite.pieceVal)
              : SoldierTile(14),
    );
  }
}

class PaintedTile extends StatelessWidget {
  final int mIndex;
  const PaintedTile(this.mIndex, {super.key});

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
