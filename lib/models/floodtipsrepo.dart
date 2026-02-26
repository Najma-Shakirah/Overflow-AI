class FloodTip {
  final String title;
  final String description;
  final String icon;

  FloodTip({
    required this.title,
    required this.description,
    required this.icon,
  });
}

class FloodTipsRepository {
  static final List<FloodTip> tips = [
    FloodTip(
      title: 'Move to Higher Ground',
      description: 'When flooding occurs, immediately move to higher ground. Never wait to see if water levels will decrease.',
      icon: '⛰️',
    ),
    FloodTip(
      title: 'Never Drive Through Water',
      description: 'Just 60cm of water can sweep away most vehicles. Turn around, don\'t drown!',
      icon: '🚗',
    ),
    FloodTip(
      title: 'Avoid Walking in Water',
      description: 'Just 15cm of moving water can knock you down. Water may hide dangerous debris or open manholes.',
      icon: '🚶',
    ),
    FloodTip(
      title: 'Prepare Emergency Kit',
      description: 'Keep water, food, first aid supplies, flashlight, batteries, and important documents ready.',
      icon: '🎒',
    ),
    FloodTip(
      title: 'Monitor Weather Updates',
      description: 'Stay informed through official channels and weather apps. Know your area\'s flood warning levels.',
      icon: '📡',
    ),
    FloodTip(
      title: 'Know Evacuation Routes',
      description: 'Plan multiple escape routes from your home and workplace. Practice them with your family.',
      icon: '🗺️',
    ),
    FloodTip(
      title: 'Protect Valuables',
      description: 'Move important documents and valuables to upper floors before floods arrive.',
      icon: '📄',
    ),
    FloodTip(
      title: 'Turn Off Utilities',
      description: 'If time permits, turn off electricity, gas, and water to prevent further damage.',
      icon: '⚡',
    ),
    FloodTip(
      title: 'Stay Away from Power Lines',
      description: 'Downed power lines can electrify water. Report them immediately and keep far away.',
      icon: '⚠️',
    ),
    FloodTip(
      title: 'Don\'t Return Too Soon',
      description: 'Wait for official clearance before returning home. Buildings may be structurally damaged.',
      icon: '🏠',
    ),
  ];

  static List<FloodTip> getAllTips() => tips;
}