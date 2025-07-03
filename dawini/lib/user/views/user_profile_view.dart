import 'package:dawini/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controllers/user_profile_controller.dart';

class UserProfileView extends StatefulWidget {
  const UserProfileView({super.key});

  @override
  UserProfileViewState createState() => UserProfileViewState();
}

class UserProfileViewState extends State<UserProfileView> {
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  final TextEditingController _passwordController = TextEditingController();

  bool _editing = false;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final userProfileController = Provider.of<UserProfileController>(
      context,
      listen: false,
    );
    _nameController = TextEditingController(text: '');
    _emailController = TextEditingController(text: userProfileController.email);

    userProfileController.userName.then((name) {
      setState(() => _nameController.text = name);
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _toast(String msg) => ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(msg, textDirection: TextDirection.rtl),
      backgroundColor: AppColors.plum,
      behavior: SnackBarBehavior.floating,
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    ),
  );

  Future<void> _confirmAndLogout(UserProfileController ctrl) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder:
          (c) => Directionality(
            textDirection: TextDirection.rtl,
            child: AlertDialog(
              title: const Text('تسجيل الخروج'),
              content: const Text('هل أنت متأكد أنك تريد تسجيل الخروج؟'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(c).pop(false),
                  child: const Text('إلغاء'),
                ),
                TextButton(
                  onPressed: () => Navigator.of(c).pop(true),
                  child: const Text('خروج'),
                ),
              ],
            ),
          ),
    );

    if (confirm == true) {
      if (context.mounted) {
        Navigator.pushNamed(context, 'Dawini/User/Login');
      }
      await Future.delayed(const Duration(milliseconds: 100));
      await ctrl.logout(context);
    }
  }

  Future<void> _confirmAndDelete(UserProfileController ctrl) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder:
          (c) => Directionality(
            textDirection: TextDirection.rtl,
            child: AlertDialog(
              backgroundColor: AppColors.darkBackground,
              title: const Text(
                'حذف الحساب',
                style: const TextStyle(color: Colors.white),
              ),
              content: const Text(
                'هل أنت متأكد أنك تريد حذف حسابك؟ لا يمكن التراجع عن هذا الإجراء.',
                style: const TextStyle(color: Colors.white70),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(c).pop(false),
                  child: const Text(
                    'إلغاء',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
                TextButton(
                  onPressed: () => Navigator.of(c).pop(true),
                  child: const Text(
                    'حذف',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
    );

    if (confirm == true) {
      if (context.mounted) {
        Navigator.pushNamed(context, 'Dawini/User/Signup');
      }
      await Future.delayed(const Duration(milliseconds: 100));
      if (context.mounted) {
        await ctrl.deleteAccount(context);
      }
    }
  }

  Widget _infoCard(String label, Widget child) => Container(
    margin: const EdgeInsets.symmetric(vertical: 8),
    padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 18),
    decoration: BoxDecoration(
      color: AppColors.darkPlum,
      borderRadius: BorderRadius.circular(18),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.1),
          blurRadius: 5,
          offset: const Offset(0, 3),
        ),
      ],
    ),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 120,
          child: Text(
            '$label:',
            style: const TextStyle(
              color: AppColors.plumPurple,
              fontFamily: 'Jawadtaut',
              fontSize: 19,
            ),
          ),
        ),
        Expanded(child: child),
      ],
    ),
  );

  Widget _textOrField(
    TextEditingController controller, {
    bool isPassword = false,
  }) {
    if (!_editing) {
      return Text(
        controller.text,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 17,
          fontFamily: 'Din',
        ),
      );
    }
    return TextField(
      controller: controller,
      obscureText: isPassword,
      style: const TextStyle(color: Colors.white, fontFamily: 'Din'),
      decoration: const InputDecoration(
        filled: true,
        fillColor: AppColors.deepPurple,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(20)),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final profileController = Provider.of<UserProfileController>(context);

    return Scaffold(
      backgroundColor: AppColors.darkBackground,
      appBar: AppBar(
        backgroundColor: AppColors.darkBackground,
        elevation: 0,
        leadingWidth: 100,
        leading: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            IconButton(
              icon: const Icon(Icons.delete_forever, color: AppColors.darkPlum),
              tooltip: 'حذف الحساب',
              onPressed: () => _confirmAndDelete(profileController),
            ),
            IconButton(
              icon:
                  _saving
                      ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                      : Icon(
                        _editing ? Icons.save : Icons.edit,
                        color: Colors.white,
                      ),
              onPressed:
                  _saving
                      ? null
                      : () async {
                        if (_editing) {
                          final name = _nameController.text.trim();
                          final email = _emailController.text.trim();
                          final password = _passwordController.text.trim();

                          final currentName = await profileController.userName;
                          final currentEmail = profileController.email;

                          final changed =
                              name != currentName || email != currentEmail;

                          if (!changed && password.isEmpty) {
                            setState(() => _editing = false);
                            _toast('لم يتم تعديل أي بيانات');
                            return;
                          }

                          setState(() => _saving = true);

                          await profileController.updateProfile(
                            newName: name,
                            newEmail: email,
                            newPassword: password.isNotEmpty ? password : '',
                            context: context,
                          );

                          setState(() {
                            _saving = false;
                            _editing = false;
                          });

                          _passwordController.clear();

                          _toast('تم الحفظ بنجاح');
                        } else {
                          setState(() => _editing = true);
                        }
                      },
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Directionality(
              textDirection: TextDirection.rtl,
              child: Icon(Icons.arrow_back_ios_new, color: Colors.white),
            ),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
      body: Directionality(
        textDirection: TextDirection.rtl,
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 22),
          child: Column(
            children: [
              const SizedBox(height: 22),
              _infoCard('الاسم', _textOrField(_nameController)),
              _infoCard('البريد الإلكتروني', _textOrField(_emailController)),
              if (_editing)
                _infoCard(
                  'كلمة مرور جديدة',
                  _textOrField(_passwordController, isPassword: true),
                ),
              const SizedBox(height: 24),

              ElevatedButton(
                onPressed: () => _confirmAndLogout(profileController),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.darkPlum,
                  minimumSize: const Size(170, 48),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(22),
                  ),
                ),
                child: const Text(
                  'تسجيل الخروج',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontFamily: 'Jawadtaut',
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}
