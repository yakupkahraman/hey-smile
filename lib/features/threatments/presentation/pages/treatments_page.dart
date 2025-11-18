import 'package:flutter/material.dart';
import 'package:hey_smile/features/threatments/domain/treatment.dart';

class TreatmentsPage extends StatefulWidget {
  const TreatmentsPage({super.key});

  @override
  State<TreatmentsPage> createState() => _TreatmentsPageState();
}

class _TreatmentsPageState extends State<TreatmentsPage> {
  int _selectedTreatmentIndex = 0;

  // Area to image mapping
  final Map<String, String> _areaImageMap = {
    'frontal': 'assets/images/front.jpeg',
    'front': 'assets/images/front.jpeg',
    'crown': 'assets/images/top.jpeg',
    'top': 'assets/images/top.jpeg',
    'left': 'assets/images/left.jpeg',
    'right': 'assets/images/right.jpeg',
    'back': 'assets/images/back.jpeg',
    'full scalp': 'assets/images/front.jpeg',
  };

  List<String> _getImagesForTreatment(Treatment treatment) {
    final areas = treatment.areas.toLowerCase().split(',');
    final Set<String> images = {};

    for (var area in areas) {
      final trimmedArea = area.trim();
      for (var key in _areaImageMap.keys) {
        if (trimmedArea.contains(key)) {
          images.add(_areaImageMap[key]!);
        }
      }
    }

    // If no specific match, return front image
    if (images.isEmpty) {
      images.add('assets/images/front.jpeg');
    }

    return images.toList();
  }

  String _getLabelForImage(String imagePath) {
    if (imagePath.contains('front')) return 'Front';
    if (imagePath.contains('top')) return 'Top';
    if (imagePath.contains('left')) return 'Left';
    if (imagePath.contains('right')) return 'Right';
    if (imagePath.contains('back')) return 'Back';
    return 'View';
  }

  // Fake treatments data
  final List<Treatment> _treatments = [
    Treatment(
      id: '1',
      name: 'Hair Transplant #1',
      opDate: DateTime(2024, 6, 15),
      grafts: 4500,
      method: 'FUE (Follicular Unit Extraction)',
      duration: '8 hours',
      anesthesia: 'Local Anesthesia',
      donorCap: 'Good',
      extracted: 4500,
      remaining: 2000,
      areas: 'Frontal, Crown',
      firstWash: DateTime(2024, 6, 18),
      followUp: DateTime(2024, 7, 15),
      warnings:
          'Avoid direct sunlight for 2 weeks. Do not scratch the transplanted area. Sleep with head elevated.',
    ),
    Treatment(
      id: '2',
      name: 'Hair Transplant #2',
      opDate: DateTime(2023, 3, 20),
      grafts: 3200,
      method: 'DHI (Direct Hair Implantation)',
      duration: '6 hours',
      anesthesia: 'Local Anesthesia',
      donorCap: 'Excellent',
      extracted: 3200,
      remaining: 3300,
      areas: 'Frontal',
      firstWash: DateTime(2023, 3, 23),
      followUp: DateTime(2023, 4, 20),
      warnings:
          'No heavy exercise for 10 days. Avoid swimming for 1 month. Use prescribed shampoo only.',
    ),
    Treatment(
      id: '3',
      name: 'PRP Treatment',
      opDate: DateTime(2024, 10, 5),
      grafts: 0,
      method: 'PRP (Platelet-Rich Plasma)',
      duration: '1 hour',
      anesthesia: 'Topical',
      donorCap: 'N/A',
      extracted: 0,
      remaining: 0,
      areas: 'Full Scalp',
      firstWash: DateTime(2024, 10, 6),
      followUp: DateTime(2024, 11, 5),
      warnings:
          'Avoid washing hair for 24 hours. No alcohol for 3 days. Stay hydrated.',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final selectedTreatment = _treatments[_selectedTreatmentIndex];

    return Scaffold(
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // Treatment Selector as SliverAppBar
            SliverAppBar(
              floating: true,
              snap: true,
              pinned: false,
              expandedHeight: 60,
              flexibleSpace: Container(
                padding: const EdgeInsets.symmetric(vertical: 8),
                color: Theme.of(context).colorScheme.primary,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: _treatments.length,
                  itemBuilder: (context, index) {
                    final isSelected = index == _selectedTreatmentIndex;
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedTreatmentIndex = index;
                        });
                      },
                      child: Container(
                        margin: const EdgeInsets.only(right: 12),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? Theme.of(context).colorScheme.secondary
                              : Theme.of(context).scaffoldBackgroundColor,
                          borderRadius: BorderRadius.circular(25),
                          boxShadow: isSelected
                              ? [
                                  BoxShadow(
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.secondary.withOpacity(0.3),
                                    blurRadius: 8,
                                    offset: const Offset(0, 2),
                                  ),
                                ]
                              : null,
                        ),
                        child: Center(
                          child: Text(
                            _treatments[index].name,
                            style: TextStyle(
                              color: isSelected ? Colors.white : Colors.black87,
                              fontWeight: isSelected
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                              fontSize: 15,
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),

            // Content
            SliverToBoxAdapter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 16),

                  // Uploaded Photos Section
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Text(
                      'Uploaded Photos',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),

                  SizedBox(
                    height: 200,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: _getImagesForTreatment(
                        selectedTreatment,
                      ).length,
                      itemBuilder: (context, index) {
                        final images = _getImagesForTreatment(
                          selectedTreatment,
                        );
                        return Container(
                          width: 280,
                          margin: const EdgeInsets.only(right: 12),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Stack(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(16),
                                child: Image.asset(
                                  images[index],
                                  fit: BoxFit.cover,
                                  width: double.infinity,
                                  height: double.infinity,
                                ),
                              ),
                              Positioned(
                                top: 12,
                                left: 12,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 6,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.black.withOpacity(0.6),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Text(
                                    _getLabelForImage(images[index]),
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Treatment Information Section
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Text(
                      'Treatment Details',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  _buildInfoCard(
                    'OP Date',
                    _formatDate(selectedTreatment.opDate),
                  ),
                  _buildInfoCard('Grafts', '${selectedTreatment.grafts}'),
                  _buildInfoCard('Method', selectedTreatment.method),
                  _buildInfoCard('Duration', selectedTreatment.duration),
                  _buildInfoCard('Anesthesia', selectedTreatment.anesthesia),
                  _buildInfoCard('Donor Cap.', selectedTreatment.donorCap),
                  _buildInfoCard('Extracted', '${selectedTreatment.extracted}'),
                  _buildInfoCard('Remaining', '${selectedTreatment.remaining}'),
                  _buildInfoCard('Areas', selectedTreatment.areas),
                  _buildInfoCard(
                    '1st Wash',
                    _formatDate(selectedTreatment.firstWash),
                  ),
                  _buildInfoCard(
                    'Follow-Up',
                    _formatDate(selectedTreatment.followUp),
                  ),
                  _buildInfoCard(
                    'Warnings',
                    selectedTreatment.warnings,
                    isLarge: true,
                  ),

                  const SizedBox(height: 24),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard(String label, String value, {bool isLarge = false}) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                _getIconForLabel(label),
                size: 20,
                color: Theme.of(context).colorScheme.secondary,
              ),
              const SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade600,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: isLarge ? 14 : 16,
              color: Colors.black87,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  IconData _getIconForLabel(String label) {
    switch (label) {
      case 'OP Date':
        return Icons.calendar_today;
      case 'Grafts':
        return Icons.grain;
      case 'Method':
        return Icons.medical_services;
      case 'Duration':
        return Icons.access_time;
      case 'Anesthesia':
        return Icons.healing;
      case 'Donor Cap.':
        return Icons.inventory;
      case 'Extracted':
        return Icons.arrow_upward;
      case 'Remaining':
        return Icons.arrow_downward;
      case 'Areas':
        return Icons.location_on;
      case '1st Wash':
        return Icons.water_drop;
      case 'Follow-Up':
        return Icons.event_repeat;
      case 'Warnings':
        return Icons.warning_amber;
      default:
        return Icons.info;
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
