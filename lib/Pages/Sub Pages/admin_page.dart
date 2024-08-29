import 'package:cryptel007/Tools/colors.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AdminPage extends StatelessWidget {
  const AdminPage({super.key});

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final double cardPadding = screenWidth * 0.05;
    final double avatarRadius = screenWidth * 0.075;
    final double textFontSize = screenWidth * 0.045;

    return DefaultTabController(
      length: 3, // Number of tabs
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            'Admin Page',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          backgroundColor: AppColors.white,
          bottom: const TabBar(
            indicatorColor: Colors.blueAccent,
            tabs: [
              Tab(text: 'Requesting'),
              Tab(text: 'Accepted'),
              Tab(text: 'Denied'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildUserList(context, 'Requesting'),
            _buildUserList(context, 'Accepted'),
            _buildUserList(context, 'Denied'),
          ],
        ),
      ),
    );
  }

  Widget _buildUserList(BuildContext context, String status) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final double cardPadding = screenWidth * 0.05;
    final double avatarRadius = screenWidth * 0.075;
    const double textFontSize = 12;

    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('users')
          .where('access', isEqualTo: status)
          .orderBy('createdAt', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(child: Text('No users found'));
        }
        final users = snapshot.data!.docs;

        return ListView.builder(
          padding: EdgeInsets.symmetric(
              horizontal: cardPadding, vertical: cardPadding / 2),
          itemCount: users.length,
          itemBuilder: (context, index) {
            var user = users[index];
            return GestureDetector(
              onTap: () => _showRoleSelectionSheet(context, user),
              child: Card(
                color: Colors.white,
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                margin: EdgeInsets.symmetric(vertical: cardPadding / 7),
                child: Padding(
                  padding: EdgeInsets.all(cardPadding / 7),
                  child: ListTile(
                    leading: CircleAvatar(
                      radius: avatarRadius,
                      backgroundImage: user['profilePhoto'] != null
                          ? NetworkImage(user['profilePhoto'])
                          : const AssetImage('assets/profileimg.png')
                              as ImageProvider,
                    ),
                    title: Text(
                      user['username'] ?? '',
                      style: TextStyle(
                          fontSize: textFontSize, fontWeight: FontWeight.bold),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          user['email'] ?? '',
                          style: TextStyle(
                              fontSize: textFontSize * 0.9, color: Colors.grey),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          user['role'] ?? '',
                          style: TextStyle(
                              fontSize: textFontSize, color: Colors.black),
                        ),
                      ],
                    ),
                    trailing: _buildActionButtons(context, user, status),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildActionButtons(
      BuildContext context, QueryDocumentSnapshot user, String status) {
    if (status == 'Accepted') {
      return IconButton(
        icon: const Icon(Icons.block, color: Colors.red),
        onPressed: () => _updateUserStatus(context, user, 'Denied'),
      );
    } else if (status == 'Denied') {
      return IconButton(
        icon: const Icon(Icons.check, color: Colors.green),
        onPressed: () => _updateUserStatus(context, user, 'Accepted'),
      );
    } else {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: const Icon(Icons.check, color: Colors.green),
            onPressed: () => _updateUserStatus(context, user, 'Accepted'),
          ),
          IconButton(
            icon: const Icon(Icons.block, color: Colors.red),
            onPressed: () => _updateUserStatus(context, user, 'Denied'),
          ),
        ],
      );
    }
  }

  void _showRoleSelectionSheet(
      BuildContext context, QueryDocumentSnapshot user) {
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

  void _updateUserRole(
      BuildContext context, QueryDocumentSnapshot user, String newRole) {
    FirebaseFirestore.instance.collection('users').doc(user.id).update({
      'role': newRole,
    }).then((_) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${user['username']}\'s role updated to $newRole'),
          backgroundColor: Colors.blueAccent,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          duration: const Duration(seconds: 3),
        ),
      );
    }).catchError((error) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to update ${user['username']}\'s role: $error'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          duration: const Duration(seconds: 3),
        ),
      );
    });
  }

  void _updateUserStatus(
      BuildContext context, QueryDocumentSnapshot user, String newStatus) {
    FirebaseFirestore.instance.collection('users').doc(user.id).update({
      'access': newStatus,
    }).then((_) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${user['username']}\'s status updated to $newStatus'),
          backgroundColor: Colors.blueAccent,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          duration: const Duration(seconds: 3),
        ),
      );
    }).catchError((error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content:
              Text('Failed to update ${user['username']}\'s status: $error'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          duration: const Duration(seconds: 3),
        ),
      );
    });
  }
}
