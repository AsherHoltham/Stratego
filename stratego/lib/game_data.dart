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
