import 'package:cryptel007/Tools/colors.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AdminPage extends StatelessWidget {
  const AdminPage({super.key});

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final double screenHeight = MediaQuery.of(context).size.height;
    final double cardPadding = screenWidth * 0.05;
    final double avatarRadius = screenWidth * 0.075;
    final double textFontSize = screenWidth * 0.045;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Admin Page',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        backgroundColor: AppColors.white,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('users').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('No users found'));
          }
          final users = snapshot.data!.docs;

          return ListView.builder(
            padding: EdgeInsets.symmetric(horizontal: cardPadding, vertical: cardPadding / 2),
            itemCount: users.length,
            itemBuilder: (context, index) {
              var user = users[index];
              return GestureDetector(
                onTap: () => _showRoleSelectionSheet(context, user),
                child: Card(
                  color: Colors.white,
                  elevation: 5,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  margin: EdgeInsets.symmetric(vertical: cardPadding / 2),
                  child: Padding(
                    padding: EdgeInsets.all(cardPadding / 2),
                    child: ListTile(
                      leading: CircleAvatar(
                        radius: avatarRadius,
                        backgroundImage: user['profilePhoto'] != null
                            ? NetworkImage(user['profilePhoto'])
                            : const AssetImage('assets/profileimg.png') as ImageProvider,
                      ),
                      title: Text(
                        user['username'] ?? '',
                        style: TextStyle(fontSize: textFontSize, fontWeight: FontWeight.bold),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            user['email'] ?? '',
                            style: TextStyle(fontSize: textFontSize * 0.9, color: Colors.grey),
                          ),
                          const SizedBox(height: 5),
                          Text(
                            user['role'] ?? '',
                            style: TextStyle(fontSize: textFontSize, color: Colors.black),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  void _showRoleSelectionSheet(BuildContext context, QueryDocumentSnapshot user) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Container(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              const Text(
                'Select Role',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              ListTile(
                title: const Text('Manager'),
                onTap: () => _updateUserRole(context, user, 'Manager'),
              ),
              ListTile(
                title: const Text('Supervisor'),
                onTap: () => _updateUserRole(context, user, 'Supervisor'),
              ),
              ListTile(
                title: const Text('Editor'),
                onTap: () => _updateUserRole(context, user, 'Editor'),
              ),
              ListTile(
                title: const Text('Customer'),
                onTap: () => _updateUserRole(context, user, 'Customer'),
              ),
              ListTile(
                title: const Text('MD'),
                onTap: () => _updateUserRole(context, user, 'MD'),
              ),
            ],
          ),
        );
      },
    );
  }

  void _updateUserRole(BuildContext context, QueryDocumentSnapshot user, String newRole) {
    FirebaseFirestore.instance.collection('users').doc(user.id).update({
      'role': newRole,
    }).then((_) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Role updated to $newRole')),
      );
    }).catchError((error) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update role: $error')),
      );
    });
  }
}
