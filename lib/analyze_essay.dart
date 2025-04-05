import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class AnalyzeEssayPage extends StatefulWidget {
  const AnalyzeEssayPage({super.key});

  @override
  _AnalyzeEssayPageState createState() => _AnalyzeEssayPageState();
}

class _AnalyzeEssayPageState extends State<AnalyzeEssayPage> {
  final TextEditingController _essayController = TextEditingController();
  String _overallScore = '';
  Map<String, String> _feedback = {};
  bool _isAnalyzing = false;
  String _errorMessage = '';

  Future<void> _analyzeEssay() async {
    setState(() {
      _isAnalyzing = true;
      _overallScore = '';
      _feedback.clear();
      _errorMessage = '';
    });

    final String essayText = _essayController.text.trim();
    if (essayText.isEmpty) {
      setState(() {
        _isAnalyzing = false;
        _errorMessage = 'Please enter the student essay.';
      });
      return;
    }

    // Replace with your actual Cloud Function URL
    final Uri apiUrl = Uri.parse('https://analyze-essay-803182683214.us-central1.run.app');

    try {
      final response = await http.post(
        apiUrl,
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, String>{
          'essay': essayText,
        }),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = jsonDecode(response.body);
        setState(() {
          _overallScore = responseData['overallScore'] ?? 'N/A';
          _feedback = (responseData['feedback'] as Map<String, dynamic>).cast<String, String>() ?? {};
          _isAnalyzing = false;
        });
      } else {
        setState(() {
          _overallScore = 'Error';
          _feedback = {'Error': 'Failed to analyze essay: ${response.statusCode} - ${response.body}'};
          _isAnalyzing = false;
        });
        print('Error analyzing essay: ${response.statusCode} - ${response.body}');
      }
    } catch (error) {
      setState(() {
        _overallScore = 'Error';
        _feedback = {'Error': 'Error connecting to backend: $error'};
        _isAnalyzing = false;
      });
      print('Error connecting to backend: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Essay Feedback'),
        backgroundColor: Colors.black,
      ),
      backgroundColor: Colors.black,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            TextField(
              controller: _essayController,
              maxLines: 10,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                labelText: 'Student Essay',
                labelStyle: TextStyle(color: Colors.grey),
                border: OutlineInputBorder(borderSide: BorderSide(color: Colors.grey)),
                focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.blue)),
                enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.grey)),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _isAnalyzing ? null : _analyzeEssay,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromARGB(255, 201, 196, 51),
                foregroundColor: const Color.fromARGB(255, 9, 9, 9),
              ),
              child: _isAnalyzing
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : const Text('Analyze Essay'),
            ),
            const SizedBox(height: 20),
            if (_errorMessage.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(bottom: 10.0),
                child: Text(
                  _errorMessage,
                  style: const TextStyle(color: Colors.red),
                ),
              ),
            Text(
              'Overall Score: $_overallScore',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
            ),
            const SizedBox(height: 10),
            Text(
              'Feedback:',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
            ),
            if (_feedback.isNotEmpty)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: _feedback.entries.map((entry) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4.0),
                      child: Text(
                        '${entry.key}: ${entry.value}',
                        style: const TextStyle(color: Colors.white),
                      ),
                    ))
                    .toList(),
              )
            else if (!_isAnalyzing && _overallScore.isNotEmpty && _feedback.isEmpty && _errorMessage.isEmpty)
              const Text(
                'No feedback received.',
                style: TextStyle(color: Colors.white),
              ),
          ],
        ),
      ),
    );
  }
}