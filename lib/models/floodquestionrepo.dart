import '../../models/games_model.dart';
import 'dart:math';

class FloodQuestionsRepository {
  static final List<FloodQuestion> _questions = [
    FloodQuestion(
      question: 'What should you do if you see rising floodwater?',
      options: [
        'Stay calm and move to higher ground',
        'Try to cross it',
        'Wait and see',
        'Drive through it'
      ],
      correctIndex: 0,
    ),
    FloodQuestion(
      question: 'How deep does water need to be to sweep away a car?',
      options: ['1 meter', '30 cm', '60 cm', '2 meters'],
      correctIndex: 2,
    ),
    FloodQuestion(
      question: 'What is the safest place during a flood?',
      options: [
        'Basement',
        'Ground floor',
        'Upper floor or high ground',
        'Near windows'
      ],
      correctIndex: 2,
    ),
    FloodQuestion(
      question: 'Should you walk through moving floodwater?',
      options: [
        'Yes, if it\'s shallow',
        'No, never',
        'Only in daylight',
        'Yes, with boots'
      ],
      correctIndex: 1,
    ),
    FloodQuestion(
      question: 'What items should be in a flood emergency kit?',
      options: [
        'Food and games',
        'Water, food, first aid, flashlight',
        'Just your phone',
        'Money only'
      ],
      correctIndex: 1,
    ),
    FloodQuestion(
      question: 'How much water can knock you off your feet?',
      options: ['50 cm', '15 cm', '1 meter', '5 cm'],
      correctIndex: 1,
    ),
    FloodQuestion(
      question: 'What should you do before a predicted flood?',
      options: [
        'Go shopping',
        'Move valuables to upper floors',
        'Nothing',
        'Open all windows'
      ],
      correctIndex: 1,
    ),
    FloodQuestion(
      question: 'Is it safe to drive through flooded roads?',
      options: [
        'Yes, slowly',
        'No, turn around don\'t drown',
        'Only in 4WD',
        'Yes, if others are doing it'
      ],
      correctIndex: 1,
    ),
    FloodQuestion(
      question: 'When should you evacuate during a flood?',
      options: [
        'When told by authorities',
        'After the rain stops',
        'Never',
        'Only at night'
      ],
      correctIndex: 0,
    ),
    FloodQuestion(
      question: 'What color indicates the highest flood warning?',
      options: ['Yellow', 'Orange', 'Red', 'Blue'],
      correctIndex: 2,
    ),
    FloodQuestion(
      question: 'What does "Turn Around, Don\'t Drown" mean?',
      options: [
        'Avoid swimming',
        'Don\'t drive through flooded roads',
        'Stay indoors',
        'Close windows'
      ],
      correctIndex: 1,
    ),
    FloodQuestion(
      question: 'How long can you survive in cold floodwater?',
      options: ['5 minutes', '30 minutes', '2 hours', '1 day'],
      correctIndex: 1,
    ),
  ];

  FloodQuestion getRandomQuestion() {
    final random = Random();
    return _questions[random.nextInt(_questions.length)];
  }

  List<FloodQuestion> getAllQuestions() {
    return List.unmodifiable(_questions);
  }
}