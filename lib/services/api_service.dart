import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class ApiService   {
  final String _baseUrl ="https://investortrack-backend.onrender.com";
  final _storage = const FlutterSecureStorage();

  Future<Map<String,dynamic>> registerUser(String email,String password) async {
    try{
      final response = await http.post(
        Uri.parse('$_baseUrl/signup'),
        headers: <String,String>{
          'Content-Type':'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String,String>{
          //'name': name,
          'email':email,
          'password':password,
        }),
      );

      if(response.statusCode == 201){
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed To Register User.Status Code : ${response.statusCode}');
      }
    }
    catch(e){
      throw Exception('Failed To Connect To The Server. Error: $e');
    }
  }

  Future<Map<String,dynamic>> loginUser(String email,String password) async{
    try{
      final response = await http.post(
        Uri.parse('$_baseUrl/login'),
        headers:<String,String>{
          'Content-Type':'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String,String>{
          'email':email,
          'password':password,
        }),
      );
      
      //final data = jsonDecode(response.body);
      final data = response.body.isNotEmpty ? jsonDecode(response.body) : {};
      if(response.statusCode == 200){
        return {
        'token': data['token'],
        'userId': data['userId'],
      };
      } 
      else {
        throw Exception(data['message']??'Failed To Login');
      }
    }
    catch(e){
      throw Exception('Failed To Connect To Server. Error:$e');
    }
  }


  Future<List<dynamic>> getTransactions() async{
    try{
      final token = await _storage.read(key: 'token');
      final userId = await _storage.read(key: 'userId');

      if (token == null) throw Exception('User not logged in. Token not found.');
      if (userId == null) throw Exception('User ID not found.'); 

      final response =await http.get(
        Uri.parse('$_baseUrl/api/transactions/$userId'),
        headers:{
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'Bearer $token',
        },
      );
      if(response.statusCode == 200){
        return jsonDecode(response.body);
      }
      else{
        //final data = jsonDecode(response.body);
        final data = response.body.isNotEmpty ? jsonDecode(response.body) : {};

        throw Exception(data['message']?? 'Failed To Load Transactions.');
      }
    }
    catch(e){
      throw Exception('Failed To Connect To Server. Error:$e');
    }
  }

  Future<Map<String,dynamic>> addTransaction(
    double amount,String type , String category, String description) async{
      try{
        final token = await _storage.read(key: 'token');
        final userId = await _storage.read(key: 'userId');

        if (token == null) throw Exception('User not logged in. Token not found.');

        final response = await http.post(
          Uri.parse('$_baseUrl/api/add-transaction'),
          headers:{
            'Content-Type':'application/json; charset=UTF-8',
            'Authorization':'Bearer $token',
          },
          body: jsonEncode(<String, dynamic>{
            'user_id': userId,
            'amount':amount,
            'type':type,
            'category':category,
            'description':description,
          }),
        );

        if(response.statusCode == 201){
          return jsonDecode(response.body);
        }
        else{
          final data = response.body.isNotEmpty ? jsonDecode(response.body) : {};
          throw Exception(data['message']??'Failed to add transaction.');
        }
      }
      catch(e){
        throw Exception('Failed to connect to the server. Error:$e');
      }
    }


    Future<List<dynamic>> getTransactionSummary() async{
      try{
        final token = await _storage.read(key:'token');
        final userId = await _storage.read(key:'userId');

        if (token == null) throw Exception('User not logged in. Token not found.');
        if(userId== null) throw Exception('user ID not found');

        final response = await http.get(Uri.parse('$_baseUrl/api/summary/$userId'),
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'Bearer $token',
        },
        );
        if(response.statusCode==200){
          return jsonDecode(response.body);
        }
        else{
          //final data = jsonDecode(response.body);
          final data = response.body.isNotEmpty ? jsonDecode(response.body) : {};

      throw Exception(data['message'] ?? 'Failed to load summary.');
        }
      }
      catch(e){
        throw Exception('Failed to connect to the server. Error: $e');
      }
    }


Future<List<dynamic>> getBudgets() async{
  try{
    final token = await _storage.read(key: 'token');
    final userId = await _storage.read(key:'userId');

    if (token == null) throw Exception('User not logged in. Token not found.');
    if(userId== null) throw Exception('user ID not found.');

    final response = await http.get(
      Uri.parse('$_baseUrl/api/budgets/$userId'),
      headers: { 'Authorization': 'Bearer $token'},
    );
    if(response.statusCode == 200){
      return jsonDecode(response.body);
    }
    else{
      throw Exception('Failed to load budgets.');
    }
  }
  catch(e){
    throw Exception('API call failed : $e');
  }
}

Future<Map<String,dynamic>> addBudget(String category, double amount, String month) async{
  try{
    final token = await _storage.read(key: 'token');
    final userId = await _storage.read(key:'userId');

    if (token == null) throw Exception('User not logged in. Token not found.');

    final response = await http.post(
      Uri.parse('$_baseUrl/api/budgets'),
      headers: {
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization':'Bearer $token',
      },
      body: jsonEncode(<String,dynamic>{
        'user_id': userId,
        'category':category,
        'amount': amount,
        'month': month,
      }),
    );

    if(response.statusCode == 201){
      return jsonDecode(response.body);
    }
    else{
      throw Exception('Failed to add budget');
    }
  }
  catch(e){
    throw Exception('API call failed: $e');
  }
}


Future<List<dynamic>> getGoals()  async{
  try{
    final token = await _storage.read(key:'token');
    final userId = await _storage.read(key:'userId');

    if (token == null) throw Exception('User not logged in. Token not found.');
    if(userId == null) throw Exception('User ID not found.');

    final response = await http.get(
      Uri.parse('$_baseUrl/api/goals/$userId'),
      headers:{'Authorization':'Bearer $token'},
    );

    if(response.statusCode == 200){
      return jsonDecode(response.body);
    }
    else{
      throw Exception('Failed to load goals');
    }
  }
  catch(e){
    throw Exception('API call failed: $e');
  }
}

Future<Map<String,dynamic>> addGoal(String title, double targetAmount, String targetDate ) async{
  try{
    final token = await _storage.read(key:'token');
    final userId = await _storage.read(key:'userId');

    if (token == null) throw Exception('User not logged in. Token not found.');


    final response = await http.post(
      Uri.parse('$_baseUrl/api/goals'),
      headers: {
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(<String,dynamic>{
        'user_id':userId,
        'title':title,
        'target_amount': targetAmount,
        'target_date': targetDate,
      }),      
    );

    if(response.statusCode == 201){
      return jsonDecode(response.body);
    }
    else{
      print('Failed to add goal. Server response: ${response.body}');
      throw Exception('Failed to add goal');
    }
  }
  catch(e){
    throw Exception('API call failed: $e');
  }
}


Future<Map<String,dynamic>> getDashboardStats() async{
  try{
    final token = await _storage.read(key:'token');
    final userId = await _storage.read(key:'userId');

    if (token == null) throw Exception('User not logged in. Token not found.');
    if(userId == null) throw Exception('User ID not found.');

    final response = await http.get(Uri.parse('$_baseUrl/api/stats/$userId'),
    headers: {'Authorization':'Bearer $token'},
    );

    if(response.statusCode == 200){
      return jsonDecode(response.body);
    }
    else{
      throw Exception('Failed to load dashboard stats.');
    }
  }
  catch(e){
    throw Exception('Failed to load dashboard stats.');
  }
}


Future<List<dynamic>> getInvestmentPerformance() async{
  try{
    final token= await _storage.read(key: 'token');
    final userId = await _storage.read(key: 'userId');
    if (token == null) throw Exception('User not logged in. Token not found.');
    if(userId == null) throw Exception('User ID not found.');

    final response = await http.get(Uri.parse('$_baseUrl/api/investments/performance/$userId'),
    headers: {'Authorization': 'Bearer $token'},
    );

    if(response.statusCode == 200){
      return jsonDecode(response.body);
    }
    else{
      throw Exception('Failed to load investment data');
    }
  }
  catch(e){
    throw Exception('API call failed: $e');
  }
}

Future<List<dynamic>> getTransactionCategories() async{
  try {
      final token = await _storage.read(key: 'token');
      final userId = await _storage.read(key: 'userId');

      if (token == null) throw Exception('User not logged in. Token not found.');
      if (userId == null) throw Exception('User ID not found.');

      final response = await http.get(
        Uri.parse('$_baseUrl/api/categories/$userId'),
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'Bearer $token',
        },
      );
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((item) => item as String).toList();
      } else {
        final data = response.body.isNotEmpty ? jsonDecode(response.body) : {};
        throw Exception(data['message'] ?? 'Failed to load categories.');
      }
    } catch (e) {
      throw Exception('Failed to connect to server. Error:$e');
    }
}
}