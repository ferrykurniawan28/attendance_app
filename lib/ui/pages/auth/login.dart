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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Attendance App')),
      body: Center(
        child: Card(
          margin: const EdgeInsets.all(16.0),
          elevation: 4.0,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          border: Border(
                            bottom: BorderSide(
                              color: isSignInMode ? Colors.blue : Colors.grey,
                              width: 2.0,
                            ),
                          ),
                        ),
                        child: TextButton(
                          onPressed: () {
                            setState(() {
                              isSignInMode = true;
                            });
                          },
                          child: Text('Sign In'),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 50,
                      child: const VerticalDivider(
                        thickness: 1,
                        width: 1,
                        color: Colors.grey,
                      ),
                    ),
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          border: Border(
                            bottom: BorderSide(
                              color: isSignInMode ? Colors.grey : Colors.blue,
                              width: 2.0,
                            ),
                          ),
                        ),
                        child: TextButton(
                          onPressed: () {
                            setState(() {
                              isSignInMode = false;
                            });
                          },
                          child: Text('Register'),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      if (!isSignInMode)
                        TextFormField(
                          controller: _nameController,
                          decoration: InputDecoration(
                            labelText: 'Name',
                            border: OutlineInputBorder(),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter your name';
                            }
                            return null;
                          },
                        ),
                      if (!isSignInMode) const SizedBox(height: 16),
                      TextFormField(
                        controller: _emailController,
                        decoration: InputDecoration(
                          labelText: 'Email',
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your email';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _passwordController,
                        obscureText: true,
                        decoration: InputDecoration(
                          labelText: 'Password',
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your password';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 24),
                      SizedBox(
                        width: double.infinity,
                        child:
                            (_isLoading)
                                ? CircularProgressIndicator()
                                : ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 16.0,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8.0),
                                    ),
                                    backgroundColor: Colors.blue,
                                  ),
                                  onPressed: () async {
                                    if (_formKey.currentState?.validate() ??
                                        false) {
                                      setState(() {
                                        _isLoading = true;
                                      });
                                      if (isSignInMode) {
                                        await AuthService.signInWithEmail(
                                          email: _emailController.text,
                                          password: _passwordController.text,
                                        ).then((value) {
                                          Modular.to.navigate('/home');
                                        });
                                        // Modular.to.navigate('/home');
                                      } else {
                                        await AuthService.signUpWithEmail(
                                          email: _emailController.text,
                                          password: _passwordController.text,
                                        ).then((value) async {
                                          await UserService.createUserProfile(
                                            userId: value.user!.id,
                                            name: _nameController.text,
                                          ).then((_) {
                                            Modular.to.navigate('/home');
                                          });
                                        });
                                        setState(() {
                                          _isLoading = false;
                                        });
                                      }
                                    }
                                  },
                                  child: Text(
                                    isSignInMode ? 'Sign In' : 'Register',
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
