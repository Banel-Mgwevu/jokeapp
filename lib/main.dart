import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Quotes and Jokes',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        appBarTheme: AppBarTheme(
          elevation: 0, // Optional: To remove shadow
          backgroundColor: Colors.orange, // Change the app bar color
          centerTitle: true,
          toolbarTextStyle: TextStyle(
            fontSize: 24, // Increase the font size
            fontWeight: FontWeight.bold,
            color: Colors.white, // Text color
          ),
        ),),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  List<dynamic> data = [];
  bool isLoading = true;
  late String error;
  late Timer timer;

  Future<void> fetchData() async {
    try {
      final response = await http
          .get(Uri.parse('https://jokes-api-ppbv.onrender.com/random'));
      print(
          'Response status code: ${response.statusCode}'); // Debugging statement
      if (response.statusCode == 200) {
        setState(() {
          data = [json.decode(response.body)];
          isLoading = false;
        });
        startTimer();
      } else {
        throw Exception('Failed to load data');
      }
    } catch (error) {
      print('Error fetching data: $error');
      setState(() {
        //    error = 'Failed to fetch data. Please check your internet connection or API URL.';
        isLoading = false;
      });
    }
  }

  void startTimer() {
    timer = Timer.periodic(Duration(seconds: 10), (timer) {
      fetchData();
    });
  }

  @override
  void initState() {
    super.initState();
    error = ''; // Initializing error here
    fetchData();
  }

  @override
  void dispose() {
    super.dispose();
    timer.cancel(); // Cancel the timer to prevent memory leaks
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Quotes and Jokes  '), // Add emojis or additional text here
              Icon(Icons.emoji_emotions), // Add emojis or icons
            ],
          ),
        ),      body: isLoading
          ? Center(
              child: CircularProgressIndicator(), // Show loading indicator
            )
          : error.isNotEmpty
              ? Center(
                  child: Text(error), // Show error message
                )
              : ListView.builder(
                  itemCount: data.length,
                  itemBuilder: (context, index) {
                    return Center(
                      child: Card(
                        margin: EdgeInsets.all(8.0),
                        child: ListTile(
                          title: Text(data[index]['text'] ?? ''),
                          subtitle: Text(
                              'Author: ${data[index]['author'] ?? "Unknown"}'),
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}
