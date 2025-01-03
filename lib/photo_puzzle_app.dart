import 'package:flutter/material.dart';
import 'dart:math';

class PhotoPuzzleApp extends StatefulWidget {
  @override
  _PhotoPuzzleAppState createState() => _PhotoPuzzleAppState();
}

class _PhotoPuzzleAppState extends State<PhotoPuzzleApp> {
  final int gridSize = 4;
  List<int> tiles = List.generate(16, (index) => index);
  final String _mockImageUrl = 'https://via.placeholder.com/400';

  @override
  void initState() {
    super.initState();
    tiles.shuffle(Random());
  }

  void _onTileTap(int index) {
    int emptyIndex = tiles.indexOf(0);
    if (_isAdjacent(index, emptyIndex)) {
      setState(() {
        tiles[emptyIndex] = tiles[index];
        tiles[index] = 0;
      });
    }
  }

  bool _isAdjacent(int index1, int index2) {
    int row1 = index1 ~/ gridSize;
    int col1 = index1 % gridSize;
    int row2 = index2 ~/ gridSize;
    int col2 = index2 % gridSize;
    return (row1 == row2 && (col1 - col2).abs() == 1) ||
           (col1 == col2 && (row1 - row2).abs() == 1);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: Text('Photo Puzzle'),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 400,
                height: 400,
                child: GridView.builder(
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: gridSize,
                  ),
                  itemCount: tiles.length,
                  itemBuilder: (context, index) {
                    return GestureDetector(
                      onTap: () => _onTileTap(index),
                      child: Container(
                        margin: EdgeInsets.all(1),
                        color: tiles[index] == 0 ? Colors.white : Colors.blue,
                        child: tiles[index] == 0
                            ? SizedBox.shrink()
                            : Image.network(
                                _mockImageUrl,
                                fit: BoxFit.cover,
                                width: 100,
                                height: 100,
                                alignment: Alignment(
                                  (tiles[index] % gridSize) / (gridSize - 1) * 2 - 1,
                                  (tiles[index] ~/ gridSize) / (gridSize - 1) * 2 - 1,
                                ),
                              ),
                      ),
                    );
                  },
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    tiles.shuffle(Random());
                  });
                },
                child: Text('Create Puzzle'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
