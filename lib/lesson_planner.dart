// import 'package:flutter/material.dart';

// class LessonPlannerPage extends StatefulWidget {
//   const LessonPlannerPage({super.key});

//   @override
//   _LessonPlannerPageState createState() => _LessonPlannerPageState();
// }

// class _LessonPlannerPageState extends State<LessonPlannerPage> {
//   final _topicController = TextEditingController();
//   String _gradeLevel = 'Elementary School'; // Default grade level
//   String _lessonPlan = ''; // Store generated lesson plan

//   void _generateLessonPlan() {
//     // Replace with your actual lesson plan generation logic
//     setState(() {
//       _lessonPlan = 'Generated Lesson Plan for ${_topicController.text} (Grade: $_gradeLevel)';
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Lesson Planner'),
//         backgroundColor: Colors.black,
//       ),
//       backgroundColor: Colors.black,
//       body: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.stretch,
//           children: <Widget>[
//             TextField(
//               controller: _topicController,
//               decoration: const InputDecoration(labelText: 'Topic'),
//             ),
//             const SizedBox(height: 16),
//             DropdownButtonFormField<String>(
//               value: _gradeLevel,
//               onChanged: (String? newValue) {
//                 setState(() {
//                   _gradeLevel = newValue!;
//                 });
//               },
//               items: <String>['Elementary School', 'Middle School', 'High School']
//                   .map<DropdownMenuItem<String>>((String value) {
//                 return DropdownMenuItem<String>(
//                   value: value,
//                   child: Text(value),
//                 );
//               }).toList(),
//               decoration: const InputDecoration(labelText: 'Grade Level'),
//             ),
//             const SizedBox(height: 20),
//             ElevatedButton(
//               onPressed: _generateLessonPlan,
//               child: const Text('Generate Lesson Plan'),
//             ),
//             const SizedBox(height: 20),
//             Expanded(
//               child: Container(
//                 padding: const EdgeInsets.all(12),
//                 decoration: BoxDecoration(
//                   border: Border.all(color: Colors.grey),
//                   borderRadius: BorderRadius.circular(5),
//                 ),
//                 child: SingleChildScrollView(
//                   child: Text(
//                     _lessonPlan,
//                     style: const TextStyle(color: Colors.white),
//                   ),
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class LessonPlannerPage extends StatefulWidget {
  const LessonPlannerPage({super.key});

  @override
  _LessonPlannerPageState createState() => _LessonPlannerPageState();
}

class _LessonPlannerPageState extends State<LessonPlannerPage> {
  final _topicController = TextEditingController();
  String _gradeLevel = 'Elementary School'; // Default grade level
  String _lessonPlan = ''; // Store generated lesson plan
  bool _isLoading = false; // Track loading state

  Future<void> _generateLessonPlan() async {
    setState(() {
      _isLoading = true;
      _lessonPlan = ''; // Clear previous plan
    });

    final String topic = _topicController.text.trim();

    // Replace with your actual Cloud Function URL
    final Uri apiUrl = Uri.parse('https://lessonplan-generator-803182683214.us-central1.run.app');

    try {
      final response = await http.post(
        apiUrl,
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, String>{
          'topic': topic,
          'gradeLevel': _gradeLevel,
        }),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = jsonDecode(response.body);
        setState(() {
          _lessonPlan = _formatLessonPlan(responseData);
          _isLoading = false;
        });
      } else {
        setState(() {
          _lessonPlan =
              'Error generating lesson plan: ${response.statusCode} - ${response.body}';
          _isLoading = false;
        });
        print('Error: ${response.statusCode} - ${response.body}');
      }
    } catch (error) {
      setState(() {
        _lessonPlan = 'Error connecting to the backend: $error';
        _isLoading = false;
      });
      print('Error: $error');
    }
  }

String _formatLessonPlan(Map<String, dynamic> data) {
  String formattedPlan = '';

  if (data.containsKey('topic')) {
    formattedPlan += 'Topic: ${data['topic']}\n';
  }
  if (data.containsKey('gradeLevel')) {
    formattedPlan += 'Grade Level: ${data['gradeLevel']}\n\n';
  }

  if (data.containsKey('objectives')) {
    formattedPlan += 'Objectives:\n';
    for (var objective in data['objectives']) {
      formattedPlan += '- $objective\n';
    }
    formattedPlan += '\n';
  }

  if (data.containsKey('keyConcepts')) {
    formattedPlan += 'Key Concepts:\n';
    for (var concept in data['keyConcepts']) {
      formattedPlan += '- $concept\n';
    }
    formattedPlan += '\n';
  }

  if (data.containsKey('teachingStrategy')) {
    formattedPlan += 'Teaching Strategy:\n${data['teachingStrategy']}\n\n';
  }

  if (data.containsKey('activities')) {
    formattedPlan += 'Suggested Activities:\n';
    for (var activity in data['activities']) {
      formattedPlan += '- $activity\n';
    }
  }

  return formattedPlan;
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Lesson Planner'),
        backgroundColor: Colors.black,
      ),
      backgroundColor: Colors.black,
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            TextField(
              controller: _topicController,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                labelText: 'Topic',
                labelStyle: TextStyle(color: Colors.grey),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.grey),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.blue),
                ),
              ),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _gradeLevel,
              dropdownColor: Colors.grey[900],
              onChanged: (String? newValue) {
                setState(() {
                  _gradeLevel = newValue!;
                });
              },
              items: <String>['Elementary School', 'Middle School', 'High School']
                  .map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(
                    value,
                    style: const TextStyle(color: Colors.white),
                  ),
                );
              }).toList(),
              decoration: const InputDecoration(
                labelText: 'Grade Level',
                labelStyle: TextStyle(color: Colors.grey),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.grey),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.blue),
                ),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _isLoading ? null : _generateLessonPlan,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromARGB(255, 201, 196, 51),
                foregroundColor: const Color.fromARGB(255, 9, 9, 9),
              ),
              child: _isLoading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : const Text('Generate Lesson Plan'),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  border: Border.all(color: const Color.fromARGB(255, 220, 202, 202)),
                  borderRadius: BorderRadius.circular(5),
                ),
                child: SingleChildScrollView(
                   scrollDirection: Axis.vertical,
                  child: Text(
                    _lessonPlan.isEmpty
                        ? 'Generated lesson plan will appear here.'
                        : _lessonPlan,
                    style: const TextStyle(color: Color.fromARGB(255, 241, 233, 233)),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}