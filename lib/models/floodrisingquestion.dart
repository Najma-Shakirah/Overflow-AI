// lib/models/flood_rising_questions.dart
import 'floodrisingmodel.dart';

class FloodRisingQuestions {
  static const List<FloodQuestion> all = [
    // ── LEVEL 1 ───────────────────────────────────────────────────────────
    FloodQuestion(
      id: 'q1',
      level: 1,
      question: 'A flood warning is issued. What should you do FIRST?',
      options: ['Take photos for social media', 'Prepare emergency kit & move valuables up', 'Wait and see if it gets serious', 'Call your friends'],
      correctIndex: 1,
      explanation: 'Prepare immediately — every minute counts when flooding is forecast.',
    ),
    FloodQuestion(
      id: 'q2',
      level: 1,
      question: 'Where should you move important documents during a flood?',
      options: ['Leave them on the table', 'Put them in the car', 'Move them to a high floor', 'Wrap them in plastic downstairs'],
      correctIndex: 2,
      explanation: 'Always move documents (IC, insurance) to the highest floor available.',
    ),
    FloodQuestion(
      id: 'q3',
      level: 1,
      question: 'What should you do to electrical systems before flooding reaches your home?',
      options: ['Leave them on so you have light', 'Turn off at the main switch', 'Unplug only the TV', 'Put sandbags on sockets'],
      correctIndex: 1,
      explanation: 'Floodwater + electricity = electrocution risk. Always cut power at the main switch.',
    ),
    FloodQuestion(
      id: 'q4',
      level: 1,
      question: 'How many days of supplies should an emergency flood kit contain?',
      options: ['Half a day', '1 day', '3 days', '1 week'],
      correctIndex: 2,
      explanation: 'Emergency kits should have at least 3 days of food, water and medicine.',
    ),
    FloodQuestion(
      id: 'q5',
      level: 1,
      question: 'A mandatory evacuation order is issued. You should:',
      options: ['Ignore it if you feel safe', 'Evacuate immediately', 'Wait until water enters your house', 'Only leave if neighbours leave'],
      correctIndex: 1,
      explanation: 'Mandatory evacuations are issued for your safety. Leave immediately — no exceptions.',
    ),

    // ── LEVEL 2 ───────────────────────────────────────────────────────────
    FloodQuestion(
      id: 'q6',
      level: 2,
      question: 'You encounter fast-moving floodwater on a road. You should:',
      options: ['Drive through slowly', 'Wade through on foot', 'Find an alternate route', 'Wait for it to clear'],
      correctIndex: 2,
      explanation: '6 inches of fast water can knock you down. 2 feet sweeps a car. Never cross.',
    ),
    FloodQuestion(
      id: 'q7',
      level: 2,
      question: 'Is it safe to drink floodwater if you boil it first?',
      options: ['Yes, boiling kills all dangers', 'Yes, if it looks clean', 'No, boiling doesn\'t remove chemicals', 'Only if you add salt'],
      correctIndex: 2,
      explanation: 'Floodwater has sewage AND chemicals. Boiling kills bacteria but not toxic chemicals.',
    ),
    FloodQuestion(
      id: 'q8',
      level: 2,
      question: 'What colour clothing helps rescuers spot you from a helicopter?',
      options: ['Dark blue or black', 'Camouflage green', 'Bright orange or yellow', 'White'],
      correctIndex: 2,
      explanation: 'Bright, high-contrast colours are visible from aircraft. Always pack bright gear.',
    ),
    FloodQuestion(
      id: 'q9',
      level: 2,
      question: 'A rescue boat is at capacity. What should you do?',
      options: ['Jump on anyway', 'Prioritise children & injured first', 'Demand everyone makes room', 'Swim behind the boat'],
      correctIndex: 1,
      explanation: 'Overloading boats capsizes them and kills everyone. Prioritise vulnerable people.',
    ),
    FloodQuestion(
      id: 'q10',
      level: 2,
      question: 'You find a person with a bleeding wound during flood evacuation. First step?',
      options: ['Leave them to find help', 'Apply firm pressure to the wound', 'Pour floodwater to clean it', 'Give them all your medicine'],
      correctIndex: 1,
      explanation: 'Direct firm pressure on wounds is the #1 first aid action to stop bleeding.',
    ),

    // ── LEVEL 3 ───────────────────────────────────────────────────────────
    FloodQuestion(
      id: 'q11',
      level: 3,
      question: 'You\'re trapped on a rooftop. Best way to signal a helicopter?',
      options: ['Shout as loud as possible', 'Flash a mirror at the helicopter', 'Wave your dark jacket', 'Stay still so they see you'],
      correctIndex: 1,
      explanation: 'Mirror flashes are visible for miles and are the most effective rooftop signal.',
    ),
    FloodQuestion(
      id: 'q12',
      level: 3,
      question: 'At night, stranded in floodwater — what helps most against hypothermia?',
      options: ['Swim to keep warm', 'Huddle with others & block the wind', 'Eat all food at once', 'Remove wet clothes and leave them off'],
      correctIndex: 1,
      explanation: 'Shared body heat + windbreaks dramatically slow heat loss in cold conditions.',
    ),
    FloodQuestion(
      id: 'q13',
      level: 3,
      question: 'Someone in your group is panicking uncontrollably. Best approach?',
      options: ['Shout at them to focus', 'Leave them and continue', 'Give calm breathing instructions and small tasks', 'Ignore them completely'],
      correctIndex: 2,
      explanation: 'Controlled breathing and small tasks redirect panicking people\'s energy productively.',
    ),
    FloodQuestion(
      id: 'q14',
      level: 3,
      question: 'What is leptospirosis and how is it related to floods?',
      options: ['A type of flood barrier', 'A bacteria spread through floodwater contact', 'A weather phenomenon causing floods', 'A rescue technique'],
      correctIndex: 1,
      explanation: 'Leptospirosis is a deadly bacteria in floodwater. Avoid skin contact with floodwater.',
    ),
    FloodQuestion(
      id: 'q15',
      level: 3,
      question: 'After a flood, when is it safe to return home?',
      options: ['As soon as water clears', 'Only after authorities declare it safe', 'After 24 hours regardless', 'Whenever you feel ready'],
      correctIndex: 1,
      explanation: 'Structural damage, gas leaks & contamination make homes dangerous until officially cleared.',
    ),
  ];

  static List<FloodQuestion> forLevel(int level) =>
      all.where((q) => q.level == level).toList();

  static List<FloodQuestion> allShuffled() {
    final list = List<FloodQuestion>.from(all);
    list.shuffle();
    return list;
  }
}