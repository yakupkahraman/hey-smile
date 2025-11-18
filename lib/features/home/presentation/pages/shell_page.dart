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
                height: 84,
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
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 10,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      NavItem(
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
                      NavItem(
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
                      NavItem(
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
                      NavItem(
                        index: 3,
                        label: 'Treatments',
                        isSelected: currentLocation == '/treatments',
                        onTap: () => context.go('/treatments'),
                        unSelectedIcon: PhosphorIcons.handHeart(
                          PhosphorIconsStyle.regular,
                        ),
                        selectedIcon: PhosphorIcons.handHeart(
                          PhosphorIconsStyle.fill,
                        ),
                      ),
                      NavItem(
                        index: 4,
                        label: 'Shop',
                        isSelected: currentLocation == '/shop',
                        onTap: () => context.go('/shop'),
                        unSelectedIcon: PhosphorIcons.shoppingCart(
                          PhosphorIconsStyle.regular,
                        ),
                        selectedIcon: PhosphorIcons.shoppingCart(
                          PhosphorIconsStyle.fill,
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
      'HeySmile',
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
    child: Column(
      children: [
        ListTile(
          leading: const Icon(Icons.exit_to_app),
          title: const Text('Çıkış Yap'),
          onTap: () async {
            try {
              await context.read<AuthProvider>().logout();
              if (context.mounted) {
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
      ],
    ),
  );
}
