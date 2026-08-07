import 'package:enki/core/common/widgets/loader.dart';
import 'package:enki/core/utils/show_snackbar.dart';
import 'package:enki/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:enki/features/auth/presentation/pages/signup_page.dart';
import 'package:enki/features/auth/presentation/widgets/auth_field.dart';
import 'package:enki/features/auth/presentation/widgets/auth_gradient_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class LoginPage extends StatefulWidget {
  static Route route()=> MaterialPageRoute(builder: (context) =>const SignUpPage());
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => LoginPageState();
}
// create and design how the layout look and function
class LoginPageState extends State<LoginPage> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final formKey = GlobalKey<FormState>();
  
// adding dispose for the controllers to access and edit editor 
  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }



  @override
  Widget build(BuildContext context) {
  
    return Scaffold(
// for controlling the padding in the page you should make padding as parent

      body: Padding(
        padding: const EdgeInsets.all(15.0),
        child: BlocConsumer<AuthBloc, AuthState>(
          listener: (context, state) {
            if(state is AuthFailure){
              showSnackBar(context, state.message);
            }
          },
          builder: (context, state) {
            if(state is AuthLoading){
              return const Loader();
            }
            return Form( 
                key: formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'Sign In.',
                      style: TextStyle(fontSize: 50, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 30),
                    AuthField(hintText: 'Email',controller: emailController),
                    const SizedBox(height: 15),
                    AuthField(hintText: 'Password',controller: passwordController,isObscureText: true,),
                    const SizedBox(height: 20),
                    AuthGradientButton(buttonText: 'Sign In',
                    onPressed: () {
                      if(formKey.currentState!.validate()){
                      context.read<AuthBloc>().add(AuthLogin(email: emailController.text.trim(),password: passwordController.text.trim()));
                      }
                    },),
                    const SizedBox(height: 20),
                    // adding route for the Login
                    GestureDetector(
                    onTap: (){
                      Navigator.push(context, LoginPage.route());
                    },
                    child: RichText(text: TextSpan(
                      text:"Don't have an account? ",
                      style: Theme.of(context).textTheme.titleMedium,
                      children: [
                        TextSpan(
                          text: 'Sign Up',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: Colors.amberAccent,
                            fontWeight: FontWeight.bold,
                          ), 
                          
                        )
                      ]
                    )
                  )
                )
                  ],
                ),
              );
          },
        ),
      ),
    );

  }
}
