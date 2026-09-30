import 'dart:convert';
import 'dart:typed_data';
import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';
import 'package:image/image.dart' as img;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/network/http_client.dart';
import '../../../../shared/theme/app_theme.dart';
import '../../../../shared/widgets/calotex_sidebar.dart';
import '../../../../shared/widgets/calotex_top_bar.dart';
import '../../domain/entities/user_entity.dart';
import '../bloc/auth_bloc.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final _nameController = TextEditingController();
  String? _avatar;
  Uint8List? _avatarBytes;
  String? _originalName;
  String? _originalAvatar;
  bool _saving = false;
  String? _error;

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      withData: true,
    );
    final bytes = result?.files.single.bytes;
    if (bytes == null) return;
    final decoded = img.decodeImage(bytes);
    if (decoded == null) {
      setState(() => _error = 'The selected image could not be read.');
      return;
    }

    final resized = decoded.width > 512 || decoded.height > 512
        ? img.copyResize(
            decoded,
            width: decoded.width >= decoded.height ? 512 : null,
            height: decoded.height > decoded.width ? 512 : null,
          )
        : decoded;
    final compressed = Uint8List.fromList(img.encodeJpg(resized, quality: 78));
    setState(() {
      _avatarBytes = compressed;
      _avatar = 'data:image/jpeg;base64,${base64Encode(compressed)}';
      _error = null;
    });
  }

  Future<void> _save() async {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      setState(() => _error = 'Enter your name.');
      return;
    }
    setState(() {
      _saving = true;
      _error = null;
    });
    try {
      final form = FormData.fromMap({
        'name': name,
        if (_avatarBytes != null)
          'avatar': MultipartFile.fromBytes(_avatarBytes!, filename: 'avatar.jpg'),
        if (_avatarBytes == null) 'avatar': _avatar,
      });
      final response = await sl<HttpClient>().dio.patch('/profile', data: form);
      if (mounted) {
        final rawData = response.data is Map ? response.data['data'] : null;
        if (rawData is! Map) {
          throw const FormatException('Invalid profile response');
        }
        final data = Map<String, dynamic>.from(rawData);
        final current = context.read<AuthBloc>().state;
        if (current is Authenticated) {
          final createdAtText = data['created_at']?.toString();
          final createdAt = createdAtText == null
              ? current.user.createdAt
              : DateTime.tryParse(createdAtText) ?? current.user.createdAt;
          context.read<AuthBloc>().add(ProfileUpdated(UserEntity(
                id: '${data['id']}',
                email: '${data['email'] ?? current.user.email}',
                firstName: '${data['name'] ?? name}',
                lastName: '',
                avatar: data['avatar']?.toString(),
                role: '${data['role'] ?? current.user.role}',
                createdAt: createdAt,
              )));
        }
        _originalName = name;
        _originalAvatar = _avatar;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile updated successfully')),
        );
        if (mounted) {
          Navigator.pop(context);
        }
      }
    } on DioException catch (error) {
      setState(() => _error =
          (error.response?.data is Map ? error.response?.data['message'] : null)
                  ?.toString() ??
              'Could not update profile');
    } catch (error) {
      if (mounted) {
        setState(() => _error = 'Could not update profile: $error');
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthBloc>().state;
    final user = auth is Authenticated ? auth.user : null;
    if (user != null && _nameController.text.isEmpty) {
      _nameController.text = user.fullName;
      _avatar ??= user.avatar;
      _originalName ??= user.fullName;
      _originalAvatar ??= user.avatar;
    }
    return Scaffold(
      backgroundColor: AppTheme.bgPrimary,
      body: Row(
        children: [
          CalotexSidebar(
            activeRoute: '/profile',
            userRole: user?.role ?? '',
            onNavItemTap: (route) {
              if (route == '/logout') {
                context.read<AuthBloc>().add(const LogoutRequested());
                Navigator.pushReplacementNamed(context, '/login');
              } else if (route != '/profile') {
                Navigator.pushReplacementNamed(context, route);
              }
            },
          ),
          Expanded(
            child: Column(
              children: [
                CalotexTopBar(
                  userName: user?.fullName ?? 'User',
                  userRole: user?.role ?? '',
                ),
                Expanded(
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 560),
                      child: Container(
                        padding: const EdgeInsets.all(28),
                        decoration: AppTheme.cardDecoration(),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            _avatarWidget(user),
                            const SizedBox(height: 12),
                            OutlinedButton.icon(
                              onPressed: _pickImage,
                              icon: const Icon(Icons.photo_camera_outlined),
                              label: const Text('Choose profile picture'),
                            ),
                            const SizedBox(height: 24),
                            TextField(
                              controller: _nameController,
                              style: const TextStyle(color: AppTheme.textPrimary),
                              decoration: AppTheme.inputDecoration(hint: 'Full name'),
                            ),
                            const SizedBox(height: 16),
                            if (_error != null)
                              Text(_error!, style: const TextStyle(color: AppTheme.accentRed)),
                            const SizedBox(height: 8),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                OutlinedButton(
                                  onPressed: _saving
                                      ? null
                                      : () {
                                          setState(() {
                                            _nameController.text =
                                                _originalName ?? '';
                                            _avatar = _originalAvatar;
                                            _error = null;
                                          });
                                          Navigator.pop(context);
                                        },
                                  child: const Text('Cancel'),
                                ),
                                const SizedBox(width: 12),
                                FilledButton.icon(
                                  onPressed: _saving ? null : _save,
                                  icon: const Icon(Icons.save_outlined),
                                  label: const Text('Save profile'),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _avatarWidget(dynamic user) {
    final image = _avatar ?? user?.avatar;
    return CircleAvatar(
      radius: 54,
      backgroundColor: AppTheme.bgElevated,
      backgroundImage: image != null ? NetworkImage(image) : null,
      child: image == null
          ? Text(
              _nameController.text.isEmpty
                  ? 'U'
                  : _nameController.text[0].toUpperCase(),
              style: const TextStyle(fontSize: 36, color: AppTheme.textPrimary),
            )
          : null,
    );
  }
}
