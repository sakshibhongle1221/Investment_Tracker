import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'services/api_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}
class _LoginScreenState extends State<LoginScreen>{

  final ApiService _apiService = ApiService();
  final _storage = const FlutterSecureStorage();

  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold( 
      appBar: AppBar(
        title: const Text('InvestmentTracking Login'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: emailController,
              decoration: const InputDecoration(labelText: 'Email'),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: passwordController,
              obscureText: true,
              decoration: const InputDecoration(labelText: 'Password'),
            ),
            const SizedBox(height: 24),
            
            ElevatedButton(
              onPressed: () async {

                final String email = emailController.text.trim();
                final String password = passwordController.text;
                
                if(email.isEmpty || password.isEmpty){
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Please Fill All Fields")),
                  );
                  return;
                }
                try{
                  
                  final responseData = await _apiService.loginUser(email, password);
   
                  final String token = responseData['token'];
                  final String userId = responseData['userId'].toString(); 

                  await _storage.write(key: 'token', value: token);
                  await _storage.write(key: 'userId', value: userId);

                  final testToken = await _storage.read(key: 'token');
                  final testId = await _storage.read(key: 'userId');
                  print("Saved token: $testToken, Saved userId: $testId");


                  if(mounted){
                    Navigator.pushReplacementNamed(context,'/dashboard');
                  }
                }
                catch(e){
                  if(mounted){
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Failed To Login:$e')),
                    );
                  }
                }
              },
              child: const Text("Login",
                   style: TextStyle(fontWeight: FontWeight.bold),
            ),
            ),
            const SizedBox(height: 16),
            TextButton(
              onPressed:(){
                    Navigator.pushNamed(context, '/signup');
              },
              child:
               Column(
                children:[
                  Text("Don't have an account ?"),
                  Text("Sign up",
                   style: TextStyle(fontWeight: FontWeight.bold), 
              ),
              ],
              ),                 
            ),

            const SizedBox(height: 16), 
            ElevatedButton(
              onPressed: () {
                
                Navigator.pushReplacementNamed(context, '/guest_dashboard');
              },
              child: const Column(
                children: [
                  Text("Or"),
                  Text(
                    "Continue as Guest",
                    style: TextStyle(fontWeight: FontWeight.bold,fontSize:22),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
