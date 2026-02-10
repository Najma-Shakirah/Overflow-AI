import 'package:flutter/material.dart';
import 'navbar.dart';

class ChecklistPage extends StatefulWidget {
  const ChecklistPage({super.key});

  @override
  State<ChecklistPage> createState() => _ChecklistPageState();
}

class _ChecklistPageState extends State<ChecklistPage> {
  // Track which items are checked
  final Map<String, bool> _checkedItems = {};

  final List<ChecklistCategory> _categories = [
    ChecklistCategory(
      title: 'Important Documents',
      icon: Icons.description,
      color: Colors.blue,
      items: [
        'IC/Passport',
        'Birth certificates',
        'Insurance documents',
        'Medical records',
        'Property documents',
        'Bank statements',
        'Educational certificates',
      ],
    ),
    ChecklistCategory(
      title: 'Emergency Supplies',
      icon: Icons.medical_services,
      color: Colors.red,
      items: [
        'First aid kit',
        'Medicines and prescriptions',
        'Flashlight and batteries',
        'Portable radio',
        'Emergency whistle',
        'Waterproof matches/lighter',
        'Emergency blanket',
      ],
    ),
    ChecklistCategory(
      title: 'Food & Water',
      icon: Icons.restaurant,
      color: Colors.orange,
      items: [
        'Bottled water (3 days supply)',
        'Canned food',
        'Energy bars',
        'Baby food (if needed)',
        'Pet food (if needed)',
        'Can opener',
        'Disposable plates and utensils',
      ],
    ),
    ChecklistCategory(
      title: 'Personal Items',
      icon: Icons.shopping_bag,
      color: Colors.purple,
      items: [
        'Change of clothes',
        'Raincoat/poncho',
        'Sturdy shoes',
        'Toiletries',
        'Towels',
        'Sleeping bag/blanket',
        'Personal hygiene items',
      ],
    ),
    ChecklistCategory(
      title: 'Electronics & Communication',
      icon: Icons.phone_android,
      color: Colors.green,
      items: [
        'Fully charged phone',
        'Power bank',
        'Charging cables',
        'Important phone numbers written down',
        'Portable charger',
      ],
    ),
    ChecklistCategory(
      title: 'Money & Keys',
      icon: Icons.vpn_key,
      color: Colors.amber,
      items: [
        'Cash in small bills',
        'House keys',
        'Car keys',
        'Important passwords written down',
      ],
    ),
  ];

  @override
  void initState() {
    super.initState();
    // Initialize all items as unchecked
    for (var category in _categories) {
      for (var item in category.items) {
        _checkedItems[item] = false;
      }
    }
  }

  int get _totalItems {
    int count = 0;
    for (var category in _categories) {
      count += category.items.length;
    }
    return count;
  }

  int get _checkedCount {
    return _checkedItems.values.where((checked) => checked).length;
  }

  double get _progress {
    if (_totalItems == 0) return 0;
    return _checkedCount / _totalItems;
  }

  void _resetChecklist() {
    setState(() {
      _checkedItems.updateAll((key, value) => false);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // Header with gradient
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 28),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF3A83B7), Color.fromARGB(255, 29, 255, 142)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(20),
                bottomRight: Radius.circular(20),
              ),
            ),
            child: SafeArea(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back, color: Colors.white),
                        onPressed: () => Navigator.pop(context),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Flood Checklist',
                          style: Theme.of(context).textTheme.headlineSmall
                              ?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.refresh, color: Colors.white),
                        onPressed: _resetChecklist,
                        tooltip: 'Reset checklist',
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Essential items to prepare for flooding',
                    style: Theme.of(
                      context,
                    ).textTheme.bodyMedium?.copyWith(color: Colors.white70),
                  ),
                  const SizedBox(height: 16),
                  // Progress indicator
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Progress',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Text(
                              '$_checkedCount / $_totalItems items',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: LinearProgressIndicator(
                            value: _progress,
                            backgroundColor: Colors.white.withOpacity(0.3),
                            valueColor: const AlwaysStoppedAnimation<Color>(
                              Colors.white,
                            ),
                            minHeight: 8,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Checklist content
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _categories.length,
              itemBuilder: (context, index) {
                final category = _categories[index];
                return _ChecklistCategoryCard(
                  category: category,
                  checkedItems: _checkedItems,
                  onItemChanged: (item, value) {
                    setState(() {
                      _checkedItems[item] = value;
                    });
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: const MonitorFAB(),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: const CustomBottomNavBar(currentIndex: 0),
    );
  }
}

class ChecklistCategory {
  final String title;
  final IconData icon;
  final Color color;
  final List<String> items;

  ChecklistCategory({
    required this.title,
    required this.icon,
    required this.color,
    required this.items,
  });
}

class _ChecklistCategoryCard extends StatelessWidget {
  final ChecklistCategory category;
  final Map<String, bool> checkedItems;
  final Function(String, bool) onItemChanged;

  const _ChecklistCategoryCard({
    required this.category,
    required this.checkedItems,
    required this.onItemChanged,
  });

  int get _categoryCheckedCount {
    return category.items.where((item) => checkedItems[item] == true).length;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: category.color.withOpacity(0.3), width: 2),
        boxShadow: [
          BoxShadow(
            color: category.color.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Category header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: category.color.withOpacity(0.1),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(14),
                topRight: Radius.circular(14),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: category.color,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(category.icon, color: Colors.white, size: 24),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        category.title,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: category.color,
                        ),
                      ),
                      Text(
                        '$_categoryCheckedCount / ${category.items.length} completed',
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),
                CircularProgressIndicator(
                  value: category.items.isEmpty
                      ? 0
                      : _categoryCheckedCount / category.items.length,
                  backgroundColor: Colors.grey[200],
                  valueColor: AlwaysStoppedAnimation<Color>(category.color),
                  strokeWidth: 3,
                ),
              ],
            ),
          ),
          // Category items
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: category.items.length,
            itemBuilder: (context, index) {
              final item = category.items[index];
              final isChecked = checkedItems[item] ?? false;

              return CheckboxListTile(
                value: isChecked,
                onChanged: (value) {
                  onItemChanged(item, value ?? false);
                },
                title: Text(
                  item,
                  style: TextStyle(
                    fontSize: 14,
                    color: isChecked
                        ? Colors.grey[600]
                        : const Color(0xFF2D3748),
                    decoration: isChecked ? TextDecoration.lineThrough : null,
                  ),
                ),
                activeColor: category.color,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 4,
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
