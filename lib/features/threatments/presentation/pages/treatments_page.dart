import 'package:flutter/material.dart';
import 'package:hey_smile/features/threatments/data/treatment_service.dart';
import 'package:hey_smile/features/threatments/domain/hair_checkup.dart';

class TreatmentsPage extends StatefulWidget {
  const TreatmentsPage({super.key});

  @override
  State<TreatmentsPage> createState() => _TreatmentsPageState();
}

class _TreatmentsPageState extends State<TreatmentsPage> {
  int _selectedTreatmentIndex = 0;
  final TreatmentService _treatmentService = TreatmentService();
  List<HairCheckup> _hairCheckups = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadHairCheckups();
  }

  Future<void> _loadHairCheckups() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final checkups = await _treatmentService.getHairCheckups();
      setState(() {
        _hairCheckups = checkups;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading hair checkups: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  List<Map<String, String>> _getImagesForCheckup(HairCheckup checkup) {
    return [
      {'url': checkup.imageFrontUrl, 'label': 'Front'},
      {'url': checkup.imageBackUrl, 'label': 'Back'},
      {'url': checkup.imageLeftUrl, 'label': 'Left'},
      {'url': checkup.imageRightUrl, 'label': 'Right'},
      {'url': checkup.imageTopUrl, 'label': 'Top'},
    ];
  }

  Map<String, String> _getTreatmentDetails(int index) {
    final List<Map<String, String>> fakeData = [
      {
        'method': 'FUE (Follicular Unit Extraction)',
        'duration': '8 hours',
        'anesthesia': 'Local Anesthesia',
        'donorCap': 'Good',
        'extracted': '4500',
        'remaining': '2000',
        'areas': 'Frontal, Crown',
        'firstWash': '2024-06-18',
        'followUp': '2024-07-15',
        'warnings':
            'Avoid direct sunlight for 2 weeks. Do not scratch the transplanted area. Sleep with head elevated.',
      },
      {
        'method': 'DHI (Direct Hair Implantation)',
        'duration': '6 hours',
        'anesthesia': 'Local Anesthesia',
        'donorCap': 'Excellent',
        'extracted': '3200',
        'remaining': '3300',
        'areas': 'Frontal',
        'firstWash': '2023-03-23',
        'followUp': '2023-04-20',
        'warnings':
            'No heavy exercise for 10 days. Avoid swimming for 1 month. Use prescribed shampoo only.',
      },
      {
        'method': 'PRP (Platelet-Rich Plasma)',
        'duration': '1 hour',
        'anesthesia': 'Topical',
        'donorCap': 'N/A',
        'extracted': '0',
        'remaining': '0',
        'areas': 'Full Scalp',
        'firstWash': '2024-10-06',
        'followUp': '2024-11-05',
        'warnings':
            'Avoid washing hair for 24 hours. No alcohol for 3 days. Stay hydrated.',
      },
    ];

    // Return the corresponding fake data or cycle through them
    return fakeData[index % fakeData.length];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // Treatment Selector as SliverAppBar
            if (!_isLoading && _hairCheckups.isNotEmpty)
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
                    itemCount: _hairCheckups.length,
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
                              'Hair Checkup #${index + 1}',
                              style: TextStyle(
                                color: isSelected
                                    ? Colors.white
                                    : Colors.black87,
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

                  _isLoading
                      ? const SizedBox(
                          height: 200,
                          child: Center(child: CircularProgressIndicator()),
                        )
                      : _hairCheckups.isEmpty
                      ? const SizedBox(
                          height: 200,
                          child: Center(
                            child: Text(
                              'No photos uploaded yet',
                              style: TextStyle(color: Colors.grey),
                            ),
                          ),
                        )
                      : SizedBox(
                          height: 200,
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            itemCount: _getImagesForCheckup(
                              _hairCheckups[_selectedTreatmentIndex %
                                  _hairCheckups.length],
                            ).length,
                            itemBuilder: (context, index) {
                              final images = _getImagesForCheckup(
                                _hairCheckups[_selectedTreatmentIndex %
                                    _hairCheckups.length],
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
                                      child: Image.network(
                                        images[index]['url']!,
                                        fit: BoxFit.cover,
                                        width: double.infinity,
                                        height: double.infinity,
                                        errorBuilder:
                                            (context, error, stackTrace) {
                                              return Container(
                                                color: Colors.grey[300],
                                                child: const Icon(
                                                  Icons.error_outline,
                                                  size: 50,
                                                  color: Colors.grey,
                                                ),
                                              );
                                            },
                                        loadingBuilder: (context, child, loadingProgress) {
                                          if (loadingProgress == null) {
                                            return child;
                                          }
                                          return Center(
                                            child: CircularProgressIndicator(
                                              value:
                                                  loadingProgress
                                                          .expectedTotalBytes !=
                                                      null
                                                  ? loadingProgress
                                                            .cumulativeBytesLoaded /
                                                        loadingProgress
                                                            .expectedTotalBytes!
                                                  : null,
                                            ),
                                          );
                                        },
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
                                          borderRadius: BorderRadius.circular(
                                            20,
                                          ),
                                        ),
                                        child: Text(
                                          images[index]['label']!,
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
                  if (!_isLoading && _hairCheckups.isNotEmpty) ...[
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
                      'Date',
                      _hairCheckups[_selectedTreatmentIndex %
                              _hairCheckups.length]
                          .date,
                    ),
                    _buildInfoCard(
                      'Grafts',
                      '${_hairCheckups[_selectedTreatmentIndex % _hairCheckups.length].graft}',
                    ),
                    _buildInfoCard(
                      'Method',
                      _getTreatmentDetails(_selectedTreatmentIndex)['method']!,
                    ),
                    _buildInfoCard(
                      'Duration',
                      _getTreatmentDetails(
                        _selectedTreatmentIndex,
                      )['duration']!,
                    ),
                    _buildInfoCard(
                      'Anesthesia',
                      _getTreatmentDetails(
                        _selectedTreatmentIndex,
                      )['anesthesia']!,
                    ),
                    _buildInfoCard(
                      'Donor Cap.',
                      _getTreatmentDetails(
                        _selectedTreatmentIndex,
                      )['donorCap']!,
                    ),
                    _buildInfoCard(
                      'Extracted',
                      _getTreatmentDetails(
                        _selectedTreatmentIndex,
                      )['extracted']!,
                    ),
                    _buildInfoCard(
                      'Remaining',
                      _getTreatmentDetails(
                        _selectedTreatmentIndex,
                      )['remaining']!,
                    ),
                    _buildInfoCard(
                      'Areas',
                      _getTreatmentDetails(_selectedTreatmentIndex)['areas']!,
                    ),
                    _buildInfoCard(
                      '1st Wash',
                      _getTreatmentDetails(
                        _selectedTreatmentIndex,
                      )['firstWash']!,
                    ),
                    _buildInfoCard(
                      'Follow-Up',
                      _getTreatmentDetails(
                        _selectedTreatmentIndex,
                      )['followUp']!,
                    ),
                    _buildInfoCard(
                      'User Notes',
                      _hairCheckups[_selectedTreatmentIndex %
                              _hairCheckups.length]
                          .userNotes,
                      isLarge: true,
                    ),
                    if (_hairCheckups[_selectedTreatmentIndex %
                                _hairCheckups.length]
                            .doctorComment !=
                        null)
                      _buildInfoCard(
                        'Doctor Comment',
                        _hairCheckups[_selectedTreatmentIndex %
                                _hairCheckups.length]
                            .doctorComment!,
                        isLarge: true,
                      ),
                    _buildInfoCard(
                      'Warnings',
                      _getTreatmentDetails(
                        _selectedTreatmentIndex,
                      )['warnings']!,
                      isLarge: true,
                    ),
                  ],

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
      case 'Date':
        return Icons.calendar_today;
      case 'Grafts':
        return Icons.grain;
      case 'User Notes':
        return Icons.note_alt;
      case 'Doctor Comment':
        return Icons.medical_information;
      case 'OP Date':
        return Icons.calendar_today;
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
}
