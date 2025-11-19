import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hey_smile/core/constants.dart';
import 'package:hey_smile/core/widgets/navbar_item.dart';
import 'package:hey_smile/features/auth/presentation/providers/auth_provider.dart';
import 'package:hey_smile/features/home/presentation/providers/page_provider.dart';
import 'package:provider/provider.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

class ShellPage extends StatelessWidget {
  final Widget child;

  const ShellPage({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => PageProvider(),
      child: Consumer<PageProvider>(
        builder: (context, pageProvider, _) {
          final currentLocation = GoRouterState.of(context).matchedLocation;

          return Scaffold(
            extendBodyBehindAppBar: true,
            extendBody: true,
            appBar: appBar(context),
            drawer: drawer(context),
            body: child,
            bottomNavigationBar: SafeArea(
              child: Container(
                height: 76,
                decoration: BoxDecoration(
                  color: ThemeConstants.primaryColor,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.3),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      Expanded(
                        child: NavItem(
                          index: 0,
                          label: 'Home',
                          isSelected: currentLocation == '/home',
                          onTap: () => context.go('/home'),
                          unSelectedIcon: PhosphorIcons.house(
                            PhosphorIconsStyle.regular,
                          ),
                          selectedIcon: PhosphorIcons.house(
                            PhosphorIconsStyle.fill,
                          ),
                        ),
                      ),
                      Expanded(
                        child: NavItem(
                          index: 1,
                          label: 'Tracker',
                          isSelected: currentLocation == '/tracker',
                          onTap: () => context.go('/tracker'),
                          unSelectedIcon: PhosphorIcons.calendar(
                            PhosphorIconsStyle.regular,
                          ),
                          selectedIcon: PhosphorIcons.calendar(
                            PhosphorIconsStyle.fill,
                          ),
                        ),
                      ),
                      Expanded(
                        child: NavItem(
                          index: 2,
                          isSelected: currentLocation == '/capture',
                          onTap: () => context.push('/capture'),
                          unSelectedIcon: PhosphorIcons.camera(
                            PhosphorIconsStyle.regular,
                          ),
                          selectedIcon: PhosphorIcons.camera(
                            PhosphorIconsStyle.fill,
                          ),
                          centerItem: true,
                        ),
                      ),
                      Expanded(
                        child: NavItem(
                          index: 3,
                          label: 'Treatments',
                          isSelected: currentLocation == '/treatments',
                          onTap: () => context.go('/treatments'),
                          unSelectedIcon: PhosphorIcons.heartbeat(
                            PhosphorIconsStyle.regular,
                          ),
                          selectedIcon: PhosphorIcons.heartbeat(
                            PhosphorIconsStyle.fill,
                          ),
                        ),
                      ),
                      Expanded(
                        child: NavItem(
                          index: 4,
                          label: 'Hair Care',
                          isSelected: currentLocation == '/shop',
                          onTap: () => context.go('/shop'),
                          unSelectedIcon: PhosphorIcons.shoppingCart(
                            PhosphorIconsStyle.regular,
                          ),
                          selectedIcon: PhosphorIcons.shoppingCart(
                            PhosphorIconsStyle.fill,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  AppBar appBar(BuildContext context) => AppBar(
    title: const Text(
      'heySMILE',
      style: TextStyle(
        fontFamily: 'Poppins',
        color: ThemeConstants.backgroundColor,
      ),
    ),
    centerTitle: false,
    leading: Builder(
      builder: (BuildContext context) {
        return IconButton(
          onPressed: () => Scaffold.of(context).openDrawer(),
          icon: PhosphorIcon(PhosphorIcons.list(PhosphorIconsStyle.regular)),
        );
      },
    ),
  );

  Drawer drawer(BuildContext context) => Drawer(
    child: SafeArea(
      child: Column(
        children: [
          // Header
          Container(
            width: double.infinity,
            padding: const EdgeInsets.only(top: 70, left: 10, bottom: 10),
            decoration: BoxDecoration(color: ThemeConstants.primaryColor),
            child: SafeArea(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  RichText(
                    text: TextSpan(
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                      ),
                      children: [
                        TextSpan(
                          text: 'hey',
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.secondary,
                          ),
                        ),
                        TextSpan(
                          text: 'SMILE',
                          style: TextStyle(color: Colors.white),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Menu Items
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                ListTile(
                  leading: PhosphorIcon(
                    PhosphorIcons.user(PhosphorIconsStyle.regular),
                  ),
                  title: const Text('Profile'),
                  onTap: () {
                    Navigator.pop(context);
                    context.go('/profile');
                  },
                ),
                ListTile(
                  leading: PhosphorIcon(
                    PhosphorIcons.chartLine(PhosphorIconsStyle.regular),
                  ),
                  title: const Text('Analysis'),
                  onTap: () {
                    Navigator.pop(context);
                    // TODO: Navigate to analysis page
                  },
                ),
                ListTile(
                  leading: PhosphorIcon(
                    PhosphorIcons.translate(PhosphorIconsStyle.regular),
                  ),
                  title: const Text('Language'),
                  onTap: () {
                    Navigator.pop(context);
                    // TODO: Show language picker
                  },
                ),
                ListTile(
                  leading: PhosphorIcon(
                    PhosphorIcons.bellRinging(PhosphorIconsStyle.regular),
                  ),
                  title: const Text('Notifications'),
                  onTap: () {
                    Navigator.pop(context);
                    // TODO: Show language picker
                  },
                ),
                ListTile(
                  leading: PhosphorIcon(
                    PhosphorIcons.lock(PhosphorIconsStyle.regular),
                  ),
                  title: const Text('Privacy & Terms'),
                  onTap: () {
                    Navigator.pop(context);
                    // TODO: Show privacy & terms
                  },
                ),
                ListTile(
                  leading: PhosphorIcon(
                    PhosphorIcons.envelope(PhosphorIconsStyle.regular),
                  ),
                  title: const Text('Contact Us'),
                  onTap: () {
                    Navigator.pop(context);
                    // TODO: Navigate to contact page
                  },
                ),
              ],
            ),
          ),
          // Logout at bottom
          const Divider(height: 1),
          ListTile(
            leading: PhosphorIcon(
              PhosphorIcons.signOut(PhosphorIconsStyle.regular),
              color: Colors.red,
            ),
            title: const Text('Log Out', style: TextStyle(color: Colors.red)),
            onTap: () async {
              try {
                await context.read<AuthProvider>().logout();
                if (context.mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Başarıyla çıkış yapıldı'),
                      backgroundColor: Colors.green,
                    ),
                  );
                  context.go('/auth');
                }
              } catch (e) {
                if (context.mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(e.toString()),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
          ),
          const SizedBox(height: 10),
        ],
      ),
    ),
  );
}
