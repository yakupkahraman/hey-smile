import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:hey_smile/features/tracker/presentation/widgets/fab_menu.dart';

class TrackerPage extends StatefulWidget {
  const TrackerPage({super.key});

  @override
  State<TrackerPage> createState() => _TrackerPageState();
}

class _TrackerPageState extends State<TrackerPage>
    with SingleTickerProviderStateMixin {
  DateTime _selectedDay = DateTime.now();
  DateTime _focusedDay = DateTime.now();
  CalendarFormat _calendarFormat = CalendarFormat.month;

  final ScrollController _scrollController = ScrollController();
  bool _isCalendarExpanded = true;

  late Animation<double> _animation;
  late AnimationController _animationController;

  // Reminder'ları saklamak için map (tarih -> reminder listesi)
  final Map<DateTime, List<String>> _reminders = {};

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 260),
    );

    final curvedAnimation = CurvedAnimation(
      curve: Curves.easeInOut,
      parent: _animationController,
    );
    _animation = Tween<double>(begin: 0, end: 1).animate(curvedAnimation);
  }

  void _onScroll() {
    if (_scrollController.offset > 50 && _isCalendarExpanded) {
      setState(() {
        _isCalendarExpanded = false;
      });
    } else if (_scrollController.offset <= 50 && !_isCalendarExpanded) {
      setState(() {
        _isCalendarExpanded = true;
      });
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  List<String> _getRemindersForDay(DateTime day) {
    final normalizedDay = DateTime(day.year, day.month, day.day);
    return _reminders[normalizedDay] ?? [];
  }

  void _addReminder(String reminder) {
    final normalizedDay = DateTime(
      _selectedDay.year,
      _selectedDay.month,
      _selectedDay.day,
    );

    setState(() {
      if (_reminders[normalizedDay] == null) {
        _reminders[normalizedDay] = [];
      }
      _reminders[normalizedDay]!.add(reminder);
    });
  }

  void _showAddReminderDialog() {
    final TextEditingController controller = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('New Reminder'),
          content: TextField(
            controller: controller,
            decoration: const InputDecoration(
              hintText: 'Enter reminder',
              border: OutlineInputBorder(),
            ),
            maxLines: 3,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                if (controller.text.trim().isNotEmpty) {
                  _addReminder(controller.text.trim());
                  Navigator.pop(context);
                }
              },
              child: const Text('Add'),
            ),
          ],
        );
      },
    );
  }

  void _deleteReminder(int index) {
    final normalizedDay = DateTime(
      _selectedDay.year,
      _selectedDay.month,
      _selectedDay.day,
    );

    setState(() {
      _reminders[normalizedDay]?.removeAt(index);
      if (_reminders[normalizedDay]?.isEmpty ?? false) {
        _reminders.remove(normalizedDay);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final selectedDayReminders = _getRemindersForDay(_selectedDay);

    return Scaffold(
      body: SafeArea(
        child: CustomScrollView(
          controller: _scrollController,
          slivers: [
            // Takvim Bölümü
            SliverToBoxAdapter(
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: TableCalendar(
                  firstDay: DateTime.utc(2020, 1, 1),
                  lastDay: DateTime.utc(2030, 12, 31),
                  focusedDay: _focusedDay,
                  selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
                  calendarFormat: _isCalendarExpanded
                      ? _calendarFormat
                      : CalendarFormat.week,
                  onDaySelected: (selectedDay, focusedDay) {
                    setState(() {
                      _selectedDay = selectedDay;
                      _focusedDay = focusedDay;
                    });
                  },
                  onFormatChanged: (format) {
                    if (_isCalendarExpanded) {
                      setState(() {
                        _calendarFormat = format;
                      });
                    }
                  },
                  onPageChanged: (focusedDay) {
                    _focusedDay = focusedDay;
                  },
                  eventLoader: (day) {
                    return _getRemindersForDay(day);
                  },
                  calendarStyle: CalendarStyle(
                    todayDecoration: BoxDecoration(
                      color: Theme.of(
                        context,
                      ).colorScheme.primary.withOpacity(0.5),
                      shape: BoxShape.circle,
                    ),
                    selectedDecoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primary,
                      shape: BoxShape.circle,
                    ),
                    markerDecoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.secondary,
                      shape: BoxShape.circle,
                    ),
                  ),
                  headerStyle: HeaderStyle(
                    formatButtonVisible: _isCalendarExpanded,
                    titleCentered: true,
                  ),
                ),
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 16)),

            // Seçili Günün Reminder Başlığı
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Row(
                  children: [
                    const Icon(Icons.event_note, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      '${_selectedDay.day}/${_selectedDay.month}/${_selectedDay.year}',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.blue.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '${selectedDayReminders.length} reminder${selectedDayReminders.length != 1 ? 's' : ''}',
                        style: TextStyle(
                          color: Colors.blue.shade700,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 8)),

            // Reminder Listesi
            selectedDayReminders.isEmpty
                ? SliverFillRemaining(
                    hasScrollBody: false,
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.event_available,
                            size: 64,
                            color: Colors.grey.shade300,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No reminders for this day',
                            style: TextStyle(
                              color: Colors.grey.shade600,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Tap the + button to add one',
                            style: TextStyle(
                              color: Colors.grey.shade400,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                : SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate((context, index) {
                        return Card(
                          margin: const EdgeInsets.only(bottom: 8),
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor: Colors.blue.shade100,
                              child: Icon(
                                Icons.notifications_active,
                                color: Colors.blue.shade700,
                                size: 20,
                              ),
                            ),
                            title: Text(selectedDayReminders[index]),
                            trailing: IconButton(
                              icon: const Icon(
                                Icons.delete_outline,
                                color: Colors.red,
                              ),
                              onPressed: () => _deleteReminder(index),
                            ),
                          ),
                        );
                      }, childCount: selectedDayReminders.length),
                    ),
                  ),
          ],
        ),
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 90.0),
        child: FloatingActionBubble(
          items: <Bubble>[
            Bubble(
              title: "Add Reminder",
              iconColor: Colors.white,
              bubbleColor: Theme.of(context).colorScheme.secondary,
              icon: Icons.add_alert,
              titleStyle: const TextStyle(fontSize: 16, color: Colors.white),
              onPress: () {
                _animationController.reverse();
                _showAddReminderDialog();
              },
            ),
            Bubble(
              title: "Add Photo",
              iconColor: Colors.white,
              bubbleColor: Theme.of(context).colorScheme.secondary,
              icon: Icons.add_a_photo,
              titleStyle: const TextStyle(fontSize: 16, color: Colors.white),
              onPress: () {},
            ),

            // İsterseniz daha fazla menü öğesi ekleyebilirsiniz
            // Bubble(
            //   title: "Tümünü Göster",
            //   iconColor: Colors.white,
            //   bubbleColor: Colors.green,
            //   icon: Icons.event_note,
            //   titleStyle: const TextStyle(fontSize: 16, color: Colors.white),
            //   onPress: () {
            //     _animationController.reverse();
            //     // Başka bir işlem
            //   },
            // ),
          ],
          animation: _animation,
          onPress: () {
            if (_animationController.isCompleted) {
              _animationController.reverse();
            } else {
              _animationController.forward();
            }
          },
          iconColor: Colors.white,
          backGroundColor: Theme.of(context).colorScheme.secondary,
          animatedIconData: AnimatedIcons.add_event,
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }
}
