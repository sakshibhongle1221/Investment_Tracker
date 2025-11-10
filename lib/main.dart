import 'main_screen.dart';
import 'package:flutter/material.dart';
import 'login_screen.dart';
import 'signup_screen.dart';
import 'dashboard_screen.dart';
import 'budgets_screen.dart';
import 'goals_screen.dart';
import 'theme.dart';
import 'guest_budget_screen.dart';
import 'guest_goal_screen.dart';
import 'guest_transaction_screen.dart';
import 'guest_dashboard_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  // like for example take this above code , whatever we are writing in the 'class MyApp extends StatelessWidget' Anything that are in the inside of MyApp class like in this case SignUpScreen we didn't care of that whether it is stateless or statefull We just care of whatever MyApp is which in this is stateless// This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'InvestorTrack',
      theme: appTheme, 
    //  ThemeData(
    //    colorScheme: ColorScheme.fromSeed(
    //    seedColor: const Color(0xFF4CAF50), 
    //   brightness: Brightness.light,),
    //    useMaterial3: true,
    //    // Set the background color for the whole app
    //    scaffoldBackgroundColor: const Color//(0xFFF6FBF6), // A very light gray ab mne //made it light green
//
    //   // Define default text styles
    //  textTheme: const TextTheme(
    //  headlineSmall: TextStyle(fontWeight: //FontWeight.bold, fontSize: 30.0),
    //  bodyLarge: TextStyle(fontSize: 16.0),
    //  bodyMedium: TextStyle(fontSize: 14.0, //color: Colors.black),
    //  ),
//
    // // Define Card theme
    // cardTheme: CardThemeData(
   // elevation: 2.0,
   // shape: RoundedRectangleBorder(borderRadius: //BorderRadius.circular(12.0)),
   // margin: const EdgeInsets.symmetric(vertical: //8.0, horizontal: 4.0),
   // ),
   // ),
      debugShowCheckedModeBanner : false,
      //home: const SignupScreen(),
      home: const LoginScreen(),
      routes: {
        '/login': (context) => const LoginScreen(),
        '/signup': (context) => const SignupScreen(),
        '/dashboard':(context) => const MainScreen(),
        '/budgets':(context) => const BudgetsScreen(),
        '/goals':(context) => const GoalsScreen(),
        '/guest_budget': (context) => const GuestBudgetScreen(),
        '/guest_goal': (context) => const GuestGoalScreen(),
        '/guest_transaction': (context) => const GuestTransactionScreen(),
        '/guest_dashboard':(context) => const GuestDashboardScreen(),
      },
    );
  }
}
