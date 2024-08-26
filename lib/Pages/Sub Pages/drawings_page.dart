import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cryptel007/Pages/Sub%20Pages/drawingsupload_page.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';


class DrawingsPage extends StatefulWidget {
  final String workOrderNumber;

  const DrawingsPage({required this.workOrderNumber});

  @override
  _DrawingsPageState createState() => _DrawingsPageState();
}

class _DrawingsPageState extends State<DrawingsPage> {
  String drawingID = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        leading: IconButton(
          icon: Image.asset('assets/arrow.png'),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: const Text(
          'Drawings',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              setState(() {
                drawingID = '';
              });
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.blue,
                borderRadius: BorderRadius.circular(15),
              ),
              child: TextField(
                decoration: InputDecoration(
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                  labelText: 'Search by Drawing ID',
                  labelStyle: const TextStyle(color: Colors.white),
                  border: InputBorder.none,
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.clear, color: Colors.black12),
                    onPressed: () {
                      setState(() {
                        drawingID = '';
                      });
                    },
                  ),
                ),
                onChanged: (value) {
                  setState(() {
                    drawingID = value;
                  });
                },
              ),
            ),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('works')
                  .doc(widget.workOrderNumber)
                  .collection('Drawings')
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(child: Text('No drawings found.'));
                }

                var drawings = snapshot.data!.docs;

                // Filter drawings by ID if necessary
                if (drawingID.isNotEmpty) {
                  drawings =
                      drawings.where((doc) => doc.id == drawingID).toList();
                }

                return GridView.builder(
                  padding: const EdgeInsets.all(16),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: 1,
                  ),
                  itemCount: drawings.length,
                  itemBuilder: (context, index) {
                    var drawing = drawings[index];
                    return GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => FullScreenImagePage(
                              drawings: drawings,
                              initialIndex: index,
                            ),
                          ),
                        );
                      },
                      child: Card(
                        elevation: 5,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15)),
                        child: Column(
                          children: [
                            Expanded(
                              child: ClipRRect(
                                borderRadius: const BorderRadius.vertical(
                                    top: Radius.circular(15)),
                                child: Image.network(
                                  drawing['url'],
                                  fit: BoxFit.cover,
                                  width: double.infinity,
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(
                                'Drawing ID: ${drawing.id}',
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(30),
        ),
        child: FloatingActionButton.extended(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => DrawingUploadPage(
                  workOrderNumber: widget.workOrderNumber,
                ),
              ),
            );
          },
          label: const Text(
            'Upload Drawing',
            style: TextStyle(color: Colors.white),
          ),
          icon: const Icon(
            Icons.add,
            color: Colors.white,
          ),
          backgroundColor: Colors.blue, // Background color for the FAB
        ),
      ),
    );
  }
}

class FullScreenImagePage extends StatelessWidget {
  final List<DocumentSnapshot> drawings;
  final int initialIndex;

  const FullScreenImagePage(
      {Key? key, required this.drawings, required this.initialIndex})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: PhotoViewGallery.builder(
        itemCount: drawings.length,
        pageController: PageController(initialPage: initialIndex),
        builder: (context, index) {
          var drawing = drawings[index];
          return PhotoViewGalleryPageOptions(
            imageProvider: NetworkImage(drawing['url']),
            minScale: PhotoViewComputedScale.contained,
            maxScale: PhotoViewComputedScale.covered * 2,
            heroAttributes: PhotoViewHeroAttributes(tag: drawing.id),
          );
        },
        scrollPhysics: const BouncingScrollPhysics(),
        backgroundDecoration: const BoxDecoration(
          color: Colors.black,
        ),
        loadingBuilder: (context, event) => Center(
          child: Container(
            width: 50.0,
            height: 50.0,
            child: const CircularProgressIndicator(),
          ),
        ),
      ),
    );
  }
}
