import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'dart:math';
import 'package:google_fonts/google_fonts.dart';

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
          seedColor: const Color(0xFF6B9DFF),
          brightness: Brightness.light,
        ),
        textTheme: GoogleFonts.poppinsTextTheme(),
      ),
      home: CupertinoPageScaffold(
        backgroundColor: const Color(0xFFF8F9FD),
        navigationBar: CupertinoNavigationBar(
          backgroundColor: Colors.white.withOpacity(0.8),
          middle: Text(
            'Photo Puzzle',
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.w600,
              color: const Color(0xFF2D3142),
            ),
          ),
          trailing: Container(
            decoration: BoxDecoration(
              color: const Color(0xFF6B9DFF),
              borderRadius: BorderRadius.circular(8),
            ),
            child: CupertinoButton(
              padding: const EdgeInsets.all(8),
              child: Icon(
                CupertinoIcons.camera,
                color: Colors.white,
                size: 20,
              ),
              onPressed: _showImageSourceDialog,
            ),
          ),
        ),
        child: SafeArea(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (selectedImage == null)
                  Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE8EEFF),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Icon(
                          CupertinoIcons.photo,
                          size: 48,
                          color: const Color(0xFF6B9DFF),
                        ),
                      ),
                      const SizedBox(height: 24),
                      Text(
                        'Start Your Puzzle',
                        style: GoogleFonts.poppins(
                          fontSize: 24,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF2D3142),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Choose a photo to begin the game',
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          color: const Color(0xFF9094A6),
                        ),
                      ),
                      const SizedBox(height: 24),
                      CupertinoButton(
                        color: const Color(0xFF6B9DFF),
                        borderRadius: BorderRadius.circular(12),
                        child: Text(
                          'Select Photo',
                          style: GoogleFonts.poppins(
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        onPressed: _showImageSourceDialog,
                      ),
                    ],
                  )
                else
                  Column(
                    children: [
                      Container(
                        width: 300,
                        height: 300,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(16),
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
                      ),
                      const SizedBox(height: 24),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          CupertinoButton(
                            color: const Color(0xFFE8EEFF),
                            borderRadius: BorderRadius.circular(12),
                            child: Text(
                              'New Game',
                              style: GoogleFonts.poppins(
                                color: const Color(0xFF6B9DFF),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            onPressed: _showImageSourceDialog,
                          ),
                        ],
                      ),
                    ],
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
