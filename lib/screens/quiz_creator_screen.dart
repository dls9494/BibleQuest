import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';
import '../models/quiz.dart';
import '../services/firebase_service.dart';
import 'self_paced_screen.dart'; // for preview
import '../widgets/gradient_background.dart';

class QuizCreatorScreen extends StatefulWidget {
  final Quiz? existingQuiz; // if editing
  const QuizCreatorScreen({super.key, this.existingQuiz});
  @override
  State<QuizCreatorScreen> createState() => _QuizCreatorScreenState();
}

class _QuizCreatorScreenState extends State<QuizCreatorScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleEn = TextEditingController();
  final _titleTe = TextEditingController();
  final _descEn = TextEditingController();
  final _descTe = TextEditingController();
  final _bibleVersion = TextEditingController(text: 'BSI Telugu');
  final List<Map<String, dynamic>> _questions = [];
  int _currentStep = 0;

  @override
  void initState() {
    super.initState();
    if (widget.existingQuiz != null) {
      final q = widget.existingQuiz!;
      _titleEn.text = q.titleEn;
      _titleTe.text = q.titleTe;
      _descEn.text = q.descriptionEn;
      _descTe.text = q.descriptionTe;
      _bibleVersion.text = q.bibleVersion;
      // Load existing questions (simplified - would need to fetch)
    }
  }

  void _addQuestion(String type) {
    Map<String, dynamic> newQ = {
      'type': type,
      'questionEn': TextEditingController(),
      'questionTe': TextEditingController(),
      'options': <Map<String, dynamic>>[],
      'correctAnswerEn': TextEditingController(),
      'correctAnswerTe': TextEditingController(),
    };
    if (type == 'multiple_choice') {
      for (int i = 0; i < 4; i++) {
        newQ['options'].add({
          'textEn': TextEditingController(),
          'textTe': TextEditingController(),
          'isCorrect': i == 0, // default first correct
        });
      }
    } else if (type == 'true_false') {
      newQ['correctAnswerEn'].text = 'True';
      newQ['correctAnswerTe'].text = 'నిజం';
    } else if (type == 'type_answer') {
      // correctAnswerEn/Te are used
    }
    setState(() => _questions.add(newQ));
  }

  Future<void> _previewQuiz() async {
    final previewQuiz = Quiz(
      id: 'preview', creatorId: 'preview', titleKey: 'preview',
      bibleVersion: _bibleVersion.text,
      topics: const [], isPublic: false, questionCount: _questions.length,
      createdAt: DateTime.now(), updatedAt: DateTime.now(),
      titleEn: _titleEn.text, titleTe: _titleTe.text,
      descriptionEn: _descEn.text, descriptionTe: _descTe.text,
      level: 1,
      difficulty: 'easy',
    );
    
    // Build temporary questions
    List<Question> questions = [];
    for (int i = 0; i < _questions.length; i++) {
      final q = _questions[i];
      List<Option> options = [];
      if (q['type'] == 'multiple_choice') {
        for (var opt in q['options']) {
          options.add(Option(
            id: 'preview_opt_${i}_${opt['textEn'].text}',
            order: q['options'].indexOf(opt),
            isCorrect: opt['isCorrect'],
            textEn: opt['textEn'].text,
            textTe: opt['textTe'].text,
          ));
        }
      }
      questions.add(Question(
        id: 'preview_q$i', order: i+1, type: q['type'],
        timeLimitSeconds: 20, points: 1000,
        questionEn: q['questionEn'].text, questionTe: q['questionTe'].text,
        options: options,
        correctAnswerEn: q['correctAnswerEn']?.text,
        correctAnswerTe: q['correctAnswerTe']?.text,
      ));
    }
    Navigator.push(context, MaterialPageRoute(builder: (_) => PreviewScreen(quiz: previewQuiz, questions: questions)));
  }

  Map<String, dynamic> _buildQuizData() {
    return {
      'title_en': _titleEn.text,
      'title_te': _titleTe.text,
      'desc_en': _descEn.text,
      'desc_te': _descTe.text,
      'bible_version': _bibleVersion.text,
      'questions': _questions.map((q) => {
        'type': q['type'],
        'questionEn': q['questionEn'].text,
        'questionTe': q['questionTe'].text,
        'options': q['options'].map((o) => {
          'textEn': o['textEn'].text,
          'textTe': o['textTe'].text,
          'isCorrect': o['isCorrect'],
        }).toList(),
        'correctAnswerEn': q['correctAnswerEn']?.text,
        'correctAnswerTe': q['correctAnswerTe']?.text,
      }).toList(),
    };
  }

  void _saveQuiz() async {
    if (!_formKey.currentState!.validate()) return;
    await FirebaseService.saveQuiz(_buildQuizData());
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Quiz saved!')));
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    return Theme(
      data: ThemeData.dark().copyWith(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFFE21B3C),
          brightness: Brightness.dark,
        ),
        scaffoldBackgroundColor: const Color(0xFF1A1A2E),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.transparent,
          elevation: 0,
          titleTextStyle: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
            fontFamily: 'Outfit',
          ),
        ),
      ),
      child: Scaffold(
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          title: Text(widget.existingQuiz != null ? 'Edit Quiz' : loc.createQuiz),
          leading: IconButton(
            icon: const Text('✝', style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
            onPressed: () => Navigator.pop(context),
          ),
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
        body: Stack(
          children: [
            Positioned.fill(
              child: const GradientBackground(child: SizedBox.shrink()),
            ),
            SafeArea(
              child: Form(
              key: _formKey,
        child: Stepper(
          currentStep: _currentStep,
          onStepContinue: () {
            if (_currentStep < 2) {
              setState(() => _currentStep++);
            }
          },
          onStepCancel: () {
            if (_currentStep > 0) {
              setState(() => _currentStep--);
            }
          },
          steps: [
            Step(
              title: const Text('Quiz Details'),
              content: Column(children: [
                TextFormField(controller: _titleEn, decoration: const InputDecoration(labelText: 'Title (English)'), validator: (v) => v!.isEmpty ? 'Required' : null),
                TextFormField(controller: _titleTe, decoration: const InputDecoration(labelText: 'Title (Telugu)')),
                TextFormField(controller: _descEn, decoration: const InputDecoration(labelText: 'Description (English)')),
                TextFormField(controller: _descTe, decoration: const InputDecoration(labelText: 'Description (Telugu)')),
                TextFormField(controller: _bibleVersion, decoration: const InputDecoration(labelText: 'Bible Version')),
              ]),
            ),
            Step(
              title: const Text('Questions'),
              content: Column(children: [
                ..._questions.asMap().entries.map((entry) {
                  int i = entry.key;
                  var q = entry.value;
                  return Card(
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Text('Question ${i+1} (${q['type']})', style: const TextStyle(fontWeight: FontWeight.bold)),
                        TextFormField(controller: q['questionEn'], decoration: const InputDecoration(labelText: 'Question (English)')),
                        TextFormField(controller: q['questionTe'], decoration: const InputDecoration(labelText: 'Question (Telugu)')),
                        if (q['type'] == 'multiple_choice')
                          ...List.generate(4, (j) => Row(children: [
                            Expanded(child: TextFormField(controller: q['options'][j]['textEn'], decoration: InputDecoration(labelText: 'Option ${j+1} EN'))),
                            const SizedBox(width:8),
                            Expanded(child: TextFormField(controller: q['options'][j]['textTe'], decoration: InputDecoration(labelText: 'Option ${j+1} TE'))),
                            Checkbox(value: q['options'][j]['isCorrect'], onChanged: (v) => setState(() => q['options'][j]['isCorrect'] = v)),
                          ])),
                        if (q['type'] == 'true_false')
                          DropdownButtonFormField<String>(
                            initialValue: q['correctAnswerEn']?.text ?? 'True',
                            items: const ['True','False'].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
                            onChanged: (v) {
                              setState(() {
                                q['correctAnswerEn']?.text = v;
                                q['correctAnswerTe']?.text = (v == 'True' ? 'నిజం' : 'తప్పు');
                              });
                            },
                          ),
                        if (q['type'] == 'type_answer') ...[
                          TextFormField(controller: q['correctAnswerEn'], decoration: const InputDecoration(labelText: 'Correct Answer (English)')),
                          TextFormField(controller: q['correctAnswerTe'], decoration: const InputDecoration(labelText: 'Correct Answer (Telugu)')),
                        ],
                      ]),
                    ),
                  );
                }),
                const SizedBox(height: 12),
                Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
                  ElevatedButton(onPressed: () => _addQuestion('multiple_choice'), child: const Text('MCQ')),
                  ElevatedButton(onPressed: () => _addQuestion('true_false'), child: const Text('True/False')),
                  ElevatedButton(onPressed: () => _addQuestion('type_answer'), child: const Text('Type Answer')),
                ]),
              ]),
            ),
            Step(
              title: const Text('Preview & Save'),
              content: Column(children: [
                ElevatedButton(onPressed: _previewQuiz, child: const Text('Preview Quiz')),
                const SizedBox(height: 16),
                ElevatedButton(onPressed: _saveQuiz, child: Text(loc.save)),
              ]),
            ),
          ],
              ),
            ),
          ),
        ],
      ),
    ),
  );
  }
}

// A simple preview screen that cycles through questions
class PreviewScreen extends StatelessWidget {
  final Quiz quiz;
  final List<Question> questions;
  const PreviewScreen({super.key, required this.quiz, required this.questions});
  @override
  Widget build(BuildContext context) {
    return SelfPacedScreen(quiz: quiz, questions: questions);
  }
}
