import 'package:flutter/material.dart';
import 'package:hey_smile/features/auth/presentation/providers/auth_provider.dart';
import 'package:hey_smile/features/threatments/data/treatment_service.dart';
import 'package:hey_smile/features/threatments/domain/hair_checkup.dart';
import 'package:hey_smile/features/tracker/data/tracker_service.dart';
import 'package:hey_smile/features/tracker/domain/reminder.dart';
import 'package:provider/provider.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final TreatmentService _treatmentService = TreatmentService();
  final TrackerService _trackerService = TrackerService();
  List<HairCheckup> _hairCheckups = [];
  List<Reminder> _todayReminders = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadData();
    // Debug: Print user profile photo URL
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authProvider = context.read<AuthProvider>();
      print(
        'DEBUG: User profile photo URL: ${authProvider.currentUser?.profilePhotoUrl}',
      );
    });
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Load hair checkups and reminders in parallel
      final results = await Future.wait([
        _treatmentService.getHairCheckups(),
        _trackerService.getReminders(),
      ]);

      final checkups = results[0] as List<HairCheckup>;
      final allReminders = results[1] as List<Reminder>;

      // Filter today's reminders
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final todayReminders = allReminders.where((reminder) {
        if (reminder.date == null || reminder.date!.isEmpty) return false;
        try {
          final reminderDate = DateTime.parse(reminder.date!);
          final normalizedDate = DateTime(
            reminderDate.year,
            reminderDate.month,
            reminderDate.day,
          );
          return normalizedDate.isAtSameMomentAs(today);
        } catch (e) {
          return false;
        }
      }).toList();

      setState(() {
        _hairCheckups = checkups;
        _todayReminders = todayReminders;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Map<String, dynamic> _getCurrentPhase(DateTime treatmentDate) {
    final now = DateTime.now();
    final daysSince = now.difference(treatmentDate).inDays;

    if (daysSince < 0) {
      return {
        'phase': 'Pre-Op Phase',
        'description': 'Preparing the scalp, medical checks',
        'progress': 0.0,
        'color': Colors.blue,
        'icon': Icons.medical_services,
      };
    } else if (daysSince <= 7) {
      return {
        'phase': 'Immediate Post-Op Phase',
        'description': 'Crust formation, washing protocol begins',
        'progress': daysSince / 7,
        'color': Colors.red,
        'icon': Icons.healing,
      };
    } else if (daysSince <= 28) {
      return {
        'phase': 'Healing Phase',
        'description': 'Crusts fall off, redness decreases',
        'progress': (daysSince - 7) / 21,
        'color': Colors.orange,
        'icon': Icons.auto_fix_high,
      };
    } else if (daysSince <= 56) {
      return {
        'phase': 'Shock Loss Phase',
        'description': 'Transplanted hairs shed (normal process)',
        'progress': (daysSince - 28) / 28,
        'color': Colors.amber,
        'icon': Icons.warning_amber,
      };
    } else if (daysSince <= 120) {
      return {
        'phase': 'Early Growth Phase',
        'description': 'First thin hairs appear',
        'progress': (daysSince - 56) / 64,
        'color': Colors.lightGreen,
        'icon': Icons.grass,
      };
    } else if (daysSince <= 270) {
      return {
        'phase': 'Density Growth Phase',
        'description': 'Hair thickens, density increases',
        'progress': (daysSince - 120) / 150,
        'color': Colors.green,
        'icon': Icons.trending_up,
      };
    } else if (daysSince <= 540) {
      return {
        'phase': 'Full Maturation Phase',
        'description': 'Final thickness, full density',
        'progress': (daysSince - 270) / 270,
        'color': Colors.teal,
        'icon': Icons.check_circle,
      };
    } else {
      return {
        'phase': 'Completed',
        'description': 'Natural look achieved',
        'progress': 1.0,
        'color': Colors.purple,
        'icon': Icons.celebration,
      };
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final user = authProvider.currentUser;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              Container(
                width: double.infinity,
                color: Theme.of(context).colorScheme.primary,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(height: 20),
                    CircleAvatar(
                      radius: 40,
                      backgroundColor: Colors.white,
                      backgroundImage:
                          user?.profilePhotoUrl != null &&
                              user!.profilePhotoUrl!.isNotEmpty
                          ? NetworkImage(user.profilePhotoUrl!)
                          : null,
                      child:
                          user?.profilePhotoUrl == null ||
                              user!.profilePhotoUrl!.isEmpty
                          ? Text(
                              user?.firstName[0].toUpperCase() ?? 'U',
                              style: const TextStyle(
                                fontSize: 32,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            )
                          : null,
                    ),
                    const SizedBox(height: 10),
                    Text(
                      user?.fullName ?? 'Kullanıcı',
                      style: const TextStyle(
                        fontSize: 20,
                        color: Colors.white,
                        fontFamily: 'Poppins',
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),

              // Treatment Progress Section
              if (_isLoading)
                const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Center(child: CircularProgressIndicator()),
                )
              else if (_hairCheckups.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: _buildProgressCard(
                    context,
                    DateTime.parse(_hairCheckups.first.date),
                  ),
                ),

              // Tasks for Today Section
              if (!_isLoading)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.task_alt,
                            color: Theme.of(context).colorScheme.secondary,
                            size: 24,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Tasks for Today',
                            style: Theme.of(context).textTheme.titleLarge
                                ?.copyWith(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: Theme.of(
                                context,
                              ).colorScheme.secondary.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              '${_todayReminders.length}',
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.secondary,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      _todayReminders.isEmpty
                          ? Card(
                              elevation: 2,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(24.0),
                                child: Center(
                                  child: Column(
                                    children: [
                                      Icon(
                                        Icons.check_circle_outline,
                                        size: 48,
                                        color: Colors.grey.shade300,
                                      ),
                                      const SizedBox(height: 12),
                                      Text(
                                        'No tasks for today!',
                                        style: TextStyle(
                                          color: Colors.grey.shade600,
                                          fontSize: 16,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                      Text(
                                        'Enjoy your day',
                                        style: TextStyle(
                                          color: Colors.grey.shade400,
                                          fontSize: 14,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            )
                          : Column(
                              children: _todayReminders
                                  .map(
                                    (reminder) => Card(
                                      elevation: 2,
                                      margin: const EdgeInsets.only(bottom: 8),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: ListTile(
                                        leading: Container(
                                          width: 40,
                                          height: 40,
                                          decoration: BoxDecoration(
                                            color: Theme.of(context)
                                                .colorScheme
                                                .secondary
                                                .withOpacity(0.1),
                                            borderRadius: BorderRadius.circular(
                                              10,
                                            ),
                                          ),
                                          child: Icon(
                                            Icons.notifications_active,
                                            color: Theme.of(
                                              context,
                                            ).colorScheme.secondary,
                                            size: 20,
                                          ),
                                        ),
                                        title: Text(
                                          reminder.title,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.w600,
                                            fontSize: 15,
                                          ),
                                        ),
                                        subtitle: Text(
                                          reminder.content,
                                          style: TextStyle(
                                            color: Colors.grey.shade600,
                                            fontSize: 13,
                                          ),
                                        ),
                                        trailing: Icon(
                                          Icons.arrow_forward_ios,
                                          size: 16,
                                          color: Colors.grey.shade400,
                                        ),
                                      ),
                                    ),
                                  )
                                  .toList(),
                            ),
                    ],
                  ),
                ),
              const SizedBox(height: 16),

              // Treatment Summary Section
              if (!_isLoading && _hairCheckups.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: _buildTreatmentSummary(context, _hairCheckups.first),
                ),
              const SizedBox(height: 24),

              // Diğer ana sayfa içeriği buraya gelecek
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProgressCard(BuildContext context, DateTime treatmentDate) {
    final phaseInfo = _getCurrentPhase(treatmentDate);
    final now = DateTime.now();
    final daysSince = now.difference(treatmentDate).inDays;

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              phaseInfo['color'].withOpacity(0.1),
              phaseInfo['color'].withOpacity(0.05),
            ],
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: phaseInfo['color'],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(phaseInfo['icon'], color: Colors.white, size: 28),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        phaseInfo['phase'],
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: phaseInfo['color'],
                        ),
                      ),
                      Text(
                        phaseInfo['description'],
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Day $daysSince',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey.shade700,
                  ),
                ),
                Text(
                  '${(phaseInfo['progress'] * 100).toStringAsFixed(0)}%',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: phaseInfo['color'],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: LinearProgressIndicator(
                value: phaseInfo['progress'],
                minHeight: 10,
                backgroundColor: Colors.grey.shade200,
                valueColor: AlwaysStoppedAnimation<Color>(phaseInfo['color']),
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.calendar_today,
                    size: 16,
                    color: Colors.grey.shade600,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Treatment Date: ${treatmentDate.day}/${treatmentDate.month}/${treatmentDate.year}',
                    style: TextStyle(fontSize: 13, color: Colors.grey.shade700),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTreatmentSummary(BuildContext context, HairCheckup checkup) {
    final treatmentDate = DateTime.parse(checkup.date);
    final daysSince = DateTime.now().difference(treatmentDate).inDays;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Icons.summarize,
              color: Theme.of(context).colorScheme.secondary,
              size: 24,
            ),
            const SizedBox(width: 8),
            Text(
              'Treatment Summary',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Card(
          elevation: 3,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                _buildSummaryRow(
                  context,
                  Icons.event,
                  'Treatment Date',
                  '${treatmentDate.day}/${treatmentDate.month}/${treatmentDate.year}',
                ),
                const Divider(height: 24),
                _buildSummaryRow(
                  context,
                  Icons.schedule,
                  'Days Since Treatment',
                  '$daysSince days',
                ),
                const Divider(height: 24),
                _buildSummaryRow(
                  context,
                  Icons.grain,
                  'Total Grafts',
                  '${checkup.graft}',
                ),
                const Divider(height: 24),
                _buildSummaryRow(
                  context,
                  Icons.medical_services,
                  'Method',
                  'FUE (Follicular Unit Extraction)',
                ),
                if (checkup.doctorComment != null) ...[
                  const Divider(height: 24),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.medical_information,
                            size: 20,
                            color: Theme.of(context).colorScheme.secondary,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Doctor\'s Comment',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Colors.grey.shade700,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.blue.shade50,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.blue.shade200),
                        ),
                        child: Text(
                          checkup.doctorComment!,
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey.shade800,
                            height: 1.4,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryRow(
    BuildContext context,
    IconData icon,
    String label,
    String value,
  ) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.secondary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            size: 20,
            color: Theme.of(context).colorScheme.secondary,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
