import 'package:flutter/material.dart';
import 'package:hey_smile/core/constants.dart';
import 'package:hey_smile/features/auth/presentation/providers/auth_provider.dart';
import 'package:hey_smile/features/profile/data/profile_service.dart';
import 'package:provider/provider.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:intl/intl.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final ProfileService _profileService = ProfileService();

  // Health questionnaire data
  String? medicalConditions;
  String? allergies;
  String? pastSurgeries;
  String? currentMedications;
  bool _isLoadingHealthData = true;

  @override
  void initState() {
    super.initState();
    _loadHealthData();
  }

  // Load health data from local storage
  Future<void> _loadHealthData() async {
    try {
      final data = await _profileService.loadHealthData();
      setState(() {
        medicalConditions = data['medicalConditions'];
        allergies = data['allergies'];
        pastSurgeries = data['pastSurgeries'];
        currentMedications = data['currentMedications'];
        _isLoadingHealthData = false;
      });
    } catch (e) {
      setState(() {
        _isLoadingHealthData = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to load health data: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  // Save health data to local storage
  Future<void> _saveHealthData() async {
    try {
      final healthData = {
        'medicalConditions': medicalConditions ?? '',
        'allergies': allergies ?? '',
        'pastSurgeries': pastSurgeries ?? '',
        'currentMedications': currentMedications ?? '',
      };
      await _profileService.saveHealthData(healthData);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to save health data: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  // Calculate profile completion percentage
  int _calculateProfileCompletion() {
    int completedFields = 0;
    int totalFields = 5; // 4 health questions + profile photo

    final authProvider = context.read<AuthProvider>();
    final user = authProvider.currentUser;

    // Profile photo
    if (user?.profilePhotoUrl != null && user!.profilePhotoUrl!.isNotEmpty) {
      completedFields++;
    }

    // Health questions
    if (medicalConditions != null && medicalConditions!.isNotEmpty) {
      completedFields++;
    }
    if (allergies != null && allergies!.isNotEmpty) completedFields++;
    if (pastSurgeries != null && pastSurgeries!.isNotEmpty) completedFields++;
    if (currentMedications != null && currentMedications!.isNotEmpty) {
      completedFields++;
    }

    return ((completedFields / totalFields) * 100).round();
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final user = authProvider.currentUser;
    final completionPercentage = _calculateProfileCompletion();

    return Scaffold(
      backgroundColor: ThemeConstants.backgroundColor,
      body: user == null || _isLoadingHealthData
          ? const Center(child: CircularProgressIndicator())
          : SafeArea(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    // Header with profile photo
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
                              const SizedBox(height: 10),
                              // Profile Photo
                              Container(
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: Colors.white,
                                    width: 4,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.2),
                                      blurRadius: 20,
                                      offset: const Offset(0, 10),
                                    ),
                                  ],
                                ),
                                child: CircleAvatar(
                                  radius: 50,
                                  backgroundColor: Colors.white,
                                  backgroundImage:
                                      user.profilePhotoUrl != null &&
                                          user.profilePhotoUrl!.isNotEmpty
                                      ? NetworkImage(user.profilePhotoUrl!)
                                      : null,
                                  child:
                                      user.profilePhotoUrl == null ||
                                          user.profilePhotoUrl!.isEmpty
                                      ? Text(
                                          user.firstName[0].toUpperCase(),
                                          style: const TextStyle(
                                            fontSize: 40,
                                            fontWeight: FontWeight.bold,
                                            color: ThemeConstants.primaryColor,
                                          ),
                                        )
                                      : null,
                                ),
                              ),
                              const SizedBox(height: 12),
                              // Name
                              Text(
                                '${user.firstName} ${user.lastName}',
                                style: const TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(height: 6),
                              // Email
                              Text(
                                user.email,
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.white.withOpacity(0.9),
                                ),
                              ),
                              const SizedBox(height: 16),
                            ],
                          ),
                        ),
                      ),
                    ),

                    // Profile Information Cards
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        children: [
                          // Profile Completion Card
                          _buildProfileCompletionCard(completionPercentage),
                          const SizedBox(height: 24),

                          // Personal Information Section
                          _buildSectionTitle('Personal Information'),
                          const SizedBox(height: 12),
                          _buildInfoCard(
                            icon: PhosphorIcons.user(
                              PhosphorIconsStyle.regular,
                            ),
                            title: 'First Name',
                            value: user.firstName,
                          ),
                          const SizedBox(height: 12),
                          _buildInfoCard(
                            icon: PhosphorIcons.user(
                              PhosphorIconsStyle.regular,
                            ),
                            title: 'Last Name',
                            value: user.lastName,
                          ),
                          const SizedBox(height: 12),
                          _buildInfoCard(
                            icon: PhosphorIcons.envelope(
                              PhosphorIconsStyle.regular,
                            ),
                            title: 'Email',
                            value: user.email,
                          ),
                          const SizedBox(height: 12),
                          _buildInfoCard(
                            icon: PhosphorIcons.phone(
                              PhosphorIconsStyle.regular,
                            ),
                            title: 'Phone Number',
                            value: user.phoneNumber,
                          ),
                          const SizedBox(height: 12),
                          _buildInfoCard(
                            icon: PhosphorIcons.calendar(
                              PhosphorIconsStyle.regular,
                            ),
                            title: 'Date of Birth',
                            value: DateFormat(
                              'MMMM dd, yyyy',
                            ).format(user.dateOfBirth),
                          ),

                          const SizedBox(height: 24),

                          // Health Information Section
                          _buildSectionTitle('Health Information'),
                          const SizedBox(height: 12),
                          _buildHealthQuestionCard(
                            icon: PhosphorIcons.heartbeat(
                              PhosphorIconsStyle.regular,
                            ),
                            question: 'Do you have any medical conditions?',
                            answer: medicalConditions,
                            onTap: () => _showEditDialog(
                              context,
                              'Medical Conditions',
                              medicalConditions,
                              (value) =>
                                  setState(() => medicalConditions = value),
                            ),
                          ),
                          const SizedBox(height: 12),
                          _buildHealthQuestionCard(
                            icon: PhosphorIcons.warning(
                              PhosphorIconsStyle.regular,
                            ),
                            question: 'Do you have any allergies?',
                            answer: allergies,
                            onTap: () => _showEditDialog(
                              context,
                              'Allergies',
                              allergies,
                              (value) => setState(() => allergies = value),
                            ),
                          ),
                          const SizedBox(height: 12),
                          _buildHealthQuestionCard(
                            icon: PhosphorIcons.firstAid(
                              PhosphorIconsStyle.regular,
                            ),
                            question:
                                'Any past surgeries except hair transplant?',
                            answer: pastSurgeries,
                            onTap: () => _showEditDialog(
                              context,
                              'Past Surgeries',
                              pastSurgeries,
                              (value) => setState(() => pastSurgeries = value),
                            ),
                          ),
                          const SizedBox(height: 12),
                          _buildHealthQuestionCard(
                            icon: PhosphorIcons.pill(
                              PhosphorIconsStyle.regular,
                            ),
                            question: 'Current medications?',
                            answer: currentMedications,
                            onTap: () => _showEditDialog(
                              context,
                              'Current Medications',
                              currentMedications,
                              (value) =>
                                  setState(() => currentMedications = value),
                            ),
                          ),

                          const SizedBox(height: 32),

                          // Edit Profile Button
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              onPressed: () {
                                // TODO: Navigate to edit profile page
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      'Edit profile feature coming soon!',
                                    ),
                                  ),
                                );
                              },
                              icon: PhosphorIcon(
                                PhosphorIcons.pencilSimple(
                                  PhosphorIconsStyle.regular,
                                ),
                                color: Colors.white,
                              ),
                              label: const Text('Edit Profile'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: ThemeConstants.primaryColor,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 16,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            ),
                          ),

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

  Widget _buildProfileCompletionCard(int percentage) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            ThemeConstants.secondaryColor,
            ThemeConstants.secondaryColor.withOpacity(0.8),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: ThemeConstants.secondaryColor.withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Profile Completion',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              Text(
                '$percentage%',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: percentage / 100,
              minHeight: 10,
              backgroundColor: Colors.white.withOpacity(0.3),
              valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            percentage == 100
                ? '🎉 Your profile is complete!'
                : 'Complete your health information to get personalized care',
            style: TextStyle(
              fontSize: 13,
              color: Colors.white.withOpacity(0.9),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildHealthQuestionCard({
    required IconData icon,
    required String question,
    required String? answer,
    required VoidCallback onTap,
  }) {
    final hasAnswer = answer != null && answer.isNotEmpty;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: hasAnswer
                ? ThemeConstants.secondaryColor.withOpacity(0.3)
                : Colors.grey.withOpacity(0.2),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: hasAnswer
                    ? ThemeConstants.secondaryColor.withOpacity(0.1)
                    : Colors.grey.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: PhosphorIcon(
                icon,
                color: hasAnswer
                    ? ThemeConstants.secondaryColor
                    : Colors.grey[600],
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    question,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    hasAnswer ? answer : 'Tap to answer',
                    style: TextStyle(
                      fontSize: 13,
                      color: hasAnswer ? Colors.black54 : Colors.grey[400],
                      fontStyle: hasAnswer
                          ? FontStyle.normal
                          : FontStyle.italic,
                    ),
                  ),
                ],
              ),
            ),
            PhosphorIcon(
              PhosphorIcons.pencilSimple(PhosphorIconsStyle.regular),
              color: ThemeConstants.secondaryColor,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }

  void _showEditDialog(
    BuildContext context,
    String title,
    String? currentValue,
    Function(String) onSave,
  ) {
    final controller = TextEditingController(text: currentValue ?? '');

    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: Text(title),
          content: TextField(
            controller: controller,
            maxLines: 3,
            decoration: InputDecoration(
              hintText: 'Enter your answer...',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                onSave(controller.text);
                await _saveHealthData();
                if (dialogContext.mounted) {
                  Navigator.pop(dialogContext);
                }
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Information saved successfully!'),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: ThemeConstants.primaryColor,
                foregroundColor: Colors.white,
              ),
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildSectionTitle(String title) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: ThemeConstants.secondaryColor,
        ),
      ),
    );
  }

  Widget _buildInfoCard({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Container(
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
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: ThemeConstants.primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: PhosphorIcon(
              icon,
              color: ThemeConstants.primaryColor,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
