import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:enki/core/themes/app_colors.dart';
import 'package:enki/features/enki/domain/entities/user_info_entity.dart';
import 'package:enki/features/enki/domain/usecases/update_user.dart';
import 'package:enki/features/enki/presentation/bloc/user_info_bloc.dart';
 
class EditProfilePage extends StatefulWidget {
  final UserInfoEntity user;
  const EditProfilePage({super.key, required this.user});
 
  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}
 
class _EditProfilePageState extends State<EditProfilePage> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameCtrl;
  late final TextEditingController _workCtrl;
  late final TextEditingController _ageCtrl;
  late final TextEditingController _descCtrl;
  late final TextEditingController _specCtrl;
 
  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController(text: widget.user.fullName);
    _workCtrl = TextEditingController(text: widget.user.workAt ?? '');
    _ageCtrl = TextEditingController(
        text: widget.user.age?.toString() ?? '');
    _descCtrl =
        TextEditingController(text: widget.user.description ?? '');
    _specCtrl =
        TextEditingController(text: widget.user.speciality ?? '');
  }
 
  @override
  void dispose() {
    _nameCtrl.dispose();
    _workCtrl.dispose();
    _ageCtrl.dispose();
    _descCtrl.dispose();
    _specCtrl.dispose();
    super.dispose();
  }
 
  void _save() {
    if (!_formKey.currentState!.validate()) return;
 
    context.read<UserInfoBloc>().add(
          UserInfoUpdate(
            params: UpdateUserParams(
              userid: widget.user.userid,
              fullName: _nameCtrl.text.trim(),
              workAt: _workCtrl.text.trim().isEmpty
                  ? null
                  : _workCtrl.text.trim(),
              age: _ageCtrl.text.trim().isEmpty
                  ? null
                  : int.tryParse(_ageCtrl.text.trim()),
              description: _descCtrl.text.trim().isEmpty
                  ? null
                  : _descCtrl.text.trim(),
              speciality: _specCtrl.text.trim().isEmpty
                  ? null
                  : _specCtrl.text.trim(),
            ),
          ),
        );
  }
 
  @override
  Widget build(BuildContext context) {
    return BlocListener<UserInfoBloc, UserInfoState>(
      listener: (context, state) {
        if (state is UserInfoLoaded) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Profile updated!'),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.pop(context);
        }
        if (state is UserInfoFailure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: Colors.red,
            ),
          );
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Edit Profile',
              style: TextStyle(fontWeight: FontWeight.bold)),
          centerTitle: true,
          actions: [
            BlocBuilder<UserInfoBloc, UserInfoState>(
              builder: (context, state) {
                if (state is UserInfoUpdating) {
                  return const Padding(
                    padding: EdgeInsets.all(16.0),
                    child: SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  );
                }
                return TextButton(
                  onPressed: _save,
                  child: Text('Save',
                      style: TextStyle(
                          color: AppColors.enkiMain,
                          fontWeight: FontWeight.bold,
                          fontSize: 16)),
                );
              },
            ),
          ],
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildField(
                  label: 'Full name *',
                  controller: _nameCtrl,
                  hint: 'Your full name',
                  validator: (v) =>
                      v == null || v.trim().isEmpty ? 'Name is required' : null,
                ),
                _buildField(
                  label: 'Works at',
                  controller: _workCtrl,
                  hint: 'Company or institution',
                ),
                _buildField(
                  label: 'Age',
                  controller: _ageCtrl,
                  hint: 'Your age',
                  keyboardType: TextInputType.number,
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) return null;
                    final age = int.tryParse(v.trim());
                    if (age == null || age <= 0) return 'Enter a valid age';
                    return null;
                  },
                ),
                _buildField(
                  label: 'Speciality',
                  controller: _specCtrl,
                  hint: 'e.g. Flutter Developer, Data Scientist',
                ),
                _buildField(
                  label: 'About me',
                  controller: _descCtrl,
                  hint: 'Tell others about yourself...',
                  maxLines: 4,
                ),
                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _save,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.enkiMain,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Save changes',
                      style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
 
  Widget _buildField({
    required String label,
    required TextEditingController controller,
    required String hint,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: const TextStyle(
                  fontSize: 13, fontWeight: FontWeight.w600)),
          const SizedBox(height: 6),
          TextFormField(
            controller: controller,
            keyboardType: keyboardType,
            maxLines: maxLines,
            validator: validator,
            decoration: InputDecoration(
              hintText: hint,
              filled: true,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(
                  horizontal: 14, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }
}
