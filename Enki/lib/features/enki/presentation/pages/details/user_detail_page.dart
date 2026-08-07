 import 'package:flutter/material.dart';
import 'package:enki/features/enki/domain/entities/user_info_entity.dart';
import 'package:enki/core/themes/app_colors.dart';
 
class UserDetailPage extends StatelessWidget {
  final UserInfoEntity user;
  const UserDetailPage({super.key, required this.user});
 
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: const BackButton(color: Colors.white),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildHeader(context),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 70),
                  Center(
                    child: Column(
                      children: [
                        Text(
                          user.fullName,
                          style: const TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            letterSpacing: -0.5,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          _buildSubtitle(user),
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.blueGrey[600],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),
                  _buildStatsRow(),
                  const SizedBox(height: 32),
                  const Text(
                    "About Me",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    user.description ?? 'No description yet.',
                    style: const TextStyle(
                      fontSize: 15,
                      height: 1.6,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
 
  String _buildSubtitle(UserInfoEntity user) {
    final speciality = user.speciality ?? '';
    final workAt = user.workAt ?? '';
    if (speciality.isNotEmpty && workAt.isNotEmpty) return '$speciality @ $workAt';
    if (speciality.isNotEmpty) return speciality;
    if (workAt.isNotEmpty) return workAt;
    return '';
  }
 
  Widget _buildHeader(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      alignment: Alignment.bottomCenter,
      children: [
        Container(
          height: 200,
          width: double.infinity,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [AppColors.enkiMain, Color(0xFF0D47A1)],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
        ),
        Positioned(
          bottom: -50,
          child: Container(
            padding: const EdgeInsets.all(4),
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
            child: CircleAvatar(
              radius: 55,
              backgroundImage: NetworkImage(user.profilePicturePath),
              onBackgroundImageError: (_, __) {},
            ),
          ),
        ),
      ],
    );
  }
 
  Widget _buildStatsRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildStatItem("Age", user.age?.toString() ?? '—'),
      ],
    );
  }
 
  Widget _buildStatItem(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),
        Text(
          label,
          style: const TextStyle(color: Colors.grey, fontSize: 13),
        ),
      ],
    );
  }
}    
