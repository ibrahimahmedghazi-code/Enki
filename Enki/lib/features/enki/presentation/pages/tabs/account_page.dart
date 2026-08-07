import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:enki/core/themes/app_colors.dart';
import 'package:enki/core/secrets/app_secrets.dart';
import 'package:enki/features/enki/domain/entities/user_info_entity.dart';
import 'package:enki/features/enki/domain/usecases/update_user.dart';
import 'package:enki/features/enki/presentation/bloc/user_info_bloc.dart';
import 'package:enki/features/enki/presentation/pages/edit_profile_page.dart';
 
class AccountPage extends StatelessWidget {
  const AccountPage({super.key});
 
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.enkiTransparent,
      appBar: AppBar(
        title: const Text('My Profile',
            style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {},
          ),
        ],
      ),
      body: BlocBuilder<UserInfoBloc, UserInfoState>(
        builder: (context, state) {
          if (state is UserInfoLoading || state is UserInfoInitial) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is UserInfoFailure) {
            return Center(child: Text(state.message));
          }
          if (state is UserInfoLoaded) {
            return _ProfileBody(user: state.user);
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }
}
 
class _ProfileBody extends StatelessWidget {
  final UserInfoEntity user;
  const _ProfileBody({required this.user});
 
  Future<void> _pickAndUploadPhoto(BuildContext context) async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 512,
      maxHeight: 512,
      imageQuality: 85,
    );
    if (picked == null) return;
 
    final bytes = await picked.readAsBytes();
    final filename = picked.name;
 
    try {
      // Upload image
      final uri = Uri.parse('${AppSecrets.apiBaseUrl}/api/v1/upload/image');
      final request = http.MultipartRequest('POST', uri);
      request.files.add(http.MultipartFile.fromBytes(
        'file', bytes, filename: filename,
      ));
      final streamed = await request.send();
      final response = await http.Response.fromStream(streamed);
 
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        final imageFilename = data['filename'] as String;
 
        // Update user profile with new image filename
        if (context.mounted) {
          context.read<UserInfoBloc>().add(
            UserInfoUpdate(
              params: UpdateUserParams(
                userid: user.userid,
                profilePicturePath: imageFilename,
              ),
            ),
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to upload photo: $e')),
        );
      }
    }
  }
 
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // ── Avatar with camera button ──────────────────────────
          Stack(
            children: [
            CircleAvatar(
              radius: 60,
              backgroundColor:
                  Theme.of(context).primaryColor.withOpacity(0.1),
              backgroundImage: user.profilePicturePath.isNotEmpty &&
                      !user.profilePicturePath.startsWith('assets')
                  ? NetworkImage(user.profilePicturePath)
                  : null,
              // ← only set onBackgroundImageError when backgroundImage is not null
              onBackgroundImageError: user.profilePicturePath.isNotEmpty &&
                      !user.profilePicturePath.startsWith('assets')
                  ? (_, __) {}
                  : null,
              child: user.profilePicturePath.isEmpty ||
                      user.profilePicturePath.startsWith('assets')
                  ? const Icon(Icons.person,
                      size: 60, color: AppColors.enkiMain)
                  : null,
            ),

              Positioned(
                bottom: 0,
                right: 0,
                child: GestureDetector(
                  onTap: () => _pickAndUploadPhoto(context),
                  child: Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: AppColors.enkiMain,
                      shape: BoxShape.circle,
                      border: Border.all(
                          color: Theme.of(context).scaffoldBackgroundColor,
                          width: 2),
                    ),
                    child: const Icon(Icons.camera_alt,
                        size: 16, color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
 
          Text(user.fullName,
              style: Theme.of(context)
                  .textTheme
                  .headlineSmall
                  ?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
 
          Text(
            _buildSubtitle(user),
            style: Theme.of(context)
                .textTheme
                .titleMedium
                ?.copyWith(color: AppColors.enkiDarkMain),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
 
          ElevatedButton.icon(
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => BlocProvider.value(
                  value: context.read<UserInfoBloc>(),
                  child: EditProfilePage(user: user),
                ),
              ),
            ),
            icon: const Icon(Icons.edit_outlined, size: 20),
            label: const Text('Edit Profile'),
            style: ElevatedButton.styleFrom(
              padding:
                  const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30)),
            ),
          ),
          const SizedBox(height: 32),
 
          _buildInfoCard(context,
              title: 'About Me',
              icon: Icons.person_outline,
              content: user.description?.isNotEmpty == true
                  ? user.description!
                  : 'No description yet.'),
          const SizedBox(height: 16),
 
          _buildInfoCard(context,
              title: 'Personal Information',
              icon: Icons.info_outline,
              content: _buildPersonalInfo(user)),
        ],
      ),
    );
  }
 
  String _buildSubtitle(UserInfoEntity user) {
    final s = user.speciality ?? '';
    final w = user.workAt ?? '';
    if (s.isNotEmpty && w.isNotEmpty) return '$s @ $w';
    if (s.isNotEmpty) return s;
    if (w.isNotEmpty) return w;
    return 'No role set yet';
  }
 
  String _buildPersonalInfo(UserInfoEntity user) {
    final parts = <String>[];
    if (user.age != null) parts.add('Age: ${user.age} years old');
    if (user.speciality?.isNotEmpty == true)
      parts.add('Speciality: ${user.speciality}');
    if (user.workAt?.isNotEmpty == true)
      parts.add('Works at: ${user.workAt}');
    return parts.isNotEmpty ? parts.join('\n') : 'No information added yet.';
  }
 
  Widget _buildInfoCard(BuildContext context,
      {required String title,
      required IconData icon,
      required String content}) {
    return Card(
      elevation: 0,
      color: AppColors.enkiTransparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              Icon(icon, color: Theme.of(context).primaryColor),
              const SizedBox(width: 12),
              Text(title,
                  style: Theme.of(context)
                      .textTheme
                      .titleMedium
                      ?.copyWith(fontWeight: FontWeight.bold)),
            ]),
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 12.0),
              child: Divider(height: 1),
            ),
            Text(content,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    height: 1.5, color: AppColors.enkiDarkMain)),
          ],
        ),
      ),
    );
  }
}
