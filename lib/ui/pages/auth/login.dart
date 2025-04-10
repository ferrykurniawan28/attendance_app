part of '../pages.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool isSignInMode = true;
  bool _isLoading = false;

  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  void _toggleMode(bool signInMode) {
    setState(() {
      isSignInMode = signInMode;
    });
  }

  Future<void> _handleSubmit() async {
    if (_formKey.currentState?.validate() ?? false) {
      setState(() {
        _isLoading = true;
      });

      try {
        if (isSignInMode) {
          await AuthService.signInWithEmail(
            email: _emailController.text,
            password: _passwordController.text,
          );
          Modular.to.navigate('/home');
        } else {
          final user = await AuthService.signUpWithEmail(
            email: _emailController.text,
            password: _passwordController.text,
          );
          await UserService.createUserProfile(
            userId: user.user!.id,
            name: _nameController.text,
          );
          Modular.to.navigate('/home');
        }
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Attendance App')),
      body: Center(
        child: Card(
          margin: const EdgeInsets.all(16.0),
          elevation: 4.0,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildModeToggle(),
                const SizedBox(height: 16),
                _buildForm(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildModeToggle() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildModeButton('Sign In', isSignInMode, () => _toggleMode(true)),
        const SizedBox(
          height: 50,
          child: VerticalDivider(thickness: 1, width: 1, color: Colors.grey),
        ),
        _buildModeButton('Register', !isSignInMode, () => _toggleMode(false)),
      ],
    );
  }

  Widget _buildModeButton(String text, bool isActive, VoidCallback onPressed) {
    return Expanded(
      child: Container(
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: isActive ? Colors.blue : Colors.grey,
              width: 2.0,
            ),
          ),
        ),
        child: TextButton(onPressed: onPressed, child: Text(text)),
      ),
    );
  }

  Widget _buildForm() {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          if (!isSignInMode) ...[
            _buildTextField(
              controller: _nameController,
              labelText: 'Name',
              validator:
                  (value) =>
                      value == null || value.isEmpty
                          ? 'Please enter your name'
                          : null,
            ),
            const SizedBox(height: 16),
          ],
          _buildTextField(
            controller: _emailController,
            labelText: 'Email',
            validator:
                (value) =>
                    value == null || value.isEmpty
                        ? 'Please enter your email'
                        : null,
          ),
          const SizedBox(height: 16),
          _buildTextField(
            controller: _passwordController,
            labelText: 'Password',
            obscureText: true,
            validator:
                (value) =>
                    value == null || value.isEmpty
                        ? 'Please enter your password'
                        : null,
          ),
          const SizedBox(height: 24),
          _buildSubmitButton(),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String labelText,
    bool obscureText = false,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      decoration: InputDecoration(
        labelText: labelText,
        border: const OutlineInputBorder(),
      ),
      validator: validator,
    );
  }

  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      child:
          _isLoading
              ? const CircularProgressIndicator()
              : DateTime.now().hour < 8 || DateTime.now().hour > 17
              ? const Text(
                'Access is not allowed before 08:00',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.red,
                ),
              )
              : ElevatedButton(
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16.0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  backgroundColor: Colors.blue,
                ),
                onPressed: _handleSubmit,
                child: Text(
                  isSignInMode ? 'Sign In' : 'Register',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
    );
  }
}
