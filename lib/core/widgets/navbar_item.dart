import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../../core/constants.dart';

class NavItem extends StatefulWidget {
  final int index;
  final PhosphorIconData unSelectedIcon;
  final PhosphorIconData selectedIcon;
  final bool isSelected;
  final VoidCallback onTap;
  final String? label;
  final bool? centerItem;

  const NavItem({
    super.key,
    required this.index,
    required this.isSelected,
    required this.onTap,
    required this.unSelectedIcon,
    required this.selectedIcon,
    this.label,
    this.centerItem,
  });

  @override
  State<NavItem> createState() => _NavItemState();
}

class _NavItemState extends State<NavItem> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: Container(
        decoration: BoxDecoration(
          color: widget.centerItem == true
              ? ThemeConstants.secondaryColor
              : Colors.transparent,
          shape: BoxShape.circle,
        ),
        child: Padding(
          padding: EdgeInsets.all(widget.centerItem == true ? 14 : 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              PhosphorIcon(
                widget.isSelected ? widget.selectedIcon : widget.unSelectedIcon,
                size: 26,
                color: widget.isSelected
                    ? Colors.white
                    : (widget.centerItem == true ? Colors.white : Colors.grey),
              ),
              if (widget.centerItem != true && widget.label != null)
                Padding(
                  padding: const EdgeInsets.only(top: 5.0),
                  child: Text(
                    widget.label!,
                    style: TextStyle(
                      color: widget.isSelected ? Colors.white : Colors.grey,
                      fontSize: 9,
                      fontFamily: 'Poppins',
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
