part of 'pages.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  bool _isEditing = false;
  bool _isLoading = false;
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  File? _imageFile;
  UserModel? _currentUser;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    try {
      final user = await UserService.getCurrentUser();
      if (mounted) {
        setState(() {
          _currentUser = user;
          _nameController.text = user?.name ?? '';
          _emailController.text = user?.email ?? '';
        });
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load user data: $error')),
        );
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _toggleEditing() async {
    if (_isEditing) {
      // Save changes
      setState(() => _isLoading = true);

      try {
        String? imageUrl;
        if (_imageFile != null) {
          final fileName =
              '${DateTime.now().millisecondsSinceEpoch}_${const Uuid().v4()}';
          imageUrl = await StorageService.uploadFile(
            file: _imageFile!,
            bucket: 'profile',
            fileName: fileName,
          );
        }

        await UserService.updateProfile(
          name: _nameController.text,
          photoProfileUrl: imageUrl,
        );

        if (mounted) {
          setState(() {
            _isEditing = false;
            _isLoading = false;
          });
          await _loadUserData(); // Refresh user data
        }
      } catch (error) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error updating profile: $error')),
          );
          setState(() => _isLoading = false);
        }
      }
    } else {
      // Start editing
      setState(() => _isEditing = true);
    }
  }

  Future<void> _pickImage() async {
    try {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 50,
      );

      if (pickedFile != null && mounted) {
        setState(() => _imageFile = File(pickedFile.path));
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to pick image: $error')));
      }
    }
  }

  Future<void> _logout() async {
    setState(() => _isLoading = true);
    try {
      await AuthService.signOut();
      if (mounted) {
        Modular.to.navigate('/auth');
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Logout failed: $error')));
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        actions: [
          if (_isEditing)
            IconButton(
              icon: const Icon(Icons.close),
              onPressed: () => setState(() => _isEditing = false),
            ),
          IconButton(
            icon: Icon(_isEditing ? Icons.check : Icons.edit),
            onPressed: _isLoading ? null : _toggleEditing,
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildProfileImage(),
            const SizedBox(height: 20),
            _buildNameField(),
            const SizedBox(height: 10),
            _buildEmailField(),
            const SizedBox(height: 20),
            _buildLogoutButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileImage() {
    return Stack(
      children: [
        CircleAvatar(
          radius: 50,
          backgroundImage: _getProfileImage(),
          child:
              _getProfileImage() == null
                  ? const Icon(Icons.person, size: 50)
                  : null,
        ),
        if (_isEditing)
          Positioned(
            bottom: 0,
            right: 0,
            child: IconButton(
              icon: const Icon(Icons.camera_alt, color: Colors.blue),
              onPressed: _pickImage,
            ),
          ),
      ],
    );
  }

  ImageProvider? _getProfileImage() {
    if (_imageFile != null) return FileImage(_imageFile!);
    if (_currentUser?.photoProfileUrl != null) {
      return NetworkImage(_currentUser!.photoProfileUrl!);
    }
    return null;
  }

  Widget _buildNameField() {
    return _isEditing
        ? TextField(
          controller: _nameController,
          decoration: const InputDecoration(labelText: 'Name'),
        )
        : Text(
          _currentUser?.name ?? 'Unknown',
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        );
  }

  Widget _buildEmailField() {
    return _isEditing
        ? TextField(
          controller: _emailController,
          decoration: const InputDecoration(labelText: 'Email'),
          enabled: false, // Email typically shouldn't be editable
        )
        : Text(
          _currentUser?.email ?? 'Unknown',
          style: TextStyle(fontSize: 16, color: Colors.grey),
        );
  }

  Widget _buildLogoutButton() {
    return _isLoading
        ? const CircularProgressIndicator()
        : ElevatedButton(onPressed: _logout, child: const Text('Logout'));
  }
}
