import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../navbar/navbar.dart';

// ─────────────────────────────────────────
// DATA MODEL
// ─────────────────────────────────────────
class Shelter {
  final String id;
  final String name;
  final String address;
  final String district;
  final int capacity;
  final int currentOccupancy;
  final int boatsAvailable;
  final bool hasFirstAidTraining;
  final int firstAidPersonnel;
  final bool hasWorkingWaterPump;
  final bool hasFoodStockpile;
  final bool hasMedicineStockpile;
  final int dialysisPatients;
  final int pregnantWomen;
  final String contactNumber;
  final String status;

  Shelter({
    required this.id,
    required this.name,
    required this.address,
    required this.district,
    required this.capacity,
    required this.currentOccupancy,
    required this.boatsAvailable,
    required this.hasFirstAidTraining,
    required this.firstAidPersonnel,
    required this.hasWorkingWaterPump,
    required this.hasFoodStockpile,
    required this.hasMedicineStockpile,
    required this.dialysisPatients,
    required this.pregnantWomen,
    required this.contactNumber,
    required this.status,
  });

  factory Shelter.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Shelter(
      id: doc.id,
      name: data['name'] ?? '',
      address: data['address'] ?? '',
      district: data['district'] ?? '',
      capacity: data['capacity'] ?? 0,
      currentOccupancy: data['currentOccupancy'] ?? 0,
      boatsAvailable: data['boatsAvailable'] ?? 0,
      hasFirstAidTraining: data['hasFirstAidTraining'] ?? false,
      firstAidPersonnel: data['firstAidPersonnel'] ?? 0,
      hasWorkingWaterPump: data['hasWorkingWaterPump'] ?? false,
      hasFoodStockpile: data['hasFoodStockpile'] ?? false,
      hasMedicineStockpile: data['hasMedicineStockpile'] ?? false,
      dialysisPatients: data['dialysisPatients'] ?? 0,
      pregnantWomen: data['pregnantWomen'] ?? 0,
      contactNumber: data['contactNumber'] ?? '',
      status: data['status'] ?? 'Open',
    );
  }

  double get occupancyRate => capacity > 0 ? currentOccupancy / capacity : 0;
  int get availableSpots => capacity - currentOccupancy;
}

// ─────────────────────────────────────────
// MAIN PAGE
// ─────────────────────────────────────────
class ShelterPage extends StatefulWidget {
  const ShelterPage({super.key});
  @override
  State<ShelterPage> createState() => _ShelterPageState();
}

class _ShelterPageState extends State<ShelterPage> {
  // ── Dropdowns ──────────────────────────
  String _selectedState = 'All States';
  String _selectedStatus = 'All Status';

  static const List<String> _states = [
    'All States',
    'Johor',
    'Kedah',
    'Kelantan',
    'Melaka',
    'Negeri Sembilan',
    'Pahang',
    'Perak',
    'Perlis',
    'Pulau Pinang',
    'Sabah',
    'Sarawak',
    'Selangor',
    'Terengganu',
    'Kuala Lumpur',
    'Labuan',
    'Putrajaya',
  ];

  static const List<String> _statuses = [
    'All Status',
    'Open',
    'Full',
    'Closed',
  ];

  // ── Seed ───────────────────────────────
  Future<void> _seedData() async {
    final col = FirebaseFirestore.instance.collection('shelters');
    final existing = await col.limit(1).get();
    if (existing.docs.isNotEmpty) return;

    final shelters = [
      {
        'name': 'Dewan Orang Ramai Kampung Baru',
        'address': 'Jalan Raja Muda Musa, Kampung Baru, 50300 KL',
        'district': 'Kuala Lumpur',
        'capacity': 500,
        'currentOccupancy': 320,
        'boatsAvailable': 4,
        'hasFirstAidTraining': true,
        'firstAidPersonnel': 8,
        'hasWorkingWaterPump': true,
        'hasFoodStockpile': true,
        'hasMedicineStockpile': true,
        'dialysisPatients': 3,
        'pregnantWomen': 2,
        'contactNumber': '03-2691 0000',
        'status': 'Open'
      },
      {
        'name': 'SK Taman Setapak',
        'address': 'Jalan Setapak, 53000 Kuala Lumpur',
        'district': 'Kuala Lumpur',
        'capacity': 300,
        'currentOccupancy': 295,
        'boatsAvailable': 2,
        'hasFirstAidTraining': true,
        'firstAidPersonnel': 5,
        'hasWorkingWaterPump': true,
        'hasFoodStockpile': true,
        'hasMedicineStockpile': false,
        'dialysisPatients': 1,
        'pregnantWomen': 4,
        'contactNumber': '03-4021 5555',
        'status': 'Full'
      },
      {
        'name': 'Pusat Komuniti Shah Alam Seksyen 7',
        'address': 'Jalan Pelabuhan 7/1, Seksyen 7, 40000 Shah Alam',
        'district': 'Selangor',
        'capacity': 800,
        'currentOccupancy': 410,
        'boatsAvailable': 6,
        'hasFirstAidTraining': true,
        'firstAidPersonnel': 12,
        'hasWorkingWaterPump': true,
        'hasFoodStockpile': true,
        'hasMedicineStockpile': true,
        'dialysisPatients': 5,
        'pregnantWomen': 3,
        'contactNumber': '03-5519 1234',
        'status': 'Open'
      },
      {
        'name': 'Dewan MBPJ Petaling Jaya',
        'address': 'Jalan Yong Shook Lin, 46050 Petaling Jaya',
        'district': 'Selangor',
        'capacity': 600,
        'currentOccupancy': 150,
        'boatsAvailable': 3,
        'hasFirstAidTraining': false,
        'firstAidPersonnel': 2,
        'hasWorkingWaterPump': false,
        'hasFoodStockpile': true,
        'hasMedicineStockpile': true,
        'dialysisPatients': 0,
        'pregnantWomen': 1,
        'contactNumber': '03-7955 7777',
        'status': 'Open'
      },
      {
        'name': 'Dewan Serbaguna Johor Bahru',
        'address': 'Jalan Skudai, 81300 Johor Bahru',
        'district': 'Johor',
        'capacity': 1000,
        'currentOccupancy': 670,
        'boatsAvailable': 8,
        'hasFirstAidTraining': true,
        'firstAidPersonnel': 15,
        'hasWorkingWaterPump': true,
        'hasFoodStockpile': true,
        'hasMedicineStockpile': true,
        'dialysisPatients': 8,
        'pregnantWomen': 6,
        'contactNumber': '07-223 4567',
        'status': 'Open'
      },
      {
        'name': 'Dewan Jubli Perak Sultan Ismail',
        'address': 'Jalan Sultan Ismail, 20200 Kuala Terengganu',
        'district': 'Terengganu',
        'capacity': 700,
        'currentOccupancy': 480,
        'boatsAvailable': 10,
        'hasFirstAidTraining': true,
        'firstAidPersonnel': 14,
        'hasWorkingWaterPump': true,
        'hasFoodStockpile': true,
        'hasMedicineStockpile': true,
        'dialysisPatients': 6,
        'pregnantWomen': 4,
        'contactNumber': '09-622 1000',
        'status': 'Open'
      },
      {
        'name': 'SMK Bukit Besar',
        'address': 'Jalan Bukit Besar, 21300 Kuala Terengganu',
        'district': 'Terengganu',
        'capacity': 400,
        'currentOccupancy': 210,
        'boatsAvailable': 5,
        'hasFirstAidTraining': true,
        'firstAidPersonnel': 6,
        'hasWorkingWaterPump': true,
        'hasFoodStockpile': true,
        'hasMedicineStockpile': false,
        'dialysisPatients': 2,
        'pregnantWomen': 1,
        'contactNumber': '09-623 4567',
        'status': 'Open'
      },
      {
        'name': 'Pusat Komuniti Kota Bharu',
        'address': 'Jalan Hamzah, 15000 Kota Bharu',
        'district': 'Kelantan',
        'capacity': 900,
        'currentOccupancy': 750,
        'boatsAvailable': 12,
        'hasFirstAidTraining': true,
        'firstAidPersonnel': 18,
        'hasWorkingWaterPump': true,
        'hasFoodStockpile': true,
        'hasMedicineStockpile': true,
        'dialysisPatients': 10,
        'pregnantWomen': 7,
        'contactNumber': '09-748 1000',
        'status': 'Full'
      },
      {
        'name': 'Dewan Orang Ramai Pasir Mas',
        'address': 'Jalan Hospital, 17000 Pasir Mas',
        'district': 'Kelantan',
        'capacity': 500,
        'currentOccupancy': 320,
        'boatsAvailable': 7,
        'hasFirstAidTraining': true,
        'firstAidPersonnel': 9,
        'hasWorkingWaterPump': true,
        'hasFoodStockpile': true,
        'hasMedicineStockpile': true,
        'dialysisPatients': 4,
        'pregnantWomen': 3,
        'contactNumber': '09-790 2222',
        'status': 'Open'
      },
      {
        'name': 'Dewan Serbaguna Kuantan',
        'address': 'Jalan Beserah, 25300 Kuantan',
        'district': 'Pahang',
        'capacity': 750,
        'currentOccupancy': 390,
        'boatsAvailable': 9,
        'hasFirstAidTraining': true,
        'firstAidPersonnel': 11,
        'hasWorkingWaterPump': true,
        'hasFoodStockpile': true,
        'hasMedicineStockpile': true,
        'dialysisPatients': 5,
        'pregnantWomen': 3,
        'contactNumber': '09-513 1000',
        'status': 'Open'
      },
      {
        'name': 'SK Temerloh Pusat',
        'address': 'Jalan Dato Hamzah, 28000 Temerloh',
        'district': 'Pahang',
        'capacity': 350,
        'currentOccupancy': 180,
        'boatsAvailable': 4,
        'hasFirstAidTraining': false,
        'firstAidPersonnel': 2,
        'hasWorkingWaterPump': true,
        'hasFoodStockpile': true,
        'hasMedicineStockpile': false,
        'dialysisPatients': 1,
        'pregnantWomen': 2,
        'contactNumber': '09-296 3333',
        'status': 'Open'
      },
    ];

    for (final s in shelters) {
      await col.add(s);
    }
  }

  @override
  void initState() {
    super.initState();
    _seedData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // ── Header ──────────────────────
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 28),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF3A83B7), Color.fromARGB(255, 29, 217, 255)],
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
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text('Flood Shelters',
                            style: Theme.of(context)
                                .textTheme
                                .headlineSmall
                                ?.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                )),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text('Find available shelters near you',
                      style: Theme.of(context)
                          .textTheme
                          .bodyMedium
                          ?.copyWith(color: Colors.white70)),
                ],
              ),
            ),
          ),

          // ── Filter row ──────────────────
          Container(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  _DropdownChip(
                    value: _selectedState,
                    items: _states,
                    icon: Icons.location_on,
                    onChanged: (v) =>
                        setState(() => _selectedState = v ?? 'All States'),
                  ),
                  const SizedBox(width: 10),
                  _DropdownChip(
                    value: _selectedStatus,
                    items: _statuses,
                    icon: Icons.info_outline,
                    onChanged: (v) =>
                        setState(() => _selectedStatus = v ?? 'All Status'),
                  ),
                ],
              ),
            ),
          ),

          // ── Shelter list ─────────────────
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream:
                  FirebaseFirestore.instance.collection('shelters').snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(child: Text('No shelters found.'));
                }

                List<Shelter> shelters = snapshot.data!.docs
                    .map((d) => Shelter.fromFirestore(d))
                    .toList();

                // Apply state filter
                if (_selectedState != 'All States') {
                  shelters = shelters
                      .where((s) => s.district == _selectedState)
                      .toList();
                }
                // Apply status filter
                if (_selectedStatus != 'All Status') {
                  shelters = shelters
                      .where((s) => s.status == _selectedStatus)
                      .toList();
                }

                if (shelters.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.search_off,
                            size: 64, color: Colors.grey[300]),
                        const SizedBox(height: 16),
                        Text(
                          'No shelters found\nfor the selected filters.',
                          textAlign: TextAlign.center,
                          style:
                              TextStyle(color: Colors.grey[500], fontSize: 15),
                        ),
                        const SizedBox(height: 12),
                        TextButton(
                          onPressed: () => setState(() {
                            _selectedState = 'All States';
                            _selectedStatus = 'All Status';
                          }),
                          child: const Text('Clear Filters'),
                        ),
                      ],
                    ),
                  );
                }

                return Column(
                  children: [
                    // Results count bar
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      color: Colors.grey[50],
                      child: Row(
                        children: [
                          Text(
                            '${shelters.length} shelter${shelters.length == 1 ? '' : 's'} found',
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey[600],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const Spacer(),
                          if (_selectedState != 'All States' ||
                              _selectedStatus != 'All Status')
                            GestureDetector(
                              onTap: () => setState(() {
                                _selectedState = 'All States';
                                _selectedStatus = 'All Status';
                              }),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: Colors.red[50],
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: Colors.red[200]!),
                                ),
                                child: Row(
                                  children: [
                                    Icon(Icons.close,
                                        size: 12, color: Colors.red[600]),
                                    const SizedBox(width: 4),
                                    Text('Clear',
                                        style: TextStyle(
                                            fontSize: 12,
                                            color: Colors.red[600],
                                            fontWeight: FontWeight.w600)),
                                  ],
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: ListView.builder(
                        padding: const EdgeInsets.fromLTRB(16, 12, 16, 100),
                        itemCount: shelters.length,
                        itemBuilder: (context, index) =>
                            _ShelterCard(shelter: shelters[index]),
                      ),
                    ),
                  ],
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

// ─────────────────────────────────────────
// DROPDOWN CHIP — matches old filter chip style
// ─────────────────────────────────────────
class _DropdownChip extends StatelessWidget {
  final String value;
  final List<String> items;
  final IconData icon;
  final ValueChanged<String?> onChanged;

  const _DropdownChip({
    required this.value,
    required this.items,
    required this.icon,
    required this.onChanged,
  });

  bool get _isFiltered => value != items.first;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(
        color: _isFiltered ? const Color(0xFF3A83B7) : Colors.grey[200],
        borderRadius: BorderRadius.circular(20),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          isDense: true,
          icon: Icon(
            Icons.keyboard_arrow_down,
            color: _isFiltered ? Colors.white : Colors.grey[700],
            size: 16,
          ),
          dropdownColor: Colors.white,
          style: TextStyle(
            color: _isFiltered ? Colors.white : Colors.grey[700],
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
          onChanged: onChanged,
          selectedItemBuilder: (context) => items
              .map((item) => Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(icon,
                          size: 13,
                          color: _isFiltered ? Colors.white : Colors.grey[700]),
                      const SizedBox(width: 5),
                      Text(item,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color:
                                _isFiltered ? Colors.white : Colors.grey[700],
                          )),
                    ],
                  ))
              .toList(),
          items: items
              .map((item) => DropdownMenuItem<String>(
                    value: item,
                    child: Text(
                      item,
                      style: TextStyle(
                        fontSize: 13,
                        color: item == value
                            ? const Color(0xFF3A83B7)
                            : Colors.grey[800],
                        fontWeight:
                            item == value ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                  ))
              .toList(),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────
// SHELTER CARD
// ─────────────────────────────────────────
class _ShelterCard extends StatelessWidget {
  final Shelter shelter;
  const _ShelterCard({required this.shelter});

  Color get _statusColor {
    switch (shelter.status) {
      case 'Open':
        return Colors.green;
      case 'Full':
        return Colors.orange;
      case 'Closed':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  Color get _occupancyColor {
    if (shelter.occupancyRate >= 0.9) return Colors.red;
    if (shelter.occupancyRate >= 0.7) return Colors.orange;
    return Colors.green;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
              builder: (_) => _ShelterDetailPage(shelter: shelter))),
      child: Container(
        margin: const EdgeInsets.only(bottom: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: _statusColor.withOpacity(0.3), width: 1.5),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Name + Status
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: const Color(0xFF3A83B7).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.house_rounded,
                        color: Color(0xFF3A83B7), size: 24),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(shelter.name,
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF2D3748),
                            )),
                        const SizedBox(height: 4),
                        Row(children: [
                          Icon(Icons.location_on,
                              size: 13, color: Colors.grey[500]),
                          const SizedBox(width: 3),
                          Text(shelter.district,
                              style: TextStyle(
                                  fontSize: 12, color: Colors.grey[600])),
                        ]),
                      ],
                    ),
                  ),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: _statusColor,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(shelter.status.toUpperCase(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        )),
                  ),
                ],
              ),
              const SizedBox(height: 14),

              // Occupancy bar
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Occupancy',
                          style:
                              TextStyle(fontSize: 12, color: Colors.grey[600])),
                      Text('${shelter.currentOccupancy} / ${shelter.capacity}',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: _occupancyColor,
                          )),
                    ],
                  ),
                  const SizedBox(height: 6),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: LinearProgressIndicator(
                      value: shelter.occupancyRate.clamp(0.0, 1.0),
                      backgroundColor: Colors.grey[200],
                      valueColor:
                          AlwaysStoppedAnimation<Color>(_occupancyColor),
                      minHeight: 7,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text('${shelter.availableSpots} spots available',
                      style: TextStyle(fontSize: 11, color: Colors.grey[500])),
                ],
              ),
              const SizedBox(height: 12),

              // Quick chips
              Wrap(
                spacing: 8,
                runSpacing: 6,
                children: [
                  _InfoChip(
                    icon: Icons.directions_boat,
                    label: '${shelter.boatsAvailable} Boats',
                    color: Colors.blue,
                  ),
                  _InfoChip(
                    icon: Icons.medical_services,
                    label: shelter.hasFirstAidTraining
                        ? '${shelter.firstAidPersonnel} First Aid'
                        : 'No First Aid',
                    color: shelter.hasFirstAidTraining
                        ? Colors.green
                        : Colors.grey,
                  ),
                  _InfoChip(
                    icon: Icons.restaurant,
                    label: shelter.hasFoodStockpile ? 'Food' : 'No Food',
                    color:
                        shelter.hasFoodStockpile ? Colors.orange : Colors.grey,
                  ),
                  _InfoChip(
                    icon: Icons.water_drop,
                    label:
                        shelter.hasWorkingWaterPump ? 'Water Pump' : 'No Pump',
                    color:
                        shelter.hasWorkingWaterPump ? Colors.cyan : Colors.grey,
                  ),
                ],
              ),

              // Medical warning
              if (shelter.dialysisPatients > 0 || shelter.pregnantWomen > 0)
                Container(
                  margin: const EdgeInsets.only(top: 10),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.red[50],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.red[200]!),
                  ),
                  child: Row(children: [
                    Icon(Icons.favorite, size: 14, color: Colors.red[600]),
                    const SizedBox(width: 6),
                    Text(
                        'Medical needs: ${[
                          if (shelter.dialysisPatients > 0)
                            '${shelter.dialysisPatients} dialysis',
                          if (shelter.pregnantWomen > 0)
                            '${shelter.pregnantWomen} pregnant',
                        ].join(', ')}',
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.red[700],
                          fontWeight: FontWeight.w600,
                        )),
                  ]),
                ),

              const SizedBox(height: 10),
              Row(children: [
                Icon(Icons.phone, size: 13, color: Colors.grey[500]),
                const SizedBox(width: 4),
                Text(shelter.contactNumber,
                    style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                const Spacer(),
                const Text('View Details →',
                    style: TextStyle(
                      fontSize: 12,
                      color: Color(0xFF3A83B7),
                      fontWeight: FontWeight.w600,
                    )),
              ]),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────
// DETAIL PAGE
// ─────────────────────────────────────────
class _ShelterDetailPage extends StatelessWidget {
  final Shelter shelter;
  const _ShelterDetailPage({required this.shelter});

  Color get _statusColor {
    switch (shelter.status) {
      case 'Open':
        return Colors.green;
      case 'Full':
        return Colors.orange;
      case 'Closed':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 180,
            pinned: true,
            backgroundColor: const Color(0xFF3A83B7),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Color(0xFF3A83B7),
                      Color.fromARGB(255, 29, 255, 142)
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 48, 20, 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: _statusColor,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(shelter.status.toUpperCase(),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                              )),
                        ),
                        const SizedBox(height: 8),
                        Text(shelter.name,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            )),
                        const SizedBox(height: 4),
                        Row(children: [
                          const Icon(Icons.location_on,
                              color: Colors.white70, size: 14),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(shelter.address,
                                style: const TextStyle(
                                    color: Colors.white70, fontSize: 13)),
                          ),
                        ]),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          SliverList(
            delegate: SliverChildListDelegate([
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _SectionCard(
                      title: 'Capacity & Occupancy',
                      icon: Icons.people,
                      color: Colors.blue,
                      child: Column(children: [
                        _DetailRow(
                            label: 'Total Capacity',
                            value: '${shelter.capacity} people'),
                        _DetailRow(
                            label: 'Current Occupancy',
                            value: '${shelter.currentOccupancy} people'),
                        _DetailRow(
                          label: 'Available Spots',
                          value: '${shelter.availableSpots} spots',
                          valueColor: shelter.availableSpots > 50
                              ? Colors.green
                              : Colors.red,
                        ),
                        const SizedBox(height: 8),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: LinearProgressIndicator(
                            value: shelter.occupancyRate.clamp(0.0, 1.0),
                            backgroundColor: Colors.grey[200],
                            valueColor: AlwaysStoppedAnimation<Color>(
                              shelter.occupancyRate >= 0.9
                                  ? Colors.red
                                  : shelter.occupancyRate >= 0.7
                                      ? Colors.orange
                                      : Colors.green,
                            ),
                            minHeight: 10,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                            '${(shelter.occupancyRate * 100).toStringAsFixed(0)}% full',
                            style: TextStyle(
                                fontSize: 12, color: Colors.grey[600])),
                      ]),
                    ),
                    const SizedBox(height: 16),
                    _SectionCard(
                      title: 'Rescue Resources',
                      icon: Icons.directions_boat,
                      color: Colors.teal,
                      child: Column(children: [
                        _DetailRow(
                          label: 'Boats / Rafts Available',
                          value: '${shelter.boatsAvailable}',
                          icon: Icons.directions_boat,
                        ),
                        _DetailRow(
                          label: 'Working Water Pumps',
                          value: shelter.hasWorkingWaterPump ? 'Yes' : 'No',
                          valueColor: shelter.hasWorkingWaterPump
                              ? Colors.green
                              : Colors.red,
                          icon: Icons.water_drop,
                        ),
                      ]),
                    ),
                    const SizedBox(height: 16),
                    _SectionCard(
                      title: 'Stockpiles',
                      icon: Icons.inventory,
                      color: Colors.orange,
                      child: Column(children: [
                        _DetailRow(
                          label: 'Food Stockpile',
                          value:
                              shelter.hasFoodStockpile ? 'Available' : 'None',
                          valueColor: shelter.hasFoodStockpile
                              ? Colors.green
                              : Colors.red,
                          icon: Icons.restaurant,
                        ),
                        _DetailRow(
                          label: 'Medicine Stockpile',
                          value: shelter.hasMedicineStockpile
                              ? 'Available'
                              : 'None',
                          valueColor: shelter.hasMedicineStockpile
                              ? Colors.green
                              : Colors.red,
                          icon: Icons.medical_services,
                        ),
                      ]),
                    ),
                    const SizedBox(height: 16),
                    _SectionCard(
                      title: 'First Aid & Medical',
                      icon: Icons.local_hospital,
                      color: Colors.red,
                      child: Column(children: [
                        _DetailRow(
                          label: 'First Aid Training Available',
                          value: shelter.hasFirstAidTraining ? 'Yes' : 'No',
                          valueColor: shelter.hasFirstAidTraining
                              ? Colors.green
                              : Colors.red,
                        ),
                        _DetailRow(
                          label: 'Trained Personnel',
                          value: '${shelter.firstAidPersonnel} persons',
                        ),
                      ]),
                    ),
                    const SizedBox(height: 16),
                    _SectionCard(
                      title: 'Special Medical Needs',
                      icon: Icons.favorite,
                      color: Colors.pink,
                      child: Column(children: [
                        _DetailRow(
                          label: 'Dialysis Patients',
                          value: '${shelter.dialysisPatients} persons',
                          valueColor: shelter.dialysisPatients > 0
                              ? Colors.red
                              : Colors.grey,
                        ),
                        _DetailRow(
                          label: 'Pregnant Women',
                          value: '${shelter.pregnantWomen} persons',
                          valueColor: shelter.pregnantWomen > 0
                              ? Colors.pink
                              : Colors.grey,
                        ),
                      ]),
                    ),
                    const SizedBox(height: 16),
                    _SectionCard(
                      title: 'Contact',
                      icon: Icons.phone,
                      color: Colors.purple,
                      child: _DetailRow(
                        label: 'Phone',
                        value: shelter.contactNumber,
                        icon: Icons.phone,
                      ),
                    ),
                    const SizedBox(height: 100),
                  ],
                ),
              ),
            ]),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────
// HELPER WIDGETS
// ─────────────────────────────────────────
class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  const _InfoChip(
      {required this.icon, required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: color),
          const SizedBox(width: 4),
          Text(label,
              style: TextStyle(
                fontSize: 11,
                color: color,
                fontWeight: FontWeight.w600,
              )),
        ],
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color color;
  final Widget child;
  const _SectionCard(
      {required this.title,
      required this.icon,
      required this.color,
      required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.2), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.08),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(14),
                topRight: Radius.circular(14),
              ),
            ),
            child: Row(children: [
              Icon(icon, color: color, size: 20),
              const SizedBox(width: 8),
              Text(title,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: color,
                  )),
            ]),
          ),
          Padding(padding: const EdgeInsets.all(16), child: child),
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;
  final IconData? icon;
  const _DetailRow(
      {required this.label, required this.value, this.valueColor, this.icon});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(children: [
        if (icon != null) ...[
          Icon(icon, size: 15, color: Colors.grey[500]),
          const SizedBox(width: 6),
        ],
        Expanded(
          child: Text(label,
              style: TextStyle(fontSize: 13, color: Colors.grey[700])),
        ),
        Text(value,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: valueColor ?? const Color(0xFF2D3748),
            )),
      ]),
    );
  }
}
