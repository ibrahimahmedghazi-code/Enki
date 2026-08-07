import 'package:enki/features/enki/presentation/pages/details/user_detail_page.dart';
import 'package:flutter/material.dart';
import 'package:enki/core/themes/app_colors.dart';
import 'package:enki/features/enki/presentation/widgets/cards/user_card.dart';
import 'package:enki/features/enki/presentation/providers/user_list.dart';

class NetworkPage extends StatelessWidget {
  const NetworkPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'My Network',
          style: TextStyle(
            color: AppColors.enkiMain,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true, 
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),
            
            Expanded(
              child: ListView.builder(
                scrollDirection: Axis.vertical,
                itemCount: UserList.followedUsers.length,
                itemBuilder: (context, index) {
                  final user = UserList.followedUsers[index];
                  
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12.0), 
                    child: UserCard(
                      userInfo: user,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => UserDetailPage(user: user),
                          ),
                        );
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
