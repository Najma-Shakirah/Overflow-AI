// models/scenario_repository.dart
import 'survivalgamemodel.dart';

class ScenarioRepository {
  static const List<GameLevel> levels = [
    GameLevel(
      levelNumber: 1,
      title: 'The Warning',
      description: 'Heavy rain has been forecast. Prepare before the flood hits.',
      setting: 'Your Home',
      scenarioIds: ['l1_s1', 'l1_s2', 'l1_s3', 'l1_s4'],
      pointsToUnlock: 0,
    ),
    GameLevel(
      levelNumber: 2,
      title: 'Rising Waters',
      description: 'Water is rising fast. Make critical escape decisions.',
      setting: 'Flooded Streets',
      scenarioIds: ['l2_s1', 'l2_s2', 'l2_s3', 'l2_s4'],
      pointsToUnlock: 150,
    ),
    GameLevel(
      levelNumber: 3,
      title: 'Survival Mode',
      description: 'Stranded. Every decision could be your last.',
      setting: 'Rooftop & Rescue',
      scenarioIds: ['l3_s1', 'l3_s2', 'l3_s3', 'l3_s4'],
      pointsToUnlock: 300,
    ),
  ];

  static const List<Scenario> scenarios = [
    // ── LEVEL 1: The Warning ──────────────────────────────────────────────

    Scenario(
      id: 'l1_s1',
      level: 1,
      title: 'Flood Alert Received',
      description:
          'Your phone buzzes. A flood warning has been issued for your area. '
          'Water levels are expected to rise within 6 hours. What do you do first?',
      imageEmoji: '📱',
      backgroundType: 'rain',
      educationalTip:
          'When a flood alert is issued, act immediately. Every minute counts.',
      choices: [
        Choice(
          text: 'Ignore it, floods never reach my area',
          icon: '😴',
          isCorrect: false,
          effect: ChoiceEffect(
            healthDelta: -5,
            suppliesDelta: -10,
            moraleDelta: -15,
            timeDelta: -20,
            feedbackText:
                'Dangerous! Ignoring official warnings costs precious preparation time.',
          ),
        ),
        Choice(
          text: 'Gather emergency kit: water, food, medicine',
          icon: '🎒',
          isCorrect: true,
          effect: ChoiceEffect(
            healthDelta: 5,
            suppliesDelta: 25,
            moraleDelta: 10,
            timeDelta: -5,
            feedbackText:
                'Great! An emergency kit with 3 days of supplies is the #1 recommended action.',
          ),
        ),
        Choice(
          text: 'Call family and warn them',
          icon: '📞',
          isCorrect: true,
          effect: ChoiceEffect(
            healthDelta: 0,
            suppliesDelta: 5,
            moraleDelta: 20,
            timeDelta: -8,
            feedbackText:
                'Good thinking! Coordinating with family improves everyone\'s survival chances.',
          ),
        ),
        Choice(
          text: 'Post about it on social media',
          icon: '📸',
          isCorrect: false,
          effect: ChoiceEffect(
            healthDelta: -5,
            suppliesDelta: -5,
            moraleDelta: 5,
            timeDelta: -15,
            feedbackText:
                'You wasted time! Use alerts to act, not to post. Preparation is urgent.',
          ),
        ),
      ],
    ),

    Scenario(
      id: 'l1_s2',
      level: 1,
      title: 'Prepare Your Home',
      description:
          'Rain is getting heavier. Water is starting to pool outside. '
          'You have 30 minutes to prepare your house. What is most important?',
      imageEmoji: '🏠',
      backgroundType: 'rain',
      educationalTip:
          'Move valuables and important documents to higher floors before evacuating.',
      choices: [
        Choice(
          text: 'Move electrical items & documents upstairs',
          icon: '📄',
          isCorrect: true,
          effect: ChoiceEffect(
            healthDelta: 0,
            suppliesDelta: 15,
            moraleDelta: 15,
            timeDelta: -8,
            feedbackText:
                'Smart! Protecting documents (IC, insurance) and electronics saves huge losses.',
          ),
        ),
        Choice(
          text: 'Sandbag the doors and ground floor',
          icon: '🧱',
          isCorrect: true,
          effect: ChoiceEffect(
            healthDelta: 5,
            suppliesDelta: 10,
            moraleDelta: 10,
            timeDelta: -10,
            feedbackText:
                'Good! Sandbags can reduce flood damage significantly if placed correctly.',
          ),
        ),
        Choice(
          text: 'Pack only clothes and leave quickly',
          icon: '👔',
          isCorrect: false,
          effect: ChoiceEffect(
            healthDelta: -5,
            suppliesDelta: -15,
            moraleDelta: -5,
            timeDelta: 5,
            feedbackText:
                'You left without medicine or food. Important items lost to the flood.',
          ),
        ),
        Choice(
          text: 'Turn off electricity at the main switch',
          icon: '⚡',
          isCorrect: true,
          effect: ChoiceEffect(
            healthDelta: 15,
            suppliesDelta: 0,
            moraleDelta: 5,
            timeDelta: -5,
            feedbackText:
                'Critical safety step! Floodwater + electricity = electrocution risk.',
          ),
        ),
      ],
    ),

    Scenario(
      id: 'l1_s3',
      level: 1,
      title: 'Evacuation Order',
      description:
          'Authorities announce mandatory evacuation. A neighbour offers you a ride. '
          'Your elderly neighbour across the street seems to be still home. What do you do?',
      imageEmoji: '🚨',
      backgroundType: 'rain',
      educationalTip:
          'Check on vulnerable neighbours during evacuations — elderly and disabled people need extra help.',
      choices: [
        Choice(
          text: 'Leave immediately, protect yourself first',
          icon: '🚗',
          isCorrect: false,
          effect: ChoiceEffect(
            healthDelta: 5,
            suppliesDelta: 5,
            moraleDelta: -20,
            timeDelta: 10,
            feedbackText:
                'You\'re physically safe but left a vulnerable neighbour behind. Community matters.',
          ),
        ),
        Choice(
          text: 'Quickly check on the elderly neighbour first',
          icon: '🧓',
          isCorrect: true,
          effect: ChoiceEffect(
            healthDelta: 0,
            suppliesDelta: 0,
            moraleDelta: 25,
            timeDelta: -15,
            feedbackText:
                'You helped save a life! Elderly and disabled are at highest risk in floods.',
          ),
        ),
        Choice(
          text: 'Call emergency services to check on them',
          icon: '🆘',
          isCorrect: true,
          effect: ChoiceEffect(
            healthDelta: 0,
            suppliesDelta: 0,
            moraleDelta: 15,
            timeDelta: -5,
            feedbackText:
                'Good balance! Alerting authorities ensures they get professional help.',
          ),
        ),
        Choice(
          text: 'Assume they\'ve already left',
          icon: '🤷',
          isCorrect: false,
          effect: ChoiceEffect(
            healthDelta: 0,
            suppliesDelta: 5,
            moraleDelta: -15,
            timeDelta: 5,
            feedbackText:
                'Never assume. Always verify vulnerable neighbours are safe if possible.',
          ),
        ),
      ],
    ),

    Scenario(
      id: 'l1_s4',
      level: 1,
      title: 'Evacuation Route',
      description:
          'You\'re in the car. The GPS shows two routes: the highway (faster but low-lying) '
          'or the mountain road (slower but higher ground). Water is rising.',
      imageEmoji: '🗺️',
      backgroundType: 'flood',
      educationalTip:
          'Always take higher ground routes during floods, even if they take longer.',
      choices: [
        Choice(
          text: 'Take the highway — it\'s faster',
          icon: '🛣️',
          isCorrect: false,
          effect: ChoiceEffect(
            healthDelta: -25,
            suppliesDelta: -10,
            moraleDelta: -20,
            timeDelta: -10,
            feedbackText:
                'The highway flooded! Fast-moving shallow water can sweep away vehicles. Never drive through floods.',
          ),
        ),
        Choice(
          text: 'Take the mountain road — higher ground',
          icon: '⛰️',
          isCorrect: true,
          effect: ChoiceEffect(
            healthDelta: 10,
            suppliesDelta: 5,
            moraleDelta: 15,
            timeDelta: -10,
            feedbackText:
                'Correct! Higher ground is always safer. Time lost is worth the safety gained.',
          ),
        ),
        Choice(
          text: 'Wait in the car and see which clears first',
          icon: '⏳',
          isCorrect: false,
          effect: ChoiceEffect(
            healthDelta: -15,
            suppliesDelta: -10,
            moraleDelta: -10,
            timeDelta: -20,
            feedbackText:
                'Waiting in a low-lying area is dangerous. Water rose around your car.',
          ),
        ),
        Choice(
          text: 'Turn back home — it\'s too risky to drive',
          icon: '🔙',
          isCorrect: false,
          effect: ChoiceEffect(
            healthDelta: -10,
            suppliesDelta: 0,
            moraleDelta: -5,
            timeDelta: -15,
            feedbackText:
                'Your home is now flooded. Once evacuation is ordered, do not turn back.',
          ),
        ),
      ],
    ),

    // ── LEVEL 2: Rising Waters ────────────────────────────────────────────

    Scenario(
      id: 'l2_s1',
      level: 2,
      title: 'Flooded Street',
      description:
          'You\'re on foot. The road ahead has 50cm of fast-moving floodwater. '
          'Your shelter is on the other side. What do you do?',
      imageEmoji: '🌊',
      backgroundType: 'flood',
      educationalTip:
          '6 inches of fast-moving water can knock you down. 2 feet can sweep away a car.',
      choices: [
        Choice(
          text: 'Wade through — it doesn\'t look that deep',
          icon: '🚶',
          isCorrect: false,
          effect: ChoiceEffect(
            healthDelta: -30,
            suppliesDelta: -20,
            moraleDelta: -20,
            timeDelta: -15,
            feedbackText:
                'You were swept off your feet! Never walk through fast-moving floodwater.',
          ),
        ),
        Choice(
          text: 'Find an alternate route on higher ground',
          icon: '🗺️',
          isCorrect: true,
          effect: ChoiceEffect(
            healthDelta: 0,
            suppliesDelta: -5,
            moraleDelta: 10,
            timeDelta: -15,
            feedbackText:
                'Wise decision. The longer route kept you safe. Time is less important than survival.',
          ),
        ),
        Choice(
          text: 'Wait for the water to recede',
          icon: '⏰',
          isCorrect: false,
          effect: ChoiceEffect(
            healthDelta: -10,
            suppliesDelta: -15,
            moraleDelta: -10,
            timeDelta: -20,
            feedbackText:
                'The water kept rising while you waited. In active flooding, waiting is rarely safe.',
          ),
        ),
        Choice(
          text: 'Use a rope/stick to test depth and cross carefully',
          icon: '🪵',
          isCorrect: false,
          effect: ChoiceEffect(
            healthDelta: -15,
            suppliesDelta: -10,
            moraleDelta: 0,
            timeDelta: -10,
            feedbackText:
                'Even careful crossing of fast-moving water is dangerous. Find another route.',
          ),
        ),
      ],
    ),

    Scenario(
      id: 'l2_s2',
      level: 2,
      title: 'Contaminated Water',
      description:
          'You\'re very thirsty. There is floodwater everywhere but your bottle is empty. '
          'You spot a shop with its door open — supplies might be inside.',
      imageEmoji: '💧',
      backgroundType: 'flood',
      educationalTip:
          'Floodwater is highly contaminated with sewage, chemicals, and bacteria. Never drink it.',
      choices: [
        Choice(
          text: 'Drink the floodwater — thirst is dangerous',
          icon: '🥤',
          isCorrect: false,
          effect: ChoiceEffect(
            healthDelta: -35,
            suppliesDelta: 0,
            moraleDelta: -10,
            timeDelta: -5,
            feedbackText:
                'Severe illness! Floodwater contains sewage, E.coli, leptospirosis and more. Never drink it.',
          ),
        ),
        Choice(
          text: 'Enter the shop to find sealed bottled water',
          icon: '🏪',
          isCorrect: true,
          effect: ChoiceEffect(
            healthDelta: 15,
            suppliesDelta: 20,
            moraleDelta: 15,
            timeDelta: -10,
            feedbackText:
                'Good! Sealed bottled water is safe. You found supplies and stayed healthy.',
          ),
        ),
        Choice(
          text: 'Boil the floodwater first before drinking',
          icon: '🔥',
          isCorrect: false,
          effect: ChoiceEffect(
            healthDelta: -10,
            suppliesDelta: -5,
            moraleDelta: -5,
            timeDelta: -15,
            feedbackText:
                'Boiling kills bacteria but NOT chemical contaminants in floodwater. Still dangerous.',
          ),
        ),
        Choice(
          text: 'Ration existing supplies and keep searching for sealed water',
          icon: '🔍',
          isCorrect: true,
          effect: ChoiceEffect(
            healthDelta: 5,
            suppliesDelta: 10,
            moraleDelta: 10,
            timeDelta: -8,
            feedbackText:
                'Smart rationing! You found more sealed water nearby. Good discipline.',
          ),
        ),
      ],
    ),

    Scenario(
      id: 'l2_s3',
      level: 2,
      title: 'Injured Stranger',
      description:
          'You spot someone with a bleeding leg wound sitting on a raised ledge. '
          'They need help but it will delay your escape. The water is still rising.',
      imageEmoji: '🤕',
      backgroundType: 'flood',
      educationalTip:
          'In emergencies, basic first aid (stopping bleeding with pressure) saves lives.',
      choices: [
        Choice(
          text: 'Leave them — you can\'t risk your own safety',
          icon: '🏃',
          isCorrect: false,
          effect: ChoiceEffect(
            healthDelta: 5,
            suppliesDelta: 0,
            moraleDelta: -25,
            timeDelta: 5,
            feedbackText:
                'You survived, but morale collapsed. The psychological impact of abandoning someone is real.',
          ),
        ),
        Choice(
          text: 'Apply pressure to stop bleeding, help them move',
          icon: '🩹',
          isCorrect: true,
          effect: ChoiceEffect(
            healthDelta: 0,
            suppliesDelta: -10,
            moraleDelta: 25,
            timeDelta: -15,
            feedbackText:
                'You saved them! Direct pressure on wounds is the most important first aid step.',
          ),
        ),
        Choice(
          text: 'Radio/shout for rescuers and mark the location',
          icon: '📢',
          isCorrect: true,
          effect: ChoiceEffect(
            healthDelta: 0,
            suppliesDelta: -5,
            moraleDelta: 20,
            timeDelta: -8,
            feedbackText:
                'Great coordination! Getting professional help to them quickly is the right call.',
          ),
        ),
        Choice(
          text: 'Give them all your medicine and leave',
          icon: '💊',
          isCorrect: false,
          effect: ChoiceEffect(
            healthDelta: -10,
            suppliesDelta: -20,
            moraleDelta: 5,
            timeDelta: -5,
            feedbackText:
                'Well-intentioned but risky. You depleted your own supplies and the wound still needed pressure.',
          ),
        ),
      ],
    ),

    Scenario(
      id: 'l2_s4',
      level: 2,
      title: 'The Rescue Boat',
      description:
          'A rescue boat approaches. It\'s already carrying 8 people and looks close to capacity. '
          'There are 4 of you who need rescue. The operator says he can only take 2 more.',
      imageEmoji: '⛵',
      backgroundType: 'rescue',
      educationalTip:
          'Overloading rescue boats causes capsizing. Follow operator instructions strictly.',
      choices: [
        Choice(
          text: 'All 4 of you jump on — the boat can handle it',
          icon: '👨‍👩‍👧‍👦',
          isCorrect: false,
          effect: ChoiceEffect(
            healthDelta: -40,
            suppliesDelta: -20,
            moraleDelta: -30,
            timeDelta: -20,
            feedbackText:
                'The boat capsized! Overloading kills everyone. Always follow capacity rules.',
          ),
        ),
        Choice(
          text: 'Prioritise children and injured, you wait',
          icon: '👶',
          isCorrect: true,
          effect: ChoiceEffect(
            healthDelta: 0,
            suppliesDelta: -5,
            moraleDelta: 25,
            timeDelta: -10,
            feedbackText:
                'Exemplary decision. The boat returned for you. Prioritising vulnerable people is the right protocol.',
          ),
        ),
        Choice(
          text: 'Ask boat to radio for a second rescue boat',
          icon: '📻',
          isCorrect: true,
          effect: ChoiceEffect(
            healthDelta: 5,
            suppliesDelta: 0,
            moraleDelta: 20,
            timeDelta: -10,
            feedbackText:
                'Smart! Calling for additional support ensures everyone gets rescued safely.',
          ),
        ),
        Choice(
          text: 'Refuse the boat and find another way',
          icon: '❌',
          isCorrect: false,
          effect: ChoiceEffect(
            healthDelta: -20,
            suppliesDelta: -15,
            moraleDelta: -15,
            timeDelta: -20,
            feedbackText:
                'Pride cost you dearly. Accept rescue when available — no second boats came.',
          ),
        ),
      ],
    ),

    // ── LEVEL 3: Survival Mode ────────────────────────────────────────────

    Scenario(
      id: 'l3_s1',
      level: 3,
      title: 'Stranded on Rooftop',
      description:
          'You\'re trapped on a rooftop. Helicopter rescue is searching the area. '
          'You have a phone, a mirror, and a bright orange jacket. How do you signal?',
      imageEmoji: '🚁',
      backgroundType: 'rescue',
      educationalTip:
          'Signal rescuers with bright colours, mirrors, smoke, or light — movement and contrast attract attention.',
      choices: [
        Choice(
          text: 'Wave your arms continuously',
          icon: '🙌',
          isCorrect: false,
          effect: ChoiceEffect(
            healthDelta: -10,
            suppliesDelta: -10,
            moraleDelta: -5,
            timeDelta: -10,
            feedbackText:
                'Arm-waving tires you out and is less visible than bright objects from a helicopter.',
          ),
        ),
        Choice(
          text: 'Use mirror to reflect sunlight at the helicopter',
          icon: '🪞',
          isCorrect: true,
          effect: ChoiceEffect(
            healthDelta: 5,
            suppliesDelta: 0,
            moraleDelta: 20,
            timeDelta: 10,
            feedbackText:
                'Brilliant! Mirror flashes are visible for miles. One of the best rescue signals.',
          ),
        ),
        Choice(
          text: 'Lay the orange jacket flat on the roof',
          icon: '🧡',
          isCorrect: true,
          effect: ChoiceEffect(
            healthDelta: 5,
            suppliesDelta: 0,
            moraleDelta: 15,
            timeDelta: 10,
            feedbackText:
                'Great! Bright flat signals contrast against grey rooftops and are clearly visible from above.',
          ),
        ),
        Choice(
          text: 'Call emergency services on your phone',
          icon: '📱',
          isCorrect: true,
          effect: ChoiceEffect(
            healthDelta: 10,
            suppliesDelta: 0,
            moraleDelta: 20,
            timeDelta: 15,
            feedbackText:
                'Best action if you have signal! Direct communication gets precise coordinates to rescuers.',
          ),
        ),
      ],
    ),

    Scenario(
      id: 'l3_s2',
      level: 3,
      title: 'Night Falls',
      description:
          'Night has come. Temperature is dropping. You\'re still stranded with 2 others. '
          'You have limited supplies. How do you manage through the night?',
      imageEmoji: '🌙',
      backgroundType: 'shelter',
      educationalTip:
          'Hypothermia can occur even in tropical floods at night. Stay dry and warm.',
      choices: [
        Choice(
          text: 'Eat all remaining food to stay warm',
          icon: '🍱',
          isCorrect: false,
          effect: ChoiceEffect(
            healthDelta: 5,
            suppliesDelta: -30,
            moraleDelta: -10,
            timeDelta: -10,
            feedbackText:
                'Short-sighted! You\'re warm now but will have nothing tomorrow. Ration carefully.',
          ),
        ),
        Choice(
          text: 'Huddle together and ration supplies equally',
          icon: '🤝',
          isCorrect: true,
          effect: ChoiceEffect(
            healthDelta: 10,
            suppliesDelta: -5,
            moraleDelta: 20,
            timeDelta: -5,
            feedbackText:
                'Body heat shared between people can prevent hypothermia. Smart rationing too.',
          ),
        ),
        Choice(
          text: 'Build a shelter from debris to block wind',
          icon: '🏕️',
          isCorrect: true,
          effect: ChoiceEffect(
            healthDelta: 15,
            suppliesDelta: -5,
            moraleDelta: 15,
            timeDelta: -8,
            feedbackText:
                'Excellent survival skill! Windbreaks drastically reduce heat loss overnight.',
          ),
        ),
        Choice(
          text: 'Try to swim to safety in the dark',
          icon: '🏊',
          isCorrect: false,
          effect: ChoiceEffect(
            healthDelta: -40,
            suppliesDelta: -20,
            moraleDelta: -20,
            timeDelta: -15,
            feedbackText:
                'Extremely dangerous! Swimming in dark floodwater risks drowning, hypothermia, and hidden hazards.',
          ),
        ),
      ],
    ),

    Scenario(
      id: 'l3_s3',
      level: 3,
      title: 'Mental Breakdown',
      description:
          'One of your companions is panicking — crying, hyperventilating, refusing to move. '
          'The rescue window may be closing. How do you handle this?',
      imageEmoji: '😰',
      backgroundType: 'shelter',
      educationalTip:
          'Panic in emergencies is normal. Calm communication saves lives more than force.',
      choices: [
        Choice(
          text: 'Shout at them to pull themselves together',
          icon: '😤',
          isCorrect: false,
          effect: ChoiceEffect(
            healthDelta: -5,
            suppliesDelta: 0,
            moraleDelta: -25,
            timeDelta: -5,
            feedbackText:
                'Aggression worsens panic. They shut down completely. Empathy is more effective.',
          ),
        ),
        Choice(
          text: 'Calm breathing exercises and reassuring words',
          icon: '🧘',
          isCorrect: true,
          effect: ChoiceEffect(
            healthDelta: 5,
            suppliesDelta: 0,
            moraleDelta: 25,
            timeDelta: -10,
            feedbackText:
                'Perfect! Controlled breathing activates the calm response. They stabilised and you moved together.',
          ),
        ),
        Choice(
          text: 'Leave them, go get help and come back',
          icon: '🏃',
          isCorrect: false,
          effect: ChoiceEffect(
            healthDelta: -5,
            suppliesDelta: 0,
            moraleDelta: -15,
            timeDelta: 0,
            feedbackText:
                'Risky — they may move into danger alone. Never split group unless absolutely necessary.',
          ),
        ),
        Choice(
          text: 'Give simple, clear tasks to focus their mind',
          icon: '📋',
          isCorrect: true,
          effect: ChoiceEffect(
            healthDelta: 5,
            suppliesDelta: 5,
            moraleDelta: 20,
            timeDelta: -8,
            feedbackText:
                'Excellent technique! Giving panicking people small tasks redirects their energy productively.',
          ),
        ),
      ],
    ),

    Scenario(
      id: 'l3_s4',
      level: 3,
      title: 'Final Rescue',
      description:
          'A rescue helicopter is hovering above. They drop a rope. '
          'The water is 2 metres below the rooftop and rising fast. '
          'Your companion is afraid of heights and refuses to grab the rope.',
      imageEmoji: '🚁',
      backgroundType: 'rescue',
      educationalTip:
          'In life-threatening situations, trusted encouragement gets people to overcome fear.',
      choices: [
        Choice(
          text: 'Go up first, then convince them from the helicopter',
          icon: '🪜',
          isCorrect: false,
          effect: ChoiceEffect(
            healthDelta: 10,
            suppliesDelta: 0,
            moraleDelta: -20,
            timeDelta: 5,
            feedbackText:
                'You were rescued but they refused from below. Moral victory lost. Never leave someone during active rescue.',
          ),
        ),
        Choice(
          text: 'Hold their hand, go together on the rope',
          icon: '🤝',
          isCorrect: true,
          effect: ChoiceEffect(
            healthDelta: 10,
            suppliesDelta: 0,
            moraleDelta: 30,
            timeDelta: -5,
            feedbackText:
                'You both made it! Physical reassurance overcame fear. This is true teamwork and leadership.',
          ),
        ),
        Choice(
          text: 'Explain calmly that drowning is worse than heights',
          icon: '💬',
          isCorrect: true,
          effect: ChoiceEffect(
            healthDelta: 5,
            suppliesDelta: 0,
            moraleDelta: 25,
            timeDelta: -8,
            feedbackText:
                'Logical framing worked. They grabbed the rope. Calm rational talk overcomes fear effectively.',
          ),
        ),
        Choice(
          text: 'Force them onto the rope physically',
          icon: '💪',
          isCorrect: false,
          effect: ChoiceEffect(
            healthDelta: -10,
            suppliesDelta: 0,
            moraleDelta: -10,
            timeDelta: -10,
            feedbackText:
                'They struggled and fell. Force during rescue is dangerous. Trust and communication are better.',
          ),
        ),
      ],
    ),
  ];

  static List<Scenario> getScenariosForLevel(int level) {
    return scenarios.where((s) => s.level == level).toList();
  }

  static Scenario getScenario(String id) {
    return scenarios.firstWhere((s) => s.id == id);
  }
}