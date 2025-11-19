import 'package:flutter/material.dart';
import 'package:hey_smile/core/constants.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

class AnalysisPage extends StatelessWidget {
  const AnalysisPage({super.key});

  // Fake analysis data from doctor
  Map<String, dynamic> _getAnalysisData() {
    return {
      'hairLossClassification': {
        'norwoodScale': 'NW5',
        'primaryAreas': 'Frontal zone + Midscalp + Crown',
        'recessionLevel': 'Advanced recession, temporal peaks weakened',
      },
      'recipientArea': {
        'frontalArea': '62 cm²',
        'midscalpArea': '45 cm²',
        'crownArea': '38 cm²',
        'totalArea': '145 cm²',
      },
      'donorArea': {
        'donorDensity': '52 FU/cm²',
        'safeDonorZone': '145 cm²',
        'extractableGrafts': 'Approx. 3,900 – 4,200',
        'hairThickness': '65 microns',
        'hairType': 'Wavy',
        'hairColor': 'Brown',
        'follicleComposition': '60% double grafts, 30% single, 10% triple',
      },
      'surgicalPlan': {
        'method': 'DHI (for high precision and density)',
        'totalGrafts': '3,500 grafts',
        'distribution': {
          'frontal': '1,800',
          'midscalp': '1,000',
          'crown': '700',
        },
        'sessions': '1 session',
        'expectedCoverage': {
          'frontal': '100%',
          'midscalp': '80–90%',
          'crown': '50–60%',
        },
      },
      'donorManagement': {
        'minSafeExtraction': '4,000 grafts',
        'suggestedExtraction': '3,500 grafts',
        'remainingReserve': '500–700 grafts (future use)',
      },
      'pricePlans': [
        {
          'package': 'Basic',
          'grafts': '3,500',
          'includes': 'Operation + aftercare kit',
          'price': '€1,800',
        },
        {
          'package': 'Standard',
          'grafts': '3,500',
          'includes': 'Operation + 2-night hotel + transfers',
          'price': '€2,300',
        },
        {
          'package': 'Premium',
          'grafts': '3,500',
          'includes': 'Operation + 5-star hotel + VIP travel + PRP',
          'price': '€2,900',
        },
      ],
    };
  }

  @override
  Widget build(BuildContext context) {
    final analysisData = _getAnalysisData();

    return Scaffold(
      backgroundColor: ThemeConstants.backgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              // Header
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      ThemeConstants.primaryColor,
                      ThemeConstants.primaryColor.withOpacity(0.8),
                    ],
                  ),
                ),
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      children: [
                        PhosphorIcon(
                          PhosphorIcons.chartLine(PhosphorIconsStyle.fill),
                          size: 50,
                          color: Colors.white,
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          'Medical Assessment',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Detailed Analysis & Recommendations',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.white.withOpacity(0.9),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // Content
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    // A. Hair Loss Classification
                    _buildSectionCard(
                      title: 'A. Hair Loss Classification',
                      icon: PhosphorIcons.warning(PhosphorIconsStyle.regular),
                      children: [
                        _buildInfoRow(
                          'Norwood-Hamilton Scale',
                          analysisData['hairLossClassification']['norwoodScale'],
                        ),
                        _buildInfoRow(
                          'Primary Affected Areas',
                          analysisData['hairLossClassification']['primaryAreas'],
                        ),
                        _buildInfoRow(
                          'Hairline Recession Level',
                          analysisData['hairLossClassification']['recessionLevel'],
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    // B. Recipient Area Assessment
                    _buildSectionCard(
                      title: 'B. Recipient (Open) Area Assessment',
                      icon: PhosphorIcons.mapPin(PhosphorIconsStyle.regular),
                      children: [
                        _buildInfoRow(
                          'Frontal Area Size',
                          analysisData['recipientArea']['frontalArea'],
                        ),
                        _buildInfoRow(
                          'Midscalp Area Size',
                          analysisData['recipientArea']['midscalpArea'],
                        ),
                        _buildInfoRow(
                          'Crown (Vertex) Area Size',
                          analysisData['recipientArea']['crownArea'],
                        ),
                        _buildInfoRow(
                          'Total Open Area',
                          analysisData['recipientArea']['totalArea'],
                          highlight: true,
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    // C. Donor Area Evaluation
                    _buildSectionCard(
                      title: 'C. Donor Area Evaluation',
                      icon: PhosphorIcons.dna(PhosphorIconsStyle.regular),
                      children: [
                        _buildInfoRow(
                          'Donor Density (avg.)',
                          analysisData['donorArea']['donorDensity'],
                        ),
                        _buildInfoRow(
                          'Safe Donor Zone Size',
                          analysisData['donorArea']['safeDonorZone'],
                        ),
                        _buildInfoRow(
                          'Extractable Grafts (Safe)',
                          analysisData['donorArea']['extractableGrafts'],
                        ),
                        const Divider(height: 24),
                        const Text(
                          'Hair Characteristics',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 8),
                        _buildInfoRow(
                          'Hair Thickness',
                          analysisData['donorArea']['hairThickness'],
                        ),
                        _buildInfoRow(
                          'Hair Type',
                          analysisData['donorArea']['hairType'],
                        ),
                        _buildInfoRow(
                          'Hair Color',
                          analysisData['donorArea']['hairColor'],
                        ),
                        _buildInfoRow(
                          'Follicle Composition',
                          analysisData['donorArea']['follicleComposition'],
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    // D. Recommended Surgical Plan
                    _buildSectionCard(
                      title: 'D. Recommended Surgical Plan',
                      icon: PhosphorIcons.heartbeat(PhosphorIconsStyle.regular),
                      children: [
                        _buildInfoRow(
                          'Recommended Method',
                          analysisData['surgicalPlan']['method'],
                          highlight: true,
                        ),
                        _buildInfoRow(
                          'Total Grafts Recommended',
                          analysisData['surgicalPlan']['totalGrafts'],
                          highlight: true,
                        ),
                        const SizedBox(height: 8),
                        _buildInfoRow(
                          '  • Frontal',
                          '${analysisData['surgicalPlan']['distribution']['frontal']} grafts',
                        ),
                        _buildInfoRow(
                          '  • Midscalp',
                          '${analysisData['surgicalPlan']['distribution']['midscalp']} grafts',
                        ),
                        _buildInfoRow(
                          '  • Crown',
                          '${analysisData['surgicalPlan']['distribution']['crown']} grafts',
                        ),
                        const SizedBox(height: 8),
                        _buildInfoRow(
                          'Sessions Required',
                          analysisData['surgicalPlan']['sessions'],
                        ),
                        const Divider(height: 24),
                        const Text(
                          'Expected Coverage',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 8),
                        _buildInfoRow(
                          'Frontal',
                          analysisData['surgicalPlan']['expectedCoverage']['frontal'],
                        ),
                        _buildInfoRow(
                          'Midscalp',
                          analysisData['surgicalPlan']['expectedCoverage']['midscalp'],
                        ),
                        _buildInfoRow(
                          'Crown',
                          analysisData['surgicalPlan']['expectedCoverage']['crown'],
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    // E. Donor Management Plan
                    _buildSectionCard(
                      title: 'E. Donor Management Plan',
                      icon: PhosphorIcons.shieldCheck(
                        PhosphorIconsStyle.regular,
                      ),
                      children: [
                        _buildInfoRow(
                          'Minimum Safe Extraction Limit',
                          analysisData['donorManagement']['minSafeExtraction'],
                        ),
                        _buildInfoRow(
                          'Suggested Extraction',
                          analysisData['donorManagement']['suggestedExtraction'],
                          highlight: true,
                        ),
                        _buildInfoRow(
                          'Remaining Donor Reserve',
                          analysisData['donorManagement']['remainingReserve'],
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    // F. Price Plans
                    _buildPricePlansCard(analysisData['pricePlans']),

                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionCard({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: ThemeConstants.secondaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: PhosphorIcon(
                  icon,
                  color: ThemeConstants.secondaryColor,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: ThemeConstants.secondaryColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...children,
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, {bool highlight = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey[700],
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              value,
              style: TextStyle(
                fontSize: 13,
                color: highlight
                    ? ThemeConstants.secondaryColor
                    : Colors.black87,
                fontWeight: highlight ? FontWeight.bold : FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPricePlansCard(List<Map<String, String>> plans) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            ThemeConstants.secondaryColor,
            ThemeConstants.secondaryColor.withOpacity(0.8),
          ],
        ),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: ThemeConstants.secondaryColor.withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              PhosphorIcon(
                PhosphorIcons.currencyEur(PhosphorIconsStyle.fill),
                color: Colors.white,
                size: 24,
              ),
              const SizedBox(width: 12),
              const Text(
                'F. Price Plans',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...plans.map((plan) => _buildPricePlanRow(plan)).toList(),
        ],
      ),
    );
  }

  Widget _buildPricePlanRow(Map<String, String> plan) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.white.withOpacity(0.3), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                plan['package']!,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              Text(
                plan['price']!,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            '${plan['grafts']} grafts',
            style: TextStyle(
              fontSize: 12,
              color: Colors.white.withOpacity(0.9),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            plan['includes']!,
            style: TextStyle(
              fontSize: 12,
              color: Colors.white.withOpacity(0.8),
            ),
          ),
        ],
      ),
    );
  }
}
