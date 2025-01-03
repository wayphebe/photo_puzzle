import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'dart:math';

class PhotoPuzzleApp extends StatefulWidget {
  @override
  _PhotoPuzzleAppState createState() => _PhotoPuzzleAppState();
}

class _PhotoPuzzleAppState extends State<PhotoPuzzleApp> {
  final int gridSize = 3;
  List<int> tiles = List.generate(9, (index) => index);
  File? selectedImage;
  int? draggingTileIndex;

  @override
  void initState() {
    super.initState();
    tiles.shuffle(Random());
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(source: source);
      
      if (image != null) {
        setState(() {
          selectedImage = File(image.path);
          tiles.shuffle(Random());
        });
      }
    } catch (e) {
      // Handle error gracefully
      showCupertinoDialog(
        context: context,
        builder: (context) => CupertinoAlertDialog(
          title: Text('Error'),
          content: Text('Could not access image. Please try again.'),
          actions: [
            CupertinoDialogAction(
              child: Text('OK'),
              onPressed: () => Navigator.pop(context),
            ),
          ],
        ),
      );
    }
  }

  void _showImageSourceDialog() {
    showCupertinoModalPopup(
      context: context,
      builder: (context) => CupertinoActionSheet(
        actions: [
          CupertinoActionSheetAction(
            onPressed: () {
              Navigator.pop(context);
              _pickImage(ImageSource.camera);
            },
            child: Text('Take Photo'),
          ),
          CupertinoActionSheetAction(
            onPressed: () {
              Navigator.pop(context);
              _pickImage(ImageSource.gallery);
            },
            child: Text('Choose from Library'),
          ),
        ],
        cancelButton: CupertinoActionSheetAction(
          onPressed: () => Navigator.pop(context),
          child: Text('Cancel'),
          isDestructiveAction: true,
        ),
      ),
    );
  }

  void _onTileDragStart(int index) {
    setState(() {
      draggingTileIndex = index;
    });
  }

  void _onTileDragEnd(DraggableDetails details) {
    setState(() {
      draggingTileIndex = null;
    });
  }

  void _onTileAccept(int targetIndex) {
    if (draggingTileIndex != null) {
      setState(() {
        int temp = tiles[targetIndex];
        tiles[targetIndex] = tiles[draggingTileIndex!];
        tiles[draggingTileIndex!] = temp;
        draggingTileIndex = null;
        
        // Check if puzzle is complete
        if (_isPuzzleComplete()) {
          _showCompletionDialog();
        }
      });
    }
  }

  bool _isPuzzleComplete() {
    for (int i = 0; i < tiles.length; i++) {
      if (tiles[i] != i) return false;
    }
    return true;
  }

  void _showCompletionDialog() {
    showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: Text('Congratulations!'),
        content: Text('You completed the puzzle!'),
        actions: [
          CupertinoDialogAction(
            child: Text('New Game'),
            onPressed: () {
              Navigator.pop(context);
              _showImageSourceDialog();
            },
          ),
          CupertinoDialogAction(
            child: Text('Close'),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
          brightness: Brightness.light,
        ),
      ),
      home: CupertinoPageScaffold(
        navigationBar: CupertinoNavigationBar(
          middle: Text('Photo Puzzle'),
          trailing: CupertinoButton(
            padding: EdgeInsets.zero,
            child: Icon(CupertinoIcons.camera),
            onPressed: _showImageSourceDialog,
          ),
        ),
        child: SafeArea(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (selectedImage == null)
                  CupertinoButton(
                    child: Text('Select a Photo to Start'),
                    onPressed: _showImageSourceDialog,
                  )
                else
                  Container(
                    width: 300,
                    height: 300,
                    child: GridView.builder(
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: gridSize,
                      ),
                      itemCount: tiles.length,
                      itemBuilder: (context, index) {
                        return DragTarget<int>(
                          onWillAccept: (data) => true,
                          onAccept: (_) => _onTileAccept(index),
                          builder: (context, candidateData, rejectedData) {
                            return Draggable<int>(
                              data: index,
                              feedback: _buildTile(index, size: 100),
                              childWhenDragging: Container(
                                margin: EdgeInsets.all(1),
                                color: Colors.grey.withOpacity(0.3),
                              ),
                              onDragStarted: () => _onTileDragStart(index),
                              onDragEnd: _onTileDragEnd,
                              child: _buildTile(index),
                            );
                          },
                        );
                      },
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTile(int index, {double? size}) {
    if (selectedImage == null) return SizedBox();
    
    return Container(
      margin: EdgeInsets.all(1),
      width: size,
      height: size,
      child: ClipRect(
        child: Image.file(
          selectedImage!,
          fit: BoxFit.cover,
          alignment: Alignment(
            (tiles[index] % gridSize) / (gridSize - 1) * 2 - 1,
            (tiles[index] ~/ gridSize) / (gridSize - 1) * 2 - 1,
          ),
        ),
      ),
    );
  }
}
